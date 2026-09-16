# Stock matériel — ce que disent les exports

Exports reçus : `Produits` (36 lignes) et `MouvementsStock` (261 lignes).

## Produits

| Colonne | Renseignée | Conséquence |
|---|---|---|
| `CodeArticle`, `Designation` | 36 / 36 | Référentiel complet |
| `Categorie_1` | 36 / 36 | Le métier : Électricité (16), Equipments (13), Plomberie (4), Divers (2), Serrurerie (1) |
| `Categorie_2` | 36 / 36 | Le lieu : Chambre (15), General (12), Salle de Bain (9) |
| `Prix Unitaire` | **20 / 36** | 16 produits sans prix — le coût d'intervention sera annoncé comme partiel |
| `SeuilAlerte` | **21 / 36** | 15 produits ne déclencheront aucune alerte tant que le seuil n'est pas fixé |
| `Stock_Initial` | 25 / 36 | Sert de première entrée à l'import |
| `Photo` | **4 / 36** | 32 produits sans visuel dans la liste du technicien |
| `Fournisseur_*` | **0 / 36** | **Aucun fournisseur renseigné** : la demande de devis automatique ne peut pas fonctionner |

Deux catégories, deux usages : `Categorie_1` alimente le filtre métier (et rejoint les types
d'intervention), `Categorie_2` le filtre par lieu. Les deux sont conservées.

## Mouvements

| Constat | Détail |
|---|---|
| 261 mouvements | 206 sorties, 53 entrées, 1 ajustement |
| **249 sur 261 marqués `EstHistorique`** | Le stock affiché aujourd'hui en ignore 95 % : il repose donc presque entièrement sur `Stock_Initial` |
| `StockActuel` vide sur les 36 produits | Le champ censé porter le stock n'est plus alimenté |
| 35 produits cités, **0 introuvable** | Le rattachement des mouvements aux produits se fera sans perte |

C'est l'explication du problème d'inventaire : le stock visible n'est pas le résultat des
mouvements, c'est un chiffre de départ que 95 % de l'historique ne corrige jamais.

Dans le nouveau modèle, `EstHistorique`, `Stock_Initial` et `StockActuel` disparaissent : les 261
mouvements sont repris tels quels et le stock est leur somme.

## Ce que fait l'import

Les 261 mouvements sont repris **tels quels** : qui a pris quoi, quand, pour quelle chambre, et pour
quelle anomalie — la colonne `Intervention_ID` pointe sur l'identifiant SharePoint de l'anomalie, ce
qui donne les coûts matériel réels par intervention.

Leur somme ne redonne pas le stock affiché aujourd'hui, puisque l'ancienne application en ignorait
249. Une **ligne de régularisation par produit**, datée de la reprise et rattachée à un inventaire
« Reprise de l'ancienne application », recale l'écart. L'historique est conservé sans que le stock
mente.

```
stock visé = Stock_Initial + les seuls mouvements non marqués « historique »
           = ce que l'ancienne application affiche

régularisation = stock visé − somme des 261 mouvements
```

Le comptage physique du jour J produira une seconde régularisation, qui fera foi.

### Résultat

| | |
|---|---|
| Produits | 36 |
| Mouvements | 257 repris + 26 régularisations de reprise |
| Sorties rattachées à une intervention | 139 |
| Produits sous leur seuil | 20 |
| Valeur du stock | ~3 900 € HT |

### Signalé par le rapport d'import

| Constat | Traitement |
|---|---|
| Deux produits portent le code `Inconnu` | Le second est suffixé `Inconnu-2` plutôt que perdu |
| 2 mouvements sans date, 1 sans quantité | Écartés, comptés dans le rapport |
| 1 mouvement daté du 20/01/2000 | Importé, signalé comme aberrant |
| 1 produit au stock négatif (−42) | Importé tel quel, listé dans `v_controle_donnees` |
| 4 photos | Références SharePoint (`Reserved_ImageAttachment_…`), **non récupérables** : à recharger |

## À compléter avant la bascule

1. **Les fournisseurs** — sans eux, pas de demande de devis groupée. C'est le seul manque bloquant.
2. **Les 16 prix manquants** — sinon le coût d'intervention restera partiel sur ces articles.
3. **Les 15 seuils manquants** — sinon aucune alerte de réapprovisionnement sur ces articles.
4. **Les photos** — confort, non bloquant : la liste affiche un visuel de remplacement.
