-- =============================================================================
-- Migration 0034 : la clôture ne rend que ce que le technicien a retouché
-- =============================================================================
-- « J'ai une anomalie de plus d'office. » Pour ajouter une seule déclaration
-- neuve à un passage déjà rendu, il faut d'abord « Reprendre le passage » —
-- c'est un geste sur TOUTE la tournée, il n'y a pas d'autre porte. Mais une
-- anomalie que la gouvernante avait mise « en cours » sur ce même passage, et
-- que le technicien n'a PAS retouchée cette fois, se retrouvait quand même
-- reproposée à la gouvernante à la clôture suivante — avec l'ancien avis,
-- l'ancien matériel, l'ancienne date, comme si elle venait d'être redéclarée.
--
-- `fn_cloture_tournee_maj_anomalies` (migration 0004) basculait `en_cours` en
-- `attente_validation` dès qu'UNE déclaration technicien existait un jour ou
-- l'autre pour cette intervention — jamais si elle datait d'avant le dernier
-- avis de la gouvernante. Exactement le défaut que la 0033 corrigeait déjà
-- côté lecture (`v_recap_interventions`), mais resté ici côté écriture : ce
-- n'est pas la vue qui mentait, c'est le statut lui-même qui changeait à
-- tort. Même principe, au même endroit où il manquait : un avis technicien
-- ne « rend » l'anomalie que s'il est POSTÉRIEUR au dernier avis de la
-- gouvernante — sinon rien n'a changé depuis qu'elle a dit « en cours », et
-- la lui remontrer n'apprend rien, ni combien d'anomalies il y a vraiment.
create or replace function fn_cloture_tournee_maj_anomalies() returns trigger
language plpgsql as $$
begin
  update anomalies a set statut = 'attente_validation', maj_le = now()
   from interventions i
  where i.tournee_id = new.id
    and i.anomalie_id = a.id
    and a.statut = 'en_cours'
    and exists (
      select 1 from validations v
       where v.intervention_id = i.id
         and v.acteur = 'technicien' and v.decision = 'fait'
         and v.decide_le >= coalesce(
           (select max(vg.decide_le) from validations vg
             where vg.intervention_id = i.id and vg.acteur = 'gouvernante'),
           v.decide_le));
  return new;
end;
$$;

comment on function fn_cloture_tournee_maj_anomalies() is
  'Bascule en attente_validation ce que le technicien a déclaré fait — seulement '
  'si ce « fait » est postérieur au dernier avis de la gouvernante. Reprendre le '
  'passage pour une autre anomalie ne doit pas representer, inchangée, celle '
  'qu''elle avait mise en cours et que personne n''a retouchée.';
