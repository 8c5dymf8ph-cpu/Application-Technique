-- =============================================================================
-- Application Technique — Hôtel Parisianer
-- Migration 0001 : schéma initial
-- =============================================================================

create extension if not exists pgcrypto;

-- -----------------------------------------------------------------------------
-- Types énumérés
-- -----------------------------------------------------------------------------
create type role_utilisateur          as enum ('technicien', 'gouvernante', 'admin', 'lecture');
create type type_emplacement          as enum ('chambre', 'commun', 'technique', 'exterieur');
create type statut_anomalie           as enum ('a_faire', 'en_cours', 'attente_validation', 'validee', 'annulee');
create type priorite_anomalie         as enum ('basse', 'normale', 'haute', 'urgente');
create type acteur_validation         as enum ('technicien', 'gouvernante');
create type decision_validation       as enum ('fait', 'non_fait', 'validee', 'refusee');
create type type_mouvement_stock      as enum ('entree', 'sortie', 'regularisation');
create type type_inventaire           as enum ('materiel', 'bouteilles');
create type statut_inventaire         as enum ('brouillon', 'valide');
create type lieu_bouteille            as enum ('reserve', 'emplacement', 'hors_parc');
create type type_mouvement_bouteille  as enum ('entree', 'dotation', 'retour', 'perte', 'regularisation');
create type cause_incident_bouteille  as enum ('client_perte', 'client_casse', 'personnel_casse', 'inconnu');
create type statut_incident_bouteille as enum ('a_transmettre', 'transmis', 'facture', 'non_facture', 'clos');
create type frequence_recap           as enum ('quotidien', 'hebdomadaire', 'mensuel');

-- -----------------------------------------------------------------------------
-- Référentiels
-- -----------------------------------------------------------------------------

-- Une personne peut exister sans compte de connexion (auth_id null) : elle reste
-- sélectionnable comme « constaté par » sans pouvoir ouvrir l'application.
create table utilisateurs (
  id          uuid primary key default gen_random_uuid(),
  auth_id     uuid unique references auth.users (id) on delete set null,
  email       text unique,
  nom         text not null,
  role        role_utilisateur not null default 'technicien',
  actif       boolean not null default true,
  cree_le     timestamptz not null default now()
);

create table etages (
  id     uuid primary key default gen_random_uuid(),
  code   text not null unique,          -- RDC, 1er, 2eme, ... Sous-Sol, Autres
  nom    text not null,
  ordre  int  not null
);

create table emplacements (
  id        uuid primary key default gen_random_uuid(),
  code      text not null unique,        -- 01, 32, Cuisine, Toit...
  nom       text not null,
  etage_id  uuid not null references etages (id),
  type      type_emplacement not null default 'chambre',
  -- true  => la chambre reçoit la dotation permanente de bouteilles Purezza
  dote_bouteilles boolean not null default false,
  actif     boolean not null default true,
  ordre     int not null default 0
);
create index on emplacements (etage_id);

create table types_intervention (
  id     uuid primary key default gen_random_uuid(),
  code   text not null unique,
  nom    text not null,
  actif  boolean not null default true
);

create table prestataires (
  id          uuid primary key default gen_random_uuid(),
  nom         text not null,
  specialite  text,
  contact     text,
  actif       boolean not null default true
);

-- -----------------------------------------------------------------------------
-- Interventions techniques
-- -----------------------------------------------------------------------------

create table anomalies (
  id              uuid primary key default gen_random_uuid(),
  reference       bigint generated always as identity,
  emplacement_id  uuid not null references emplacements (id),
  type_id         uuid references types_intervention (id),
  description     text not null,
  commentaire     text,
  statut          statut_anomalie   not null default 'a_faire',
  priorite        priorite_anomalie not null default 'normale',
  declare_par     uuid references utilisateurs (id),
  declare_le      timestamptz not null default now(),
  cloture_le      timestamptz,
  -- Traçabilité de la reprise SharePoint (null pour les anomalies créées dans l'app)
  sharepoint_id   int unique,
  maj_le          timestamptz not null default now()
);
create index on anomalies (statut);
create index on anomalies (emplacement_id);
create index on anomalies (declare_le desc);

-- Une intervention = le traitement d'une anomalie par un technicien à une date.
-- Une anomalie refusée puis reprise génère une seconde intervention : l'historique
-- des allers-retours est donc lisible ligne à ligne.
create table interventions (
  id                 uuid primary key default gen_random_uuid(),
  anomalie_id        uuid not null references anomalies (id) on delete cascade,
  technicien_id      uuid references utilisateurs (id),
  debut              timestamptz,
  fin                timestamptz,
  commentaire        text,
  -- Coûts : le matériel est calculé (vue v_interventions_cout), les deux autres sont saisis
  prestataire_id     uuid references prestataires (id),
  cout_prestataire   numeric(10, 2) not null default 0 check (cout_prestataire >= 0),
  facture_reference  text,
  facture_url        text,
  cout_libre         numeric(10, 2) not null default 0 check (cout_libre >= 0),
  cout_libre_motif   text,
  cree_le            timestamptz not null default now(),
  constraint cout_libre_motif_requis
    check (cout_libre = 0 or coalesce(btrim(cout_libre_motif), '') <> '')
);
create index on interventions (anomalie_id);
create index on interventions (technicien_id);

-- Les deux avis sont conservés séparément et définitivement : c'est ce qui permet
-- au récapitulatif d'afficher « déclarée faite par X — non validée par la gouvernante ».
create table validations (
  id              uuid primary key default gen_random_uuid(),
  intervention_id uuid not null references interventions (id) on delete cascade,
  acteur          acteur_validation not null,
  decision        decision_validation not null,
  utilisateur_id  uuid references utilisateurs (id),
  commentaire     text,
  decide_le       timestamptz not null default now(),
  constraint decision_coherente_avec_acteur check (
    (acteur = 'technicien'  and decision in ('fait', 'non_fait')) or
    (acteur = 'gouvernante' and decision in ('validee', 'refusee'))
  )
);
create index on validations (intervention_id);

-- -----------------------------------------------------------------------------
-- Stock matériel
-- -----------------------------------------------------------------------------

create table produits (
  id             uuid primary key default gen_random_uuid(),
  code           text not null unique,       -- ex-colonne Name / CodeArticle
  designation    text not null,
  categorie      text,
  unite          text not null default 'unité',
  prix_unitaire  numeric(10, 2) not null default 0 check (prix_unitaire >= 0),
  seuil_alerte   numeric(10, 2) not null default 0 check (seuil_alerte >= 0),
  photo_url      text,
  actif          boolean not null default true
);
create index on produits (categorie);

create table inventaires (
  id            uuid primary key default gen_random_uuid(),
  type          type_inventaire not null,
  libelle       text,
  statut        statut_inventaire not null default 'brouillon',
  ouvert_par    uuid references utilisateurs (id),
  ouvert_le     timestamptz not null default now(),
  valide_par    uuid references utilisateurs (id),
  valide_le     timestamptz,
  commentaire   text,
  constraint validation_complete
    check (statut = 'brouillon' or (valide_par is not null and valide_le is not null))
);

-- `quantite` est SIGNÉE : positive pour une entrée, négative pour une sortie,
-- de signe libre pour une régularisation d'inventaire. Le stock est toujours la
-- somme de cette colonne — il ne peut donc pas diverger de son historique.
create table mouvements_stock (
  id              uuid primary key default gen_random_uuid(),
  produit_id      uuid not null references produits (id),
  type            type_mouvement_stock not null,
  quantite        numeric(10, 2) not null check (quantite <> 0),
  date_mouvement  timestamptz not null default now(),
  utilisateur_id  uuid references utilisateurs (id),
  emplacement_id  uuid references emplacements (id),
  intervention_id uuid references interventions (id) on delete set null,
  inventaire_id   uuid references inventaires (id) on delete cascade,
  commentaire     text,
  constraint signe_coherent check (
    (type = 'entree' and quantite > 0) or
    (type = 'sortie' and quantite < 0) or
    (type = 'regularisation')
  ),
  constraint regularisation_rattachee_a_un_inventaire
    check (type <> 'regularisation' or inventaire_id is not null)
);
create index on mouvements_stock (produit_id, date_mouvement desc);
create index on mouvements_stock (intervention_id);

create table inventaire_lignes_produit (
  id                  uuid primary key default gen_random_uuid(),
  inventaire_id       uuid not null references inventaires (id) on delete cascade,
  produit_id          uuid not null references produits (id),
  quantite_theorique  numeric(10, 2) not null,
  quantite_comptee    numeric(10, 2) not null check (quantite_comptee >= 0),
  ecart               numeric(10, 2) generated always as (quantite_comptee - quantite_theorique) stored,
  commentaire         text,
  unique (inventaire_id, produit_id)
);

-- -----------------------------------------------------------------------------
-- Bouteilles Purezza
-- -----------------------------------------------------------------------------

create table bouteille_types (
  id           uuid primary key default gen_random_uuid(),
  code         text not null unique,        -- filtree | petillante
  libelle      text not null,
  prix_vente   numeric(10, 2) not null default 0,   -- facturation client
  prix_achat   numeric(10, 2) not null default 0,   -- valorisation d'une casse interne
  couleur      text
);

-- Dotation permanente théorique d'une chambre (1 filtrée + 1 pétillante par défaut).
create table dotations (
  emplacement_id     uuid not null references emplacements (id) on delete cascade,
  bouteille_type_id  uuid not null references bouteille_types (id),
  quantite           int not null check (quantite >= 0),
  primary key (emplacement_id, bouteille_type_id)
);

create table incidents_bouteille (
  id                 uuid primary key default gen_random_uuid(),
  reference          bigint generated always as identity,
  emplacement_id     uuid not null references emplacements (id),
  bouteille_type_id  uuid not null references bouteille_types (id),
  quantite           int not null default 1 check (quantite > 0),
  cause              cause_incident_bouteille not null,
  constate_par       uuid references utilisateurs (id),
  constate_le        timestamptz not null default now(),
  statut             statut_incident_bouteille not null default 'a_transmettre',
  transmis_a         uuid references utilisateurs (id),
  transmis_le        timestamptz,
  montant            numeric(10, 2),
  decide_par         uuid references utilisateurs (id),
  decide_le          timestamptz,
  commentaire        text
);
create index on incidents_bouteille (statut);
create index on incidents_bouteille (constate_le desc);

-- Registre de DÉPLACEMENTS, pas de soustractions : chaque ligne dit d'où part la
-- bouteille et où elle arrive. Une perte suivie d'une re-dotation produit donc
-- deux lignes mais UNE SEULE sortie de parc — c'était le bug de l'application Power Apps.
create table mouvements_bouteilles (
  id                    uuid primary key default gen_random_uuid(),
  type                  type_mouvement_bouteille not null,
  bouteille_type_id     uuid not null references bouteille_types (id),
  quantite              int not null check (quantite > 0),
  de_lieu               lieu_bouteille not null,
  de_emplacement_id     uuid references emplacements (id),
  vers_lieu             lieu_bouteille not null,
  vers_emplacement_id   uuid references emplacements (id),
  date_mouvement        timestamptz not null default now(),
  utilisateur_id        uuid references utilisateurs (id),
  incident_id           uuid references incidents_bouteille (id) on delete cascade,
  inventaire_id         uuid references inventaires (id) on delete cascade,
  commentaire           text,
  constraint emplacement_requis_si_lieu_emplacement check (
    (de_lieu   = 'emplacement') = (de_emplacement_id   is not null) and
    (vers_lieu = 'emplacement') = (vers_emplacement_id is not null)
  ),
  constraint deplacement_reel check (
    de_lieu <> vers_lieu or de_emplacement_id is distinct from vers_emplacement_id
  ),
  constraint flux_coherent_avec_type check (
    (type = 'entree'         and de_lieu = 'hors_parc' and vers_lieu = 'reserve')      or
    (type = 'dotation'       and de_lieu = 'reserve'   and vers_lieu = 'emplacement')  or
    (type = 'retour'         and de_lieu = 'emplacement' and vers_lieu = 'reserve')    or
    (type = 'perte'          and vers_lieu = 'hors_parc' and de_lieu <> 'hors_parc')   or
    (type = 'regularisation')
  )
);
create index on mouvements_bouteilles (date_mouvement desc);
create index on mouvements_bouteilles (incident_id);

create table inventaire_lignes_bouteille (
  id                  uuid primary key default gen_random_uuid(),
  inventaire_id       uuid not null references inventaires (id) on delete cascade,
  bouteille_type_id   uuid not null references bouteille_types (id),
  -- emplacement null = comptage de la réserve centrale
  emplacement_id      uuid references emplacements (id),
  quantite_theorique  int not null,
  quantite_comptee    int not null check (quantite_comptee >= 0),
  ecart               int generated always as (quantite_comptee - quantite_theorique) stored,
  commentaire         text
);
create unique index on inventaire_lignes_bouteille (inventaire_id, bouteille_type_id, coalesce(emplacement_id, '00000000-0000-0000-0000-000000000000'::uuid));

-- -----------------------------------------------------------------------------
-- Récapitulatifs automatiques
-- -----------------------------------------------------------------------------

create table recap_abonnements (
  id             uuid primary key default gen_random_uuid(),
  libelle        text not null,
  destinataires  text[] not null check (cardinality(destinataires) > 0),
  frequence      frequence_recap not null,
  heure_envoi    time not null default '18:00',
  jour_semaine   int check (jour_semaine between 1 and 7),   -- hebdomadaire
  jour_mois      int check (jour_mois between 1 and 28),     -- mensuel
  perimetre      jsonb not null default '{}'::jsonb,         -- filtres : étages, statuts, techniciens
  inclure_couts  boolean not null default true,
  actif          boolean not null default true,
  cree_le        timestamptz not null default now()
);

create table recap_envois (
  id             uuid primary key default gen_random_uuid(),
  abonnement_id  uuid references recap_abonnements (id) on delete set null,
  periode_debut  timestamptz not null,
  periode_fin    timestamptz not null,
  envoye_le      timestamptz not null default now(),
  destinataires  text[] not null,
  succes         boolean not null default true,
  erreur         text
);

-- -----------------------------------------------------------------------------
-- Journal d'audit
-- -----------------------------------------------------------------------------
create table journal (
  id              bigint generated always as identity primary key,
  table_cible     text not null,
  ligne_id        uuid,
  action          text not null,
  utilisateur_id  uuid references utilisateurs (id),
  avant           jsonb,
  apres           jsonb,
  date_action     timestamptz not null default now()
);
create index on journal (table_cible, ligne_id);
