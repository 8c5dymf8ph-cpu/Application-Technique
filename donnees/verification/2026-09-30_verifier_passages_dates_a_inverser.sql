-- Suite du diagnostic du 30/09/2026 : les résultats reçus disent deux choses
-- importantes.
--
-- 1. Les requêtes 1 et 2 du script précédent n'ont RIEN trouvé : aucun
--    commentaire en base ne s'écarte de l'export. Pour l'anomalie 832 en
--    particulier, ça veut dire qu'il n'y a tout simplement PLUS de ligne
--    dans `commentaires` pour elle qui ne corresponde pas à l'export — donc
--    soit elle n'en a jamais eu, soit elle a déjà été nettoyée. Rien à faire
--    ici : la base est propre au sens de ce contrôle. Si la bulle affiche
--    encore quelque chose d'inattendu pour la 832 aujourd'hui, ce n'est
--    plus un problème de données — à redire, et je regarde le code.
--
-- 2. Les 9 inversions jour/mois sont confirmées présentes dans l'export.
--    Cinq d'entre elles (461, 537, 638, 752, 777) partagent la même date
--    « FAIT_LE » : probablement le même passage (même intervenant, même
--    jour), touché une seule fois à la saisie. AVANT de corriger, il faut
--    savoir si ce passage ne contient QUE ces cinq anomalies, ou s'il en
--    porte d'autres dont la date, elle, est déjà correcte — parce que
--    corriger depuis l'écran du PASSAGE déplace TOUTES ses interventions
--    d'un coup (règle « Corriger une donnée n'est pas un geste de
--    terrain »).
--
-- Cette requête ne modifie rien : elle dit comment corriger chaque cas.

-- ---------------------------------------------------------------------------
-- A. Les 5 anomalies du 06/02 → 02/06 : à quel(s) passage(s) appartiennent-
--    elles, et ce passage porte-t-il d'AUTRES interventions ?
-- ---------------------------------------------------------------------------
select
  a.sharepoint_id,
  a.description,
  i.date_intervention,
  t.id as tournee_id,
  t.date_tournee as date_du_passage,
  coalesce(u.nom, p.nom) as intervenant,
  (select count(*) from interventions i2 where i2.tournee_id = t.id) as nb_interventions_du_passage,
  (select string_agg(a2.sharepoint_id::text, ', ' order by a2.sharepoint_id)
     from interventions i2 join anomalies a2 on a2.id = i2.anomalie_id
    where i2.tournee_id = t.id) as toutes_les_anomalies_du_passage
from anomalies a
join interventions i on i.anomalie_id = a.id
join tournees t on t.id = i.tournee_id
left join utilisateurs u on u.id = t.technicien_id
left join prestataires p on p.id = t.prestataire_id
where a.sharepoint_id in (461, 537, 638, 752, 777)
order by a.sharepoint_id;

-- Lire le résultat :
--  - si « toutes_les_anomalies_du_passage » ne contient QUE 461, 537, 638,
--    752, 777 (et rien d'autre) → corriger la DATE DU PASSAGE une seule
--    fois, depuis l'écran du passage (/technique/tournee/<id>, réservé à
--    Sarah P et Miguel) : les cinq suivent d'un coup, comme prévu par la
--    règle.
--  - si d'autres numéros apparaissent → ne PAS corriger le passage entier :
--    corriger chaque anomalie une par une, depuis sa propre fiche
--    (la date d'intervention s'y règle aussi) — sinon on décale des
--    interventions qui étaient déjà à la bonne date.

-- ---------------------------------------------------------------------------
-- B. Les 4 dates de DÉCLARATION à inverser (380, 386, 695, 863) : indépendantes
--    les unes des autres, à corriger depuis la fiche de chaque anomalie —
--    pas de passage à vérifier ici.
-- ---------------------------------------------------------------------------
select a.sharepoint_id, a.description, a.declare_le, a.id
  from anomalies a
 where a.sharepoint_id in (380, 386, 695, 863)
 order by a.sharepoint_id;
