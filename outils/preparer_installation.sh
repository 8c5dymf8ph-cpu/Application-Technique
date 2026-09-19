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
  cat outils/preambule_schema.sql
  for f in supabase/migrations/*.sql supabase/seed/*.sql; do
    printf -- '\n-- ===== %s =====\n' "$f"
    cat "$f"
  done
} > "$sortie/1-schema-et-referentiels.sql"

rm -f "$sortie"/2-anomalies-*.sql "$sortie"/3-stock-*.sql
cp donnees/import_anomalies.sql  "$sortie/2-anomalies.sql"
cp donnees/import_stock.sql      "$sortie/3-stock.sql"
cp donnees/import_bouteilles.sql "$sortie/4-bouteilles.sql"
python3 outils/equipe.py            > "$sortie/5-equipe.sql"

# Les gros fichiers dépassent ce que l'éditeur SQL du navigateur encaisse : ils
# sont aussi livrés en morceaux collables, à jouer dans l'ordre des lettres.
python3 outils/decouper.py "$sortie/2-anomalies.sql" "$sortie/3-stock.sql" > /dev/null

# Chaque fichier inscrit son passage dans installation_journal et affiche son
# nom en résultat ; 0-ou-en-suis-je.sql se déduit de la liste ainsi produite.
python3 outils/finaliser_installation.py

wc -c "$sortie"/*.sql
