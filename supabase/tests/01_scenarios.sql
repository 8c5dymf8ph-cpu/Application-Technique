-- =============================================================================
-- Tests de scénario — verrouillent les règles métier réelles de l'hôtel.
-- À rejouer après toute modification du schéma.
--   psql -f supabase/tests/01_scenarios.sql
-- =============================================================================
\set ON_ERROR_STOP on
begin;

insert into utilisateurs (id, nom, role) values
  ('11111111-1111-1111-1111-111111111111', 'Miguel',   'technicien'),
  ('22222222-2222-2222-2222-222222222222', 'Victoria', 'gouvernante');

insert into prestataires (id, nom, specialite) values
  ('99999999-9999-9999-9999-999999999999', 'Plomberie Dupont', 'Plomberie');

-- ===========================================================================
-- SCÉNARIO 1 — Bouteilles : les quatre situations réelles de l'hôtel.
-- ===========================================================================

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
  assert v.en_reserve = 63 and v.en_chambre = 37 and v.chez_clients = 0 and v.parc_total = 100,
    format('après dotation : réserve %s, chambre %s, clients %s, parc %s',
           v.en_reserve, v.en_chambre, v.chez_clients, v.parc_total);
end $$;

-- ---------------------------------------------------------------------------
-- Cas A — Un client emporte la bouteille filtrée de la 32. La gouvernante le
-- signale, la chambre est re-dotée. Rien n'est encore perdu : la bouteille est
-- « chez le client » et peut revenir.
-- ---------------------------------------------------------------------------
insert into incidents_bouteille (id, emplacement_id, bouteille_type_id, nature, responsable, constate_par)
select 'aaaaaaaa-0000-0000-0000-000000000001', e.id, bt.id, 'emport', 'client',
       '22222222-2222-2222-2222-222222222222'
from emplacements e, bouteille_types bt where e.code = '32' and bt.code = 'filtree';

do $$
declare v record;
begin
  select * into v from v_stock_bouteilles where code = 'filtree';
  assert v.en_reserve = 62,   format('réserve = %s, attendu 62 (une bouteille sortie pour re-doter)', v.en_reserve);
  assert v.en_chambre = 37,   format('chambre = %s, attendu 37 (la 32 est re-dotée)', v.en_chambre);
  assert v.chez_clients = 1,  format('chez clients = %s, attendu 1', v.chez_clients);
  assert v.parc_total = 100,  format('parc = %s, attendu 100 : un emport ne perd rien', v.parc_total);
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
  select * into v from v_stock_bouteilles where code = 'filtree';
  assert v.en_reserve = 63,  format('réserve = %s, attendu 63 (la bouteille rendue revient en stock)', v.en_reserve);
  assert v.en_chambre = 37,  format('chambre = %s, attendu 37 (inchangée)', v.en_chambre);
  assert v.chez_clients = 0, format('chez clients = %s, attendu 0', v.chez_clients);
  assert v.parc_total = 100, format('parc = %s, attendu 100 : rien n''a été perdu', v.parc_total);
end $$;

-- ---------------------------------------------------------------------------
-- Cas B — Un client emporte la pétillante de la 14 et ne la rend pas : on la
-- lui facture. C'est seulement à cet instant qu'elle sort du parc.
-- ---------------------------------------------------------------------------
insert into incidents_bouteille (id, emplacement_id, bouteille_type_id, nature, responsable, constate_par)
select 'aaaaaaaa-0000-0000-0000-000000000002', e.id, bt.id, 'emport', 'client',
       '22222222-2222-2222-2222-222222222222'
from emplacements e, bouteille_types bt where e.code = '14' and bt.code = 'petillante';

do $$
declare v record;
begin
  select * into v from v_stock_bouteilles where code = 'petillante';
  assert v.parc_total = 100 and v.chez_clients = 1,
    format('en attente : parc %s, chez clients %s', v.parc_total, v.chez_clients);
end $$;

update incidents_bouteille
   set statut = 'facture', montant = 17.50, resolu_le = now(),
       resolu_par = '22222222-2222-2222-2222-222222222222'
 where id = 'aaaaaaaa-0000-0000-0000-000000000002';

do $$
declare v record;
begin
  select * into v from v_stock_bouteilles where code = 'petillante';
  assert v.parc_total = 99,   format('parc = %s, attendu 99 après facturation', v.parc_total);
  assert v.en_reserve = 62,   format('réserve = %s, attendu 62', v.en_reserve);
  assert v.en_chambre = 37,   format('chambre = %s, attendu 37', v.en_chambre);
  assert v.chez_clients = 0,  format('chez clients = %s, attendu 0', v.chez_clients);
end $$;

-- ---------------------------------------------------------------------------
-- Cas C — Une femme de chambre casse la filtrée de la 21. Perte immédiate,
-- jamais facturée au client, valorisée au prix d'achat.
-- ---------------------------------------------------------------------------
insert into incidents_bouteille (id, emplacement_id, bouteille_type_id, nature, responsable, constate_par)
select 'aaaaaaaa-0000-0000-0000-000000000003', e.id, bt.id, 'casse', 'personnel',
       '22222222-2222-2222-2222-222222222222'
from emplacements e, bouteille_types bt where e.code = '21' and bt.code = 'filtree';

do $$
declare v record; v_incident record;
begin
  select * into v from v_stock_bouteilles where code = 'filtree';
  assert v.parc_total = 99,  format('parc = %s, attendu 99 : une casse sort du parc tout de suite', v.parc_total);
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
  ('88888888-8888-8888-8888-888888888888', 'Quincaillerie Martin', 'contact@martin.test');

insert into produits (code, designation, prix_unitaire, seuil_alerte, fournisseur_id) values
  ('JNT-12', 'Joint 12mm',    2.50, 10, '88888888-8888-8888-8888-888888888888'),
  ('FLX-40', 'Flexible 40cm', 8.90,  5, '88888888-8888-8888-8888-888888888888'),
  -- Prix inconnu : l'article ne doit pas être compté pour zéro en silence
  ('DIV-01', 'Pièce diverse', null,  2, '88888888-8888-8888-8888-888888888888');

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
  assert v_tournee.reference like 'INT-MIGUEL-%',
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
  assert v.intervenant = 'Miguel' and v.gouvernante = 'Victoria', 'les deux noms doivent apparaître';
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

insert into factures (id, type, prestataire_id, reference, date_reference, montant_ht, statut)
values ('77777777-7777-7777-7777-777777777777', 'prestation',
        '99999999-9999-9999-9999-999999999999',
        'FA-2026-0512', date '2026-05-17', 450.00, 'a_rapprocher');

do $$
declare v_nb int;
begin
  select count(*) into v_nb from v_factures_rapprochement
   where facture_id = '77777777-7777-7777-7777-777777777777' and not deja_rapprochee;
  assert v_nb = 3, format('%s interventions proposées au rapprochement, attendu 3', v_nb);
end $$;

-- Rapprochement des trois interventions : 450 € répartis à parts égales
insert into facture_interventions (facture_id, intervention_id)
select '77777777-7777-7777-7777-777777777777',
       ('66666666-0000-0000-0000-00000000000' || n)::uuid
from generate_series(1, 3) n;

update factures set statut = 'rapprochee' where id = '77777777-7777-7777-7777-777777777777';

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
   where fournisseur = 'Quincaillerie Martin';
  -- JNT-12 (7 <= 10), FLX-40 (3 <= 5) et DIV-01 (19 > 2, donc absent)
  assert v_nb = 2, format('%s articles sous seuil, attendu 2', v_nb);
end $$;

do $$
declare v_demandes int; v_lignes int;
begin
  perform fn_preparer_demandes_devis('22222222-2222-2222-2222-222222222222');

  select count(*) into v_demandes from demandes_devis d
   join fournisseurs f on f.id = d.fournisseur_id
   where f.nom = 'Quincaillerie Martin';
  assert v_demandes = 1, format('%s demandes de devis, attendu 1 seule pour ce fournisseur', v_demandes);

  select count(*) into v_lignes from demande_devis_lignes l
   join demandes_devis d on d.id = l.demande_id
   join fournisseurs f on f.id = d.fournisseur_id
   where f.nom = 'Quincaillerie Martin';
  assert v_lignes = 2, format('%s lignes dans le devis, attendu 2', v_lignes);
end $$;

-- Un second appel ne doit pas rouvrir un devis déjà en cours
do $$
declare v_demandes int;
begin
  perform fn_preparer_demandes_devis('22222222-2222-2222-2222-222222222222');
  select count(*) into v_demandes from demandes_devis d
   join fournisseurs f on f.id = d.fournisseur_id
   where f.nom = 'Quincaillerie Martin';
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

\echo '✅ Tous les scénarios sont passés'
rollback;
