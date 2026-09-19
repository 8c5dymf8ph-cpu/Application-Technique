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
  printf -- '\n\nselect %s as "Fichier joué",\n' "'1-schema-et-referentiels.sql'"
  printf -- '       count(*) || %s as "Où ça en est"\n  from emplacements;\n' \
    "' emplacements — le schéma est en place'"
} > "$sortie/1-schema-et-referentiels.sql"

rm -f "$sortie"/2-anomalies-*.sql
cp donnees/import_anomalies.sql  "$sortie/2-anomalies.sql"
cp donnees/import_stock.sql      "$sortie/3-stock.sql"
cp donnees/import_bouteilles.sql "$sortie/4-bouteilles.sql"
python3 outils/equipe.py            > "$sortie/5-equipe.sql"

# Le fichier des anomalies dépasse ce que l'éditeur SQL du navigateur encaisse :
# il est aussi livré en morceaux collables, à jouer dans l'ordre des lettres.
python3 outils/decouper.py "$sortie/2-anomalies.sql" > /dev/null

# Chaque fichier se nomme dans son résultat : collé dans un éditeur qui a gardé
# le contenu précédent, on voit lequel a réellement tourné.
{
  printf -- '\n\nselect %s as "Fichier joué",\n' "'3-stock.sql'"
  printf -- '       count(*) || %s as "Où ça en est"\n  from produits;\n' \
    "' produits sur 36'"
} >> "$sortie/3-stock.sql"
{
  printf -- '\n\nselect %s as "Fichier joué",\n' "'4-bouteilles.sql'"
  printf -- '       count(*) || %s as "Où ça en est"\n  from incidents_bouteille;\n' \
    "' dossiers de bouteille sur 17'"
} >> "$sortie/4-bouteilles.sql"
{
  printf -- '\n\nselect %s as "Fichier joué",\n' "'5-equipe.sql'"
  printf -- '       case when exists (select 1 from prestataires where nom = %s)\n' "'ALAIN'"
  printf -- '            then %s else %s end as "Où ça en est";\n' \
    "'noms NON corrigés — le fichier n''a pas tourné'" \
    "'noms corrigés — installation terminée'"
} >> "$sortie/5-equipe.sql"

wc -c "$sortie"/*.sql
