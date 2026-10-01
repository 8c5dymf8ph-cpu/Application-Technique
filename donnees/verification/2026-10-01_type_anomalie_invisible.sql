-- Diagnostic sur l'anomalie 1264 (invisible pour Alain, spécialisé Électrique)
-- et sur l'ampleur du problème. Ne modifie rien.
--
-- Fait établi en lisant le code : `anomalies.type_id` est une COPIE posée au
-- moment de la création (ou de l'import), indépendante de
-- `catalogue_anomalies.type_id`. C'est `anomalies.type_id` qui décide si un
-- intervenant spécialisé voit l'anomalie (fn_anomalies_pour_intervenant) —
-- corriger seulement le catalogue ne suffirait pas sur une ligne déjà
-- importée.
--
-- À jouer une requête à la fois.

-- ---------------------------------------------------------------------------
-- 1. L'anomalie 1264 précisément : son type_id, celui du catalogue dont elle
--    vient, et si les deux sont d'accord.
-- ---------------------------------------------------------------------------
select a.sharepoint_id, a.description, a.statut,
       t_ligne.code as "type de la ligne (ce qui compte pour le filtre)",
       t_catalogue.code as "type du catalogue",
       c.libelle as "libellé du catalogue",
       case when a.type_id is null then 'AUCUN TYPE : invisible pour tout spécialiste'
            when t_ligne.code is distinct from t_catalogue.code
              then 'ÉCART : la ligne et son catalogue ne sont pas d''accord'
            else 'cohérent'
       end as diagnostic
  from anomalies a
  left join types_intervention t_ligne on t_ligne.id = a.type_id
  left join catalogue_anomalies c on c.id = a.catalogue_id
  left join types_intervention t_catalogue on t_catalogue.id = c.type_id
 where a.sharepoint_id = 1264;

-- ---------------------------------------------------------------------------
-- 2. L'ampleur : combien d'anomalies ACTIVES (à faire / en cours) n'ont AUCUN
--    type — invisibles pour tout intervenant spécialisé, pas seulement pour
--    l'électricien.
-- ---------------------------------------------------------------------------
select count(*) as nb_sans_type
  from anomalies
 where statut in ('a_faire', 'en_cours') and type_id is null;

-- ---------------------------------------------------------------------------
-- 3. Le désaccord ligne / catalogue : des anomalies actives dont le type
--    diffère de celui du catalogue dont elles sont issues — un signe que
--    l'export d'origine et le catalogue reconstruit ne racontaient pas la
--    même chose pour ce libellé.
-- ---------------------------------------------------------------------------
select a.sharepoint_id, a.description, t_ligne.code as type_ligne,
       t_catalogue.code as type_catalogue, c.libelle
  from anomalies a
  join types_intervention t_ligne on t_ligne.id = a.type_id
  join catalogue_anomalies c on c.id = a.catalogue_id
  join types_intervention t_catalogue on t_catalogue.id = c.type_id
 where a.statut in ('a_faire', 'en_cours')
   and t_ligne.code is distinct from t_catalogue.code
 order by a.sharepoint_id;
