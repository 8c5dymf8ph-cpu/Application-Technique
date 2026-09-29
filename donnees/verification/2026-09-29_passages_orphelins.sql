-- Des passages manquent dans /technique/historique pour « Technicien Telec »
-- (anomalies 823, 824, 839, 840 notamment). Cause : les blocs
-- `insert into interventions (...)` de donnees/import_anomalies.sql
-- écrivent `left join tournees t on t.reference = null` — une comparaison à
-- NULL ne matche jamais rien, donc `t.id` est TOUJOURS null et ces
-- interventions sont entrées en base sans tournée. La migration 0015 a bien
-- une fonction pour recoller ça (fn_regrouper_les_passages, « rejouable » :
-- « après chaque reprise d'export, on rappelle la fonction »), mais elle
-- n'a tourné qu'au moment de son installation — avant que ces lignes
-- n'existent. Il suffit de la rappeler.
--
-- L'anomalie 832 (affichage signalé différent sur sa fiche) porte la même
-- forme de ligne dans l'export — mise dans la requête 2 par précaution, pour
-- voir si elle est logée à la même enseigne. Le motif RÉEL de la différence
-- vue à l'écran reste à confirmer : sans la capture, impossible de dire si
-- c'est ce même défaut (pas de passage rattaché) ou autre chose.
--
-- À jouer une requête à la fois dans l'éditeur SQL de Supabase.

-- ---------------------------------------------------------------------------
-- 1. L'ampleur : toutes les interventions reprises (sharepoint_id non nul)
--    sans tournée, par intervenant.
-- ---------------------------------------------------------------------------
select coalesce(u.nom, p.nom, 'inconnu') as intervenant,
       count(*)::int as interventions_orphelines,
       min(i.date_intervention) as depuis,
       max(i.date_intervention) as jusqu_a
  from interventions i
  join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u  on u.id = i.technicien_id
  left join prestataires p  on p.id = i.prestataire_id
 where a.sharepoint_id is not null
   and i.tournee_id is null
 group by 1
 order by 2 desc;

-- ---------------------------------------------------------------------------
-- 2. Le détail des anomalies citées (dont 832), pour vérifier avant/après.
-- ---------------------------------------------------------------------------
select a.sharepoint_id, a.description, i.date_intervention, i.tournee_id,
       coalesce(u.nom, p.nom) as intervenant
  from interventions i
  join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u  on u.id = i.technicien_id
  left join prestataires p  on p.id = i.prestataire_id
 where a.sharepoint_id in (823, 824, 832, 839, 840);

-- ---------------------------------------------------------------------------
-- 3. Le correctif : rejouer la fonction. Elle ne touche que les
--    interventions reprises (sharepoint_id non nul), jamais une intervention
--    saisie dans l'application — sans risque pour le travail en cours.
-- ---------------------------------------------------------------------------
select * from fn_regrouper_les_passages();

-- ---------------------------------------------------------------------------
-- 4. Revérifier : ces anomalies doivent maintenant porter un tournee_id, et
--    la requête 1 rejouée devrait rendre 0 ligne (ou beaucoup moins) pour
--    Technicien Telec.
-- ---------------------------------------------------------------------------
select a.sharepoint_id, a.description, i.date_intervention, t.reference as tournee,
       coalesce(u.nom, p.nom) as intervenant
  from interventions i
  join anomalies a on a.id = i.anomalie_id
  left join tournees t on t.id = i.tournee_id
  left join utilisateurs u  on u.id = i.technicien_id
  left join prestataires p  on p.id = i.prestataire_id
 where a.sharepoint_id in (823, 824, 832, 839, 840);
