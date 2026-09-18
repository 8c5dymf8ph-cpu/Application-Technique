#!/usr/bin/env python3
"""Génère le SQL d'import des bouteilles Purezza depuis l'export de l'ancienne app.

    python3 outils/importer_bouteilles.py donnees/export/Bouteilles_Purezza.xlsx \
        > donnees/import_bouteilles.sql

Le script n'écrit rien en base : il produit du SQL à relire, et un rapport sur
stderr. Aucune ligne n'est perdue en silence.

Deux pièges de l'export, traités ici :

1. **Les dates sont ambiguës.** Excel a interprété certaines cellules au format
   américain : `01/07/2026` est devenu le 7 janvier. La référence du dossier,
   elle, porte la date en clair (`PERTE-52-01072026...`) : c'est elle qui fait foi.

2. **Les quantités sont parfois vides** alors que les cases « Filtree » et
   « Petillante » disent le contraire. On retombe alors sur les cases.
"""
import datetime
import re
import sys
from collections import Counter, defaultdict

import openpyxl

# Le parc constaté au moment de la reprise : chaque chambre dotée avait ses deux
# bouteilles. On l'écrit comme une régularisation tracée, jamais comme un stock
# posé d'autorité.
DATE_REPRISE = datetime.date(2026, 3, 30)

STATUTS = {
    "Récupéré": "restitue",
    "Facturé": "facture",
    "Perte": "non_facture",
}

# Qui constate (gouvernantes et femmes de chambre) et qui reçoit le dossier.
ROLES = {
    "miguel": "admin",
    "victoria": "gouvernante",
    "sarah p": "operations",
}


def q(v):
    """Un littéral SQL, ou NULL."""
    if v is None:
        return "null"
    return "'" + str(v).replace("'", "''") + "'"


def date_de_reference(ref):
    """La date portée par la référence du dossier — la seule non ambiguë."""
    if not ref:
        return None
    m = re.search(r"-(\d{8})", str(ref))
    if not m:
        return None
    j, mo, a = m.group(1)[:2], m.group(1)[2:4], m.group(1)[4:]
    try:
        return datetime.date(int(a), int(mo), int(j))
    except ValueError:
        return None


def date_de_cellule(v):
    """Une date de cellule : sûre si c'est du texte, suspecte si Excel l'a devinée."""
    if isinstance(v, datetime.datetime):
        return v.date(), False        # Excel a tranché le jour/mois : à confirmer
    if isinstance(v, datetime.date):
        return v, False
    if isinstance(v, str):
        m = re.match(r"(\d{1,2})/(\d{1,2})/(\d{4})", v.strip())
        if m:
            return datetime.date(int(m.group(3)), int(m.group(2)), int(m.group(1))), True
    return None, False


def lire_date(cellule, reference, rapport, quoi, apres=None):
    """La date retenue.

    Une cellule texte est explicite : on la garde telle quelle. Une cellule que
    Excel a devinée est ambiguë — `05/12/2026` peut être le 5 décembre ou le
    12 mai. Pour la date du constat, la référence du dossier tranche. Pour les
    dates qui suivent (transmission, contact, clôture), on retient celle des deux
    lectures qui ne précède pas le constat et qui en est la plus proche : une
    transmission n'a jamais lieu avant le constat.
    """
    depuis_cellule, sure = date_de_cellule(cellule)
    if depuis_cellule is None:
        return None
    if sure:
        return depuis_cellule

    if apres is None:
        depuis_ref = date_de_reference(reference)
        if depuis_ref:
            if depuis_ref != depuis_cellule:
                rapport["dates_redressees"].append(
                    f"{reference} ({quoi}) : Excel lisait {depuis_cellule:%d/%m/%Y}, "
                    f"la référence dit {depuis_ref:%d/%m/%Y}")
            return depuis_ref
        rapport["dates_incertaines"].append(f"{reference} ({quoi}) : {depuis_cellule}")
        return depuis_cellule

    lectures = [depuis_cellule]
    try:
        lectures.append(depuis_cellule.replace(
            day=depuis_cellule.month, month=depuis_cellule.day))
    except ValueError:
        pass
    possibles = sorted(d for d in set(lectures) if d >= apres)
    if not possibles:
        rapport["dates_incertaines"].append(
            f"{reference} ({quoi}) : {depuis_cellule:%d/%m/%Y}, antérieure au constat")
        return apres
    if len(set(lectures)) > 1 and possibles[0] != depuis_cellule:
        rapport["dates_redressees"].append(
            f"{reference} ({quoi}) : Excel lisait {depuis_cellule:%d/%m/%Y}, "
            f"retenu {possibles[0]:%d/%m/%Y} — une date postérieure au constat")
    return possibles[0]


def montant(v):
    if v is None:
        return None
    if isinstance(v, (int, float)):
        return float(v)
    t = str(v).replace("€", "").replace(" ", "").replace(",", ".").strip()
    try:
        return float(t)
    except ValueError:
        return None


def quantites(ligne):
    """Combien de chaque type — les cases font foi quand la quantité est vide."""
    f = ligne.get("Quantite_Filtree")
    p = ligne.get("Quantite_Petillante")
    if f is None and p is None:
        f = 1 if ligne.get("Filtree") else 0
        p = 1 if ligne.get("Petillante") else 0
    return int(f or 0), int(p or 0)


def main(chemin):
    wb = openpyxl.load_workbook(chemin, data_only=True)
    ws = wb.active
    lignes = list(ws.iter_rows(values_only=True))
    entetes = lignes[0]
    data = [dict(zip(entetes, r)) for r in lignes[1:] if any(r)]

    rapport = defaultdict(list)
    compte = Counter()

    print("-- ==========================================================================")
    print("-- Import des bouteilles Purezza — produit par outils/importer_bouteilles.py")
    print("-- Ne pas éditer à la main : régénérer depuis l'export.")
    print("-- ==========================================================================")
    print("begin;")

    # --- Les personnes qui apparaissent dans l'export --------------------------
    personnes = set()
    for d in data:
        for col in ("Constate_Par", "Transmis_A"):
            nom = str(d.get(col) or "").strip()
            if nom:
                personnes.add(nom)
    print("\n-- Personnes citées dans l'export des bouteilles ------------------------")
    for nom in sorted(personnes):
        role = ROLES.get(nom.lower(), "gouvernante" if nom.lower() != "taibi" else "technicien")
        print(f"insert into utilisateurs (nom, role) values ({q(nom)}, {q(role)}) "
              f"on conflict (nom) do nothing;")

    # --- Le parc constaté à la reprise ----------------------------------------
    print("\n-- Parc constaté à la reprise : chaque chambre dotée avait ses bouteilles.")
    print("-- Écrit comme une régularisation tracée, jamais comme un stock posé.")
    print(f"""insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, vers_emplacement_id, date_mouvement, commentaire)
select 'regularisation', d.bouteille_type_id, d.quantite, 'hors_parc', 'emplacement',
       d.emplacement_id, timestamptz '{DATE_REPRISE} 08:00+02',
       'Parc constaté à la reprise de l''ancienne application'
from dotations d join emplacements e on e.id = d.emplacement_id
where e.actif and e.dote_bouteilles;""")

    # --- Les opérations, dans l'ordre chronologique ---------------------------
    operations = []
    for d in data:
        ref = d.get("Reference")
        date = lire_date(d.get("Constate_Le"), ref, rapport, "constat")
        if date is None:
            rapport["sans_date"].append(str(ref))
            continue
        operations.append((date, d, ref))
    operations.sort(key=lambda o: o[0])

    print("\n-- Opérations reprises, dans l'ordre chronologique ----------------------")
    for date, d, ref in operations:
        type_evt = str(d.get("Type_Evenement") or "").strip()
        chambre = d.get("Chambre")
        f, p = quantites(d)
        compte[type_evt] += 1

        if type_evt == "Entrée":
            # Une livraison : elle entre en réserve, pas en chambre.
            print(f"\n-- Entrée en réserve du {date:%d/%m/%Y} — {f} filtrées, {p} gazeuses")
            for code, qte in (("filtree", f), ("petillante", p)):
                if qte <= 0:
                    continue
                print(f"""insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, date_mouvement, commentaire)
select 'entree', bt.id, {qte}, 'hors_parc', 'reserve',
       timestamptz '{date} 10:00+02', 'Livraison reprise de l''ancienne application'
from bouteille_types bt where bt.code = '{code}';""")
            continue

        if chambre is None:
            rapport["sans_chambre"].append(str(ref))
            continue
        code_chambre = str(chambre).strip()

        if type_evt == "Remplacement":
            # Une re-dotation : la chambre est resservie depuis la réserve. Ce
            # n'est pas une seconde sortie de parc, c'est un déplacement.
            print(f"\n-- Remplacement en chambre {code_chambre} le {date:%d/%m/%Y}")
            for code, qte in (("filtree", f), ("petillante", p)):
                if qte <= 0:
                    continue
                print(f"""insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, vers_emplacement_id, date_mouvement, utilisateur_id, commentaire)
select 'dotation', bt.id, {qte}, 'reserve', 'emplacement', e.id,
       timestamptz '{date} 12:00+02',
       (select id from utilisateurs where nom = {q(str(d.get('Constate_Par') or '').strip() or None)}),
       'Remplacement repris — {ref}'
from bouteille_types bt, emplacements e
where bt.code = '{code}' and e.code = {q(code_chambre)};""")
            continue

        if type_evt != "Perte":
            rapport["type_inconnu"].append(f"{ref} : {type_evt}")
            continue

        if f == 0 and p == 0:
            rapport["sans_quantite"].append(str(ref))
            continue

        transmis_le = lire_date(d.get("Transmis_Le"), ref, rapport, "transmission", date)
        contacte_le = lire_date(d.get("Client_Contacte_Le"), ref, rapport, "contact client", date)
        final_le = lire_date(d.get("Statut_Final_Le"), ref, rapport, "clôture",
                             contacte_le or transmis_le or date)
        statut_source = str(d.get("Statut_Final") or "").strip() or None
        statut = STATUTS.get(statut_source)
        if statut_source and statut is None:
            rapport["statut_inconnu"].append(f"{ref} : {statut_source}")

        if statut is None:
            statut = ("client_contacte" if contacte_le
                      else "transmis" if transmis_le
                      else "signale")

        mt = montant(d.get("Montant"))
        constate_par = str(d.get("Constate_Par") or "").strip() or None
        transmis_a = str(d.get("Transmis_A") or "").strip() or None
        client = str(d.get("Nom_Dossier") or "").strip() or None
        note = str(d.get("Commentaire") or "").strip() or None

        # Le dossier est créé au statut « signalé » : ce sont les mises à jour
        # qui suivent qui déclenchent les mouvements de résolution, exactement
        # comme si la gouvernante avait cliqué.
        print(f"\n-- {ref} — chambre {code_chambre}, {date:%d/%m/%Y}")
        print(f"""with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', {q(client)},
         (select id from utilisateurs where nom = {q(constate_par)}),
         timestamptz '{date} 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = {q(transmis_a)}),
         {f"timestamptz '{transmis_le} 11:30+02'" if transmis_le else 'null'},
         {f"timestamptz '{contacte_le} 11:30+02'" if contacte_le else 'null'},
         {mt if mt is not None else 'null'}, {q(note)}
  from emplacements e where e.code = {q(code_chambre)}
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', {f}), ('petillante', {p})) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;""")

        if statut in ("restitue", "facture", "non_facture"):
            quand = final_le or date
            print(f"""update incidents_bouteille
   set statut = '{statut}', resolu_le = timestamptz '{quand} 17:00+02',
       resolu_par = (select id from utilisateurs where nom = {q(transmis_a or constate_par)})
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = {q(code_chambre)})
                and constate_le = timestamptz '{date} 11:00+02'
              order by reference desc limit 1);""")
        elif statut in ("transmis", "client_contacte"):
            print(f"""update incidents_bouteille set statut = '{statut}'
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = {q(code_chambre)})
                and constate_le = timestamptz '{date} 11:00+02'
              order by reference desc limit 1);""")

    print("\ncommit;")

    # --- Rapport sur stderr ---------------------------------------------------
    e = sys.stderr
    print(f"\n{len(data)} lignes lues", file=e)
    for t, n in sorted(compte.items()):
        print(f"  {t:<14} {n}", file=e)
    for cle, valeurs in sorted(rapport.items()):
        print(f"\n{cle} ({len(valeurs)})", file=e)
        for v in valeurs:
            print(f"  {v}", file=e)


if __name__ == "__main__":
    main(sys.argv[1])
