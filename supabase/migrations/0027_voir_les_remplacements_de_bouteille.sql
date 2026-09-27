-- =============================================================================
-- Migration 0027 : voir les remplacements de bouteille
-- =============================================================================
-- `redoter` existe depuis le début (`incidents_bouteille.redoter`) et le
-- déclencheur de la migration 0014 le tient parfaitement synchronisé avec le
-- mouvement de re-dotation. Mais `v_incidents_bouteille` ne le sélectionnait
-- pas : ni la fiche d'un dossier, ni la liste des dossiers, ni le
-- récapitulatif ne pouvaient donc dire si une chambre avait été re-dotée.
--
-- En reprenant l'historique tenu à la main, ça se voit : deux dossiers du même
-- jour pour la même chambre peuvent chacun porter une re-dotation sans que
-- rien ne le dise nulle part — la réserve rend deux bouteilles pour une seule
-- perte réelle, et rien à l'écran ne permet de le remarquer.
--
-- `create or replace view` ne permet pas d'insérer une colonne au milieu sans
-- casser les vues qui en dépendent : on l'ajoute donc à la fin, comme
-- `commentaire`.
--
-- Postgres fige la liste de colonnes d'un `select i.*` au moment où la vue est
-- créée : la remplacer ne suffit pas à faire apparaître `redoter` dans
-- `v_dossiers_bouteille`, qui fait justement `select i.*, ... from
-- v_incidents_bouteille i`. Testé : sans le `drop` ci-dessous, l'écran des
-- dossiers renvoie « column "redoter" does not exist » — la vue de dessus n'a
-- jamais vu la nouvelle colonne. Il faut la recréer entièrement ; rien d'autre
-- n'en dépend (aucune autre vue, aucune politique RLS).

create or replace view v_incidents_bouteille as
select
  i.id,
  i.reference,
  i.emplacement_id,
  e.code                                   as emplacement,
  l.libelles                               as bouteille,
  coalesce(l.quantite, 0)                  as quantite,
  coalesce(l.detail, '[]'::jsonb)          as lignes,
  i.nature,
  i.responsable,
  i.client_nom,
  uc.nom                                   as constate_par,
  ut.nom                                   as transmis_a,
  i.constate_le,
  i.statut,
  i.notifie_le,
  i.transmis_le,
  i.client_contacte_le,
  i.resolu_le,
  -- Les quatre étapes du dossier, pour la frise de l'écran de suivi.
  i.constate_le is not null                as etape_constate,
  i.transmis_le is not null                as etape_transmis,
  i.client_contacte_le is not null         as etape_client_contacte,
  i.statut in ('restitue', 'facture', 'non_facture', 'clos') as etape_resolue,
  -- Le montant retenu s'il a été saisi ; sinon le prix du barème, ligne à ligne.
  coalesce(i.montant, l.montant_theorique, 0) as montant,
  i.responsable = 'client'                 as facturable_client,
  i.statut in ('signale', 'transmis', 'client_contacte') as dossier_ouvert,
  i.commentaire,
  -- Ajouté en 0027, à la fin : la chambre a-t-elle été re-dotée depuis la
  -- réserve ? C'est ce qui manquait pour repérer un remplacement compté deux
  -- fois sur la même chambre, le même jour.
  i.redoter
from incidents_bouteille i
join emplacements e     on e.id = i.emplacement_id
left join utilisateurs uc on uc.id = i.constate_par
left join utilisateurs ut on ut.id = i.transmis_a
left join lateral (
  select
    string_agg(bt.libelle, ' + ' order by bt.libelle)                as libelles,
    sum(li.quantite)::int                                            as quantite,
    sum(li.quantite * case when i.responsable = 'client'
                           then bt.prix_vente else bt.prix_achat end) as montant_theorique,
    jsonb_agg(jsonb_build_object(
      'code', bt.code, 'libelle', bt.libelle, 'quantite', li.quantite,
      'prix', case when i.responsable = 'client' then bt.prix_vente else bt.prix_achat end)
      order by bt.libelle)                                           as detail
  from incident_lignes_bouteille li
  join bouteille_types bt on bt.id = li.bouteille_type_id
  where li.incident_id = i.id
) l on true;

drop view v_dossiers_bouteille;

create view v_dossiers_bouteille as
select
  i.*,
  -- Trois familles suffisent aux filtres : à traiter, réglé, abandonné.
  case
    when i.statut in ('signale', 'transmis', 'client_contacte') then 'ouvert'
    when i.statut in ('restitue', 'facture')                    then 'resolu'
    else 'perdu'
  end                                              as famille,
  (current_date - i.constate_le::date)::int        as jours_ouvert,
  -- Un dossier client ouvert depuis plus d'une semaine : le client est parti,
  -- la bouteille ne reviendra pas toute seule.
  i.statut in ('signale', 'transmis', 'client_contacte')
    and (current_date - i.constate_le::date) >= 7  as urgent,
  -- De quoi chercher sans se soucier de la casse ni des accents.
  lower(coalesce(i.client_nom, '') || ' ' || i.emplacement || ' ' ||
        coalesce(i.bouteille, '') || ' ' || coalesce(i.commentaire, '') || ' ' ||
        i.reference::text)                         as recherche
from v_incidents_bouteille i;
