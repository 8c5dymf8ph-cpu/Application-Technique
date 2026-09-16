#!/usr/bin/env python3
"""Génère le SQL d'import de la liste « TEST Tech 3 » vers le nouveau modèle.

    python3 outils/importer_anomalies.py <export.xlsx> > donnees/import_anomalies.sql

Le script n'écrit rien en base : il produit du SQL à relire, et un rapport sur
stderr listant tout ce qu'il n'a pas su rattacher. Aucune ligne n'est perdue en
silence.
"""
import collections
import datetime
import re
import sys
import unicodedata

from analyse_source import charger, lire_date, normaliser_libelle
from referentiel_lieux import CHAMBRES_DE_TEST, EMPLACEMENTS, SYNONYMES

# Intervenants extérieurs : ils facturent une journée, ils ne se connectent pas.
# Tout autre nom devient un utilisateur. À corriger ici si le classement est faux.
PRESTATAIRES = {
    "ecoflair", "technicien avir", "technicien kone", "technicien telec",
    "technicien euprohr", "technicien europroh", "mr negroni", "mrnegroni",
    "alain", "hedi", "juan", "serafino",
}

# Rôle dans l'application. Les personnes absentes de cette table sont créées
# comme techniciens ; celles classées prestataires ne s'y connectent pas.
ROLES = {
    "miguel": "admin",
    "victoria": "gouvernante",
    "sarah p": "gouvernante",
}

STATUTS = {
    "FAIT": "validee", "A FAIRE": "a_faire", "EN COURS": "en_cours",
    "ACHATS": "a_acheter",
}

# Avant 2025, le suivi était tenu hors application et beaucoup de lignes
# déclarées faites n'ont jamais été vérifiées. On ne les reprend pas : l'export
# reste l'archive.
DEPUIS = datetime.date(2025, 1, 1)

# Spécialités connues : la section d'ALAIN ne doit montrer que l'électrique.
SPECIALITES = {"alain": ["ELECTRIQUE"]}


def cle(t) -> str:
    t = "".join(c for c in unicodedata.normalize("NFD", str(t).lower())
                if unicodedata.category(c) != "Mn")
    return re.sub(r"\s+", " ", t).strip()


def q(t) -> str:
    """Littéral SQL, ou NULL."""
    if t is None or (isinstance(t, str) and not t.strip()):
        return "null"
    return "'" + str(t).strip().replace("'", "''") + "'"


def code_emplacement(brut, rapport) -> str | None:
    """Rend le code du référentiel, ou None si la ligne ne doit pas être reprise.
    Un lieu non résolu bascule sur « Parties communes » : on préfère une anomalie
    mal localisée à une anomalie perdue, et l'original part en commentaire."""
    if not brut:
        return None
    brut = str(brut).strip()
    if brut.isdigit():
        if brut in CHAMBRES_DE_TEST:
            rapport["lignes_de_test"][brut] += 1
            return None
        code = f"{int(brut):02d}"
        if code in EMPLACEMENTS:
            return code
        rapport["chambres_hors_plan"][brut] += 1
        return "Parties communes"
    code = SYNONYMES.get(cle(brut))
    if not code:
        rapport["lieux_non_reconnus"][brut] += 1
        return "Parties communes"
    return code


def libelles_canoniques(data) -> dict[str, str]:
    """Même regroupement que generer_catalogue.py : chaque graphie pointe vers la
    graphie retenue au catalogue, sinon le rattachement échouerait sur un accent."""
    groupes = collections.defaultdict(list)
    for d in data:
        if d.get("AnomaliesCommentaires"):
            groupes[normaliser_libelle(d["AnomaliesCommentaires"])].append(
                " ".join(str(d["AnomaliesCommentaires"]).split()))
    return {k: collections.Counter(v).most_common(1)[0][0] for k, v in groupes.items()}


def main(chemin: str) -> None:
    data = charger(chemin)
    rapport = collections.defaultdict(collections.Counter)
    aujourdhui = datetime.date.today()
    canoniques = libelles_canoniques(data)

    # --- Personnes ---------------------------------------------------------
    utilisateurs, prestataires = {}, {}
    for d in data:
        for col in ("Constate_Par", "SAISIE PAR", "PAR", "VERIFIE_PAR"):
            nom = str(d.get(col) or "").strip()
            if not nom:
                continue
            if col == "PAR" and cle(nom) in PRESTATAIRES:
                prestataires.setdefault(cle(nom), nom)
            else:
                utilisateurs.setdefault(cle(nom), nom)

    print("-- Généré par outils/importer_anomalies.py — ne pas modifier à la main.")
    print("-- Import de la liste « TEST Tech 3 » vers anomalies / tournees /")
    print("-- interventions / validations. Rejouable : rien n'est inséré deux fois.")
    print("\nbegin;\n")

    print("-- Personnes rencontrées dans l'export ---------------------------------")
    for nom in sorted(utilisateurs.values()):
        role = ROLES.get(cle(nom), "technicien")
        print(f"insert into utilisateurs (nom, role) values ({q(nom)}, '{role}') "
              f"on conflict do nothing;")
    for nom in sorted(prestataires.values()):
        print(f"insert into prestataires (nom) values ({q(nom)}) on conflict do nothing;")

    print("\n-- Spécialités : une section qui ne montre que son métier -------------")
    for nom in sorted(list(utilisateurs.values()) + list(prestataires.values())):
        for type_code in SPECIALITES.get(cle(nom), []):
            print(
                "insert into specialites_intervenant (utilisateur_id, prestataire_id,"
                " type_intervention_id)\n  select u.id, p.id, t.id from types_intervention t"
                f"\n  left join utilisateurs u  on u.nom = {q(nom)}"
                f"\n  left join prestataires p  on p.nom = {q(nom)}"
                f"\n  where t.code = {q(type_code)}"
                "\n    and num_nonnulls(u.id, p.id) = 1 on conflict do nothing;")

    # --- Tournées ----------------------------------------------------------
    tournees = {}
    for d in data:
        ref = str(d.get("InterventionID") or "").strip()
        if ref and ref not in tournees:
            tournees[ref] = d
    print("\n-- Tournées (InterventionID d'origine) ---------------------------------")
    for ref, d in sorted(tournees.items()):
        nom = str(d.get("PAR") or "").strip()
        date = lire_date(d.get("FAIT_LE")) or lire_date(d.get("Date")) or aujourdhui
        cible = ("technicien_id, (select id from utilisateurs where nom = %s)" % q(nom)
                 if cle(nom) not in PRESTATAIRES else
                 "prestataire_id, (select id from prestataires where nom = %s)" % q(nom))
        colonne, valeur = cible.split(", ", 1)
        print(f"insert into tournees (reference, date_tournee, {colonne}) "
              f"values ({q(ref)}, date '{date}', {valeur}) on conflict (reference) do nothing;")

    # --- Anomalies ---------------------------------------------------------
    print("\n-- Anomalies -----------------------------------------------------------")
    retenues = 0
    for d in data:
        sid = d.get("ID")
        libelle = d.get("AnomaliesCommentaires")
        if sid is None or not libelle:
            rapport["ignorees"]["sans identifiant ou sans libellé"] += 1
            continue
        date = lire_date(d.get("Date"))
        if date and date < DEPUIS:
            rapport["archivees"][f"antérieures au {DEPUIS:%d/%m/%Y}"] += 1
            continue

        lieu_brut = str(d.get("LOCALISATION") or "").strip()
        code = code_emplacement(lieu_brut, rapport)
        if not code:
            rapport["ignorees"]["sans localisation"] += 1
            continue

        date = date or aujourdhui
        if date > aujourdhui:
            rapport["dates_futures"][str(date)] += 1
        statut = STATUTS.get(str(d.get("STATUT") or "").strip(), "a_faire")
        libelle = " ".join(str(libelle).split())
        # Le libellé reste celui saisi ; le rattachement au catalogue passe par
        # la graphie canonique du groupe.
        canonique = canoniques.get(normaliser_libelle(libelle), libelle)

        commentaire = d.get("COMMENTAIRES")
        if code == "Parties communes" and cle(lieu_brut) != "parties communes":
            note = f"Localisation d'origine : {lieu_brut}"
            commentaire = f"{commentaire}\n{note}" if commentaire else note

        print(
            "insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id,"
            " description, commentaire, statut, constate_par, saisie_par, declare_le) select "
            f"{int(sid)}, e.id, c.id, t.id, {q(libelle)}, {q(commentaire)},"
            f" '{statut}', u1.id, u2.id, timestamptz '{date}'\n"
            f"  from emplacements e"
            f"\n  left join catalogue_anomalies c on c.libelle = {q(canonique)}"
            f"\n  left join types_intervention t on t.code = {q(d.get('TYPE'))}"
            f"\n  left join utilisateurs u1 on u1.nom = {q(d.get('Constate_Par'))}"
            f"\n  left join utilisateurs u2 on u2.nom = {q(d.get('SAISIE PAR'))}"
            f"\n  where e.code = {q(code)} on conflict (sharepoint_id) do nothing;")
        retenues += 1

        # --- Intervention + avis du technicien -----------------------------
        fait_le, par = lire_date(d.get("FAIT_LE")), str(d.get("PAR") or "").strip()
        if not (fait_le or par):
            continue
        ref = str(d.get("InterventionID") or "").strip()
        externe = cle(par) in PRESTATAIRES
        print(
            "insert into interventions (anomalie_id, tournee_id, technicien_id,"
            " prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id,"
            f" date '{fait_le or date}', timestamptz '{fait_le or date}'"
            f"\n  from anomalies a"
            f"\n  left join tournees t on t.reference = {q(ref)}"
            f"\n  left join utilisateurs u on u.nom = {q('' if externe else par)}"
            f"\n  left join prestataires p on p.nom = {q(par if externe else '')}"
            f"\n  where a.sharepoint_id = {int(sid)}"
            f"\n    and not exists (select 1 from interventions i where i.anomalie_id = a.id);")

        if fait_le:
            print(
                "insert into validations (intervention_id, acteur, decision, utilisateur_id,"
                " decide_le) select i.id, 'technicien', 'fait', u.id,"
                f" timestamptz '{fait_le}'"
                f"\n  from interventions i join anomalies a on a.id = i.anomalie_id"
                f"\n  left join utilisateurs u on u.nom = {q('' if externe else par)}"
                f"\n  where a.sharepoint_id = {int(sid)}"
                f"\n    and not exists (select 1 from validations v"
                f" where v.intervention_id = i.id and v.acteur = 'technicien');")

        # --- Avis de la gouvernante ----------------------------------------
        verifie_le = lire_date(d.get("VERIFIE_LE"))
        if verifie_le:
            print(
                "insert into validations (intervention_id, acteur, decision, utilisateur_id,"
                " decide_le) select i.id, 'gouvernante', 'validee', u.id,"
                f" timestamptz '{verifie_le}'"
                f"\n  from interventions i join anomalies a on a.id = i.anomalie_id"
                f"\n  left join utilisateurs u on u.nom = {q(d.get('VERIFIE_PAR'))}"
                f"\n  where a.sharepoint_id = {int(sid)}"
                f"\n    and not exists (select 1 from validations v"
                f" where v.intervention_id = i.id and v.acteur = 'gouvernante');")

    # Les déclencheurs ont recalculé le statut à partir des validations ;
    # on rétablit celui de la source là où elle fait foi.
    print("\n-- Statuts d'origine (la source fait foi sur les lignes non terminées) --")
    for source, cible in STATUTS.items():
        if cible == "validee":
            continue
        ids = [int(d["ID"]) for d in data
               if d.get("ID") is not None
               and str(d.get("STATUT") or "").strip() == source]
        if ids:
            print(f"update anomalies set statut = '{cible}' where sharepoint_id in "
                  f"({', '.join(map(str, ids))});")

    print("\ncommit;")

    # --- Rapport -----------------------------------------------------------
    e = sys.stderr
    print(f"\n{retenues} anomalies retenues sur {len(data)} lignes", file=e)
    print(f"{len(utilisateurs)} utilisateurs, {len(prestataires)} prestataires, "
          f"{len(tournees)} tournées", file=e)
    for titre, compteur in rapport.items():
        if compteur:
            print(f"\n⚠ {titre.replace('_', ' ')} :", file=e)
            for k, n in compteur.most_common():
                print(f"    {n:4d}  {k}", file=e)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "donnees/export/test-tech-3.xlsx")
