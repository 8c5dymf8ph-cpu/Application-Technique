#!/usr/bin/env python3
"""L'équipe, telle que Miguel l'a énoncée.

    python3 outils/equipe.py > donnees/equipe.sql

Ce fichier se joue EN DERNIER, après les imports : il corrige l'orthographe des
noms repris des exports (l'ancienne application les écrivait en capitales) et
fixe qui fait partie des intervenants techniques. Cette liste ne se devine pas
d'un rôle : Taibi est réceptionniste et intervient, la chargée des opérations
n'intervient pas. Elle est donnée, donc elle est écrite ici.
"""

# Orthographe retenue pour l'affichage. La clé est le nom tel qu'il sort des
# exports ; la valeur, celui que l'hôtel emploie.
ORTHOGRAPHE = {
    "ALAIN": "Alain",
    "FARID": "Farid",
    "MR NEGRONI": "Mr Negroni",
    "Technicien AVIR": "Technicien Avir",
    "Technicien TELEC": "Technicien Telec",
}

# Les intervenants techniques internes, mot pour mot. Les entreprises
# extérieures (Alain, Serafino, Hedi, Juan, EcoFlair, Mr Negroni, Technicien
# Telec / Kone / Avir / EUROPROH) sont des prestataires : elles interviennent
# du seul fait d'exister.
INTERVENANTS_INTERNES = ["Farid", "Miguel", "Rachid", "Victoria", "Taibi"]

# Qui, parmi eux, n'est pas salarié de l'hôtel et facture ses passages. Les
# autres interviennent aussi, mais leur passage ne coûte que le matériel sorti.
FACTURENT = ["Farid", "Rachid"]


def q(v):
    return "'" + str(v).replace("'", "''") + "'"


print("-- ==========================================================================")
print("-- L'équipe — produit par outils/equipe.py. Ne pas éditer à la main.")
print("-- À jouer après les imports : il corrige des noms qu'ils ont créés.")
print("-- ==========================================================================")
print("begin;")

print("\n-- Orthographe des noms repris des exports ------------------------------")
for avant, apres in sorted(ORTHOGRAPHE.items()):
    for table in ("utilisateurs", "prestataires"):
        # On ne renomme que s'il n'existe pas déjà quelqu'un sous le bon nom :
        # sinon on garderait deux fiches pour une seule personne.
        print(f"update {table} set nom = {q(apres)} where nom = {q(avant)} "
              f"and not exists (select 1 from {table} x where x.nom = {q(apres)});")

print("\n-- Qui fait partie des intervenants techniques ---------------------------")
print("update utilisateurs set intervient_technique = false;")
noms = ", ".join(q(n) for n in INTERVENANTS_INTERNES)
print(f"update utilisateurs set intervient_technique = true where nom in ({noms});")

print("\n-- Qui facture ses passages, et qui est de la maison ---------------------")
print("update utilisateurs set emet_des_factures = false;")
facturent = ", ".join(q(n) for n in FACTURENT)
print(f"update utilisateurs set emet_des_factures = true where nom in ({facturent});")

print("\ncommit;")
