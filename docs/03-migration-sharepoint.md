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

## Points à trancher

1. **Classement des intervenants.** `outils/importer_anomalies.py` sépare utilisateurs et
   prestataires sur une liste de noms. Sont classés **prestataires** : EcoFlair, Technicien AVIR,
   Technicien Kone, Technicien TELEC, Technicien EUROPROH, MR NEGRONI, ALAIN, Hedi, Juan.
   Sont classés **utilisateurs** : Miguel, Victoria, Serafino, Sarah P, Taibi, FARID, Rachid.
   À corriger dans la constante `PRESTATAIRES` si le classement est faux.

2. **Aménagement proposé pour le catalogue.** Plutôt que de bloquer la gouvernante sur les 64 % de
   cas neufs : elle choisit dans le catalogue, et si rien ne convient elle saisit son texte, qui
   crée une anomalie marquée **« à classer »**. L'admin la voit dans une file dédiée et, d'un clic,
   la promeut au catalogue ou la rattache à une entrée existante. Le catalogue reste sous contrôle,
   sans que le travail s'arrête. C'est une politique RLS à changer, pas une refonte.

3. **Les 12 dates dans le futur** sont probablement des fautes de frappe (2026 au lieu de 2025).
   À confirmer avant de les corriger.
