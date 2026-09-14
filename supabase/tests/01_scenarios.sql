-- =============================================================================
-- Tests de scénario — vérifient les règles métier qui posaient problème
-- dans l'application Power Apps. À rejouer après toute modification du schéma.
--   psql -f supabase/tests/01_scenarios.sql
-- =============================================================================
\set ON_ERROR_STOP on
begin;

-- Personnel de test
insert into utilisateurs (id, nom, role) values
  ('11111111-1111-1111-1111-111111111111', 'Miguel',   'technicien'),
  ('22222222-2222-2222-2222-222222222222', 'Victoria', 'gouvernante');

-- ---------------------------------------------------------------------------
-- SCÉNARIO 1 — Bouteilles : une perte ne doit déduire qu'UNE bouteille du parc,
-- même quand la chambre est immédiatement re-dotée. C'était le bug d'origine.
-- ---------------------------------------------------------------------------
-- Livraison de 100 bouteilles de chaque type en réserve
insert into mouvements_bouteilles (type, bouteille_type_id, quantite, de_lieu, vers_lieu)
select 'entree', id, 100, 'hors_parc', 'reserve' from bouteille_types;

-- Dotation initiale : 1 de chaque dans chacune des 37 chambres
insert into mouvements_bouteilles (type, bouteille_type_id, quantite, de_lieu, vers_lieu, vers_emplacement_id)
select 'dotation', d.bouteille_type_id, d.quantite, 'reserve', 'emplacement', d.emplacement_id
from dotations d;

do $$
declare v record;
begin
  select * into v from v_stock_bouteilles where code = 'filtree';
  assert v.parc_total = 100, format('parc après dotation = %s, attendu 100', v.parc_total);
  assert v.en_chambre = 37,  format('en chambre = %s, attendu 37', v.en_chambre);
  assert v.en_reserve = 63,  format('en réserve = %s, attendu 63', v.en_reserve);
end $$;

-- Incident : un client casse la bouteille filtrée de la chambre 32
insert into incidents_bouteille (emplacement_id, bouteille_type_id, cause, constate_par)
select e.id, bt.id, 'client_casse', '22222222-2222-2222-2222-222222222222'
from emplacements e, bouteille_types bt
where e.code = '32' and bt.code = 'filtree';

-- Re-dotation immédiate de la chambre depuis la réserve
select fn_redoter_emplacement(
  (select id from emplacements    where code = '32'),
  (select id from bouteille_types where code = 'filtree'),
  1,
  '22222222-2222-2222-2222-222222222222'
);

do $$
declare v record;
begin
  select * into v from v_stock_bouteilles where code = 'filtree';
  -- UNE seule bouteille sortie du parc, malgré les deux mouvements enregistrés
  assert v.parc_total = 99, format('parc après incident = %s, attendu 99 (déduction unique)', v.parc_total);
  assert v.en_chambre = 37, format('en chambre = %s, attendu 37 (chambre re-dotée)', v.en_chambre);
  assert v.en_reserve = 62, format('en réserve = %s, attendu 62', v.en_reserve);
end $$;

-- Le dossier part en arbitrage, il n'est pas facturé automatiquement
do $$
declare v record;
begin
  select * into v from v_incidents_bouteille limit 1;
  assert v.statut = 'a_transmettre', format('statut = %s, attendu a_transmettre', v.statut);
  assert v.montant = 17.50,          format('montant = %s, attendu 17.50', v.montant);
  assert v.facturable_client,        'une casse client doit être facturable';
end $$;

-- ---------------------------------------------------------------------------
-- SCÉNARIO 2 — Intervention : coût matériel calculé, et les deux avis conservés
-- quand la gouvernante refuse ce que le technicien a déclaré fait.
-- ---------------------------------------------------------------------------
insert into produits (code, designation, prix_unitaire, seuil_alerte) values
  ('JNT-12', 'Joint 12mm',    2.50, 10),
  ('FLX-40', 'Flexible 40cm', 8.90,  5);

-- Comptage physique initial : le stock ne part pas d'un chiffre figé
insert into mouvements_stock (produit_id, type, quantite, commentaire)
select id, 'entree', 20, 'Comptage physique initial' from produits;

insert into anomalies (id, emplacement_id, description, declare_par)
select '33333333-3333-3333-3333-333333333333', id, 'Fuite lavabo',
       '11111111-1111-1111-1111-111111111111'
from emplacements where code = '32';

insert into interventions (id, anomalie_id, technicien_id, cout_prestataire, cout_libre, cout_libre_motif)
values ('44444444-4444-4444-4444-444444444444',
        '33333333-3333-3333-3333-333333333333',
        '11111111-1111-1111-1111-111111111111',
        0, 5.00, 'Taxi pour pièce urgente');

-- Sorties de stock rattachées à l'intervention : 2 joints + 1 flexible
insert into mouvements_stock (produit_id, type, quantite, intervention_id, utilisateur_id)
select p.id, 'sortie', q.qte, '44444444-4444-4444-4444-444444444444',
       '11111111-1111-1111-1111-111111111111'
from (values ('JNT-12', -2), ('FLX-40', -1)) as q (code, qte)
join produits p on p.code = q.code;

do $$
declare v record;
begin
  select * into v from v_interventions_cout
   where intervention_id = '44444444-4444-4444-4444-444444444444';
  -- 2 × 2,50 + 1 × 8,90 = 13,90
  assert v.cout_materiel = 13.90, format('coût matériel = %s, attendu 13.90', v.cout_materiel);
  assert v.cout_total    = 18.90, format('coût total = %s, attendu 18.90', v.cout_total);

  assert (select stock from v_stock_produits where code = 'JNT-12') = 18, 'stock joint attendu 18';
end $$;

-- Le technicien déclare fait => l'anomalie passe en attente de validation
insert into validations (intervention_id, acteur, decision, utilisateur_id, commentaire)
values ('44444444-4444-4444-4444-444444444444', 'technicien', 'fait',
        '11111111-1111-1111-1111-111111111111', 'Joint changé');

do $$ begin
  assert (select statut from anomalies where id = '33333333-3333-3333-3333-333333333333')
         = 'attente_validation', 'statut attendu attente_validation';
end $$;

-- La gouvernante refuse => retour à « à faire », avis du technicien conservé
insert into validations (intervention_id, acteur, decision, utilisateur_id, commentaire)
values ('44444444-4444-4444-4444-444444444444', 'gouvernante', 'refusee',
        '22222222-2222-2222-2222-222222222222', 'Fuite toujours présente');

do $$
declare v record;
begin
  assert (select statut from anomalies where id = '33333333-3333-3333-3333-333333333333')
         = 'a_faire', 'un refus doit renvoyer l''anomalie en a_faire';

  select * into v from v_recap_interventions
   where intervention_id = '44444444-4444-4444-4444-444444444444';
  assert v.decision_technicien  = 'fait',    'l''avis du technicien doit être conservé';
  assert v.decision_gouvernante = 'refusee', 'l''avis de la gouvernante doit être conservé';
  assert v.refusee_par_gouvernante,          'le récapitulatif doit signaler le refus';
  assert v.technicien = 'Miguel' and v.gouvernante = 'Victoria', 'les deux noms doivent apparaître';
end $$;

-- ---------------------------------------------------------------------------
-- SCÉNARIO 3 — Inventaire matériel : un écart ne corrige pas le stock en douce,
-- il crée une régularisation datée et nominative.
-- ---------------------------------------------------------------------------
insert into inventaires (id, type, libelle, ouvert_par)
values ('55555555-5555-5555-5555-555555555555', 'materiel', 'Inventaire du mois',
        '22222222-2222-2222-2222-222222222222');

-- Théorique 18 joints, on n'en compte que 15
insert into inventaire_lignes_produit (inventaire_id, produit_id, quantite_theorique, quantite_comptee)
select '55555555-5555-5555-5555-555555555555', id, 18, 15 from produits where code = 'JNT-12';

update inventaires
   set statut = 'valide', valide_par = '22222222-2222-2222-2222-222222222222', valide_le = now()
 where id = '55555555-5555-5555-5555-555555555555';

do $$
declare v_stock numeric; v_nb int;
begin
  select stock into v_stock from v_stock_produits where code = 'JNT-12';
  assert v_stock = 15, format('stock après inventaire = %s, attendu 15', v_stock);

  select count(*) into v_nb from mouvements_stock
   where type = 'regularisation' and inventaire_id = '55555555-5555-5555-5555-555555555555';
  assert v_nb = 1, 'l''écart doit laisser exactement une régularisation tracée';
end $$;

\echo '✅ Tous les scénarios sont passés'
rollback;
