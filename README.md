# Application Technique — Hôtel Parisianer

Gestion des interventions techniques, du stock matériel et des bouteilles Purezza.
Remplace l'application Power Apps Canvas existante.

| | |
|---|---|
| **Utilisateurs** | Techniciens, gouvernante, direction |
| **Plateformes** | Téléphone (application installable) et ordinateur |
| **Base** | PostgreSQL / Supabase |
| **Connexion** | Microsoft 365 de l'hôtel |

## Documentation

- [`docs/01-cahier-des-charges.md`](docs/01-cahier-des-charges.md) — périmètre, règles métier, architecture
- [`docs/02-modele-de-donnees.md`](docs/02-modele-de-donnees.md) — tables, vues, contraintes
- [`docs/03-migration-sharepoint.md`](docs/03-migration-sharepoint.md) — export des 5 listes et bascule
- [`CLAUDE.md`](CLAUDE.md) — conventions et règles à ne pas casser

## État

- [x] Modèle de données, règles métier et sécurité (validés par les tests de scénario)
- [ ] Import des données SharePoint — *en attente des exports CSV*
- [ ] Interface : interventions, stock matériel, bouteilles
- [ ] Récapitulatifs par email
