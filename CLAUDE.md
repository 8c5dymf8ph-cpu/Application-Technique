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
2. **Une bouteille emportée n'est pas perdue.** Elle passe en position `chez_client` et peut
   revenir. Le parc ne diminue qu'à la facturation, à la non-restitution ou à la casse. La
   re-dotation d'une chambre est un déplacement `reserve → emplacement`, jamais une seconde
   sortie de parc. Une bouteille restituée rejoint la **réserve**, pas la chambre.
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
   tombent sous le seuil en même temps.
8. **Une anomalie hors catalogue ne se crée que par un admin**, depuis un ordinateur. La règle est
   dans la RLS : ne pas la déplacer dans l'interface.
9. **Le technicien rend un lot, la gouvernante valide à l'unité.** Une `tournee` regroupe les
   anomalies traitées ensemble (l'ancien `InterventionID`). Le mail récapitulatif ne part que
   lorsque `v_tournees.prete_pour_recap` est vrai et que `mail_recap_envoye_le` est nul : la
   gouvernante peut valider en plusieurs sessions sans déclencher d'envoi prématuré.
10. **La gouvernante a trois issues**, pas deux : `validee`, `en_cours`, `a_refaire`. Ne jamais
   réduire le choix à valider/refuser.
11. **Les commentaires ne s'empilent pas dans un champ texte.** Chaque avis est une ligne de
   `validations` avec son auteur et sa date ; `v_fil_commentaires` reconstitue le fil.
12. **Un ajustement de stock porte toujours un motif** (`inventaire`, `casse`, `perte`,
   `erreur_saisie`, `autre`). Seul le motif `inventaire` exige un comptage complet : une casse
   se corrige au fil de l'eau.
13. **Le technicien dit toujours s'il a utilisé du matériel**, anomalie par anomalie, en le
   choisissant dans la liste des produits avec leurs photos. « Aucun matériel » est une réponse
   explicite, pas une absence de réponse.
14. **Une section spécialisée ne montre que son métier.** Sans ligne dans
   `specialites_intervenant`, un intervenant est polyvalent ; avec, il ne voit que ses types.
   La règle vaut pour les salariés comme pour les entreprises extérieures.
15. **Il n'y a pas de bouton « recalculer le stock ».** Rien n'est stocké, donc rien à recalculer.
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

## Contraintes d'usage

- Utilisée sur téléphone, en déplacement dans l'hôtel : chaque écran doit rester utilisable
  à une main, et la saisie d'une sortie de matériel ne doit pas dépasser quelques appuis.
- Le réseau peut sauter (sous-sol, chaufferie) : toute écriture passe par la file d'attente
  locale, jamais par un appel direct bloquant.
- Budget 0 € : rester dans les offres gratuites Supabase / Vercel / Resend.
