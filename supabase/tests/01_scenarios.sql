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

-- Dotation initiale : ce que le référentiel prévoit, chambre par chambre. Le
-- nombre de chambres dotées n'est pas écrit ici — il change quand l'hôtel
-- change, et un scénario qui le fige se réécrit à chaque fois.
insert into mouvements_bouteilles (type, bouteille_type_id, quantite, de_lieu, vers_lieu, vers_emplacement_id)
select 'dotation', d.bouteille_type_id, d.quantite, 'reserve', 'emplacement', d.emplacement_id
from dotations d
join emplacements e on e.id = d.emplacement_id
-- Un scénario mesure l'hôtel, pas les chambres d'entraînement.
where not e.essai;

do $$
declare
  v record;
  v_dotees int;
begin
  select coalesce(sum(d.quantite), 0)::int into v_dotees
    from dotations d
    join bouteille_types b on b.id = d.bouteille_type_id
    join emplacements e    on e.id = d.emplacement_id
   where b.code = 'filtree' and not e.essai;

  select * into v from ecart_bouteilles('filtree');
  assert v.en_reserve = 100 - v_dotees and v.en_chambre = v_dotees
     and v.chez_clients = 0 and v.parc_detenu = 100,
    format('après dotation de %s bouteilles : réserve %s, chambre %s, clients %s, détenu %s (en écart)',
           v_dotees, v.en_reserve, v.en_chambre, v.chez_clients, v.parc_detenu);
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


-- Une tournée à nous, encore ouverte : c'est elle qui décide du moment où la
-- gouvernante voit le travail.
-- Son propre JOUR. Un intervenant n'a qu'un passage par jour (0018) : deux
-- lots indépendants dans les scénarios sont donc deux journées, pas deux
-- tournées du même jour. C'est aussi ce qui se passe dans l'hôtel.
insert into tournees (id, reference, technicien_id, date_tournee)
values ('55555555-5555-5555-5555-555555555555', 'TEST-LOT-0001',
        '11111111-1111-1111-1111-111111111111', current_date - 1);

insert into interventions (id, anomalie_id, tournee_id, technicien_id)
values ('44444444-4444-4444-4444-444444444444',
        '33333333-3333-3333-3333-333333333333',
        '55555555-5555-5555-5555-555555555555',
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

-- Le technicien déclare fait, mais sa tournée est encore ouverte : il peut
-- revenir sur cette chambre, la gouvernante n'a rien à valider pour l'instant.
insert into validations (intervention_id, acteur, decision, utilisateur_id, commentaire)
values ('44444444-4444-4444-4444-444444444444', 'technicien', 'fait',
        '11111111-1111-1111-1111-111111111111', 'Joint changé');

do $$ begin
  assert (select statut from anomalies where id = '33333333-3333-3333-3333-333333333333')
         = 'en_cours', 'tournée ouverte : l''anomalie doit rester en_cours';
  assert (select nb_en_attente from v_tournees
           where id = '55555555-5555-5555-5555-555555555555') = 0,
         'une tournée ouverte ne présente rien à valider';
end $$;

-- Fin d'intervention : le lot est rendu, tout passe sous les yeux de la
-- gouvernante d'un seul coup.
update tournees set cloturee_le = now()
 where id = '55555555-5555-5555-5555-555555555555';

do $$ begin
  assert (select statut from anomalies where id = '33333333-3333-3333-3333-333333333333')
         = 'attente_validation', 'lot rendu : statut attendu attente_validation';
  assert (select nb_en_attente from v_tournees
           where id = '55555555-5555-5555-5555-555555555555') = 1,
         'le lot rendu présente son anomalie à valider';
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
  v_tournee := fn_creer_tournee('11111111-1111-1111-1111-111111111111',
                                null, current_date - 2);

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
  v_tournee := fn_creer_tournee('11111111-1111-1111-1111-111111111111',
                                null, current_date - 3);
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
    '11111111-1111-1111-1111-111111111111', null, current_date - 4);

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

  -- Tant que le passage n'est pas rendu, la gouvernante n'a rien devant elle.
  select nb_en_attente into v_n from v_tournees where id = v_tournee;
  assert v_n = 0, format('tournée ouverte : %s à valider, attendu 0', v_n);

  -- Fin d'intervention : le lot est rendu.
  update tournees set cloturee_le = now() where id = v_tournee;
  select nb_en_attente into v_n from v_tournees where id = v_tournee;
  assert v_n = 3, format('lot rendu : %s à valider, attendu 3', v_n);

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

-- ===========================================================================
-- SCÉNARIO 14 — Le prix payé se suit dans les mouvements. Une hausse se lit
-- sans être stockée nulle part, et le prix de référence ne bouge pas tout seul.
-- ===========================================================================
do $$
declare
  v_produit uuid;
  v_prix    record;
begin
  -- Un produit à soi : le scénario doit tenir sur n'importe quelle base, y
  -- compris celle de l'hôtel où JNT-12 a déjà une histoire.
  insert into produits (code, designation, prix_unitaire, seuil_alerte)
  values ('TEST-PRIX', 'Produit de test — suivi du prix', 3.00, 5)
  returning id into v_produit;

  -- Trois livraisons, à trois prix différents.
  insert into mouvements_stock (produit_id, type, quantite, prix_unitaire,
                                date_mouvement, utilisateur_id)
  values (v_produit, 'entree', 10, 3.00, now() - interval '90 days',
          '11111111-1111-1111-1111-111111111111'),
         (v_produit, 'entree', 10, 3.20, now() - interval '45 days',
          '11111111-1111-1111-1111-111111111111'),
         (v_produit, 'entree', 10, 3.84, now() - interval '2 days',
          '11111111-1111-1111-1111-111111111111');

  select * into v_prix from v_prix_produit where produit_id = v_produit;
  assert v_prix.nb_achats = 3, format('%s achats, attendu 3', v_prix.nb_achats);
  assert v_prix.dernier_prix = 3.84, format('dernier prix = %s, attendu 3.84', v_prix.dernier_prix);
  assert v_prix.prix_precedent = 3.20,
    format('prix précédent = %s, attendu 3.20', v_prix.prix_precedent);
  assert v_prix.variation_pct = 20.0,
    format('variation = %s %%, attendu 20.0', v_prix.variation_pct);
  assert v_prix.ecart_reference_pct = 28.0,
    format('écart au prix de référence = %s %%, attendu 28.0', v_prix.ecart_reference_pct);
  assert v_prix.prix_min = 3.00 and v_prix.prix_max = 3.84,
    format('min %s, max %s — attendu 3.00 et 3.84', v_prix.prix_min, v_prix.prix_max);

  -- Le prix de référence n'a pas bougé : c'est une décision, pas un effet de bord.
  assert (select prix_unitaire from produits where id = v_produit) = 3.00,
    'le prix de référence ne doit jamais se mettre à jour tout seul';

  -- Et il se lit depuis la liste du stock, sans requête de plus.
  assert (select variation_pct from v_stock_produits where id = v_produit) = 20.0,
    'la hausse doit être lisible depuis la liste du stock';
end $$;

-- ===========================================================================
-- SCÉNARIO 15 — Antidater une réception déplace les mouvements qu'elle a
-- produits : une entrée porte la date de la livraison, pas celle de sa saisie.
-- ===========================================================================
do $$
declare
  v_cmd     uuid;
  v_produit uuid;
  v_quand   timestamptz;
  v_prix    numeric;
begin
  select id into v_produit from produits where code = 'FLX-40';
  insert into commandes (fournisseur_id, saisie_par)
  select id, '22222222-2222-2222-2222-222222222222'
  from fournisseurs where nom = 'Fournisseur de test'
  returning id into v_cmd;

  insert into commande_lignes (commande_id, produit_id, quantite, prix_unitaire_ht)
  values (v_cmd, v_produit, 5, 11.40);

  update commandes set statut = 'recue', recue_le = now() where id = v_cmd;

  -- Le prix payé suit la ligne de commande : il nourrit l'historique du prix.
  select date_mouvement, prix_unitaire into v_quand, v_prix
  from mouvements_stock where commande_id = v_cmd and type = 'entree';
  assert v_prix = 11.40, format('prix repris = %s, attendu 11.40', v_prix);
  assert v_quand::date = current_date,
    format('mouvement daté du %s, attendu aujourd''hui', v_quand::date);

  -- La livraison était en fait arrivée dix jours plus tôt.
  update commandes set recue_le = now() - interval '10 days' where id = v_cmd;

  select date_mouvement into v_quand
  from mouvements_stock where commande_id = v_cmd and type = 'entree';
  assert v_quand::date = (current_date - 10),
    format('mouvement daté du %s après correction, attendu %s',
           v_quand::date, current_date - 10);

  -- Et une seule entrée : redater ne duplique rien.
  assert (select count(*) from mouvements_stock
           where commande_id = v_cmd and type = 'entree') = 1,
    'redater une réception ne doit pas créer une seconde entrée';
end $$;

-- ===========================================================================
-- SCÉNARIO 16 — L'aperçu d'une journée garde chaque anomalie avec son lieu.
-- Deux listes séparées laissaient croire qu'il y avait un lave-vaisselle
-- dans la chambre 57.
-- ===========================================================================
do $$
declare
  v_facture uuid;
  v_apercu  text;
begin
  insert into anomalies (emplacement_id, description, constate_par)
  select e.id, 'Fuite au niveau du lave-vaisselle',
         '22222222-2222-2222-2222-222222222222'
  from emplacements e where e.code = 'Cuisine';
  insert into anomalies (emplacement_id, description, constate_par)
  select e.id, 'Difficulté à fermer la porte',
         '22222222-2222-2222-2222-222222222222'
  from emplacements e where e.code = '57';

  insert into interventions (anomalie_id, prestataire_id, date_intervention)
  select a.id, '99999999-9999-9999-9999-999999999999', current_date - 5
  from anomalies a
  where a.description in ('Fuite au niveau du lave-vaisselle',
                          'Difficulté à fermer la porte');

  insert into factures (type, prestataire_id, date_reference, statut)
  values ('prestation', '99999999-9999-9999-9999-999999999999',
          current_date, 'a_rapprocher')
  returning id into v_facture;

  select apercu into v_apercu
  from fn_journees_rapprochables(v_facture, 30)
  where date_intervention = current_date - 5;

  assert v_apercu like '%Cuisine — Fuite au niveau du lave-vaisselle%',
    format('le lave-vaisselle doit rester à la cuisine — aperçu : %s', v_apercu);
  assert v_apercu like '%57 — Difficulté à fermer la porte%',
    format('la porte doit rester à la 57 — aperçu : %s', v_apercu);
end $$;

-- ===========================================================================
-- SCÉNARIO 17 — Inventaire matériel : un produit non compté n'existe pas dans
-- l'inventaire, et un écart devient une régularisation de motif « inventaire ».
-- ===========================================================================
do $$
declare
  v_inv     uuid;
  v_produit uuid;
  v_autre   uuid;
  v_avant   numeric;
  v_apres   numeric;
  v_motif   motif_regularisation;
begin
  select id into v_produit from produits where code = 'JNT-12';
  select id into v_autre   from produits where code = 'FLX-40';
  select stock into v_avant from v_stock_produits where id = v_produit;

  insert into inventaires (type, libelle, ouvert_par)
  values ('materiel', 'Comptage de test', '22222222-2222-2222-2222-222222222222')
  returning id into v_inv;

  -- On compte UN seul produit : l'autre n'est pas dans l'inventaire.
  insert into inventaire_lignes_produit (inventaire_id, produit_id,
                                         quantite_theorique, quantite_comptee)
  values (v_inv, v_produit, v_avant, v_avant - 4);

  -- En brouillon, rien n'a bougé.
  select stock into v_apres from v_stock_produits where id = v_produit;
  assert v_apres = v_avant,
    format('le stock a bougé (%s → %s) avant validation', v_avant, v_apres);

  update inventaires set statut = 'valide', valide_le = now(),
                         valide_par = '22222222-2222-2222-2222-222222222222'
   where id = v_inv;

  select stock into v_apres from v_stock_produits where id = v_produit;
  assert v_apres = v_avant - 4,
    format('stock = %s, attendu %s après régularisation', v_apres, v_avant - 4);

  -- La régularisation dit pourquoi, et à quel inventaire elle se rattache.
  select motif into v_motif from mouvements_stock
   where inventaire_id = v_inv and produit_id = v_produit;
  assert v_motif = 'inventaire', format('motif = %s, attendu inventaire', v_motif);

  -- Le produit non compté n'a produit aucun mouvement : il n'a pas été compté
  -- pour zéro, il était simplement absent.
  assert (select count(*) from mouvements_stock
           where inventaire_id = v_inv and produit_id = v_autre) = 0,
    'un produit absent de l''inventaire ne doit produire aucun mouvement';
end $$;

-- ===========================================================================
-- SCÉNARIO 18 — Un essai ne touche pas le stock.
-- Les chambres 06 et 07 servent à répéter le geste complet. Cocher du matériel
-- pour une anomalie qui s'y trouve ne doit rien sortir de la réserve : personne
-- n'est allé chercher la pièce sur l'étagère. La même sortie dans une vraie
-- chambre, elle, doit compter — sinon on aurait juste cassé le stock.
-- ===========================================================================
do $$
declare
  v_produit uuid;
  v_essai   uuid;
  v_vrai    uuid;
  v_ano     uuid;
  v_inter   uuid;
  v_avant   numeric;
  v_apres   numeric;
  v_sorties numeric;
  v_cout    numeric;
begin
  select id into v_produit from produits where code = 'JNT-12';
  select id into v_essai   from emplacements where essai limit 1;
  select id into v_vrai    from emplacements where not essai and type = 'chambre' limit 1;
  assert v_essai is not null, 'il faut au moins un lieu d''essai (migration 0008)';

  select stock into v_avant from v_stock_produits where id = v_produit;
  select total_sorties into v_sorties from v_stock_produits where id = v_produit;

  -- Un passage d'essai, complet : une anomalie en 06, une intervention, du
  -- matériel coché.
  insert into anomalies (emplacement_id, description, constate_par)
  values (v_essai, 'Répétition — mitigeur qui goutte',
          '22222222-2222-2222-2222-222222222222')
  returning id into v_ano;
  insert into interventions (anomalie_id, prestataire_id, date_intervention)
  values (v_ano, '99999999-9999-9999-9999-999999999999', current_date)
  returning id into v_inter;
  insert into mouvements_stock (produit_id, type, quantite, emplacement_id,
                                intervention_id)
  values (v_produit, 'sortie', -3, v_essai, v_inter);

  -- La ligne existe : le technicien doit revoir ce qu'il a coché, et la
  -- gouvernante doit pouvoir le valider. C'est tout l'intérêt de répéter.
  assert (select count(*) from mouvements_stock
           where intervention_id = v_inter) = 1,
    'la sortie d''essai doit rester visible, rattachée à son intervention';

  -- Mais elle ne compte pas : ni dans le stock, ni dans les sorties, ni dans
  -- le coût du passage.
  select stock into v_apres from v_stock_produits where id = v_produit;
  assert v_apres = v_avant,
    format('une sortie en lieu d''essai a bougé le stock : %s → %s', v_avant, v_apres);
  assert (select total_sorties from v_stock_produits where id = v_produit) = v_sorties,
    'une sortie en lieu d''essai ne doit pas compter dans les sorties';
  select cout_materiel into v_cout from v_interventions_cout
   where intervention_id = v_inter;
  assert coalesce(v_cout, 0) = 0,
    format('un passage d''essai ne coûte rien en matériel, or %s', v_cout);

  -- La même sortie dans une vraie chambre, elle, compte.
  insert into mouvements_stock (produit_id, type, quantite, emplacement_id)
  values (v_produit, 'sortie', -3, v_vrai);
  select stock into v_apres from v_stock_produits where id = v_produit;
  assert v_apres = v_avant - 3,
    format('une vraie sortie doit bouger le stock : %s → %s, attendu %s',
           v_avant, v_apres, v_avant - 3);
end $$;

-- ===========================================================================
-- SCÉNARIO 19 — Un dossier bouteille se corrige, et ses mouvements suivent.
-- Le parc n'est pas un chiffre stocké : c'est la somme des mouvements. Changer
-- la chambre ou la date d'un dossier sans déplacer ce qu'il a produit rendrait
-- le parc faux — la 27 aurait rendu une bouteille que la 28 n'a jamais perdue.
-- Et un dossier supprimé n'a jamais rien déplacé : le parc redevient ce qu'il
-- était, contrairement au matériel d'une intervention, qui a bien quitté
-- l'étagère.
-- ===========================================================================
do $$
declare
  v_27 uuid; v_28 uuid; v_filtree uuid; v_gazeuse uuid; v_dossier uuid;
  v_27_avant bigint; v_27_apres bigint;
  v_detenu_avant bigint; v_clients_avant bigint;
  n int;
begin
  select id into v_27 from emplacements where code = '27';
  select id into v_28 from emplacements where code = '28';
  select id into v_filtree  from bouteille_types where code = 'filtree';
  select id into v_gazeuse  from bouteille_types where code = 'petillante';

  -- Tout se mesure en écart, et par rapport à CE bloc : les scénarios
  -- précédents ont déjà fait bouger des bouteilles dans la même transaction.
  select coalesce(sum(quantite_reelle), 0) into v_27_avant
    from v_bouteilles_par_emplacement where emplacement_id = v_27;
  select sum(parc_detenu), sum(chez_clients) into v_detenu_avant, v_clients_avant
    from v_stock_bouteilles;

  insert into incidents_bouteille (emplacement_id, nature, client_nom, constate_le)
  values (v_27, 'emport', 'Client d''essai', now()) returning id into v_dossier;
  insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
  values (v_dossier, v_filtree, 1), (v_dossier, v_gazeuse, 1);

  assert (select count(*) from mouvements_bouteilles where incident_id = v_dossier) = 4,
    'un dossier de deux types doit produire 2 emports et 2 re-dotations';

  -- La date : on saisit un dossier d'il y a trois semaines.
  update incidents_bouteille set constate_le = now() - interval '21 days'
   where id = v_dossier;
  assert (select count(*) from mouvements_bouteilles
           where incident_id = v_dossier
             and date_mouvement < now() - interval '20 days') = 4,
    'les mouvements doivent porter la date du constat, corrigée comprise';

  -- Le lieu : ce n'était pas la 27, c'était la 28.
  update incidents_bouteille set emplacement_id = v_28 where id = v_dossier;
  select coalesce(sum(quantite_reelle), 0) into v_27_apres
    from v_bouteilles_par_emplacement where emplacement_id = v_27;
  assert v_27_apres = v_27_avant,
    format('la 27 doit revenir exactement à son état d''avant : %s puis %s',
           v_27_avant, v_27_apres);

  -- Un type retiré emporte ses mouvements : sinon la bouteille reste partie.
  delete from incident_lignes_bouteille
   where incident_id = v_dossier and bouteille_type_id = v_gazeuse;
  assert (select count(*) from mouvements_bouteilles
           where incident_id = v_dossier and bouteille_type_id = v_gazeuse) = 0,
    'retirer une ligne doit retirer ce qu''elle avait déplacé';

  -- Une quantité corrigée vaut pour l'emport ET pour la re-dotation.
  update incident_lignes_bouteille set quantite = 3
   where incident_id = v_dossier and bouteille_type_id = v_filtree;
  assert (select count(*) from mouvements_bouteilles
           where incident_id = v_dossier and quantite = 3) = 2,
    'la quantité doit suivre sur les deux mouvements';

  -- La re-dotation se dédit — la réserve était vide — et revient, sans doubler.
  update incidents_bouteille set redoter = false where id = v_dossier;
  assert (select count(*) from mouvements_bouteilles
           where incident_id = v_dossier and type = 'dotation') = 0,
    'se dédire de la re-dotation doit retirer son mouvement';
  update incidents_bouteille set redoter = true where id = v_dossier;
  select count(*) into n from mouvements_bouteilles
   where incident_id = v_dossier and type = 'dotation';
  assert n = 1, format('la re-dotation doit revenir une seule fois, or %s', n);

  -- Supprimé : le parc redevient exactement ce qu'il était avant ce bloc.
  delete from incidents_bouteille where id = v_dossier;
  assert (select sum(parc_detenu) from v_stock_bouteilles) = v_detenu_avant
     and (select sum(chez_clients) from v_stock_bouteilles) = v_clients_avant,
    format('après suppression, détenu %s (attendu %s) et chez les clients %s (attendu %s)',
           (select sum(parc_detenu) from v_stock_bouteilles), v_detenu_avant,
           (select sum(chez_clients) from v_stock_bouteilles), v_clients_avant);
  select coalesce(sum(quantite_reelle), 0) into v_27_apres
    from v_bouteilles_par_emplacement where emplacement_id = v_27;
  assert v_27_apres = v_27_avant,
    'la chambre d''origine doit être intacte : le dossier n''a jamais existé';
  assert (select count(*) from mouvements_bouteilles where incident_id = v_dossier) = 0,
    'la suppression doit emporter les mouvements du dossier';
end $$;

-- ===========================================================================
-- SCÉNARIO 21 — Un passage, c'est qui est venu et quel jour. Il se reprend, et
-- ce que la gouvernante a tranché ne se reprend pas.
-- ===========================================================================
do $$
declare
  t1 tournees; t2 tournees;
  v_a uuid; v_i uuid; n int; v_statut text;
begin
  -- Son jour à lui : les autres scénarios ont pris les précédents.
  t1 := fn_creer_tournee('11111111-1111-1111-1111-111111111111',
                         null, current_date - 5);
  t2 := fn_creer_tournee('11111111-1111-1111-1111-111111111111',
                         null, current_date - 5);
  assert t1.id = t2.id,
    'deux passages ouverts le même jour pour le même intervenant';

  insert into anomalies (emplacement_id, description, constate_par)
  select id, 'Passage du jour — la racine', '22222222-2222-2222-2222-222222222222'
    from emplacements where code = '55' returning id into v_a;
  insert into interventions (anomalie_id, tournee_id, technicien_id)
  values (v_a, t1.id, '11111111-1111-1111-1111-111111111111') returning id into v_i;
  insert into validations (intervention_id, acteur, decision, utilisateur_id)
  values (v_i, 'technicien', 'fait', '11111111-1111-1111-1111-111111111111');

  -- Rendu : la gouvernante l'a devant elle.
  update tournees set cloturee_le = now() where id = t1.id;
  select nb_en_attente into n from v_tournees where id = t1.id;
  assert n = 1, format('lot rendu : %s à valider, attendu 1', n);

  -- Repris : il est reparti dans les étages, elle ne doit plus l'avoir.
  update tournees set cloturee_le = null where id = t1.id;
  select statut::text into v_statut from anomalies where id = v_a;
  assert v_statut = 'en_cours',
    format('reprise : anomalie en %s, attendu en_cours', v_statut);
  select nb_en_attente into n from v_tournees where id = t1.id;
  assert n = 0, format('passage repris : %s à valider, attendu 0', n);

  -- Rendu à nouveau, et c'est TOUJOURS le même passage : revenir l'après-midi
  -- n'en ouvre pas un second, sinon l'historique montrerait deux journées.
  update tournees set cloturee_le = now() where id = t1.id;
  select nb_en_attente into n from v_tournees where id = t1.id;
  assert n = 1, format('rendu à nouveau : %s à valider, attendu 1', n);
  t2 := fn_creer_tournee('11111111-1111-1111-1111-111111111111',
                         null, current_date - 5);
  assert t2.id = t1.id, 'revenir après avoir rendu ouvrait un second passage';

  -- Sa décision est un fait : la reprise ne l'efface pas.
  insert into validations (intervention_id, acteur, decision, utilisateur_id)
  values (v_i, 'gouvernante', 'validee', '22222222-2222-2222-2222-222222222222');
  update tournees set cloturee_le = null where id = t1.id;
  select statut::text into v_statut from anomalies where id = v_a;
  assert v_statut = 'validee',
    format('une décision tranchée doit tenir : anomalie en %s', v_statut);
end $$;


-- ===========================================================================
-- SCÉNARIO 22 — Une anomalie supprimée laisse une trace. Un effacement qui ne
-- laisse rien n'est pas une suppression, c'est un trou.
-- ===========================================================================
do $$
declare
  v_a uuid; n int; d anomalies_supprimees;
begin
  insert into anomalies (emplacement_id, description, constate_par)
  select id, 'Anomalie qui va disparaître', '22222222-2222-2222-2222-222222222222'
    from emplacements where code = '55' returning id into v_a;
  insert into commentaires (anomalie_id, texte, auteur_id)
  values (v_a, 'un mot avant de partir', '22222222-2222-2222-2222-222222222222');

  delete from anomalies where id = v_a;

  select count(*) into n from anomalies_supprimees where id = v_a;
  assert n = 1, 'la suppression doit laisser une trace';

  select * into d from anomalies_supprimees where id = v_a;
  assert d.emplacement = '55', format('lieu perdu : %s', d.emplacement);
  assert d.description = 'Anomalie qui va disparaître',
    format('libellé perdu : %s', d.description);
  assert d.nb_commentaires = 1,
    format('%s commentaires notés, attendu 1', d.nb_commentaires);
end $$;


\echo '✅ Tous les scénarios sont passés'
rollback;
