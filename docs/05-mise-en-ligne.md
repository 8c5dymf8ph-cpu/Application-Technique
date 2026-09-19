# Mettre l'application en ligne

Trois choses à créer, toutes gratuites, une seule fois. Compter une demi-heure.

Aucune des étapes ci-dessous ne demande de partager un mot de passe ou une chaîne de
connexion : tout se saisit directement dans Supabase et dans Vercel.

---

## 1. La base de données — Supabase

1. Créer un compte sur **supabase.com**, puis un projet.
   - Région : **Europe (Paris ou Francfort)**, pour que l'application reste rapide depuis l'hôtel.
   - Noter le mot de passe de la base : il n'est affiché qu'une fois.
2. Dans le projet, ouvrir **SQL Editor**, puis exécuter dans cet ordre les trois fichiers de
   `donnees/installation/` :

| Fichier | Contenu | Taille |
|---|---|---|
| `1-schema-et-referentiels.sql` | Tables, vues, règles, sécurité, 70 emplacements, 268 libellés | 121 Ko |
| `2-anomalies.sql` | 670 anomalies, 528 interventions, 29 tournées | 1 010 Ko |
| `3-stock.sql` | 36 produits, 257 mouvements | 164 Ko |
| `4-bouteilles.sql` | 17 dossiers de bouteille, la livraison du 31/03, le parc constaté | 30 Ko |
| `5-equipe.sql` | L'orthographe des noms et la liste des intervenants techniques | 2 Ko |

> Ces trois fichiers sont produits par `outils/preparer_installation.sh` : ils ne
> s'éditent pas à la main, ils se regénèrent après toute modification du schéma.

> Les deux derniers sont volumineux pour l'éditeur SQL du navigateur. S'il bloque, les passer
> depuis un terminal :
> `psql "<chaîne de connexion>" -f donnees/installation/2-anomalies.sql`
> La chaîne se trouve dans **Settings → Database → Connection string → URI**.

3. Vérifier dans **Table Editor** que `anomalies` contient bien 670 lignes.

## 2. Les mails — Resend

1. Créer un compte sur **resend.com** (offre gratuite : 100 messages par jour, 3 000 par mois —
   l'hôtel en enverra quelques-uns).
2. **API Keys → Create**, copier la clé. Elle se saisit dans Vercel à l'étape suivante, jamais ici.
3. Pour que les messages partent depuis une adresse de l'hôtel, ajouter le domaine dans
   **Domains** et suivre les enregistrements DNS. Sans cette étape, l'expéditeur reste
   `onboarding@resend.dev`, ce qui suffit pour essayer.

La file d'attente se vide toute seule **toutes les quinze minutes** (`vercel.json`). L'écran
`/administration` montre ce qui attend, ce qui est parti, et ce qui a échoué — et permet de
déclencher un passage sans attendre.

## 3. L'hébergement — Vercel

1. Créer un compte sur **vercel.com** en se connectant avec GitHub.
2. **Add New → Project**, choisir le dépôt `Application-Technique`, branche
   `claude/friendly-allen-lmkxuo`.
3. Avant de déployer, ouvrir **Environment Variables** et ajouter :

   | Nom | Valeur |
   |---|---|
   | `DATABASE_URL` | la chaîne de connexion Supabase (Settings → Database → **Connection pooling**, mode *Transaction*) |
   | `RESEND_API_KEY` | la clé d'API Resend (resend.com → API Keys). Sans elle, rien ne part : les messages s'accumulent dans la file sans se perdre |
   | `MAIL_EXPEDITEUR` | l'expéditeur, par exemple `Parisianer <technique@contacthotelparisianer.com>`. Le domaine doit être vérifié chez Resend ; à défaut, `onboarding@resend.dev` fonctionne pour les essais |
   | `CRON_SECRET` | une longue chaîne au hasard. Elle protège `/api/envoi` : sans elle, n'importe qui pourrait déclencher des envois |

   Prendre bien celle du *pooling* et non la connexion directe : Vercel ouvre beaucoup de
   connexions courtes, et la connexion directe les épuiserait.

4. **Deploy**. Au bout de deux minutes, une adresse en `.vercel.app` s'affiche.

## 3. Sur le téléphone

Ouvrir l'adresse dans Safari ou Chrome, puis **Partager → Sur l'écran d'accueil**.
L'application s'ouvre ensuite en plein écran, sans barre de navigateur.

---

## Ce qui reste à faire ensuite

- **Un nom de domaine** — `technique.grandhotelsavoy.fr` par exemple, à brancher dans Vercel.
  Sans cela, l'adresse en `.vercel.app` fonctionne parfaitement mais retient mal.
- **La connexion Microsoft** — pour l'instant l'application demande seulement de choisir un
  profil. Tant que l'adresse n'est pas publique, l'enjeu est faible ; il devient réel dès qu'elle
  l'est.
- **Les envois de mail** — un compte Resend et une adresse d'expéditeur.
