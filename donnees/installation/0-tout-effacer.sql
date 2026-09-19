-- -----------------------------------------------------------------------------
-- Tout effacer, volontairement — pour repartir d'une base propre.
-- -----------------------------------------------------------------------------
-- 1-schema-et-referentiels.sql refuse de s'exécuter dès que la base porte des
-- données : c'est ce qui empêche un collage malheureux d'effacer l'hôtel. Ce
-- fichier-ci est la porte de sortie quand l'effacement est VOULU — une
-- installation à reprendre depuis le début, par exemple.
--
--            ┌──────────────────────────────────────────────┐
--            │  IL EFFACE TOUT, SANS RIEN DEMANDER.          │
--            │  Ne jamais le jouer sur la base de l'hôtel.   │
--            └──────────────────────────────────────────────┘
--
-- Après lui, reprendre à 1-schema-et-referentiels.sql.
do $$
declare
  t text;
begin
  execute 'drop schema if exists public cascade';
  execute 'create schema public';

  -- Rétablir les droits que Supabase pose sur le schéma public d'un projet
  -- neuf. Ces rôles n'existent pas sur une base PostgreSQL ordinaire.
  foreach t in array array['postgres', 'anon', 'authenticated', 'service_role'] loop
    if exists (select 1 from pg_roles where rolname = t) then
      execute format('grant usage on schema public to %I', t);
    end if;
  end loop;
  foreach t in array array['postgres', 'service_role'] loop
    if exists (select 1 from pg_roles where rolname = t) then
      execute format('grant create on schema public to %I', t);
    end if;
  end loop;
end $$;

select 'Base vidée. Reprendre à 1-schema-et-referentiels.sql.' as "C'est fait";
