-- =============================================================================
-- Migration 0026 : un essai ne touche pas les bouteilles non plus
-- =============================================================================
-- La 0013 a posé la règle pour le matériel : un mouvement passé dans une
-- chambre d'essai (06, 07) n'est pas un mouvement de stock. Elle ne parlait
-- que de `mouvements_stock` — les bouteilles n'ont jamais été couvertes.
-- Déclarer une bouteille perdue en 06 pour montrer le geste sortait pour de
-- bon une bouteille du parc détenu, et re-doter la chambre en 06 sortait pour
-- de bon une bouteille de la réserve : exactement le défaut que la 0013
-- corrigeait côté matériel.
--
-- Même geste, même endroit unique : `v_bouteilles_positions` est la SEULE vue
-- qui lit `mouvements_bouteilles` directement (v_stock_bouteilles et
-- v_bouteilles_par_emplacement en dérivent toutes les deux) — un filtre posé
-- ici vaut pour le parc entier, sans le répéter vue par vue.
--
-- La ligne reste, avec son lieu — on ne l'efface pas, le dossier existe
-- toujours et doit pouvoir se corriger comme n'importe quel autre. C'est le
-- lieu qui dit qu'elle ne compte pas dans le parc.

create or replace view v_mouvements_bouteilles_reels as
select m.*
  from mouvements_bouteilles m
  left join emplacements e_de   on e_de.id = m.de_emplacement_id
  left join emplacements e_vers on e_vers.id = m.vers_emplacement_id
 where not coalesce(e_de.essai, false)
   and not coalesce(e_vers.essai, false);

comment on view v_mouvements_bouteilles_reels is
  'Les mouvements de bouteilles qui comptent : tout sauf ce qui touche un lieu '
  'd''essai, d''un côté comme de l''autre du mouvement. Pendant du '
  'v_mouvements_reels de la 0013, pour le parc plutôt que pour le stock.';

create or replace view v_bouteilles_positions as
select
  m.bouteille_type_id,
  f.lieu,
  f.emplacement_id,
  f.qte
from v_mouvements_bouteilles_reels m
cross join lateral (values
  (m.vers_lieu, m.vers_emplacement_id,  m.quantite),
  (m.de_lieu,   m.de_emplacement_id,   -m.quantite)
) as f (lieu, emplacement_id, qte)
where f.lieu <> 'hors_parc';

alter view v_mouvements_bouteilles_reels set (security_invoker = on);
grant select on v_mouvements_bouteilles_reels to authenticated;
