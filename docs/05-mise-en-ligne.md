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

2. **Récupérer la chaîne de connexion.** Dans Supabase, *Connect* (en haut) →
   **Session pooler** → copier l'URI. Celle-là, et pas la connexion directe : les machines de
   GitHub n'ont pas d'IPv6, la directe ne répondrait pas.

3. **La poser dans GitHub, jamais ailleurs.** Sur le dépôt : *Settings* → *Secrets and variables*
   → *Actions* → **New repository secret**, nom `INSTALL_DATABASE_URL`, valeur la chaîne copiée.
   Elle contient le mot de passe de la base : elle se saisit là et nulle part d'autre — ni dans
   un fichier, ni dans un message.

4. **Lancer l'installation.** Onglet *Actions* → **Installer la base** → *Run workflow* :
   - branche `claude/friendly-allen-lmkxuo`
   - taper `INSTALLER` dans la case de confirmation
   - cocher **« Effacer d'abord la base »** si une installation a déjà été commencée
   - *Run workflow*

   GitHub joue les quatorze fichiers dans l'ordre, sur la machine, et affiche à la fin :

   ```
   anomalies   : 670 sur 670
   produits    : 36 sur 36
   bouteilles  : 17 dossiers sur 17
   emplacements: 70 sur 70
   ```

   Si une étape échoue, rien de la suite ne part : l'ordre est tenu, et le journal dit où.

> **Pourquoi pas l'éditeur SQL de Supabase.** Il faut y coller quatorze fichiers à la main, et il
> lui arrive de rejouer un contenu périmé : on croit coller un fichier, c'est le précédent qui
> part. Le chemin ci-dessus ne colle rien.

### Plus tard : appliquer une évolution du schéma

Quand une modification touche la base, elle arrive comme un fichier de plus dans
`supabase/migrations/`. Onglet *Actions* → **Mettre à jour la base** → *Run workflow*.

Ce workflow **ne touche pas aux données** : il ne joue que les fichiers qui manquent et note ce
qu'il a joué dans `migrations_appliquees`. Le relancer sur une base à jour ne fait rien.

### Si vous préférez coller à la main

Les fichiers restent dans `donnees/installation/`, dans l'ordre donné par `ordre.txt` :

| Ordre | Fichier | Contenu |
|---|---|---|
| — | `0-ou-en-suis-je.sql` | **Ne modifie rien.** Dit où en est l'installation et quel fichier jouer ensuite |
| — | `0-tout-effacer.sql` | **Efface tout, sans rien demander.** Pour reprendre volontairement à zéro |
| 1 | `1-schema-et-referentiels.sql` | Tables, vues, règles, sécurité, 70 emplacements, 268 libellés |
| 2 | `2-anomalies-a.sql` … `-i.sql` | 670 anomalies, 528 interventions, 29 tournées — neuf morceaux |
| 3 | `3-stock-a.sql`, `-b.sql` | 36 produits, 279 mouvements — deux morceaux |
| 4 | `4-bouteilles.sql` | 17 dossiers de bouteille, la livraison du 31/03, le parc constaté |
| 5 | `5-equipe.sql` | L'orthographe des noms et la liste des intervenants techniques |

Les récupérer sur GitHub, dossier `donnees/installation/`, bouton **Raw**, tout sélectionner,
copier. Dans Supabase, **une nouvelle requête par fichier** (*New query*) : un éditeur vide ne
peut pas rejouer le précédent.

**Chaque fichier se nomme dans son résultat.** Après chaque Run, le tableau affiche le nom du
fichier qui vient réellement de tourner :

| Fichier joué | Où ça en est |
|---|---|
| `2-anomalies-b.sql` | 161 anomalies sur 670 |

Si ce n'est pas celui que vous venez de coller, le collage n'a pas pris — recommencez ce
fichier-là. **Rejouer un fichier déjà passé ne casse rien** ; le seul qui refuse est le 1, parce
qu'il efface le schéma avant de le reconstruire. Son message commence par
« RIEN N'A ÉTÉ EFFACÉ » : il s'est arrêté, la base est intacte, il suffit de continuer où
vous en étiez. `0-ou-en-suis-je.sql` le dit.

Supabase demande parfois de confirmer l'exécution : c'est normal pour un script qui crée des
tables, cela ne change rien au résultat.

> `2-anomalies.sql` et `3-stock.sql` restent dans le dossier, entiers, pour qui passe par un
> terminal. **Jouer les morceaux OU l'entier, jamais les deux.**

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

### Vérifier le domaine — ce que ça débloque, et ce que ça ne fait pas

**Recevoir à `fom@hotelparisianer.com` ne demande rien.** Cette boîte existe déjà chez
l'hébergeur de messagerie de l'hôtel et reçoit ce qu'on lui envoie. Rien à faire chez Resend
pour ça.

Ce que la vérification débloque, c'est **d'envoyer AU NOM du domaine**. Tant qu'aucun domaine
n'est vérifié, Resend n'accepte qu'une seule destination : l'adresse du titulaire du compte.
Tout message adressé à quelqu'un d'autre est refusé, avec ce texte, que `/administration`
affiche en toutes lettres :

> *You can only send testing emails to your own email address. To send emails to other
> recipients, please verify a domain at resend.com/domains*

**La marche à suivre.**

1. Resend → **Domains → Add Domain**. Saisir le **nom complet** : `hotelparisianer.com`.
   Pas `hotelparisianer` seul — Resend attend un domaine, pas un mot.
2. Resend affiche alors **trois enregistrements DNS** à poser, et les donne tout faits :
   - un **MX** sur le sous-domaine `send` — il sert aux retours (adresses mortes, refus) ;
   - un **TXT** sur `send` aussi — le SPF, qui dit que Resend a le droit d'envoyer pour vous ;
   - un **TXT** sur `resend._domainkey` — la clé DKIM, qui signe les messages.
3. Les poser chez celui qui héberge le DNS de `hotelparisianer.com` — souvent le registrar
   (OVH, Gandi, Ionos, GoDaddy…), parfois Cloudflare. On y cherche « Zone DNS » ou
   « Enregistrements DNS », et on ajoute les trois lignes en recopiant exactement ce que Resend
   affiche.
   - Si le champ demande un nom **relatif**, écrire `send` et `resend._domainkey` ;
   - s'il demande un nom **complet**, écrire `send.hotelparisianer.com` et
     `resend._domainkey.hotelparisianer.com`.
   - Ne pas toucher aux MX existants du domaine : celui de Resend est sur `send`, il ne
     remplace pas la messagerie de l'hôtel.
4. Revenir sur Resend → **Verify**. Le domaine passe à *Verified* — quelques minutes en
   général, jusqu'à quelques heures si le DNS est lent.
5. Dans Vercel, poser `MAIL_EXPEDITEUR` avec une adresse **de ce domaine** :
   `Hôtel Parisianer <technique@hotelparisianer.com>`. Cette boîte n'a pas besoin d'exister —
   c'est une adresse d'expédition. Redéployer.
6. Ouvrir `/administration` → **Envoyer maintenant**. Les messages en attente repartent.

**En attendant, pour essayer tout de suite** : mettre comme destinataire de l'alerte bouteille
l'adresse du compte Resend lui-même, dans `/administration` → *Destinataires des alertes*. Le
message partira sans rien vérifier, et l'on saura que toute la chaîne fonctionne — il ne
restera qu'à changer le destinataire une fois le domaine en place.

**Un message part dans la seconde qui suit son dépôt** : l'alerte bouteille doit joindre la
réception pendant que le client est peut-être encore là. Une tâche planifiée repasse une fois par
jour pour reprendre ce qui aurait échoué — l'offre gratuite de Vercel n'en accepte pas de plus
fréquente, et un réglage plus rapide ferait échouer le déploiement.

L'écran `/administration` montre ce qui attend, ce qui est parti, ce qui a échoué — et permet de
déclencher un passage sans attendre.

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
| `SUPABASE_SECRET_KEY` | Supabase → **Connect** → *Server* → `SUPABASE_SECRET_KEY` (`sb_secret_…`) | idem |
| `SUPABASE_BUCKET` | `fichiers` | Vaut `fichiers` par défaut — à ne renseigner que si le seau porte un autre nom |
| `RESEND_API_KEY` | Resend → API Keys | Rien ne part. Les messages s'accumulent dans la file sans se perdre |
| `MAIL_EXPEDITEUR` | `Hôtel Parisianer <technique@hotelparisianer.com>` — une adresse d'un domaine **vérifié** chez Resend | L'expéditeur reste `onboarding@resend.dev`, et Resend n'accepte alors que l'adresse du titulaire du compte |
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
| Les photos disparaissent après un déploiement | `SUPABASE_URL` ou `SUPABASE_SECRET_KEY` manquante |
| Une photo ne s'enregistre pas | Le seau `fichiers` n'existe pas, ou porte un autre nom |
| Rien ne part en mail | `RESEND_API_KEY` absente — l'écran `/administration` le dit |
| Les mails partent mais tombent en spam | Le domaine n'est pas vérifié chez Resend |
| « en échec » dans `/administration`, avec *you can only send testing emails…* | Aucun domaine vérifié : Resend n'accepte que l'adresse du titulaire du compte. Voir « Vérifier le domaine » plus haut |
| « non autorisé » sur `/api/envoi` | `CRON_SECRET` absente |

Rien de tout cela ne perd de données : la base garde tout, et la file de messages repart au
passage suivant.
