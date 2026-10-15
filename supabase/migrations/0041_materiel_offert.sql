-- =============================================================================
-- Migration 0041 : un produit peut être offert — sorti, gardé, pas compté
-- =============================================================================
-- Un fournisseur offre une pièce, un échantillon arrive gratuitement : elle
-- sort bien de la réserve — le technicien l'a utilisée, le stock doit le
-- dire — mais elle n'a rien coûté à l'hôtel. Compter son prix de référence
-- dans le coût du passage ferait passer un cadeau pour une dépense.
--
-- `gratuit` vit sur le mouvement, pas sur le produit : la même pièce peut
-- être payée une fois, offerte la suivante. Faux par défaut, jamais retiré
-- d'un mouvement existant par une migration — seul un geste explicite,
-- depuis la fiche du produit, le pose.
alter table mouvements_stock
  add column gratuit boolean not null default false;

comment on column mouvements_stock.gratuit is
  'Vrai pour une sortie dont le produit a été fourni sans frais (fournisseur, '
  'échantillon) : elle sort du stock et reste dans l''historique, mais ne '
  'compte pas dans le coût matériel d''un passage.';

-- `v_mouvements_reels` fait `select m.*`, mais Postgres fige la liste des
-- colonnes au moment où la vue est CRÉÉE — un `select *` ne se ré-étend pas
-- tout seul quand la table gagne une colonne. Il faut la recréer, à
-- l'identique, pour qu'elle porte enfin `gratuit`.
create or replace view v_mouvements_reels as
select m.*
  from mouvements_stock m
  left join emplacements e on e.id = m.emplacement_id
 where not coalesce(e.essai, false);

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
  -- Les sorties sont négatives : on reprend la valeur absolue pour obtenir un coût.
  -- Une sortie offerte (gratuit) est exclue du coût, pas du compte des
  -- articles sans prix — on SAIT son prix, on a juste choisi de ne pas le
  -- facturer au passage.
  select
    sum(abs(m.quantite) * p.prix_unitaire)
      filter (where p.prix_unitaire is not null and not m.gratuit)         as cout_materiel,
    count(*) filter (where p.prix_unitaire is null and not m.gratuit)      as articles_sans_prix
  from v_mouvements_reels m
  join produits p on p.id = m.produit_id
  where m.intervention_id = i.id and m.type = 'sortie'
) mat on true
left join v_cout_prestataire cp on cp.intervention_id = i.id;
