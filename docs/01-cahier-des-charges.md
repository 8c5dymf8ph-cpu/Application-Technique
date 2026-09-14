# Application Technique — Hôtel Parisianer
## Cahier des charges de la refonte

> Remplace l'application Power Apps Canvas décrite dans `script_nouveau_chat_v2.docx` (mars 2026).
> Objectif : une application web installable, utilisable sur n'importe quel téléphone et sur ordinateur,
> sur laquelle on peut ajouter des fonctionnalités sans se battre contre l'outil.

---

## 1. Décisions structurantes (validées)

| Sujet | Décision | Conséquence |
|---|---|---|
| Base de données | **PostgreSQL via Supabase** | Vraies relations, calculs de stock fiables, export CSV/Excel à tout moment |
| Connexion | **SSO Microsoft 365** (Entra ID) | Pas de mot de passe à gérer, comptes existants de l'hôtel |
| Réseau | **Tolérant aux coupures** | Les saisies partent en file d'attente et se renvoient seules ; indicateur « non synchronisé » |
| Périmètre V1 | **3 modules d'un coup** | Interventions + Stock matériel + Bouteilles Purezza |
| Historique | **Les 739 lignes sont reprises** | Historique complet consultable par chambre |
| SharePoint | **Coupé après migration** | Listes gelées en lecture seule comme archive ; l'app devient l'unique source de vérité |
| Budget | **0 €/mois** | Offres gratuites ; le passage en payant sera un changement de formule, sans reprise de code |

## 2. Rôles

| Rôle | Peut faire |
|---|---|
| **Technicien** (Miguel, Serafino) | Déclarer une anomalie, la prendre en charge, sortir du matériel, déclarer « fait », saisir un coût |
| **Gouvernante** (Victoria) | Tout ce qui précède + valider ou refuser une intervention, constater une perte de bouteille, faire les inventaires |
| **Admin** | Référentiels (produits, emplacements, utilisateurs, prestataires), paramétrage des récapitulatifs, export |
| **Lecture** (direction) | Consultation et récapitulatifs, y compris les coûts. Aucune écriture |

## 3. Module Interventions

### 3.1 Cycle de vie d'une anomalie

```
   Déclaration                Prise en charge           Déclaration technicien        Décision gouvernante
        │                            │                           │                            │
   [ A FAIRE ] ──────────────▶ [ EN COURS ] ──────────▶ [ ATTENTE VALIDATION ] ──┬──▶ [ VALIDÉE ]   (fin)
        ▲                                                                        │
        └────────────────────────────────────────────────────────────────────────┘
                     refus de la gouvernante + commentaire (optionnel)
```

**Règle de désaccord (validée) :** la gouvernante décide. Si elle refuse, l'anomalie **repasse en `A FAIRE`**
avec son commentaire. L'avis du technicien n'est **jamais effacé** : le récapitulatif montre explicitement
« déclarée faite par X le JJ/MM — **non validée par la gouvernante** le JJ/MM ».

### 3.2 Traçabilité des deux validations

Chaque intervention porte une ligne de validation par acteur, conservée à vie :

| Acteur | Décision | Qui | Quand | Commentaire |
|---|---|---|---|---|
| Technicien | `fait` / `non_fait` | Miguel | 12/09 14:20 | « joint changé » |
| Gouvernante | `validee` / `refusee` | Victoria | 12/09 18:05 | « fuite toujours présente » |

Une anomalie refusée puis refaite accumule les lignes : le nombre d'allers-retours est visible.

### 3.3 Coût d'une intervention (nouveau)

```
coût total = coût matériel (calculé)  +  coût prestataire (saisi)  +  montant libre (saisi)
```

- **Coût matériel** : somme automatique des sorties de stock rattachées à l'intervention
  × le prix unitaire du produit. Aucune saisie supplémentaire pour le technicien.
- **Coût prestataire** : entreprise + n° de devis/facture + montant + pièce jointe (PDF/photo).
- **Montant libre** : champ ouvert avec motif obligatoire, pour tout ce qui n'entre pas dans les deux autres.

Les coûts ne sont visibles que par les rôles Gouvernante, Admin et Lecture.

## 4. Module Stock matériel

**Principe : repartir d'une base saine.** Plus de `Stock_Initial` figé qui dérive.

```
stock d'un produit = Σ (entrées) − Σ (sorties) ± Σ (régularisations d'inventaire)
```

- Un **comptage physique initial** à la mise en service crée la première ligne de mouvement de chaque produit.
- Toute sortie est rattachée à une intervention et à un emplacement — on sait donc ce qui a été consommé où.
- Un **inventaire** compare le théorique au compté et génère une ligne de **régularisation** signée,
  datée, nominative. Le stock ne « saute » jamais sans trace.
- Alerte visuelle quand `stock <= seuil d'alerte`.

## 5. Module Bouteilles Purezza

### 5.1 Ce qui était faux dans l'application actuelle

La formule `Entrées − Remplacements − Pertes` déduisait **deux fois** la même bouteille : une fois au titre
de la perte, une fois au titre de la bouteille sortie de réserve pour re-doter la chambre. L'inventaire ne
pouvait donc que dériver.

### 5.2 Modèle corrigé

Une bouteille n'est pas consommée : **elle circule**. On suit donc des *positions*, pas des soustractions.

```
        livraison                 dotation                   perte / casse
  HORS PARC ────────▶ RÉSERVE ────────────▶ CHAMBRE ────────────────────────▶ HORS PARC
                         ▲                     │
                         └─────────────────────┘
                                 retour
```

- Chaque chambre a une dotation permanente de **1 filtrée 🔵 + 1 pétillante 🔴**.
- **Seule la perte ou la casse déclarée** fait sortir une bouteille du parc. Une bouteille rendue et non
  déclarée ne bouge pas : c'est voulu, le stock reflète ce qui a été constaté.
- La re-dotation de la chambre est un **déplacement** réserve → chambre, **pas une seconde déduction**.

```
parc total     = Σ livraisons − Σ pertes
stock réserve  = ce qui est en réserve, à l'instant T
en chambre     = ce qui est dans les chambres, à l'instant T
écart inventaire = compté − théorique   → génère une régularisation tracée
```

### 5.3 Incident et facturation

Un incident de bouteille enregistre : la chambre, le type, la cause (client perte / client casse /
casse personnel / inconnu), qui l'a constaté et quand. Il génère **une seule** sortie de parc.

La facturation au client (17,50 €) n'est **pas automatique** : le dossier est *transmis* à la
réception/direction, qui tranche.

```
[ À TRANSMETTRE ] ──▶ [ TRANSMIS ] ──┬──▶ [ FACTURÉ ]      ──▶ [ CLOS ]
                                     └──▶ [ NON FACTURÉ ]  ──▶ [ CLOS ]
```

La casse par le personnel n'est pas facturée mais reste valorisée (8 € prix d'achat) pour le suivi direction.

## 6. Récapitulatifs

**Deux canaux, validés :**

1. **Écran de consultation** dans l'application, avec filtres période / étage / chambre / technicien /
   statut / validé ou non, et les totaux de coûts affichés.
2. **Email automatique** selon une fréquence paramétrable (quotidien, hebdomadaire, mensuel),
   vers une liste de destinataires définie par l'admin.

Contenu d'un récapitulatif d'intervention :

| Chambre | Anomalie | Technicien | Déclaré fait le | Gouvernante | Validé le | Matériel | Coût |
|---|---|---|---|---|---|---|---|
| 32 | Fuite lavabo | Miguel | 12/09 | Victoria | 12/09 | 1 joint, 1 flexible | 18,40 € |
| 14 | Volet bloqué | Serafino | 12/09 | **Refusé** | 12/09 | — | 0,00 € |

## 7. Architecture technique

| Couche | Choix | Pourquoi |
|---|---|---|
| Interface | **Next.js + TypeScript + Tailwind** | Une seule base de code pour téléphone et ordinateur, mise en page adaptative |
| Application mobile | **PWA installable** | S'ajoute à l'écran d'accueil iOS/Android, plein écran, sans passer par un store |
| Base de données | **Supabase (PostgreSQL)** | Relations, vues de calcul, sécurité par ligne, export natif |
| Connexion | **Supabase Auth + Entra ID** | SSO Microsoft 365 de l'hôtel |
| Fichiers | **Supabase Storage** | Photos produits, photos d'anomalies, factures prestataires |
| Emails | **Resend** (3 000/mois gratuits) | Récapitulatifs automatiques |
| Planification | **pg_cron** dans Supabase | Déclenche les envois ; maintient aussi la base active |
| Hébergement | **Vercel** (offre gratuite) | Déploiement automatique à chaque modification |

### Tolérance aux coupures réseau

Les saisies (déclaration d'anomalie, sortie de matériel, comptage d'inventaire) sont écrites dans une file
d'attente locale avant d'être envoyées. En cas de coupure, l'écran affiche un bandeau « X saisies en
attente » et le renvoi se fait automatiquement au retour du réseau.

## 8. Migration des données

| Liste SharePoint | Destination | Volume |
|---|---|---|
| `TEST Tech 3` | `anomalies` + `interventions` + `validations` | 739 lignes |
| `RecapInterventions` | fusionné dans `interventions` (dédoublonné sur `SharePointId`) | — |
| `Produits` | `produits` (+ photos vers Storage) | 34 |
| `MouvementsStock` | `mouvements_stock` | — |
| `Bouteilles_Purezza` | `incidents_bouteille` + `mouvements_bouteilles` (**recalculés** selon le modèle corrigé) | — |

Les listes SharePoint sont ensuite passées en lecture seule et conservées comme archive.
