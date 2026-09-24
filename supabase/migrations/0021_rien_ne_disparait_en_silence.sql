-- =============================================================================
-- Migration 0021 : une anomalie supprimée laisse une trace
-- =============================================================================
-- « Sans faire exprès j'ai supprimé une ancienne anomalie, mais je ne sais
-- plus laquelle. »
--
-- Le geste était d'un seul appui, au bout d'une ligne d'historique, sans
-- confirmation — et il emporte tout : le fil, les photos, les interventions.
-- Après quoi la base ne sait même plus qu'il y avait quelque chose là. On ne
-- peut ni le retrouver, ni dire ce qu'on a perdu, ni le remettre.
--
-- Supprimer reste possible : une anomalie déclarée deux fois ou dans la
-- mauvaise chambre n'a pas à rester (règle de `fn_peut_supprimer`). Mais un
-- effacement qui ne laisse RIEN n'est pas une suppression, c'est un trou.
--
-- Le déclencheur copie donc la ligne avant qu'elle parte, avec ce qu'elle
-- portait — son lieu, son libellé, qui l'avait constatée, combien de photos,
-- de commentaires et d'interventions s'en vont avec elle. C'est assez pour
-- dire « voilà ce qui a disparu » et pour la redéclarer telle quelle.

create table if not exists anomalies_supprimees (
  id                 uuid primary key,
  sharepoint_id      bigint,
  emplacement        text,
  emplacement_id     uuid,
  description        text,
  statut             text,
  priorite           text,
  declare_le         timestamptz,
  constate_par       text,
  -- Ce que la suppression a emporté : on ne le reconstituera pas, mais on
  -- doit pouvoir dire ce que ça valait.
  nb_photos          int not null default 0,
  nb_commentaires    int not null default 0,
  nb_interventions   int not null default 0,
  supprimee_le       timestamptz not null default now(),
  supprimee_par      uuid references utilisateurs (id)
);

create index if not exists anomalies_supprimees_date
  on anomalies_supprimees (supprimee_le desc);

comment on table anomalies_supprimees is
  'Ce qui a été supprimé, et quand. Un effacement qui ne laisse rien n''est '
  'pas une suppression, c''est un trou : on ne peut ni dire ce qu''on a '
  'perdu, ni le remettre.';

create or replace function fn_journal_suppression_anomalie() returns trigger
language plpgsql as $$
begin
  insert into anomalies_supprimees (
    id, sharepoint_id, emplacement, emplacement_id, description, statut,
    priorite, declare_le, constate_par, nb_photos, nb_commentaires,
    nb_interventions, supprimee_par)
  select
    old.id, old.sharepoint_id, e.code, old.emplacement_id, old.description,
    old.statut::text, old.priorite::text, old.declare_le, u.nom,
    (select count(*) from photos_anomalie p where p.anomalie_id = old.id),
    (select count(*) from commentaires c where c.anomalie_id = old.id),
    (select count(*) from interventions i where i.anomalie_id = old.id),
    -- Qui a appuyé : `auth.uid()` le dit quand la RLS est en place. Depuis
    -- l'application, c'est toujours quelqu'un de connecté.
    (select x.id from utilisateurs x where x.auth_id = auth.uid())
  from (select 1) z
  left join emplacements e  on e.id = old.emplacement_id
  left join utilisateurs u  on u.id = old.constate_par
  on conflict (id) do nothing;
  return old;
end;
$$;

drop trigger if exists tg_journal_suppression_anomalie on anomalies;
create trigger tg_journal_suppression_anomalie
before delete on anomalies
for each row execute function fn_journal_suppression_anomalie();

-- Le journal se lit, il ne s'écrit pas à la main.
alter table anomalies_supprimees enable row level security;
drop policy if exists lecture_suppressions on anomalies_supprimees;
create policy lecture_suppressions on anomalies_supprimees
  for select to authenticated using (fn_est_connecte());
grant select on anomalies_supprimees to authenticated;
