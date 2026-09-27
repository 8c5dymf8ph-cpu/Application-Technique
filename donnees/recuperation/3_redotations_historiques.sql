-- Rattraper l'historique des re-dotations de bouteilles.
--
-- `outils/importer_bouteilles.py` a repris chaque « Perte » avec
-- `redoter = false`, quoi qu'il arrive — et quand la liste Microsoft portait
-- une ligne « Remplacement » en face, il l'a écrite comme un mouvement
-- SÉPARÉ, jamais rattaché au dossier (`incident_id` nul). C'était voulu :
-- un remplacement peut arriver plusieurs jours après la perte (chambre 18 :
-- perte le 13/05, remplacement le 19/05, la réserve était vide), et l'écran
-- de correction ne sait dater la re-dotation que le même jour que le
-- constat. Le détacher était le seul moyen de garder la vraie date.
--
-- Résultat : la fiche d'un dossier affiche « Non re-dotée » pour tout
-- l'historique repris, même quand la chambre a bien été resservie — la
-- colonne `redoter` est fausse, pas l'écran qui la lit.
--
-- Ce fichier fait deux choses, dans cet ordre :
--
-- 1. Retire un DOUBLON trouvé dans l'export des mouvements : chambres 12
--    (20/07) et 46 (13/07) ont chacune reçu leur remplacement deux fois —
--    une fois via « Remplacer » (geste manuel de Miguel, mouvement
--    détaché), une fois via le dossier lui-même, qui portait déjà
--    `redoter = true` et sa propre re-dotation liée. Deux bouteilles de
--    trop sorties de la réserve. On retire le geste manuel : le dossier
--    reste la source de vérité pour ce qu'il a produit.
--
-- 2. RATTACHE au dossier chaque mouvement de remplacement qui existe déjà
--    mais reste détaché, puis seulement ensuite coche `redoter`. L'ordre
--    compte : le déclencheur de la migration 0014 ne pose une nouvelle
--    re-dotation que s'il n'en trouve AUCUNE déjà liée à ce dossier pour ce
--    type de bouteille — rattacher d'abord le fait trouver celle qui
--    existe, et il n'en crée pas une seconde. Cocher la case avant de
--    rattacher aurait recréé exactement le doublon du point 1.
--
--    Chaque mouvement rattaché GARDE sa date réelle : on ne touche à
--    `constate_le` nulle part ici.
--
-- Rejouable sans risque : si une ligne est déjà rattachée ou déjà cochée,
-- la mise à jour ne fait rien de plus.
--
-- À jouer d'un bloc dans l'éditeur SQL de Supabase. Le résultat affiché à
-- la fin dit, pour chaque dossier touché, combien de re-dotations il porte
-- désormais — jamais plus d'une par type de bouteille qu'il concerne.

begin;

-- -----------------------------------------------------------------------
-- 1. Le doublon : chambres 12 et 46, chacune remplacée deux fois le même
--    jour. On ne retire que le geste manuel de Miguel, et seulement là où
--    une re-dotation déjà liée à un dossier existe pour le même jour et le
--    même type — la condition `exists` protège contre une suppression sur
--    une chambre qui n'a pas ce doublon.
-- -----------------------------------------------------------------------
delete from mouvements_bouteilles m
 using emplacements e, utilisateurs u
 where m.type = 'dotation'
   and m.commentaire = 'Remplacement en chambre'
   and m.vers_emplacement_id = e.id
   and m.utilisateur_id = u.id
   and u.nom = 'Miguel'
   and e.code in ('12', '46')
   and m.date_mouvement::date in ('2026-07-20', '2026-07-13')
   and exists (
     select 1 from mouvements_bouteilles m2
      where m2.type = 'dotation'
        and m2.vers_emplacement_id = m.vers_emplacement_id
        and m2.bouteille_type_id = m.bouteille_type_id
        and m2.date_mouvement::date = m.date_mouvement::date
        and m2.incident_id is not null
   )
returning m.id, e.code as chambre, m.bouteille_type_id, m.date_mouvement;

-- -----------------------------------------------------------------------
-- 2. Rattacher, puis cocher. Six dossiers, chacun identifié par son numéro
--    de référence (visible sur sa fiche) et le mouvement de remplacement
--    qui lui correspond déjà dans la réserve.
-- -----------------------------------------------------------------------

-- Dossier n° 2 — chambre 46, perte le 08/04, remplacée le jour même.
update mouvements_bouteilles
   set incident_id = (select id from incidents_bouteille where reference = 2)
 where commentaire = 'Remplacement repris — REMPL-46-080420260,5197314';
update incidents_bouteille set redoter = true where reference = 2;

-- Dossier n° 3 — chambre 11, perte le 13/04, remplacée le jour même.
update mouvements_bouteilles
   set incident_id = (select id from incidents_bouteille where reference = 3)
 where commentaire = 'Remplacement repris — REMPL-11-130420260,43524213';
update incidents_bouteille set redoter = true where reference = 3;

-- Dossier n° 4 — chambre 35, perte le 15/04, remplacée le jour même (les
-- deux types : filtrée et gazeuse).
update mouvements_bouteilles
   set incident_id = (select id from incidents_bouteille where reference = 4)
 where commentaire = 'Remplacement repris — REMPL-35-150420260,7616837';
update incidents_bouteille set redoter = true where reference = 4;

-- Dossier n° 9 — chambre 18, perte le 13/05, remplacée le 19/05 : la
-- réserve était vide six jours. Le mouvement garde le 19/05, pas le 13/05.
update mouvements_bouteilles
   set incident_id = (select id from incidents_bouteille where reference = 9)
 where commentaire = 'Remplacement repris — REMPL-18-190520260,51746711';
update incidents_bouteille set redoter = true where reference = 9;

-- Dossier n° 15 — chambre 36, perte le 15/09, remplacée le jour même (les
-- deux types).
update mouvements_bouteilles
   set incident_id = (select id from incidents_bouteille where reference = 15)
 where commentaire = 'Remplacement repris — REMPL-36-150920260,2648282';
update incidents_bouteille set redoter = true where reference = 15;

-- Dossier n° 33 — chambre 31, perte le 17/07, remplacée le jour même via le
-- geste manuel de Miguel (« Remplacer »), jamais reliée au dossier jusqu'ici.
update mouvements_bouteilles
   set incident_id = (select id from incidents_bouteille where reference = 33)
 where type = 'dotation' and commentaire = 'Remplacement en chambre'
   and vers_emplacement_id = (select id from emplacements where code = '31')
   and date_mouvement::date = '2026-07-17';
update incidents_bouteille set redoter = true where reference = 33;

-- -----------------------------------------------------------------------
-- Vérification : chaque dossier touché a désormais exactement une
-- re-dotation par type de bouteille qu'il porte — jamais deux, jamais zéro.
-- -----------------------------------------------------------------------
select i.reference, e.code as chambre, i.redoter,
       count(m.id) as nb_redotations,
       count(distinct l.bouteille_type_id) as nb_types_concernes
  from incidents_bouteille i
  join emplacements e on e.id = i.emplacement_id
  join incident_lignes_bouteille l on l.incident_id = i.id
  left join mouvements_bouteilles m
    on m.incident_id = i.id and m.type = 'dotation'
       and m.bouteille_type_id = l.bouteille_type_id
 where i.reference in (2, 3, 4, 9, 15, 33)
 group by i.reference, e.code, i.redoter
 order by i.reference;

commit;
