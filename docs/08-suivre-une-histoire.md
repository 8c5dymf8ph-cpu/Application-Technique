# Suivre une histoire : le modèle

Note de conception. **Rien n'est construit.** Elle fixe le vocabulaire, le périmètre, et
surtout ce qu'on ne fera pas.

---

## 1. Ce que les données disent

L'épisode 2024 est complet dans l'export, et il est **absent de la base** : l'import coupe
l'histoire au 1er janvier 2025 (`DEBUT` dans `importer_anomalies.py`). **87 lignes de 2024
n'ont jamais été importées, dont 47 sur les punaises** — plus de la moitié du sujet.

Reconstitué depuis l'export, l'épisode est exactement le schéma décrit par l'hôtel :

| Date | Lieu | Acte | Résultat |
|---|---|---|---|
| 20/09/2024 | 46 | Un client suspecte la présence de punaises — constaté par Sarah P | — |
| 20/09/2024 | 46 | Vérification à l'œil nu par **Victoria** | **négatif** |
| 11/10/2024 | 42 chambres | Détection canine — **EcoFlair** | **4 positives : 15, 28, 46, 48** |
| 12/10/2024 | 15, 28, 46, 48 | **Traitement chimique** — Rachid | — |
| 21/10/2024 | 15, 28, 46, 48 | **Traitement à froid** — Rachid | — |
| 05/11/2024 | 15, 28, 46, 48 | Contre-visite demandée — EcoFlair | **inconnu** |
| 30/09/2025 | 37 chambres | Détection canine — EcoFlair | **1 positive : 54** |
| 01/10/2025 | 54 | Traitement — Rachid | — |
| — | 54 | *aucune contre-visite* | **inconnu** |

Quatre enseignements, tous vérifiables :

1. **La 46 est le cas d'école.** Vérifiée à l'œil nu le 20/09 : rien. Détectée positive par les
   chiens trois semaines plus tard. C'est précisément la raison d'être de la détection canine,
   et l'application ne relie pas les deux lignes.
2. **Le commentaire est un journal comprimé, réécrit par copier-coller.** Celui du 05/11 contient
   quatre dates et trois actes recopiés depuis celui du 11/10, plus une phrase. À chaque étape on
   recopie tout. C'est la définition d'une chronologie qui n'a pas de place où se mettre.
3. **Aucune des deux histoires n'a de fin.** On ne sait pas si le traitement de 2024 a marché, ni
   si celui de 2025 a été contrôlé. Personne ne peut le dire aujourd'hui.
4. **Une même chambre porte plusieurs lignes pour le même épisode** — la 15 apparaît le 11/10
   deux fois puis le 05/11 — et deux libellés du catalogue portent une **date** et une
   **société** dans leur texte, ce qui tue le comptage des récurrences.

---

## 2. Trois formes, pas une — c'est le point de calibrage

L'ascenseur et les extincteurs ont été cités ensemble. **Ce ne sont pas la même chose**, et les
confondre produirait le mauvais outil.

### A. L'épisode réactif — les punaises
Ouvert par un **déclencheur** (client, prévention, constat du personnel), il enchaîne des actes
dont l'ordre varie, et se ferme quand une vérification revient négative. Il traverse plusieurs
chambres et s'élargit en cours de route. **C'est la seule forme qui manque vraiment.**

### B. L'obligation périodique — extincteurs, désenfumage, contrôle annuel de l'ascenseur, légionelle
Ouverte par le **calendrier**, fermée par un **rapport**, et elle **rouvre toute seule** à la
période suivante. Mesuré : `extincteur`, `désenfumage` → **zéro ligne dans l'export**. Il n'y a
rien à reprendre ; tout est à saisir. Ce qui manque ici n'est pas une chronologie, c'est une
**échéance** et une pièce jointe.

### C. L'équipement qui récidive — l'ascenseur en panne
Les 10 lignes « ascenseur » de l'export sont **5 pannes** (21/05, 29/05, 18/08, 09/09, 11/12/2025)
et 5 spots à changer à côté. Ce ne sont pas des épisodes : ce sont des anomalies ponctuelles
ordinaires, sur un lieu qui s'appelle « Ascenseur ».

> **Et cette forme est déjà traitée.** « Ascenseur en panne » est un libellé du catalogue,
> « Ascenseur » est un lieu : `v_frequence_anomalie_lieu` dit déjà « 5 fois ». Ne rien construire
> pour elle. Le seul manque côté ascenseur relève de la forme **B** — son contrôle annuel.

---

## 3. Le modèle

Trois objets. Un vocabulaire : **suivi**, **portée**, **acte**. (« Dossier » est pris par les
bouteilles ; garder deux mots différents évite de confondre deux écrans.)

### Le suivi
Une histoire, avec sa **nature** (punaises, extincteurs, désenfumage, contrôle ascenseur…), son
**déclencheur** (client, prévention, personnel, réglementaire), sa date d'ouverture, ses
documents propres — le rapport d'EcoFlair n'appartient à aucune chambre.

**Pas de statut stocké.** Il se calcule (§ 4), comme le stock et le parc de bouteilles.

### La portée
Les lieux concernés, **avec la date d'entrée et le motif**. La 46 entre le 20/09 (le client), les
15, 28 et 48 entrent le 11/10 (la détection). Sans la date d'entrée, on ne sait plus quand la
surveillance s'est élargie.

### L'acte
L'unité de la chronologie. Une ligne = un fait daté.

- **la date** du geste, jamais celle de la saisie ;
- **le type** — vérification interne, détection canine, traitement chimique, traitement à froid,
  contrôle réglementaire, chambre bloquée, remise en service, rapport reçu… Chaque type appartient
  à une nature et porte deux drapeaux : `est_une_verification`, `est_un_traitement` ;
- **qui** — un utilisateur **ou** un prestataire. Les deux existent : EcoFlair détecte, Rachid
  traite. Ne jamais supposer que l'intervenant est une entreprise ;
- **la portée de l'acte** — quelles chambres il a couvertes, **avec un résultat par chambre** :
  `positif` / `negatif` / `non_concluant` ;
- **le lien vers l'existant**, facultatif : `intervention_id` quand l'acte correspond à un passage
  déjà enregistré, `anomalie_id` quand il naît d'une anomalie déclarée ;
- commentaire et photos.

> **Le résultat par chambre remplace les 38 anomalies de balayage.** La campagne du 11/10 devient
> **un** acte, une date, une ligne dans la chronologie, et 42 résultats. La preuve
> « on a vérifié la 27 le 11/10, il n'y avait rien » existe toujours — elle est sur l'acte, pas
> dans 42 historiques de chambre.

---

## 4. La règle de clôture — calculée, jamais stockée

> **Une chambre est réglée quand il existe, pour elle, une vérification NÉGATIVE postérieure à
> tous ses traitements. Un suivi est réglé quand toutes les chambres de sa portée le sont.**

Elle suffit à décrire toute la boucle sans jamais l'imposer :

- vérification positive → pas réglé ;
- traitement postérieur à la dernière vérification négative → pas réglé : il faut re-contrôler ;
- chambre ajoutée mais jamais vérifiée → pas réglée.

Trois états en découlent, et le deuxième est celui qui manquait :

| État | Ce qu'il veut dire |
|---|---|
| **en cours** | au moins une chambre positive, ou jamais vérifiée |
| **à contrôler** | tout a été traité, **aucune vérification depuis** — il faut rappeler la société |
| **réglé** | toutes négatives, après traitement |

« À contrôler » est la valeur du dispositif : aujourd'hui, **personne ne sait que la contre-visite
du 05/11/2024 attend une réponse depuis deux ans**, ni que la 54 n'a jamais été recontrôlée depuis
octobre 2025.

L'ordre des traitements n'entre nulle part dans la règle — chimique puis froid, l'inverse, ou les
deux : ce sont trois actes, et seule leur date compte.

### Pour la forme B
Même objet, autre règle : le suivi se ferme quand un acte `contrôle réglementaire` porte son
rapport, et `nature.periodicite_mois` fixe la prochaine échéance. C'est **un champ**, pas un
moteur de conformité.

---

## 5. Les conséquences

**Chambre bloquée** — deux actes, `chambre bloquée` et `remise en service`. La durée se calcule,
la chronologie les porte comme le reste, et aucune table de plus.

> **Ne pas inventer le coût.** L'application ne connaît pas le prix d'une nuit. Elle dit
> « 34 bloquée 6 nuits », pas « 780 € perdus ». Poser un tarif moyen est une décision séparée, à
> prendre en la voyant.

**Surfacturation** — un drapeau `hors_contrat` et un motif libre sur le rattachement d'une facture
à un acte. Répond à « combien nous a-t-on facturé qui aurait dû être inclus ». **Ne pas modéliser
les contrats fournisseurs** : savoir si une prestation était couverte est un jugement humain, pas
une règle qu'une base peut tenir.

Le coût, lui, ne bouge pas de place : il reste sur l'intervention et la facture. Un acte pointe
vers elles, il ne les recopie pas.

---

## 6. Les chambres adjacentes — proposer, jamais décider

Quand une chambre est positive, l'écran **propose** les voisines et laisse cocher.

`emplacements` porte `etage_id` et `ordre` : les voisines de palier se déduisent (ordre ± 1).
**Mais ce n'est pas la vérité du bâtiment** — une chambre peut être en face, ou juste au-dessus,
et les punaises passent aussi par le plancher. L'écran propose donc les voisines de palier
**et laisse cocher n'importe quel autre lieu**, sans rien ajouter tout seul.

Et **l'élargissement est daté** : une chambre entre dans la portée à une date, avec un motif.

---

## 7. Ce qu'on ne construit pas

1. **Pas de machine à états.** L'ordre varie, parfois les deux traitements, parfois une
   contre-visite en plus. On enregistre ce qui a été fait ; on ne dicte pas la suite.
2. **Pas d'ajout automatique des chambres adjacentes.**
3. **Pas de coût de chambre bloquée inventé.**
4. **Pas de modèle de contrat fournisseur.** Un drapeau et un motif.
5. **Pas de duplication.** Un acte pointe vers l'intervention existante. Matériel, passage,
   facture restent où ils sont — sinon le coût d'un passage change selon l'écran qui le regarde.
6. **Pas de suppression des anomalies existantes.** Les 85 lignes restent ; on les **rattache**.
7. **Rien pour l'ascenseur en panne** : le comptage des récurrences le fait déjà.

---

## 8. Ce qui est indépendant, et peut se faire tout de suite

**Reprendre 2024.** Le seuil du 1er janvier 2025 existait pour ne pas faire apparaître deux ans
d'arriéré dans les écrans de travail — bon motif, mais il coûte la moitié de l'histoire. Les
87 lignes peuvent revenir **closes** (`validee` ou `annulee`, à leur vraie date) : elles
n'apparaissent dans aucun écran « à faire », et elles existent pour la chronologie et pour le
comptage des récurrences.

**Nettoyer les deux libellés-événements du catalogue** — ceux qui portent une date et le nom
d'une société. Le libellé redevient « Détection de punaises de lit », la date et la société
deviennent un acte.

Ces deux chantiers ne dépendent pas du modèle ci-dessus et le préparent.

---

## 9. Ce qui reste à décider

1. **Le mot.** « Suivi » ? « Affaire » ? « Épisode » ? Il apparaîtra partout.
2. **Le résultat par chambre** vaut-il d'être saisi pour les 42 chambres d'un balayage, ou
   seulement pour les positives (les autres étant négatives par défaut) ? Le second est plus
   rapide à saisir ; le premier distingue « vérifiée, rien » de « pas vérifiée ».
3. **Qui ouvre un suivi ?** `peutValider`, probablement — c'est une décision d'encadrement.
4. **Une anomalie peut-elle appartenir à deux suivis ?** Une chambre traitée pour punaises en
   2024 et de nouveau en 2025 : deux suivis, deux actes, aucune ambiguïté. Mais une anomalie
   déclarée une fois et rattachée à deux histoires n'a pas de sens — un rattachement unique
   suffit, et c'est plus simple à lire.
5. **L'ampleur.** C'est le plus gros ajout depuis les bouteilles : deux tables de référence,
   quatre tables, un écran de suivi, un écran de saisie d'acte, et un rattachement du passé.
