#!/bin/sh
# Prépare les trois fichiers à jouer sur la base de production, dans l'ordre.
# À relancer après toute modification du schéma, des vues, de la sécurité ou
# des référentiels : les fichiers ne sont qu'une concaténation, jamais une
# source à éditer à la main.
set -e
cd "$(dirname "$0")/.."
sortie=donnees/installation
mkdir -p "$sortie"

{
  printf -- '-- Application Technique — Hôtel Parisianer\n'
  printf -- '-- Schéma, vues, règles, sécurité et référentiels.\n'
  printf -- '-- Fichier produit par outils/preparer_installation.sh — ne pas éditer.\n\n'
  for f in supabase/migrations/*.sql supabase/seed/*.sql; do
    printf -- '\n-- ===== %s =====\n' "$f"
    cat "$f"
  done
} > "$sortie/1-schema-et-referentiels.sql"

rm -f "$sortie"/2-anomalies-*.sql
cp donnees/import_anomalies.sql  "$sortie/2-anomalies.sql"
cp donnees/import_stock.sql      "$sortie/3-stock.sql"
cp donnees/import_bouteilles.sql "$sortie/4-bouteilles.sql"
python3 outils/equipe.py            > "$sortie/5-equipe.sql"

# Le fichier des anomalies dépasse ce que l'éditeur SQL du navigateur encaisse :
# il est aussi livré en morceaux collables, à jouer dans l'ordre des lettres.
python3 outils/decouper.py "$sortie/2-anomalies.sql" > /dev/null

wc -c "$sortie"/*.sql
