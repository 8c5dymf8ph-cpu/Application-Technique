-- =============================================================================
-- Migration 0028 : une perte sèche coûte le prix d'achat, jamais le prix client
-- =============================================================================
-- `montant_theorique` ne regardait que `responsable` : client → prix de vente,
-- personnel ou inconnu → prix d'achat. Un dossier `non_facture` — une perte
-- sèche, que personne ne rembourse — suivait donc le même calcul, et pouvait
-- afficher le prix de vente dès que `responsable = 'client'` : un client qui
-- emporte une bouteille sans qu'on la lui facture coûte quand même à l'hôtel
-- le prix d'ACHAT, pas le prix qu'on aurait demandé s'il avait payé. Miguel
-- avait corrigé chaque dossier `non_facture` à la main ; ce calcul le fait
-- désormais tout seul, pour ceux déjà réglés comme pour les suivants.
--
-- Ce n'est pas un réglage : un dossier `non_facture` est par construction ce
-- qu'on ne facture à personne (`casse_personnel_non_facturee` interdit même
-- `facture` pour un `responsable` autre que `client`). Il n'y a pas de cas où
-- on voudrait y voir le prix de vente : le poser en paramètre inviterait à
-- choisir un prix qui ne s'est jamais produit.
--
-- Même remarque qu'en 0027 : `create or replace view` en garde les colonnes
-- et leurs types à l'identique (seule la formule de `montant` et du `prix` de
-- chaque ligne change), donc `v_dossiers_bouteille`, qui fige `i.*` au moment
-- de sa création, n'a pas besoin d'être recréée.

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
  i.redoter
from incidents_bouteille i
join emplacements e     on e.id = i.emplacement_id
left join utilisateurs uc on uc.id = i.constate_par
left join utilisateurs ut on ut.id = i.transmis_a
left join lateral (
  select
    string_agg(bt.libelle, ' + ' order by bt.libelle)                as libelles,
    sum(li.quantite)::int                                            as quantite,
    sum(li.quantite * case when i.statut = 'non_facture' then bt.prix_achat
                           when i.responsable = 'client'  then bt.prix_vente
                           else bt.prix_achat end)                    as montant_theorique,
    jsonb_agg(jsonb_build_object(
      'code', bt.code, 'libelle', bt.libelle, 'quantite', li.quantite,
      'prix', case when i.statut = 'non_facture' then bt.prix_achat
                    when i.responsable = 'client' then bt.prix_vente
                    else bt.prix_achat end)
      order by bt.libelle)                                           as detail
  from incident_lignes_bouteille li
  join bouteille_types bt on bt.id = li.bouteille_type_id
  where li.incident_id = i.id
) l on true;
