#!/bin/sh
# Applique les migrations qui manquent, dans l'ordre, et note ce qui est joué.
#
# L'installation initiale pose le schéma d'un bloc. Ensuite, chaque évolution
# arrive comme un fichier de plus dans supabase/migrations/ : le rejouer sur une
# base déjà à jour ne doit rien casser, et ne pas le jouer laisserait
# l'application devant un schéma qu'elle ne reconnaît plus.
#
# Usage : PGURL="postgresql://…" ./outils/appliquer_migrations.sh
set -e
cd "$(dirname "$0")/.."
[ -n "$PGURL" ] || { echo "PGURL manquante." >&2; exit 1; }

psql "$PGURL" -v ON_ERROR_STOP=1 --quiet --no-psqlrc -c "
  create table if not exists migrations_appliquees (
    fichier  text primary key,
    jouee_le timestamptz not null default now()
  );"

# Une base installée avant l'existence de ce journal porte déjà le schéma
# initial : on l'inscrit sans le rejouer, sinon on tenterait de recréer des
# types qui existent.
psql "$PGURL" -v ON_ERROR_STOP=1 --quiet --no-psqlrc -c "
  insert into migrations_appliquees (fichier)
  select f from (values
      ('0001_schema_initial.sql'),
      ('0002_vues_et_regles.sql'),
      ('0003_securite.sql')) as v (f)
   where to_regclass('public.anomalies') is not null
  on conflict do nothing;"

for chemin in supabase/migrations/*.sql; do
  fichier=$(basename "$chemin")
  deja=$(psql "$PGURL" --quiet --no-psqlrc --no-align --tuples-only \
    -c "select 1 from migrations_appliquees where fichier = '$fichier'")
  if [ -n "$deja" ]; then
    echo "déjà jouée   $fichier"
    continue
  fi
  echo "::group::$fichier"
  psql "$PGURL" -v ON_ERROR_STOP=1 --quiet --no-psqlrc -f "$chemin"
  psql "$PGURL" -v ON_ERROR_STOP=1 --quiet --no-psqlrc \
    -c "insert into migrations_appliquees (fichier) values ('$fichier')"
  echo "::endgroup::"
  echo "appliquée    $fichier"
done
