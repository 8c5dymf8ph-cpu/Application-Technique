#!/usr/bin/env python3
"""Analyse l'export de la liste « TEST Tech 3 » avant import.

Ne modifie rien : produit un état des lieux des valeurs réelles, des doublons de
libellés et des localisations à normaliser.
"""
import collections
import datetime
import re
import sys
import unicodedata

import openpyxl

CHEMIN = sys.argv[1] if len(sys.argv) > 1 else "donnees/export/test-tech-3.xlsx"


def sans_accent(t: str) -> str:
    return "".join(c for c in unicodedata.normalize("NFD", t)
                   if unicodedata.category(c) != "Mn")


def normaliser_libelle(t: str) -> str:
    """Clé de regroupement : minuscules, sans accent, espaces et ponctuation lissés."""
    t = sans_accent(str(t).lower())
    t = re.sub(r"[^a-z0-9]+", " ", t)
    return re.sub(r"\s+", " ", t).strip()


MOTS_VIDES = {
    "a", "au", "aux", "de", "des", "du", "en", "et", "il", "la", "le", "les", "ne",
    "on", "ou", "par", "pas", "pour", "que", "qui", "sur", "un", "une", "y", "dans",
    "ce", "cet", "cette", "est", "sont", "ete", "avec", "plus", "faire", "ya",
}


def mots_cles(libelle: str, maxi: int = 8) -> list[str]:
    """Mots significatifs, sans accent : c'est sur eux que porte la recherche."""
    vus, sortie = set(), []
    for mot in normaliser_libelle(libelle).split():
        if len(mot) >= 3 and mot not in MOTS_VIDES and mot not in vus:
            vus.add(mot)
            sortie.append(mot)
    return sortie[:maxi]


def charger(chemin):
    ws = openpyxl.load_workbook(chemin, read_only=True, data_only=True).worksheets[0]
    lignes = list(ws.iter_rows(values_only=True))
    entetes = [h.strip() if isinstance(h, str) else h for h in lignes[0]]
    return [dict(zip(entetes, r)) for r in lignes[1:] if any(v is not None for v in r)]


def lire_date(v):
    """Les dates de l'export sont à moitié de vraies dates, à moitié du texte."""
    if isinstance(v, datetime.datetime):
        return v.date()
    if isinstance(v, datetime.date):
        return v
    if not v:
        return None
    for fmt in ("%d/%m/%Y", "%Y-%m-%d", "%d-%m-%Y", "%d/%m/%y"):
        try:
            return datetime.datetime.strptime(str(v).strip(), fmt).date()
        except ValueError:
            continue
    return None


if __name__ == "__main__":
    data = charger(CHEMIN)
    print(f"{len(data)} lignes\n")

    # --- Libellés d'anomalie regroupés ------------------------------------
    groupes = collections.defaultdict(list)
    for d in data:
        if d.get("AnomaliesCommentaires"):
            groupes[normaliser_libelle(d["AnomaliesCommentaires"])].append(
                str(d["AnomaliesCommentaires"]).strip())
    print(f"Libellés : {sum(len(v) for v in groupes.values())} occurrences, "
          f"{len(groupes)} après regroupement casse/accents\n")
    print("Les 15 plus fréquents :")
    for cle, occ in sorted(groupes.items(), key=lambda x: -len(x[1]))[:15]:
        variantes = collections.Counter(occ)
        libelle = variantes.most_common(1)[0][0]
        suffixe = f"  [{len(variantes)} graphies]" if len(variantes) > 1 else ""
        print(f"  {len(occ):4d}×  {libelle[:70]}{suffixe}")

    uniques = sum(1 for v in groupes.values() if len(v) == 1)
    print(f"\n  dont {uniques} libellés vus une seule fois "
          f"({100*uniques//len(groupes)} %)")

    # --- Dates -------------------------------------------------------------
    print()
    aujourdhui = datetime.date.today()
    for col in ("Date", "FAIT_LE", "VERIFIE_LE"):
        vals = [lire_date(d[col]) for d in data if d.get(col)]
        ok = [v for v in vals if v]
        futur = [v for v in ok if v > aujourdhui]
        print(f"{col}: {len(ok)}/{len(vals)} interprétées"
              + (f" — ⚠ {len(futur)} dans le futur (max {max(futur)})" if futur else ""))

    # --- Localisations -----------------------------------------------------
    print()
    locs = collections.Counter(str(d["LOCALISATION"]).strip()
                               for d in data if d.get("LOCALISATION"))
    chambres = {l for l in locs if l.isdigit()}
    print(f"Localisations : {len(locs)} distinctes — "
          f"{len(chambres)} numériques, {len(locs)-len(chambres)} nommées")
    print(f"  numéros : {' '.join(sorted(chambres, key=int))}")
