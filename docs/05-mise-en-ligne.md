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

### Ce qu'est un enregistrement DNS, en deux phrases

Le DNS d'un domaine, c'est son annuaire public : il dit où se trouve le site, où va le
courrier, et qui a le droit d'envoyer au nom du domaine. Il est tenu par **un seul**
prestataire — le registrar chez qui `hotelparisianer.com` a été acheté (OVH, Gandi, Ionos,
GoDaddy…), ou Cloudflare, ou Microsoft si le domaine y a été délégué.

**Rien de ce qui s'y trouve n'est secret** : n'importe qui sur Internet peut lire le DNS d'un
domaine. Ce n'est pas comme une clé d'API. Vous pouvez donc recopier sans crainte ce que Resend
affiche, ou me le montrer si un doute subsiste.

Ce n'est pas Microsoft 365 qui décide : **M365 gère les boîtes**, le DNS dit seulement au monde
où les trouver. Ajouter des lignes pour Resend ne touche pas aux boîtes de l'hôtel.

### La marche à suivre, avec Microsoft 365

**Utiliser un sous-domaine, pas le domaine principal.** C'est ce que Resend recommande, et ici
c'est surtout ce qui met la messagerie de l'hôtel complètement à l'abri : les lignes posées ne
croisent jamais celles de Microsoft.

1. Resend → **Domains → Add Domain**. Saisir **`notifications.hotelparisianer.com`** — un
   sous-domaine qui n'existe pas encore et ne sert qu'à ça. (Et non `hotelparisianer` seul :
   Resend attend un domaine entier.) **Choisir la région `eu-west-1` (Irlande)** : les messages
   restent en Europe, et c'est elle qui décide de l'adresse du serveur MX ci-dessous.
2. Resend affiche **trois lignes à ajouter**, toutes prêtes. Elles ressemblent à ceci — les
   valeurs exactes sont celles que VOTRE écran affiche, pas celles-ci :

   | Type | Nom | Valeur |
   |---|---|---|
   | `MX` | `send.notifications` | `feedback-smtp.eu-west-1.amazonses.com` (priorité 10) |
   | `TXT` | `send.notifications` | `v=spf1 include:amazonses.com ~all` |
   | `TXT` | `resend._domainkey.notifications` | `p=MIGfMA0GCSq…` (une longue suite) |

3. **Qui les pose ?** Celui qui tient le DNS. Si vous ne savez pas qui c'est, tapez
   `hotelparisianer.com` sur **who.is** : le champ *Registrar* donne le nom. Si l'hôtel a un
   prestataire informatique, c'est lui — le message tout prêt est plus bas.
4. Dans l'interface du DNS, chercher **« Zone DNS »**, « Enregistrements DNS » ou « DNS
   records », puis **Ajouter un enregistrement**, trois fois. Recopier exactement.
   - Si le champ *Nom* attend une valeur **relative**, écrire `send.notifications` et
     `resend._domainkey.notifications` ;
   - s'il attend le **nom complet**, écrire `send.notifications.hotelparisianer.com` et
     `resend._domainkey.notifications.hotelparisianer.com`.
   - En cas de doute : regarder une ligne déjà présente. Si elle affiche `@` ou `www`, le champ
     est relatif ; si elle affiche `hotelparisianer.com`, il est complet.
5. Revenir sur Resend → **Verify**. Le domaine passe à *Verified* — quelques minutes d'ordinaire,
   jusqu'à quelques heures si le DNS est lent. Le bouton peut se represser autant de fois qu'on
   veut.
6. Dans Vercel → Settings → Environment Variables, poser `MAIL_EXPEDITEUR` :
   `Hôtel Parisianer <technique@notifications.hotelparisianer.com>`. **Cette boîte n'a pas
   besoin d'exister** : c'est une adresse d'expédition, pas une boîte aux lettres. Redéployer.
7. Ouvrir `/administration` → **Envoyer maintenant**. Ce qui attendait part.

### Chez OVH, pas à pas

Le domaine de l'hôtel est chez **OVH**. Tout se fait depuis l'espace client, sans passer par
personne.

**Attention au bon site.** `ovhcloud.com` mène à la **boutique**, pour acheter un domaine : en
y cherchant `hotelparisianer.com` on lit « Indisponible », ce qui veut simplement dire qu'il est
déjà à l'hôtel. Il n'y a rien à acheter. Ce qu'il faut, c'est l'**espace client** :

> **www.ovh.com/manager** — ou, depuis `ovh.com`, le lien **« Espace client »** en haut à droite.

Une fois connecté, l'espace client est découpé en « univers ». En haut à gauche, un sélecteur
propose *Bare Metal Cloud*, *Hosted Private Cloud*, *Public Cloud*, **Web Cloud**, *Telecom* :
choisir **Web Cloud**. Dans la colonne de gauche, **Noms de domaine**, puis cliquer sur
`hotelparisianer.com`. L'adresse ressemble alors à
`ovh.com/manager/#/web/domain/hotelparisianer.com`.

> **Si `hotelparisianer.com` n'apparaît pas dans la liste**, c'est que ce compte OVH n'est pas
> celui qui détient le domaine — il a été pris par une agence, un prestataire ou un
> prédécesseur. Il faut alors les identifiants de ce compte-là, ou demander une délégation de
> gestion. Le nom du titulaire se lit sur **who.is**, champ *Registrant*.

**D'abord, vérifier qu'OVH tient bien la zone.** Sur la page du domaine, une rangée d'onglets :
*Informations générales*, **Serveurs DNS**, **Zone DNS**, *Redirection*, *DynHost*… Ouvrir
**Serveurs DNS**. S'ils ressemblent à `dns**.ovh.net`
et `ns**.ovh.net`, c'est bien OVH qui décide : la suite s'applique. S'ils pointent ailleurs
(Cloudflare, Microsoft…), c'est là-bas qu'il faut ajouter les lignes — la zone OVH ne serait pas
lue.

Ensuite, revenir sur l'onglet **Zone DNS** → bouton **Ajouter une entrée**, en haut à droite du
tableau. Trois fois, une par ligne.

**Ligne 1 — le MX.** Choisir le type **MX**.

| Champ OVH | Ce qu'on saisit |
|---|---|
| Sous-domaine | `send.notifications` |
| TTL | laisser *Par défaut* |
| Priorité | `10` |
| Cible | `feedback-smtp.eu-west-1.amazonses.com.` — avec le **point final** |

> OVH peut afficher un avertissement en voyant un MX ajouté à la main : il prévient qu'un MX
> s'ajoute d'ordinaire depuis la partie e-mail. C'est sans conséquence ici — celui-ci porte sur
> `send.notifications`, pas sur le domaine, et la messagerie de l'hôtel n'est pas concernée.

**Ligne 2 — le SPF.** Choisir le type **TXT**, et **pas** le type « SPF » proposé par OVH : son
assistant réécrit la valeur à sa façon, et Resend ne la reconnaîtrait plus.

| Champ OVH | Ce qu'on saisit |
|---|---|
| Sous-domaine | `send.notifications` |
| Valeur | `v=spf1 include:amazonses.com ~all` |

**Ligne 3 — la clé DKIM.** Type **TXT** là encore, jamais l'assistant « DKIM ».

| Champ OVH | Ce qu'on saisit |
|---|---|
| Sous-domaine | `resend._domainkey.notifications` |
| Valeur | la longue suite affichée par Resend, en entier, d'un seul tenant |

> Si OVH refuse la valeur parce qu'elle est trop longue, la couper en deux morceaux entre
> guillemets sur la même ligne : `"première moitié" "seconde moitié"`. C'est la façon normale
> d'écrire une valeur TXT de plus de 255 caractères, et elle se relit comme si elle était
> entière.

**Enfin**, en haut de la zone DNS, OVH demande parfois de **confirmer les modifications** : les
lignes ne sont posées qu'une fois cette confirmation donnée. OVH les applique en général en
quelques minutes.

### Ce qu'il ne faut surtout pas faire

- **Ne pas toucher aux enregistrements MX du domaine principal.** Ce sont eux qui amènent le
  courrier aux boîtes Microsoft 365 de l'hôtel. Y toucher couperait la messagerie de tout le
  monde. Ceux de Resend sont sur le sous-domaine `send.notifications`, ils ne les croisent pas.
- **Ne jamais ajouter un second enregistrement SPF à la racine.** Le domaine en a déjà un pour
  Microsoft (`v=spf1 include:spf.protection.outlook.com -all`). Deux SPF à la racine, et
  l'ensemble devient invalide : les mails de l'hôtel partiraient en spam. Avec un sous-domaine,
  la question ne se pose pas — c'est précisément pourquoi on en prend un.
- **Ne pas remplacer une ligne existante** : on en **ajoute** trois, on n'en modifie aucune.

### Le message à transmettre, si quelqu'un d'autre tient le DNS

> Bonjour,
>
> Nous mettons en service une application interne qui envoie des notifications par courriel.
> Le service d'envoi est Resend, et il demande que trois enregistrements soient ajoutés à la
> zone DNS de `hotelparisianer.com`.
>
> **Ils portent tous sur un sous-domaine dédié, `notifications.hotelparisianer.com`.** Ils
> n'ont donc aucun contact avec les MX ni avec le SPF de Microsoft 365 : la messagerie de
> l'hôtel n'est pas concernée, rien n'est à modifier, il n'y a que trois lignes à ajouter.
>
> [coller ici les trois lignes affichées par Resend]
>
> Merci de me dire quand c'est en place, je ferai la vérification de mon côté.

**Où lire l'adresse du compte Resend ?** Le plus simple : dans `/administration`, le message
d'échec la contient — Resend écrit *« You can only send testing emails to your own email
address (…) »*, et l'adresse est entre parenthèses. Sinon, c'est celle avec laquelle le compte a
été créé : Resend → menu en haut à droite → **Settings → Profile**.

**En attendant, pour essayer tout de suite et ne pas rester bloqué** : dans `/administration`
→ *Destinataires des alertes*, mettre comme destinataire **l'adresse du compte Resend
lui-même**. Le message partira sans qu'aucun domaine soit vérifié — c'est la seule destination
que Resend accepte en l'état. On saura ainsi que toute la chaîne fonctionne, et il ne restera
qu'à remettre `fom@hotelparisianer.com` le jour où le sous-domaine est en place.

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
| `MAIL_EXPEDITEUR` | `Hôtel Parisianer <technique@notifications.hotelparisianer.com>` — une adresse d'un domaine **vérifié** chez Resend | L'expéditeur reste `onboarding@resend.dev`, et Resend n'accepte alors que l'adresse du titulaire du compte |
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
