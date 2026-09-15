#!/usr/bin/env python3
"""Table de correspondance entre les localisations saisies et le référentiel.

Les 86 orthographes relevées dans l'export sont ramenées à un emplacement
canonique. Ce qui n'est pas listé ici est signalé à l'import, jamais ignoré.
"""

# code canonique -> (libellé, étage, type)
EMPLACEMENTS = {
    # Chambres — 37 au total, une par ligne du référentiel d'origine
    **{f"{n:02d}": (f"Chambre {n:02d}", etage, "chambre")
       for etage, nums in {
           "RDC":  [1, 2, 3],
           "1er":  [11, 12, 14, 15, 16, 18],
           "2eme": [21, 22, 24, 25, 26, 27, 28],
           "3eme": [31, 32, 34, 35, 36, 37, 38],
           "4eme": [41, 42, 44, 45, 46, 47, 48],
           "5eme": [51, 52, 54, 55, 56, 57, 58],
       }.items() for n in nums},

    # Rez-de-chaussée
    "Reception":      ("Réception",              "RDC", "commun"),
    "Lobby":          ("Lobby",                  "RDC", "commun"),
    "Entree":         ("Entrée",                 "RDC", "commun"),
    "PDJ":            ("Salle petit-déjeuner",   "RDC", "commun"),
    "Cuisine":        ("Cuisine",                "RDC", "technique"),
    "Bagagerie":      ("Bagagerie",              "RDC", "technique"),
    "Bureau":         ("Bureau",                 "RDC", "technique"),
    "Escalier-RDC":   ("Escalier de secours RDC","RDC", "commun"),

    # Étages
    "Etage-1":        ("1er étage — général",    "1er",  "commun"),
    "Palier-1":       ("Palier 1er",             "1er",  "commun"),
    "Escalier-1":     ("Escalier du 1er",        "1er",  "commun"),
    "Etage-2":        ("2ème étage — général",   "2eme", "commun"),
    "Etage-3":        ("3ème étage — général",   "3eme", "commun"),
    "Palier-3":       ("Palier 3ème",            "3eme", "commun"),
    "Etage-4":        ("4ème étage — général",   "4eme", "commun"),
    "Escalier-4":     ("Escalier du 4ème",       "4eme", "commun"),
    "Etage-5":        ("5ème étage — général",   "5eme", "commun"),
    "Palier-5":       ("Palier 5ème",            "5eme", "commun"),
    "Escalier-5":     ("Escalier du 5ème",       "5eme", "commun"),
    "Office-5":       ("Office 5ème étage",      "5eme", "technique"),

    # Sous-sol
    "WC-Clients":     ("WC clients",             "Sous-Sol", "commun"),
    "WC-Femmes":      ("WC femmes",              "Sous-Sol", "commun"),
    "WC-Hommes":      ("WC hommes",              "Sous-Sol", "commun"),
    "Salle-Sport":    ("Salle de sport",         "Sous-Sol", "commun"),
    "Salle-Repos":    ("Salle de repos",         "Sous-Sol", "commun"),
    "Chaufferie":     ("Chaufferie",             "Sous-Sol", "technique"),
    "Local-TGBT":     ("Local TGBT",             "Sous-Sol", "technique"),
    "Local-Technique":("Local technique",        "Sous-Sol", "technique"),
    "Lingerie":       ("Lingerie",               "Sous-Sol", "technique"),
    "Escalier-SS":    ("Escalier du sous-sol",   "Sous-Sol", "commun"),
    "Sous-Sol":       ("Sous-sol — général",     "Sous-Sol", "commun"),

    # Transverses et extérieurs
    "Ascenseur":      ("Ascenseur",              "Autres", "technique"),
    "Communs":        ("Parties communes",       "Autres", "commun"),
    "Toit":           ("Toit",                   "Autres", "exterieur"),
    "Cour":           ("Cour intérieure",        "Autres", "exterieur"),
    "Exterieur":      ("Extérieur de l'hôtel",   "Autres", "exterieur"),
    "General":        ("Général / non localisé", "Autres", "commun"),
}

# orthographe rencontrée (minuscules, espaces lissés) -> code canonique
SYNONYMES = {
    "reception": "Reception",
    "mur a cote de la reception": "Reception",
    "rdc face ascenseur": "Lobby",
    "lobby": "Lobby",
    "lobby devant(le pillier)": "Lobby",
    "lobby devant le pillier": "Lobby",
    "entree": "Entree",
    "rdc": "Lobby",
    "pdj": "PDJ",
    "buffet du petit dejeuner": "PDJ",
    "cuisine": "Cuisine",
    "bagagerie": "Bagagerie",
    "bureau": "Bureau",
    "escalier de secours (rdc)": "Escalier-RDC",

    "1er etage": "Etage-1",
    "palier 1er": "Palier-1",
    "escalier du 1er": "Escalier-1",
    "escalier qui mene au 1er": "Escalier-1",
    "2eme etage": "Etage-2",
    "3eme etage": "Etage-3",
    "palier du 3eme": "Palier-3",
    "4eme etage": "Etage-4",
    "escalier qui mene au 4eme": "Escalier-4",
    "5eme etage": "Etage-5",
    "palier 5eme": "Palier-5",
    "escalier qui mene au 5eme": "Escalier-5",
    "office 5 eme etage": "Office-5",

    "wc clients": "WC-Clients",
    "wc femmes": "WC-Femmes",
    "wc hommes": "WC-Hommes",
    "salle de sport": "Salle-Sport",
    "salle de repos (sous sol)": "Salle-Repos",
    "chaufferie": "Chaufferie",
    "local tgbt": "Local-TGBT",
    "local technique": "Local-Technique",
    "lingerie": "Lingerie",
    "escalier qui mene au sous-sol": "Escalier-SS",
    "sous sol": "Sous-Sol",

    "ascenseur": "Ascenseur",
    "parties communes": "Communs",
    "toit": "Toit",
    "cour interieure": "Cour",
    "exterieur de l'hotel": "Exterieur",
    "exterieur de lhotel": "Exterieur",
    "general": "General",
    "divers": "General",
}

# Numéros présents dans l'export mais absents du plan de l'hôtel (37 chambres).
# Signalés à l'import plutôt que créés en douce.
CHAMBRES_INCONNUES = {"6", "7"}
