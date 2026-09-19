# Mettre l'application en ligne

Trois comptes à créer, tous gratuits, une seule fois. Compter une heure la première fois.

**Aucune étape ne demande de m'envoyer un mot de passe, une clé ou une chaîne de connexion.**
Tout se saisit directement dans Supabase, dans Resend et dans Vercel. Une clé partagée dans une
conversation est une clé à changer.

L'ordre compte : la base d'abord, les fichiers ensuite, l'hébergement en dernier — il a besoin
des adresses des deux autres.

---

## 1. La base de données — Supabase

1. Créer un compte sur **supabase.com**, puis un projet.
   - Région : **Europe (Paris ou Francfort)**, pour que l'application reste rapide depuis l'hôtel.
   - Noter le mot de passe de la base : il n'est affiché qu'une fois.

2. **Récupérer les fichiers à jouer.** Ils ne sont pas dans Supabase : le *SQL Editor* est une
   page blanche, il n'ouvre aucun fichier, on y **colle** du texte. Les fichiers sont dans le
   dépôt GitHub, dossier `donnees/installation/`, sur la branche
   `claude/friendly-allen-lmkxuo` :

   > https://github.com/8c5dymf8ph-cpu/Application-Technique/tree/claude/friendly-allen-lmkxuo/donnees/installation

   Pour chacun : l'ouvrir, cliquer **Raw** en haut à droite, **Ctrl+A** puis **Ctrl+C**
   (Cmd sur Mac). Dans Supabase, *SQL Editor → New query*, coller, **Run**, et attendre
   « Success » avant de passer au suivant.

3. Les exécuter **dans cet ordre** :

| Ordre | Fichier | Contenu | Taille |
|---|---|---|---|
| 1 | `1-schema-et-referentiels.sql` | Tables, vues, règles, sécurité, 70 emplacements, 268 libellés | 143 Ko |
| 2 | `2-anomalies-a.sql` … `-e.sql` | 670 anomalies, 528 interventions, 29 tournées — **cinq morceaux, dans l'ordre des lettres** | ~215 Ko chacun |
| 3 | `3-stock.sql` | 36 produits, 257 mouvements | 163 Ko |
| 4 | `4-bouteilles.sql` | 17 dossiers de bouteille, la livraison du 31/03, le parc constaté | 30 Ko |
| 5 | `5-equipe.sql` | L'orthographe des noms et la liste des intervenants techniques | 2 Ko |

> **Pourquoi les anomalies sont en cinq morceaux.** Le fichier entier fait un méga-octet, et
> l'éditeur du navigateur s'étrangle bien avant. `2-anomalies.sql` reste dans le dossier, entier,
> pour qui passe par un terminal : `psql "<chaîne de connexion>" -f donnees/installation/2-anomalies.sql`
> (la chaîne est dans **Settings → Database → Connection string → URI**).
> **Jouer les morceaux OU le fichier entier, jamais les deux.** Dans les deux cas rien n'est
> inséré en double si on rejoue : un morceau passé deux fois ne fait aucun dégât.

> Ces fichiers sont produits par `outils/preparer_installation.sh` : ils ne s'éditent pas à la
> main, ils se regénèrent après toute modification du schéma.

4. Vérifier dans **Table Editor** que `anomalies` contient bien **670 lignes**. C'est ce qui
   prouve que les cinq morceaux sont tous passés — s'il en manque un, le compte est plus bas.

### Où vont les photos et les factures

Elles ne vivent pas dans la base : elles vivent dans Supabase Storage.

5. **Storage → New bucket**, nom `fichiers`, **privé** (ne pas cocher « Public bucket »).
   L'application lit et écrit avec sa clé de service ; rien n'est accessible sans passer par elle.
6. **Settings → API**, noter deux valeurs pour la partie Vercel, plus bas :
   - **Project URL** (`https://xxxx.supabase.co`)
   - **service_role secret** — la clé longue. Elle contourne les règles de sécurité : elle ne
     doit figurer que dans Vercel, jamais dans le code, jamais dans un message.

> Sans ces deux valeurs, l'application écrit les fichiers sur le disque du serveur. En ligne, ce
> disque repart à zéro à chaque déploiement : **les photos seraient perdues**. L'écran
> `/administration` affiche un avertissement rouge tant qu'elles manquent.

---

## 2. Les mails — Resend

1. Créer un compte sur **resend.com**. L'offre gratuite donne 100 messages par jour et 3 000 par
   mois ; l'hôtel en enverra quelques-uns.
2. **API Keys → Create**, copier la clé. Elle se saisit dans Vercel à l'étape suivante.
3. Pour que les messages partent d'une adresse de l'hôtel, ajouter le domaine dans **Domains** et
   poser les enregistrements DNS demandés. Sans cette étape, l'expéditeur reste
   `onboarding@resend.dev`, ce qui suffit pour essayer.

La file d'attente se vide toute seule **toutes les quinze minutes**. L'écran `/administration`
montre ce qui attend, ce qui est parti, ce qui a échoué — et permet de déclencher un passage sans
attendre.

---

## 3. L'hébergement — Vercel

1. Créer un compte sur **vercel.com** en se connectant avec GitHub.
2. **Add New → Project**, choisir le dépôt `Application-Technique`, branche
   `claude/friendly-allen-lmkxuo`.
3. Avant de déployer, ouvrir **Environment Variables** et ajouter :

| Nom | Valeur | Si elle manque |
|---|---|---|
| `DATABASE_URL` | Supabase → Settings → Database → **Connection pooling**, mode *Transaction* | L'application ne démarre pas |
| `SUPABASE_URL` | Supabase → Settings → API → **Project URL** | Les photos sont écrites sur un disque éphémère et perdues au déploiement suivant |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase → Settings → API → **service_role secret** | idem |
| `SUPABASE_BUCKET` | `fichiers` | Vaut `fichiers` par défaut — à ne renseigner que si le seau porte un autre nom |
| `RESEND_API_KEY` | Resend → API Keys | Rien ne part. Les messages s'accumulent dans la file sans se perdre |
| `MAIL_EXPEDITEUR` | `Parisianer <technique@contacthotelparisianer.com>`, ou `onboarding@resend.dev` pour essayer | L'expéditeur par défaut de Resend est employé |
| `CRON_SECRET` | une longue chaîne au hasard, que vous inventez | `/api/envoi` refuse tout appel : la file ne se vide plus automatiquement |

   Prendre bien la chaîne du *pooling* et non la connexion directe : Vercel ouvre beaucoup de
   connexions courtes, et la connexion directe les épuiserait.

4. **Deploy**. Au bout de deux minutes, une adresse en `.vercel.app` s'affiche.

---

## 4. Vérifier, dans cet ordre

Sur l'adresse `.vercel.app`, connecté en **Miguel** :

1. **`/administration`** — aucun bandeau rouge ni ambre. S'il y en a un, une variable manque.
2. **`/stock`** — 36 produits, la valeur du stock affichée.
3. **Ouvrir un produit, appuyer sur la vignette, ajouter une photo.** Recharger la page : la
   photo doit être là. C'est le test du dépôt de fichiers, et il ne se fait qu'en ligne.
4. **`/bouteilles`** — le parc, puis déclarer une perte de test dans une chambre.
5. **`/administration`** — le message doit apparaître dans la file, puis partir au passage
   suivant (ou tout de suite avec « Envoyer maintenant »).
6. Supprimer le dossier de test : `/bouteilles/dossiers`, ouvrir le dossier, « Perte sèche ».

## 5. Sur le téléphone

Ouvrir l'adresse dans Safari ou Chrome, puis **Partager → Sur l'écran d'accueil**.
L'application s'ouvre ensuite en plein écran, sans barre de navigateur.

---

## Ce qui reste à faire ensuite

- **Un nom de domaine** — `technique.contacthotelparisianer.com` par exemple, à brancher dans
  Vercel. Sans cela, l'adresse en `.vercel.app` fonctionne mais retient mal.
- **La connexion Microsoft** — pour l'instant l'application demande seulement de choisir un
  profil. Tant que l'adresse n'est pas connue au-dehors l'enjeu est faible ; il devient réel dès
  qu'elle l'est.
- **Les photos et les fournisseurs** — 32 produits sur 36 n'ont pas de photo, et aucun n'a de
  fournisseur. Ce sont des saisies, pas du développement : elles se font dans l'application, au
  fil de l'eau.
- **Les 15 chambres à dotation incomplète** — le rattrapage des remplacements non saisis dans
  l'ancienne application, puis un inventaire pour trancher.

---

## En cas de pépin

| Symptôme | Cause la plus probable |
|---|---|
| Page blanche, « A server error occurred » | `DATABASE_URL` absente ou mauvaise. Vercel → Deployments → Logs |
| Les photos disparaissent après un déploiement | `SUPABASE_URL` ou `SUPABASE_SERVICE_ROLE_KEY` manquante |
| Une photo ne s'enregistre pas | Le seau `fichiers` n'existe pas, ou porte un autre nom |
| Rien ne part en mail | `RESEND_API_KEY` absente — l'écran `/administration` le dit |
| Les mails partent mais tombent en spam | Le domaine n'est pas vérifié chez Resend |
| « non autorisé » sur `/api/envoi` | `CRON_SECRET` absente |

Rien de tout cela ne perd de données : la base garde tout, et la file de messages repart au
passage suivant.
