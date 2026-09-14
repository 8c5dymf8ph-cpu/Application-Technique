# Modèle de données

Fichiers : `supabase/migrations/` (schéma), `supabase/seed/` (référentiels), `supabase/tests/` (scénarios).

## Principe directeur

**Rien de calculable n'est stocké.** Le stock matériel, le parc de bouteilles et le coût d'une
intervention sont des *vues* dérivées de leur historique de mouvements. Une valeur affichée ne peut
donc jamais diverger de ce qui l'explique — c'est exactement ce qui manquait à l'application Power Apps.

## Tables

### Référentiels
| Table | Rôle |
|---|---|
| `utilisateurs` | Personnel. `auth_id` nul = personne sélectionnable sans droit de connexion |
| `etages`, `emplacements` | RDC → 5ème, sous-sol, extérieurs. `dote_bouteilles` marque les 37 chambres |
| `types_intervention`, `prestataires` | Listes de choix |

### Interventions
| Table | Rôle |
|---|---|
| `anomalies` | Le problème constaté. `sharepoint_id` conserve le lien avec la ligne d'origine |
| `interventions` | Le traitement d'une anomalie par un technicien. Une anomalie refusée puis reprise en génère une seconde |
| `validations` | **Une ligne par avis**, technicien et gouvernante. Jamais écrasées |

### Stock matériel
| Table | Rôle |
|---|---|
| `produits` | 34 articles, prix unitaire, seuil d'alerte |
| `mouvements_stock` | Quantité **signée** : `+` entrée, `−` sortie, libre pour une régularisation |
| `inventaires`, `inventaire_lignes_produit` | Comptage physique ; la validation écrit les régularisations |

### Bouteilles Purezza
| Table | Rôle |
|---|---|
| `bouteille_types` | Filtrée / pétillante, 17,50 € vente, 8 € achat |
| `dotations` | Dotation permanente par chambre (1 + 1) |
| `incidents_bouteille` | Perte ou casse constatée, et le dossier d'arbitrage |
| `mouvements_bouteilles` | **Registre de déplacements** : d'où part la bouteille, où elle arrive |

## Vues

| Vue | Donne |
|---|---|
| `v_stock_produits` | Stock, valeur, dépassement de seuil |
| `v_interventions_cout` | matériel (calculé) + prestataire + libre = total |
| `v_recap_interventions` | Les deux avis côte à côte + `refusee_par_gouvernante` |
| `v_stock_bouteilles` | Réserve / en chambre / parc total / dotation théorique |
| `v_bouteilles_par_emplacement` | Théorique vs réel, chambre par chambre |
| `v_incidents_bouteille` | Dossiers de perte avec montant et caractère facturable |

## Pourquoi le registre de déplacements pour les bouteilles

L'ancienne formule `Entrées − Remplacements − Pertes` retirait deux bouteilles du stock pour un
seul incident. Ici, chaque mouvement dit `de_lieu → vers_lieu` et la vue `v_bouteilles_positions`
l'éclate en deux demi-lignes (`+` à l'arrivée, `−` au départ). Une bouteille qui passe de la réserve
à la chambre change de colonne sans changer le total ; seule une sortie vers `hors_parc` diminue le parc.

Le test `supabase/tests/01_scenarios.sql` verrouille précisément ce comportement : perte + re-dotation
immédiate ⇒ parc `100 → 99`, et non `100 → 98`.

## Contraintes qui empêchent les erreurs de saisie

- Une sortie de stock ne peut pas être positive, une entrée ne peut pas être négative.
- Une régularisation doit être rattachée à un inventaire.
- Un montant libre exige un motif.
- Un technicien ne peut pas enregistrer une décision de gouvernante (`decision_coherente_avec_acteur` + RLS).
- Un mouvement de bouteille doit être un déplacement réel et cohérent avec son type.
