-- =============================================================================
-- Migration 0031 : vérifier une fusion du catalogue, et pouvoir la défaire
-- =============================================================================
-- Deux manques dans la 0030, remontés en la mettant entre les mains de Miguel.
--
-- 1. « Comment je vérifie que le changement est bien pris en compte ? »
--    Un libellé se repère par sa phrase, qui peut ressembler à celle d'à
--    côté — c'est tout le problème qu'on fusionne. `catalogue_anomalies`
--    porte désormais un `reference` court et stable, comme
--    `anomalies.reference` : un numéro à noter avant de fusionner, et à
--    retrouver après — dans l'écran ou dans Supabase — pour être sûr que
--    c'est bien CE libellé-là qui a bougé.
--
-- 2. « Assure-toi qu'il soit possible de revenir en arrière. »
--    La 0030 écrit `description` et `type_id` par-dessus leur ancienne
--    valeur : une fois fusionnée, l'ancienne valeur n'existe plus nulle
--    part. Un geste réversible doit pouvoir se défaire jusqu'au bout
--    (règle 16octies) — pas seulement se comprendre après coup.
--
--    `fusions_catalogue` journalise CHAQUE fusion (qui, quand, le survivant,
--    ce qui a été fusionné dedans) ; `fusions_catalogue_anomalies` garde,
--    anomalie par anomalie, la valeur d'AVANT (catalogue_id, description,
--    type_id) — exactement ce qu'il faut pour la restaurer telle quelle.
--    `fn_fusionner_catalogue` écrit ce journal avant de déplacer quoi que ce
--    soit ; `fn_annuler_fusion_catalogue` le relit pour tout remettre en
--    place, et réactive les libellés retirés. Une fusion déjà annulée ne se
--    défait pas deux fois.
-- =============================================================================

alter table catalogue_anomalies
  add column if not exists reference bigint generated always as identity;

create unique index if not exists catalogue_anomalies_reference_idx
  on catalogue_anomalies (reference);

comment on column catalogue_anomalies.reference is
  'Numéro court et stable, pour vérifier à l''œil quel libellé a bougé lors '
  'd''une fusion — la phrase seule ne suffit pas à distinguer deux doublons.';

-- `fn_rechercher_catalogue` rend `setof catalogue_anomalies` : la forme de la
-- table a changé (nouvelle colonne `reference`), sa définition doit suivre.
create or replace function fn_rechercher_catalogue(p_terme text default null)
returns setof catalogue_anomalies
language sql stable as $$
  select c.id, c.libelle, c.mots_cles, c.type_id,
         (select count(*)::int from anomalies a where a.catalogue_id = c.id) as occurrences,
         c.actif, c.cree_par, c.cree_le, c.reference
    from catalogue_anomalies c
   where c.actif
     and (
       coalesce(btrim(p_terme), '') = ''
       or c.libelle ilike '%' || btrim(p_terme) || '%'
       or exists (
         select 1 from unnest(c.mots_cles) m
         where m ilike btrim(p_terme) || '%'
       )
     )
   order by (select count(*) from anomalies a where a.catalogue_id = c.id) desc, c.libelle;
$$;

create table if not exists fusions_catalogue (
  id                uuid primary key default gen_random_uuid(),
  survivant_id      uuid not null references catalogue_anomalies (id),
  survivant_libelle text not null,
  survivant_reference bigint not null,
  autres_ids        uuid[] not null,
  autres_libelles   text[] not null,
  autres_references bigint[] not null,
  nb_anomalies      int not null default 0,
  fusionne_par      uuid references utilisateurs (id),
  fusionne_le       timestamptz not null default now(),
  annulee_le        timestamptz,
  annulee_par       uuid references utilisateurs (id)
);
create index if not exists fusions_catalogue_date on fusions_catalogue (fusionne_le desc);

comment on table fusions_catalogue is
  'Journal des fusions de libellés du catalogue : ce qui a été fusionné dans '
  'quoi, par qui, et si ça a été défait.';

create table if not exists fusions_catalogue_anomalies (
  fusion_id            uuid not null references fusions_catalogue (id) on delete cascade,
  anomalie_id          uuid not null references anomalies (id) on delete cascade,
  ancien_catalogue_id  uuid not null,
  ancienne_description text not null,
  ancien_type_id       uuid,
  primary key (fusion_id, anomalie_id)
);

comment on table fusions_catalogue_anomalies is
  'Ce que portait CHAQUE anomalie avant une fusion — de quoi la restaurer '
  'exactement si la fusion est défaite.';

alter table fusions_catalogue enable row level security;
alter table fusions_catalogue_anomalies enable row level security;

drop policy if exists lecture_fusions_catalogue on fusions_catalogue;
create policy lecture_fusions_catalogue on fusions_catalogue
  for select to authenticated using (fn_est_connecte());
grant select on fusions_catalogue to authenticated;

drop policy if exists lecture_fusions_catalogue_anomalies on fusions_catalogue_anomalies;
create policy lecture_fusions_catalogue_anomalies on fusions_catalogue_anomalies
  for select to authenticated using (fn_est_connecte());
grant select on fusions_catalogue_anomalies to authenticated;

-- fn_fusionner_catalogue : même geste que la 0030, mais il commence par
-- écrire le journal — avant tout déplacement — et rend l'identifiant de la
-- fusion plutôt qu'un simple compte, pour que l'écran puisse proposer
-- « annuler » tout de suite. Le type de retour change (int -> uuid), et un
-- paramètre s'ajoute : la fonction doit être recréée, pas seulement
-- remplacée.
--
-- `p_par` plutôt que `fn_utilisateur_courant_id()` (qui lit `auth.uid()`) :
-- « l'hôtel partage un seul compte », dit `lib/profil.ts` — l'application se
-- connecte à la base avec UNE SEULE connexion directe, jamais au nom d'un
-- utilisateur Supabase authentifié, donc `auth.uid()` n'y vaut jamais rien.
-- Partout ailleurs, l'écriture porte le profil choisi dans le cookie,
-- explicitement — `fusionne_par` doit faire pareil, sous peine de rester
-- NULL pour toujours.
drop function if exists fn_fusionner_catalogue(uuid, uuid[]);
create function fn_fusionner_catalogue(p_survivant uuid, p_autres uuid[], p_par uuid default null)
returns uuid
language plpgsql as $$
declare
  v_libelle   text;
  v_reference bigint;
  v_type_id   uuid;
  v_fusion_id uuid;
  v_n         int;
begin
  if not fn_peut_enrichir_le_catalogue() then
    raise exception 'Fusionner le catalogue est réservé à ceux qui peuvent l''enrichir';
  end if;

  select libelle, reference, type_id into v_libelle, v_reference, v_type_id
    from catalogue_anomalies where id = p_survivant and actif;
  if v_libelle is null then
    raise exception 'Le libellé survivant est introuvable ou retiré';
  end if;

  insert into fusions_catalogue (
    survivant_id, survivant_libelle, survivant_reference,
    autres_ids, autres_libelles, autres_references, fusionne_par)
  select p_survivant, v_libelle, v_reference,
         p_autres,
         coalesce(array_agg(c.libelle order by c.reference), '{}'),
         coalesce(array_agg(c.reference order by c.reference), '{}'),
         p_par
    from catalogue_anomalies c where c.id = any(p_autres)
  returning id into v_fusion_id;

  -- La valeur d'AVANT, anomalie par anomalie — c'est elle qui rend la fusion
  -- réversible.
  insert into fusions_catalogue_anomalies
    (fusion_id, anomalie_id, ancien_catalogue_id, ancienne_description, ancien_type_id)
  select v_fusion_id, a.id, a.catalogue_id, a.description, a.type_id
    from anomalies a
   where a.catalogue_id = any(p_autres);
  get diagnostics v_n = row_count;

  update anomalies
     set catalogue_id = p_survivant,
         description   = v_libelle,
         -- Un métier déjà posé à la main reste : seul celui qui manque se
         -- comble avec celui du survivant.
         type_id        = coalesce(type_id, v_type_id),
         maj_le         = now()
   where catalogue_id = any(p_autres);

  update catalogue_anomalies set actif = false where id = any(p_autres);
  update fusions_catalogue set nb_anomalies = v_n where id = v_fusion_id;

  return v_fusion_id;
end;
$$;

comment on function fn_fusionner_catalogue(uuid, uuid[], uuid) is
  $$Fusionne p_autres dans p_survivant, journalise la fusion (p_par : qui l'a faite) dans fusions_catalogue/fusions_catalogue_anomalies (pour pouvoir la défaire), déplace les anomalies avec la description et (si absent) le type du survivant, et retire p_autres du catalogue sans les supprimer. Rend l''id de la fusion. Réservé à fn_peut_enrichir_le_catalogue().$$;

-- fn_annuler_fusion_catalogue : le miroir exact. Restaure anomalie par
-- anomalie ce que le journal a gardé, réactive les libellés retirés, et
-- marque la fusion comme défaite — jamais deux fois. Même raison pour
-- `p_par` que ci-dessus : `auth.uid()` ne vaut rien dans cette application.
create or replace function fn_annuler_fusion_catalogue(p_fusion_id uuid, p_par uuid default null)
returns int
language plpgsql as $$
declare
  v_n int;
begin
  if not fn_peut_enrichir_le_catalogue() then
    raise exception 'Annuler une fusion est réservé à ceux qui peuvent enrichir le catalogue';
  end if;

  if not exists (select 1 from fusions_catalogue where id = p_fusion_id) then
    raise exception 'Fusion introuvable';
  end if;
  if exists (select 1 from fusions_catalogue where id = p_fusion_id and annulee_le is not null) then
    raise exception 'Cette fusion a déjà été annulée';
  end if;

  with restaure as (
    update anomalies a
       set catalogue_id = j.ancien_catalogue_id,
           description   = j.ancienne_description,
           type_id        = j.ancien_type_id,
           maj_le         = now()
      from fusions_catalogue_anomalies j
     where j.fusion_id = p_fusion_id and a.id = j.anomalie_id
    returning 1
  )
  select count(*) into v_n from restaure;

  update catalogue_anomalies c
     set actif = true
    from fusions_catalogue fc
   where fc.id = p_fusion_id and c.id = any(fc.autres_ids);

  update fusions_catalogue
     set annulee_le = now(), annulee_par = p_par
   where id = p_fusion_id;

  return v_n;
end;
$$;

comment on function fn_annuler_fusion_catalogue(uuid, uuid) is
  $$Défait une fusion : restaure catalogue_id/description/type_id de chaque anomalie déplacée à leur valeur d''avant (fusions_catalogue_anomalies), réactive les libellés retirés, et marque la fusion annulée. Refuse de défaire deux fois la même fusion. Réservé à fn_peut_enrichir_le_catalogue().$$;
