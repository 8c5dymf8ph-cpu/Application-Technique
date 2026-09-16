#!/usr/bin/env python3
"""Référentiel des localisations, tel que défini dans l'application d'origine.

EMPLACEMENTS reproduit exactement la liste fournie : le code est la chaîne
utilisée dans le Switch de l'application Power Apps, pour que rien ne se perde
à la traduction. À noter, et c'est volontaire : un escalier est rangé à l'étage
d'où l'on part, pas à celui où l'on arrive.

SYNONYMES ramène les 86 orthographes rencontrées dans l'export vers ces codes.
"""

# étage -> codes, dans l'ordre de la liste d'origine
LISTE_ORIGINE = {
    "RDC":      ["01", "02", "03", "PDJ", "Réception", "Lobby", "Entrée", "Cuisine",
                 "Bagagerie", "Ascenseur"],
    "1er":      ["Palier 1er", "11", "12", "14", "15", "16", "18"],
    "2eme":     ["2eme étage", "21", "22", "24", "25", "26", "27", "28"],
    "3eme":     ["3eme étage", "31", "32", "34", "35", "36", "37", "38",
                 "escalier qui mène au 4ème"],
    "4eme":     ["4eme étage", "41", "42", "44", "45", "46", "47", "48",
                 "escalier qui mène au 5ème"],
    "5eme":     ["Palier 5ème", "Office 5 ème étage", "51", "52", "54", "55", "56", "57", "58"],
    "Sous-Sol": ["Salle de sport", "Sas de sécurité", "WC Clients", "WC Femmes", "WC Hommes",
                 "Escalier qui mène au RDC", "Salle de repos", "Vestiaire Hommes",
                 "Vestiaire Femmes", "Lingerie", "Local TGBT", "Local Technique",
                 "Local poubelle", "Chaufferie"],
    "Autres":   ["Toit", "COUR intèrieure"],
}

# Trois emplacements absents de la liste d'origine mais nécessaires pour placer
# une vingtaine de lignes de l'export. À confirmer, puis à intégrer à la liste.
AJOUTS_A_CONFIRMER = {
    "Sous-sol divers":  "Sous-Sol",   # les 4 lignes qui disent seulement « sous sol »
    "Parties communes": "Autres",     # « Divers », « GENERAL », « Bureau », escaliers du RDC
}

# « Vestiaire Femmes » est déduit : la liste fournie répète « Vestiaire Hommes »
# deux fois, et le sous-sol distingue par ailleurs WC hommes et WC femmes.
DEDUCTIONS_A_CONFIRMER = {"Vestiaire Femmes"}

TYPES = {
    "PDJ": "commun", "Réception": "commun", "Lobby": "commun", "Entrée": "commun",
    "Cuisine": "technique", "Bagagerie": "technique",
    "Palier 1er": "commun", "2eme étage": "commun", "3eme étage": "commun",
    "4eme étage": "commun", "Palier 5ème": "commun", "Office 5 ème étage": "technique",
    "escalier qui mène au 4ème": "commun", "escalier qui mène au 5ème": "commun",
    "WC Clients": "commun", "WC Femmes": "commun", "WC Hommes": "commun",
    "Salle de sport": "commun", "Sas de sécurité": "commun", "Salle de repos": "commun",
    "Escalier qui mène au RDC": "commun",
    "Vestiaire Hommes": "technique", "Vestiaire Femmes": "technique",
    "Chaufferie": "technique", "Local TGBT": "technique", "Local Technique": "technique",
    "Local poubelle": "technique", "Lingerie": "technique",
    "Toit": "exterieur", "COUR intèrieure": "exterieur",
    "Ascenseur": "technique", "Sous-sol divers": "commun", "Parties communes": "commun",
}

# code -> (étage, type). Un code purement numérique est une chambre.
EMPLACEMENTS = {
    code: (etage, "chambre" if code.isdigit() else TYPES[code])
    for etage, codes in LISTE_ORIGINE.items() for code in codes
}
EMPLACEMENTS.update({
    code: (etage, TYPES[code]) for code, etage in AJOUTS_A_CONFIRMER.items()
})

# orthographe rencontrée (minuscules, sans accent, espaces lissés) -> code
SYNONYMES = {
    # Rez-de-chaussée
    "reception": "Réception", "mur a cote de la reception": "Réception",
    "lobby": "Lobby", "lobby devant(le pillier)": "Lobby",
    "rdc": "Lobby",
    "entree": "Entrée", "pdj": "PDJ", "buffet du petit dejeuner": "PDJ",
    "cuisine": "Cuisine", "bagagerie": "Bagagerie",

    # Étages : un escalier appartient à l'étage d'où l'on part
    "palier 1er": "Palier 1er", "1er etage": "Palier 1er", "escalier du 1er": "Palier 1er",
    "2eme etage": "2eme étage",
    "3eme etage": "3eme étage", "palier du 3eme": "3eme étage",
    "escalier qui mene au 4eme": "escalier qui mène au 4ème",
    "4eme etage": "4eme étage",
    "escalier qui mene au 5eme": "escalier qui mène au 5ème",
    "palier 5eme": "Palier 5ème", "5eme etage": "Palier 5ème",
    "office 5 eme etage": "Office 5 ème étage",

    # Sous-sol
    "wc clients": "WC Clients", "wc hommes": "WC Hommes", "wc femmes": "WC Femmes",
    "salle de sport": "Salle de sport", "chaufferie": "Chaufferie",
    "local tgbt": "Local TGBT", "local technique": "Local Technique", "lingerie": "Lingerie",
    "salle de repos (sous sol)": "Salle de repos",
    "escalier qui mene au sous-sol": "Escalier qui mène au RDC",
    "sous sol": "Sous-sol divers",

    # Transverses et extérieurs
    "ascenseur": "Ascenseur", "rdc face ascenseur": "Ascenseur",
    "toit": "Toit",
    "cour interieure": "COUR intèrieure", "exterieur de l'hotel": "COUR intèrieure",
    "parties communes": "Parties communes", "divers": "Parties communes",
    "general": "Parties communes", "bureau": "Parties communes",
    "escalier de secours (rdc)": "Parties communes",
    "escalier qui mene au 1er": "Parties communes",
}

# Lignes de test de l'application d'origine : elles ne sont pas importées.
CHAMBRES_DE_TEST = {"6", "7"}

ORDRE_ETAGES = {"RDC": 0, "1er": 1, "2eme": 2, "3eme": 3,
                "4eme": 4, "5eme": 5, "Sous-Sol": 6, "Autres": 7}
