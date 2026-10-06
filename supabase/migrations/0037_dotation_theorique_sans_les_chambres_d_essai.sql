-- =============================================================================
-- Migration 0037 : la dotation théorique ne compte plus les chambres d'essai
-- =============================================================================
-- « 37/39 en chambre » pour l'eau filtrée, alors que l'hôtel compte 37
-- chambres dotées — Miguel l'a mesuré en comptant physiquement : 39, pas 37.
--
-- La 0026 a posé le filtre essai pour `en_chambre`, `en_reserve`,
-- `parc_detenu`, `parc_theorique` — tout ce qui dérive de
-- `v_bouteilles_positions`, elle-même rebranchée sur `v_mouvements_bouteilles_reels`.
-- Mais `dotation_theorique`, dans `v_stock_bouteilles`, ne passe PAS par cette
-- vue : c'est un sous-select direct sur `dotations`, sans jointure vers
-- `emplacements`, donc sans moyen d'exclure 06 et 07. Les deux chambres
-- d'essai sont dotées comme n'importe quelle autre (il faut pouvoir y
-- déclarer une perte pour s'entraîner) : leurs deux lignes de `dotations`
-- s'ajoutaient donc au compte de l'hôtel réel — 37 + 2 = 39, exactement
-- l'écart mesuré.
--
-- Même principe que la 0026 : exclure au même endroit unique plutôt que vue
-- par vue, pour que le prochain chiffre dérivé de `dotations` n'ait pas à
-- retenir la règle.
create or replace view v_stock_bouteilles as
select
  bt.id                as bouteille_type_id,
  bt.code,
  bt.libelle,
  bt.couleur,
  bt.photo,
  bt.prix_vente,
  bt.prix_achat,
  bt.seuil_alerte,
  coalesce(sum(p.qte) filter (where p.lieu = 'reserve'), 0)      as en_reserve,
  coalesce(sum(p.qte) filter (where p.lieu = 'emplacement'), 0)  as en_chambre,
  coalesce(sum(p.qte) filter (where p.lieu = 'chez_client'), 0)  as chez_clients,
  coalesce(sum(p.qte) filter (where p.lieu in ('reserve', 'emplacement')), 0) as parc_detenu,
  coalesce(sum(p.qte), 0)                                        as parc_theorique,
  coalesce(d.dotation_theorique, 0)                              as dotation_theorique,
  coalesce(sum(p.qte) filter (where p.lieu = 'reserve'), 0) <= bt.seuil_alerte as sous_seuil
from bouteille_types bt
left join v_bouteilles_positions p on p.bouteille_type_id = bt.id
left join lateral (
  select sum(d2.quantite) as dotation_theorique
    from dotations d2
    join emplacements e2 on e2.id = d2.emplacement_id
   where d2.bouteille_type_id = bt.id
     and not coalesce(e2.essai, false)
) d on true
group by bt.id, d.dotation_theorique;

comment on view v_stock_bouteilles is
  'Le parc de bouteilles, type par type. `dotation_theorique` exclut les '
  'chambres d''essai (06, 07) depuis la 0037 — elles sont dotées comme les '
  'autres pour qu''on puisse s''y entraîner, mais ne comptent pas dans ce '
  'que l''hôtel doit vraiment avoir.';
