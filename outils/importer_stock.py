#!/usr/bin/env python3
"""Génère le SQL d'import des produits et des mouvements de stock.

    python3 outils/importer_stock.py <Produits.xlsx> <MouvementsStock.xlsm> \
        > donnees/import_stock.sql

À jouer APRÈS l'import des anomalies : les sorties se rattachent aux
interventions par l'identifiant SharePoint de l'anomalie.

Les 261 mouvements sont repris tels quels — qui a pris quoi, quand, pour quelle
chambre. Comme l'ancienne application ignorait 249 d'entre eux (colonne
`EstHistorique`), leur somme ne redonne pas le stock affiché : une ligne de
régularisation par produit, datée de la reprise, recale l'écart. L'historique
est donc conservé sans que le stock mente.
"""
import collections
import datetime
import re
import sys
import unicodedata

import openpyxl

from analyse_source import lire_date
from importer_anomalies import NOMS_CANONIQUES, PRESTATAIRES, cle, q, qnom
from referentiel_lieux import CHAMBRES_DE_TEST, EMPLACEMENTS, SYNONYMES

INVENTAIRE_REPRISE = "cccccccc-0000-0000-0000-000000000001"


def charger(chemin):
    ws = openpyxl.load_workbook(chemin, read_only=True, data_only=True).worksheets[0]
    lignes = list(ws.iter_rows(values_only=True))
    entetes = [h.strip() if isinstance(h, str) else h for h in lignes[0]]
    return [dict(zip(entetes, r)) for r in lignes[1:] if any(v is not None for v in r)]


def montant(v):
    """Les prix de l'export sont du texte français : « 74,00 € »."""
    if v is None or v == "":
        return None
    if isinstance(v, (int, float)):
        return float(v)
    t = re.sub(r"[^0-9,.\-]", "", str(v)).replace(",", ".")
    try:
        return float(t) if t not in ("", "-", ".") else None
    except ValueError:
        return None


def nettoyer(v):
    """Les identifiants de l'export portent des espaces insécables : « 1 040 »."""
    if v is None:
        return None
    t = re.sub(r"[\s ]", "", str(v))
    return int(t) if t.isdigit() else None


def code_lieu(brut):
    if not brut:
        return None
    brut = str(brut).strip()
    if brut.isdigit():
        if brut in CHAMBRES_DE_TEST:
            return None
        code = f"{int(brut):02d}"
        return code if code in EMPLACEMENTS else None
    return SYNONYMES.get(
        re.sub(r"\s+", " ", "".join(
            c for c in unicodedata.normalize("NFD", brut.lower())
            if unicodedata.category(c) != "Mn")).strip())


def main(chemin_produits: str, chemin_mouvements: str) -> None:
    produits = charger(chemin_produits)
    mouvements = [m for m in charger(chemin_mouvements) if m.get("TypeMouvement")]
    rapport = collections.defaultdict(collections.Counter)

    # Deux produits partagent le code « Inconnu » dans l'export : on les
    # distingue plutôt que d'en perdre un silencieusement à l'insertion.
    vus = collections.Counter()
    for p in produits:
        brut = str(p["CodeArticle"]).strip()
        vus[brut] += 1
        p["_code"] = brut if vus[brut] == 1 else f"{brut}-{vus[brut]}"
        if vus[brut] > 1:
            rapport["codes_dupliques"][brut] += 1

    # Le libellé des mouvements reprend la désignation, parfois le code.
    par_designation = {str(p["Designation"]).strip(): p for p in produits}
    par_code = {str(p["CodeArticle"]).strip(): p for p in produits}

    def produit_de(m):
        n = str(m["Produit"]).strip() if m.get("Produit") else None
        return par_designation.get(n) or par_code.get(n)

    print("-- Généré par outils/importer_stock.py — ne pas modifier à la main.")
    print("-- À jouer après donnees/import_anomalies.sql.")
    print("\nbegin;\n")

    # --- Produits ----------------------------------------------------------
    print("-- Produits ------------------------------------------------------------")
    for p in produits:
        code = p["_code"]
        prix = montant(p.get("Prix Unitaire"))
        seuil = montant(p.get("SeuilAlerte")) or 0
        if prix is None:
            rapport["sans_prix"][code] += 1
        if not p.get("SeuilAlerte"):
            rapport["sans_seuil"][code] += 1
        if p.get("Photo"):
            rapport["photos_non_migrables"][code] += 1
        print(
            "insert into produits (code, designation, categorie, categorie_lieu,"
            " prix_unitaire, seuil_alerte) values ("
            f"{q(code)}, {q(str(p['Designation']).strip())}, {q(p.get('Categorie_1'))},"
            f" {q(p.get('Categorie_2'))}, {prix if prix is not None else 'null'},"
            f" {seuil}) on conflict (code) do nothing;")

    # --- Inventaire de reprise, pour porter les régularisations -------------
    print("\n-- Inventaire de reprise ------------------------------------------------")
    print(
        "insert into inventaires (id, type, libelle, statut, ouvert_par, valide_par, valide_le,"
        " commentaire) select "
        f"'{INVENTAIRE_REPRISE}', 'materiel', 'Reprise de l''ancienne application', 'valide',"
        " u.id, u.id, now(),"
        " 'Recale chaque produit sur le stock affiché avant la bascule, sans effacer"
        " l''historique des mouvements.'\n"
        "  from utilisateurs u where u.nom = 'Miguel' on conflict (id) do nothing;")

    # --- Mouvements --------------------------------------------------------
    print("\n-- Mouvements de stock --------------------------------------------------")
    retenus = 0
    for m in mouvements:
        p = produit_de(m)
        if not p:
            rapport["produit_introuvable"][str(m.get("Produit"))] += 1
            continue
        date = lire_date(m.get("DateMouvement"))
        if not date:
            rapport["sans_date"][str(m.get("Produit"))] += 1
            continue
        if date.year < 2015:
            rapport["dates_aberrantes"][str(date)] += 1

        type_source = str(m["TypeMouvement"]).strip()
        qte = montant(m.get("Quantite")) or 0
        if type_source == "Entrée":
            type_cible, qte, motif = "entree", abs(qte), None
        elif type_source == "Sortie":
            type_cible, qte, motif = "sortie", -abs(qte), None
        else:
            type_cible, motif = "regularisation", "inventaire"
            qte = montant(m.get("Ecart")) if m.get("Ecart") is not None else qte
        if not qte:
            rapport["quantite_nulle"][str(m.get("Produit"))] += 1
            continue

        nom = str(m.get("Par") or "").strip()
        externe = cle(nom) in PRESTATAIRES
        lieu = code_lieu(m.get("LOCALISATION"))
        anomalie = nettoyer(m.get("Intervention_ID"))
        inventaire = f"'{INVENTAIRE_REPRISE}'" if motif == "inventaire" else "null"

        print(
            "insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement,"
            " utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id,"
            " commentaire) select "
            f"pr.id, '{type_cible}', {q(motif)}, {qte}, timestamptz '{date}', u.id, pt.id,"
            f" e.id, i.id, {inventaire}, {q(m.get('Commentaire'))}"
            f"\n  from produits pr"
            f"\n  left join utilisateurs u  on u.nom = {qnom('' if externe else nom)}"
            f"\n  left join prestataires pt on pt.nom = {qnom(nom if externe else '')}"
            f"\n  left join emplacements e  on e.code = {q(lieu)}"
            f"\n  left join anomalies a     on a.sharepoint_id = {anomalie if anomalie else 'null'}"
            f"\n  left join interventions i on i.anomalie_id = a.id"
            f"\n  where pr.code = {q(p['_code'])};")
        retenus += 1

    # --- Recalage : l'historique reste, le stock devient juste ---------------
    print("\n-- Recalage de reprise --------------------------------------------------")
    print("-- L'ancienne application ignorait les mouvements marqués « historique » ;")
    print("-- son stock affiché vaut donc Stock_Initial plus les seuls mouvements")
    print("-- récents. On vise ce chiffre, et l'écart devient une régularisation.")
    cibles = []
    for p in produits:
        code = p["_code"]
        recents = sum(
            (montant(m.get("Quantite")) or 0) * (-1 if str(m["TypeMouvement"]).strip() == "Sortie" else 1)
            for m in mouvements
            if produit_de(m) is p and m.get("EstHistorique") is not True
            and str(m["TypeMouvement"]).strip() in ("Entrée", "Sortie"))
        cibles.append((code, (montant(p.get("Stock_Initial")) or 0) + recents))

    valeurs = ",\n  ".join(f"({q(c)}, {v})" for c, v in cibles)
    print(f"""with cible (code, stock_vise) as (values
  {valeurs}
)
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement,
                              utilisateur_id, inventaire_id, commentaire)
select p.id, 'regularisation', 'inventaire',
       c.stock_vise - coalesce(sum(m.quantite), 0),
       now(), u.id, '{INVENTAIRE_REPRISE}',
       'Reprise : recalage sur le stock affiché avant la bascule'
from produits p
join cible c on c.code = p.code
left join mouvements_stock m on m.produit_id = p.id
left join utilisateurs u on u.nom = 'Miguel'
group by p.id, c.stock_vise, u.id
having c.stock_vise - coalesce(sum(m.quantite), 0) <> 0;""")

    print("\ncommit;")

    e = sys.stderr
    print(f"\n{len(produits)} produits · {retenus} mouvements sur {len(mouvements)}", file=e)
    for titre, compteur in rapport.items():
        print(f"\n⚠ {titre.replace('_', ' ')} : {sum(compteur.values())}", file=e)
        for k, n in compteur.most_common(5):
            print(f"    {n:4d}  {k[:60]}", file=e)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
