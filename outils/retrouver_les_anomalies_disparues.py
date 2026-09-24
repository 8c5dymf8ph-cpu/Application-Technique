#!/usr/bin/env python3
"""Retrouve dans l'export les anomalies que la base n'a plus, et les remet.

    python3 outils/retrouver_les_anomalies_disparues.py manque   > donnees/recuperation/1_ce_qui_manque.sql
    python3 outils/retrouver_les_anomalies_disparues.py remettre > donnees/recuperation/2_les_remettre.sql

Deux fichiers, parce que l'éditeur SQL de Supabase ne montre QUE le dernier
résultat : le premier ne fait que regarder, le second remet. On lit, puis on
remet.

Une anomalie supprimée par erreur ne laisse rien derrière elle quand le journal
(migration 0021) n'était pas encore posé : la ligne part, et son fil, ses photos
et ses interventions partent avec elle. Mais l'export « TEST Tech 3 » la porte
toujours — c'est la source de tout le côté technique — et `sharepoint_id` dit
laquelle manque.

Ce script ne fait QUE cela. `reprendre_export.py` réaligne toute la base sur le
tableau ; celui-ci ne touche à rien de ce qui existe. Il ne lit que l'absence :
un identifiant que le tableau porte et que `anomalies` n'a pas.

Ce qu'il remet : l'anomalie (son lieu, son libellé, son rattachement au
catalogue, son métier, son état, qui l'a constatée, sa date), son commentaire
d'origine, son intervention, les deux avis, et le matériel sorti.

Ce qu'il ne peut PAS remettre : les photos et les commentaires écrits dans
l'application après l'import. Ils n'existent que dans la base, le tableau ne les
a jamais connus, et la suppression les a emportés. De même, une anomalie
déclarée directement dans l'application n'a pas de `sharepoint_id` : le tableau
ne la porte pas, elle est hors de portée. Le journal des suppressions (0021)
est là pour que cela n'arrive plus.

Le matériel, lui, n'est pas reperdu : supprimer une anomalie laisse son
mouvement de stock en place (il a bien quitté l'étagère), seulement détaché. Le
script le RACCROCHE plutôt que d'en créer un second — sinon la pièce sortirait
deux fois de la réserve.
"""
import collections
import datetime
import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0])

from analyse_source import charger, lire_date, normaliser_libelle  # noqa: E402
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

DEBUT = datetime.date(2025, 1, 1)


def nom_canonique(brut) -> str:
    t = str(brut or "").strip()
    return NOMS_CANONIQUES.get(cle(t), t)


def materiel(d) -> str:
    return (
        str(d.get("PRODUIT_UTILISE") or "").strip()
        or str(d.get("Materiel_Utilise") or "").strip()
    )


def main(quoi: str, chemin: str) -> None:
    data = charger(chemin)
    e = sys.stderr
    rapport = {"doublons_annules": collections.Counter()}
    canoniques = libelles_canoniques(data)
    doublons = doublons_ouverts(data, canoniques, rapport)

    lignes = []
    for d in data:
        sid = d.get("ID")
        libelle = " ".join(str(d.get("AnomaliesCommentaires") or "").split())
        if sid is None or not libelle:
            continue
        declare = lire_date(d.get("Date"))
        if declare and declare < DEBUT:
            continue
        lieu = code_emplacement(d.get("LOCALISATION"), {})
        if not lieu:
            continue
        lignes.append((int(sid), d, declare, lieu, libelle))

    remet = quoi == "remettre"
    print("-- Retrouver les anomalies que la base n'a plus"
          + (" — et les remettre." if remet else " : ce qui manque."))
    print(f"-- Produit par outils/retrouver_les_anomalies_disparues.py"
          f" — {len(lignes)} lignes du tableau.")
    print("--")
    if remet:
        print("-- Ne touche à RIEN de ce qui existe : ni les anomalies présentes,")
        print("-- ni les photos, ni le fil, ni le stock, ni les dossiers bouteille.")
        print("-- Il ne lit que l'absence — un identifiant que le tableau porte et")
        print("-- que la table n'a pas — et remet la ligne manquante avec ce que le")
        print("-- tableau sait d'elle.")
        print("--")
        print("-- À jouer APRÈS avoir lu 1_ce_qui_manque.sql, d'un bloc, dans")
        print("-- l'éditeur SQL de Supabase. Le résultat affiché dit ce qui a été")
        print("-- remis.")
    else:
        print("-- NE MODIFIE RIEN. Il ne fait que regarder, et dire quelles")
        print("-- anomalies du tableau « TEST Tech 3 » ne sont plus dans la base.")
        print("-- Une ligne ici = une anomalie disparue.")
        print("--")
        print("-- À jouer d'un bloc dans l'éditeur SQL de Supabase. Ensuite,")
        print("-- 2_les_remettre.sql les remet.")

    print("\nbegin;")
    if remet:
        print("\n-- L'état d'une anomalie vient du tableau, pas du recalcul des avis.")
        print("alter table validations disable trigger tg_validation_maj_anomalie;")

    # ------------------------------------------------------------------ table
    print("\n-- Le tableau, tel qu'il est. Une ligne par anomalie.")
    print("create temporary table tableau (")
    print("  sharepoint_id  int primary key,")
    print("  lieu           text,")
    print("  libelle        text,")
    print("  canonique      text,")
    print("  type_code      text,")
    print("  statut         text,")
    print("  declare_le     date,")
    print("  cloture_le     date,")
    print("  constate_par   text,")
    print("  saisie_par     text,")
    print("  commentaire    text,")
    print("  fait_le        date,")
    print("  par            text,")
    print("  prestataire    text,")
    print("  externe        boolean,")
    print("  verifie_le     date,")
    print("  verifie_par    text,")
    print("  produit        text,")
    print("  quantite       numeric")
    print(") on commit drop;")

    valeurs = []
    for sid, d, declare, lieu, libelle in lignes:
        par = nom_canonique(d.get("PAR"))
        externe = cle(par) in PRESTATAIRES
        statut = statut_final(d, sid in doublons)
        verifie = lire_date(d.get("VERIFIE_LE"))
        fait = lire_date(d.get("FAIT_LE"))
        cloture = (verifie or fait) if statut == "validee" else None
        qte = d.get("Quantite_Sortie_Stock")
        try:
            qte = float(qte) if qte not in (None, "") else None
        except (TypeError, ValueError):
            qte = None
        commentaire = " ".join(str(d.get("COMMENTAIRES") or "").split())
        valeurs.append(
            "  ("
            + ", ".join(
                [
                    str(sid),
                    q(lieu),
                    q(libelle),
                    q(canoniques.get(normaliser_libelle(libelle), libelle)),
                    q(str(d.get("TYPE") or "").strip()),
                    q(statut),
                    q(declare),
                    q(cloture),
                    qnom(nom_canonique(d.get("Constate_Par"))),
                    qnom(nom_canonique(d.get("SAISIE PAR"))),
                    q(commentaire),
                    q(fait),
                    qnom("" if externe else par),
                    qnom(par if externe else ""),
                    "true" if externe else "false",
                    q(verifie),
                    qnom(nom_canonique(d.get("VERIFIE_PAR"))),
                    q(materiel(d)),
                    "null" if qte is None else repr(qte),
                ]
            )
            + ")"
        )
    print("insert into tableau values")
    print(",\n".join(valeurs) + ";")

    # ------------------------------------------------------------- diagnostic
    print("\n-- 1. Ce qui manque. Une ligne ici = une anomalie disparue de la base.")
    print("create temporary table disparues on commit drop as")
    print("select t.* from tableau t")
    print(" where not exists (select 1 from anomalies a")
    print("        where a.sharepoint_id = t.sharepoint_id);")
    if not remet:
        print("\n-- D'abord l'inverse, pour situer : une anomalie de la base dont")
        print("-- l'identifiant a quitté l'export. Rien n'est supprimé ici — c'est")
        print("-- une information, pas un geste.")
        print("select a.sharepoint_id as \"n° d'origine\", e.code as lieu, a.description,")
        print("       a.declare_le::date as \"déclarée le\", a.statut")
        print("  from anomalies a join emplacements e on e.id = a.emplacement_id")
        print(" where a.sharepoint_id is not null")
        print("   and not exists (select 1 from tableau t")
        print("        where t.sharepoint_id = a.sharepoint_id)")
        print(" order by a.declare_le;")

    print("\n-- Et voici ce qui manque. C'est le résultat que Supabase affiche.")
    print("select sharepoint_id as \"n° d'origine\", lieu, libelle as \"libellé\",")
    print("       declare_le as \"déclarée le\", statut,")
    print("       fait_le as \"faite le\", coalesce(nullif(par,''), prestataire) as \"par\",")
    print("       nullif(commentaire, '') as \"commentaire du tableau\"")
    print("  from disparues order by declare_le, sharepoint_id;")

    if not remet:
        print("\n-- Rien n'a été modifié.")
        print("rollback;")
        print(f"\n{len(lignes)} lignes du tableau retenues sur {len(data)}", file=e)
        return


    # ------------------------------------------------------------- l'en-tête
    print("\n-- 2. L'anomalie revient : son lieu, son libellé, son métier, son")
    print("--    rattachement au catalogue — sans lui, le comptage des")
    print("--    récurrences (règle 8) perdrait cette ligne.")
    print("insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id,")
    print("                       description, statut, constate_par, saisie_par,")
    print("                       declare_le, cloture_le)")
    print("select d.sharepoint_id, e.id, c.id, ty.id, d.libelle,")
    print("       d.statut::statut_anomalie, uc.id, coalesce(us.id, uc.id),")
    print("       d.declare_le::timestamptz, d.cloture_le::timestamptz")
    print("  from disparues d")
    print("  join emplacements e on e.code = d.lieu")
    print("  left join catalogue_anomalies c on c.libelle = d.canonique")
    print("  left join types_intervention ty on ty.code = nullif(d.type_code, '')")
    print("  left join utilisateurs uc on lower(uc.nom) = lower(d.constate_par)")
    print("  left join utilisateurs us on lower(us.nom) = lower(d.saisie_par)")
    print(" on conflict (sharepoint_id) do nothing;")

    print("\n-- Le commentaire d'origine : c'est un propos, il a sa place au fil.")
    print("insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)")
    print("select a.id, d.commentaire, 'utilisateur', u.id, d.declare_le::timestamptz")
    print("  from disparues d")
    print("  join anomalies a on a.sharepoint_id = d.sharepoint_id")
    print("  left join utilisateurs u on lower(u.nom) = lower(d.constate_par)")
    print(" where d.commentaire <> ''")
    print("   and not exists (select 1 from commentaires cm")
    print("        where cm.anomalie_id = a.id and cm.texte = d.commentaire);")

    # ---------------------------------------------------------- l'intervention
    print("\n-- 3. Le passage : qui est venu, quel jour. La tournée se retrouve")
    print("--    plus bas, par fn_regrouper_les_passages().")
    print("insert into interventions (anomalie_id, tournee_id, technicien_id,")
    print("                           prestataire_id, date_intervention, cree_le)")
    print("select a.id, null,")
    print("       case when d.externe then null else u.id end,")
    print("       case when d.externe then p.id else null end,")
    print("       d.fait_le, d.fait_le::timestamptz")
    print("  from disparues d")
    print("  join anomalies a on a.sharepoint_id = d.sharepoint_id")
    print("  left join utilisateurs u on lower(u.nom) = lower(d.par)")
    print("  left join prestataires p on lower(p.nom) = lower(d.prestataire)")
    print(" where d.fait_le is not null")
    print("   and not exists (select 1 from interventions i where i.anomalie_id = a.id);")

    # --------------------------------------------------------------- les avis
    print("\n-- 4. Les deux avis, chacun à sa date. Le refus d'une gouvernante")
    print("--    n'efface jamais l'avis du technicien (règle 3) : ils coexistent.")
    print("insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le)")
    print("select i.id, 'technicien', 'fait',")
    print("       case when d.externe then null else u.id end, d.fait_le::timestamptz")
    print("  from disparues d")
    print("  join anomalies a on a.sharepoint_id = d.sharepoint_id")
    print("  join interventions i on i.anomalie_id = a.id")
    print("  left join utilisateurs u on lower(u.nom) = lower(d.par)")
    print(" where d.fait_le is not null")
    print("   and not exists (select 1 from validations v")
    print("        where v.intervention_id = i.id and v.acteur = 'technicien');")

    print("\ninsert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le)")
    print("select i.id, 'gouvernante', 'validee', u.id, d.verifie_le::timestamptz")
    print("  from disparues d")
    print("  join anomalies a on a.sharepoint_id = d.sharepoint_id")
    print("  join interventions i on i.anomalie_id = a.id")
    print("  left join utilisateurs u on lower(u.nom) = lower(d.verifie_par)")
    print(" where d.verifie_le is not null")
    print("   and not exists (select 1 from validations v")
    print("        where v.intervention_id = i.id and v.acteur = 'gouvernante');")

    # ------------------------------------------------------------ le matériel
    print("\n-- 5. Le matériel. Supprimer une anomalie ne rend pas ce qu'elle a")
    print("--    sorti : le mouvement reste en place, seulement détaché")
    print("--    (`intervention_id` à nul) — la pièce a bien quitté l'étagère.")
    print("--    On le RACCROCHE donc, on n'en crée pas un second : ce serait")
    print("--    sortir deux fois la même pièce.")
    print("--")
    print("--    Le rapprochement se fait sur le PRODUIT et le LIEU, pas sur le")
    print("--    commentaire (celui de la reprise porte le texte du tableau,")
    print("--    celui de l'application « Intervention — … ») et pas sur la seule")
    print("--    égalité stricte des dates : le tableau nettoyé a corrigé des jours")
    print("--    et des mois inversés (règle 16sexies), et le mouvement resté en")
    print("--    base peut encore porter l'ancienne date — le 03/05 s'y lit")
    print("--    03/05 à l'envers, soit 59 jours d'écart. On accepte donc les")
    print("--    DEUX lectures de la même date, et elles seules : une fenêtre de")
    print("--    tolérance attraperait un mouvement voisin qui n'a rien à voir.")
    print("--    Un seul mouvement par intervention (`limit 1`).")
    print("create temporary table raccroches on commit drop as")
    print("select i.id as intervention_id, pick.id as mouvement_id,")
    print("       d.sharepoint_id, d.fait_le, pick.date_mouvement::date as date_en_base")
    print("  from disparues d")
    print("  join anomalies a     on a.sharepoint_id = d.sharepoint_id")
    print("  join interventions i on i.anomalie_id = a.id")
    print("  join produits pr     on pr.designation = d.produit")
    print("  join lateral (")
    print("    select mm.id, mm.date_mouvement from mouvements_stock mm")
    print("     where mm.intervention_id is null")
    print("       and mm.produit_id = pr.id")
    print("       and mm.type = 'sortie'")
    print("       and mm.emplacement_id is not distinct from a.emplacement_id")
    print("       and mm.date_mouvement::date >= date '2025-01-01'")
    print("       and (mm.date_mouvement::date = d.fait_le")
    print("         or (extract(day from d.fait_le) <= 12")
    print("             and mm.date_mouvement::date = make_date(")
    print("                   extract(year  from d.fait_le)::int,")
    print("                   extract(day   from d.fait_le)::int,")
    print("                   extract(month from d.fait_le)::int)))")
    print("     order by abs(mm.date_mouvement::date - d.fait_le), mm.id limit 1) pick on true")
    print(" where d.produit <> '' and d.fait_le is not null;")
    print("\nupdate mouvements_stock m set intervention_id = c.intervention_id")
    print("  from raccroches c where m.id = c.mouvement_id;")
    print("\n-- Un mouvement raccroché sous une autre date, à relire : le")
    print("-- rapprochement est probable, il n'est pas certain.")
    print("select sharepoint_id as \"n° d'origine\", fait_le as \"le tableau dit\",")
    print("       date_en_base as \"le mouvement portait\"")
    print("  from raccroches where date_en_base is distinct from fait_le;")

    print("\n-- Et seulement s'il n'y en avait aucun à raccrocher, on le recrée.")
    print("insert into mouvements_stock (produit_id, type, quantite, utilisateur_id,")
    print("                             prestataire_id, emplacement_id, intervention_id,")
    print("                             date_mouvement, commentaire)")
    print("select pr.id, 'sortie', -greatest(coalesce(d.quantite, 1), 1),")
    print("       case when d.externe then null else u.id end,")
    print("       case when d.externe then p.id else null end,")
    print("       a.emplacement_id, i.id, d.fait_le::timestamptz,")
    print("       'Intervention — ' || a.description")
    print("  from disparues d")
    print("  join anomalies a on a.sharepoint_id = d.sharepoint_id")
    print("  join interventions i on i.anomalie_id = a.id")
    print("  join produits pr on pr.designation = d.produit")
    print("  left join utilisateurs u on lower(u.nom) = lower(d.par)")
    print("  left join prestataires p on lower(p.nom) = lower(d.prestataire)")
    print(" where d.produit <> '' and d.fait_le is not null")
    print("   and not exists (select 1 from mouvements_stock m")
    print("        where m.intervention_id = i.id and m.produit_id = pr.id);")

    # -------------------------------------------------------- le regroupement
    print("\n-- 6. L'intervention rejoint le passage de son jour et de son")
    print("--    intervenant, qui se crée s'il n'existait pas.")
    print("select * from fn_regrouper_les_passages();")

    print("\nalter table validations enable trigger tg_validation_maj_anomalie;")

    # ---------------------------------------------------------- compte-rendu
    print("\n-- 7. Ce qui a été remis, pour vérifier avant de valider.")
    print("select a.sharepoint_id as \"n° d'origine\", e.code as lieu,")
    print("       a.description as \"libellé\", a.statut,")
    print("       a.declare_le::date as \"déclarée le\",")
    print("       i.date_intervention as \"faite le\",")
    print("       coalesce(u.nom, p.nom) as \"par\",")
    print("       t.reference as \"passage\",")
    print("       (select count(*) from commentaires cm where cm.anomalie_id = a.id)")
    print("         as \"mots au fil\",")
    print("       (select count(*) from mouvements_stock m")
    print("         where m.intervention_id = i.id) as \"sorties de stock\"")
    print("  from disparues d")
    print("  join anomalies a on a.sharepoint_id = d.sharepoint_id")
    print("  join emplacements e on e.id = a.emplacement_id")
    print("  left join interventions i on i.anomalie_id = a.id")
    print("  left join tournees t on t.id = i.tournee_id")
    print("  left join utilisateurs u on u.id = i.technicien_id")
    print("  left join prestataires p on p.id = i.prestataire_id")
    print(" order by a.declare_le;")

    print("\n-- Relire ci-dessus, puis :")
    print("commit;")
    print("-- (ou `rollback;` si quelque chose ne va pas — rien n'aura bougé.)")

    print(f"\n{len(lignes)} lignes du tableau retenues sur {len(data)}", file=e)


if __name__ == "__main__":
    args = sys.argv[1:]
    quoi = args[0] if args and args[0] in ("manque", "remettre") else "manque"
    reste = [a for a in args if a not in ("manque", "remettre")]
    main(quoi, reste[0] if reste else "donnees/export/test-tech-3.xlsx")
