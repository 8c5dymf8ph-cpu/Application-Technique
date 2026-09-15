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
| `utilisateur_specialites` | Aucune ligne = polyvalent ; sinon l'intervenant ne voit que ces types |
| `prestataires` | Entreprises extérieures qui facturent une journée |
| `fournisseurs` | Fournisseurs de consommables — plusieurs produits peuvent en partager un |
| `catalogue_anomalies` | Libellés déclarables + mots-clés de recherche |

### Interventions
| Table | Rôle |
|---|---|
| `anomalies` | Le problème constaté. `catalogue_id` obligatoire sauf pour un admin. `sharepoint_id` garde le lien avec la ligne d'origine |
| `tournees` | Le lot d'anomalies traité en une fois — l'ancien `InterventionID` |
| `interventions` | Le traitement d'une anomalie, par un technicien interne ou un prestataire |
| `validations` | **Une ligne par avis**, technicien et gouvernante. Jamais écrasées, ni modifiables |
| `photos_anomalie` | Photos de constat et d'après-intervention |
| `factures`, `facture_interventions` | Prestation (une journée de prestataire, rapprochée de N interventions) ou achat (une livraison, rattachée à N entrées de stock) |

### Stock matériel
| Table | Rôle |
|---|---|
| `produits` | Articles. `prix_unitaire` **nullable** = prix inconnu |
| `mouvements_stock` | Quantité **signée** : `+` entrée, `−` sortie, libre pour un ajustement. Un ajustement porte un `motif` ; une entrée peut porter son `prix_unitaire` payé et sa `facture_id` |
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
| `v_stock_produits` | Entrées, sorties, ajustements, stock, valeur, `prix_inconnu`, dépassement de seuil — c'est aussi la fiche produit |
| `v_interventions_cout` | matériel + prestataire + divers, `articles_sans_prix`, `cout_incomplet` |
| `v_cout_prestataire` | Part de facture revenant à chaque intervention |
| `v_recap_interventions` | Les deux avis côte à côte, `non_validee_par_gouvernante`, `en_attente_gouvernante` |
| `v_tournees` | État d'un lot : en attente, validées, à refaire, coût, `prete_pour_recap` |
| `v_fil_commentaires` | Fil chronologique des commentaires d'une anomalie, avec auteur et rôle |
| `v_recurrences_emplacement` | Chambres à problème — `recurrent` à 3 interventions sur 6 mois |
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
| `fn_creer_tournee(...)` | Ouvre une tournée et génère sa référence `INT-<NOM>-<horodatage>-<aléa>` |

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
- Un ajustement de stock porte toujours un motif ; seul le motif « inventaire » exige un inventaire.
- Une facture ne se rattache qu'à une entrée de stock, jamais à une sortie.
- Une facture de prestation vient d'un prestataire, une facture d'achat d'un fournisseur.

## Ce qui disparaît de l'ancien modèle

| Ancien mécanisme | Pourquoi il n'existe plus |
|---|---|
| `Stock_Initial` + `StockActuel` | Le stock est la somme de ses mouvements. Deux sources de vérité, c'était la garantie de la dérive |
| `EstHistorique` | Servait à repartir d'un comptage physique sans perdre l'historique. Un ajustement de motif `inventaire` fait la même chose, en restant lisible |
| Bouton « recalculer le stock » | Il n'y a rien à recalculer |
| `RecapInterventions` (buffer) | Les validations *sont* le registre ; plus besoin d'une liste tampon entre technicien et gouvernante |
| Commentaires empilés dans un champ | Une ligne par avis, avec auteur et date |
