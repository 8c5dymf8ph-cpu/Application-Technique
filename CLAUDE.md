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
4bis. **Le stock repris est la somme des mouvements, pas le chiffre de l'ancienne
   application.** L'import posait vingt-deux régularisations pour recaler chaque produit sur ce
   qu'affichait l'ancienne application — or elle ignorait 249 mouvements sur 261
   (`EstHistorique`) et son chiffre était faux. Viser ce chiffre, c'était réintroduire
   `Stock_Initial` sous le nom de « régularisation », et couvrir l'écart d'un comptage que
   personne n'avait fait. Les entrées viennent du tableau des mouvements, les sorties de
   l'export des anomalies, et **le signe du tableau est une information** : « Entrée −8 », ce
   sont huit pièces reparties chez le fournisseur, donc une sortie — `abs()` en faisait une
   entrée et le stock portait seize pièces de trop. Là où la somme passe sous zéro (cinq
   produits), l'étagère n'était pas vide quand le tableau a commencé : l'écran dit **« à
   compter »** et non « épuisé », parce que ce n'est pas un stock vide, c'est un stock faux, et
   que le seul chemin est un inventaire. **Un comptage reste vrai quand le théorique change** :
   la 0017 recalcule l'écart des inventaires de l'application, elle n'efface pas ce qui a été
   compté.

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

7duodecies. **Une action serveur ne se referme pas non plus sur une fonction déclarée à côté
   d'elle.** Le pendant de 7undecies, du côté des fonctions ordinaires. `reprendre()` appelait
   `versLaListe()`, une fonction déclarée dans le même composant : Next essaie alors de
   l'envoyer au navigateur pour l'amélioration progressive et refuse — « Functions cannot be
   passed directly to Client Components ». **Le typage n'en dit rien, et l'écran se tait** :
   « Reprendre le passage » ne faisait simplement rien, sans un mot. Une fonction qu'une action
   utilise vit au niveau du MODULE et reçoit ce dont elle a besoin en arguments. C'est ce qui a
   été attrapé dans un vrai navigateur, pas par `tsc` ni par le build.

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
9quater. **Créer un libellé, c'est aussi dire de quel métier il est.** « Poignée de porte qui
   grince » peut être un travail de menuiserie ou d'électricité selon ce qu'il y a derrière, et
   rien ne permet de le deviner : un métier posé par défaut range au hasard, et la section
   spécialisée d'un intervenant (règle 15) devient fausse. Le formulaire demande donc les trois
   choses — le libellé, corrigeable avant d'entrer au catalogue pour toujours, le métier, sans
   valeur par défaut, et si ça presse.

9bis. **Le libellé qui manque se crée — et il REJOINT le catalogue.** Le catalogue fermé est ce
   qui rend le comptage des récurrences possible (règle 8) ; mais un catalogue qu'on ne peut pas
   enrichir depuis le terrain finit par mentir — on déclare « autre chose » à la place, ou on ne
   déclare pas. L'écran de déclaration renvoyait « demandez à l'administrateur » à
   l'administrateur lui-même. Sarah P et Miguel ajoutent donc le libellé depuis l'écran, et il
   entre dans le catalogue : la fois suivante, le même problème portera le même mot. La règle
   reste dans la RLS (`fn_peut_enrichir_le_catalogue`), comme l'exige la règle 9 — elle
   s'élargit, elle ne se déplace pas dans l'interface.

9quinquies. **Le même constat se déclare dans plusieurs lieux d'un seul geste.** On change
   les mitigeurs d'un étage, la même liseuse lâche dans quatre chambres : c'est UN constat, et
   le refaire chambre par chambre demandait quatre fois six appuis. Le formulaire porte donc
   « Aussi ailleurs » — les lieux en pastilles, dans l'ordre du bâtiment — et le bouton compte
   ce qui part (« Déclarer dans 4 lieux ») : sans ce compte, rien ne disait que les cases
   avaient été prises. Ce qui ne change pas : **chaque lieu garde SA ligne** (règle 16bis), et
   un libellé déjà ouvert quelque part n'y est pas proposable — il est marqué, grisé, non
   cochable, parce que la base le refuserait (règle 8) et que le dire vaut mieux que de laisser
   échouer. La **photo reste sur le lieu d'où l'on déclare** : elle montre cette chambre-là,
   l'attacher aux autres serait un mensonge ; le **commentaire suit partout**, c'est le même
   constat dit une fois. Le retour nomme ce qui est parti ET ce qui a été sauté. Réservé à
   `peutValider`, et revérifié à l'écriture : un lien recopié ne doit pas passer.

9ter. **Un avis peut être donné AU NOM de quelqu'un d'autre.** Un passage de juin a été vérifié
   par Victoria, pas par celui qui le saisit aujourd'hui : sans ce choix, le récapitulatif dirait
   « validé par Miguel » pour un travail qu'il n'a pas vu. `validations.utilisateur_id` porte qui
   décide, `saisie_par` qui tape — les deux existaient déjà, l'écran ne s'en servait pas.
   Réservé à `suitLesDossiers` : en cours de journée, c'est celle qui regarde qui décide.

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

10septies. **Un passage, c'est qui est venu et quel jour — et l'index le tient.** `tourneeEnCours`
   ne rendait la tournée du jour que si elle était ENCORE OUVERTE : le technicien rendait son lot
   le matin, revenait l'après-midi, et un second passage naissait. Trois passages dans
   l'historique pour une journée, trois récapitulatifs, trois fois ceux de la gouvernante — c'est
   le « dix mails par jour » de l'ancienne application — et une facture qui ne se rapproche plus
   de rien de net. La règle est désormais en base (`passage_unique_par_intervenant_et_jour`), pas
   dans l'écran : `fn_creer_tournee` RETROUVE la tournée du jour, rendue ou non, et
   `fn_fusionner_les_passages_du_jour()` ramène l'existant à un passage par journée.
   **Un passage se reprend**, et la reprise est le miroir exact de la clôture :
   `tg_reouverture_tournee` retire de la file de la gouvernante ce qu'elle n'a pas encore
   tranché — elle ne doit pas valider un travail qu'il est en train de reprendre — et ce qu'elle
   a tranché ne bouge pas, sa décision est un fait. Le récapitulatif qui n'était pas encore parti
   est retiré de la file (`annulerRecapNonParti`) ; celui qui est parti reste parti, on ne
   prétend pas le contraire.

10octies. **« Fin d'intervention » se confirme, il ne se déclenche pas.** Le bouton envoie un
   message, et c'est irréversible pour qui le reçoit : un appui de trop à 9 h et le récapitulatif
   annonce deux anomalies sur douze. Un décompte ferait attendre sans rien apprendre ; ce qui
   empêche l'erreur, c'est de VOIR ce qui part — combien de déclarées, combien restent, et à qui
   ça va — puis de répondre « Oui, j'ai fini ». Et comme le passage se reprend, l'erreur ne coûte
   plus une journée. Ne jamais faire partir un message sur un seul appui.

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

10sexies. **Ce qui attend la gouvernante, c'est une anomalie en `attente_validation`, rien
   d'autre.** L'écran « À valider » en annonçait 343 alors que la base n'en portait AUCUNE :
   `v_tournees.nb_en_attente` comptait toute intervention « sans avis de gouvernante », et
   l'historique repris en porte des centaines — du travail fait et clos dans l'ancienne
   application, où la colonne de vérification n'a été tenue qu'à partir de 2026. L'import
   l'avait vu et les avait closes ; la vue comptait autrement, et l'arriéré revenait par la
   fenêtre. Une règle appliquée à un endroit et pas à l'autre ne vaut rien. Les deux conditions
   se cumulent et ne se remplacent pas : **le lot est rendu** (10bis) ET l'anomalie lui a été
   remise. Un passage `reprise` n'envoie jamais de récapitulatif, même complet — un message
   arrivant aujourd'hui pour un passage d'avril ne se comprend pas.

10ter. **Un intervenant ne voit que sa tournée.** Ni le coût d'un passage, ni les factures, ni la
   valeur du stock, ni l'historique : il vient traiter des anomalies. Désigner qui intervient est
   une décision d'encadrement — Victoria, Miguel, Sarah P, c'est-à-dire `peutValider`. La règle
   est dans `lib/acces.ts` (`exigerEncadrement`), et les écrans de `/technique` la posent tous.
   Ne jamais rouvrir ces écrans à un technicien « pour dépanner ».

10nonies. **Un passage passé se saisit à SA date, depuis l'écran d'intervention habituel.**
   Miguel et Sarah P (`suitLesDossiers`) reprennent de l'historique : `/technique/intervenants`
   porte « Saisir un passage passé » — qui, quel jour — et renvoie sur `/technique/<nom>?jour=…`.
   Rien de nouveau à apprendre : mêmes étages, même liste, même « C'est fait », même matériel.
   Ce qui change se voit — **le jour en gros est celui du passage**, pas celui de l'horloge, et
   un bandeau ambre dit que tout ce qu'on coche portera cette date. Le jour suit ensuite partout :
   les onglets d'étage, le lien vers l'anomalie, la déclaration (`declare_le`), la clôture. Un
   technicien ne date pas son passage : il vient aujourd'hui.

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

16quinquies bis. **Le coût d'une facture se lit sur la facture, additionné.** Le matériel et le
   montant facturé étaient affichés côte à côte sans jamais être additionnés — or c'est la somme
   qu'on cherche quand la facture arrive, et une facture couvre souvent plusieurs interventions.
   L'écran d'une facture porte donc « Ce qu'elles ont coûté » : matériel sorti, facturé par
   l'intervenant, total — et chaque ligne dit ce qu'elle pèse, sa part de la facture comprise
   (`v_cout_prestataire` répartit à parts égales faute de `montant_affecte`). Tout était déjà
   calculé en base ; il manquait de le montrer. Un total incomplet le dit (règle 6), et un
   montant non saisi le dit aussi plutôt que d'afficher le matériel seul comme si c'était tout.

16duodecies. **La facture d'un passage se règle ENTIÈREMENT depuis le passage — un seul écran.**
   C'était deux écrans pour une seule chose : ici le montant et la pièce, là-bas les journées à
   rapprocher, la même facture des deux côtés et un aller-retour entre les deux. Un pont entre
   eux ne suffisait pas : « je veux réellement que les deux écrans soient un seul et même
   écran ». Le passage porte donc tout — le montant, la pièce, et **« Ce que cette facture
   couvre »** avec un + pour ajouter une journée et un − pour la retirer. Une facture de
   prestation ne se crée plus ailleurs (règle 16quater : là où on regarde le passage), et
   `/technique/facture/[id]` RENVOIE sur le passage. L'écran des factures reste pour lister, et
   pour les factures d'ACHAT, qui n'ont pas de passage. L'historique porte **la pastille** — le
   numéro de facture en vert avec le nombre de journées couvertes, ou « sans facture » en
   ambre : sans ce signe, rien ne distinguait ce qui est couvert de ce qui attend sa pièce.

16terdecies. **Un passage et une facture sont deux LECTURES, pas deux écrans.** La 16duodecies
   avait mis la facture sur le passage ; il restait deux tuiles dans Technique, deux listes, et
   la même pièce des deux côtés — « je ne veux pas de pont, je veux réellement que les deux
   écrans soient un seul et même écran ». On ne peut pas mettre un passage et une facture dans
   une seule liste : ce sont deux objets. Mais ce sont deux façons de regarder UNE chose — ce
   que l'hôtel a fait faire, et ce qu'il paye. Un seul écran, donc, `/technique/historique`,
   avec deux onglets, et un seul chemin depuis Technique. `/technique/factures` n'est plus
   qu'une redirection, pour les liens déjà partagés. **Une facture se lit par ce qu'elle
   couvre** : sa carte porte les JOURNÉES, pas « 3 interventions » — on ouvrait pour savoir
   lesquelles. Et « Passages sans facture » mène aux passages de l'intervenant : c'est le geste
   qui suit, quand la pièce arrive. Sur le passage, « Ce que cette facture couvre » n'est plus
   replié sous « Corriger la facture » — c'est la question qu'on se pose en ouvrant — et les
   gestes portent des MOTS, « + Ajouter » et « − Retirer » : un signe nu ne dit pas ce qu'il
   ajoute ni à quoi.

16quaterdecies. **Une facture couvre aussi les jours qui SUIVENT le jour où on la
   saisit.** La fenêtre des journées rapprochables était fermée d'un côté :
   `between date_reference - p_jours and date_reference`. Or `date_reference` est le jour du
   passage DEPUIS lequel la pièce a été saisie, pas le dernier jour qu'elle couvre — Serafino
   facture son mois, et la facture arrive après. Mesuré : la facture saisie sur le passage du
   23 février proposait **4 journées** ; elle en propose **16** une fois la fenêtre ouverte des
   deux côtés, dont les 24 et 25 février, que rien ne pouvait lui rattacher. « Je ne peux pas
   ajouter cet ancien passage. » Et **une journée que porte une AUTRE pièce ne disparaît
   plus** : elle était retirée de la liste (`not exists … facture_id <> f.id`), donc ni
   rattachable, ni détachable, ni même nommée — le même défaut que la 0019 corrigeait à
   l'intérieur d'une journée. Elle est écrite en pointillé, avec le numéro de la pièce qui la
   porte, et **« Déplacer ici »** la prend : une ligne ne vit que sur une facture, sinon son
   coût est compté deux fois (migration 0024). La fonction ne joignait d'ailleurs que sur
   `prestataire_id` : la facture de Farid ou de Rachid, qui facturent sans être une entreprise
   (règle 10quinquies), ne trouvait jamais une seule journée.

16quindecies. **Un passage se rattache à une facture DÉJÀ saisie.** L'autre sens du même
   geste, et celui qui manquait entièrement : depuis la facture on ajoute une journée, mais
   depuis un passage sans pièce le seul bouton offert en créait une NOUVELLE — deux factures
   pour le même mois de Serafino. Le passage porte donc « Rattacher ce passage à une facture
   déjà saisie », avec les pièces du même intervenant, la plus proche en date d'abord. Si le
   passage était sur une autre pièce, il la quitte, et l'écran le dit : l'ancienne facture
   reste dans la liste, sans journée si elle n'en couvre plus aucune — elle s'y supprime
   (règle 16decies). Ne jamais faire disparaître une pièce dans le dos de celui qui déplace.

16octies. **Un geste réversible doit pouvoir se défaire — jusqu'au bout.** Le « − » d'une
   facture détachait une intervention, et elle DISPARAISSAIT : `fn_journees_rapprochables`
   marquait la journée entière « déjà rattachée » dès qu'UNE de ses lignes l'était
   (`bool_or`), et l'écran retirait alors le seul bouton qui pouvait la ramener. Deux anomalies
   perdues, sans aucun chemin pour revenir en arrière. La fonction rend maintenant `restantes`
   — les lignes qui ne sont PAS sur cette facture — et c'est ce que le bouton rattache : une
   journée à moitié rattachée reste actionnable, et dit combien de ses lignes y sont déjà.

16undecies. **Un montant de facture ne se montre JAMAIS par anomalie.** Serafino facture son
   mois — 396 € pour tout juin, pas pour chaque robinet. Diviser ce chiffre par le nombre
   d'anomalies produit un montant que personne n'a convenu, et le poser sur une ligne le fait
   passer pour un prix : « je ne comprends pas pourquoi elle partage le montant entre toutes les
   anomalies, c'est trompeur ». La répartition RESTE dans le modèle — `v_cout_prestataire`, il
   faut bien pouvoir totaliser un passage — mais elle ne s'affiche nulle part ligne à ligne. Sur
   une ligne on lit le MATÉRIEL, qui est un vrai prix ; la facture se lit sur le passage et sur
   la facture, là où elle a un sens. (Remplace 16nonies, qui expliquait la répartition au lieu de
   la retirer : une explication ne rattrape pas un chiffre qui n'aurait pas dû être là.)

16nonies. **Une clé de répartition n'est pas un prix.** Serafino facture son mois : 396 € pour
   toutes les interventions de juin, pas pour chaque robinet. Le montant se répartit quand même
   entre les interventions couvertes — il faut bien pouvoir dire ce qu'un passage a coûté — mais
   afficher cette part sur CHAQUE ligne faisait passer une division pour un tarif négocié, et le
   calcul paraissait sorti de nulle part. L'écran mène donc avec le total, puis dit la
   répartition en une phrase : « 396 € répartis à parts égales entre 3 interventions, soit
   132 € chacune. C'est une clé de répartition, pas un prix négocié ligne à ligne. » Le matériel,
   lui, est un vrai prix : il reste sur la ligne.

16decies. **Une facture saisie pour rien se supprime.** On en crée une pour essayer, on se
   trompe d'intervenant, on la saisit deux fois — et rien ne permettait de la retirer : elle
   restait « à rapprocher » pour toujours. Réservé à `suitLesDossiers`, en deux temps, et
   l'écran dit ce que ça emporte : le rattachement part, les interventions reprennent leur coût
   matériel seul, le fichier déposé reste dans le dépôt.

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
18. **Certaines anomalies sont des HISTOIRES, et elles ont leurs propres objets.** Une anomalie
   est un problème dans un lieu, qu'on répare et qu'on clôt. Les punaises de lit n'entrent pas
   là-dedans : ça traverse des chambres et des semaines, ça enchaîne des actes dont l'ordre
   varie, et ça ne se termine pas par une réparation mais par une vérification qui revient
   négative. Mesuré sur l'export : l'histoire complète tient en **quatorze actes sur vingt-sept
   mois, et un seul était correctement en base** — deux dans l'export jamais importé, quatre en
   phrases dans un commentaire, cinq sur des notes de facture, dont celui qui clôt l'histoire.
   L'application savait que le problème avait commencé et ignorait qu'il était résolu.
   Trois objets (migration 0023), et pas un de plus :
   **le SUIVI** — permanent (il ne se clôt jamais, il porte un rythme) ou épisode, rattaché au
   permanent ; **la PORTÉE** — les lieux, avec la date d'entrée, parce qu'on s'élargit en cours
   de route ; **l'ACTE** — une ligne = un fait daté, avec sa propre portée et **un résultat par
   lieu**. C'est ce dernier point qui fait qu'un balayage de 38 chambres est UNE ligne de
   chronologie et non 38 anomalies — sans perdre la preuve qu'une chambre a été vérifiée.
   « J'ai besoin de savoir quelles chambres ont été contrôlées même si elles n'ont rien relevé. »

18bis. **Aucune machine à états.** L'ordre des traitements varie — chimique puis froid,
   l'inverse, ou les deux — une contre-visite peut s'ajouter, une chambre voisine peut entrer.
   On enregistre ce qui a eu lieu ; on ne dicte jamais la suite. L'état se CALCULE, comme le
   stock (règle 1) : **un lieu est réglé quand une vérification négative est postérieure à tous
   ses traitements et à toute vérification positive.** Une vérification `non_concluant` ne
   conclut rien et ne compte pas — la contre-visite du 05/11/2024 est exactement ce cas, et ses
   quatre chambres sont **à contrôler** depuis. C'est l'état qui manquait : traité, jamais
   revérifié, personne ne le savait. Un dossier permanent, lui, ne se « règle » pas : il porte
   le périmètre et le rythme (`periodicite_jours`), et dit quand la campagne est en retard —
   354 jours entre les deux balayages de l'hôtel, 359 depuis le dernier.

18ter. **Ce qu'un acte ne recopie jamais.** `intervention_id` pointe vers le passage quand il y
   en a un : le matériel, le coût et la facture restent où ils sont. `gratuit` et
   `hors_contrat` disent les deux sens de l'anomalie commerciale — EcoFlair a OFFERT la
   vérification du 26/11/2025, et une société sous contrat peut facturer un passage ponctuel.
   Le coût des pièces est ce qu'elles ANNONCENT, pas la comptabilité. Et on ne modélise pas les
   contrats fournisseurs : « ça aurait dû être couvert » est un jugement, pas une règle.

18quater. **Une conséquence n'est pas un événement.** « Chambre bloquée », « remise en
   vente » et « geste commercial » étaient des TYPES D'ACTE, à côté de « détection canine » :
   « ces options sont plus la conséquence que des événements ». Une ligne de chronologie qui dit
   « Chambre bloquée » et rien d'autre ne raconte rien — c'est le constat de la veille qui dit
   pourquoi, et il est trois lignes plus haut. Une conséquence PEND donc à son acte
   (`consequences_acte`, migration 0025) : elle porte les lieux qu'elle touche — une chambre se
   bloque, pas un dossier —, un montant pour le geste commercial, et **pas de date propre**,
   c'est celle du fait qui l'a causée. On lit « le 04/11, constat client, et la 34 a été
   bloquée ». Rien ne change au principe : aucune machine à états (18bis), une conséquence ne
   ferme rien et n'impose aucune suite. Le montant d'un geste commercial compte dans ce que
   l'épisode a coûté — c'est de l'argent sorti.

18quinquies. **Une étape passée se corrige — sur place.** On reprend de l'historique : une date
   lue de travers sur une note de facture, un intervenant retrouvé trois jours plus tard, une
   chambre oubliée dans un balayage de trente-huit. Sans correction, la chronologie fige la
   première saisie, et c'est exactement ce qu'on essaie d'éviter en la tenant. Un crayon au bout
   de chaque acte ouvre le MÊME formulaire que la saisie — deux formulaires pour une seule chose,
   c'est deux endroits où l'un des deux oublie un champ — avec ses lieux et leurs résultats déjà
   cochés : rouvrir un acte pour changer sa date ne doit pas coûter ses trente-huit chambres.
   Les lieux et les conséquences sont réécrits d'un bloc, les pièces déjà jointes restent.
   Retirer un acte emporte ses lieux, ses conséquences et ses pièces — c'est le geste qui défait
   une SAISIE, jamais celui qui annule un fait : un traitement qui a eu lieu se corrige.

18sexies. **Les lieux d'un acte se lisent en pastilles, et l'encadré ne s'ouvre que s'il sert.**
   Rouge pour ce qui a été trouvé, vert pour « vérifié, rien relevé », **pointillé pour le
   résultat qui n'a jamais été écrit** — sans quoi une contre-visite non conclue ressemble à une
   chambre saine. C'est la preuve qu'une chambre a été contrôlée même quand elle n'a rien relevé,
   et ça se voit d'un coup d'œil : « j'aimais bien ce visuel ». « Ce qu'il faut retenir »
   s'ouvrait en revanche sur TOUS les actes, alors qu'un balayage n'a rien à retenir : c'est un
   dépliant, ouvert pour un devis ou une note, et **un acte qui porte un commentaire le dit** par
   une bulle à côté de son titre — sinon on ne sait pas qu'il y a quelque chose à lire. Enfin,
   « Où on en est, lieu par lieu » est un CALCUL, pas une saisie : l'écran le dit, range les
   lieux par état en pastilles, et replie le détail ligne à ligne — « je ne sais pas à quoi ça
   correspond ».

18septies. **Un intertitre ne se lit pas plus petit que le texte qu'il annonce.** `etiquette`
   (10 px, capitales, gris pâle) titrait des sections dont le corps fait 15,5 px : ça ne titre
   rien, ça flotte. Les titres de section prennent `titre`, et dans la chronologie **c'est le
   FAIT qui est le titre**, la date passant au-dessus en petit — on cherche « détection canine »,
   pas « vendredi 11 octobre ». `etiquette` reste ce qu'elle est : l'étiquette d'un champ.

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
donnees/recuperation/  ce qui manque à la base et comment le remettre, produit par
                       outils/retrouver_les_anomalies_disparues.py — à jouer dans
                       l'éditeur SQL de Supabase, le 1 regarde, le 2 remet
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

**Vérifier dans un navigateur se fait sur `next start`, jamais sur `next dev`.** Dans cet
environnement, le serveur de développement ne parvient pas à hydrater : aucun composant client ne
répond, et on conclut qu'un bouton est cassé alors qu'il marche. Mesuré : `fibres React sur un
bouton` vaut 0 en `dev` et 2 sur une build — sur le MÊME commit, avant comme après une
modification. `npm run build && npx next start -p <port>` avant toute vérification au navigateur ;
et un seul serveur à la fois, `dev` et `start` se partageant `.next` se corrompent mutuellement.

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

**Sur un historique, on corrige — on ne supprime pas.** L'écran d'un lieu portait une poubelle au
bout de chaque ligne, d'un seul appui et sans confirmation : une anomalie d'il y a six mois a
disparu comme ça, « et je ne sais plus laquelle ». Or ce qu'on veut sur un historique, c'est
corriger — la reprise s'est trompée de porte, le libellé est approximatif, la date est fausse.
C'est donc un crayon, qui mène à la fiche. Supprimer reste possible depuis la fiche, où l'écran
dit d'abord ce que ça emporte.

**Une suppression laisse une trace.** Un effacement qui ne laisse RIEN n'est pas une suppression,
c'est un trou : on ne peut ni dire ce qu'on a perdu, ni le remettre. `tg_journal_suppression_anomalie`
(migration 0021) copie la ligne avant qu'elle parte — son lieu, son libellé, qui l'avait
constatée, et combien de photos, de commentaires et d'interventions s'en vont avec elle — et
`/administration/supprimees` les liste. Le journal ne voit que ce qui passe
APRÈS son installation : ce qui a disparu avant lui n'y figure pas, et l'écran le dit plutôt que
de laisser croire à une liste complète.

**Supprimer une anomalie efface une trace : trois personnes, jamais un technicien.** Victoria,
Sarah P et Miguel — c'est-à-dire `peutValider`. C'est la gouvernante qui déclare, donc c'est elle
qui se trompe de chambre ou déclare deux fois le même robinet : l'obliger à attendre quelqu'un
d'autre pour défaire son propre geste n'avait pas de sens. La règle est dans `fn_peut_supprimer`
et dans la politique de suppression. L'écran dit ce que la suppression emporte — fil, photos,
interventions — avant de la proposer. Un problème résolu se clôt, il ne se supprime pas.

**Et le matériel REVIENT en réserve** (migration 0022). Il restait auparavant sorti, le mouvement
détaché : le raisonnement — « le matériel a bien quitté l'étagère » — vaut pour un passage ancien
et clos, pas pour ce qu'on supprime vraiment, une anomalie déclarée dans la mauvaise chambre ou
deux fois, encore `a_faire` ou `en_cours`. Là, rien n'est sorti de la réserve, et la ligne
détachée la fausse dans l'autre sens : elle retire une pièce que personne n'a prise. La règle
était d'ailleurs déjà en contradiction avec elle-même — **décocher** une déclaration (règle
10bis) supprime son matériel « qui n'a donc pas été utilisé », et le même geste en plus large le
gardait. Une règle appliquée à un endroit et pas à l'autre ne vaut rien. L'écran dit AVANT
combien de pièces reviennent, et rappelle que ce qui a réellement été posé se CLÔT plutôt que de
se supprimer ; `anomalies_supprimees.nb_mouvements` le note, sinon un stock qui remonte de trois
pièces n'a d'explication nulle part.

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

## Regarder ce qui s'est passé

**Un tableau de bord et un récapitulatif répondent à deux questions différentes.** Le tableau de
bord dit **où on en est aujourd'hui** — il se regarde le matin. Le récapitulatif dit **ce qui
s'est passé entre deux dates** — il se sort en fin de mois, pour la direction ou pour rapprocher
une facture. Les mêmes chiffres ne répondent pas aux deux : ne pas en faire un seul écran.

`/bouteilles/recapitulatif` prend une période — trois raccourcis couvrent neuf cas sur dix — et
rend trois choses dans cet ordre : **entrées et sorties, récupérations comprises** (une bouteille
restituée revient dans la réserve, et c'est ce qui dit si le dispositif marche), **les
livraisons**, puis **chaque dossier par date avec son commentaire**. C'est là que se trouve ce
que les chiffres ne disent pas. Une période à l'envers se remet à l'endroit plutôt que de rendre
une page vide. La re-dotation n'entre jamais dans le solde du parc : elle déplace une bouteille,
elle n'en fait pas sortir une seconde (règle 2bis).

`/technique/tableau` reprend les mêmes marques — SVG écrit à la main, rien à charger, et **le
tableau des chiffres replié sous chaque graphique**, parce que rien ne doit être accessible
seulement en image. Il répond à quatre questions : ce qui arrive, où ça tombe, ce que ça coûte
(matériel **plus** facturé, règle 16quater), et **ce qui part de la réserve** — le stock se lisait
article par article sans jamais dire ce qu'on consomme. Réservé à l'encadrement (règle 10ter).

**Un nom de produit ne tient pas dans 62 px.** « Détection Canine », « Télérupteurs (Mécaniques)
Paris Elec » devenaient « Détectio… », « Télérupt… », « Télérupt… » : trois lignes qu'on ne
distingue plus, donc un graphique qui n'apprend rien. `Barres` prend `nomsLongs` et pose alors le
nom AU-DESSUS de sa barre. De même, « 1 679,00 € » ne tient pas dans un quart de largeur :
`eurosCourt()` arrondit, parce qu'un montant tronqué est pire qu'un montant absent — on lit
« 1 679,0 » et on croit que c'est le chiffre.

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
- **Un PDF part au lecteur du téléphone ; une image s'ouvre sur l'écran.** Le `<dialog>` a été
  essayé pour les deux, et raté pour le PDF : dans un cadre de la largeur d'un téléphone il
  arrive trop zoomé, on ne voit que la première page, et sur un ordinateur ce n'est pas mieux. Le
  lecteur du téléphone fait tout cela correctement — pages, pincement, rotation — et il n'y a
  aucune raison de le refaire moins bien. `estUnPdf()` décide, et l'écran dit « s'ouvre dans le
  lecteur PDF » AVANT l'appui, pour qu'on ne soit pas surpris de changer d'onglet.
- **Un document se regarde SUR l'écran, comme une photo.** La facture s'ouvrait dans un onglet
  et « Le fil » dans un écran de plus : on quittait l'application, et revenir demandait trois
  gestes. `VoirDocument` (`app/composants/fenetre.tsx`) ouvre un `<dialog>` natif — PDF dans un
  cadre, image telle quelle, Échap et l'appui à côté referment — et « Plein écran » reste offert
  sans être le seul chemin. Le fil passe par `ApercuFil`, qui existait déjà. Rien n'a de raison
  d'être l'exception : photos, documents et commentaires s'ouvrent tous par-dessus.
- **Revenir sur un écran, c'est le redemander au serveur — et c'est posé UNE fois.** Le routeur
  ressort la page telle qu'il l'avait mise de côté : on rapproche une facture, on joue les
  migrations, on déclare une perte, on revient, et l'écran rend le formulaire rempli, le bouton
  encore actif, le travail encore à faire. « Le retour en arrière fonctionne comme un contrôle Z
  partiel. » C'était corrigé écran par écran, à la main : **dix-sept écrans écrivaient sans la
  protection**. Une règle appliquée à un endroit et pas à l'autre ne vaut rien —
  `RelireEnRevenant` vit donc dans la mise en page, clé sur le chemin, et vaut pour tout.
  `router.refresh()` garde la position de défilement : c'est un aller-retour, et ce qui s'affiche
  est vrai. Ne plus jamais poser ça écran par écran.
- **Le fil porte l'anomalie ENTIÈRE, pas seulement les mots.** « Dès qu'on peut éviter des pages
  inutiles, on essaye. » Lire ce qui s'est passé sur une anomalie ne vaut pas un écran de plus :
  on y va, on lit trois lignes, on revient — et le retour ne ramène pas toujours là où on avait
  appuyé. La fenêtre montre donc le lieu, l'état, qui a constaté, les photos des deux moments,
  chaque passage avec son matériel et l'avis de la gouvernante, puis le fil. La FICHE ne reste que
  pour ce qui s'ÉCRIT : ajouter un mot, une photo, corriger. Une fenêtre montre, un écran modifie.
- **« Le fil » reste « Le fil », et au même endroit.** Le remplacer par un lien « La fiche » quand
  il n'y avait pas encore de commentaire déplaçait la cible d'une ligne à l'autre selon qu'il y
  avait eu des mots ou non — on ne savait plus où appuyer — et renvoyait vers un écran de plus,
  d'où le retour ne ramenait pas là où on avait appuyé. `ApercuFil` prend `libelle` et `fiche` :
  le bouton est toujours là, la fenêtre s'ouvre toujours, et elle dit « rien n'a encore été
  écrit » avec le chemin vers la fiche dedans.
- **La pastille du fil s'ouvre, partout — y compris en déclarant.** Sur l'écran de déclaration,
  `Indices` montrait l'appareil photo et la bulle et ne s'ouvrait pas : on voyait qu'il s'était
  passé quelque chose dans cette chambre sans pouvoir le lire, et il fallait quitter l'écran
  pour aller voir. C'est pourtant la question qu'on se pose juste avant de déclarer — le
  problème a-t-il déjà été traité, et qu'en a-t-on dit ? C'est donc `ApercuFil`, qui prend
  `photos` et `grand` : les deux pictogrammes sont conservés, le bouton fait 44 px de haut pour
  se viser au pouce, et il est posé **à côté** du lien, jamais dedans.
- **On crée un libellé APRÈS avoir cherché, pas avant.** L'encadré « Rien de tout ça ? » tenait
  six lignes AVANT les résultats : on tapait trois lettres et on lisait une explication sur les
  récurrences au lieu de voir ce que le catalogue proposait. C'est un bouton discret sous la
  liste, et `CreerLibelle` ouvre une fenêtre — libellé, métier, urgence, commentaire. Le métier
  arrive sur **Technique**, qui est le métier général de l'hôtel et non un rangement au hasard
  (Plomberie, Électrique et Achats sont les spécialités) ; c'est la seule exception à la
  règle 9quater, et elle vaut parce que « Technique » existe vraiment comme fourre-tout. Le
  **commentaire se saisit là** — c'est en créant le libellé qu'on a en tête ce que le mot ne
  dira jamais — et il suit jusqu'à la déclaration sans être retapé.
- **Une liste qui se tronque en silence est un mensonge.** `/technique/historique` rendait les
  50 passages les plus récents et s'arrêtait là, sans un mot : sur la base de l'hôtel,
  **46 passages sur 96 — 304 anomalies — n'existaient tout simplement pas à l'écran**, et tout
  ce qui précédait le 23/12/2025 était hors d'atteinte. « Je ne comprends pas pourquoi certaines
  anomalies n'apparaissent pas. » Les mois se **replient**, ils ne se coupent pas : une section
  par mois avec ce qu'il pèse — passages, anomalies, coût — les deux plus récents ouverts, le
  reste à un appui. Une liste longue se range ; elle ne se raccourcit jamais sans le dire.
- **Le mot cherché se surligne là où il se trouve.** Filtrer ne suffit pas : un mois déplié
  porte quarante-sept lignes, et la liste dit « il y a quelque chose ici » sans dire OÙ — on
  relit tout pour retrouver le mot qu'on vient de taper. Sur « 22 », qui est autant une chambre
  qu'un numéro d'anomalie, on ne sait même pas ce qui a répondu. `Surligne`
  (`app/composants/suivi.tsx`) marque le mot dans le libellé, le lieu, le matériel, le nom de
  l'intervenant. Le **numéro d'origine ne s'affiche QUE si c'est lui qu'on cherche** : « il n'est
  pas nécessaire dans cet écran », on y lit des libellés et pas des identifiants — mais sans lui,
  taper « 378 » trouve le passage sans dire quelle ligne a répondu. Et **chercher rouvre les mois qui répondent** :
  sinon le mot tombe dans une section restée fermée par la question d'avant, et on croit qu'il
  n'a rien donné. Une recherche est une question neuve — elle ne traîne pas les mois ouverts
  de la précédente.
- **On identifie une anomalie par son NUMÉRO d'origine.** « L'anomalie 378 », « celle de Serafino
  du 24/02 » : c'est le langage de l'hôtel, hérité de l'ancienne application. La recherche ne
  portait que sur la description, le lieu et l'intervenant — taper « 378 » ne rendait rien, et on
  en concluait que la ligne avait disparu. Elle couvre donc aussi `anomalies.sharepoint_id`.
- **Déplier un mois, c'est vouloir le lire EN ENTIER.** Un aperçu de trois anomalies obligeait
  encore à ouvrir chaque passage : « si je clique pour avoir le détail, c'est que je veux tous
  les détails des anomalies regroupées ensemble, et non devoir cliquer sur la deuxième
  intervention du mois pour avoir le détail à nouveau ». Le mois déplié porte donc TOUTES les
  anomalies de TOUS ses passages — lieu, libellé, matériel sorti, avis de la gouvernante — et on
  ne charge que les mois ouverts. L'écran sert au suivi rapide des passages : il se lit, il ne
  se parcourt pas. « Ouvrir le passage » reste au bas de chaque carte, pour la facture et les
  corrections.
- **Ce qui est déplié vit dans l'ADRESSE, pas dans le `<details>`.** `RelireEnRevenant` redemande
  la page au serveur en revenant : l'état d'un `<details>` n'y survit pas, et on remontait le
  mois qu'on venait de quitter à chaque aller-retour. `?mois=2026-04,2026-03` le dit, donc il
  survit au retour et le lien se partage tel qu'on le regarde. Basculer un mois se fait en
  **`replace` et `scroll={false}`** — déplier n'est pas naviguer (règle 14septies) — et `?mois=`
  vide les referme tous.
- **Le « + » n'est pas un bouton flottant.** Il vivait dans le coin bas-droit, par-dessus la
  liste : il masquait la dernière ligne, le pouce l'attrapait en faisant défiler, et il n'a rien à
  voir avec le geste du bas de l'écran, qui est « j'ai fini ». Il est maintenant à côté de la
  recherche — chercher et déclarer sont deux gestes du même moment, quand on arrive devant une
  porte.
- **Supprimer se confirme ; un dépliant n'est pas une confirmation.** On l'ouvre pour voir ce
  qu'il y a dedans, et le bouton rouge est déjà sous le pouce. La suppression passe donc par
  `?supprimer=1` : l'écran NOMME l'anomalie — « Supprimer "lavabo bouché" ? » — dit ce que ça
  emporte, et offre « Annuler » à côté de « Oui, supprimer ». Le même geste en deux temps que
  « Fin d'intervention ».
- **La bulle du fil promet des mots : sans mots ni photo, elle ne s'affiche pas.** Une icône qui
  annonce du contenu là où il n'y en a pas fait ouvrir pour rien. Elle est aussi passée de 19 à
  15 px : c'est un indice, pas un titre.
- **Ce qu'on vient de déclarer reste À SA PLACE le temps du retour.** Ce qui est coché passe à la
  fin de la liste — mais le renvoi porte son ancre, et l'écran s'ouvrait donc EN BAS de cent
  dix-neuf lignes : il fallait tout remonter pour reprendre. La ligne qu'on vient de cocher garde
  sa position pour ce seul affichage, cochée et barrée au milieu de ce qui reste ; au chargement
  suivant elle rejoint les autres.
- **Ce qu'on a déclaré se relit d'un appui, et avant de rendre.** Ce qui est coché passe en bas de
  la liste (14sexies) — mais sur cent dix-neuf lignes, le relire demandait de tout faire défiler,
  et on rendait son lot sans avoir revu ce qu'on rend. Le compteur du haut est devenu un bouton :
  un appui ne montre que les déclarées, le même appui ramène tout. Et la confirmation de « Fin
  d'intervention » les NOMME, dans une liste qui défile dans elle-même pour ne pas repousser les
  deux boutons hors de l'écran. Un compte ne dit pas ce qu'on rend.
- **Changer de profil se fait EN HAUT.** L'application est partagée : on la prend des mains de
  quelqu'un d'autre, et la première chose qu'on vérifie est le nom affiché. Le lien vivait tout en
  bas, après les tuiles — il fallait faire défiler pour corriger ce qu'on lisait en haut. C'est
  une pastille avec les initiales, sur la ligne du « Bonjour ».
- **Un calendrier a besoin de place SOUS son champ.** Le navigateur l'ouvre accroché au champ,
  vers le bas ; une date de facture se saisit en bas d'un formulaire, et seule la première rangée
  du calendrier restait atteignable. `scroll-margin-block-end` demande au navigateur de réserver
  58 vh sous le champ quand il y défile, et `.place-pour-le-calendrier` donne à l'écran de quoi
  défiler. Les deux ensemble : sans la seconde, il n'y a nulle part où remonter.
- **Un geste doit se voir AU MOMENT où on le fait.** Un écran tactile n'a pas de survol : entre
  l'appui et la réponse, il ne se passe parfois rien pendant une seconde, et on réappuie.
  `BoutonEnvoi` couvre les envois, pas les liens ni les onglets d'étage. La marque était là mais
  imperceptible — 1,5 % de réduction et rien d'autre. Elle est maintenant franche et **posée une
  seule fois, dans `globals.css`** : boutons, dépliants et tuiles se réduisent et s'éclaircissent,
  les liens s'éclaircissent seulement (un lien au milieu d'une phrase qui rétrécit fait sauter le
  texte). Ne pas repeindre ça écran par écran.
- **L'administration est un menu, pas un écran.** Tout y était posé bout à bout — l'état de la
  base, la file des courriels, le test du dépôt, le journal des suppressions, les destinataires
  — puis quatre tuiles tout en bas : « toutes les sous-menus en vrac ». On faisait défiler pour
  trouver, et rien ne disait ce qu'il y avait plus loin. Trois groupes, chacun avec son compte
  quand il y a quelque chose à regarder : **Réglages** (l'équipe, les bouteilles, alertes &
  courriels), **Les données** (contrôle, ce qui a été supprimé, exporter), **L'application**
  (`/administration/base` : ce que la base sait faire, où vont les fichiers). Ce qui bloque se
  dit AVANT le menu, sinon on cherche le défaut dans l'écran qui le subit. Un menu qui contient
  tout n'est plus un menu : chaque section vit sur son écran.
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
