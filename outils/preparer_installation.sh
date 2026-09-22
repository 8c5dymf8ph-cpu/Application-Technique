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

# Les passages, en DERNIER. Le regroupement est posé par la migration 0015,
# donc dans le premier fichier — mais il n'a rien à regrouper à ce moment-là :
# les interventions n'arrivent qu'au deuxième. Sur une base neuve, quatre cent
# vingt-deux interventions restaient donc sans passage, et l'historique n'en
# montrait qu'un vingtième. On rappelle la fonction une fois les données là.
#
# C'est aussi l'étape qui corrige l'orthographe des noms : 5-equipe.sql
# renomme « ALAIN » en « Alain », et une intervention dont l'intervenant vient
# d'être renommé doit rejoindre son passage.
cat > "$sortie/6-passages.sql" <<'SQL'
-- Un passage par intervenant et par jour, une fois les interventions en place.
-- Rejouable : un second passage ne recrée rien.
select * from fn_regrouper_les_passages();
SQL

# Les gros fichiers dépassent ce que l'éditeur SQL du navigateur encaisse : ils
# sont aussi livrés en morceaux collables, à jouer dans l'ordre des lettres.
python3 outils/decouper.py "$sortie/2-anomalies.sql" "$sortie/3-stock.sql" > /dev/null

# Chaque fichier inscrit son passage dans installation_journal et affiche son
# nom en résultat ; 0-ou-en-suis-je.sql se déduit de la liste ainsi produite.
python3 outils/finaliser_installation.py

wc -c "$sortie"/*.sql
