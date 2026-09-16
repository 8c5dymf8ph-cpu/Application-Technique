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

## Lancer en local

```bash
npm install
cp .env.example .env.local      # la base de développement
npm run dev                      # http://localhost:3000
```

## État

- [x] Modèle de données, règles métier et sécurité — validés par `supabase/tests/01_scenarios.sql`
- [ ] Import des données SharePoint — *en attente des exports CSV*
- [x] Import du stock : 36 produits, 257 mouvements, 139 sorties rattachées à leur anomalie
- [x] Interface : choix du profil, accueil, hub gouvernante, déclaration d'anomalie
- [ ] Interface : tournée technicien, validation, stock, bouteilles
- [ ] Photos d'anomalies et factures
- [ ] Récapitulatifs, alertes et demandes de devis par email
- [ ] Écran Documents : factures, rapport mensuel, historique des devis
