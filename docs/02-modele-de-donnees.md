# Modèle de données

Fichiers : `supabase/migrations/` (schéma), `supabase/seed/` (référentiels), `supabase/tests/` (scénarios).

## Principe directeur

**Rien de calculable n'est stocké.** Le stock matériel, le parc de bouteilles et le coût d'une
intervention sont des *vues* dérivées de leur historique de mouvements. Une valeur affichée ne peut donc
jamais diverger de ce qui l'explique — c'est exactement ce qui manquait à l'application Power Apps.

## Tables

### Référentiels
| Table | Rôle |
|---|---|
| `utilisateurs` | Personnel. `auth_id` nul = personne sélectionnable sans droit de connexion |
| `etages`, `emplacements` | RDC → 5ème, sous-sol, extérieurs. `dote_bouteilles` marque les 37 chambres |
| `types_intervention` | Plomberie, électricité… |
| `prestataires` | Entreprises extérieures qui facturent une journée |
| `fournisseurs` | Fournisseurs de consommables — plusieurs produits peuvent en partager un |
| `catalogue_anomalies` | Libellés déclarables + mots-clés de recherche |

### Interventions
| Table | Rôle |
|---|---|
| `anomalies` | Le problème constaté. `catalogue_id` obligatoire sauf pour un admin. `sharepoint_id` garde le lien avec la ligne d'origine |
| `interventions` | Le traitement d'une anomalie, par un technicien interne ou un prestataire, à une date |
| `validations` | **Une ligne par avis**, technicien et gouvernante. Jamais écrasées, ni modifiables |
| `photos_anomalie` | Photos de constat et d'après-intervention |
| `factures`, `facture_interventions` | Facture d'une journée de prestataire, rapprochée de N interventions |

### Stock matériel
| Table | Rôle |
|---|---|
| `produits` | Articles. `prix_unitaire` **nullable** = prix inconnu |
| `mouvements_stock` | Quantité **signée** : `+` entrée, `−` sortie, libre pour une régularisation |
| `inventaires`, `inventaire_lignes_produit` | Comptage physique ; la validation écrit les régularisations |

### Bouteilles Purezza
| Table | Rôle |
|---|---|
| `bouteille_types` | Filtrée / pétillante. `seuil_alerte` porte sur la **réserve** |
| `dotations` | Dotation permanente par chambre (1 + 1) |
| `incidents_bouteille` | Emport ou casse, et le dossier d'arbitrage |
| `mouvements_bouteilles` | **Registre de déplacements** : d'où part la bouteille, où elle arrive |

### Réapprovisionnement et envois
| Table | Rôle |
|---|---|
| `demandes_devis`, `demande_devis_lignes` | Une demande par fournisseur, toutes ses lignes sous seuil |
| `recap_abonnements` | Récapitulatifs automatiques : destinataires, fréquence, périmètre |
| `alertes_destinataires` | Qui reçoit les alertes immédiates (incident bouteille, seuil de stock) |
| `emails_envoyes`, `journal` | Historique d'envoi et audit — jamais écrits depuis l'application |

## Vues

| Vue | Donne |
|---|---|
| `v_stock_produits` | Stock, valeur, `prix_inconnu`, dépassement de seuil |
| `v_interventions_cout` | matériel + prestataire + divers, `articles_sans_prix`, `cout_incomplet` |
| `v_cout_prestataire` | Part de facture revenant à chaque intervention |
| `v_recap_interventions` | Les deux avis côte à côte + `refusee_par_gouvernante` |
| `v_factures_rapprochement` | Interventions candidates pour une facture (même prestataire, même date) |
| `v_stock_bouteilles` | Réserve / chambre / chez clients / parc total / sous seuil |
| `v_bouteilles_par_emplacement` | Théorique vs réel, chambre par chambre |
| `v_incidents_bouteille` | Dossiers avec montant retenu ou théorique, et caractère facturable |
| `v_reappro_necessaire` | Articles sous seuil, produits et bouteilles, groupés par fournisseur |

Toutes sont en `security_invoker = on` : elles appliquent les droits de l'appelant, et ne peuvent donc
pas servir de contournement aux règles de sécurité.

## Fonctions

| Fonction | Rôle |
|---|---|
| `fn_rechercher_catalogue(terme)` | Recherche du catalogue par libellé ou mot-clé. Ne lève jamais d'erreur de syntaxe quel que soit le texte saisi |
| `fn_redoter_emplacement(...)` | Re-dote une chambre depuis la réserve, hors incident |
| `fn_preparer_demandes_devis(...)` | Prépare **une** demande par fournisseur, sans dupliquer une demande en cours |

## Pourquoi un registre de déplacements pour les bouteilles

L'ancienne formule `Entrées − Remplacements − Pertes` retirait deux bouteilles du parc pour un seul
incident, et traitait tout emport comme définitif. Ici, chaque mouvement dit `de_lieu → vers_lieu`, et la
vue `v_bouteilles_positions` l'éclate en deux demi-lignes (`+` à l'arrivée, `−` au départ). Une bouteille
qui passe de la réserve à la chambre change de colonne sans changer le total ; **seule une sortie vers
`hors_parc` diminue le parc**.

La position `chez_client` est ce qui permet de distinguer une bouteille *peut-être* perdue d'une
bouteille *réellement* perdue.

## Règles appliquées par la base, pas par l'interface

- Une sortie de stock ne peut pas être positive, une entrée ne peut pas être négative.
- Une régularisation doit être rattachée à un inventaire.
- Un montant divers exige un motif.
- Un technicien ne peut pas enregistrer une décision de gouvernante.
- Une anomalie hors catalogue ne peut être créée que par un admin.
- Une casse imputée au personnel ne peut pas être facturée au client.
- Une bouteille cassée ne peut pas être « restituée ».
- Un mouvement de bouteille doit être un déplacement réel et cohérent avec son type.
- Les validations et le journal d'audit ne sont ni modifiables ni supprimables depuis l'application.
