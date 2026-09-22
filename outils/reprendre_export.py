#!/usr/bin/env python3
"""Aligne la base sur un nouvel export « TEST Tech 3 », sans rien perdre.

    python3 outils/reprendre_export.py <export.xlsx> > donnees/reprise_export.sql

L'import initial (`importer_anomalies.py`) suppose une base vide : il crée. Ce
script-ci suppose une base VIVANTE, dans laquelle on travaille depuis des
semaines, et il la met d'accord avec le tableau.

La différence est tout le sujet. Depuis l'import, l'application a produit des
choses que le tableau ne connaît pas : des photos, des commentaires écrits dans
le fil, des dossiers bouteille, des entrées de stock, des produits, des
fournisseurs, des factures, et des anomalies déclarées directement dans
l'application. Rien de tout cela ne doit être touché.

Ce que le tableau POSSÈDE, et qu'on réaligne donc :

  la date de déclaration, le lieu, la description, l'état, qui a constaté, qui
  a saisi ; la date de l'intervention et qui l'a faite ; la date de
  vérification et par qui ; le matériel sorti et sa quantité.

Ce qu'il ne possède pas, on n'y touche pas. Le rattachement se fait sur
`anomalies.sharepoint_id`, qui porte la colonne ID du tableau : une anomalie
sans `sharepoint_id` vient de l'application, elle est hors de portée.

Pourquoi ce script existe : l'ancien export donnait les dates en TEXTE, dans
deux formats mélangés — « 17/12/2024 » et « 2025-09-12 ». L'import a dû
deviner, et il s'est trompé sur 270 dates de déclaration et 229 dates
d'intervention, jour et mois inversés. Une date d'intervention fausse, c'est un
passage au mauvais jour, et une facture qui ne se rapproche plus.
"""
import datetime
import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0])

from analyse_source import charger, lire_date  # noqa: E402
from referentiel_lieux import EMPLACEMENTS, SYNONYMES  # noqa: E402
from importer_anomalies import (  # noqa: E402
    NOMS_CANONIQUES,
    PRESTATAIRES,
    cle,
    code_emplacement,
    doublons_ouverts,
    libelles_canoniques,
    q,
    qnom,
    statut_final,
)

# Même règle que l'import : l'histoire commence au 1er janvier 2025. Les lignes
# antérieures n'ont jamais été reprises, et les réintroduire ferait apparaître
# deux ans d'arriéré dans les écrans.
DEBUT = datetime.date(2025, 1, 1)


def nom_canonique(brut) -> str:
    t = str(brut or "").strip()
    return NOMS_CANONIQUES.get(cle(t), t)


def materiel(d) -> str:
    """Le nom du produit sorti.

    Les deux colonnes disent la même chose, à cinq lignes près — et sur ces
    cinq, c'est `PRODUIT_UTILISE` qui porte le nom du catalogue :
    « Télérupteurs (Mécaniques) Paris Elec ou YesssElectrique » plutôt que
    « Télérupteurs (Mécaniques) ». On la préfère, et on retombe sur l'autre
    quand elle est vide.
    """
    return (
        str(d.get("PRODUIT_UTILISE") or "").strip()
        or str(d.get("Materiel_Utilise") or "").strip()
    )


def main(chemin: str) -> None:
    data = charger(chemin)
    e = sys.stderr

    # Le même problème ouvert deux fois au même endroit est impossible : l'index
    # `anomalie_unique_ouverte_par_lieu` le refuse, et c'est voulu. Le tableau,
    # lui, peut porter la même ligne deux fois — saisie deux fois. On garde la
    # plus récente et on annule les autres, exactement comme l'import initial.
    rapport = {"doublons_annules": __import__("collections").Counter()}
    canoniques = libelles_canoniques(data)
    doublons = doublons_ouverts(data, canoniques, rapport)

    lignes = []
    ignorees = 0
    archivees = 0
    for d in data:
        sid = d.get("ID")
        libelle = str(d.get("AnomaliesCommentaires") or "").strip()
        if sid is None or not libelle:
            ignorees += 1
            continue
        declare = lire_date(d.get("Date"))
        if declare and declare < DEBUT:
            archivees += 1
            continue
        lieu = code_emplacement(d.get("LOCALISATION"), {})
        if not lieu:
            ignorees += 1
            continue
        lignes.append((int(sid), d, declare, lieu))

    ids = sorted(l[0] for l in lignes)

    print("-- Reprise d'un nouvel export « TEST Tech 3 » sur une base vivante.")
    print(f"-- Produit par outils/reprendre_export.py — {len(lignes)} lignes retenues.")
    print("--")
    print("-- Ne touche QUE ce que le tableau possède, et seulement les anomalies")
    print("-- qui en viennent (sharepoint_id renseigné). Les photos, le fil, les")
    print("-- dossiers bouteille, le stock et les anomalies déclarées dans")
    print("-- l'application ne sont jamais lus ni modifiés.")
    print("\nbegin;")

    # Les déclencheurs de validation recalculent le statut de l'anomalie : on
    # les coupe le temps de la reprise, comme le fait l'import.
    print("\nalter table validations disable trigger tg_validation_maj_anomalie;")

    # ------------------------------------------------------------------ table
    print("\n-- Le tableau, tel qu'il est aujourd'hui. Une ligne par anomalie.")
    print("create temporary table reprise (")
    print("  sharepoint_id  int primary key,")
    print("  lieu           text,")
    print("  libelle        text,")
    print("  statut         text,")
    print("  declare_le     date,")
    print("  constate_par   text,")
    print("  saisie_par     text,")
    print("  fait_le        date,")
    print("  par            text,")
    print("  externe        boolean,")
    print("  verifie_le     date,")
    print("  verifie_par    text,")
    print("  produit        text,")
    print("  quantite       numeric")
    print(") on commit drop;")

    valeurs = []
    for sid, d, declare, lieu in lignes:
        par = nom_canonique(d.get("PAR"))
        externe = cle(par) in PRESTATAIRES
        qte = d.get("Quantite_Sortie_Stock")
        try:
            qte = float(qte) if qte not in (None, "") else None
        except (TypeError, ValueError):
            qte = None
        valeurs.append(
            "  ("
            + ", ".join(
                [
                    str(sid),
                    q(lieu),
                    q(str(d.get("AnomaliesCommentaires") or "").strip()),
                    q(statut_final(d, sid in doublons)),
                    q(declare),
                    qnom(nom_canonique(d.get("Constate_Par"))),
                    qnom(nom_canonique(d.get("SAISIE PAR"))),
                    q(lire_date(d.get("FAIT_LE"))),
                    qnom("" if externe else par),
                    "true" if externe else "false",
                    q(lire_date(d.get("VERIFIE_LE"))),
                    qnom(nom_canonique(d.get("VERIFIE_PAR"))),
                    q(materiel(d)),
                    "null" if qte is None else repr(qte),
                ]
            )
            + ")"
        )
    print("insert into reprise values")
    print(",\n".join(valeurs) + ";")

    # Le nom d'un prestataire va dans sa propre colonne : `par` reste vide pour
    # un extérieur, et c'est `externe` qui dit où chercher.
    print("\n-- Le nom d'un intervenant extérieur, à part : il n'est pas utilisateur.")
    print("alter table reprise add column prestataire text;")
    for sid, d, declare, lieu in lignes:
        par = nom_canonique(d.get("PAR"))
        if cle(par) in PRESTATAIRES:
            print(
                f"update reprise set prestataire = {qnom(par)} "
                f"where sharepoint_id = {sid};"
            )

    # ------------------------------------------------------- lignes disparues
    print("\n-- 1. Les lignes retirées de l'export.")
    print("--    Une anomalie que le tableau ne porte plus n'a plus lieu d'être :")
    print("--    elle a été supprimée à la source. Ce qu'elle a sorti du stock")
    print("--    reste (le matériel a bien quitté l'étagère) — c'est la règle de")
    print("--    la suppression d'une anomalie, posée par le schéma.")
    print("delete from anomalies a")
    print(" where a.sharepoint_id is not null")
    print(f"   and a.sharepoint_id <> all(array[{','.join(str(i) for i in ids)}]);")

    # ---------------------------------------------------------- l'en-tête
    print("\n-- 2. L'anomalie : ce que le tableau dit d'elle.")
    print("--    Le lieu se corrige aussi — la reprise s'était trompée de porte.")
    print("--")
    print("--    En DEUX temps, et l'ordre compte. `anomalie_unique_ouverte_par_lieu`")
    print("--    interdit le même libellé ouvert deux fois au même endroit, et il le")
    print("--    vérifie ligne par ligne, pas à la fin de l'instruction. Si une")
    print("--    anomalie se ferme pour laisser la place à une autre, la fermer")
    print("--    d'abord évite un refus au milieu du chemin.")
    print("update anomalies a")
    print("   set statut = r.statut::statut_anomalie")
    print("  from reprise r")
    print(" where a.sharepoint_id = r.sharepoint_id")
    print("   and a.statut::text is distinct from r.statut")
    print("   and r.statut in ('validee', 'annulee');")
    print("\nupdate anomalies a")
    print("   set declare_le   = r.declare_le,")
    print("       description  = r.libelle,")
    print("       statut       = r.statut::statut_anomalie,")
    print("       emplacement_id = e.id,")
    print("       constate_par = coalesce(uc.id, a.constate_par),")
    print("       saisie_par   = coalesce(us.id, a.saisie_par)")
    print("  from reprise r")
    print("  join emplacements e   on e.code = r.lieu")
    print("  left join utilisateurs uc on lower(uc.nom) = lower(r.constate_par)")
    print("  left join utilisateurs us on lower(us.nom) = lower(r.saisie_par)")
    print(" where a.sharepoint_id = r.sharepoint_id")
    print("   and (a.declare_le::date is distinct from r.declare_le")
    print("     or a.description  is distinct from r.libelle")
    print("     or a.statut::text is distinct from r.statut")
    print("     or a.emplacement_id is distinct from e.id")
    print("     or (uc.id is not null and a.constate_par is distinct from uc.id));")

    # --------------------------------------------------------- l'intervention
    print("\n-- 3. L'intervention : sa date, et qui l'a faite.")
    print("--    C'est la correction la plus lourde : une date d'intervention")
    print("--    fausse met le passage au mauvais jour, et la facture ne se")
    print("--    rapproche plus. Le regroupement suit, plus bas.")
    print("--    Une reprise ne remplace jamais une valeur par du vide : si le nom")
    print("--    ne se rattache à personne, on garde ce que la base sait déjà.")
    print("--    Écraser l'intervenant d'un passage parce qu'un export l'écrit")
    print("--    « ALAIN » et la table « Alain » serait une perte, pas une")
    print("--    correction.")
    print("update interventions i")
    print("   set date_intervention = r.fait_le,")
    print("       technicien_id  = case when r.externe then i.technicien_id")
    print("                             else coalesce(u.id, i.technicien_id) end,")
    print("       prestataire_id = case when r.externe then coalesce(p.id, i.prestataire_id)")
    print("                             else i.prestataire_id end")
    print("  from reprise r")
    print("  join anomalies a on a.sharepoint_id = r.sharepoint_id")
    print("  left join utilisateurs u on lower(u.nom) = lower(r.par)")
    print("  left join prestataires p on lower(p.nom) = lower(r.prestataire)")
    print(" where i.anomalie_id = a.id")
    print("   and r.fait_le is not null")
    print("   and (i.date_intervention is distinct from r.fait_le")
    print("     or (not r.externe and u.id is not null")
    print("         and i.technicien_id is distinct from u.id)")
    print("     or (r.externe and p.id is not null")
    print("         and i.prestataire_id is distinct from p.id));")

    print("\n-- Une intervention que le tableau annonce et que la base n'a pas.")
    print("insert into interventions (anomalie_id, tournee_id, technicien_id,")
    print("                           prestataire_id, date_intervention, cree_le)")
    print("select a.id, null,")
    print("       case when r.externe then null else u.id end,")
    print("       case when r.externe then p.id else null end,")
    print("       r.fait_le, r.fait_le::timestamptz")
    print("  from reprise r")
    print("  join anomalies a on a.sharepoint_id = r.sharepoint_id")
    print("  left join utilisateurs u on lower(u.nom) = lower(r.par)")
    print("  left join prestataires p on lower(p.nom) = lower(r.prestataire)")
    print(" where r.fait_le is not null")
    print("   and not exists (select 1 from interventions i where i.anomalie_id = a.id);")

    # ------------------------------------------------------------ les avis
    print("\n-- 4. Les deux avis. Les dates suivent, elles aussi.")
    print("update validations v")
    print("   set decide_le = r.fait_le::timestamptz")
    print("  from reprise r")
    print("  join anomalies a on a.sharepoint_id = r.sharepoint_id")
    print("  join interventions i on i.anomalie_id = a.id")
    print(" where v.intervention_id = i.id and v.acteur = 'technicien'")
    print("   and r.fait_le is not null")
    print("   and v.decide_le::date is distinct from r.fait_le;")

    print("\nupdate validations v")
    print("   set decide_le = r.verifie_le::timestamptz")
    print("  from reprise r")
    print("  join anomalies a on a.sharepoint_id = r.sharepoint_id")
    print("  join interventions i on i.anomalie_id = a.id")
    print(" where v.intervention_id = i.id and v.acteur = 'gouvernante'")
    print("   and r.verifie_le is not null")
    print("   and v.decide_le::date is distinct from r.verifie_le;")

    print("\n-- L'avis du technicien, quand le tableau le donne et que la base")
    print("-- ne l'a pas : sans lui, l'anomalie n'a personne qui la déclare faite.")
    print("insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le)")
    print("select i.id, 'technicien', 'fait',")
    print("       case when r.externe then null else u.id end, r.fait_le::timestamptz")
    print("  from reprise r")
    print("  join anomalies a on a.sharepoint_id = r.sharepoint_id")
    print("  join interventions i on i.anomalie_id = a.id")
    print("  left join utilisateurs u on lower(u.nom) = lower(r.par)")
    print(" where r.fait_le is not null")
    print("   and not exists (select 1 from validations v")
    print("        where v.intervention_id = i.id and v.acteur = 'technicien');")

    print("\ninsert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le)")
    print("select i.id, 'gouvernante', 'validee', u.id, r.verifie_le::timestamptz")
    print("  from reprise r")
    print("  join anomalies a on a.sharepoint_id = r.sharepoint_id")
    print("  join interventions i on i.anomalie_id = a.id")
    print("  left join utilisateurs u on lower(u.nom) = lower(r.verifie_par)")
    print(" where r.verifie_le is not null")
    print("   and not exists (select 1 from validations v")
    print("        where v.intervention_id = i.id and v.acteur = 'gouvernante');")

    # -------------------------------------------------------- le matériel
    print("\n-- 5. Le matériel sorti : sa date suit l'intervention, et son nom")
    print("--    se corrige (l'export portait « Télérupteurs (Mécaniques) » avec")
    print("--    un retour à la ligne au milieu).")
    print("update mouvements_stock m")
    print("   set date_mouvement = r.fait_le::timestamptz")
    print("  from reprise r")
    print("  join anomalies a on a.sharepoint_id = r.sharepoint_id")
    print("  join interventions i on i.anomalie_id = a.id")
    print(" where m.intervention_id = i.id")
    print("   and r.fait_le is not null")
    print("   and m.date_mouvement::date is distinct from r.fait_le;")

    print("\n-- Une sortie que le tableau annonce et que la base n'a pas. On ne")
    print("-- sort que ce que le catalogue connaît : un nom inconnu est signalé")
    print("-- dans le compte-rendu plutôt que d'inventer un produit.")
    print("insert into mouvements_stock (produit_id, type, quantite, utilisateur_id,")
    print("                             prestataire_id, emplacement_id, intervention_id,")
    print("                             date_mouvement, commentaire)")
    # Une quantité vide OU à zéro vaut une : le tableau nomme un produit, donc
    # il a servi — c'est le compte qui n'a pas été noté. Et le schéma refuse un
    # mouvement de zéro, à juste titre : un mouvement qui ne déplace rien n'est
    # pas un mouvement.
    print("select pr.id, 'sortie', -greatest(coalesce(r.quantite, 1), 1),")
    print("       case when r.externe then null else u.id end,")
    print("       case when r.externe then p.id else null end,")
    print("       a.emplacement_id, i.id, r.fait_le::timestamptz,")
    print("       'Intervention — ' || a.description")
    print("  from reprise r")
    print("  join anomalies a on a.sharepoint_id = r.sharepoint_id")
    print("  join interventions i on i.anomalie_id = a.id")
    print("  join produits pr on pr.designation = r.produit")
    print("  left join utilisateurs u on lower(u.nom) = lower(r.par)")
    print("  left join prestataires p on lower(p.nom) = lower(r.prestataire)")
    print(" where r.produit <> '' and r.fait_le is not null")
    print("   and not exists (select 1 from mouvements_stock m")
    print("        where m.intervention_id = i.id and m.produit_id = pr.id);")

    # ----------------------------------------------------- les nouvelles lignes
    print("\n-- 6. Les anomalies que le tableau porte et que la base n'a pas.")
    print("insert into anomalies (sharepoint_id, emplacement_id, description, statut,")
    print("                       declare_le, constate_par, saisie_par)")
    print("select r.sharepoint_id, e.id, r.libelle, r.statut::statut_anomalie,")
    print("       r.declare_le, uc.id, coalesce(us.id, uc.id)")
    print("  from reprise r")
    print("  join emplacements e on e.code = r.lieu")
    print("  left join utilisateurs uc on lower(uc.nom) = lower(r.constate_par)")
    print("  left join utilisateurs us on lower(us.nom) = lower(r.saisie_par)")
    print(" where not exists (select 1 from anomalies a")
    print("        where a.sharepoint_id = r.sharepoint_id);")

    print("\nalter table validations enable trigger tg_validation_maj_anomalie;")

    # -------------------------------------------------------- le regroupement
    print("\n-- 7. Les passages se remettent d'aplomb : un par intervenant et par")
    print("--    jour, les interventions accrochées au bon, les passages vides")
    print("--    effacés. C'est ce qui suit la correction des dates.")
    print("select * from fn_regrouper_les_passages();")

    print("\n-- Ce que la reprise a laissé de côté, à relire :")
    print("select r.sharepoint_id, r.produit")
    print("  from reprise r")
    print(" where r.produit <> ''")
    print("   and not exists (select 1 from produits p where p.designation = r.produit)")
    print(" order by r.produit, r.sharepoint_id;")

    print("\ncommit;")

    print(f"\n{len(lignes)} lignes retenues sur {len(data)}", file=e)
    print(f"{ignorees} ignorées (sans identifiant, sans libellé ou sans lieu)", file=e)
    print(f"{archivees} antérieures au {DEBUT:%d/%m/%Y}", file=e)


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "donnees/export/test-tech-3.xlsx")
