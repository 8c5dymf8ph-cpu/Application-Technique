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

TAILLE = 220_000  # octets par morceau, en deçà de ce que le navigateur encaisse


def instructions(texte):
    """Rend les instructions une à une, en coupant sur les « ; » hors chaîne."""
    debut, dans_chaine = 0, False
    for i, c in enumerate(texte):
        if c == "'":
            dans_chaine = not dans_chaine
        elif c == ";" and not dans_chaine:
            morceau = texte[debut : i + 1].strip()
            if morceau:
                yield morceau
            debut = i + 1
    reste = texte[debut:].strip()
    if reste:
        yield reste


def decouper(source: Path):
    texte = source.read_text(encoding="utf-8")
    entete = [l for l in texte.splitlines() if l.startswith("--")][:3]

    # L'enveloppe de transaction est refaite autour de chaque morceau ; le
    # déclencheur de validation se neutralise et se rétablit dans chacun.
    corps = [
        s
        for s in instructions(texte)
        if s not in ("begin;", "commit;")
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
        # Chaque fichier se nomme dans son résultat. Collé dans un éditeur qui
        # a gardé le contenu précédent, on voit tout de suite lequel a tourné.
        lignes.append("")
        lignes.append(
            f"select '{nom.name}' as \"Fichier joué\","
        )
        lignes.append(
            "       count(*) || ' anomalies sur 670' as \"Où ça en est\""
        )
        lignes.append("  from anomalies;")
        nom.write_text("\n".join(lignes) + "\n", encoding="utf-8")
        ecrits.append(nom)
    return ecrits


if __name__ == "__main__":
    for arg in sys.argv[1:]:
        for f in decouper(Path(arg)):
            print(f"{f}  {f.stat().st_size} octets")
