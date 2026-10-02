-- =============================================================================
-- Migration 0033 : une reprise après refus se termine, jusqu'au mail
-- =============================================================================
-- « Je n'ai pas reçu le mail de validation, et le passage n'apparaît pas, alors
-- que l'anomalie a fait la boucle entière. » Deux défauts, le même symptôme.
--
-- 1. `app/technique/anomalie/[id]/page.tsx` ne déclarait qu'UNE fois par
--    (anomalie, tournée) : un refus suivi d'une reprise LE MÊME JOUR retrouvait
--    l'intervention déjà posée par le premier passage, l'insertion n'avait
--    jamais lieu, et la reprise ne se produisait JAMAIS — ni nouvel avis, ni
--    nouvelle photo, en silence. Corrigé côté code : l'intervention existante
--    est réutilisée quand l'anomalie est revenue `a_faire`, et un nouvel avis
--    technicien s'y ajoute.
--
-- 2. Une fois ce premier défaut corrigé, un second apparaît ici : `vg`, dans
--    `v_recap_interventions`, retient le DERNIER avis de gouvernante jamais
--    posé sur l'intervention — y compris le refus d'avant la reprise. Tant que
--    la gouvernante n'a pas redécidé, `decision_gouvernante` reste donc « à
--    refaire », `v_tournees.nb_en_attente` ne la recompte jamais (son test est
--    `decision_gouvernante is null`), et `/gouvernante/valider` montre la carte
--    « déjà décidé » au lieu des trois boutons — avec le commentaire PÉRIMÉ.
--    Rien ne dit à la gouvernante qu'il y a un nouvel avis technicien à lire.
--
-- Un avis de gouvernante ne compte que s'il est POSTÉRIEUR au dernier avis du
-- technicien : c'est le même principe que la 10septies pour la clôture d'un
-- passage, appliqué à chaque anomalie. Rejoue entièrement la vue, telle que
-- posée par la 0002 — rien d'autre n'y change.
create or replace view v_recap_interventions as
select
  i.id                        as intervention_id,
  t.reference                 as tournee,
  a.id                        as anomalie_id,
  a.reference                 as anomalie_reference,
  e.code                      as emplacement,
  et.nom                      as etage,
  ti.nom                      as type_intervention,
  a.description,
  a.statut                    as statut_anomalie,
  uc.nom                      as constate_par,
  us.nom                      as saisie_par,
  i.date_intervention,
  coalesce(ut.nom, pr.nom)    as intervenant,
  pr.nom                      as prestataire,
  vt.decision                 as decision_technicien,
  vt.decide_le                as declare_fait_le,
  vt.commentaire              as commentaire_technicien,
  ug.nom                      as gouvernante,
  vg.decision                 as decision_gouvernante,
  vg.decide_le                as decide_gouvernante_le,
  vg.commentaire              as commentaire_gouvernante,
  -- Ce drapeau est ce qui doit apparaître en clair dans le récapitulatif envoyé :
  -- le technicien a déclaré l'anomalie faite, la gouvernante ne l'a pas validée.
  (vt.decision = 'fait' and vg.decision is distinct from 'validee'
     and vg.decision is not null)         as non_validee_par_gouvernante,
  (vt.decision = 'fait' and vg.decision is null) as en_attente_gouvernante,
  c.cout_materiel,
  c.articles_sans_prix,
  c.cout_prestataire,
  c.cout_divers,
  c.cout_total,
  c.cout_incomplet,
  i.cree_le
from interventions i
join anomalies a           on a.id = i.anomalie_id
join emplacements e        on e.id = a.emplacement_id
join etages et             on et.id = e.etage_id
left join tournees t       on t.id = i.tournee_id
left join types_intervention ti on ti.id = a.type_id
left join utilisateurs uc  on uc.id = a.constate_par
left join utilisateurs us  on us.id = a.saisie_par
left join utilisateurs ut  on ut.id = i.technicien_id
left join prestataires pr  on pr.id = i.prestataire_id
left join v_interventions_cout c on c.intervention_id = i.id
left join lateral (
  select * from validations v
  where v.intervention_id = i.id and v.acteur = 'technicien'
  order by v.decide_le desc limit 1
) vt on true
left join lateral (
  select * from validations v
  where v.intervention_id = i.id and v.acteur = 'gouvernante'
    -- Un avis antérieur au dernier « fait » du technicien répond à une
    -- déclaration qui n'est plus celle d'aujourd'hui : une reprise après
    -- refus en a produit une nouvelle, que la gouvernante n'a pas encore vue.
    -- Seul un avis posté APRÈS cette déclaration-là compte ; `vt` absent (cas
    -- théorique, aucun avis technicien) neutralise la condition.
    and v.decide_le >= coalesce(vt.decide_le, v.decide_le)
  order by v.decide_le desc limit 1
) vg on true
left join utilisateurs ug on ug.id = vg.utilisateur_id;

comment on view v_recap_interventions is
  'Un avis de gouvernante ne compte que posté après le dernier « fait » du '
  'technicien : une reprise après refus efface l''ancien avis de ce récapitulatif, '
  'sans y toucher dans validations (rien ne s''efface, tout s''ajoute).';
