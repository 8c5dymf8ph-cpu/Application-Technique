# Migration depuis SharePoint

## État

| Liste | Export reçu | Import |
|---|---|---|
| `TEST Tech 3` | ✅ 795 lignes | ✅ `outils/importer_anomalies.py` |
| `Produits` | ⏳ | à écrire |
| `MouvementsStock` | ⏳ | à écrire |
| `Bouteilles_Purezza` | ⏳ | à recalculer selon le modèle corrigé |
| `RecapInterventions` | ⏳ | fusion sur `InterventionID` |

## Ce que l'export a appris

### Quatre personnes par anomalie, pas deux

`Constate_Par` (qui a vu) ≠ `SAISIE PAR` (qui a saisi) ≠ `PAR` (qui a fait) ≠ `VERIFIE_PAR`
(qui a vérifié). Le modèle porte les quatre : `anomalies.constate_par`, `anomalies.saisie_par`,
`interventions.technicien_id` / `prestataire_id`, et la ligne de `validations` de la gouvernante.

### Un statut de plus

`ACHATS` (9 lignes) est un état d'attente : la ligne ne peut pas avancer tant que l'achat n'est pas
fait. Repris tel quel sous `a_acheter`.

### Le catalogue est plus fragile qu'espéré

759 anomalies renseignées, **268 libellés distincts après regroupement** — mais **172 (64 %) ne sont
apparus qu'une seule fois**. Deux tiers des déclarations sont donc des cas neufs.

La règle « la gouvernante ne saisit pas de texte libre » est appliquée telle que demandée, mais avec
ce taux, elle sera bloquée souvent. Voir la proposition d'aménagement en fin de document.

### Qualité des données

| Constat | Traitement |
|---|---|
| Dates à moitié en texte (`13/04/2026`), à moitié en date Excel | Les deux formats sont lus |
| 12 dates postérieures à aujourd'hui (jusqu'au 01/12/2026) | Importées telles quelles, **signalées dans le rapport** |
| 86 orthographes de localisation pour ~74 lieux réels | Table de correspondance dans `outils/referentiel_lieux.py` |
| Chambres « 6 » et « 7 », absentes du plan des 37 chambres | Rattachées à « Général », localisation d'origine conservée en commentaire |
| `Materiel_Utilise` et `PRODUIT_UTILISE` en double | Une seule colonne conservée |
| 36 lignes entièrement vides | Ignorées, comptées dans le rapport |

**Aucune ligne n'est perdue en silence.** Le script écrit son rapport sur la sortie d'erreur et
bascule sur « Général » plutôt que d'écarter une anomalie mal localisée.

## Résultat de l'import

```
795 lignes  −  36 vides  =  759 anomalies
625 FAIT      → 415 en attente de vérification + 210 validées
110 A FAIRE   → 110        15 EN COURS → 15        9 ACHATS → 9
759/759 rattachées au catalogue
611 interventions · 797 validations · 29 tournées · 8 utilisateurs · 9 prestataires
```

## Mode d'emploi

```bash
# 1. Vérifier ce que contient l'export, sans rien écrire
python3 outils/analyse_source.py donnees/export/test-tech-3.xlsx

# 2. Régénérer le catalogue d'anomalies
cd outils && python3 generer_catalogue.py ../donnees/export/test-tech-3.xlsx \
  > ../supabase/seed/02_catalogue_anomalies.sql

# 3. Produire le SQL d'import — à relire avant de l'appliquer
cd outils && python3 importer_anomalies.py ../donnees/export/test-tech-3.xlsx \
  > ../donnees/import_anomalies.sql
```

Le SQL produit est **rejouable** : chaque insertion est conditionnée, un second passage n'ajoute rien.

## Décisions prises

**Intervenants extérieurs** (ils facturent une journée, ne se connectent pas) : EcoFlair,
Technicien AVIR, Technicien Kone, Technicien TELEC, Technicien EUROPROH, MR NEGRONI, ALAIN, Hedi,
Juan. **Utilisateurs de l'application** : Miguel, Victoria, Serafino, Sarah P, Taibi, FARID, Rachid.
Le classement se corrige dans la constante `PRESTATAIRES` du script d'import.

**Catalogue strict**, conformément à la demande : aucune saisie libre depuis le téléphone. Une
anomalie absente du catalogue doit d'abord y être ajoutée par un admin, depuis un ordinateur.
La réserve reste valable — 64 % des libellés n'ont servi qu'une fois — donc l'écran d'administration
du catalogue doit être rapide à utiliser, et l'ajout d'une entrée tenir en quelques secondes.

**Dates douteuses importées telles quelles** et listées dans `v_controle_donnees`, qui alimente un
écran de contrôle : 12 anomalies datées dans le futur, 11 interventions dans le futur, 4 anomalies
dont la localisation n'a pas pu être résolue. Rien n'est corrigé sans décision explicite.
