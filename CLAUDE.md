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
2ter. **Un dossier se corrige, et ses mouvements le suivent.** On reprend l'historique — des
   dossiers d'il y a des semaines, saisis aujourd'hui — et on se trompe de chambre. Le parc
   n'est pas un chiffre stocké : corriger l'en-tête sans déplacer ce que le dossier a produit
   le rendrait faux, la 27 aurait rendu une bouteille que la 28 n'a jamais perdue. La migration
   0014 pose les déclencheurs : la date, le lieu, les quantités et la re-dotation suivent, et
   retirer une ligne emporte ses mouvements. **La nature ne se corrige pas** — un emport n'est
   pas une casse : on supprime et on redéclare. Supprimer un dossier emporte ses mouvements
   (`on delete cascade`), et c'est juste : contrairement au matériel d'une intervention, qui a
   réellement quitté l'étagère, une bouteille déclarée par erreur n'a jamais bougé. Réservé à
   `peutValider`, comme pour une anomalie.
2quater. **Une chambre est dotée d'UNE bouteille de chaque type : la quantité ne se demande
   pas.** Les boutons + et − posaient une question qui n'a jamais d'autre réponse que « une », et
   laissaient croire qu'il fallait y répondre. On marque la bouteille manquante, c'est tout — le
   modèle garde `quantite` pour les cas anciens, mais aucun écran ne la règle. Et les bouteilles
   se voient : 150 px à la déclaration, parce qu'on les reconnaît à leur couleur et à leur forme,
   pas à leur nom.
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

7undecies. **Une action serveur n'appelle pas une autre action serveur déclarée à côté
   d'elle.** « Transmettre à la réception » changeait le statut du dossier puis appelait
   `mettreEnFile`, une fonction `"use server"` imbriquée dans le même écran : à l'exécution elle
   n'existait pas. L'action plantait APRÈS l'écriture — le dossier passait à « transmis » et
   **aucun message n'était déposé**, en silence. Le dépôt vit maintenant dans
   `lib/alerte-bouteille.ts`, une fonction de module que les deux écrans appellent : celui de
   déclaration et celui du dossier, qui en avaient chacun leur copie. Ce qu'une action appelle
   doit être une fonction ordinaire, jamais une action voisine.

7septies. **Une alerte qui ne part pas doit le dire sur-le-champ.** L'alerte bouteille ne concerne
   que l'emport PAR LE CLIENT — une casse ou une bouteille prise par le personnel ne regarde pas
   la réception. Mais quand elle devait partir et n'est pas partie, l'écran se taisait : on
   croyait la réception prévenue alors que rien n'avait bougé. L'écran du dossier dit maintenant
   laquelle des quatre situations s'applique — partie, sans destinataire, alerte éteinte, ou
   rédigée mais en attente faute de `RESEND_API_KEY`. Ne jamais laisser une alerte échouer en
   silence.

7octies. **Un échec d'envoi se lit, motif compris.** « 3 en échec » sans le texte du refus
   n'apprend rien : c'est Resend qui dit pourquoi, et c'est ce texte qui donne le geste à
   faire. `/administration` rend la dernière erreur de chaque catégorie telle quelle, et
   reconnaît le refus le plus courant — sans domaine vérifié, Resend n'accepte que l'adresse du
   titulaire du compte. Ne jamais afficher un compteur d'échecs sans son motif.

7nonies. **L'alerte de seuil part quand le seuil est franchi, une fois.** Le réglage existait
   dans `/administration` depuis le début, mais **aucune ligne de code ne déposait de message** :
   on le réglait et on attendait. `alerterSiSousSeuil()` est appelée après une sortie de stock ;
   elle ne se répète pas tant que l'article reste sous son seuil — sinon chaque sortie d'un
   article durablement bas renverrait un message et on cesserait de les lire — et repart quand
   il remonte puis redescend. Un réglage qui ne commande rien est pire qu'un réglage absent.

7decies. **Un message porte les destinataires qu'il avait AU DÉPÔT.** C'est juste — un message
   est un fait, pas une intention — mais quand on corrige une adresse après coup, les messages
   déjà en file gardent l'ancienne et échouent indéfiniment : on croit que la correction n'a
   servi à rien. `/administration` montre donc **à qui** chaque file est adressée, et offre deux
   issues sur une file en échec : **réadresser** aux destinataires réglés aujourd'hui — en
   gardant, pour le « lot rendu », l'adresse propre à l'intervenant, qui ne figure dans aucun
   réglage — ou **abandonner**, ce qui EFFACE les messages. Jamais un `envoye_le` posé sur un
   message qui n'est pas parti : ce serait prétendre l'avoir envoyé. L'erreur affichée porte
   enfin la date du dernier essai (`dernier_essai_le`, migration 0012) : sans elle, un refus
   d'il y a deux jours passe pour un refus de maintenant, et on recorrige ce qui était déjà
   corrigé.

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

14sexies. **Après « C'est fait », on revient SUR la ligne, pas en haut de la liste.** Le renvoi
   porte l'ancre de l'anomalie : l'écran s'ouvre dessus, cochée, barrée, sur fond vert, avec le
   matériel sorti. Revenir en haut de cent dix-neuf lignes ne disait pas ce qui avait changé.
   L'écran d'intervention se lit comme une liste de tâches — le jour en gros, l'avancement
   dessiné, ce qui presse en tête, ce qui est déjà déclaré en bas sous « Déjà déclarées ».

14octies. **L'ordre de la liste est celui du bâtiment, pas celui de l'alphabet.** Trier d'abord
   par priorité mettait l'urgent du cinquième avant le reste du rez-de-chaussée : on redescendait,
   on remontait. Et trier les lieux par leur nom renvoyait « 4eme étage » — le palier, qui est un
   lieu comme un autre — après la chambre 39, donc au milieu du troisième. L'ordre est donc
   `etages.ordre`, puis le lieu dans l'étage, puis la priorité pour départager deux lignes du
   même endroit ; en regardant « Tout », un intertitre marque le changement d'étage.

14septies. **Les étages sont des onglets, sur le côté.** Cent dix-neuf lignes à faire défiler
   pour trouver le troisième étage, ce n'est pas une liste, c'est un rouleau. L'écran
   d'intervention porte une colonne d'onglets verticaux dans l'ordre du bâtiment, une couleur
   par étage et le reste à traiter sur chacun — on reconnaît sa bande avant de lire son nom,
   comme la bouteille bleue et la bouteille rouge. **Les bandes se partagent toute la hauteur
   visible** : une colonne d'onglets serrés en haut se vise mal avec le pouce. L'onglet choisi
   reste même s'il ne reste rien dessus, sinon on se retrouve devant une liste vide sans savoir
   où l'on est. Le compteur du haut et « Fin d'intervention » portent sur TOUT le passage,
   jamais sur l'étage regardé. **Choisir un étage se fait en `replace`, pas en `push`** :
   changer d'étage n'est pas naviguer, et la flèche arrière remontait le premier étage, puis le
   cinquième, puis le premier, au lieu de sortir de l'écran. Une **recherche** filtre sur la
   description et le lieu — « mitigeur », « 27 » — en gardant l'étage regardé. **La poubelle
   supprime**, au bout de la ligne, là où on la lit.

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

16sexies. **Une date lue dans un tableur n'est pas une date.** L'export donnait les dates en
   TEXTE, dans deux formats mélangés — « 17/12/2024 » et « 2025-09-12 » — et l'import a dû
   deviner : **270 dates de déclaration et 229 dates d'intervention** avaient le jour et le mois
   inversés. Une date d'intervention fausse met le passage au mauvais jour, et la facture ne se
   rapproche plus. L'export nettoyé les rend en vraies dates ; `outils/reprendre_export.py` les
   réaligne sur une base VIVANTE, et la migration 0015 fait suivre les passages
   (`fn_regrouper_les_passages()`, rejouable). Ne jamais faire deviner un format de date à
   l'import : le corriger à la source est le seul chemin qui ne laisse pas de trace fausse.

16septies. **Une reprise d'export ne touche que ce que le tableau possède.** Depuis l'import,
   l'application a produit des photos, des commentaires, des dossiers bouteille, des entrées de
   stock, des factures, et des anomalies déclarées directement. Le rattachement se fait sur
   `anomalies.sharepoint_id` : une anomalie sans cet identifiant vient de l'application et reste
   hors de portée. Et **une reprise ne remplace jamais une valeur par du vide** — l'export écrit
   « ALAIN », la table dit « Alain » ; la jointure est donc insensible à la casse, et si un nom
   ne se rattache à personne on garde ce que la base sait déjà. Écraser l'intervenant d'un
   passage parce qu'une capitalisation diffère serait une perte, pas une correction.

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
donnees/installation/  les fichiers à jouer en production, dans l'ordre d'ordre.txt,
                       produits par outils/preparer_installation.sh — jamais
                       édités à la main. Le DERNIER regroupe les passages : la
                       migration qui le fait est jouée avant les données, elle
                       n'a rien à regrouper à ce moment-là
donnees/export/        l'export « TEST Tech 3 » de l'hôtel, source de tout côté
                       technique. `importer_anomalies.py` en fait une base
                       neuve, `reprendre_export.py` aligne une base vivante
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

**L'adresse du profil d'un intervenant S'AJOUTE aux destinataires réglés, elle ne les remplace
pas.** `alertes_destinataires` porte le côté hôtel ; `deposerRecap()` y ajoute l'adresse de
l'intervenant pour le message « lot rendu » seulement. Le récapitulatif complet ne concerne que
l'hôtel. Les deux écrans le disent, parce que la question se pose naturellement en réglant l'un
sans l'autre.

**Chaque intervenant peut recevoir son récapitulatif de fin de passage**, à l'adresse notée sur
la même ligne. Le message « lot rendu » part chez lui ET chez Miguel : il est en copie, jamais
court-circuité. Le récapitulatif complet, lui, ne concerne que l'hôtel — il porte l'avis de la
gouvernante, y compris ce qu'elle n'a pas validé.

**La liste des intervenants se tient depuis l'application.** Un renfort ponctuel s'ajoute et se
retire d'un appui dans `/administration/equipe` ; ce qu'il a fait reste attaché à son nom.
Retirer, c'est `intervient_technique = false` pour une personne et `actif = false` pour une
entreprise — jamais une suppression. **Les retirés ne se lisent pas dans `v_intervenants`** :
la vue ne retient que `intervient_technique`, et ils en disparaissaient entièrement, sans plus
aucun moyen de les remettre. Ils ont leur propre requête, et leur propre repli. Un geste qui
ajoute ou retire rouvre la section et affiche le nom : sans cela la page se rechargeait repliée
et l'appui paraissait n'avoir rien fait.

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

**Un formulaire validé n'est plus un écran de saisie.** On déclare une perte, on arrive sur le
dossier, on revient en arrière — et le formulaire revient, rempli comme avant l'envoi. Rien ne
dit qu'il est déjà parti : on corrige, on renvoie, et le dossier existe deux fois. L'écran
d'arrivée pose une marque (`<MarquerValide>`), le formulaire la trouve en se remontant,
**l'efface** et repart d'où l'on vient (`<QuitterSiRevenu>`). L'effacer au passage est ce qui
distingue le retour en arrière d'une nouvelle saisie : rouvrir l'écran plus tard fonctionne
normalement.

**Un écran de décision n'est pas un écran de lecture.** Le routeur garde la page qu'on quitte et
la ressort telle quelle à la flèche arrière — c'est ce qui rend la position de lecture. Mais
après avoir validé le dernier avis d'un lot, revenir en arrière reproposait de décider : on
croyait que rien n'avait été enregistré. `RelireAuRetour` marque le premier passage et redemande
la page au serveur si l'on revient ; l'écran de validation renvoie alors vers la liste, puisqu'il
n'y a plus rien à décider. Le poser sur tout écran dont l'état change en le quittant.

**Corriger une donnée n'est pas un geste de terrain.** La description, la priorité, la date de
déclaration **et le lieu** d'une anomalie se corrigent depuis sa fiche ; la date d'un passage
depuis le passage, et elle déplace TOUTES ses interventions avec lui — un passage ne s'étale pas
sur deux jours, et c'est la date qui permet à la facture de se rapprocher. Réservé à
`suitLesDossiers` (Sarah P et Miguel). **Le lieu se corrige parce que la reprise s'est trompée de
porte** : l'ancienne application avait un champ libre, et « lavabo bouché » s'est retrouvé sur le
palier du 4ème. Sans correction, l'historique de la chambre est faux pour toujours, et le
comptage des récurrences avec lui. Le déplacement peut se heurter à
`anomalie_unique_ouverte_par_lieu` : on rend le refus (code 23505) en clair, on ne l'avale pas.
L'état, lui, ne se corrige jamais ici : il se décide en déclarant, en intervenant ou en validant.

## Photos

Une anomalie porte deux séries : **au constat**, prises par qui déclare, et **après
intervention**, prises par le technicien. Les deux sont facultatives et les deux s'affichent
dans l'historique du lieu. Le technicien voit les photos du constat avant d'intervenir.

**Miguel ajoute lui-même les photos** : celles des bouteilles depuis `/administration/bouteilles`,
celles des produits **en appuyant sur la vignette du produit** — elle mène à
`/stock/produit/[id]/photos`, où l'on consulte, ajoute, met en avant et supprime. L'image est sa
propre porte d'entrée. Sans photo, l'écran dessine la bouteille à sa couleur — il n'attend jamais
une image pour fonctionner.

**Une galerie n'est pas un panneau replié.** Elles vivaient dans un tiroir qui montait du bas de
la fiche et défilait dans lui-même : ce qu'on venait de choisir et le bouton d'enregistrement
tombaient hors de vue, alors on rechoisissait la même photo — quatre fois. Un écran règle les
trois défauts d'un coup : en-tête, retour vers la fiche, confirmation en haut, et **on y reste
après l'ajout**, les nouvelles photos sous la confirmation.

**Le technicien les voit TOUTES, pas seulement celle mise en avant.** On en ajoutait quatre et il
n'en voyait qu'une : les trois autres n'existaient nulle part pour lui, alors que ce sont elles
qui montrent le filetage, le dos, la référence imprimée. `PhotoProduit` prend la liste entière,
avec les flèches et le glissement du doigt, et une pastille sur la vignette dit combien il y en
a — sans elle, rien n'indique qu'il y a autre chose à regarder.

**Un bouton dans un lien reste un lien.** La photo d'un article ouvrait sa fenêtre ET ajoutait
l'article : `preventDefault()` et `stopPropagation()` n'y suffisaient pas. Elle est désormais
placée À CÔTÉ du lien, jamais dedans — il n'y a plus rien à arrêter. Et à 92 px, le nom et les
boutons de quantité ne tiennent plus sur la même ligne qu'elle : la carte d'un article retenu se
lit sur deux lignes, le nom en haut, les gestes en dessous.

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

**L'application se met à jour elle-même.** `/administration` joue les migrations manquantes, sur
un bouton, réservé à l'administrateur. Aller sur GitHub, trouver l'onglet Actions et lire un
journal pour savoir si une colonne existe, c'était trois allers-retours pendant lesquels des
boutons restaient grisés sans explication. `lib/migrations.ts` lit `supabase/migrations/`,
compare à `migrations_appliquees` — la même table que le script de GitHub, donc les deux chemins
se complètent — et joue chaque fichier **dans une transaction** : il passe entièrement ou pas du
tout, et un échec arrête la série au lieu de migrer à moitié. L'écran nomme le fichier fautif et
rend l'erreur telle quelle. `outputFileTracingIncludes` fait partir les fichiers `.sql` avec le
déploiement : sans cette ligne Vercel ne garde que ce que le code importe, et le bouton ne
trouverait rien à jouer.

**L'application dit quelle version est en ligne.** « Les modifications ne sont pas là » et « le
code est poussé » peuvent être vrais en même temps : entre les deux il y a un déploiement, qui
peut ne pas avoir eu lieu, avoir échoué, ou être servi depuis le cache du téléphone. Sans repère,
on compare des écrans de mémoire et on se trompe. `/administration` affiche le commit déployé et
**le titre de son message**, qui se lit en français — la comparaison prend une seconde.
`lib/version.ts` le lit dans les variables système de Vercel, et dit « inconnue » plutôt que
d'inventer quand le projet ne les expose pas.

**L'application dit elle-même ce que la base sait faire.** Le code part en ligne avant la
migration : entre les deux, un bouton est grisé sans que rien n'explique pourquoi — « donner un
profil ne fonctionne pas ». `lib/capacites.ts` liste les capacités et leur sonde
(`colonneExiste`, ou `regleContient` quand la migration ne touche qu'une fonction, comme la
0011), et `/administration` les affiche avec le geste qui débloque. Un écran bloqué renvoie vers
cette liste au lieu d'afficher un bouton mort. Ajouter une migration qui change ce que l'on peut
faire, c'est ajouter une ligne ici.

**Le stock se lit par ordre alphabétique.** Mettre les alertes en tête paraissait utile, mais la
place d'un article changeait selon son stock du jour et on ne savait plus où le prendre : la
liste dit **où trouver**, les compteurs et le filtre « sous le seuil » disent l'urgence. L'ordre
est posé dans la requête, sans casse ni accent — la collation d'une installation à l'autre place
« BOUILLOIRE » avant ou après « Batteries ». Les deux colonnes de catégories de l'hôtel — le
**rayon** (`categorie_lieu`) et le **métier** (`categorie`) — se croisent dans un dépliant, et
les rayons se regroupent sans tenir compte de la casse : la reprise a laissé « Salle de Bain » et
« Salle de bain », donc deux pastilles pour un seul rayon.

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

**Un essai ne sort rien de la réserve.** Cocher du matériel pour une anomalie en 06 le déduisait
du stock pour de bon, et le comptait dans le coût du passage — or personne n'est allé chercher la
pièce sur l'étagère. La ligne de mouvement RESTE, avec son lieu : le technicien doit revoir ce
qu'il a coché et la gouvernante doit pouvoir le valider, c'est tout l'intérêt de répéter. C'est le
lieu qui dit qu'elle ne compte pas. La définition d'un vrai mouvement est posée **une seule fois**,
dans `v_mouvements_reels` (migration 0013) ; `v_stock_produits` et `v_interventions_cout` la
lisent. Ne jamais refaire ce filtre vue par vue — une seule oubliée et les essais reviennent dans
les chiffres. L'écran du matériel le dit avant de cocher, et l'historique du produit marque la
ligne « essai · non déduit » : sans cela l'historique ne tombe plus juste.

## Écrans

- **La maison ramène à l'accueil, de n'importe où.** Depuis le fil d'une anomalie ouverte au
  bout de cinq écrans, rentrer demandait cinq appuis — on finissait par fermer l'application
  pour la rouvrir. Elle est dans l'en-tête, à l'opposé du retour : deux gestes différents, le
  pouce ne doit pas hésiter.
- **Un dépliant se voit comme tel.** `list-none` retirait le triangle du navigateur sans rien
  mettre à la place : il restait un titre qui ne ressemblait pas à un bouton, et on ne trouvait
  pas les intervenants. `Depliant` et `LigneDepliante` (`app/composants/depliant.tsx`) posent un
  chevron qui pivote, un titre assez grand pour le pouce, et le compte à droite — « 4 prénoms »
  se lit plus vite qu'on n'ouvre. Les groupes CSS y sont **nommés** (`group/section`,
  `group/ligne`) : sans cela, ouvrir une section fait pivoter tous les chevrons qu'elle contient.
- **Le retour ramène d'où l'on vient, pas à un parent supposé.** Chaque écran désignait son
  parent en dur : consulter une ancienne intervention depuis l'historique d'une chambre, puis
  revenir, renvoyait à l'historique complet et non à l'endroit quitté. Le composant `Retour`
  refait le geste de la flèche du navigateur ; l'adresse passée à `Entete` n'est plus qu'un
  filet, pour l'ouverture directe d'un lien partagé ou l'application lancée depuis l'écran
  d'accueil. Il ne sort jamais de l'application.

  **Ni `history.length` ni `document.referrer` ne répondent à « y a-t-il un de nos écrans
  derrière ? ».** La première ne dit pas ce qui nous appartient. Le second ne change JAMAIS
  pendant une navigation Next — il garde la valeur du dernier chargement complet : ouvrir
  l'application une fois depuis un lien reçu dans un message la fixait sur l'origine de ce
  message, et chaque retour, ensuite, poussait le parent écrit en dur. `Parcours`
  (`app/composants/parcours.tsx`), posé dans la mise en page, compte NOS écrans : avancer
  allonge l'historique, remplacer ne le touche pas, revenir non plus mais `popstate` a eu lieu.
- **Un écran annoncé doit exister.** `/gouvernante/historique` disait « arrive dans la
  prochaine étape » alors que la tuile de l'accueil y menait avec son compte de lieux
  récurrents : la pire impasse est celle qui annonce quelque chose. Il répond maintenant à deux
  questions et pas à d'autres — **où est-ce que ça revient ?** (`v_frequence_anomalie_lieu`, la
  raison d'être du catalogue fermé) et **que s'est-il passé ici ?**, le chemin vers l'historique
  d'un lieu, qu'on ne pouvait atteindre qu'en passant par l'écran de déclaration.
- **Un dossier bouteille montre où il en est avant ce qu'il contient.** Cinq boutons de cinq
  couleurs côte à côte ne disaient pas lequel était le pas suivant — et « Facturé », plein et
  vert, ressemblait au geste principal alors qu'il clôt le dossier. La frise dessine l'avancement,
  une phrase le dit en mots, UN bouton porte le pas suivant, et les trois issues sont groupées
  sous « Clore le dossier ». La gouvernante garde ses trois issues : on les range, on n'en retire
  aucune.
- **En déclarant, la gouvernante ne voit que ce qui reste à traiter** dans le lieu — à faire, en
  cours, achat à faire. L'historique complet est derrière un lien, jamais dans le chemin de saisie.
  Il a toute sa place ailleurs : historique du lieu, rapports.
- **La bulle de commentaires s'ouvre.** Elle affichait un nombre et rien d'autre : on voyait
  qu'il y avait eu des mots sans pouvoir les lire. `ApercuFil` les montre dans une fenêtre
  native — pas un écran de plus, on ne perd pas sa place.
- **Une ancienneté porte sa date entre parenthèses.** « il y a 6 mois » se lit d'un coup d'œil
  et suffit la plupart du temps — mais pour rapprocher un dossier d'un passage, d'une facture ou
  d'une conversation, il faut le jour, et le recalculer de tête n'a pas de sens quand il tient en
  huit caractères. `depuis()` de `lib/domaine.ts` rend « il y a 6 mois (12/06/2026) » ; aujourd'hui
  et hier s'en passent, la date n'y apprend rien.
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
