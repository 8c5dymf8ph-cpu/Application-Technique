-- Des interventions sans tournée : un passage supprimé avant que la
-- migration 0036 (qui défait proprement tout ce qu'un passage a produit)
-- soit jouée en production a laissé ses interventions derrière lui.
--
-- Cause racine : avant la 0036, supprimer une tournée (bouton « Supprimer
-- ce passage », ou une suppression directe en SQL) ne portait qu'un
-- `interventions.tournee_id` en `on delete set null` — la tournée partait,
-- l'intervention restait, orpheline, avec ses sorties de stock et ses avis
-- toujours attachés. C'est ce qui a rendu invisible, le 21/09/2026, un
-- passage que Miguel voulait justement supprimer : plus aucune tournée
-- pour le porter dans l'historique, et le lien ajouté depuis `/stock` vers
-- l'intervention (`tournee_id`) ne pouvait pas non plus le retrouver.
--
-- `tournee_id` ne devient NULL que par ce chemin — aucun écran ne crée une
-- intervention sans tournée — donc `tournee_id is null` identifie
-- exactement ces orphelines, sans faux positif.
--
-- À jouer À LA SUITE dans l'éditeur SQL de Supabase — il n'affiche que le
-- résultat de la DERNIÈRE requête d'un bloc, donc jouer d'abord la requête 1
-- seule, vérifier la liste, puis jouer la requête 2.

-- ---------------------------------------------------------------------------
-- 1. Vérifier — les interventions orphelines, et ce qu'elles emportent.
-- ---------------------------------------------------------------------------
select i.id, i.date_intervention, a.description, e.code as lieu,
       (select string_agg(p.designation || ' × ' || abs(m.quantite), ', ')
          from mouvements_stock m join produits p on p.id = m.produit_id
         where m.intervention_id = i.id and m.type = 'sortie') as materiel
  from interventions i
  join anomalies a on a.id = i.anomalie_id
  join emplacements e on e.id = a.emplacement_id
 where i.tournee_id is null
 order by i.date_intervention desc;

-- ---------------------------------------------------------------------------
-- 2. Supprimer — seulement si la requête 1 correspond bien à ce qu'on veut
--    retirer. Ça emporte leurs sorties de stock (mouvements_stock, cascade)
--    et leurs avis (validations, cascade) ; l'anomalie elle-même reste dans
--    l'hôtel, intacte, comme pour une suppression de passage normale.
-- ---------------------------------------------------------------------------
delete from interventions where tournee_id is null
returning id, date_intervention, anomalie_id;
