-- Corrige une sortie de stock qui n'aurait jamais dû être enregistrée :
-- l'anomalie n° 819 (« Batterie du bloc secours à changer (celui en face de
-- la chambre 28) », 2ème étage, faite le 16/11/2025 par Hedi) a produit une
-- sortie de -1 NI-Cd 2,4V 1,5AH (URA), alors que le tableau d'origine
-- portait une quantité de 0 pour cette ligne, et que son propre commentaire
-- le confirme : « Le 16/11/25 Hedi a changé une seule batterie sur les deux
-- et pour l'instant tout semble en ordre - je n'ai pas modifé le stock
-- parce que d'après lui la batterie fonctionne encore à confirmer ».
--
-- Cause racine : les scripts de reprise (outils/retrouver_les_anomalies_
-- disparues.py et outils/reprendre_export.py) écrivaient
-- -greatest(coalesce(quantite, 1), 1) — coalesce() ne remplace que le NULL,
-- jamais le 0, donc un 0 EXPLICITE (compté, et nul) était traité comme
-- « pas noté » et remonté à 1. Les deux scripts sont corrigés pour l'avenir
-- (ils écartent désormais toute ligne où la quantité vaut explicitement 0) ;
-- ce fichier corrige la seule ligne déjà écrite en base.
--
-- À jouer À LA SUITE dans l'éditeur SQL de Supabase — il n'affiche que le
-- résultat de la DERNIÈRE requête d'un bloc, donc jouer d'abord la requête 1
-- seule, vérifier qu'elle ne montre qu'UNE ligne et que c'est la bonne,
-- puis jouer la requête 2.

-- ---------------------------------------------------------------------------
-- 1. Vérifier — la ligne, et rien d'autre, avant de toucher à quoi que ce
--    soit. Doit rendre exactement une sortie de -1, datée du 16/11/2025.
-- ---------------------------------------------------------------------------
select m.id, m.type::text, m.quantite, m.date_mouvement,
       pr.designation as produit, e.code as lieu,
       coalesce(u.nom, pt.nom) as par, a.sharepoint_id, m.commentaire
  from mouvements_stock m
  join produits pr on pr.id = m.produit_id
  join interventions i on i.id = m.intervention_id
  join anomalies a on a.id = i.anomalie_id
  left join emplacements e on e.id = m.emplacement_id
  left join utilisateurs u on u.id = m.utilisateur_id
  left join prestataires pt on pt.id = m.prestataire_id
 where a.sharepoint_id = 819
   and pr.code = 'NI-Cd 2,4V 1,5AH (URA)'
   and m.type = 'sortie';

-- ---------------------------------------------------------------------------
-- 2. Supprimer — seulement si la requête 1 a rendu exactement cette ligne.
--    Rien d'autre ne référence mouvements_stock.id : la suppression est
--    directe, et le stock (une somme, jamais un chiffre stocké — règle 1)
--    remonte de lui-même d'une unité au prochain calcul.
-- ---------------------------------------------------------------------------
delete from mouvements_stock m
 using interventions i, anomalies a, produits pr
 where m.intervention_id = i.id
   and i.anomalie_id = a.id
   and pr.id = m.produit_id
   and a.sharepoint_id = 819
   and pr.code = 'NI-Cd 2,4V 1,5AH (URA)'
   and m.type = 'sortie'
returning m.id, m.quantite, m.date_mouvement;
