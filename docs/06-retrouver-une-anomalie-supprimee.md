# Retrouver une anomalie supprimée

Une anomalie supprimée **avant** que le journal existe (migration 0021) ne laisse rien derrière
elle : la ligne est partie, et la base ne sait même plus qu'elle a existé. Mais l'export
« TEST Tech 3 » la porte toujours, et c'est lui qui permet de la remettre.

**Aucune étape ne demande d'envoyer un mot de passe, une clé ou une chaîne de connexion.** Tout
se fait dans l'éditeur SQL de Supabase, depuis un ordinateur.

Compter dix minutes. Rien n'est perdu si on s'arrête au milieu : le premier fichier ne modifie
rien du tout, et le second passe entièrement ou pas du tout.

---

## Ce qui peut revenir, et ce qui ne peut pas

| | |
|---|---|
| ✅ L'anomalie | son lieu, son libellé, son état, sa date, qui l'a constatée |
| ✅ Son rattachement au catalogue | sans lui, le comptage des récurrences perdrait la ligne |
| ✅ Son métier | plomberie, électricité… |
| ✅ Son commentaire d'origine | celui du tableau, remis au fil |
| ✅ Son intervention et les deux avis | qui l'a faite, quel jour, qui a vérifié |
| ✅ Son passage | retrouvé ou recréé, à la bonne date |
| ✅ Le matériel sorti | **raccroché**, jamais ressorti une seconde fois |
| ❌ Les photos | le tableau ne les a jamais connues |
| ❌ Les mots écrits dans l'application | idem — ils n'existaient qu'en base |

Et si l'anomalie avait été déclarée **directement dans l'application** (donc absente du tableau),
elle n'est pas récupérable : le tableau ne la porte pas. Vous étiez sur l'écran d'historique
côté gouvernante, devant une ancienne ligne — c'est donc presque sûrement une ligne du tableau.

---

## 1. Ouvrir l'éditeur SQL de Supabase

1. Aller sur **supabase.com**, se connecter, ouvrir le projet de l'hôtel.
2. Dans la colonne de gauche, **SQL Editor** (l'icône `>_`).
3. **New query** (ou « + »).

C'est le même endroit que pour l'installation. Il n'y a rien à installer.

---

## 2. Regarder ce qui manque — ce fichier ne modifie rien

Il ne fait que lire, et il finit par `rollback` : même si on le joue trois fois, rien ne bouge.

1. Ouvrir dans GitHub :
   **`donnees/recuperation/1_ce_qui_manque.sql`**
2. Appuyer sur le bouton **« Copy raw file »** (l'icône de deux feuilles, en haut à droite du
   fichier). Ne pas sélectionner à la souris : le fichier fait 188 Ko, on en oublierait un bout.
3. Coller dans l'éditeur SQL de Supabase.
4. **Run** (ou Ctrl + Entrée).

Le résultat qui s'affiche est un tableau comme celui-ci :

```
 n° d'origine | lieu | libellé                   | déclarée le | statut  | faite le   | par
--------------+------+---------------------------+-------------+---------+------------+--------
         1036 | 14   | changement du séche cheveux | 2026-05-03 | validee | 2026-05-03 | Miguel
```

**Chaque ligne est une anomalie que le tableau porte et que la base n'a plus.**

- **Une seule ligne** → c'est elle. Notez son **n° d'origine**.
- **Plusieurs lignes** → la vôtre est celle que vous reconnaissez : la chambre, le libellé, la
  date. Les autres sont sans doute des lignes ajoutées au tableau depuis le dernier import —
  les remettre toutes ne fait de mal à personne, elles ont leur place dans la base.
- **Aucune ligne** → l'anomalie ne venait pas du tableau : elle a été déclarée dans
  l'application, et elle n'est pas récupérable. Arrêtez-vous là.

> Supabase n'affiche que le **dernier** résultat. Le fichier en produit deux : celui-ci en
> dernier, et juste avant l'inverse (les anomalies de la base que le tableau ne porte plus).
> Pour voir celui-là, faites défiler le fichier jusqu'au premier `select` et jouez-le seul.

---

## 3. Les remettre

1. Ouvrir dans GitHub :
   **`donnees/recuperation/2_les_remettre.sql`**
2. **Copy raw file**, coller dans une **nouvelle** requête Supabase.
3. **Run**.

Le résultat affiché dit ce qui a été remis :

```
 n° d'origine | lieu | libellé | statut | déclarée le | faite le | par | passage | mots au fil | sorties de stock
```

Vérifiez que la ligne attendue y est, puis **ouvrez l'application** : l'anomalie est de retour
dans l'historique de sa chambre, avec son passage.

### Pour n'en remettre qu'une seule

Si la liste en avait plusieurs et que vous ne voulez que la vôtre, cherchez dans le fichier ces
quatre lignes (vers la ligne 718) :

```sql
create temporary table disparues on commit drop as
select t.* from tableau t
 where not exists (select 1 from anomalies a
        where a.sharepoint_id = t.sharepoint_id);
```

et remplacez le `;` de la dernière ligne par une condition portant votre numéro :

```sql
create temporary table disparues on commit drop as
select t.* from tableau t
 where not exists (select 1 from anomalies a
        where a.sharepoint_id = t.sharepoint_id)
   and t.sharepoint_id = 1036;
```

Tout le reste du fichier suit cette table : rien d'autre à modifier.

---

## Pourquoi le matériel ne ressort pas deux fois

Supprimer une anomalie ne rend pas ce qu'elle a sorti : le mouvement de stock **reste en
place**, seulement détaché — la pièce avait bien quitté l'étagère, et c'est la règle. Le script
le **raccroche** à l'intervention rendue, il n'en crée pas un second.

Le rapprochement se fait sur le **produit** et le **lieu**, et il accepte les **deux lectures de
la date** : la base porte parfois encore l'ancienne (03/05) là où le tableau nettoyé dit 05/03 —
c'est le jour et le mois inversés de l'ancien export, 59 jours d'écart. Une simple égalité de
dates aurait raté le rapprochement et sorti la pièce une deuxième fois.

Quand une date diffère, le fichier l'affiche dans un petit tableau « à relire » : le
rapprochement est probable, il n'est pas certain.

*Mesuré sur une copie de la base de l'hôtel : stock à 2 avant la suppression, 2 après la
restauration, huit mouvements et pas neuf.*

---

## Si quelque chose bloque

**« syntax error at or near "begin" » ou « commit » refusé** — l'éditeur enveloppe déjà tout
dans une transaction. Supprimez la ligne `begin;` du début et la ligne `commit;` de la fin, puis
rejouez. Pour le fichier 1 c'est sans risque : il ne contient que des lectures.

**L'éditeur rame ou ne répond plus** — les fichiers font près de 200 Ko. Laissez-lui dix
secondes ; si rien ne vient, rechargez la page et recollez.

**« relation "anomalies_supprimees" does not exist » ou une autre table inconnue** — la base
n'est pas à jour. Ouvrez `/administration` → **État de l'application** → **Mettre la base à
jour**, puis recommencez.

**Le résultat est vide alors que vous attendiez une ligne** — relisez l'étape 2 : si la liste
était vide là aussi, l'anomalie ne venait pas du tableau.

---

## Pour que cela n'arrive plus

La migration 0021 pose le journal : depuis qu'elle est jouée, toute suppression est copiée avant
de partir — le lieu, le libellé, qui avait constaté, et combien de photos, de commentaires et
d'interventions s'en vont avec elle. On le lit dans `/administration` → **Ce qui a été
supprimé**.

Et sur l'historique d'un lieu, la poubelle a été remplacée par un **crayon** : ce qu'on veut sur
une ancienne ligne, c'est corriger, pas effacer. Supprimer reste possible depuis la fiche, en
deux temps, et l'écran nomme l'anomalie avant de le proposer.

---

## Régénérer les deux fichiers

Ils sont produits à partir de l'export. Si l'hôtel fournit un nouveau « TEST Tech 3 » :

```bash
python3 outils/retrouver_les_anomalies_disparues.py manque \
  > donnees/recuperation/1_ce_qui_manque.sql
python3 outils/retrouver_les_anomalies_disparues.py remettre \
  > donnees/recuperation/2_les_remettre.sql
```

Le script ne touche qu'à l'**absence** : une anomalie que la base possède déjà n'est jamais
modifiée, et rien de ce que l'application a produit depuis l'import — photos, fil, dossiers
bouteille, stock, factures — n'est lu ni touché.
