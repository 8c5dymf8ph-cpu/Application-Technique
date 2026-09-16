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
2. **Une bouteille emportée sort du parc détenu, sans être perdue pour autant.** `parc_detenu`
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
   anomalies traitées ensemble (l'ancien `InterventionID`). Le mail récapitulatif ne part que
   lorsque `v_tournees.prete_pour_recap` est vrai et que `mail_recap_envoye_le` est nul : la
   gouvernante peut valider en plusieurs sessions sans déclencher d'envoi prématuré.
11. **La gouvernante a trois issues**, pas deux : `validee`, `en_cours`, `a_refaire`. Ne jamais
   réduire le choix à valider/refuser.
12. **Les commentaires ne s'empilent pas dans un champ texte.** Chaque avis est une ligne de
   `validations` avec son auteur et sa date ; `v_fil_commentaires` reconstitue le fil.
13. **Un ajustement de stock porte toujours un motif** (`inventaire`, `casse`, `perte`,
   `erreur_saisie`, `autre`). Seul le motif `inventaire` exige un comptage complet : une casse
   se corrige au fil de l'eau.
14. **Le technicien dit toujours s'il a utilisé du matériel**, anomalie par anomalie, en le
   choisissant dans la liste des produits avec leurs photos. « Aucun matériel » est une réponse
   explicite, pas une absence de réponse.
15. **Une section spécialisée ne montre que son métier.** Sans ligne dans
   `specialites_intervenant`, un intervenant est polyvalent ; avec, il ne voit que ses types.
   La règle vaut pour les salariés comme pour les entreprises extérieures.
16. **Il n'y a pas de bouton « recalculer le stock ».** Rien n'est stocké, donc rien à recalculer.
   Ne jamais réintroduire `Stock_Initial`, `StockActuel` ni `EstHistorique`.

## Base de données

```
supabase/migrations/   schéma, vues, règles, sécurité — jouées dans l'ordre
supabase/seed/         référentiels (étages, emplacements, types, dotations)
supabase/tests/        scénarios métier, à rejouer après toute modification du schéma
```

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

## Rôles

| Rôle | En plus du précédent |
|---|---|
| `technicien` | Traite ses anomalies, dit s'il a pris du matériel |
| `gouvernante` | Déclare, valide, déclare au nom d'un intervenant |
| `operations` | Supprime une anomalie (Sarah P, chargée des opérations) |
| `admin` | Référentiels, catalogue, paramétrage (Miguel) |

Supprimer une anomalie efface une trace : réservé à `operations` et `admin`, jamais à la
gouvernante. La règle est dans `fn_peut_supprimer` et dans la politique de suppression.

## Photos

Une anomalie porte deux séries : **au constat**, prises par qui déclare, et **après
intervention**, prises par le technicien. Les deux sont facultatives et les deux s'affichent
dans l'historique du lieu. Le technicien voit les photos du constat avant d'intervenir.

Le stockage passe par `lib/stockage.ts` : disque en développement, Supabase Storage en
production. Rien d'autre dans l'application ne connaît autre chose qu'un nom de fichier.

## Écrans

- **En déclarant, la gouvernante ne voit que ce qui reste à traiter** dans le lieu — à faire, en
  cours, achat à faire. L'historique complet est derrière un lien, jamais dans le chemin de saisie.
  Il a toute sa place ailleurs : historique du lieu, rapports.
- **Les listes longues se replient.** Les étages, les sections d'un écran : sur un téléphone tenu
  d'une main, faire défiler trois écrans avant d'atteindre le cinquième étage est un défaut.

## Contraintes d'usage

- Utilisée sur téléphone, en déplacement dans l'hôtel : chaque écran doit rester utilisable
  à une main, et la saisie d'une sortie de matériel ne doit pas dépasser quelques appuis.
- Le réseau peut sauter (sous-sol, chaufferie) : toute écriture passe par la file d'attente
  locale, jamais par un appel direct bloquant.
- Budget 0 € : rester dans les offres gratuites Supabase / Vercel / Resend.
