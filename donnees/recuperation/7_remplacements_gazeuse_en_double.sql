-- Trois chambres (35, 46, 52) portaient 2 bouteilles d'eau gazeuse en
-- théorique au lieu d'1 — c'est ce qui faisait dire « 40 en chambre » à
-- l'application alors que l'hôtel ne compte que 37 chambres réelles.
--
-- Cause racine : `app/bouteilles/signaler/page.tsx`, en mode remplacement,
-- cherchait un dossier encore « à re-doter » (`redoter = false`) pour
-- rattacher le mouvement ; quand il n'en trouvait pas, il posait quand même
-- la dotation, détachée, avec le commentaire nu « Remplacement en chambre ».
-- Dans ces trois chambres, une re-dotation légitime avait déjà eu lieu la
-- même heure (rattachée, elle) — celle-ci s'ajoutait en trop. Corrigé cette
-- session : le formulaire ne propose plus que les types réellement manquants
-- de la chambre (règle g, remplacement limité à la bouteille perdue).
--
-- Vérifié physiquement par Miguel le 06/10/2026 : les trois chambres n'ont
-- qu'UNE bouteille gazeuse chacune. Aucune bouteille n'a donc réellement
-- bougé pour ces trois mouvements : à supprimer, pas à compenser par un
-- retour.
--
-- Un 4ème mouvement au même commentaire existe (chambre 31, 17/07/2026) :
-- il n'est pas en double — la chambre n'a eu qu'un seul dossier et le
-- solde y est resté à 1 — donc exclu d'ici. Simple oubli de rattachement
-- au dossier n° 33, sans conséquence sur le stock.
--
-- À jouer À LA SUITE dans l'éditeur SQL de Supabase — il n'affiche que le
-- résultat de la DERNIÈRE requête d'un bloc, donc jouer d'abord la requête 1
-- seule, vérifier qu'elle rend exactement ces trois lignes, puis jouer la
-- requête 2.

-- ---------------------------------------------------------------------------
-- 1. Vérifier — doit rendre exactement 3 lignes : chambres 35, 46, 52,
--    chacune à sa date.
-- ---------------------------------------------------------------------------
select m.id, m.date_mouvement, e.code as chambre, m.commentaire,
       coalesce(u.nom, pt.nom) as par
  from mouvements_bouteilles m
  join bouteille_types bt on bt.id = m.bouteille_type_id
  join emplacements e on e.id = m.vers_emplacement_id
  left join utilisateurs u on u.id = m.utilisateur_id
  left join prestataires pt on pt.id = m.prestataire_id
 where m.type = 'dotation'
   and bt.code = 'petillante'
   and m.de_lieu = 'reserve'
   and m.vers_lieu = 'emplacement'
   and m.commentaire = 'Remplacement en chambre'
   and m.incident_id is null
   and e.code in ('35', '46', '52')
 order by m.date_mouvement;

-- ---------------------------------------------------------------------------
-- 2. Supprimer — seulement si la requête 1 a rendu exactement ces trois
--    lignes. Le théorique « en réserve » de l'eau gazeuse remonte de 3
--    (34 → 37) et le « en chambre » redescend de 3 (40 → 37) au prochain
--    calcul — rien n'est stocké, donc rien d'autre à toucher.
-- ---------------------------------------------------------------------------
delete from mouvements_bouteilles m
 using bouteille_types bt, emplacements e
 where m.bouteille_type_id = bt.id
   and m.vers_emplacement_id = e.id
   and m.type = 'dotation'
   and bt.code = 'petillante'
   and m.de_lieu = 'reserve'
   and m.vers_lieu = 'emplacement'
   and m.commentaire = 'Remplacement en chambre'
   and m.incident_id is null
   and e.code in ('35', '46', '52')
returning m.id, m.date_mouvement, e.code;
