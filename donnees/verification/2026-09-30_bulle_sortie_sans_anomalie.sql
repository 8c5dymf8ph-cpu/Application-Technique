-- La bulle du fil vue sur les sorties d'Alain du 10/07/2024 (et sans doute
-- d'autres, "principalement de 2024") est une bulle DIFFÉRENTE de celle
-- déjà corrigée pour 832/839 : ces sorties n'affichent AUCUNE anomalie
-- après leur date (contrairement à celles de 2025, qui portent bien
-- « · bloc secour/batterie a changer ») — signe que `intervention_id` est
-- NUL sur ces lignes. Dans ce cas, l'écran retombe sur le commentaire posé
-- directement sur le MOUVEMENT (`mouvements_stock.commentaire`), rempli par
-- `outils/importer_stock.py` depuis une colonne « Commentaire » d'un
-- tableau différent (MouvementsStock.xlsm) — pas celui des anomalies déjà
-- vérifié. Cette requête montre ce que porte vraiment cette colonne pour
-- ces lignes-là, avant de savoir si c'est un vrai mot ou une répétition à
-- filtrer.
select m.id, m.date_mouvement, m.quantite, pr.designation as produit,
       e.code as lieu, coalesce(u.nom, p.nom) as qui,
       m.intervention_id, m.commentaire,
       a.sharepoint_id as anomalie_sharepoint_id, a.description as anomalie_description
  from mouvements_stock m
  join produits pr on pr.id = m.produit_id
  left join emplacements e on e.id = m.emplacement_id
  left join utilisateurs u on u.id = m.utilisateur_id
  left join prestataires p on p.id = m.prestataire_id
  left join interventions i on i.id = m.intervention_id
  left join anomalies a on a.id = i.anomalie_id
 where m.type = 'sortie'
   and m.date_mouvement::date = date '2024-07-10'
   and coalesce(u.nom, p.nom) = 'Alain'
 order by m.id;
