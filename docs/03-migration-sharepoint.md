# Migration depuis SharePoint

## Étape 1 — Exporter les 5 listes (à faire par toi)

Pour chaque liste, dans SharePoint : **Exporter** → **Exporter vers CSV**, puis déposer le fichier
dans `donnees/export/` avec le nom indiqué.

| Liste SharePoint | Fichier attendu |
|---|---|
| `TEST Tech 3` | `donnees/export/test-tech-3.csv` |
| `RecapInterventions` | `donnees/export/recap-interventions.csv` |
| `Produits` | `donnees/export/produits.csv` |
| `MouvementsStock` | `donnees/export/mouvements-stock.csv` |
| `Bouteilles_Purezza` | `donnees/export/bouteilles-purezza.csv` |

> L'export CSV ne contient pas les pièces jointes. Les photos des produits se récupèrent depuis
> la bibliothèque de la liste, ou seront re-photographiées à l'usage — ce n'est pas bloquant.

## Étape 2 — Ce que fait le script d'import

| Source | Destination | Transformation |
|---|---|---|
| `TEST Tech 3` | `anomalies` | `STATUT` → `statut`, `LOCALISATION` → `emplacement_id`, `ID` → `sharepoint_id` |
| `TEST Tech 3` (lignes faites) | `interventions` + `validations` | `PAR` / `FAIT_LE` deviennent l'avis du technicien |
| `RecapInterventions` | complète `interventions` | Dédoublonné sur `SharePointId` |
| `Produits` | `produits` | `Name` → `code`, `Stock_Initial` → **un mouvement d'entrée daté**, pas un champ |
| `MouvementsStock` | `mouvements_stock` | Signe appliqué selon `TypeMouvement` |
| `Bouteilles_Purezza` | `incidents_bouteille` + `mouvements_bouteilles` | **Recalculé** : les `Remplacement` liés à une perte ne sont plus une déduction mais une re-dotation |

Les emplacements absents du référentiel sont signalés dans un rapport d'import plutôt qu'ignorés
silencieusement — on ne perd aucune ligne sans le savoir.

## Étape 3 — Bascule

1. Comptage physique du matériel et des bouteilles le jour J (écran dédié dans l'application).
2. Import des données.
3. Contrôle : nombre d'anomalies actives identique des deux côtés.
4. Listes SharePoint passées en **lecture seule** et conservées comme archive.
