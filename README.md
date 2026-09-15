# Application Technique — Hôtel Parisianer

Gestion des interventions techniques, du stock matériel et des bouteilles Purezza.
Remplace l'application Power Apps Canvas existante.

| | |
|---|---|
| **Utilisateurs** | Techniciens, gouvernante, direction |
| **Plateformes** | Téléphone (application installable) et ordinateur |
| **Base** | PostgreSQL / Supabase |
| **Connexion** | Microsoft 365 de l'hôtel |

## Comprendre l'application

**[Le Parisianer, mode d'emploi](https://claude.ai/artifact/7b2ByPrfTyFWW6k7UT9uUx)** — qui fait
quoi, le cycle d'une anomalie, les bouteilles, les mails, les briques techniques et leur coût.
Source : [`docs/fonctionnement.html`](docs/fonctionnement.html).

**[Maquettes des écrans](https://claude.ai/artifact/Qa89iyADqTh6eRQ55xzyN2)** — sept écrans mobiles.
Sources dans [`maquettes/`](maquettes/).

## Documentation technique

- [`docs/01-cahier-des-charges.md`](docs/01-cahier-des-charges.md) — périmètre, règles métier, architecture
- [`docs/02-modele-de-donnees.md`](docs/02-modele-de-donnees.md) — tables, vues, contraintes
- [`docs/03-migration-sharepoint.md`](docs/03-migration-sharepoint.md) — export des 5 listes et bascule
- [`docs/04-stock-materiel.md`](docs/04-stock-materiel.md) — ce que disent les exports produits et mouvements
- [`CLAUDE.md`](CLAUDE.md) — conventions et règles à ne pas casser

## État

- [x] Modèle de données, règles métier et sécurité — validés par `supabase/tests/01_scenarios.sql`
- [ ] Import des données SharePoint — *en attente des exports CSV*
- [ ] Interface : interventions, stock matériel, bouteilles
- [ ] Photos d'anomalies et factures
- [ ] Récapitulatifs, alertes et demandes de devis par email
- [ ] Écran Documents : factures, rapport mensuel, historique des devis
