-- =============================================================================
-- Migration 0016 : ce qui attend vraiment la gouvernante
-- =============================================================================
-- L'écran « À valider » annonçait 343 anomalies. Or la base n'en porte AUCUNE
-- en attente de validation : 541 sont validées, 113 à faire, 10 en cours, 9 en
-- achat. Les 343 venaient d'ailleurs.
--
-- `v_tournees.nb_en_attente` comptait les interventions « sans avis de
-- gouvernante », sans regarder l'état de l'anomalie. Sur 345 interventions sans
-- cet avis, 344 portent une anomalie **déjà validée** : du travail fait et clos
-- dans l'ancienne application, où la colonne de vérification n'a été tenue
-- qu'à partir de 2026.
--
-- L'import l'avait bien vu. Son commentaire dit : « la traiter comme une étape
-- obligatoire inventerait à la gouvernante un arriéré de plusieurs centaines
-- d'anomalies à valider qui n'a jamais existé ». Il a donc clos ces lignes —
-- mais la vue qui nourrit son écran comptait autrement, et l'arriéré
-- réapparaissait par la fenêtre. Une règle appliquée à un endroit et pas à
-- l'autre ne vaut rien.
--
-- Ce qui attend la gouvernante, c'est ce que `tg_cloture_tournee` lui a remis :
-- une anomalie en `attente_validation`. Rien d'autre. Un rendu d'aujourd'hui y
-- passe ; deux ans d'historique clos, non.
--
-- La 0004 avait déjà posé l'autre moitié de la règle : **rien n'attend tant
-- que le lot n'est pas rendu**. Elle reste. Les deux conditions se cumulent,
-- elles ne se remplacent pas : un passage ouvert ne compte rien et n'est
-- jamais prêt, un passage rendu ne compte que ce qui lui a été remis.

create or replace view v_tournees as
select
  t.id,
  t.reference,
  t.date_tournee,
  coalesce(u.nom, p.nom)                   as intervenant,
  t.cloturee_le,
  t.reprise,
  t.mail_technicien_envoye_le,
  t.mail_recap_envoye_le,
  count(r.intervention_id)                                                  as nb_interventions,
  -- Ce que la gouvernante a réellement à décider : le lot lui a été rendu,
  -- l'anomalie lui a été remise, et elle ne s'est pas encore prononcée.
  case when t.cloturee_le is null then 0 else
    count(*) filter (where r.intervention_id is not null
                       and r.statut_anomalie = 'attente_validation'
                       and r.decision_gouvernante is null) end              as nb_en_attente,
  count(*) filter (where r.decision_gouvernante = 'validee')                as nb_validees,
  count(*) filter (where r.decision_gouvernante = 'a_refaire')              as nb_a_refaire,
  count(*) filter (where r.decision_gouvernante = 'en_cours')               as nb_en_cours,
  coalesce(sum(r.cout_total), 0)                                            as cout_total,
  bool_or(r.cout_incomplet)                                                 as cout_incomplet,
  t.cloturee_le is not null
    and count(r.intervention_id) > 0
    and count(*) filter (where r.intervention_id is not null
                           and r.statut_anomalie = 'attente_validation'
                           and r.decision_gouvernante is null) = 0          as prete_pour_recap
from tournees t
left join utilisateurs u  on u.id = t.technicien_id
left join prestataires p  on p.id = t.prestataire_id
left join v_recap_interventions r on r.tournee = t.reference
group by t.id, u.nom, p.nom;

comment on view v_tournees is
  'Un passage, ses interventions et leur avancement. `nb_en_attente` ne compte '
  'que ce qui attend VRAIMENT la gouvernante — un lot rendu, une anomalie '
  'remise en attente_validation — et non toute intervention dépourvue de son '
  'avis : l''historique repris en porte des centaines, closes dans l''ancienne '
  'application, que personne n''a jamais eu à valider.';
