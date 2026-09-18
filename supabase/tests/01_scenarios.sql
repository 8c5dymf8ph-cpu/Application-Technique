-- =============================================================================
-- Tests de scénario — verrouillent les règles métier réelles de l'hôtel.
-- À rejouer après toute modification du schéma.
--   psql -f supabase/tests/01_scenarios.sql
-- =============================================================================
\set ON_ERROR_STOP on
begin;

-- Des noms qui ne peuvent pas entrer en collision avec le personnel réel :
-- les scénarios doivent passer sur une base vierge comme sur la base reprise.
insert into utilisateurs (id, nom, role) values
  ('11111111-1111-1111-1111-111111111111', 'Technicien de test',  'technicien'),
  ('22222222-2222-2222-2222-222222222222', 'Gouvernante de test', 'gouvernante');

insert into prestataires (id, nom, specialite) values
  ('99999999-9999-9999-9999-999999999999', 'Prestataire de test', 'Plomberie');

-- ===========================================================================
-- SCÉNARIO 1 — Bouteilles : les quatre situations réelles de l'hôtel.
-- ===========================================================================

-- Ces scénarios doivent pouvoir se rejouer sur N'IMPORTE QUELLE base, y compris
-- celle de l'hôtel avec son parc réel. On prend donc un repère avant de toucher
-- à quoi que ce soit, et tout ce qui suit se mesure en ÉCART par rapport à lui.
create temporary table repere_bouteilles on commit drop as
select code, en_reserve, en_chambre, chez_clients, parc_detenu, parc_theorique
from v_stock_bouteilles;

create or replace function ecart_bouteilles(p_code text)
returns table (en_reserve int, en_chambre int, chez_clients int,
               parc_detenu int, parc_theorique int)
language sql as $f$
  select (v.en_reserve - r.en_reserve)::int, (v.en_chambre - r.en_chambre)::int,
         (v.chez_clients - r.chez_clients)::int, (v.parc_detenu - r.parc_detenu)::int,
         (v.parc_theorique - r.parc_theorique)::int
  from v_stock_bouteilles v join repere_bouteilles r on r.code = v.code
  where v.code = p_code;
$f$;

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
  select * into v from ecart_bouteilles('filtree');
  assert v.en_reserve = 63 and v.en_chambre = 37 and v.chez_clients = 0 and v.parc_detenu = 100,
    format('après dotation : réserve %s, chambre %s, clients %s, détenu %s (en écart)',
           v.en_reserve, v.en_chambre, v.chez_clients, v.parc_detenu);
end $$;

-- ---------------------------------------------------------------------------
-- Cas A — Un client emporte la bouteille filtrée de la 32. La gouvernante le
-- signale, la chambre est re-dotée. Rien n'est encore perdu : la bouteille est
-- « chez le client » et peut revenir.
-- ---------------------------------------------------------------------------
insert into incidents_bouteille (id, emplacement_id, nature, responsable, constate_par)
select 'aaaaaaaa-0000-0000-0000-000000000001', e.id, 'emport', 'client',
       '22222222-2222-2222-2222-222222222222'
from emplacements e where e.code = '32';
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select 'aaaaaaaa-0000-0000-0000-000000000001', bt.id, 1
from bouteille_types bt where bt.code = 'filtree';

do $$
declare v record;
begin
  select * into v from ecart_bouteilles('filtree');
  assert v.en_reserve = 62,   format('réserve = %s, attendu 62 (une bouteille sortie pour re-doter)', v.en_reserve);
  assert v.en_chambre = 37,   format('chambre = %s, attendu 37 (la 32 est re-dotée)', v.en_chambre);
  assert v.chez_clients = 1,  format('chez clients = %s, attendu 1', v.chez_clients);
  -- La bouteille est partie : on ne l'a plus, même si elle peut revenir.
  assert v.parc_detenu = 99,  format('détenu = %s, attendu 99 : la bouteille n''est plus à nous', v.parc_detenu);
  assert v.parc_theorique = 100, format('théorique = %s, attendu 100 : rien n''est encore perdu', v.parc_theorique);
end $$;

-- ---------------------------------------------------------------------------
-- Cas A bis — Le client revient avec la bouteille. La chambre ayant déjà été
-- re-dotée, elle rejoint la RÉSERVE et non la chambre.
-- ---------------------------------------------------------------------------
update incidents_bouteille
   set statut = 'restitue', resolu_le = now(), resolu_par = '22222222-2222-2222-2222-222222222222'
 where id = 'aaaaaaaa-0000-0000-0000-000000000001';

do $$
declare v record;
begin
  select * into v from ecart_bouteilles('filtree');
  assert v.en_reserve = 63,  format('réserve = %s, attendu 63 (la bouteille rendue revient en stock)', v.en_reserve);
  assert v.en_chambre = 37,  format('chambre = %s, attendu 37 (inchangée)', v.en_chambre);
  assert v.chez_clients = 0, format('chez clients = %s, attendu 0', v.chez_clients);
  assert v.parc_detenu = 100, format('détenu = %s, attendu 100 : on la récupère', v.parc_detenu);
end $$;

-- ---------------------------------------------------------------------------
-- Cas B — Un client emporte la pétillante de la 14 et ne la rend pas : on la
-- lui facture. C'est seulement à cet instant qu'elle sort du parc.
-- ---------------------------------------------------------------------------
insert into incidents_bouteille (id, emplacement_id, nature, responsable, constate_par)
select 'aaaaaaaa-0000-0000-0000-000000000002', e.id, 'emport', 'client',
       '22222222-2222-2222-2222-222222222222'
from emplacements e where e.code = '14';
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select 'aaaaaaaa-0000-0000-0000-000000000002', bt.id, 1
from bouteille_types bt where bt.code = 'petillante';

do $$
declare v record;
begin
  select * into v from ecart_bouteilles('petillante');
  assert v.parc_detenu = 99 and v.chez_clients = 1 and v.parc_theorique = 100,
    format('en attente : détenu %s, chez clients %s, théorique %s',
           v.parc_detenu, v.chez_clients, v.parc_theorique);
end $$;

update incidents_bouteille
   set statut = 'facture', montant = 17.50, resolu_le = now(),
       resolu_par = '22222222-2222-2222-2222-222222222222'
 where id = 'aaaaaaaa-0000-0000-0000-000000000002';

do $$
declare v record;
begin
  select * into v from ecart_bouteilles('petillante');
  assert v.parc_detenu = 99 and v.parc_theorique = 99,
    format('après facturation : détenu %s, théorique %s — la perte est actée',
           v.parc_detenu, v.parc_theorique);
  assert v.en_reserve = 62,   format('réserve = %s, attendu 62', v.en_reserve);
  assert v.en_chambre = 37,   format('chambre = %s, attendu 37', v.en_chambre);
  assert v.chez_clients = 0,  format('chez clients = %s, attendu 0', v.chez_clients);
end $$;

-- ---------------------------------------------------------------------------
-- Cas C — Une femme de chambre casse la filtrée de la 21. Perte immédiate,
-- jamais facturée au client, valorisée au prix d'achat.
-- ---------------------------------------------------------------------------
insert into incidents_bouteille (id, emplacement_id, nature, responsable, constate_par)
select 'aaaaaaaa-0000-0000-0000-000000000003', e.id, 'casse', 'personnel',
       '22222222-2222-2222-2222-222222222222'
from emplacements e where e.code = '21';
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select 'aaaaaaaa-0000-0000-0000-000000000003', bt.id, 1
from bouteille_types bt where bt.code = 'filtree';

do $$
declare v record; v_incident record;
begin
  select * into v from ecart_bouteilles('filtree');
  assert v.parc_detenu = 99 and v.parc_theorique = 99,
    format('casse : détenu %s, théorique %s — sortie immédiate', v.parc_detenu, v.parc_theorique);
  assert v.en_reserve = 62,  format('réserve = %s, attendu 62 (chambre re-dotée)', v.en_reserve);
  assert v.en_chambre = 37,  format('chambre = %s, attendu 37', v.en_chambre);

  select * into v_incident from v_incidents_bouteille where reference =
    (select reference from incidents_bouteille where id = 'aaaaaaaa-0000-0000-0000-000000000003');
  assert not v_incident.facturable_client, 'une casse du personnel n''est pas facturable';
  assert v_incident.montant = 8.00, format('montant = %s, attendu 8.00 (prix d''achat)', v_incident.montant);
end $$;

-- Le schéma refuse de facturer une casse imputée au personnel
do $$
begin
  begin
    update incidents_bouteille set statut = 'facture'
     where id = 'aaaaaaaa-0000-0000-0000-000000000003';
    raise exception 'la facturation d''une casse du personnel aurait dû être refusée';
  exception when check_violation then
    null;  -- comportement attendu
  end;
end $$;

-- ---------------------------------------------------------------------------
-- Cas C bis — Une chambre perd les DEUX bouteilles d'un coup. C'est un seul
-- dossier, un seul montant, un seul mail — et deux lignes.
-- ---------------------------------------------------------------------------
insert into incidents_bouteille (id, emplacement_id, nature, responsable, client_nom, constate_par)
select 'aaaaaaaa-0000-0000-0000-000000000004', e.id, 'emport', 'client', 'Client de test',
       '22222222-2222-2222-2222-222222222222'
from emplacements e where e.code = '46';
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select 'aaaaaaaa-0000-0000-0000-000000000004', bt.id, 1 from bouteille_types bt;

do $$
declare v record; f record; g record;
begin
  select * into v from v_incidents_bouteille where id = 'aaaaaaaa-0000-0000-0000-000000000004';
  assert v.quantite = 2, format('quantité = %s, attendu 2', v.quantite);
  assert v.montant = 35.00, format('montant = %s, attendu 35.00 (2 × 17,50)', v.montant);
  assert jsonb_array_length(v.lignes) = 2,
    format('%s ligne(s) détaillée(s), attendu 2', jsonb_array_length(v.lignes));

  -- Les deux types ont bougé, chacun pour son compte.
  select * into f from ecart_bouteilles('filtree');
  select * into g from ecart_bouteilles('petillante');
  assert f.chez_clients = 1 and g.chez_clients = 1,
    format('chez clients : filtrée %s, gazeuse %s — attendu 1 et 1', f.chez_clients, g.chez_clients);
end $$;

-- Restitution : les deux reviennent, en une seule décision.
update incidents_bouteille
   set statut = 'restitue', resolu_le = now(), resolu_par = '22222222-2222-2222-2222-222222222222'
 where id = 'aaaaaaaa-0000-0000-0000-000000000004';

do $$
declare f record; g record;
begin
  select * into f from ecart_bouteilles('filtree');
  select * into g from ecart_bouteilles('petillante');
  assert f.chez_clients = 0 and g.chez_clients = 0,
    format('après restitution : filtrée %s, gazeuse %s chez clients — attendu 0',
           f.chez_clients, g.chez_clients);
end $$;

-- ---------------------------------------------------------------------------
-- Cas D — Une bouteille cassée ne peut pas être « restituée ».
-- ---------------------------------------------------------------------------
do $$
begin
  begin
    update incidents_bouteille set statut = 'restitue'
     where id = 'aaaaaaaa-0000-0000-0000-000000000003';
    raise exception 'la restitution d''une bouteille cassée aurait dû être refusée';
  exception when check_violation then
    null;
  end;
end $$;

-- ===========================================================================
-- SCÉNARIO 2 — Coût d'intervention : le technicien ne saisit aucun prix, et le
-- matériel reste consommé même si la gouvernante refuse l'intervention.
-- ===========================================================================
insert into fournisseurs (id, nom, email) values
  ('88888888-8888-8888-8888-888888888888', 'Fournisseur de test', 'contact@test.invalid');

insert into produits (code, designation, prix_unitaire, seuil_alerte) values
  ('JNT-12', 'Joint 12mm',    2.50, 10),
  ('FLX-40', 'Flexible 40cm', 8.90,  5),
  -- Prix inconnu : l'article ne doit pas être compté pour zéro en silence
  ('DIV-01', 'Pièce diverse', null,  2);

-- Uniquement les produits de ce scénario : les tests doivent passer aussi sur
-- une base contenant déjà les données reprises.
insert into article_fournisseurs (produit_id, fournisseur_id)
select id, '88888888-8888-8888-8888-888888888888'
from produits where code in ('JNT-12', 'FLX-40', 'DIV-01');

-- Comptage physique initial : le stock ne part pas d'un chiffre figé
insert into mouvements_stock (produit_id, type, quantite, commentaire)
select id, 'entree', 20, 'Comptage physique initial' from produits;

insert into anomalies (id, emplacement_id, description, constate_par)
select '33333333-3333-3333-3333-333333333333', id, 'Fuite lavabo',
       '22222222-2222-2222-2222-222222222222'
from emplacements where code = '32';

-- Le technicien ouvre une tournée : toutes les anomalies qu'il traite en une
-- fois y sont rattachées, comme l'InterventionID actuel.
do $$
declare v_tournee tournees;
begin
  v_tournee := fn_creer_tournee('11111111-1111-1111-1111-111111111111');
  assert v_tournee.reference like 'INT-TECHNICIEN-%',
    format('référence de tournée inattendue : %s', v_tournee.reference);
end $$;


insert into interventions (id, anomalie_id, tournee_id, technicien_id)
values ('44444444-4444-4444-4444-444444444444',
        '33333333-3333-3333-3333-333333333333',
        (select id from tournees limit 1),
        '11111111-1111-1111-1111-111111111111');

-- Le technicien coche le matériel utilisé — rien d'autre
insert into mouvements_stock (produit_id, type, quantite, intervention_id, utilisateur_id)
select p.id, 'sortie', q.qte, '44444444-4444-4444-4444-444444444444',
       '11111111-1111-1111-1111-111111111111'
from (values ('JNT-12', -2), ('FLX-40', -1), ('DIV-01', -1)) as q (code, qte)
join produits p on p.code = q.code;

do $$
declare v record;
begin
  select * into v from v_interventions_cout
   where intervention_id = '44444444-4444-4444-4444-444444444444';
  -- 2 × 2,50 + 1 × 8,90 = 13,90 ; la pièce sans prix n'est pas comptée pour zéro
  assert v.cout_materiel = 13.90,   format('coût matériel = %s, attendu 13.90', v.cout_materiel);
  assert v.articles_sans_prix = 1,  format('articles sans prix = %s, attendu 1', v.articles_sans_prix);
  assert v.cout_incomplet,          'le coût doit être signalé comme incomplet';
  assert (select stock from v_stock_produits where code = 'JNT-12') = 18, 'stock joint attendu 18';
end $$;

-- Le technicien déclare fait => attente de validation
insert into validations (intervention_id, acteur, decision, utilisateur_id, commentaire)
values ('44444444-4444-4444-4444-444444444444', 'technicien', 'fait',
        '11111111-1111-1111-1111-111111111111', 'Joint changé');

do $$ begin
  assert (select statut from anomalies where id = '33333333-3333-3333-3333-333333333333')
         = 'attente_validation', 'statut attendu attente_validation';
end $$;

-- La gouvernante refuse => retour en « à faire », avis du technicien conservé,
-- et le matériel déjà sorti reste consommé.
insert into validations (intervention_id, acteur, decision, utilisateur_id, commentaire)
values ('44444444-4444-4444-4444-444444444444', 'gouvernante', 'a_refaire',
        '22222222-2222-2222-2222-222222222222', 'Fuite toujours présente');

do $$
declare v record;
begin
  assert (select statut from anomalies where id = '33333333-3333-3333-3333-333333333333')
         = 'a_faire', 'un refus doit renvoyer l''anomalie en a_faire';
  assert (select stock from v_stock_produits where code = 'JNT-12') = 18,
         'un refus ne restitue pas le matériel utilisé';

  select * into v from v_recap_interventions
   where intervention_id = '44444444-4444-4444-4444-444444444444';
  assert v.decision_technicien  = 'fait',    'l''avis du technicien doit être conservé';
  assert v.decision_gouvernante = 'a_refaire', 'l''avis de la gouvernante doit être conservé';
  assert v.non_validee_par_gouvernante,        'le récapitulatif doit signaler la non-validation';
  assert v.intervenant = 'Technicien de test' and v.gouvernante = 'Gouvernante de test',
    'les deux noms doivent apparaître';
  assert v.tournee is not null,                'l''intervention doit porter sa tournée';
end $$;

-- Le fil de commentaires garde chaque avis avec son auteur et sa date, au lieu
-- d'empiler du texte dans un seul champ.
do $$
declare v_nb int;
begin
  select count(*) into v_nb from v_fil_commentaires
   where anomalie_id = '33333333-3333-3333-3333-333333333333';
  assert v_nb = 2, format('%s commentaires dans le fil, attendu 2 (technicien + gouvernante)', v_nb);
end $$;

-- Un commentaire libre s'ajoute à tout moment et ne remplace rien
do $$
declare v_nb int; v_textes text[];
begin
  insert into commentaires (anomalie_id, texte, auteur_id)
  values ('33333333-3333-3333-3333-333333333333', 'Le client se plaint à nouveau',
          '22222222-2222-2222-2222-222222222222');

  select count(*), array_agg(texte order by date_commentaire) into v_nb, v_textes
  from v_fil_commentaires where anomalie_id = '33333333-3333-3333-3333-333333333333';
  assert v_nb = 3, format('%s au fil, attendu 3', v_nb);
  assert 'Joint changé' = any (v_textes),
    'le commentaire du technicien doit rester lisible';
  assert 'Fuite toujours présente' = any (v_textes),
    'celui de la gouvernante aussi';
  assert 'Le client se plaint à nouveau' = any (v_textes),
    'et le commentaire ajouté après coup également';
end $$;

-- ===========================================================================
-- SCÉNARIO 3 — Facture de prestataire : une facture couvre TOUTES les
-- interventions faites par ce prestataire ce jour-là.
-- ===========================================================================
insert into anomalies (id, emplacement_id, description, constate_par)
select ('55555555-0000-0000-0000-00000000000' || n)::uuid, e.id,
       'Anomalie prestataire ' || n, '22222222-2222-2222-2222-222222222222'
from generate_series(1, 3) n
join lateral (select id from emplacements where code = '41') e on true;

insert into interventions (id, anomalie_id, prestataire_id, date_intervention)
select ('66666666-0000-0000-0000-00000000000' || n)::uuid,
       ('55555555-0000-0000-0000-00000000000' || n)::uuid,
       '99999999-9999-9999-9999-999999999999', date '2026-05-17'
from generate_series(1, 3) n;

-- La facture arrive douze jours après le passage, comme dans la vraie vie.
insert into factures (id, type, prestataire_id, reference, date_reference, montant_ht, statut)
values ('77777777-7777-7777-7777-777777777777', 'prestation',
        '99999999-9999-9999-9999-999999999999',
        'FA-2026-0512', date '2026-05-29', 450.00, 'a_rapprocher');

do $$
declare v_nb int; v_ecart int; v_journees int; v_intervenant text;
begin
  -- Le rapprochement se fait par journée d'intervenant, pas par tournée : les
  -- trois anomalies du 17 mai ne forment qu'UNE proposition.
  select count(*), max(ecart_jours), max(nb_anomalies), max(intervenant)
    into v_journees, v_ecart, v_nb, v_intervenant
  from fn_journees_rapprochables('77777777-7777-7777-7777-777777777777')
  where not deja_rapprochee;
  assert v_journees = 1, format('%s journées proposées, attendu 1', v_journees);
  assert v_nb = 3, format('%s anomalies dans la journée, attendu 3', v_nb);
  assert v_intervenant = 'Prestataire de test',
         format('journée attribuée à %s, attendu Prestataire de test', v_intervenant);
  assert v_ecart = 12, format('écart annoncé = %s jours, attendu 12', v_ecart);

  -- Une fenêtre trop courte ne doit rien proposer : c'est le garde-fou.
  select count(*) into v_journees
  from fn_journees_rapprochables('77777777-7777-7777-7777-777777777777', 5);
  assert v_journees = 0, format('%s journées proposées sur 5 jours, attendu 0', v_journees);

  -- Le détail de la journée retrouve bien les trois lignes.
  select count(*) into v_nb from fn_anomalies_de_la_journee(
    '99999999-9999-9999-9999-999999999999', date '2026-05-17');
  assert v_nb = 3, format('%s anomalies dans le détail de la journée, attendu 3', v_nb);

  -- Et tant que rien n'est rapproché, elles apparaissent dans le filet.
  select count(*) into v_nb from v_interventions_sans_facture
   where prestataire = 'Prestataire de test';
  assert v_nb = 3, format('%s interventions sans facture, attendu 3', v_nb);
end $$;

-- Rapprochement des trois interventions : 450 € répartis à parts égales
insert into facture_interventions (facture_id, intervention_id)
select '77777777-7777-7777-7777-777777777777',
       ('66666666-0000-0000-0000-00000000000' || n)::uuid
from generate_series(1, 3) n;

update factures set statut = 'rapprochee' where id = '77777777-7777-7777-7777-777777777777';

do $$
declare v_nb int;
begin
  select count(*) into v_nb from v_interventions_sans_facture
   where prestataire = 'Prestataire de test';
  assert v_nb = 0, format('%s interventions encore sans facture, attendu 0', v_nb);
end $$;

do $$
declare v record; v_total numeric;
begin
  select * into v from v_interventions_cout
   where intervention_id = '66666666-0000-0000-0000-000000000001';
  assert v.cout_prestataire = 150.00, format('coût prestataire = %s, attendu 150.00', v.cout_prestataire);

  select sum(cout_prestataire) into v_total from v_interventions_cout
   where intervention_id::text like '66666666%';
  assert v_total = 450.00, format('total réparti = %s, attendu 450.00', v_total);
end $$;

-- ===========================================================================
-- SCÉNARIO 4 — Inventaire matériel : un écart crée une régularisation tracée.
-- ===========================================================================
insert into inventaires (id, type, libelle, ouvert_par)
values ('aaaaaaaa-1111-1111-1111-111111111111', 'materiel', 'Inventaire du mois',
        '22222222-2222-2222-2222-222222222222');

insert into inventaire_lignes_produit (inventaire_id, produit_id, quantite_theorique, quantite_comptee)
select 'aaaaaaaa-1111-1111-1111-111111111111', id, 18, 15 from produits where code = 'JNT-12';

update inventaires
   set statut = 'valide', valide_par = '22222222-2222-2222-2222-222222222222', valide_le = now()
 where id = 'aaaaaaaa-1111-1111-1111-111111111111';

do $$
declare v_stock numeric; v_nb int;
begin
  select stock into v_stock from v_stock_produits where code = 'JNT-12';
  assert v_stock = 15, format('stock après inventaire = %s, attendu 15', v_stock);

  select count(*) into v_nb from mouvements_stock
   where type = 'regularisation' and inventaire_id = 'aaaaaaaa-1111-1111-1111-111111111111';
  assert v_nb = 1, 'l''écart doit laisser exactement une régularisation tracée';
end $$;

-- ===========================================================================
-- SCÉNARIO 5 — Réapprovisionnement : deux produits du même fournisseur sous le
-- seuil au même moment ne doivent produire qu'UNE demande de devis, donc un
-- seul mail.
-- ===========================================================================
-- On descend JNT-12 (seuil 10) et FLX-40 (seuil 5) sous leur seuil
insert into mouvements_stock (produit_id, type, quantite, intervention_id, utilisateur_id)
select p.id, 'sortie', q.qte, '44444444-4444-4444-4444-444444444444',
       '11111111-1111-1111-1111-111111111111'
from (values ('JNT-12', -8), ('FLX-40', -16)) as q (code, qte)
join produits p on p.code = q.code;

do $$
declare v_nb int;
begin
  select count(*) into v_nb from v_reappro_necessaire
   where fournisseur = 'Fournisseur de test';
  -- JNT-12 (7 <= 10), FLX-40 (3 <= 5) et DIV-01 (19 > 2, donc absent)
  assert v_nb = 2, format('%s articles sous seuil, attendu 2', v_nb);
end $$;

do $$
declare v_demandes int; v_lignes int;
begin
  perform fn_preparer_demandes_devis('22222222-2222-2222-2222-222222222222');

  select count(*) into v_demandes from demandes_devis d
   join fournisseurs f on f.id = d.fournisseur_id
   where f.nom = 'Fournisseur de test';
  assert v_demandes = 1, format('%s demandes de devis, attendu 1 seule pour ce fournisseur', v_demandes);

  select count(*) into v_lignes from demande_devis_lignes l
   join demandes_devis d on d.id = l.demande_id
   join fournisseurs f on f.id = d.fournisseur_id
   where f.nom = 'Fournisseur de test';
  assert v_lignes = 2, format('%s lignes dans le devis, attendu 2', v_lignes);
end $$;

-- Un second appel ne doit pas rouvrir un devis déjà en cours
do $$
declare v_demandes int;
begin
  perform fn_preparer_demandes_devis('22222222-2222-2222-2222-222222222222');
  select count(*) into v_demandes from demandes_devis d
   join fournisseurs f on f.id = d.fournisseur_id
   where f.nom = 'Fournisseur de test';
  assert v_demandes = 1, format('%s demandes après second appel, attendu 1', v_demandes);
end $$;

-- ===========================================================================
-- SCÉNARIO 6 — Tournée : le mail récapitulatif ne part que lorsque plus aucune
-- anomalie du lot n'est en attente, la gouvernante pouvant valider en plusieurs
-- fois. C'est la logique de l'InterventionID actuel.
-- ===========================================================================
do $$
declare
  v_tournee tournees;
  v_anomalie uuid;
  v_intervention uuid;
  v_etat record;
  n int;
begin
  v_tournee := fn_creer_tournee('11111111-1111-1111-1111-111111111111');

  -- Trois anomalies traitées dans la même tournée
  for n in 1..3 loop
    insert into anomalies (emplacement_id, description, constate_par)
    select id, 'Anomalie tournée ' || n, '22222222-2222-2222-2222-222222222222'
    from emplacements where code = '55'
    returning id into v_anomalie;

    insert into interventions (anomalie_id, tournee_id, technicien_id)
    values (v_anomalie, v_tournee.id, '11111111-1111-1111-1111-111111111111')
    returning id into v_intervention;

    insert into validations (intervention_id, acteur, decision, utilisateur_id)
    values (v_intervention, 'technicien', 'fait', '11111111-1111-1111-1111-111111111111');
  end loop;

  update tournees set cloturee_le = now() where id = v_tournee.id;

  select * into v_etat from v_tournees where id = v_tournee.id;
  assert v_etat.nb_interventions = 3, format('%s interventions, attendu 3', v_etat.nb_interventions);
  assert v_etat.nb_en_attente = 3,    format('%s en attente, attendu 3', v_etat.nb_en_attente);
  assert not v_etat.prete_pour_recap, 'la tournée ne doit pas être prête : rien n''est validé';

  -- La gouvernante traite deux anomalies, puis s'arrête : toujours pas de mail.
  insert into validations (intervention_id, acteur, decision, utilisateur_id)
  select i.id, 'gouvernante', 'validee', '22222222-2222-2222-2222-222222222222'
  from interventions i where i.tournee_id = v_tournee.id limit 2;

  select * into v_etat from v_tournees where id = v_tournee.id;
  assert v_etat.nb_en_attente = 1,    format('%s en attente, attendu 1', v_etat.nb_en_attente);
  assert not v_etat.prete_pour_recap, 'une anomalie reste en attente : pas de mail récap';

  -- Elle revient plus tard et traite la dernière, avec un avis différent.
  insert into validations (intervention_id, acteur, decision, utilisateur_id, commentaire)
  select i.id, 'gouvernante', 'a_refaire', '22222222-2222-2222-2222-222222222222', 'À reprendre'
  from interventions i
  where i.tournee_id = v_tournee.id
    and not exists (select 1 from validations v
                    where v.intervention_id = i.id and v.acteur = 'gouvernante');

  select * into v_etat from v_tournees where id = v_tournee.id;
  assert v_etat.nb_en_attente = 0,  format('%s en attente, attendu 0', v_etat.nb_en_attente);
  assert v_etat.prete_pour_recap,   'la tournée complète doit déclencher le mail récap';
  assert v_etat.nb_validees = 2,    format('%s validées, attendu 2', v_etat.nb_validees);
  assert v_etat.nb_a_refaire = 1,   format('%s à refaire, attendu 1', v_etat.nb_a_refaire);
  assert v_etat.mail_recap_envoye_le is null, 'le mail n''est pas encore parti';
end $$;

-- La décision « EN COURS » de la gouvernante remet bien l'anomalie en cours
do $$
declare v_anomalie uuid; v_intervention uuid;
begin
  insert into anomalies (emplacement_id, description, constate_par)
  select id, 'Anomalie en cours', '22222222-2222-2222-2222-222222222222'
  from emplacements where code = '56' returning id into v_anomalie;

  insert into interventions (anomalie_id, technicien_id)
  values (v_anomalie, '11111111-1111-1111-1111-111111111111') returning id into v_intervention;

  insert into validations (intervention_id, acteur, decision, utilisateur_id)
  values (v_intervention, 'gouvernante', 'en_cours', '22222222-2222-2222-2222-222222222222');

  assert (select statut from anomalies where id = v_anomalie) = 'en_cours',
    'la décision EN COURS doit remettre l''anomalie en cours';
end $$;

-- ===========================================================================
-- SCÉNARIO 7 — Ajustement de stock hors inventaire (casse, perte, erreur) et
-- facture d'achat couvrant plusieurs produits d'une même livraison.
-- ===========================================================================
-- Un ajustement doit toujours porter un motif
do $$
begin
  begin
    insert into mouvements_stock (produit_id, type, quantite)
    select id, 'regularisation', -1 from produits where code = 'FLX-40';
    raise exception 'un ajustement sans motif aurait dû être refusé';
  exception when check_violation then null;
  end;
end $$;

-- Une casse se corrige au fil de l'eau, sans ouvrir d'inventaire
do $$
declare v_avant numeric; v_apres numeric;
begin
  select stock into v_avant from v_stock_produits where code = 'FLX-40';

  insert into mouvements_stock (produit_id, type, motif, quantite, utilisateur_id, commentaire)
  select id, 'regularisation', 'casse', -2, '11111111-1111-1111-1111-111111111111',
         'Deux flexibles cassés au montage'
  from produits where code = 'FLX-40';

  select stock into v_apres from v_stock_produits where code = 'FLX-40';
  assert v_apres = v_avant - 2, format('stock %s attendu %s', v_apres, v_avant - 2);
end $$;

-- Une facture d'achat couvre plusieurs produits d'une même livraison
do $$
declare v_facture uuid; v_nb int; v_total numeric;
begin
  insert into factures (type, fournisseur_id, reference, date_reference, montant_ht, statut)
  values ('achat', '88888888-8888-8888-8888-888888888888', 'BL-2026-118',
          date '2026-06-02', 96.00, 'rapprochee')
  returning id into v_facture;

  insert into mouvements_stock (produit_id, type, quantite, prix_unitaire, facture_id, commentaire)
  select p.id, 'entree', q.qte, q.prix, v_facture, 'Livraison du 02/06'
  from (values ('JNT-12', 20, 2.40), ('FLX-40', 5, 9.60)) as q (code, qte, prix)
  join produits p on p.code = q.code;

  select count(*), sum(quantite * prix_unitaire) into v_nb, v_total
  from mouvements_stock where facture_id = v_facture;
  assert v_nb = 2, format('%s lignes rattachées à la facture, attendu 2', v_nb);
  assert v_total = 96.00, format('total des lignes = %s, attendu 96.00', v_total);
end $$;

-- Une facture ne peut pas être rattachée à une sortie de stock
do $$
begin
  begin
    insert into mouvements_stock (produit_id, type, quantite, facture_id)
    select p.id, 'sortie', -1, f.id
    from produits p, factures f where p.code = 'JNT-12' and f.type = 'achat' limit 1;
    raise exception 'une sortie rattachée à une facture aurait dû être refusée';
  exception when check_violation then null;
  end;
end $$;

-- Une facture de prestation sans prestataire, ou d'achat sans fournisseur,
-- est refusée
do $$
begin
  begin
    insert into factures (type, fournisseur_id, date_reference)
    values ('prestation', '88888888-8888-8888-8888-888888888888', current_date);
    raise exception 'une prestation facturée par un fournisseur aurait dû être refusée';
  exception when check_violation then null;
  end;
end $$;

-- ===========================================================================
-- SCÉNARIO 8 — Les mails ne partent pas à la validation. Ils attendent le
-- digest du soir, pour qu'une après-midi de validations fasse un seul envoi.
-- ===========================================================================
do $$
declare
  v_tournee tournees;
  v_anomalie uuid; v_intervention uuid; n int;
  v_attente int;
begin
  v_tournee := fn_creer_tournee('11111111-1111-1111-1111-111111111111');
  for n in 1..3 loop
    insert into anomalies (emplacement_id, description) select id, 'Digest ' || n
      from emplacements where code = '57' returning id into v_anomalie;
    insert into interventions (anomalie_id, tournee_id, technicien_id)
      values (v_anomalie, v_tournee.id, '11111111-1111-1111-1111-111111111111')
      returning id into v_intervention;
    insert into validations (intervention_id, acteur, decision, utilisateur_id)
      values (v_intervention, 'technicien', 'fait', '11111111-1111-1111-1111-111111111111');
  end loop;
  update tournees set cloturee_le = now() where id = v_tournee.id;

  -- Le lot est clos : le récapitulatif technicien attend, il n'est pas parti.
  select count(*) into v_attente from v_envois_en_attente
   where tournee_id = v_tournee.id and categorie = 'recap_technicien';
  assert v_attente = 1, 'le récapitulatif technicien doit attendre le digest';

  -- Victoria valide les trois, une par une : toujours aucun envoi déclenché.
  insert into validations (intervention_id, acteur, decision, utilisateur_id, saisie_par)
  select i.id, 'gouvernante', 'validee', '22222222-2222-2222-2222-222222222222',
         '11111111-1111-1111-1111-111111111111'
  from interventions i where i.tournee_id = v_tournee.id;

  select count(*) into v_attente from v_envois_en_attente where tournee_id = v_tournee.id;
  assert v_attente = 2,
    format('%s envois en attente, attendu 2 — un par catégorie, pas un par anomalie', v_attente);

  -- Le digest de 21 h passe et horodate.
  perform fn_marquer_envois('recap_technicien',   array[v_tournee.id]);
  perform fn_marquer_envois('recap_intervention', array[v_tournee.id]);

  select count(*) into v_attente from v_envois_en_attente where tournee_id = v_tournee.id;
  assert v_attente = 0, format('%s envois encore en attente après le digest, attendu 0', v_attente);

  -- Le lendemain, le digest ne renvoie rien.
  assert fn_marquer_envois('recap_technicien', array[v_tournee.id]) = 0,
    'un second passage du digest ne doit rien renvoyer';
end $$;

-- La saisie pour le compte d'un autre est tracée des deux côtés
do $$
declare v record;
begin
  select v2.utilisateur_id, v2.saisie_par into v
  from validations v2 where v2.acteur = 'gouvernante' and v2.saisie_par is not null limit 1;
  assert v.utilisateur_id <> v.saisie_par,
    'l''avis et la personne qui l''a saisi doivent rester distincts';
end $$;

-- ===========================================================================
-- SCÉNARIO 9 — Un même problème ne peut pas être ouvert deux fois au même
-- endroit. En revanche, savoir combien de fois il est revenu doit rester
-- possible : c'est tout l'intérêt d'un catalogue fermé.
-- ===========================================================================
do $$
declare
  v_catalogue uuid; v_autre uuid; v_emplacement uuid;
  v_anomalie uuid; v_intervention uuid;
  v_nb int; v_ouverte boolean;
begin
  select id into v_catalogue from catalogue_anomalies order by libelle limit 1;
  select id into v_autre     from catalogue_anomalies order by libelle offset 1 limit 1;
  select id into v_emplacement from emplacements where code = '26';

  -- Première déclaration : rien ne s'y oppose
  insert into anomalies (emplacement_id, catalogue_id, description, constate_par)
  values (v_emplacement, v_catalogue, 'Première fois',
          '22222222-2222-2222-2222-222222222222')
  returning id into v_anomalie;

  -- La même, tant qu'elle est ouverte : la base refuse
  begin
    insert into anomalies (emplacement_id, catalogue_id, description, constate_par)
    values (v_emplacement, v_catalogue, 'Doublon', '22222222-2222-2222-2222-222222222222');
    raise exception 'le doublon aurait dû être refusé par la base';
  exception when unique_violation then null;
  end;

  -- Un autre libellé dans la même chambre reste possible
  insert into anomalies (emplacement_id, catalogue_id, description, constate_par)
  values (v_emplacement, v_autre, 'Autre problème', '22222222-2222-2222-2222-222222222222');

  -- Et le même libellé dans une autre chambre aussi
  insert into anomalies (emplacement_id, catalogue_id, description, constate_par)
  select id, v_catalogue, 'Même problème ailleurs', '22222222-2222-2222-2222-222222222222'
  from emplacements where code = '27';

  -- L'écran de déclaration marque le libellé comme déjà ouvert ici
  select deja_ouverte, nb_fois_ici into v_ouverte, v_nb
  from fn_catalogue_pour_lieu(v_emplacement, 'e')
  where id = v_catalogue;
  assert v_ouverte, 'le catalogue doit signaler le libellé déjà ouvert ici';
  assert v_nb = 1, format('nb_fois_ici = %s, attendu 1', v_nb);

  -- Une fois réparée et validée, le problème peut revenir : c'est une
  -- récurrence, pas un doublon.
  insert into interventions (anomalie_id, technicien_id)
  values (v_anomalie, '11111111-1111-1111-1111-111111111111') returning id into v_intervention;
  insert into validations (intervention_id, acteur, decision, utilisateur_id)
  values (v_intervention, 'gouvernante', 'validee', '22222222-2222-2222-2222-222222222222');

  insert into anomalies (emplacement_id, catalogue_id, description, constate_par)
  values (v_emplacement, v_catalogue, 'Le problème est revenu',
          '22222222-2222-2222-2222-222222222222');

  select nb_fois, ouvertes into v_nb, v_ouverte
  from v_frequence_anomalie_lieu
  where emplacement_id = v_emplacement and catalogue_id = v_catalogue;
  assert v_nb = 2, format('nb_fois = %s, attendu 2 — la récurrence doit se compter', v_nb);
  assert v_ouverte::int = 1, 'une seule doit être ouverte';

  -- Une anomalie annulée ne revient jamais à la vie, même si une validation
  -- arrive après coup : sinon le doublon renaîtrait.
  update anomalies set statut = 'annulee' where id = v_anomalie;
  insert into validations (intervention_id, acteur, decision, utilisateur_id)
  values (v_intervention, 'technicien', 'fait', '11111111-1111-1111-1111-111111111111');
  assert (select statut from anomalies where id = v_anomalie) = 'annulee',
    'une anomalie annulée doit le rester';

  -- Et elle ne compte pas dans la fréquence : elle a été saisie deux fois,
  -- pas vécue deux fois.
  select nb_fois into v_nb from v_frequence_anomalie_lieu
   where emplacement_id = v_emplacement and catalogue_id = v_catalogue;
  assert v_nb = 1, format('nb_fois = %s, attendu 1 après annulation', v_nb);
end $$;

-- ===========================================================================
-- SCÉNARIO 10 — Une commande n'entre en stock qu'à la réception, et c'est ce
-- qui est ARRIVÉ qui compte, pas ce qui avait été commandé. Le prix garde son
-- hors taxes et son toutes taxes.
-- ===========================================================================
do $$
declare
  v_commande   uuid;
  v_fournisseur uuid;
  v_produit    uuid;
  v_bouteille  uuid;
  v_avant      int;
  v_apres      int;
  v_reserve_av int;
  v_reserve_ap int;
  v_tva        numeric;
begin
  select id into v_fournisseur from fournisseurs where nom = 'Fournisseur de test';
  select id into v_produit     from produits where code = 'JNT-12';
  select id into v_bouteille   from bouteille_types where code = 'filtree';
  select stock into v_avant from v_stock_produits where id = v_produit;
  select en_reserve into v_reserve_av from v_stock_bouteilles where bouteille_type_id = v_bouteille;

  insert into commandes (fournisseur_id, montant_ht, montant_ttc, saisie_par)
  values (v_fournisseur, 100.00, 120.00, '22222222-2222-2222-2222-222222222222')
  returning id into v_commande;

  insert into commande_lignes (commande_id, produit_id, quantite, prix_unitaire_ht)
  values (v_commande, v_produit, 20, 3.50);
  insert into commande_lignes (commande_id, bouteille_type_id, quantite, prix_unitaire_ht)
  values (v_commande, v_bouteille, 12, 4.00);

  -- Tant qu'elle n'est pas reçue, elle n'a rien ajouté.
  select stock into v_apres from v_stock_produits where id = v_produit;
  assert v_apres = v_avant,
    format('le stock a bougé (%s → %s) alors que la commande n''est pas reçue', v_avant, v_apres);

  -- La TVA est une soustraction, jamais une colonne.
  select montant_tva into v_tva from v_commandes where id = v_commande;
  assert v_tva = 20.00, format('TVA = %s, attendu 20.00', v_tva);

  -- Réception partielle sur le produit : 18 arrivés sur 20 commandés.
  update commande_lignes set quantite_recue = 18
   where commande_id = v_commande and produit_id = v_produit;
  update commandes set statut = 'recue', recue_le = now() where id = v_commande;

  select stock into v_apres from v_stock_produits where id = v_produit;
  assert v_apres = v_avant + 18,
    format('stock = %s, attendu %s : c''est ce qui est arrivé qui compte', v_apres, v_avant + 18);

  -- Les bouteilles sans quantité reçue prennent la quantité commandée, et
  -- entrent en RÉSERVE : une bouteille neuve ne va pas directement en chambre.
  select en_reserve into v_reserve_ap from v_stock_bouteilles where bouteille_type_id = v_bouteille;
  assert v_reserve_ap = v_reserve_av + 12,
    format('réserve = %s, attendu %s', v_reserve_ap, v_reserve_av + 12);

  -- Rien n'est stocké : l'entrée est un mouvement, traçable et annulable.
  assert (select count(*) from mouvements_stock
           where produit_id = v_produit and type = 'entree'
             and commentaire like 'Commande n° %') = 1,
    'la réception doit laisser un mouvement d''entrée tracé';
end $$;

-- ===========================================================================
-- SCÉNARIO 11 — Inventaire des bouteilles : un écart ne se corrige jamais par
-- une écriture directe. Il produit une régularisation, datée et signée.
-- ===========================================================================
do $$
declare
  v_inv      uuid;
  v_type     uuid;
  v_chambre  uuid;
  v_reserve_av int; v_reserve_ap int;
  v_chambre_av int; v_chambre_ap int;
  v_mouvements int;
begin
  select id into v_type    from bouteille_types where code = 'filtree';
  select id into v_chambre from emplacements where code = '11';
  select en_reserve into v_reserve_av from v_stock_bouteilles where bouteille_type_id = v_type;
  select coalesce(sum(qte), 0)::int into v_chambre_av from v_bouteilles_positions
   where bouteille_type_id = v_type and emplacement_id = v_chambre and lieu = 'emplacement';

  insert into inventaires (type, libelle, ouvert_par)
  values ('bouteilles', 'Comptage de test', '22222222-2222-2222-2222-222222222222')
  returning id into v_inv;

  -- La réserve en compte trois de moins que prévu ; la chambre 11 en a une de trop.
  insert into inventaire_lignes_bouteille (inventaire_id, bouteille_type_id, emplacement_id,
                                           quantite_theorique, quantite_comptee)
  values (v_inv, v_type, null,      v_reserve_av, v_reserve_av - 3),
         (v_inv, v_type, v_chambre, v_chambre_av, v_chambre_av + 1);

  -- Tant que l'inventaire est en brouillon, rien n'a bougé.
  select en_reserve into v_reserve_ap from v_stock_bouteilles where bouteille_type_id = v_type;
  assert v_reserve_ap = v_reserve_av,
    format('la réserve a bougé (%s → %s) avant validation', v_reserve_av, v_reserve_ap);

  update inventaires
     set statut = 'valide', valide_le = now(),
         valide_par = '22222222-2222-2222-2222-222222222222'
   where id = v_inv;

  select en_reserve into v_reserve_ap from v_stock_bouteilles where bouteille_type_id = v_type;
  assert v_reserve_ap = v_reserve_av - 3,
    format('réserve = %s, attendu %s après régularisation', v_reserve_ap, v_reserve_av - 3);

  select coalesce(sum(qte), 0)::int into v_chambre_ap from v_bouteilles_positions
   where bouteille_type_id = v_type and emplacement_id = v_chambre and lieu = 'emplacement';
  assert v_chambre_ap = v_chambre_av + 1,
    format('chambre 11 = %s, attendu %s', v_chambre_ap, v_chambre_av + 1);

  -- Et tout est tracé : deux mouvements rattachés à cet inventaire, pas une
  -- écriture anonyme dans un stock.
  select count(*) into v_mouvements from mouvements_bouteilles
   where inventaire_id = v_inv and type = 'regularisation';
  assert v_mouvements = 2, format('%s régularisations écrites, attendu 2', v_mouvements);
end $$;

-- ===========================================================================
-- SCÉNARIO 12 — Le mail de bouteille est une action, pas un texte à relire :
-- il se rédige tout seul et attend son tour dans la file.
-- ===========================================================================
do $$
declare
  v_dossier uuid;
  v_sujet   text;
  v_corps   text;
  v_nb      int;
begin
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, statut)
  select e.id, 'emport', 'client', 'Famille Lindqvist',
         '22222222-2222-2222-2222-222222222222', 'signale'
  from emplacements e where e.code = '52'
  returning id into v_dossier;
  insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
  select v_dossier, bt.id, 1 from bouteille_types bt;

  -- Ce que l'interface dépose dans la file, avec les mêmes données que l'écran.
  insert into emails_envoyes (categorie, reference_id, destinataires, sujet, corps)
  select 'alerte_bouteille', d.id,
         (select destinataires from alertes_destinataires
           where evenement = 'incident_bouteille'),
         '[A ENVOYER CLIENT] Bouteille(s) Purezza manquante(s) — Chambre ' || d.emplacement,
         'Montant total : ' || d.montant
  from v_dossiers_bouteille d where d.id = v_dossier;

  select sujet, corps into v_sujet, v_corps
  from v_courriels_en_attente where reference_id = v_dossier;
  assert v_sujet like '%Chambre 52%',
    format('sujet inattendu : %s', v_sujet);
  assert v_corps like '%35.00%', format('montant absent du corps : %s', v_corps);

  -- Tant qu'il n'est pas parti, il reste dans la file — et il n'y est qu'une fois.
  select count(*) into v_nb from v_courriels_en_attente where reference_id = v_dossier;
  assert v_nb = 1, format('%s messages en attente pour ce dossier, attendu 1', v_nb);

  -- Une fois envoyé, il quitte la file sans disparaître : la trace reste.
  update emails_envoyes set envoye_le = now(), succes = true
   where reference_id = v_dossier;
  select count(*) into v_nb from v_courriels_en_attente where reference_id = v_dossier;
  assert v_nb = 0, 'un message envoyé ne doit plus attendre';
  select count(*) into v_nb from emails_envoyes where reference_id = v_dossier;
  assert v_nb = 1, 'la trace de l''envoi doit rester';
end $$;

-- ===========================================================================
-- SCÉNARIO 13 — Le récapitulatif est un mail par LOT, pas un mail par anomalie.
-- Deux moments : la clôture du lot, puis la dernière validation.
-- ===========================================================================
do $$
declare
  v_tournee uuid;
  v_anomalie uuid;
  v_intervention uuid;
  v_emplacement uuid;
  v_n int;
  v_prete boolean;
begin
  select id into v_emplacement from emplacements where code = '35';
  select id into v_tournee from fn_creer_tournee(
    '11111111-1111-1111-1111-111111111111', null);

  -- Trois anomalies traitées dans le même passage.
  for v_n in 1..3 loop
    insert into anomalies (emplacement_id, description, constate_par)
    values (v_emplacement, 'Anomalie de lot ' || v_n,
            '22222222-2222-2222-2222-222222222222')
    returning id into v_anomalie;

    insert into interventions (anomalie_id, tournee_id, technicien_id)
    values (v_anomalie, v_tournee, '11111111-1111-1111-1111-111111111111')
    returning id into v_intervention;

    insert into validations (intervention_id, acteur, decision, utilisateur_id)
    values (v_intervention, 'technicien', 'fait',
            '11111111-1111-1111-1111-111111111111');
  end loop;

  -- Trois anomalies, une seule tournée : c'est elle l'unité d'envoi.
  select nb_interventions, prete_pour_recap into v_n, v_prete
  from v_tournees where id = v_tournee;
  assert v_n = 3, format('%s interventions dans le lot, attendu 3', v_n);
  assert not v_prete, 'le lot ne peut pas être prêt : la gouvernante n''a rien tranché';

  -- La gouvernante valide deux lignes et en refuse une.
  update validations set id = id where false;  -- no-op, garde la lisibilité
  insert into validations (intervention_id, acteur, decision, utilisateur_id)
  select i.id, 'gouvernante',
         case when row_number() over (order by i.cree_le) = 1
              then 'a_refaire' else 'validee' end::decision_validation,
         '22222222-2222-2222-2222-222222222222'
  from interventions i where i.tournee_id = v_tournee;

  select prete_pour_recap, nb_a_refaire into v_prete, v_n
  from v_tournees where id = v_tournee;
  assert v_prete, 'toutes les lignes ont un avis : le lot est prêt';
  assert v_n = 1, format('%s ligne à refaire, attendu 1', v_n);

  -- Le récapitulatif doit pouvoir dire ce qui n'a PAS été validé : c'est
  -- l'information qui manquait à l'ancienne application.
  select count(*) into v_n from v_recap_interventions
   where tournee = (select reference from tournees where id = v_tournee)
     and non_validee_par_gouvernante;
  assert v_n = 1,
    format('%s ligne déclarée faite mais non validée, attendu 1', v_n);
end $$;

\echo '✅ Tous les scénarios sont passés'
rollback;
