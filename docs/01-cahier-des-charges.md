# Application Technique — Hôtel Parisianer
## Cahier des charges de la refonte

> Remplace l'application Power Apps Canvas décrite dans `script_nouveau_chat_v2.docx` (mars 2026).
> Objectif : une application web installable, utilisable sur n'importe quel téléphone et sur ordinateur,
> sur laquelle on peut ajouter des fonctionnalités sans se battre contre l'outil.

---

## 1. Décisions structurantes (validées)

| Sujet | Décision |
|---|---|
| Base de données | **PostgreSQL via Supabase** — export CSV/Excel à tout moment |
| Connexion | **SSO Microsoft 365** (Entra ID) |
| Réseau | **Tolérant aux coupures** : file d'attente locale, indicateur « non synchronisé » |
| Périmètre V1 | **3 modules d'un coup** : interventions, stock matériel, bouteilles |
| Historique | **Les 739 lignes sont reprises** |
| SharePoint | **Coupé après migration**, listes gelées en archive |
| Budget | **0 €/mois** (Supabase, Vercel et Resend en offre gratuite) |

## 2. Rôles

| Rôle | Peut faire |
|---|---|
| **Gouvernante** (Victoria) | Déclare les anomalies depuis son téléphone **en choisissant dans le catalogue**, valide ou refuse les interventions, signale les incidents de bouteille, saisit les livraisons, fait les inventaires |
| **Technicien** (Miguel, Serafino) | Voit ses anomalies, coche celles qu'il a faites, indique le matériel utilisé. **Ne saisit et ne voit aucun prix** |
| **Admin** | Référentiels, catalogue d'anomalies, factures, paramétrage, export. Seul à pouvoir créer une anomalie hors catalogue, depuis un ordinateur |
| **Lecture** (direction) | Consultation, rapports et coûts. Aucune écriture |

## 3. Module Interventions

### 3.1 Déclaration — catalogue obligatoire sur mobile

La gouvernante déclare depuis son téléphone : elle choisit une **chambre**, puis cherche l'anomalie
**par mots-clés** dans un catalogue fermé (« fuit » → *Fuite lavabo*, *Fuite douche*). Elle ne peut pas
saisir de texte libre.

Ajouter une entrée au catalogue est réservé à l'admin, depuis un ordinateur. Cette règle est appliquée
**dans la base** (politique RLS `creation_depuis_catalogue`), pas seulement dans l'interface : même une
requête directe ne peut pas la contourner.

Le catalogue définitif sera généré à partir des libellés réellement utilisés dans la colonne
`AnomaliesCommentaires` de `TEST Tech 3`, une fois l'export CSV disponible.

### 3.2 Cycle de vie

```
   Déclaration                Prise en charge           Déclaration technicien        Décision gouvernante
        │                            │                           │                            │
   [ A FAIRE ] ──────────────▶ [ EN COURS ] ──────────▶ [ ATTENTE VALIDATION ] ──┬──▶ [ VALIDÉE ]   (fin)
        ▲                                                                        │
        └────────────────────────────────────────────────────────────────────────┘
                     refus de la gouvernante + commentaire (optionnel)
```

**Règle de désaccord :** la gouvernante décide. Si elle refuse, l'anomalie repasse en `A FAIRE` avec son
commentaire. L'avis du technicien n'est **jamais effacé** : le récapitulatif affiche « déclarée faite
par X le JJ/MM — **non validée par la gouvernante** le JJ/MM ».

**Le matériel utilisé reste consommé même en cas de refus.** Un refus ne réintègre rien au stock : le
technicien a bien utilisé la pièce. C'est vérifié par un test.

### 3.3 Photos

Chaque anomalie peut porter des photos : au **constat** (par la gouvernante) et **après** intervention
(par le technicien). Elles sont stockées dans Supabase Storage et consultables dans l'historique de la
chambre.

### 3.4 Coût d'une intervention

```
coût total = matériel (calculé)  +  prestataire (rapproché)  +  divers (saisi)
```

| Composante | Origine | Qui saisit |
|---|---|---|
| **Matériel** | Somme automatique des sorties de stock × prix unitaire | Personne — le technicien coche seulement les articles utilisés |
| **Prestataire** | Rapprochement de facture (§ 3.5) | Admin / gouvernante |
| **Divers** | Montant libre avec motif obligatoire | Gouvernante / admin |

**Prix inconnus.** Certains produits n'ont pas de prix unitaire renseigné. Ils ne sont pas comptés pour
zéro en silence : la vue expose `articles_sans_prix` et `cout_incomplet`, et l'interface affiche
« 13,90 € + 1 article sans prix connu ». Un coût partiel annoncé comme tel vaut mieux qu'un faux total.

### 3.5 Factures de prestataires

Un prestataire ne facture pas une anomalie, il facture **une journée d'intervention**. Le plombier passe
le 17 mai 2026 et envoie une facture de 450 € pour les trois anomalies traitées ce jour-là.

L'écran de rapprochement part de la facture (prestataire + date) et propose **toutes les interventions
de ce prestataire à cette date**. On coche, et le montant se répartit à parts égales — ou on affecte un
montant précis à chaque ligne si la facture le détaille.

## 4. Module Stock matériel

**Principe : repartir d'une base saine.** Plus de `Stock_Initial` figé qui dérive.

```
stock = Σ (entrées) − Σ (sorties) ± Σ (régularisations d'inventaire)
```

- **Comptage physique initial** à la mise en service : c'est la première ligne de mouvement.
- Toute sortie est rattachée à une intervention — on sait ce qui a été consommé où.
- Un **inventaire** compare théorique et compté, et génère une **régularisation** signée et datée.
  Le stock ne saute jamais sans trace.

## 5. Module Bouteilles Purezza

### 5.1 Ce qui était faux

La formule `Entrées − Remplacements − Pertes` déduisait **deux bouteilles** du stock pour un seul
incident : une au titre de la perte, une au titre de la bouteille sortie de réserve pour re-doter la
chambre. L'inventaire ne pouvait que dériver. Elle traitait aussi tout emport comme une perte
définitive, alors qu'un client rend parfois la bouteille.

### 5.2 Modèle corrigé — quatre positions

Une bouteille n'est pas consommée, **elle circule**. On suit des *positions*, pas des soustractions.

```
              livraison            dotation              emport constaté
   HORS PARC ──────────▶ RÉSERVE ──────────▶ CHAMBRE ──────────────────▶ CHEZ LE CLIENT
                            ▲                   ▲                              │
                            │   re-dotation     │                              │
                            └───────────────────┘                    ┌─────────┴─────────┐
                            ▲                                        │                   │
                            │            restitution                 │            facturée ou
                            └────────────────────────────────────────┘            non restituée
                                   (va en RÉSERVE, pas en chambre)                       │
                                                                                         ▼
                                                                                    HORS PARC
```

| Compteur | Sens |
|---|---|
| **En réserve** | Ce qu'il reste pour re-doter une chambre. **C'est le chiffre opérationnel** : c'est lui qui déclenche l'alerte et la demande de devis |
| **En chambre** | Doit toujours valoir 37 de chaque type |
| **Chez les clients** | Emportées, non encore restituées ni facturées — dossiers ouverts |
| **Parc total** | La somme des trois. Sert au contrôle d'inventaire |

### 5.3 Les cas réels, et ce que fait l'application

| Situation | Effet |
|---|---|
| Le client emporte une bouteille, la gouvernante le signale | Chambre → chez le client, **re-dotation automatique** depuis la réserve. **Le parc ne bouge pas** : rien n'est encore perdu. Un mail part vers les adresses paramétrées pour que le client soit contacté |
| Le client la rend | Chez le client → **réserve** (la chambre a déjà été re-dotée). Le parc ne bouge toujours pas |
| Le client ne la rend pas, on la facture | Chez le client → hors parc. **C'est seulement là que le parc diminue** |
| Le client la casse | Sortie immédiate du parc, re-dotation automatique. Facturation soumise à arbitrage |
| Une femme de chambre la casse | Sortie immédiate du parc, re-dotation automatique. **Jamais facturable au client** — refusé par une contrainte en base. Valorisée à 8 € (prix d'achat) pour le suivi direction |

Le cas rare — le client revient avec la bouteille alors que la chambre a déjà été re-dotée — est
précisément ce que gère la position « chez le client » : la bouteille rendue rejoint la réserve.

### 5.4 Facturation

La facturation au client (17,50 €) n'est jamais automatique : le dossier est arbitré.

```
[ SIGNALÉ ] ──▶ [ CLIENT CONTACTÉ ] ──┬──▶ [ RESTITUÉ ]      ──▶ [ CLOS ]
                                      ├──▶ [ FACTURÉ ]       ──▶ [ CLOS ]
                                      └──▶ [ NON FACTURÉ ]   ──▶ [ CLOS ]
```

## 6. Réapprovisionnement automatique

Dès qu'un article passe sous son seuil — produit **ou** bouteille (sur la réserve) — une demande de
devis est préparée et envoyée aux adresses paramétrées.

**Un seul mail par fournisseur.** Si trois produits du même fournisseur tombent le même jour, ils
arrivent dans **une seule** demande de devis, avec les trois lignes. Une demande déjà en cours pour ce
fournisseur n'est jamais dupliquée. C'est vérifié par un test.

## 7. Récapitulatifs et écran Documents

**Récapitulatifs :** écran de consultation avec filtres (période, étage, chambre, intervenant, statut,
validé ou non) **et** envoi automatique par email selon une fréquence paramétrable.

Contenu :

| Chambre | Anomalie | Intervenant | Déclaré fait | Gouvernante | Matériel | Coût |
|---|---|---|---|---|---|---|
| 32 | Fuite lavabo | Miguel | 12/09 | Victoria ✓ 12/09 | 1 joint, 1 flexible | 13,90 € |
| 14 | Volet bloqué | Serafino | 12/09 | **Refusé** 12/09 | — | 0,00 € |

**Écran Documents** — proposition à valider :

1. **Factures** — toutes les factures de prestataires, filtrables par entreprise et par période, avec le
   PDF consultable et les interventions rapprochées.
2. **Rapport mensuel** — coût total du mois, réparti par type d'intervention, par étage et par
   prestataire ; comparaison avec les mois précédents ; pertes de bouteilles valorisées.
3. **Devis et commandes** — historique des demandes de devis envoyées.
4. **Fiches techniques** — notices et documentation des équipements, par emplacement.

## 8. Architecture technique

| Couche | Choix |
|---|---|
| Interface | Next.js + TypeScript + Tailwind, mise en page adaptative |
| Mobile | PWA installable sur l'écran d'accueil iOS/Android |
| Base | Supabase (PostgreSQL), sécurité par ligne |
| Connexion | Supabase Auth + Entra ID |
| Fichiers | Supabase Storage (photos d'anomalies, photos produits, factures PDF) |
| Emails | Resend (3 000/mois gratuits) |
| Planification | pg_cron dans Supabase |
| Hébergement | Vercel (offre gratuite) |

### Tolérance aux coupures réseau

Les saisies sont écrites dans une file d'attente locale avant envoi. En cas de coupure, un bandeau
« X saisies en attente » s'affiche et le renvoi est automatique au retour du réseau.

### Une réserve sur la confidentialité des prix

Le technicien **ne saisit aucun prix**, c'est garanti par la conception. En revanche, le fait qu'il ne
les **voie** pas est assuré par l'interface (ses écrans n'affichent pas de prix), pas par la base : la
sécurité PostgreSQL s'applique aux lignes, pas aux colonnes, et tous les utilisateurs partagent le même
rôle technique. Pour une garantie au niveau de la base, il faudrait isoler les prix dans une table
dédiée protégée par sa propre règle — faisable, à décider si l'enjeu le justifie.

## 9. Migration des données

| Liste SharePoint | Destination | Volume |
|---|---|---|
| `TEST Tech 3` | `anomalies` + `interventions` + `validations` + `catalogue_anomalies` | 739 lignes |
| `RecapInterventions` | fusionné dans `interventions` (dédoublonné sur `SharePointId`) | — |
| `Produits` | `produits` (+ photos vers Storage) | 34 |
| `MouvementsStock` | `mouvements_stock` | — |
| `Bouteilles_Purezza` | `incidents_bouteille` + `mouvements_bouteilles` (**recalculés**) | — |
