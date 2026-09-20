# Application Technique — Hôtel Parisianer

Refonte de l'application Power Apps de gestion des interventions techniques, du stock matériel
et des bouteilles Purezza. Voir `docs/01-cahier-des-charges.md`.

## Langue

Le domaine, les noms de tables, de colonnes et l'interface sont **en français**. Le code
(variables, fonctions, composants) est en anglais sauf quand il nomme un concept métier.
Ne jamais utiliser d'accent dans un identifiant SQL.

## Règles métier à ne pas casser

1. **Rien de calculable n'est stocké.** Stock matériel, parc de bouteilles et coût d'intervention
   sont des vues dérivées des mouvements. Ne jamais ajouter une colonne `stock` matérialisée.
2. **Un dossier bouteille porte une chambre, une date, un client — et plusieurs types.**
   Une chambre peut perdre la filtrée ET la gazeuse d'un coup : c'est **un** dossier, un
   montant, un mail. Les types sont des lignes (`incident_lignes_bouteille`), et ce sont elles
   qui déclenchent les mouvements. Ne jamais remettre un `bouteille_type_id` sur l'en-tête.
2bis. **Une bouteille emportée sort du parc détenu, sans être perdue pour autant.** `parc_detenu`
   (réserve + chambres) est ce que l'hôtel a réellement : il baisse dès l'emport. `chez_client`
   est une position d'attente, et `parc_theorique` ne sert qu'au rapprochement d'inventaire.
   Ne jamais afficher le théorique comme le parc. Une bouteille restituée rejoint la **réserve**,
   pas la chambre — celle-ci a déjà été re-dotée — et la re-dotation est un déplacement
   `reserve → emplacement`, jamais une seconde sortie.
3. **Les deux validations sont conservées.** Le refus d'une gouvernante renvoie l'anomalie en
   `a_faire` mais n'efface jamais l'avis du technicien : les récapitulatifs doivent pouvoir
   afficher « déclarée faite par X — non validée par la gouvernante ».
4. **Un écart d'inventaire passe toujours par une régularisation tracée**, jamais par une
   écriture directe du stock.
5. **Le technicien ne saisit aucun prix.** Il coche l'anomalie faite et le matériel utilisé, rien
   de plus. Ne jamais ajouter de champ de montant sur un écran technicien.
6. **Un produit sans prix n'est pas compté pour zéro.** Les vues de coût exposent
   `articles_sans_prix` et `cout_incomplet` : l'interface doit le dire, pas l'ignorer.
7. **Un seul mail par fournisseur** pour les demandes de devis, même si plusieurs articles
   tombent sous le seuil en même temps. Un article peut avoir plusieurs fournisseurs : la
   consultation part alors vers chacun, pour comparer.
7bis. **Victoria ne reçoit ni n'envoie aucun mail.** Elle consulte, valide et déclare dans
   l'application. Les récapitulatifs vont à Miguel et, selon le paramétrage, à l'intervenant ;
   l'alerte bouteille va à la réception.
7ter. **L'application n'écrit jamais à un client.** Le mail de bouteille manquante part à la
   **réception dès le constat**, sans attendre que quelqu'un le transmette : le client est
   peut-être encore là. Il est rédigé prêt à être transféré, en français puis en anglais. C'est la réception
   qui décide de l'envoyer et qui parle au client. Ne jamais mettre une adresse de client dans
   un destinataire.
7quater. **Le mail ne s'affiche jamais : c'est une action.** Il est standardisé, il n'y a rien à
   y relire ni à y corriger. « Transmettre » le rédige et le dépose dans `emails_envoyes` avec
   `envoye_le` nul. **Le message part dans la foulée du dépôt** : `viderLaFileEnFond()` vide la
   file après la réponse (`after()` de Next), sans faire attendre l'écran. La tâche planifiée
   (`/api/envoi`, protégée par `CRON_SECRET`) n'est qu'un **filet de rattrapage quotidien** —
   l'offre gratuite de Vercel refuse une tâche plus fréquente, et un cron plus rapide fait
   échouer le déploiement. Ne jamais faire dépendre l'alerte bouteille du passage planifié : elle
   doit partir au constat. Ne jamais remettre le texte à l'écran.
7sexies. **Les destinataires se règlent dans l'application, pas dans le code.** Les
   récapitulatifs cherchaient l'adresse d'un administrateur dans `utilisateurs.email`, qu'aucun
   écran ne permet de saisir : ils ne partaient jamais, en silence. Ils lisent désormais
   `alertes_destinataires`, comme l'alerte bouteille, et se règlent depuis `/administration`.
   Une ligne sans adresse reste inactive — la contrainte l'impose, et c'est juste : une ligne
   active sans destinataire est une promesse en l'air.

7quinquies. **Sans clé d'envoi, on ne prétend pas avoir envoyé.** `RESEND_API_KEY` absente : la
   file reste intacte et l'écran le dit. Un échec n'efface rien non plus — la ligne garde son
   erreur et repart au passage suivant. Ne jamais marquer `envoye_le` sur un message qui n'est
   pas parti.
8. **Un même problème ne peut pas être ouvert deux fois au même endroit.** L'index
   `anomalie_unique_ouverte_par_lieu` l'interdit en base : ce n'est pas un avertissement que
   l'interface pourrait contourner. L'écran de déclaration montre d'abord `v_anomalies_du_lieu`,
   et `fn_catalogue_pour_lieu` marque comme non proposable tout libellé déjà ouvert ici.
   **Le comptage dans le temps est un autre sujet** : `v_frequence_anomalie_lieu` dit combien de
   fois le problème est revenu, et c'est une information à montrer, pas un obstacle. C'est aussi
   la raison d'être du catalogue fermé : sans libellés normalisés, ce comptage n'existe pas.
9. **Une anomalie hors catalogue ne se crée que par un admin**, depuis un ordinateur. La règle est
   dans la RLS : ne pas la déplacer dans l'interface.
10. **Le technicien rend un lot, la gouvernante valide à l'unité.** Une `tournee` regroupe les
   anomalies traitées ensemble (l'ancien `InterventionID`). **Le lot est l'unité d'envoi** : un
   mail par anomalie validée en produirait dix pour un passage. Deux messages, deux moments —
   à la clôture, ce que le technicien déclare avoir fait ; à la dernière validation, les deux
   avis côte à côte, avec ce qu'elle n'a PAS validé dit en clair. `deposerRecap()` les rédige et
   les dépose dans la file ; `prete_pour_recap` et `mail_recap_envoye_le` empêchent l'envoi
   prématuré et le doublon. Pas d'heure fixe : le message part quand l'événement a lieu.
10quater. **Un passage ne s'étale pas sur deux jours.** Le technicien vient le lundi, la
   gouvernante ne finit de vérifier que le mardi, et le mardi il revient pour autre chose : ce
   sont deux passages, qui se valident séparément. `tourneeEnCours` rend d'office une tournée
   restée ouverte d'un jour précédent — le récapitulatif de clôture part comme s'il avait appuyé
   sur « Fin d'intervention » — et en ouvre une neuve pour aujourd'hui. Ne jamais laisser un lot
   courir d'un jour sur l'autre.

10quinquies. **Qui facture ne se déduit pas du fait d'être une entreprise.** Farid et Rachid
   interviennent sans être salariés : ils facturent, bien qu'inscrits dans `utilisateurs`. Taibi,
   Victoria et Miguel sont de la maison : leur passage ne coûte que le matériel sorti.
   `utilisateurs.emet_des_factures` le dit, `factures.technicien_id` permet de rattacher la
   pièce, et la contrainte impose un émetteur et un seul. Ne jamais tester `prestataire_id` pour
   savoir si un passage donne lieu à une facture.

10bis. **Le lot n'existe pour la gouvernante qu'une fois rendu.** Une anomalie cochée par le
   technicien reste `en_cours` tant que la tournée est ouverte : il est encore dans les étages,
   il peut se déraviser. `tg_cloture_tournee` les bascule toutes en `attente_validation` à la
   clôture, et `v_tournees.nb_en_attente` vaut 0 sur une tournée ouverte. **Décocher supprime la
   déclaration entière** — l'avis et le matériel qu'elle portait, qui n'a donc pas été utilisé ;
   le laisser sorti fausserait le stock. Ne jamais présenter à la gouvernante un travail que
   personne n'a déclaré terminé.

10ter. **Un intervenant ne voit que sa tournée.** Ni le coût d'un passage, ni les factures, ni la
   valeur du stock, ni l'historique : il vient traiter des anomalies. Désigner qui intervient est
   une décision d'encadrement — Victoria, Miguel, Sarah P, c'est-à-dire `peutValider`. La règle
   est dans `lib/acces.ts` (`exigerEncadrement`), et les écrans de `/technique` la posent tous.
   Ne jamais rouvrir ces écrans à un technicien « pour dépanner ».

11. **La gouvernante a trois issues**, pas deux : `validee`, `en_cours`, `a_refaire`. Ne jamais
   réduire le choix à valider/refuser.
12. **Les commentaires forment un fil, jamais un champ texte.** Un commentaire libre est une ligne
   de `commentaires`, un commentaire attaché à une décision une ligne de `validations` ; chacun
   garde son auteur et sa date, et `v_fil_commentaires` les présente dans l'ordre. **Rien
   n'écrase rien** : celui de la gouvernante s'ajoute sous celui du technicien, et un commentaire
   peut s'ajouter à tout moment — à la déclaration, en cours de route, ou des mois plus tard
   quand le problème revient. Ne jamais réintroduire un champ `commentaire` sur `anomalies`.
13. **Un ajustement de stock porte toujours un motif** (`inventaire`, `casse`, `perte`,
   `erreur_saisie`, `autre`). Seul le motif `inventaire` exige un comptage complet : une casse
   se corrige au fil de l'eau.
13bis. **Un article non compté n'est pas compté pour zéro.** Dans un inventaire, le champ laissé
   vide laisse l'article ABSENT du comptage : aucune ligne, aucun écart, aucun mouvement. Le
   théorique s'affiche en filigrane, jamais pré-rempli — un chiffre déjà posé se valide sans
   être vérifié, et l'inventaire ne vaut plus rien.
14bis. **Le catalogue se replie dès qu'un article est retenu.** Il restait ouvert sous la
   sélection et repoussait l'enregistrement hors de l'écran : on ne savait pas qu'il fallait
   encore valider. Et **la quantité se règle** — l'adresse porte « identifiant~quantité », et
   l'écriture borne ce qui sort par la réserve réelle : on ne sort jamais ce qu'on n'a pas.

14ter. **Un produit se retire, il ne se supprime pas.** `produits.actif` le sort du choix du
   technicien et des alertes, sans rien effacer : ses mouvements, son prix et les interventions
   où il a servi restent, sinon le coût des passages passés changerait. **Il reste DANS la liste
   de `/stock`**, en bas, avec la mention « retiré » — l'en sortir le faisait disparaître et on
   le cherchait en croyant l'avoir perdu ; sa valeur en stock compte toujours, les pièces sont
   sur l'étagère. La fiche le remet d'un appui. Ne jamais proposer de supprimer un produit.

14quater. **Un geste ne part qu'une fois.** Rien ne change à l'écran le temps qu'une action
   réponde : on réappuie. Trois appuis sur « C'est fait » ont créé trois déclarations pour la
   même anomalie, et la gouvernante a eu trois fois la même chose à vérifier. `BoutonEnvoi`
   (`useFormStatus`) se désactive pendant l'envoi et le dit ; et l'écriture se protège elle-même
   — une intervention ne s'insère que s'il n'y en a pas déjà une pour cette anomalie dans cette
   tournée. Le bouton seul ne suffit pas : un écran resté ouvert renvoie encore.

14quinquies. **Une photo s'ajoute, elle ne remplace pas.** Le champ natif vide sa sélection à
   chaque ouverture : prendre une seconde photo effaçait la première, sans un mot — on croyait
   ne pas pouvoir en ajouter. `ChampPhotos` tient la liste lui-même et réécrit le champ à partir
   d'elle ; chaque vignette porte sa croix pour retirer une photo ratée. Un écran qui n'attend
   qu'un fichier (`multiple={false}`) remplace, lui.

14. **Le technicien dit toujours s'il a utilisé du matériel**, anomalie par anomalie, en le
   choisissant dans la liste des produits avec leurs photos. « Aucun matériel » est une réponse
   explicite, pas une absence de réponse. **Un article épuisé ne se choisit pas** : il reste
   visible, grisé, et dit qu'il n'y a rien en réserve — sinon on le cherche sans comprendre.
   L'écran le grise et l'enregistrement le revérifie : un lien recopié ne doit pas passer.
15. **Une section spécialisée ne montre que son métier.** Sans ligne dans
   `specialites_intervenant`, un intervenant est polyvalent ; avec, il ne voit que ses types.
   La règle vaut pour les salariés comme pour les entreprises extérieures.
15bis. **Le prix payé se lit dans les mouvements, il ne se stocke pas.** Chaque entrée porte le
   prix de SA livraison ; `v_prix_produit` en déduit le dernier prix, la variation et l'écart
   au prix de référence. **`produits.prix_unitaire` ne se met jamais à jour tout seul** : c'est
   lui qui valorise le stock, et l'aligner est une décision qu'on prend en voyant la hausse.
   Un produit peut avoir plusieurs fournisseurs, chacun avec son adresse : c'est là que part
   la demande de devis, et l'un d'eux est `prefere`.
16. **Une facture de prestataire se rapproche par la journée et l'intervenant**, jamais par le
   numéro de tournée. L'ancien `InterventionID` changeait à chaque anomalie validée : il fallait
   le corriger à la main, et il reste des coquilles dans les données reprises. Ce qui identifie
   un passage, c'est **qui** est venu et **quel jour** — `FAIT LE` et `PAR` dans l'ancienne
   application. `fn_interventions_rapprochables` propose donc des journées d'intervenant, pas des
   tournées, et une facture peut en couvrir plusieurs.
16quater. **Le coût d'un passage, c'est le matériel PLUS ce que l'intervenant facture.** Le
   détail de sa facture ne nous intéresse pas : le matériel appartient le plus souvent à l'hôtel,
   et ce qu'il facture est son déplacement et ce qu'il estime avoir coûté. Le montant et la pièce
   se saisissent **depuis le passage**, là où on le regarde — pas dans un écran de factures à
   part. Le coût matériel reste compté à côté : il s'ajoute, il ne se remplace pas. La facture
   couvre tout le passage ; `facture_interventions` la rattache à chaque intervention,
   `montant_affecte` nul valant répartition à parts égales.

16quinquies. **Un passage existe dès qu'un intervenant est venu un jour donné.** L'import n'avait
   créé une tournée que pour les lignes portant un InterventionID exploitable : 419 interventions
   sur 528 n'avaient aucun passage, et l'historique n'en montrait qu'un cinquième. La migration
   0006 les reconstitue par (intervenant, jour), en `reprise` pour qu'aucun récapitulatif ne
   parte. Ne jamais laisser une intervention sans tournée : elle disparaît de l'historique, et
   aucun coût ne peut s'y rattacher.

16bis. **Une anomalie ne se montre jamais séparée de son lieu.** Deux listes côte à côte — les
   lieux d'un côté, les descriptions de l'autre — laissent croire qu'il y a un lave-vaisselle
   dans la chambre 57. Partout où plusieurs anomalies s'affichent ensemble, chacune porte sa
   puce de lieu, et les listes se rangent par date, la plus récente d'abord, avec la date en
   en-tête dès qu'il y en a plusieurs.
16ter. **Une entrée de stock porte la date de la LIVRAISON, pas celle de sa saisie.** La date de
   réception se saisit et se corrige après coup ; `tg_redater_reception` déplace alors les
   mouvements que la commande a produits, grâce à `mouvements_*.commande_id`. Sans ce lien,
   l'historique du prix serait faux.
17. **Il n'y a pas de bouton « recalculer le stock ».** Rien n'est stocké, donc rien à recalculer.
   Ne jamais réintroduire `Stock_Initial`, `StockActuel` ni `EstHistorique`.

## Base de données

```
supabase/migrations/   schéma, vues, règles, sécurité — jouées dans l'ordre
supabase/seed/         référentiels (étages, emplacements, types, dotations)
supabase/tests/        scénarios métier, à rejouer après toute modification du schéma
donnees/installation/  les trois fichiers à jouer en production, produits par
                       outils/preparer_installation.sh — jamais édités à la main
donnees/demo_*.sql     données inventées, pour regarder les écrans. Jamais en production.
```

**Le pilote PostgreSQL rend les colonnes `date` sous forme d'objet `Date`, pas de chaîne.**
Découper la chaîne à la main (`.slice(0, 10)`) passe le typage et casse en production : utiliser
`jourISO()` de `lib/domaine.ts`.

Les scénarios se mesurent en **écarts**, pas en valeurs absolues : ils doivent pouvoir se
rejouer sur la base de l'hôtel, avec son parc réel, sans être réécrits.

Valider une modification de schéma en local :

```bash
export PATH=/usr/lib/postgresql/16/bin:$PATH
su postgres -c "initdb -D /tmp/pgtest -U postgres --auth=trust -E UTF8 --locale=C"
su postgres -c "pg_ctl -D /tmp/pgtest -o '-p 55432 -k /tmp' -l /tmp/pg.log start"
psql -h /tmp -p 55432 -U postgres -c "create database valid"
# Supabase fournit auth.users et auth.uid() ; les recréer en local avant les migrations
psql -h /tmp -p 55432 -U postgres -d valid -f supabase/tests/00_shim_supabase.sql
for f in supabase/migrations/*.sql supabase/seed/*.sql; do
  psql -h /tmp -p 55432 -U postgres -d valid -v ON_ERROR_STOP=1 -q -f "$f" || break
done
psql -h /tmp -p 55432 -U postgres -d valid -q -f supabase/tests/01_scenarios.sql
```

**`colonneExiste()` ne retient que les réponses positives.** Une colonne qui existe n'est jamais
retirée : la retenir est sans risque. Retenir une ABSENCE rend l'application aveugle à la
migration qui vient de l'ajouter — l'écran continue de dire « en attente » alors que la base est
à jour, jusqu'au redémarrage du serveur.

**Un geste qui aboutit doit se voir, un geste qui échoue encore plus.** Une photo refusée par le
dépôt disparaissait sans un mot : on croyait l'avoir ajoutée et la vignette ne changeait pas.
Les actions passent un `?fait=` dans l'adresse et `<Confirmation>` le rend — vert pour ce qui est
enregistré, rouge pour ce qui ne l'est pas. Ne jamais avaler un échec de `enregistrerFichier()`
avec un `continue` muet.

**Le code part en ligne avant la migration.** Vercel redéploie à chaque poussée ; une migration
s'applique à la main, plus tard. Entre les deux, l'application tourne sur un schéma plus ancien
que le code — et une requête qui nomme une colonne absente **casse l'écran** : Postgres refuse
l'instruction entière, il n'ignore pas la condition. Écrire deux requêtes et choisir avec
`colonneExiste()` de `lib/schema.ts`, jamais une condition booléenne dans le SQL.

## Rôles

| Rôle | Ce qu'il fait |
|---|---|
| `menage` | Constate. **Ne se connecte pas** : existe pour être nommée (Daria, Ira, Cristina, Rodica) |
| `reception` | Reçoit le dossier bouteille et écrit au client. **Ne se connecte pas** (Taibi, Luca) |
| `technicien` | Traite ses anomalies, dit s'il a pris du matériel |
| `gouvernante` | Déclare, valide, déclare au nom d'un intervenant (Victoria) |
| `operations` | Supprime une anomalie (Sarah P, chargée des opérations) |
| `admin` | Référentiels, catalogue, paramétrage, suivi des dossiers (Miguel) |

**Qui intervient ne se déduit pas d'un rôle.** La chargée des opérations n'intervient pas ; le
réceptionniste qui donne un coup de main, si. La liste est donnée par l'hôtel et posée par
`outils/equipe.py`, qui corrige aussi l'orthographe des noms repris des exports. Quinze
intervenants : Alain, EcoFlair, Hedi, Juan, Mr Negroni, Serafino, Technicien Avir / EUROPROH /
Kone / Telec côté extérieur ; Farid, Miguel, Rachid, Taibi, Victoria côté interne.

**Aucun écran n'est caché.** La gouvernante voit tout ; ce qui change, c'est l'ordre : ses gestes
d'abord, le suivi et l'analyse ensuite. Elle n'est pas dans l'analyse — ce qu'il lui faut, c'est
que ce soit **visuellement évident** : la bouteille dessinée à sa couleur, bleue pour la filtrée,
rouge pour la gazeuse, et le contour qui prend cette couleur quand elle est choisie. On reconnaît
une bouteille à sa couleur en chambre, pas à son nom.

**Elle doit toujours pouvoir dire qui a constaté et à qui elle l'a dit.** Ce n'est presque jamais
elle qui voit la bouteille manquante, et ce n'est jamais elle qui écrit au client. Les deux
prénoms se choisissent en un appui, en clair, jamais dans un menu déroulant. Le remplacement,
lui, est décidé par la gouvernante : il n'a besoin que de sa trace, pas d'un prénom de plus.

**Qui apparaît au choix des profils est un réglage, pas une conséquence de la table.** Farid et
Rachid s'y trouvaient d'office parce qu'ils étaient inscrits dans `utilisateurs`, et les treize
autres en étaient absents parce qu'ils sont des `prestataires` — or c'est ce lien qui sert au
rapprochement des factures, on ne peut pas les recopier ailleurs. `utilisateurs.prestataire_id`
relie un compte à son entreprise : la tournée ouverte reste rattachée au prestataire, et
`v_intervenants` ne compte pas la personne deux fois. `peut_se_connecter` décide de l'affichage,
et se règle dans `/administration/equipe` — l'hôtel change d'intervenants.

**Chaque intervenant peut recevoir son récapitulatif de fin de passage**, à l'adresse notée sur
la même ligne. Le message « lot rendu » part chez lui ET chez Miguel : il est en copie, jamais
court-circuité. Le récapitulatif complet, lui, ne concerne que l'hôtel — il porte l'avis de la
gouvernante, y compris ce qu'elle n'a pas validé.

**La liste des intervenants se tient depuis l'application.** Un renfort ponctuel s'ajoute et se
retire d'un appui dans `/administration/equipe` ; ce qu'il a fait reste attaché à son nom.

**On ne supprime jamais une personne, on la désactive.** L'étage change souvent ; `actif` la
retire des listes de saisie et son prénom reste sur les dossiers qu'elle a constatés, des années
après son départ. `/administration/equipe` tient les deux listes à jour, et la gouvernante peut
s'en servir : elle n'a pas à attendre l'administrateur pour enregistrer une arrivée.

**Supprimer une anomalie efface une trace : trois personnes, jamais un technicien.** Victoria,
Sarah P et Miguel — c'est-à-dire `peutValider`. C'est la gouvernante qui déclare, donc c'est elle
qui se trompe de chambre ou déclare deux fois le même robinet : l'obliger à attendre quelqu'un
d'autre pour défaire son propre geste n'avait pas de sens. La règle est dans `fn_peut_supprimer`
et dans la politique de suppression. L'écran dit ce que la suppression emporte — fil, photos,
interventions — avant de la proposer. **Ce qui est sorti du stock n'est pas rendu** :
`mouvements_stock.intervention_id` passe à nul, le mouvement reste ; le matériel a bien quitté la
réserve. Un problème résolu se clôt, il ne se supprime pas.

## Photos

Une anomalie porte deux séries : **au constat**, prises par qui déclare, et **après
intervention**, prises par le technicien. Les deux sont facultatives et les deux s'affichent
dans l'historique du lieu. Le technicien voit les photos du constat avant d'intervenir.

**Miguel ajoute lui-même les photos** : celles des bouteilles depuis `/administration/bouteilles`,
celles des produits **en appuyant sur la vignette du produit** — elle ouvre la galerie, où l'on
consulte, ajoute et supprime. Pas de section « Photos » séparée : l'image est sa propre porte
d'entrée. Plusieurs par produit, dont une mise en avant, qui est
celle que le technicien voit en choisissant son matériel. Sans photo, l'écran dessine la bouteille à sa
couleur — il n'attend jamais une image pour fonctionner.

**Une photo se regarde en grand, sans quitter l'écran.** Une vignette de 74 px ne dit pas si la
fuite est réparée, et ouvrir un onglet faisait perdre sa place. `Vignettes` ouvre une fenêtre
native — flèches, glissement du doigt, Échap — et prend `taille` : 104 px côté technicien, parce
que le constat est la première chose qu'il regarde en arrivant.

**Une photo se réduit dans le navigateur avant de partir.** La plateforme coupe toute requête
de plus de 4,5 Mo (413) et une photo de téléphone en fait trois à huit : l'envoi échouait sans
rien afficher, l'écran paraissait figé. `ChampPhotos` redessine l'image à 1600 px de côté, en
respectant l'orientation EXIF, et affiche ce qui est prêt à partir. Ne jamais annoncer une limite
de corps supérieure à ce que la plateforme accepte, et ne pas mettre `capture` sur le champ :
il faut pouvoir prendre une photo **ou** en choisir une dans la photothèque.

**Une photo peut s'enregistrer et rester introuvable.** Sans les variables Supabase, le fichier
part sur le disque de la machine qui a traité l'envoi — et la lecture, servie par une autre
machine, ne le trouve pas : la ligne existe, l'image est vide, rien ne le dit. `verifierDepot()`
écrit un fichier, le relit, compare et l'efface ; `/administration` le lance à la demande et
affiche le verdict. C'est la seule réponse sûre à « pourquoi ma photo ne s'affiche pas ».

Une facture se range au même endroit qu'une photo — PDF compris. Le stockage passe par
`lib/stockage.ts` : **Supabase Storage dès que `SUPABASE_URL` et la clé de service sont là, le
disque sinon.** La clé se lit sous son nom actuel `SUPABASE_SECRET_KEY` (`sb_secret_…`) ou sous
l'ancien `SUPABASE_SERVICE_ROLE_KEY` — Supabase les a renommées, les deux restent acceptés. Le choix ne se fait jamais sur `NODE_ENV` : on peut vouloir essayer
le dépôt distant depuis un poste. Le disque de Vercel repart à zéro à chaque déploiement — une
photo qui y serait écrite serait perdue, et `/administration` le signale en rouge. Rien d'autre
dans l'application ne connaît autre chose qu'un nom de fichier.

**L'application dit elle-même ce que la base sait faire.** Le code part en ligne avant la
migration : entre les deux, un bouton est grisé sans que rien n'explique pourquoi — « donner un
profil ne fonctionne pas ». `lib/capacites.ts` liste les capacités et leur sonde
(`colonneExiste`, ou `regleContient` quand la migration ne touche qu'une fonction, comme la
0011), et `/administration` les affiche avec le geste qui débloque. Un écran bloqué renvoie vers
cette liste au lieu d'afficher un bouton mort. Ajouter une migration qui change ce que l'on peut
faire, c'est ajouter une ligne ici.

## Sortir ses données

**Ce qu'on ne peut pas exporter n'est pas vraiment à soi.** `/administration/export` sort huit
tableaux déjà aplatis — anomalies, interventions, passages, mouvements, produits, bouteilles,
factures, commentaires — définis une fois dans `lib/export.ts` et servis par
`/api/export/[quoi]`. Une ligne par fait, les identifiants remplacés par les noms, les colonnes
en français. Le format est un CSV de tableur français : **point-virgule, virgule décimale, BOM en
tête** — sans le BOM, Excel lit « clé » en « clÃ© » ; sans la virgule décimale, aucune somme ne
marche. Le fichier porte la date du jour, et un par mois fait une sauvegarde indépendante de
l'application. Les exports passent par les vues quand elles existent (`v_recap_interventions`,
`v_dossiers_bouteille`, `v_tournees`) : ce sont elles qui portent déjà les jointures et les coûts.

## Essayer sans fausser les chiffres

Les chambres **06 et 07** sont des lieux d'essai (`emplacements.essai`). Tous les écrans les
acceptent comme n'importe quel lieu — déclarer, intervenir, valider, perdre une bouteille — mais
l'écran de déclaration les marque d'un contour pointillé et du mot « essai », et **les compteurs
de l'accueil excluent ce qui s'y passe**. Sans elles, on essaie sur une vraie chambre et le suivi
de l'hôtel s'en ressent. Les scénarios les écartent aussi : ils mesurent l'hôtel, pas
l'entraînement.

## Écrans

- **Le retour ramène d'où l'on vient, pas à un parent supposé.** Chaque écran désignait son
  parent en dur : consulter une ancienne intervention depuis l'historique d'une chambre, puis
  revenir, renvoyait à l'historique complet et non à l'endroit quitté. Le composant `Retour`
  refait le geste de la flèche du navigateur ; l'adresse passée à `Entete` n'est plus qu'un
  filet, pour l'ouverture directe d'un lien partagé ou l'application lancée depuis l'écran
  d'accueil. Il ne sort jamais de l'application : le point de départ de l'onglet est mémorisé,
  `history.length` seul ne distinguant pas nos pages de ce qui précédait.
- **En déclarant, la gouvernante ne voit que ce qui reste à traiter** dans le lieu — à faire, en
  cours, achat à faire. L'historique complet est derrière un lien, jamais dans le chemin de saisie.
  Il a toute sa place ailleurs : historique du lieu, rapports.
- **La bulle de commentaires s'ouvre.** Elle affichait un nombre et rien d'autre : on voyait
  qu'il y avait eu des mots sans pouvoir les lire. `ApercuFil` les montre dans une fenêtre
  native — pas un écran de plus, on ne perd pas sa place.
- **Les listes longues se replient.** Les étages, les sections d'un écran : sur un téléphone tenu
  d'une main, faire défiler trois écrans avant d'atteindre le cinquième étage est un défaut.

## Contraintes d'usage

- Utilisée sur téléphone, en déplacement dans l'hôtel : chaque écran doit rester utilisable
  à une main, et la saisie d'une sortie de matériel ne doit pas dépasser quelques appuis.
- **Le wifi couvre tout l'hôtel** : aucun écran n'a besoin d'un mode hors ligne ni d'une file
  d'attente locale. Ne pas réintroduire de couche de synchronisation différée.
- Budget 0 € : rester dans les offres gratuites Supabase / Vercel / Resend.

<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->
