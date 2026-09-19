-- -----------------------------------------------------------------------------
-- Repartir d'un schéma vide — pour que ce fichier se rejoue sans dégât.
-- -----------------------------------------------------------------------------
-- Une installation qui s'interrompt au milieu laisse des types et des tables
-- posés : rejouer le fichier butait alors sur « type ... already exists », sans
-- moyen d'avancer ni de revenir en arrière. Le bloc ci-dessous efface le schéma
-- avant de le reconstruire.
--
-- Il REFUSE de le faire si la base porte déjà des anomalies, des mouvements de
-- stock ou des dossiers de bouteille : à ce stade ce n'est plus une
-- installation, c'est la base de l'hôtel, et rien ne doit l'effacer. Le test et
-- l'effacement tiennent dans une seule instruction : l'un ne peut pas passer
-- sans l'autre.
do $$
declare
  t text;
  n bigint;
begin
  foreach t in array array['anomalies', 'mouvements_stock', 'incidents_bouteille'] loop
    if to_regclass('public.' || t) is not null then
      execute format('select count(*) from public.%I', t) into n;
      if n > 0 then
        raise exception 'La table % porte déjà % ligne(s) : ce fichier les effacerait.', t, n
          using hint = 'Installation déjà faite. Pour tout reprendre à zéro, effacer '
                    || 'le schéma public à la main, en connaissance de cause.';
      end if;
    end if;
  end loop;

  execute 'drop schema if exists public cascade';
  execute 'create schema public';

  -- Supabase accorde ces droits sur le schéma public d'un projet neuf ; les
  -- rétablir, sinon l'application perd l'accès à ses propres tables. Ces rôles
  -- n'existent pas sur une base PostgreSQL ordinaire : on passe alors son tour.
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

