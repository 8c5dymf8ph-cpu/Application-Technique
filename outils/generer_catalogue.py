#!/usr/bin/env python3
"""Génère le catalogue d'anomalies à partir de l'export de « TEST Tech 3 ».

Les libellés sont regroupés sur une clé insensible à la casse, aux accents et à
la ponctuation ; la graphie retenue est la plus fréquente. Les mots-clés sont
dérivés du libellé, sans accent, pour que la recherche depuis le téléphone
fonctionne quel que soit ce que la gouvernante tape.

    python3 outils/generer_catalogue.py <export.xlsx> > supabase/seed/02_catalogue_anomalies.sql
"""
import collections
import sys

from analyse_source import charger, mots_cles, normaliser_libelle


def echapper(t: str) -> str:
    return t.replace("'", "''")


def main(chemin: str) -> None:
    data = charger(chemin)

    groupes: dict[str, list[str]] = collections.defaultdict(list)
    types: dict[str, collections.Counter] = collections.defaultdict(collections.Counter)
    for d in data:
        libelle = d.get("AnomaliesCommentaires")
        if not libelle:
            continue
        cle = normaliser_libelle(libelle)
        groupes[cle].append(str(libelle).strip())
        if d.get("TYPE"):
            types[cle][str(d["TYPE"]).strip()] += 1

    lignes = []
    for cle, occurrences in sorted(groupes.items(), key=lambda kv: (-len(kv[1]), kv[0])):
        # La graphie la plus fréquente fait foi
        libelle = collections.Counter(occurrences).most_common(1)[0][0]
        libelle = " ".join(libelle.split())
        type_code = types[cle].most_common(1)[0][0] if types[cle] else None
        mots = ", ".join(f"'{echapper(m)}'" for m in mots_cles(libelle))
        type_sql = f"'{echapper(type_code)}'" if type_code else "null"
        lignes.append(f"  ('{echapper(libelle)}', array[{mots}]::text[], "
                      f"{type_sql}, {len(occurrences)})")

    corps = ",\n".join(lignes)
    print(f"""-- =============================================================================
-- Catalogue d'anomalies — généré depuis l'export de « TEST Tech 3 »
--   {len(data)} lignes  ->  {len(groupes)} libellés distincts
--
-- Ne pas modifier à la main : régénérer avec
--   python3 outils/generer_catalogue.py <export.xlsx> > supabase/seed/02_catalogue_anomalies.sql
--
-- La gouvernante déclare en cherchant ici par mots-clés ; elle ne peut pas
-- saisir de texte libre. Ajouter une entrée est réservé à l'admin (voir RLS).
-- `occurrences` sert à trier les plus courantes en tête de liste.
-- =============================================================================

with source (libelle, mots_cles, type_code, occurrences) as (values
{corps}
)
insert into catalogue_anomalies (libelle, mots_cles, type_id, occurrences)
select s.libelle, s.mots_cles, t.id, s.occurrences
from source s
left join types_intervention t on t.code = s.type_code
where not exists (
  select 1 from catalogue_anomalies c where c.libelle = s.libelle
);""")


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "donnees/export/test-tech-3.xlsx")
