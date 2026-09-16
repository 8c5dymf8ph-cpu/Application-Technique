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

# Orthographes rencontrées pour une même personne, ramenées à une seule.
NOMS_CANONIQUES = {
    "mr negroni": "MR NEGRONI",
    "mrnegroni": "MR NEGRONI",
    "victoria": "Victoria",
    "miguel": "Miguel",
    "sarah p": "Sarah P",
    "farid": "FARID",
}

# Rôle dans l'application. Les personnes absentes de cette table sont créées
# comme techniciens ; celles classées prestataires ne s'y connectent pas.
ROLES = {
    "miguel": "admin",
    "victoria": "gouvernante",
    "sarah p": "operations",   # chargée des opérations
}

STATUTS = {
    "FAIT": "validee", "A FAIRE": "a_faire", "EN COURS": "en_cours",
    "ACHATS": "a_acheter",
}


def statut_final(d, doublon: bool) -> str:
    """Le statut tel qu'il doit être une fois la reprise terminée.

    « FAIT » veut dire fait, et rien d'autre. La colonne de vérification n'a
    été tenue qu'à partir de 2026 — vingt-trois lignes sur trois cent
    cinquante-trois en 2025 — et la traiter comme une étape obligatoire
    inventerait à la gouvernante un arriéré de plusieurs centaines
    d'anomalies à valider qui n'a jamais existé. Quand la vérification est
    renseignée, elle est reprise comme un vrai avis ; quand elle ne l'est pas,
    la ligne est close sans avis, et le récapitulatif le montrera.

    Le statut est calculé ici plutôt que laissé aux déclencheurs : pendant
    l'import, une ligne terminée passerait transitoirement par « en attente de
    validation », et deux lignes du même problème au même endroit se
    heurteraient alors à l'unicité."""
    if doublon:
        return "annulee"
    return STATUTS.get(str(d.get("STATUT") or "").strip(), "a_faire")

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


def qnom(t) -> str:
    """Comme q(), mais ramène le nom à son orthographe canonique."""
    if t is None or not str(t).strip():
        return "null"
    return q(NOMS_CANONIQUES.get(cle(t), str(t).strip()))


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


def ouverte_a_la_reprise(d) -> bool:
    """Une ligne encore ouverte une fois reprise : ce sont celles-là qui ne
    peuvent pas coexister deux fois au même endroit. Une ligne FAIT sans
    vérification reste ouverte — elle attend la gouvernante."""
    return str(d.get("STATUT") or "").strip() in ("A FAIRE", "EN COURS", "ACHATS", "")


def doublons_ouverts(data, canoniques, rapport) -> set[int]:
    """Identifiants des lignes à annuler : le même problème ouvert plusieurs
    fois au même endroit. On garde la plus récente, les autres n'ont pas eu lieu
    deux fois — elles ont été saisies deux fois."""
    groupes = collections.defaultdict(list)
    for d in data:
        sid, libelle = d.get("ID"), d.get("AnomaliesCommentaires")
        if sid is None or not libelle or not ouverte_a_la_reprise(d):
            continue
        cle_libelle = canoniques.get(normaliser_libelle(libelle))
        lieu = str(d.get("LOCALISATION") or "").strip()
        if not lieu or not cle_libelle:
            continue
        groupes[(lieu, cle_libelle)].append(
            (lire_date(d.get("Date")) or datetime.date.min, int(sid)))

    a_annuler = set()
    for (lieu, libelle), lignes in groupes.items():
        if len(lignes) > 1:
            lignes.sort(reverse=True)
            a_annuler.update(sid for _, sid in lignes[1:])
            rapport["doublons_annules"][f"{lieu} — {libelle[:44]}"] += len(lignes) - 1
    return a_annuler


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
    doublons = doublons_ouverts(data, canoniques, rapport)

    # --- Personnes ---------------------------------------------------------
    utilisateurs, prestataires = {}, {}
    for d in data:
        for col in ("Constate_Par", "SAISIE PAR", "PAR", "VERIFIE_PAR"):
            nom = str(d.get(col) or "").strip()
            if not nom:
                continue
            # La forme canonique d'abord : « Mr Negroni » et « MrNegroni »
            # donnaient deux clés différentes, donc deux personnes.
            nom = NOMS_CANONIQUES.get(cle(nom), nom)
            k = cle(nom)
            # Un intervenant extérieur n'est jamais créé comme utilisateur, quelle
            # que soit la colonne où son nom apparaît.
            if k in PRESTATAIRES:
                prestataires.setdefault(k, nom)
            else:
                utilisateurs.setdefault(k, nom)

    print("-- Généré par outils/importer_anomalies.py — ne pas modifier à la main.")
    print("-- Import de la liste « TEST Tech 3 » vers anomalies / tournees /")
    print("-- interventions / validations. Rejouable : rien n'est inséré deux fois.")
    print("\nbegin;\n")
    print("-- Le statut de chaque ligne est calculé par le script ; le déclencheur")
    print("-- qui le recalcule d'ordinaire est neutralisé le temps de la reprise.")
    print("alter table validations disable trigger tg_validation_maj_anomalie;\n")

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
        cible = ("technicien_id, (select id from utilisateurs where nom = %s)" % qnom(nom)
                 if cle(nom) not in PRESTATAIRES else
                 "prestataire_id, (select id from prestataires where nom = %s)" % qnom(nom))
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
        statut = statut_final(d, int(sid) in doublons)
        libelle = " ".join(str(libelle).split())
        # Le libellé reste celui saisi ; le rattachement au catalogue passe par
        # la graphie canonique du groupe.
        canonique = canoniques.get(normaliser_libelle(libelle), libelle)

        # Le commentaire de l'export est un vrai propos ; les notes de reprise
        # en sont des remarques techniques. Les deux vont au fil, distingués
        # par leur origine.
        fil: list[tuple[str, str]] = []
        if d.get("COMMENTAIRES") and str(d["COMMENTAIRES"]).strip():
            fil.append(("utilisateur", " ".join(str(d["COMMENTAIRES"]).split())))
        if int(sid) in doublons:
            fil.append(("reprise", "Annulée à la reprise : le même problème était déjà ouvert ici."))
        if code == "Parties communes" and cle(lieu_brut) != "parties communes":
            fil.append(("reprise", f"Localisation d'origine : {lieu_brut}"))

        # Une ligne close l'a été à la vérification si elle existe, sinon le jour
        # où le technicien l'a déclarée faite.
        cloture = (q(lire_date(d.get("VERIFIE_LE")) or lire_date(d.get("FAIT_LE")))
                   if statut == "validee" else "null")

        print(
            "insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id,"
            " description, statut, constate_par, saisie_par, declare_le,"
            " cloture_le) select "
            f"{int(sid)}, e.id, c.id, t.id, {q(libelle)},"
            f" '{statut}', u1.id, u2.id, timestamptz '{date}',"
            f" {cloture}\n"
            f"  from emplacements e"
            f"\n  left join catalogue_anomalies c on c.libelle = {q(canonique)}"
            f"\n  left join types_intervention t on t.code = {q(d.get('TYPE'))}"
            f"\n  left join utilisateurs u1 on u1.nom = {qnom(d.get('Constate_Par'))}"
            f"\n  left join utilisateurs u2 on u2.nom = {qnom(d.get('SAISIE PAR'))}"
            f"\n  where e.code = {q(code)} on conflict (sharepoint_id) do nothing;")
        for origine, texte in fil:
            auteur = (qnom(d.get("Constate_Par")) if origine == "utilisateur" else "null")
            print(
                "insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)"
                f"\n  select a.id, {q(texte)}, '{origine}', u.id, timestamptz '{date}'"
                f"\n  from anomalies a left join utilisateurs u on u.nom = {auteur}"
                f"\n  where a.sharepoint_id = {int(sid)}"
                f"\n    and not exists (select 1 from commentaires x"
                f" where x.anomalie_id = a.id and x.texte = {q(texte)});")

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
            f"\n  left join utilisateurs u on u.nom = {qnom('' if externe else par)}"
            f"\n  left join prestataires p on p.nom = {qnom(par if externe else '')}"
            f"\n  where a.sharepoint_id = {int(sid)}"
            f"\n    and not exists (select 1 from interventions i where i.anomalie_id = a.id);")

        if fait_le:
            print(
                "insert into validations (intervention_id, acteur, decision, utilisateur_id,"
                " decide_le) select i.id, 'technicien', 'fait', u.id,"
                f" timestamptz '{fait_le}'"
                f"\n  from interventions i join anomalies a on a.id = i.anomalie_id"
                f"\n  left join utilisateurs u on u.nom = {qnom('' if externe else par)}"
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
                f"\n  left join utilisateurs u on u.nom = {qnom(d.get('VERIFIE_PAR'))}"
                f"\n  where a.sharepoint_id = {int(sid)}"
                f"\n    and not exists (select 1 from validations v"
                f" where v.intervention_id = i.id and v.acteur = 'gouvernante');")

    print("\nalter table validations enable trigger tg_validation_maj_anomalie;")

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
