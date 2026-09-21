-- =============================================================================
-- Migration 0013 : un essai ne touche pas le stock
-- =============================================================================
-- Les chambres 06 et 07 sont là pour qu'on puisse répéter le geste complet sans
-- salir les chiffres de l'hôtel. La 0008 les a créées et les a écartées des
-- compteurs de l'accueil — mais elle s'est arrêtée là. Déclarer une anomalie en
-- 06, cocher deux joints et appuyer sur « C'est fait » sortait deux joints de la
-- réserve, pour de bon : le stock baissait, le seuil pouvait se déclencher, le
-- coût du passage était compté. Miguel l'a constaté deux fois.
--
-- Or personne n'est allé chercher un joint sur l'étagère : il n'y a pas eu de
-- sortie. Un mouvement passé dans un lieu d'essai n'est pas un mouvement de
-- stock.
--
-- On ne l'efface pas pour autant : le technicien doit revoir ce qu'il a coché,
-- et la gouvernante doit pouvoir le valider — c'est tout l'intérêt de répéter.
-- La ligne reste donc, avec son lieu ; c'est le lieu qui dit qu'elle ne compte
-- pas. Rien de nouveau n'est stocké : la vérité est déjà dans
-- `emplacements.essai`.
--
-- Et comme la définition d'un « vrai mouvement » ne doit pas se répéter de vue
-- en vue — une seule oubliée et les essais reviennent dans les chiffres —, elle
-- est posée UNE FOIS ici. Les deux vues qui comptent (le stock, le coût d'une
-- intervention) la lisent.
--
-- Les deux sorties déjà passées se corrigent d'elles-mêmes : elles portent la
-- chambre d'essai, donc la nouvelle vue les écarte, hier comme aujourd'hui.

-- -----------------------------------------------------------------------------
-- Ce qui compte vraiment
-- -----------------------------------------------------------------------------
-- Une entrée de commande et un ajustement d'inventaire n'ont pas d'emplacement,
-- ou portent la réserve : ils passent. Seules les sorties faites dans un lieu
-- d'essai sont écartées.
--
-- `m.*` est figé à la création de la vue : une colonne ajoutée plus tard à
-- `mouvements_stock` n'apparaîtra ici qu'en rejouant ce `create or replace`.
create or replace view v_mouvements_reels as
select m.*
  from mouvements_stock m
  left join emplacements e on e.id = m.emplacement_id
 where not coalesce(e.essai, false);

comment on view v_mouvements_reels is
  'Les mouvements de stock qui comptent : tout sauf ce qui s''est passé dans un '
  'lieu d''essai. C''est la seule définition — les vues de stock et de coût la '
  'lisent plutôt que de refaire le filtre chacune de leur côté.';

-- -----------------------------------------------------------------------------
-- Le stock : mêmes colonnes, même ordre — seule la source change
-- -----------------------------------------------------------------------------
create or replace view v_stock_produits as
select
  p.id,
  p.code,
  p.designation,
  p.categorie,
  p.categorie_lieu,
  p.unite,
  p.prix_unitaire,
  p.prix_unitaire is null                              as prix_inconnu,
  p.seuil_alerte,
  p.quantite_reappro,
  ph.chemin                                            as photo_principale,
  (select count(*) from photos_produit x where x.produit_id = p.id) as nb_photos,
  p.actif,
  coalesce(sum(m.quantite) filter (where m.type = 'entree'), 0)          as total_entrees,
  coalesce(-sum(m.quantite) filter (where m.type = 'sortie'), 0)         as total_sorties,
  coalesce(sum(m.quantite) filter (where m.type = 'regularisation'), 0)  as total_ajustements,
  coalesce(sum(m.quantite), 0)                         as stock,
  coalesce(sum(m.quantite), 0) * p.prix_unitaire       as valeur_stock,
  coalesce(sum(m.quantite), 0) <= p.seuil_alerte       as sous_seuil,
  max(m.date_mouvement)                                as dernier_mouvement,
  pr.dernier_prix,
  pr.variation_pct,
  -- Le fournisseur préféré, et son adresse : c'est à lui que part la demande.
  fo.fournisseur,
  fo.email_fournisseur,
  fo.nb_fournisseurs
from produits p
left join v_mouvements_reels m on m.produit_id = p.id
left join v_prix_produit pr  on pr.produit_id = p.id
left join lateral (
  select chemin from photos_produit x
  where x.produit_id = p.id order by x.principale desc, x.ordre limit 1
) ph on true
left join lateral (
  select f.nom as fournisseur, f.email as email_fournisseur,
         (select count(*)::int from article_fournisseurs y where y.produit_id = p.id)
           as nb_fournisseurs
  from article_fournisseurs af
  join fournisseurs f on f.id = af.fournisseur_id
  where af.produit_id = p.id
  order by af.prefere desc, f.nom limit 1
) fo on true
group by p.id, ph.chemin, pr.dernier_prix, pr.variation_pct,
         fo.fournisseur, fo.email_fournisseur, fo.nb_fournisseurs;

-- -----------------------------------------------------------------------------
-- Le coût d'une intervention : du matériel qui n'est pas sorti ne coûte rien
-- -----------------------------------------------------------------------------
-- Sinon un passage d'essai gonflerait le total du mois dans l'historique, et le
-- récapitulatif annoncerait un coût pour une répétition.
create or replace view v_interventions_cout as
select
  i.id                                     as intervention_id,
  i.anomalie_id,
  coalesce(mat.cout_materiel, 0)           as cout_materiel,
  coalesce(mat.articles_sans_prix, 0)      as articles_sans_prix,
  coalesce(cp.cout_prestataire, 0)         as cout_prestataire,
  i.cout_divers,
  coalesce(mat.cout_materiel, 0) + coalesce(cp.cout_prestataire, 0) + i.cout_divers as cout_total,
  -- Vrai quand du matériel sans prix connu a été utilisé : le total affiché est
  -- alors un minimum, ce que l'interface doit dire explicitement.
  coalesce(mat.articles_sans_prix, 0) > 0  as cout_incomplet
from interventions i
left join lateral (
  -- Les sorties sont négatives : on reprend la valeur absolue pour obtenir un coût
  select
    sum(abs(m.quantite) * p.prix_unitaire) filter (where p.prix_unitaire is not null) as cout_materiel,
    count(*) filter (where p.prix_unitaire is null)                                   as articles_sans_prix
  from v_mouvements_reels m
  join produits p on p.id = m.produit_id
  where m.intervention_id = i.id and m.type = 'sortie'
) mat on true
left join v_cout_prestataire cp on cp.intervention_id = i.id;

-- Une vue applique les droits de l'appelant, jamais ceux de son propriétaire :
-- sans cela elle contournerait les règles de sécurité.
alter view v_mouvements_reels set (security_invoker = on);
grant select on v_mouvements_reels to authenticated;
