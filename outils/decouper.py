#!/usr/bin/env python3
"""Découpe un fichier d'import en morceaux collables dans l'éditeur SQL du navigateur.

L'éditeur de Supabase s'étrangle au-delà de quelques centaines de kilo-octets :
un fichier d'un méga-octet ne se colle pas. Les instructions produites par les
scripts d'import sont rejouables et ordonnées, donc les couper en plusieurs
transactions ne change rien au résultat — à condition de couper entre deux
instructions, jamais au milieu d'une chaîne.
"""
import sys
from pathlib import Path

# L'éditeur SQL de Supabase refuse « Query is too large » au-delà d'environ
# 220 000 caractères — mesuré : 220 112 passe, 220 502 non. On reste loin
# dessous : la marge coûte quelques fichiers de plus, la frôler coûte un blocage.
TAILLE = 120_000


def instructions(texte):
    """Rend les instructions une à une, en coupant sur les « ; » qui comptent.

    Un « ; » dans un commentaire ou dans une chaîne ne termine rien : le
    prendre pour une fin d'instruction couperait une commande en deux.
    """
    debut, i, n, dans_chaine = 0, 0, len(texte), False
    while i < n:
        c = texte[i]
        if dans_chaine:
            if c == "'":
                dans_chaine = False           # '' rouvre au tour suivant
            i += 1
        elif c == "'":
            dans_chaine = True
            i += 1
        elif texte.startswith("--", i):
            saut = texte.find("\n", i)
            i = n if saut == -1 else saut + 1
        elif texte.startswith("/*", i):
            fin = texte.find("*/", i + 2)
            i = n if fin == -1 else fin + 2
        elif c == ";":
            morceau = texte[debut : i + 1].strip()
            if morceau:
                yield morceau
            debut = i + 1
            i += 1
        else:
            i += 1
    reste = texte[debut:].strip()
    if reste:
        yield reste


def code_seul(instruction: str) -> str:
    """L'instruction sans ses commentaires, pour la reconnaître."""
    utiles = [
        l.strip() for l in instruction.splitlines()
        if l.strip() and not l.strip().startswith("--")
    ]
    return " ".join(utiles).lower()


def decouper(source: Path):
    texte = source.read_text(encoding="utf-8")
    entete = [l for l in texte.splitlines() if l.startswith("--")][:3]

    # Un fichier à corps dollar-quotés ($$) ne se découpe pas ainsi : le
    # tokeniseur ne les connaît pas et couperait au milieu d'une fonction.
    if "$$" in texte:
        raise SystemExit(f"{source} contient des corps $$ : découpage refusé.")

    # L'enveloppe de transaction est refaite autour de chaque morceau ; le
    # déclencheur de validation se neutralise et se rétablit dans chacun. Les
    # blocs de commentaires seuls ne servent plus une fois isolés.
    corps = [
        s
        for s in instructions(texte)
        if code_seul(s) not in ("", "begin;", "commit;")
        and "trigger tg_validation_maj_anomalie" not in s
    ]
    garde = "trigger tg_validation_maj_anomalie" in texte

    parts, courant, poids = [], [], 0
    for s in corps:
        if courant and poids + len(s) > TAILLE:
            parts.append(courant)
            courant, poids = [], 0
        courant.append(s)
        poids += len(s) + 1
    if courant:
        parts.append(courant)

    lettres = "abcdefghijklmnopqrstuvwxyz"
    ecrits = []
    for n, part in enumerate(parts):
        nom = source.with_name(f"{source.stem}-{lettres[n]}{source.suffix}")
        lignes = list(entete)
        lignes.append(
            f"-- Morceau {n + 1} sur {len(parts)} — à jouer dans l'ordre des lettres."
        )
        lignes.append("")
        lignes.append("begin;")
        if garde:
            lignes.append(
                "alter table validations disable trigger tg_validation_maj_anomalie;"
            )
        lignes.append("")
        lignes.extend(part)
        lignes.append("")
        if garde:
            lignes.append(
                "alter table validations enable trigger tg_validation_maj_anomalie;"
            )
        lignes.append("commit;")
        nom.write_text("\n".join(lignes) + "\n", encoding="utf-8")
        ecrits.append(nom)
    return ecrits


if __name__ == "__main__":
    for arg in sys.argv[1:]:
        for f in decouper(Path(arg)):
            print(f"{f}  {f.stat().st_size} octets")
