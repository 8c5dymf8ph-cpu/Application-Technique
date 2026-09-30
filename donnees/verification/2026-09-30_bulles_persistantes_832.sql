-- Suite du 30/09 : la bulle persiste encore par endroits (832, et d'autres
-- captures sur un produit "flexible douche"). Deux requêtes, pour voir la
-- vraie étendue avant de retoucher le code une troisième fois à l'aveugle.
--
-- À jouer une requête à la fois dans l'éditeur SQL de Supabase.

-- ---------------------------------------------------------------------------
-- 1. L'anomalie 832 précisément : d'où vient EXACTEMENT ce qui s'affiche
--    dans sa bulle — `commentaires` (déjà vérifié vide de fantômes) ou
--    `validations` (jamais vérifié directement pour elle) ? Si aucune ligne
--    ne sort ici, la bulle ne vient d'aucun des deux, et le problème est
--    ailleurs (peut-être une autre anomalie confondue avec la 832 à l'écran).
-- ---------------------------------------------------------------------------
select 'commentaires' as source, c.origine::text, c.texte, u.nom as auteur, c.ecrit_le as quand
  from commentaires c
  join anomalies a on a.id = c.anomalie_id
  left join utilisateurs u on u.id = c.auteur_id
 where a.sharepoint_id = 832
union all
select 'validations', v.acteur::text, v.commentaire, coalesce(u.nom, p.nom), v.decide_le
  from validations v
  join interventions i on i.id = v.intervention_id
  join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.id = v.utilisateur_id
  left join prestataires p on p.id = v.utilisateur_id
 where a.sharepoint_id = 832;

-- ---------------------------------------------------------------------------
-- 2. Le motif recopié (Alain, 10/07/2024) n'était peut-être qu'un cas parmi
--    d'autres : cette requête montre, pour toutes les SORTIES sans anomalie
--    liée, quels textes de commentaire reviennent, sur combien de lignes,
--    combien de PRODUITS et de JOURS différents. Un texte qui revient sur
--    plusieurs jours (pas seulement plusieurs lieux le même jour) n'est pas
--    attrapé par le filtre déjà posé, qui ne compare qu'à l'intérieur d'une
--    même journée pour le même intervenant.
-- ---------------------------------------------------------------------------
select m.commentaire,
       count(*) as nb_lignes,
       count(distinct m.produit_id) as nb_produits,
       count(distinct m.date_mouvement::date) as nb_jours,
       min(m.date_mouvement::date) as premiere_fois,
       max(m.date_mouvement::date) as derniere_fois,
       string_agg(distinct coalesce(u.nom, p.nom), ', ') as intervenants
  from mouvements_stock m
  left join utilisateurs u  on u.id = m.utilisateur_id
  left join prestataires p  on p.id = m.prestataire_id
 where m.type = 'sortie'
   and m.intervention_id is null
   and m.commentaire is not null
 group by m.commentaire
having count(*) > 1
 order by nb_lignes desc, nb_jours desc
 limit 40;
