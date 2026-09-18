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

cp donnees/import_anomalies.sql "$sortie/2-anomalies.sql"
cp donnees/import_stock.sql     "$sortie/3-stock.sql"

wc -c "$sortie"/*.sql
