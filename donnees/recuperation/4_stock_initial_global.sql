-- Corriger le stock de départ : 46 filtrées et 44 gazeuses, c'est le compte
-- GLOBAL de l'hôtel, chambres comprises — confirmé par Miguel — pas la
-- réserve seule.
--
-- `outils/importer_bouteilles.py` avait posé les 46 et les 44 ENTIÈREMENT en
-- réserve (un mouvement « entrée »), ET séparément crédité chaque chambre
-- dotée de sa bouteille par une régularisation, comme il se doit (« chaque
-- chambre dotée avait ses deux bouteilles »). Résultat : les bouteilles déjà
-- en chambre étaient comptées deux fois — une fois par l'entrée, une fois par
-- la régularisation. Le stock théorique valait l'entrée ENTIÈRE plus les
-- chambres, au lieu de se limiter à 46 et 44 au total.
--
-- Ce fichier retire de l'entrée ce que les chambres ont déjà reçu — jamais un
-- nombre écrit en dur : une sous-requête compte, au moment où ce script
-- s'exécute, combien de bouteilles de chaque type les chambres actives et
-- dotées ont réellement reçues par régularisation. Rejoué une seconde fois,
-- il ne change plus rien : la quantité qu'il pose est déjà celle qu'il
-- calcule.
--
-- À jouer d'un bloc dans l'éditeur SQL de Supabase. Le résultat affiché à la
-- fin donne, pour chaque type de bouteille, l'entrée réservée à la réserve et
-- ce que les chambres ont reçu à part — les deux doivent s'additionner à 46
-- pour la filtrée, 44 pour la gazeuse.

begin;

update mouvements_bouteilles m
   set quantite = 46 - (
     select coalesce(sum(d.quantite), 0)
       from dotations d
       join emplacements e on e.id = d.emplacement_id
      where e.actif and e.dote_bouteilles
        and d.bouteille_type_id = m.bouteille_type_id
   )
 where m.type = 'entree'
   and m.commentaire = 'Livraison reprise de l''ancienne application'
   and m.bouteille_type_id = (select id from bouteille_types where code = 'filtree');

update mouvements_bouteilles m
   set quantite = 44 - (
     select coalesce(sum(d.quantite), 0)
       from dotations d
       join emplacements e on e.id = d.emplacement_id
      where e.actif and e.dote_bouteilles
        and d.bouteille_type_id = m.bouteille_type_id
   )
 where m.type = 'entree'
   and m.commentaire = 'Livraison reprise de l''ancienne application'
   and m.bouteille_type_id = (select id from bouteille_types where code = 'petillante');

-- Vérification : entrée réservée à la réserve + ce que les chambres ont reçu
-- = le compte global d'origine (46 filtrées, 44 gazeuses).
select bt.code,
       (select m.quantite from mouvements_bouteilles m
         where m.type = 'entree'
           and m.commentaire = 'Livraison reprise de l''ancienne application'
           and m.bouteille_type_id = bt.id)                          as entree_reserve,
       (select coalesce(sum(d.quantite), 0) from dotations d
         join emplacements e on e.id = d.emplacement_id
        where e.actif and e.dote_bouteilles and d.bouteille_type_id = bt.id)
                                                                       as deja_en_chambre,
       (select m.quantite from mouvements_bouteilles m
         where m.type = 'entree'
           and m.commentaire = 'Livraison reprise de l''ancienne application'
           and m.bouteille_type_id = bt.id)
       + (select coalesce(sum(d.quantite), 0) from dotations d
           join emplacements e on e.id = d.emplacement_id
          where e.actif and e.dote_bouteilles and d.bouteille_type_id = bt.id)
                                                                       as total_global
  from bouteille_types bt
 order by bt.code;

commit;
