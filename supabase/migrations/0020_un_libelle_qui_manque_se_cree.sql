-- =============================================================================
-- Migration 0020 : un libellé qui manque se crée — et rejoint le catalogue
-- =============================================================================
-- Le catalogue est fermé, et c'est ce qui donne son sens au comptage des
-- récurrences (règle 8) : sans libellés normalisés, « ce mitigeur a été repris
-- quatre fois » n'existe pas. Mais un catalogue fermé qu'on ne peut pas
-- enrichir depuis le terrain finit par mentir : on déclare « autre chose » à la
-- place, ou on ne déclare pas.
--
-- Deux changements, tous les deux dans la RLS — c'est là que la règle 9 veut
-- qu'elle soit, pas dans l'interface :
--
--   1. Sarah P (`operations`) peut enrichir le catalogue, comme Miguel. Ce sont
--      les deux qui suivent les dossiers et qui reprennent l'historique ; faire
--      attendre l'une parce que l'autre n'est pas là n'a pas de sens.
--   2. Un libellé créé REJOINT le catalogue. On ne crée pas une anomalie « hors
--      catalogue » : on ajoute le libellé qui manquait, puis on déclare avec.
--      C'est ce qui garde le comptage juste — la fois suivante, le même
--      problème portera le même mot.

create or replace function fn_peut_enrichir_le_catalogue() returns boolean
language sql stable as $$
  select fn_role_courant() in ('operations', 'admin');
$$;

comment on function fn_peut_enrichir_le_catalogue() is
  'Qui peut ajouter un libellé au catalogue fermé : Sarah P et Miguel. Le '
  'catalogue reste fermé pour tous les autres — c''est lui qui rend le '
  'comptage des récurrences possible.';

-- Le catalogue s'écrit, pour eux deux seulement.
drop policy if exists enrichir_le_catalogue on catalogue_anomalies;
create policy enrichir_le_catalogue on catalogue_anomalies
  for insert to authenticated
  with check (fn_peut_enrichir_le_catalogue());

drop policy if exists corriger_le_catalogue on catalogue_anomalies;
create policy corriger_le_catalogue on catalogue_anomalies
  for update to authenticated
  using (fn_peut_enrichir_le_catalogue())
  with check (fn_peut_enrichir_le_catalogue());

-- Une anomalie sans libellé de catalogue reste réservée aux mêmes : la règle
-- ne se déplace pas dans l'écran, elle s'élargit ici.
drop policy if exists creation_depuis_catalogue on anomalies;
create policy creation_depuis_catalogue on anomalies
  for insert to authenticated
  with check (
    fn_peut_ecrire()
    and (catalogue_id is not null or fn_peut_enrichir_le_catalogue()));
