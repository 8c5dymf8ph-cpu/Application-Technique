-- Application Technique — Hôtel Parisianer
-- Schéma, vues, règles, sécurité et référentiels.
-- Fichier produit par outils/preparer_installation.sh — ne pas éditer.


-- ===== supabase/migrations/0001_schema_initial.sql =====
-- =============================================================================
-- Application Technique — Hôtel Parisianer
-- Migration 0001 : schéma initial
-- =============================================================================

create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

-- -----------------------------------------------------------------------------
-- Types énumérés
-- -----------------------------------------------------------------------------
-- « operations » : la chargée des opérations. Elle fait tout ce que fait la
-- gouvernante, et peut en plus supprimer une anomalie — sans toucher aux
-- référentiels ni au paramétrage, qui restent à l'administrateur.
-- `menage` et `reception` ne se connectent pas : ce sont des personnes citées
-- dans les déclarations. La femme de chambre constate la bouteille manquante, la
-- gouvernante la déclare, la réception reçoit le dossier et écrit au client.
-- Elles doivent exister pour être nommées ; elles n'écrivent rien elles-mêmes
-- (voir `fn_peut_ecrire`, qui ne les cite pas).
create type role_utilisateur          as enum ('technicien', 'gouvernante', 'operations',
                                              'admin', 'lecture', 'menage', 'reception');
create type type_emplacement          as enum ('chambre', 'commun', 'technique', 'exterieur');
-- « a_acheter » existe dans les données d'origine : une ligne qui attend un
-- achat avant de pouvoir être traitée.
create type statut_anomalie           as enum ('a_faire', 'en_cours', 'attente_validation', 'validee', 'a_acheter', 'annulee');
create type priorite_anomalie         as enum ('basse', 'normale', 'haute', 'urgente');
create type acteur_validation         as enum ('technicien', 'gouvernante');
-- La gouvernante dispose de trois issues, comme ses trois boutons actuels :
-- FAIT (validee), EN COURS, A FAIRE (a_refaire).
create type decision_validation       as enum ('fait', 'non_fait', 'validee', 'a_refaire', 'en_cours');
create type moment_photo              as enum ('constat', 'apres');
-- Un commentaire écrit par quelqu'un, ou une note posée par la reprise de
-- l'ancienne application : les deux se lisent dans le même fil, sans se
-- confondre.
create type origine_commentaire       as enum ('utilisateur', 'reprise');
create type statut_facture            as enum ('a_rapprocher', 'rapprochee', 'reglee', 'litige');
-- Une commande passe chez un fournisseur, puis arrive. Tant qu'elle n'est pas
-- reçue, elle n'a rien ajouté au stock : c'est la réception qui écrit les
-- mouvements, jamais la saisie de la commande.
create type statut_commande            as enum ('brouillon', 'envoyee', 'recue', 'annulee');
-- Prestation : une journée d'intervention facturée par un prestataire.
-- Achat      : une livraison de matériel facturée par un fournisseur.
create type type_facture              as enum ('prestation', 'achat');
create type type_mouvement_stock      as enum ('entree', 'sortie', 'regularisation');
-- Motif d'un ajustement de stock. Seul « inventaire » suppose un comptage
-- complet : casse, perte et erreur de saisie se corrigent au fil de l'eau.
create type motif_regularisation      as enum ('inventaire', 'casse', 'perte', 'erreur_saisie', 'autre');
create type type_inventaire           as enum ('materiel', 'bouteilles');
create type statut_inventaire         as enum ('brouillon', 'valide');
create type statut_demande_devis      as enum ('brouillon', 'envoyee', 'recue', 'commandee', 'annulee');
create type frequence_recap           as enum ('quotidien', 'hebdomadaire', 'mensuel');

-- Une bouteille occupe toujours l'une de ces quatre positions. « chez_client »
-- est l'état d'attente : la bouteille est sortie de la chambre mais pas encore
-- perdue — elle peut revenir en réserve, ou sortir définitivement du parc.
create type lieu_bouteille            as enum ('reserve', 'emplacement', 'chez_client', 'hors_parc');
create type type_mouvement_bouteille  as enum ('entree', 'dotation', 'emport', 'retour', 'perte', 'casse', 'regularisation');
create type nature_incident_bouteille as enum ('emport', 'casse');
create type responsable_incident      as enum ('client', 'personnel', 'inconnu');
-- Le dossier suit quatre étapes : constaté, transmis, client contacté, puis
-- une résolution — restitué, facturé ou non facturé — avant clôture.
create type statut_incident_bouteille as enum ('signale', 'transmis', 'client_contacte',
                                              'restitue', 'facture', 'non_facture', 'clos');

-- -----------------------------------------------------------------------------
-- Référentiels
-- -----------------------------------------------------------------------------

-- Une personne peut exister sans compte de connexion (auth_id null) : elle reste
-- sélectionnable comme « constaté par » sans pouvoir ouvrir l'application.
create table utilisateurs (
  id          uuid primary key default gen_random_uuid(),
  auth_id     uuid unique references auth.users (id) on delete set null,
  email       text unique,
  nom         text not null unique,
  role        role_utilisateur not null default 'technicien',
  -- Un rôle principal n'épuise pas ce qu'une personne fait. Taibi est
  -- réceptionniste, et il sait faire un peu de technique : il doit apparaître
  -- dans la liste des intervenants sans cesser d'être la réception.
  intervient_technique boolean not null default false,
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
  -- true => la chambre reçoit la dotation permanente de bouteilles Purezza
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

-- Entreprise extérieure qui intervient (plombier, ascensoriste...). Elle facture
-- une journée d'intervention, pas une anomalie : voir la table `factures`.
create table prestataires (
  id          uuid primary key default gen_random_uuid(),
  nom         text not null unique,
  specialite  text,
  email       text,
  telephone   text,
  actif       boolean not null default true
);

-- Spécialités d'un intervenant, salarié ou entreprise extérieure. Aucune ligne
-- = polyvalent, il voit tout. Une ou plusieurs lignes = sa section ne lui
-- propose que ces types d'anomalie — ainsi l'électricien ne voit que
-- l'électrique.
create table specialites_intervenant (
  id                   uuid primary key default gen_random_uuid(),
  utilisateur_id       uuid references utilisateurs (id) on delete cascade,
  prestataire_id       uuid references prestataires (id) on delete cascade,
  type_intervention_id uuid not null references types_intervention (id) on delete cascade,
  constraint un_seul_intervenant check (num_nonnulls(utilisateur_id, prestataire_id) = 1)
);
create unique index on specialites_intervenant (utilisateur_id, type_intervention_id)
  where utilisateur_id is not null;
create unique index on specialites_intervenant (prestataire_id, type_intervention_id)
  where prestataire_id is not null;

-- Fournisseur de consommables. Plusieurs produits peuvent partager le même
-- fournisseur : les demandes de devis sont alors regroupées en un seul envoi.
create table fournisseurs (
  id                    uuid primary key default gen_random_uuid(),
  nom                   text not null unique,
  email                 text,
  email_2               text,
  contact               text,
  telephone             text,
  delai_livraison_jours int check (delai_livraison_jours >= 0),
  actif                 boolean not null default true
);

-- -----------------------------------------------------------------------------
-- Catalogue d'anomalies
-- La gouvernante déclare depuis son téléphone en choisissant dans ce catalogue,
-- recherché par mots-clés. Créer une entrée hors catalogue est réservé à l'admin
-- (règle appliquée par la sécurité, migration 0003).
-- -----------------------------------------------------------------------------
create table catalogue_anomalies (
  id          uuid primary key default gen_random_uuid(),
  libelle     text not null unique,
  mots_cles   text[] not null default '{}',
  type_id     uuid references types_intervention (id),
  -- Nombre de fois que ce libellé a été utilisé : sert à remonter les plus
  -- courants en tête de la recherche, sur un téléphone où l'écran est étroit.
  occurrences int not null default 0,
  actif       boolean not null default true,
  cree_par    uuid references utilisateurs (id),
  cree_le     timestamptz not null default now()
);

-- Deux index complémentaires : recherche approximative sur le libellé, et
-- appartenance exacte pour les mots-clés. array_to_string n'est pas IMMUTABLE
-- et ne peut donc pas servir dans un index.
create index idx_catalogue_libelle  on catalogue_anomalies using gin (libelle gin_trgm_ops);
create index idx_catalogue_motscles on catalogue_anomalies using gin (mots_cles);

-- -----------------------------------------------------------------------------
-- Interventions techniques
-- -----------------------------------------------------------------------------

create table anomalies (
  id              uuid primary key default gen_random_uuid(),
  reference       bigint generated always as identity,
  emplacement_id  uuid not null references emplacements (id),
  catalogue_id    uuid references catalogue_anomalies (id),
  type_id         uuid references types_intervention (id),
  description     text not null,
  statut          statut_anomalie   not null default 'a_faire',
  priorite        priorite_anomalie not null default 'normale',
  -- Trois personnes distinctes dans les données d'origine : celle qui constate,
  -- celle qui saisit, et plus tard celle qui vérifie (voir `validations`).
  constate_par    uuid references utilisateurs (id),
  saisie_par      uuid references utilisateurs (id),
  declare_le      timestamptz not null default now(),
  cloture_le      timestamptz,
  -- Traçabilité de la reprise SharePoint (null pour les anomalies créées dans l'app)
  sharepoint_id   int unique,
  maj_le          timestamptz not null default now()
);
create index on anomalies (statut);

-- Un même problème ne peut pas être ouvert deux fois au même endroit. Tant que
-- « serrer le bras liseuse côté droit » est à faire en 58, on ne peut pas le
-- redéclarer : ce n'est pas un avertissement, c'est impossible.
-- Le comptage dans le temps, lui, reste entier — voir v_frequence_anomalie_lieu.
create unique index anomalie_unique_ouverte_par_lieu
  on anomalies (emplacement_id, catalogue_id)
  where catalogue_id is not null
    and statut in ('a_faire', 'en_cours', 'attente_validation', 'a_acheter');
create index on anomalies (emplacement_id);
create index on anomalies (declare_le desc);

-- Une tournée regroupe toutes les anomalies qu'un intervenant traite en une
-- fois — l'équivalent de l'InterventionID actuel. La gouvernante valide ensuite
-- anomalie par anomalie, éventuellement en plusieurs sessions ; le mail récap
-- ne part que lorsque plus aucune anomalie de la tournée n'est en attente.
create table tournees (
  id                        uuid primary key default gen_random_uuid(),
  reference                 text not null unique,   -- INT-MIGUEL-20260517-143012
  technicien_id             uuid references utilisateurs (id),
  prestataire_id            uuid references prestataires (id),
  date_tournee              date not null default current_date,
  cloturee_le               timestamptz,            -- le technicien a rendu son lot
  mail_technicien_envoye_le timestamptz,
  mail_recap_envoye_le      timestamptz,
  -- Une tournée reprise de l'ancienne application : le travail a eu lieu, il
  -- garde sa trace, mais plus aucun récapitulatif ne part pour elle. Sans ce
  -- drapeau, le premier envoi déverserait des années d'historique.
  reprise                   boolean not null default false,
  commentaire               text,
  cree_le                   timestamptz not null default now()
);
create index on tournees (technicien_id, date_tournee desc);

-- Une intervention = le traitement d'une anomalie, par un technicien interne ou
-- un prestataire, à une date. Une anomalie refusée puis reprise en génère une
-- seconde : les allers-retours sont lisibles ligne à ligne.
create table interventions (
  id                 uuid primary key default gen_random_uuid(),
  anomalie_id        uuid not null references anomalies (id) on delete cascade,
  tournee_id         uuid references tournees (id) on delete set null,
  technicien_id      uuid references utilisateurs (id),
  prestataire_id     uuid references prestataires (id),
  -- Qui a réellement saisi la ligne. Deux ou trois intervenants ont
  -- l'application ; pour les autres c'est l'administrateur qui saisit à leur
  -- place, et la trace doit distinguer les deux.
  saisie_par         uuid references utilisateurs (id),
  date_intervention  date not null default current_date,
  debut              timestamptz,
  fin                timestamptz,
  commentaire        text,
  -- Le coût matériel est calculé, le coût prestataire vient du rapprochement de
  -- facture. Seul ce montant divers est saisi, et uniquement par la gouvernante
  -- ou l'admin : le technicien ne saisit jamais de prix.
  cout_divers        numeric(10, 2) not null default 0 check (cout_divers >= 0),
  cout_divers_motif  text,
  cree_le            timestamptz not null default now(),
  constraint cout_divers_motif_requis
    check (cout_divers = 0 or coalesce(btrim(cout_divers_motif), '') <> '')
);
create index on interventions (anomalie_id);
create index on interventions (tournee_id);
create index on interventions (technicien_id);
create index on interventions (prestataire_id, date_intervention);

-- Les deux avis sont conservés séparément et définitivement : c'est ce qui permet
-- au récapitulatif d'afficher « déclarée faite par X — non validée par la gouvernante ».
create table validations (
  id              uuid primary key default gen_random_uuid(),
  intervention_id uuid not null references interventions (id) on delete cascade,
  acteur          acteur_validation not null,
  decision        decision_validation not null,
  -- La personne dont c'est l'avis…
  utilisateur_id  uuid references utilisateurs (id),
  -- …et celle qui a tenu le téléphone. Les deux diffèrent quand
  -- l'administrateur saisit pour un intervenant qui n'a pas l'application.
  saisie_par      uuid references utilisateurs (id),
  commentaire     text,
  decide_le       timestamptz not null default now(),
  constraint decision_coherente_avec_acteur check (
    (acteur = 'technicien'  and decision in ('fait', 'non_fait')) or
    (acteur = 'gouvernante' and decision in ('validee', 'a_refaire', 'en_cours'))
  )
);
create index on validations (intervention_id);

-- Les commentaires ne s'empilent pas dans un champ texte : chacun garde son
-- auteur et sa date, et rien ne peut en écraser un autre. Un commentaire
-- s'ajoute à tout moment — à la déclaration, en cours de route, ou des mois
-- plus tard quand le problème revient.
create table commentaires (
  id           uuid primary key default gen_random_uuid(),
  anomalie_id  uuid not null references anomalies (id) on delete cascade,
  texte        text not null check (btrim(texte) <> ''),
  origine      origine_commentaire not null default 'utilisateur',
  -- L'auteur du propos, et la personne qui a tenu le téléphone. Ils diffèrent
  -- quand l'administrateur saisit pour un intervenant qui n'a pas l'application.
  auteur_id    uuid references utilisateurs (id),
  saisie_par   uuid references utilisateurs (id),
  ecrit_le     timestamptz not null default now()
);
create index on commentaires (anomalie_id, ecrit_le);

create table photos_anomalie (
  id              uuid primary key default gen_random_uuid(),
  anomalie_id     uuid not null references anomalies (id) on delete cascade,
  intervention_id uuid references interventions (id) on delete set null,
  chemin          text not null,          -- chemin dans Supabase Storage
  moment          moment_photo not null default 'constat',
  prise_par       uuid references utilisateurs (id),
  prise_le        timestamptz not null default now()
);
create index on photos_anomalie (anomalie_id);

-- -----------------------------------------------------------------------------
-- Factures
--   prestation : un prestataire facture une JOURNÉE, pas une anomalie. La
--                facture est rapprochée de toutes ses interventions de ce jour.
--   achat      : un fournisseur facture une livraison de matériel. Une même
--                facture peut couvrir plusieurs produits — les entrées de stock
--                concernées la référencent.
-- -----------------------------------------------------------------------------
create table factures (
  id                uuid primary key default gen_random_uuid(),
  type              type_facture not null,
  prestataire_id    uuid references prestataires (id),
  fournisseur_id    uuid references fournisseurs (id),
  reference         text,
  -- Date d'intervention pour une prestation, date de livraison pour un achat.
  date_reference    date not null,
  -- Une facture de prestataire arrive une à deux semaines après, et peut
  -- couvrir plusieurs passages. Quand la période est renseignée, c'est elle qui
  -- sert au rapprochement plutôt que la date seule.
  periode_debut     date,
  periode_fin       date,
  date_facture      date,
  montant_ht        numeric(10, 2) check (montant_ht >= 0),
  montant_ttc       numeric(10, 2) check (montant_ttc >= 0),
  fichier_url       text,
  statut            statut_facture not null default 'a_rapprocher',
  saisie_par        uuid references utilisateurs (id),
  cree_le           timestamptz not null default now(),
  commentaire       text,
  constraint periode_coherente check (
    periode_debut is null or periode_fin is null or periode_debut <= periode_fin),
  constraint emetteur_coherent_avec_type check (
    (type = 'prestation' and prestataire_id is not null and fournisseur_id is null) or
    (type = 'achat'      and fournisseur_id is not null and prestataire_id is null)
  )
);
create index on factures (prestataire_id, date_reference);
create index on factures (fournisseur_id, date_reference);
create index on factures (statut);

-- `montant_affecte` nul => la facture est répartie à parts égales entre les
-- interventions rapprochées.
create table facture_interventions (
  facture_id       uuid not null references factures (id) on delete cascade,
  intervention_id  uuid not null references interventions (id) on delete cascade,
  montant_affecte  numeric(10, 2) check (montant_affecte >= 0),
  primary key (facture_id, intervention_id)
);

-- -----------------------------------------------------------------------------
-- Stock matériel
-- -----------------------------------------------------------------------------

create table produits (
  id             uuid primary key default gen_random_uuid(),
  code           text not null unique,       -- ex-colonne Name / CodeArticle
  designation    text not null,
  categorie      text,          -- le métier : Électricité, Plomberie…
  categorie_lieu text,          -- le lieu : Chambre, Salle de bain, Général
  unite          text not null default 'unité',
  -- Nul = prix inconnu. Le coût d'une intervention le signale au lieu de
  -- compter l'article pour zéro.
  prix_unitaire  numeric(10, 2) check (prix_unitaire >= 0),
  seuil_alerte   numeric(10, 2) not null default 0 check (seuil_alerte >= 0),
  quantite_reappro numeric(10, 2) check (quantite_reappro > 0),
  actif          boolean not null default true
);
create index on produits (categorie);
create index on produits (categorie_lieu);

-- Un produit peut être fourni par plusieurs maisons : une demande de devis part
-- alors vers chacune, pour comparer. Un fournisseur qui a plusieurs articles
-- sous seuil ne reçoit toujours qu'un seul mail.
create table article_fournisseurs (
  id                    uuid primary key default gen_random_uuid(),
  produit_id            uuid references produits (id) on delete cascade,
  bouteille_type_id     uuid,   -- contrainte posée plus bas, la table n'existe pas encore
  fournisseur_id        uuid not null references fournisseurs (id) on delete cascade,
  reference_fournisseur text,
  prix_indicatif        numeric(10, 2) check (prix_indicatif >= 0),
  delai_jours           int check (delai_jours >= 0),
  prefere               boolean not null default false,
  constraint un_seul_article check (num_nonnulls(produit_id, bouteille_type_id) = 1)
);
create unique index on article_fournisseurs (produit_id, fournisseur_id) where produit_id is not null;
create unique index on article_fournisseurs (bouteille_type_id, fournisseur_id) where bouteille_type_id is not null;

-- Plusieurs photos par produit, ajoutées au fil de l'eau. La principale est
-- celle qui s'affiche dans la liste du technicien.
create table photos_produit (
  id          uuid primary key default gen_random_uuid(),
  produit_id  uuid not null references produits (id) on delete cascade,
  chemin      text not null,
  principale  boolean not null default false,
  ordre       int not null default 0,
  ajoutee_par uuid references utilisateurs (id),
  ajoutee_le  timestamptz not null default now()
);
create index on photos_produit (produit_id, ordre);
create unique index on photos_produit (produit_id) where principale;

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
  motif           motif_regularisation,
  date_mouvement  timestamptz not null default now(),
  utilisateur_id  uuid references utilisateurs (id),
  prestataire_id  uuid references prestataires (id),
  emplacement_id  uuid references emplacements (id),
  intervention_id uuid references interventions (id) on delete set null,
  inventaire_id   uuid references inventaires (id) on delete cascade,
  -- Prix payé pour CETTE livraison : il varie d'une commande à l'autre, alors
  -- que produits.prix_unitaire reste le prix de référence.
  prix_unitaire   numeric(10, 2) check (prix_unitaire >= 0),
  facture_id      uuid references factures (id) on delete set null,
  commentaire     text,
  constraint signe_coherent check (
    (type = 'entree' and quantite > 0) or
    (type = 'sortie' and quantite < 0) or
    (type = 'regularisation')
  ),
  -- Un ajustement dit toujours pourquoi. Seul un ajustement d'inventaire
  -- suppose un comptage complet ; casse, perte et erreur vivent sans.
  constraint motif_requis_sur_regularisation
    check ((type = 'regularisation') = (motif is not null)),
  constraint inventaire_requis_si_motif_inventaire
    check (motif is distinct from 'inventaire' or inventaire_id is not null),
  constraint facture_reservee_aux_entrees
    check (facture_id is null or type = 'entree')
);
create index on mouvements_stock (produit_id, date_mouvement desc);
create index on mouvements_stock (intervention_id);
create index on mouvements_stock (facture_id);

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
  id             uuid primary key default gen_random_uuid(),
  code           text not null unique,        -- filtree | petillante
  libelle        text not null,
  prix_vente     numeric(10, 2) not null default 0,   -- facturation client
  prix_achat     numeric(10, 2) not null default 0,   -- valorisation d'une casse interne
  seuil_alerte   int not null default 0,              -- porte sur la RÉSERVE
  quantite_reappro int check (quantite_reappro > 0),
  couleur        text,
  -- La photo de la bouteille, ajoutée depuis l'application. Le reste du code ne
  -- connaît qu'un nom de fichier — disque en développement, Supabase Storage
  -- en production. Sans photo, l'écran dessine la bouteille à sa couleur.
  photo          text
);

alter table article_fournisseurs
  add constraint article_fournisseurs_bouteille_fkey
  foreign key (bouteille_type_id) references bouteille_types (id) on delete cascade;

-- Dotation permanente théorique d'une chambre (1 filtrée + 1 pétillante).
create table dotations (
  emplacement_id     uuid not null references emplacements (id) on delete cascade,
  bouteille_type_id  uuid not null references bouteille_types (id),
  quantite           int not null check (quantite >= 0),
  primary key (emplacement_id, bouteille_type_id)
);

-- Un incident couvre les deux cas réels : la bouteille est EMPORTÉE (elle peut
-- encore revenir) ou CASSÉE (elle est perdue immédiatement). Dans les deux cas
-- la chambre est re-dotée depuis la réserve, ce qui ne diminue pas le parc.
-- Un dossier porte UNE chambre, UNE date, UN client — et autant de lignes que de
-- types de bouteilles concernés. C'est le grain de la déclaration réelle : une
-- chambre peut perdre la filtrée ET la gazeuse d'un coup, et c'est un seul
-- dossier, un seul montant, un seul mail. Les types sont dans les lignes.
create table incidents_bouteille (
  id                 uuid primary key default gen_random_uuid(),
  reference          bigint generated always as identity,
  emplacement_id     uuid not null references emplacements (id),
  nature             nature_incident_bouteille not null,
  responsable        responsable_incident not null default 'client',
  -- Nom du client occupant la chambre : c'est lui qu'on recontacte, et c'est
  -- à lui que la bouteille est facturée le cas échéant.
  client_nom         text,
  constate_par       uuid references utilisateurs (id),
  constate_le        timestamptz not null default now(),
  statut             statut_incident_bouteille not null default 'signale',
  -- La chambre est re-dotée par défaut : le client suivant doit trouver ses
  -- deux bouteilles. Mettre à false si la réserve est vide.
  redoter            boolean not null default true,
  notifie_le         timestamptz,       -- alerte envoyée à l'équipe
  transmis_a         uuid references utilisateurs (id),
  transmis_le        timestamptz,
  client_contacte_le timestamptz,
  resolu_le          timestamptz,
  resolu_par         uuid references utilisateurs (id),
  montant            numeric(10, 2),
  commentaire        text,
  -- Une bouteille cassée ne peut pas être restituée.
  constraint restitution_reservee_aux_emports
    check (statut <> 'restitue' or nature = 'emport'),
  -- Une casse par le personnel n'est jamais facturée au client.
  constraint casse_personnel_non_facturee
    check (statut <> 'facture' or responsable = 'client')
);
create index on incidents_bouteille (statut);
create index on incidents_bouteille (constate_le desc);

-- Une ligne par type de bouteille concerné par le dossier. C'est elle qui
-- déclenche les mouvements physiques : un dossier sans ligne n'a rien déplacé.
create table incident_lignes_bouteille (
  id                uuid primary key default gen_random_uuid(),
  incident_id       uuid not null references incidents_bouteille (id) on delete cascade,
  bouteille_type_id uuid not null references bouteille_types (id),
  quantite          int not null default 1 check (quantite > 0),
  unique (incident_id, bouteille_type_id)
);
create index on incident_lignes_bouteille (incident_id);

-- Registre de DÉPLACEMENTS, pas de soustractions : chaque ligne dit d'où part la
-- bouteille et où elle arrive. Un emport suivi d'une re-dotation produit deux
-- lignes mais AUCUNE sortie de parc tant que la bouteille peut revenir — c'était
-- le bug de l'application Power Apps.
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
    (type = 'entree'   and de_lieu = 'hors_parc'   and vers_lieu = 'reserve')      or
    (type = 'dotation' and de_lieu = 'reserve'     and vers_lieu = 'emplacement')  or
    (type = 'emport'   and de_lieu = 'emplacement' and vers_lieu = 'chez_client')  or
    -- Une bouteille restituée rejoint la RÉSERVE : la chambre a déjà été re-dotée.
    (type = 'retour'   and de_lieu = 'chez_client' and vers_lieu = 'reserve')      or
    (type = 'perte'    and de_lieu = 'chez_client' and vers_lieu = 'hors_parc')    or
    (type = 'casse'    and de_lieu <> 'hors_parc'  and vers_lieu = 'hors_parc')    or
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
create unique index on inventaire_lignes_bouteille
  (inventaire_id, bouteille_type_id, coalesce(emplacement_id, '00000000-0000-0000-0000-000000000000'::uuid));

-- -----------------------------------------------------------------------------
-- Réapprovisionnement : une demande de devis par fournisseur, regroupant tous
-- ses articles sous le seuil — un seul mail même si trois produits tombent
-- en même temps.
-- -----------------------------------------------------------------------------
create table demandes_devis (
  id             uuid primary key default gen_random_uuid(),
  reference      bigint generated always as identity,
  fournisseur_id uuid not null references fournisseurs (id),
  statut         statut_demande_devis not null default 'brouillon',
  destinataires  text[] not null default '{}',
  cree_par       uuid references utilisateurs (id),
  cree_le        timestamptz not null default now(),
  envoye_le      timestamptz,
  commentaire    text
);
create index on demandes_devis (fournisseur_id, statut);

create table demande_devis_lignes (
  id                 uuid primary key default gen_random_uuid(),
  demande_id         uuid not null references demandes_devis (id) on delete cascade,
  produit_id         uuid references produits (id),
  bouteille_type_id  uuid references bouteille_types (id),
  libelle            text not null,
  stock_actuel       numeric(10, 2) not null,
  seuil              numeric(10, 2) not null,
  quantite_demandee  numeric(10, 2) not null check (quantite_demandee > 0),
  constraint un_seul_article check (num_nonnulls(produit_id, bouteille_type_id) = 1)
);
create index on demande_devis_lignes (demande_id);

-- -----------------------------------------------------------------------------
-- Récapitulatifs et alertes automatiques
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

-- Destinataires des alertes immédiates : incident de bouteille, franchissement
-- de seuil de stock.
-- -----------------------------------------------------------------------------
-- Commandes fournisseur
--
-- Une commande porte son prix hors taxes ET toutes taxes : c'est le TTC qui est
-- décaissé, c'est le HT qui se compare d'une année sur l'autre. La facture du
-- fournisseur s'y rattache, et reste consultable depuis la commande.
-- Rien n'entre en stock à la saisie : la réception écrit les mouvements.
-- -----------------------------------------------------------------------------
create table commandes (
  id             uuid primary key default gen_random_uuid(),
  reference      bigint generated always as identity,
  fournisseur_id uuid not null references fournisseurs (id),
  date_commande  date not null default current_date,
  date_livraison date,
  statut         statut_commande not null default 'brouillon',
  montant_ht     numeric(10, 2) check (montant_ht  >= 0),
  montant_ttc    numeric(10, 2) check (montant_ttc >= 0),
  -- La facture du fournisseur, quand elle arrive : un PDF ou une photo.
  facture_id     uuid references factures (id) on delete set null,
  commentaire    text,
  saisie_par     uuid references utilisateurs (id),
  cree_le        timestamptz not null default now(),
  recue_le       timestamptz,
  -- Une TVA ne peut pas être négative : le TTC ne descend jamais sous le HT.
  constraint ttc_au_moins_egal_au_ht
    check (montant_ht is null or montant_ttc is null or montant_ttc >= montant_ht),
  constraint reception_datee
    check ((statut = 'recue') = (recue_le is not null))
);
create index on commandes (statut);
create index on commandes (date_commande desc);

create table commande_lignes (
  id                uuid primary key default gen_random_uuid(),
  commande_id       uuid not null references commandes (id) on delete cascade,
  produit_id        uuid references produits (id),
  bouteille_type_id uuid references bouteille_types (id),
  quantite          int not null check (quantite > 0),
  prix_unitaire_ht  numeric(10, 2) check (prix_unitaire_ht >= 0),
  -- Ce qui est réellement arrivé, qui n'est pas toujours ce qui a été commandé.
  quantite_recue    int check (quantite_recue >= 0),
  constraint un_seul_article_commande
    check (num_nonnulls(produit_id, bouteille_type_id) = 1)
);
create index on commande_lignes (commande_id);

create table alertes_destinataires (
  id            uuid primary key default gen_random_uuid(),
  evenement     text not null,              -- incident_bouteille | seuil_stock
  destinataires text[] not null default '{}',
  actif         boolean not null default true,
  unique (evenement),
  -- Une alerte ne peut être activée qu'une fois ses destinataires renseignés.
  constraint destinataires_requis_si_actif
    check (not actif or cardinality(destinataires) > 0)
);

-- La file d'attente des courriels, et leur trace une fois partis. Une ligne
-- dont `envoye_le` est nul attend son tour : le message est déjà rédigé, il n'a
-- plus qu'à partir. C'est ce qui permet à une action de l'interface d'être
-- immédiate sans mentir sur l'envoi.
create table emails_envoyes (
  id             bigint generated always as identity primary key,
  categorie      text not null,             -- recap | alerte | devis
  reference_id   uuid,
  destinataires  text[] not null,
  sujet          text not null,
  corps          text,
  cree_le        timestamptz not null default now(),
  envoye_le      timestamptz,
  succes         boolean,
  erreur         text
);
create index on emails_envoyes (categorie) where envoye_le is null;
create index on emails_envoyes (categorie, envoye_le desc);

-- -----------------------------------------------------------------------------
-- Paramètres généraux — une seule ligne.
-- -----------------------------------------------------------------------------
create table parametres (
  id            boolean primary key default true check (id),
  -- Les mails ne partent pas à chaque validation : ils s'accumulent et sont
  -- envoyés en un seul envoi à cette heure-là.
  heure_digest  time not null default '21:00',
  fuseau        text not null default 'Europe/Paris',
  maj_le        timestamptz not null default now()
);
insert into parametres (id) values (true) on conflict do nothing;

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

-- ===== supabase/migrations/0002_vues_et_regles.sql =====
-- =============================================================================
-- Migration 0002 : vues de calcul et règles métier
-- Tout ce qui se calcule est calculé ici. Aucune valeur de stock n'est stockée
-- en dur : ni Stock_Initial, ni StockActuel, ni EstHistorique, et donc aucun
-- bouton « recalculer le stock » — il n'y a rien à recalculer.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Stock matériel — alimente aussi la fiche produit
-- (Initial / Entrées / Sorties / Ajustements / Stock actuel)
-- -----------------------------------------------------------------------------
create view v_stock_produits as
select
  p.id,
  p.code,
  p.designation,
  p.categorie,
  p.categorie_lieu,
  p.unite,
  p.prix_unitaire,
  p.prix_unitaire is null                              as prix_inconnu,
  p.seuil_alerte,
  ph.chemin                                            as photo_principale,
  (select count(*) from photos_produit x where x.produit_id = p.id) as nb_photos,
  p.actif,
  coalesce(sum(m.quantite) filter (where m.type = 'entree'), 0)          as total_entrees,
  coalesce(-sum(m.quantite) filter (where m.type = 'sortie'), 0)         as total_sorties,
  coalesce(sum(m.quantite) filter (where m.type = 'regularisation'), 0)  as total_ajustements,
  coalesce(sum(m.quantite), 0)                         as stock,
  coalesce(sum(m.quantite), 0) * p.prix_unitaire       as valeur_stock,
  coalesce(sum(m.quantite), 0) <= p.seuil_alerte       as sous_seuil,
  max(m.date_mouvement)                                as dernier_mouvement
from produits p
left join mouvements_stock m on m.produit_id = p.id
left join lateral (
  select chemin from photos_produit x
  where x.produit_id = p.id order by x.principale desc, x.ordre limit 1
) ph on true
group by p.id, ph.chemin;

-- -----------------------------------------------------------------------------
-- Coût d'une intervention
--   matériel   : calculé depuis les sorties de stock rattachées
--   prestataire: issu du rapprochement de facture, réparti à parts égales entre
--                les interventions de la facture si aucun montant n'est affecté
--   divers     : seul montant saisi, par la gouvernante ou l'admin
-- Le technicien ne saisit ni ne voit aucun prix.
-- -----------------------------------------------------------------------------
create view v_cout_prestataire as
select
  fi.intervention_id,
  sum(coalesce(fi.montant_affecte, f.montant_ht / n.nb)) as cout_prestataire
from facture_interventions fi
join factures f on f.id = fi.facture_id
cross join lateral (
  select greatest(count(*), 1) as nb
  from facture_interventions x where x.facture_id = fi.facture_id
) n
group by fi.intervention_id;

create view v_interventions_cout as
select
  i.id                                     as intervention_id,
  i.anomalie_id,
  coalesce(mat.cout_materiel, 0)           as cout_materiel,
  coalesce(mat.articles_sans_prix, 0)      as articles_sans_prix,
  coalesce(cp.cout_prestataire, 0)         as cout_prestataire,
  i.cout_divers,
  coalesce(mat.cout_materiel, 0) + coalesce(cp.cout_prestataire, 0) + i.cout_divers as cout_total,
  -- Vrai quand du matériel sans prix connu a été utilisé : le total affiché est
  -- alors un minimum, ce que l'interface doit dire explicitement.
  coalesce(mat.articles_sans_prix, 0) > 0  as cout_incomplet
from interventions i
left join lateral (
  -- Les sorties sont négatives : on reprend la valeur absolue pour obtenir un coût
  select
    sum(abs(m.quantite) * p.prix_unitaire) filter (where p.prix_unitaire is not null) as cout_materiel,
    count(*) filter (where p.prix_unitaire is null)                                   as articles_sans_prix
  from mouvements_stock m
  join produits p on p.id = m.produit_id
  where m.intervention_id = i.id and m.type = 'sortie'
) mat on true
left join v_cout_prestataire cp on cp.intervention_id = i.id;

-- -----------------------------------------------------------------------------
-- Récapitulatif d'intervention : les deux avis côte à côte
-- -----------------------------------------------------------------------------
create view v_recap_interventions as
select
  i.id                        as intervention_id,
  t.reference                 as tournee,
  a.id                        as anomalie_id,
  a.reference                 as anomalie_reference,
  e.code                      as emplacement,
  et.nom                      as etage,
  ti.nom                      as type_intervention,
  a.description,
  a.statut                    as statut_anomalie,
  uc.nom                      as constate_par,
  us.nom                      as saisie_par,
  i.date_intervention,
  coalesce(ut.nom, pr.nom)    as intervenant,
  pr.nom                      as prestataire,
  vt.decision                 as decision_technicien,
  vt.decide_le                as declare_fait_le,
  vt.commentaire              as commentaire_technicien,
  ug.nom                      as gouvernante,
  vg.decision                 as decision_gouvernante,
  vg.decide_le                as decide_gouvernante_le,
  vg.commentaire              as commentaire_gouvernante,
  -- Ce drapeau est ce qui doit apparaître en clair dans le récapitulatif envoyé :
  -- le technicien a déclaré l'anomalie faite, la gouvernante ne l'a pas validée.
  (vt.decision = 'fait' and vg.decision is distinct from 'validee'
     and vg.decision is not null)         as non_validee_par_gouvernante,
  (vt.decision = 'fait' and vg.decision is null) as en_attente_gouvernante,
  c.cout_materiel,
  c.articles_sans_prix,
  c.cout_prestataire,
  c.cout_divers,
  c.cout_total,
  c.cout_incomplet,
  i.cree_le
from interventions i
join anomalies a           on a.id = i.anomalie_id
join emplacements e        on e.id = a.emplacement_id
join etages et             on et.id = e.etage_id
left join tournees t       on t.id = i.tournee_id
left join types_intervention ti on ti.id = a.type_id
left join utilisateurs uc  on uc.id = a.constate_par
left join utilisateurs us  on us.id = a.saisie_par
left join utilisateurs ut  on ut.id = i.technicien_id
left join prestataires pr  on pr.id = i.prestataire_id
left join v_interventions_cout c on c.intervention_id = i.id
left join lateral (
  select * from validations v
  where v.intervention_id = i.id and v.acteur = 'technicien'
  order by v.decide_le desc limit 1
) vt on true
left join lateral (
  select * from validations v
  where v.intervention_id = i.id and v.acteur = 'gouvernante'
  order by v.decide_le desc limit 1
) vg on true
left join utilisateurs ug on ug.id = vg.utilisateur_id;

-- -----------------------------------------------------------------------------
-- État d'une tournée. `prete_pour_recap` remplace la logique « plus aucune ligne
-- EnAttente pour cet InterventionID » : le mail récap part quand elle devient
-- vraie et que mail_recap_envoye_le est encore nul.
-- -----------------------------------------------------------------------------
create view v_tournees as
select
  t.id,
  t.reference,
  t.date_tournee,
  coalesce(u.nom, p.nom)                   as intervenant,
  t.cloturee_le,
  t.reprise,
  t.mail_technicien_envoye_le,
  t.mail_recap_envoye_le,
  count(r.intervention_id)                                                  as nb_interventions,
  count(*) filter (where r.intervention_id is not null
                     and r.decision_gouvernante is null)                    as nb_en_attente,
  count(*) filter (where r.decision_gouvernante = 'validee')                as nb_validees,
  count(*) filter (where r.decision_gouvernante = 'a_refaire')              as nb_a_refaire,
  count(*) filter (where r.decision_gouvernante = 'en_cours')               as nb_en_cours,
  coalesce(sum(r.cout_total), 0)                                            as cout_total,
  bool_or(r.cout_incomplet)                                                 as cout_incomplet,
  count(r.intervention_id) > 0
    and count(*) filter (where r.intervention_id is not null
                           and r.decision_gouvernante is null) = 0          as prete_pour_recap
from tournees t
left join utilisateurs u  on u.id = t.technicien_id
left join prestataires p  on p.id = t.prestataire_id
left join v_recap_interventions r on r.tournee = t.reference
group by t.id, u.nom, p.nom;

-- Fil chronologique des commentaires d'une anomalie. Remplace l'empilement de
-- texte « NOM · date \n contenu » : chaque commentaire garde son auteur, sa date
-- et son rôle, donc rien ne peut être écrasé ni mal découpé à la relecture.
-- Journées candidates au rapprochement d'une facture de prestation.
--
-- Le numéro de tournée ne sert PAS ici. Dans l'application d'origine,
-- l'InterventionID changeait à chaque anomalie validée : un même passage
-- produisait plusieurs identifiants qu'il fallait recoller à la main, et il en
-- reste des coquilles dans les données reprises. Ce qui identifie réellement un
-- passage, c'est le couple **qui est venu / quel jour** — les colonnes `PAR` et
-- `FAIT LE`. On regroupe donc par journée d'intervenant.
--
-- Une facture arrive une à deux semaines après et peut couvrir plusieurs
-- journées : quand elle porte une période, c'est elle qui fait foi ; sinon on
-- remonte `p_jours` en arrière depuis sa date, puisque la facture suit toujours
-- l'intervention. Une journée dont une intervention est déjà prise par une
-- AUTRE facture n'est jamais proposée.
create function fn_journees_rapprochables(
  p_facture_id uuid,
  p_jours int default 30
) returns table (
  date_intervention  date,
  intervenant        text,
  nb_anomalies       int,
  emplacements       text,
  apercu             text,
  cout_materiel      numeric,
  ecart_jours        int,
  interventions      uuid[],
  deja_rapprochee    boolean
)
language sql stable as $$
  select
    i.date_intervention,
    coalesce(pr.nom, ut.nom)                              as intervenant,
    count(*)::int                                         as nb_anomalies,
    string_agg(distinct e.code, ', ' order by e.code)     as emplacements,
    -- De quoi reconnaître le passage sans ouvrir le détail.
    left(string_agg(a.description, ' · ' order by a.reference), 120) as apercu,
    coalesce(sum(c.cout_materiel), 0)                     as cout_materiel,
    (f.date_reference - i.date_intervention)::int         as ecart_jours,
    array_agg(i.id order by a.reference)                  as interventions,
    bool_or(fi.facture_id is not null)                    as deja_rapprochee
  from factures f
  join interventions i on i.prestataire_id = f.prestataire_id
  join anomalies a     on a.id = i.anomalie_id
  join emplacements e  on e.id = a.emplacement_id
  left join prestataires pr on pr.id = i.prestataire_id
  left join utilisateurs ut on ut.id = i.technicien_id
  left join v_interventions_cout c   on c.intervention_id = i.id
  left join facture_interventions fi on fi.facture_id = f.id and fi.intervention_id = i.id
  where f.id = p_facture_id
    and f.type = 'prestation'
    and case
          when f.periode_debut is not null and f.periode_fin is not null
            then i.date_intervention between f.periode_debut and f.periode_fin
          else i.date_intervention between f.date_reference - p_jours and f.date_reference
        end
    -- pas déjà pris par une autre facture
    and not exists (
      select 1 from facture_interventions x
      where x.intervention_id = i.id and x.facture_id <> f.id)
  group by i.date_intervention, coalesce(pr.nom, ut.nom), f.date_reference
  order by i.date_intervention desc;
$$;

-- Le détail d'une journée, quand on veut voir ce qu'elle contient avant de la
-- rattacher — ou en retirer une ligne qui n'appartient pas à cette facture.
create function fn_anomalies_de_la_journee(
  p_prestataire_id uuid,
  p_date date
) returns table (
  intervention_id    uuid,
  anomalie_reference bigint,
  emplacement        text,
  description        text,
  cout_materiel      numeric,
  facture_id         uuid
)
language sql stable as $$
  select i.id, a.reference, e.code, a.description,
         coalesce(c.cout_materiel, 0), fi.facture_id
  from interventions i
  join anomalies a    on a.id = i.anomalie_id
  join emplacements e on e.id = a.emplacement_id
  left join v_interventions_cout c   on c.intervention_id = i.id
  left join facture_interventions fi on fi.intervention_id = i.id
  where i.prestataire_id = p_prestataire_id
    and i.date_intervention = p_date
  order by a.reference;
$$;

-- Le filet de sécurité : ce qu'un prestataire a fait et qu'aucune facture ne
-- couvre encore. Une intervention qui vieillit ici est une facture qu'on
-- attend, ou qu'on a oublié de rapprocher.
create view v_interventions_sans_facture as
select
  pr.id                                as prestataire_id,
  pr.nom                               as prestataire,
  i.id                                 as intervention_id,
  a.reference                          as anomalie_reference,
  e.code                               as emplacement,
  a.description,
  i.date_intervention,
  (current_date - i.date_intervention)::int as jours_ecoules
from interventions i
join prestataires pr on pr.id = i.prestataire_id
join anomalies a     on a.id = i.anomalie_id
join emplacements e  on e.id = a.emplacement_id
where not exists (
  select 1 from facture_interventions fi where fi.intervention_id = i.id);

-- Liste des intervenants pour le filtre à avatars de l'écran technicien.
-- `specialites` vide = polyvalent : on lui propose toutes les anomalies.
-- Sinon sa section ne montre que les types listés.
create view v_intervenants as
select
  u.id                  as utilisateur_id,
  null::uuid            as prestataire_id,
  u.nom,
  'interne'::text       as origine,
  u.actif,
  coalesce(array_remove(array_agg(t.code), null), '{}')::text[] as specialites
from utilisateurs u
left join specialites_intervenant s on s.utilisateur_id = u.id
left join types_intervention t      on t.id = s.type_intervention_id
-- Qui intervient ne se déduit pas d'un rôle : la chargée des opérations
-- n'intervient pas, et le réceptionniste qui donne un coup de main, si. La
-- liste est donnée par l'hôtel et posée par `outils/equipe.py`.
where u.intervient_technique
group by u.id
union all
select
  null::uuid,
  p.id,
  p.nom,
  'externe'::text,
  p.actif,
  coalesce(array_remove(array_agg(t.code), null), '{}')::text[]
from prestataires p
left join specialites_intervenant s on s.prestataire_id = p.id
left join types_intervention t      on t.id = s.type_intervention_id
group by p.id;

-- Anomalies qu'un intervenant donné doit voir dans sa section : toutes s'il est
-- polyvalent, sinon celles de ses seuls types.
create function fn_anomalies_pour_intervenant(p_nom text)
returns setof anomalies
language sql stable as $$
  select a.*
  from anomalies a
  left join types_intervention t on t.id = a.type_id
  cross join lateral (
    select specialites from v_intervenants where nom = p_nom limit 1
  ) i
  where a.statut in ('a_faire', 'en_cours')
    and (cardinality(i.specialites) = 0 or t.code = any (i.specialites))
  order by a.emplacement_id, a.declare_le;
$$;

-- Ce que le digest du soir doit envoyer. Rien ne part à la validation : les
-- lignes s'accumulent ici et un seul envoi les reprend à l'heure dite, pour
-- éviter un mail par anomalie validée.
create view v_envois_en_attente as
select
  'recap_technicien'::text as categorie,
  t.id                     as tournee_id,
  t.reference,
  t.date_tournee,
  coalesce(u.nom, p.nom)   as intervenant,
  v.nb_interventions,
  v.nb_validees,
  v.nb_a_refaire,
  v.cout_total,
  t.cloturee_le            as pret_depuis
from tournees t
join v_tournees v         on v.id = t.id
left join utilisateurs u  on u.id = t.technicien_id
left join prestataires p  on p.id = t.prestataire_id
where not t.reprise
  and t.cloturee_le is not null and t.mail_technicien_envoye_le is null
union all
select
  'recap_intervention',
  t.id,
  t.reference,
  t.date_tournee,
  coalesce(u.nom, p.nom),
  v.nb_interventions,
  v.nb_validees,
  v.nb_a_refaire,
  v.cout_total,
  t.cloturee_le
from tournees t
join v_tournees v         on v.id = t.id
left join utilisateurs u  on u.id = t.technicien_id
left join prestataires p  on p.id = t.prestataire_id
where not t.reprise
  and v.prete_pour_recap and t.mail_recap_envoye_le is null;

-- Le fil d'une anomalie : les commentaires libres et ceux attachés à une
-- décision, dans l'ordre. Rien n'écrase rien — celui du technicien reste
-- lisible sous celui de la gouvernante, et inversement.
create view v_fil_commentaires as
select
  c.anomalie_id,
  c.id                as commentaire_id,
  case when c.origine = 'reprise' then 'reprise' else 'commentaire' end as source,
  c.ecrit_le          as date_commentaire,
  u.nom               as auteur,
  c.texte,
  null::decision_validation as decision
from commentaires c
left join utilisateurs u on u.id = c.auteur_id
union all
select
  i.anomalie_id,
  v.id,
  v.acteur::text,
  v.decide_le,
  coalesce(u.nom, p.nom),
  v.commentaire,
  v.decision
from validations v
join interventions i      on i.id = v.intervention_id
left join utilisateurs u  on u.id = v.utilisateur_id
left join prestataires p  on p.id = i.prestataire_id
where coalesce(btrim(v.commentaire), '') <> '';

-- Ce qui a déjà été déclaré dans un lieu. La gouvernante la consulte AVANT de
-- saisir : sans ça, la même fuite est déclarée trois fois en une semaine.
-- Les anomalies ouvertes remontent d'abord, l'historique récent ensuite —
-- une anomalie close il y a peu qui réapparaît n'est pas un doublon, c'est une
-- réparation qui n'a pas tenu, et cela se voit ici.
create view v_anomalies_du_lieu as
select
  a.emplacement_id,
  e.code                       as emplacement,
  a.id                         as anomalie_id,
  a.reference,
  a.catalogue_id,
  a.description,
  a.statut,
  a.statut in ('a_faire', 'en_cours', 'attente_validation', 'a_acheter') as ouverte,
  a.declare_le,
  a.cloture_le,
  (current_date - a.declare_le::date)::int as jours_depuis,
  uc.nom                       as constate_par,
  ti.nom                       as type_intervention,
  (select count(*) from photos_anomalie ph where ph.anomalie_id = a.id)::int as nb_photos,
  (select count(*) from v_fil_commentaires f where f.anomalie_id = a.id)::int as nb_commentaires
from anomalies a
join emplacements e             on e.id = a.emplacement_id
left join utilisateurs uc       on uc.id = a.constate_par
left join types_intervention ti on ti.id = a.type_id;

-- Combien de fois un même problème est revenu à un même endroit. C'est ce que
-- le catalogue fermé rend possible : sans libellés normalisés, ce comptage
-- n'aurait aucun sens. Les doublons annulés n'y figurent pas — ils n'ont pas eu
-- lieu deux fois, ils ont été saisis deux fois.
create view v_frequence_anomalie_lieu as
select
  a.emplacement_id,
  e.code               as emplacement,
  a.catalogue_id,
  c.libelle,
  count(*)::int                                    as nb_fois,
  max(a.declare_le)::date                          as derniere_fois,
  min(a.declare_le)::date                          as premiere_fois,
  count(*) filter (
    where a.statut in ('a_faire','en_cours','attente_validation','a_acheter')
  )::int                                           as ouvertes
from anomalies a
join emplacements e        on e.id = a.emplacement_id
join catalogue_anomalies c on c.id = a.catalogue_id
where a.statut <> 'annulee'
group by a.emplacement_id, e.code, a.catalogue_id, c.libelle;

-- Chambres qui reviennent trop souvent. Le drapeau reprend le seuil de la
-- maquette : 3 interventions ou plus sur les six derniers mois.
create view v_recurrences_emplacement as
select
  e.id                as emplacement_id,
  e.code              as emplacement,
  et.nom              as etage,
  count(a.id) filter (where a.declare_le > now() - interval '6 months') as nb_6_mois,
  count(a.id)                                                          as nb_total,
  max(a.declare_le)                                                    as derniere_anomalie,
  count(a.id) filter (where a.declare_le > now() - interval '6 months') >= 3 as recurrent
from emplacements e
join etages et on et.id = e.etage_id
left join anomalies a on a.emplacement_id = e.id
group by e.id, et.nom;

-- -----------------------------------------------------------------------------
-- Bouteilles : positions réelles
-- Chaque mouvement est éclaté en deux demi-lignes (+ à l'arrivée, − au départ).
-- Les demi-lignes « hors parc » sont ignorées : ce qui reste est le parc vivant.
-- -----------------------------------------------------------------------------
create view v_bouteilles_positions as
select
  m.bouteille_type_id,
  f.lieu,
  f.emplacement_id,
  f.qte
from mouvements_bouteilles m
cross join lateral (values
  (m.vers_lieu, m.vers_emplacement_id,  m.quantite),
  (m.de_lieu,   m.de_emplacement_id,   -m.quantite)
) as f (lieu, emplacement_id, qte)
where f.lieu <> 'hors_parc';

create view v_stock_bouteilles as
select
  bt.id                as bouteille_type_id,
  bt.code,
  bt.libelle,
  bt.couleur,
  bt.photo,
  bt.prix_vente,
  bt.prix_achat,
  bt.seuil_alerte,
  -- Le chiffre opérationnel : ce qu'il reste pour re-doter une chambre.
  coalesce(sum(p.qte) filter (where p.lieu = 'reserve'), 0)      as en_reserve,
  coalesce(sum(p.qte) filter (where p.lieu = 'emplacement'), 0)  as en_chambre,
  -- Emportée par un client : elle n'est plus à nous tant qu'elle n'est pas
  -- rendue. Elle ne compte donc PAS dans le parc détenu.
  coalesce(sum(p.qte) filter (where p.lieu = 'chez_client'), 0)  as chez_clients,
  -- Ce que l'hôtel a réellement, réserve et chambres réunies. C'est ce chiffre
  -- qui baisse dès qu'un client emporte une bouteille.
  coalesce(sum(p.qte) filter (where p.lieu in ('reserve', 'emplacement')), 0) as parc_detenu,
  -- Détenu + en attente de retour : sert au rapprochement d'inventaire, pas au
  -- pilotage quotidien.
  coalesce(sum(p.qte), 0)                                        as parc_theorique,
  coalesce(d.dotation_theorique, 0)                              as dotation_theorique,
  coalesce(sum(p.qte) filter (where p.lieu = 'reserve'), 0) <= bt.seuil_alerte as sous_seuil
from bouteille_types bt
left join v_bouteilles_positions p on p.bouteille_type_id = bt.id
left join lateral (
  select sum(quantite) as dotation_theorique
  from dotations d2 where d2.bouteille_type_id = bt.id
) d on true
group by bt.id, d.dotation_theorique;

create view v_bouteilles_par_emplacement as
select
  e.id            as emplacement_id,
  e.code          as emplacement,
  bt.id           as bouteille_type_id,
  bt.code         as bouteille,
  coalesce(d.quantite, 0)                     as quantite_theorique,
  coalesce(sum(p.qte), 0)                     as quantite_reelle
from emplacements e
cross join bouteille_types bt
left join dotations d on d.emplacement_id = e.id and d.bouteille_type_id = bt.id
left join v_bouteilles_positions p
       on p.emplacement_id = e.id and p.bouteille_type_id = bt.id and p.lieu = 'emplacement'
where e.dote_bouteilles
group by e.id, bt.id, d.quantite;

-- Dossiers en cours et clos, avec le montant retenu ou, à défaut, le montant
-- théorique selon qui est responsable. Les lignes sont agrégées : un dossier qui
-- porte la filtrée ET la gazeuse reste UN dossier, un montant, un mail.
create view v_incidents_bouteille as
select
  i.id,
  i.reference,
  i.emplacement_id,
  e.code                                   as emplacement,
  l.libelles                               as bouteille,
  coalesce(l.quantite, 0)                  as quantite,
  coalesce(l.detail, '[]'::jsonb)          as lignes,
  i.nature,
  i.responsable,
  i.client_nom,
  uc.nom                                   as constate_par,
  ut.nom                                   as transmis_a,
  i.constate_le,
  i.statut,
  i.notifie_le,
  i.transmis_le,
  i.client_contacte_le,
  i.resolu_le,
  -- Les quatre étapes du dossier, pour la frise de l'écran de suivi.
  i.constate_le is not null                as etape_constate,
  i.transmis_le is not null                as etape_transmis,
  i.client_contacte_le is not null         as etape_client_contacte,
  i.statut in ('restitue', 'facture', 'non_facture', 'clos') as etape_resolue,
  -- Le montant retenu s'il a été saisi ; sinon le prix du barème, ligne à ligne.
  coalesce(i.montant, l.montant_theorique, 0) as montant,
  i.responsable = 'client'                 as facturable_client,
  i.statut in ('signale', 'transmis', 'client_contacte') as dossier_ouvert,
  i.commentaire
from incidents_bouteille i
join emplacements e     on e.id = i.emplacement_id
left join utilisateurs uc on uc.id = i.constate_par
left join utilisateurs ut on ut.id = i.transmis_a
left join lateral (
  select
    string_agg(bt.libelle, ' + ' order by bt.libelle)                as libelles,
    sum(li.quantite)::int                                            as quantite,
    sum(li.quantite * case when i.responsable = 'client'
                           then bt.prix_vente else bt.prix_achat end) as montant_theorique,
    jsonb_agg(jsonb_build_object(
      'code', bt.code, 'libelle', bt.libelle, 'quantite', li.quantite,
      'prix', case when i.responsable = 'client' then bt.prix_vente else bt.prix_achat end)
      order by bt.libelle)                                           as detail
  from incident_lignes_bouteille li
  join bouteille_types bt on bt.id = li.bouteille_type_id
  where li.incident_id = i.id
) l on true;

-- -----------------------------------------------------------------------------
-- Réapprovisionnement : articles sous seuil, regroupés par fournisseur.
-- Un seul devis, donc un seul mail, même si trois articles tombent le même jour.
-- -----------------------------------------------------------------------------
-- Une ligne par couple article / fournisseur : un produit qui a trois
-- fournisseurs apparaît trois fois, et part donc en consultation chez les trois.
-- Un article sans aucun fournisseur apparaît quand même, avec `fournisseur_id`
-- nul : il doit rester visible dans l'écran d'alerte.
create view v_reappro_necessaire as
select
  af.fournisseur_id,
  f.nom                                as fournisseur,
  f.email                              as email_fournisseur,
  'produit'::text                      as nature,
  p.id                                 as article_id,
  p.designation                        as libelle,
  af.reference_fournisseur,
  s.stock::numeric                     as stock_actuel,
  p.seuil_alerte::numeric              as seuil,
  coalesce(p.quantite_reappro, greatest(p.seuil_alerte * 2 - s.stock, 1))::numeric as quantite_suggeree
from v_stock_produits s
join produits p on p.id = s.id
left join article_fournisseurs af on af.produit_id = p.id
left join fournisseurs f          on f.id = af.fournisseur_id
where p.actif and s.stock <= p.seuil_alerte
union all
select
  af.fournisseur_id,
  f.nom,
  f.email,
  'bouteille'::text,
  bt.id,
  bt.libelle,
  af.reference_fournisseur,
  b.en_reserve::numeric,
  bt.seuil_alerte::numeric,
  coalesce(bt.quantite_reappro, greatest(bt.seuil_alerte * 2 - b.en_reserve, 1))::numeric
from v_stock_bouteilles b
join bouteille_types bt on bt.id = b.bouteille_type_id
left join article_fournisseurs af on af.bouteille_type_id = bt.id
left join fournisseurs f          on f.id = af.fournisseur_id
where b.en_reserve <= bt.seuil_alerte;

-- -----------------------------------------------------------------------------
-- Commandes fournisseur
-- -----------------------------------------------------------------------------
create view v_commandes as
select
  c.id,
  c.reference,
  f.nom                                   as fournisseur,
  c.fournisseur_id,
  c.date_commande,
  c.date_livraison,
  c.recue_le,
  c.statut,
  c.montant_ht,
  c.montant_ttc,
  -- Ce que la TVA représente, quand les deux montants sont là. Rien n'est
  -- stocké : c'est une soustraction, elle se refait à chaque lecture.
  case when c.montant_ht is not null and c.montant_ttc is not null
       then c.montant_ttc - c.montant_ht end as montant_tva,
  c.facture_id,
  fa.fichier_url                          as facture_fichier,
  fa.reference                            as facture_reference,
  coalesce(l.nb_lignes, 0)                as nb_lignes,
  coalesce(l.nb_articles, 0)              as nb_articles,
  l.articles,
  -- Le total des lignes, quand les prix unitaires sont renseignés. Il sert à
  -- signaler un écart avec le montant saisi, jamais à le remplacer.
  l.total_lignes_ht,
  c.commentaire,
  u.nom                                   as saisie_par
from commandes c
join fournisseurs f      on f.id = c.fournisseur_id
left join factures fa    on fa.id = c.facture_id
left join utilisateurs u on u.id = c.saisie_par
left join lateral (
  select
    count(*)::int                                   as nb_lignes,
    sum(cl.quantite)::int                           as nb_articles,
    string_agg(
      coalesce(p.designation, bt.libelle) || ' × ' || cl.quantite,
      ', ' order by coalesce(p.designation, bt.libelle))  as articles,
    sum(cl.quantite * cl.prix_unitaire_ht)          as total_lignes_ht
  from commande_lignes cl
  left join produits p         on p.id = cl.produit_id
  left join bouteille_types bt on bt.id = cl.bouteille_type_id
  where cl.commande_id = c.id
) l on true;

-- -----------------------------------------------------------------------------
-- Dossiers bouteille : la même chose que `v_incidents_bouteille`, mais rangée
-- pour l'écran de suivi — un statut lisible, un axe de tri, et de quoi filtrer.
-- -----------------------------------------------------------------------------
create view v_dossiers_bouteille as
select
  i.*,
  -- Trois familles suffisent aux filtres : à traiter, réglé, abandonné.
  case
    when i.statut in ('signale', 'transmis', 'client_contacte') then 'ouvert'
    when i.statut in ('restitue', 'facture')                    then 'resolu'
    else 'perdu'
  end                                              as famille,
  (current_date - i.constate_le::date)::int        as jours_ouvert,
  -- Un dossier client ouvert depuis plus d'une semaine : le client est parti,
  -- la bouteille ne reviendra pas toute seule.
  i.statut in ('signale', 'transmis', 'client_contacte')
    and (current_date - i.constate_le::date) >= 7  as urgent,
  -- De quoi chercher sans se soucier de la casse ni des accents.
  lower(coalesce(i.client_nom, '') || ' ' || i.emplacement || ' ' ||
        coalesce(i.bouteille, '') || ' ' || coalesce(i.commentaire, '') || ' ' ||
        i.reference::text)                         as recherche
from v_incidents_bouteille i;

-- Ce que les bouteilles ont coûté, mois par mois : la matière du tableau de
-- bord. Un dossier compte dans le mois où il a été constaté.
create view v_bouteilles_par_mois as
select
  date_trunc('month', i.constate_le)::date          as mois,
  count(*)::int                                     as nb_dossiers,
  count(*) filter (where i.nature = 'emport')::int  as nb_emports,
  count(*) filter (where i.nature = 'casse')::int   as nb_casses,
  count(*) filter (where i.statut = 'restitue')::int    as nb_restituees,
  count(*) filter (where i.statut = 'facture')::int     as nb_facturees,
  count(*) filter (where i.statut = 'non_facture')::int as nb_perdues,
  sum(i.quantite)::int                              as nb_bouteilles,
  sum(i.montant)                                    as montant_en_jeu,
  sum(i.montant) filter (where i.statut = 'facture')     as montant_facture,
  sum(i.montant) filter (where i.statut = 'non_facture') as perte_seche
from v_incidents_bouteille i
group by 1;

-- Les emplacements qui perdent le plus de bouteilles. « Top chambres à risque »
-- du tableau de bord : c'est une information d'exploitation, pas un palmarès.
create view v_bouteilles_par_emplacement_couts as
select
  i.emplacement,
  count(*)::int          as nb_dossiers,
  sum(i.quantite)::int   as nb_bouteilles,
  sum(i.montant)         as montant,
  max(i.constate_le)     as dernier_dossier
from v_incidents_bouteille i
group by i.emplacement;

-- Ce qui est rédigé et attend de partir. Le service d'envoi lit cette vue,
-- envoie, puis horodate `envoye_le`.
create view v_courriels_en_attente as
select id, categorie, reference_id, destinataires, sujet, corps, cree_le
from emails_envoyes
where envoye_le is null
order by cree_le;

-- =============================================================================
-- Règles métier
-- =============================================================================

-- 1. Ouvrir une tournée. La référence reprend le format actuel (INT-<TECH>-...)
--    avec un suffixe aléatoire : deux tournées ouvertes dans la même seconde ne
--    peuvent pas entrer en collision.
create function fn_creer_tournee(
  p_technicien_id uuid default null,
  p_prestataire_id uuid default null
) returns tournees
language plpgsql as $$
declare
  v_nom text;
  v_tournee tournees;
begin
  select upper(regexp_replace(coalesce(u.nom, pr.nom, 'INT'), '[^A-Za-z0-9]', '', 'g'))
    into v_nom
  from (select 1) x
  left join utilisateurs u   on u.id = p_technicien_id
  left join prestataires pr  on pr.id = p_prestataire_id;

  insert into tournees (reference, technicien_id, prestataire_id)
  values (
    'INT-' || left(v_nom, 10) || '-' || to_char(now(), 'YYYYMMDD-HH24MISS')
           || '-' || substr(md5(random()::text), 1, 4),
    p_technicien_id, p_prestataire_id)
  returning * into v_tournee;

  return v_tournee;
end;
$$;

-- 2. Une LIGNE de dossier enregistre les mouvements physiques de son type.
--    Emport : la bouteille part « chez le client », d'où elle peut revenir.
--    Casse  : la bouteille sort définitivement du parc.
--    Dans les deux cas la chambre est re-dotée depuis la réserve, ce qui déplace
--    une bouteille sans en retirer une seconde du parc.
--    Le déclencheur est sur la ligne, pas sur le dossier : c'est la ligne qui
--    dit quel type et combien, et elle arrive toujours après l'en-tête.
create function fn_incident_bouteille_mouvements() returns trigger
language plpgsql as $$
declare
  d incidents_bouteille%rowtype;
begin
  select * into d from incidents_bouteille where id = new.incident_id;

  insert into mouvements_bouteilles (
    type, bouteille_type_id, quantite, de_lieu, de_emplacement_id, vers_lieu,
    date_mouvement, utilisateur_id, incident_id, commentaire)
  values (
    case when d.nature = 'emport' then 'emport' else 'casse' end::type_mouvement_bouteille,
    new.bouteille_type_id, new.quantite, 'emplacement', d.emplacement_id,
    case when d.nature = 'emport' then 'chez_client' else 'hors_parc' end::lieu_bouteille,
    d.constate_le, d.constate_par, d.id,
    case when d.nature = 'emport' then 'Bouteille emportée — dossier n° '
         else 'Bouteille cassée — dossier n° ' end || d.reference);

  if d.redoter then
    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, vers_lieu, vers_emplacement_id,
      date_mouvement, utilisateur_id, incident_id, commentaire)
    values (
      'dotation', new.bouteille_type_id, new.quantite, 'reserve', 'emplacement', d.emplacement_id,
      d.constate_le, d.constate_par, d.id,
      'Re-dotation de la chambre — dossier n° ' || d.reference);
  end if;

  return new;
end;
$$;

create trigger tg_incident_bouteille_mouvements
after insert on incident_lignes_bouteille
for each row execute function fn_incident_bouteille_mouvements();

-- 3. La résolution d'un emport décide du sort des bouteilles en attente.
--    Restituées => elles rejoignent la RÉSERVE (la chambre a déjà été re-dotée).
--    Facturées  => sortie définitive du parc.
--    Le garde-fou empêche de compter deux fois un dossier déjà tranché.
create function fn_incident_bouteille_resolution() returns trigger
language plpgsql as $$
begin
  if new.statut = old.statut or new.nature <> 'emport' then
    return new;
  end if;

  if exists (
    select 1 from mouvements_bouteilles
    where incident_id = new.id and type in ('retour', 'perte')
  ) then
    return new;
  end if;

  if new.statut = 'restitue' then
    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, vers_lieu,
      date_mouvement, utilisateur_id, incident_id, commentaire)
    select 'retour', l.bouteille_type_id, l.quantite, 'chez_client', 'reserve',
           coalesce(new.resolu_le, now()), new.resolu_par, new.id,
           'Bouteille restituée, remise en réserve — dossier n° ' || new.reference
    from incident_lignes_bouteille l where l.incident_id = new.id;

  elsif new.statut in ('facture', 'non_facture') then
    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, vers_lieu,
      date_mouvement, utilisateur_id, incident_id, commentaire)
    select 'perte', l.bouteille_type_id, l.quantite, 'chez_client', 'hors_parc',
           coalesce(new.resolu_le, now()), new.resolu_par, new.id,
           'Bouteille non restituée — dossier n° ' || new.reference
    from incident_lignes_bouteille l where l.incident_id = new.id;
  end if;

  return new;
end;
$$;

create trigger tg_incident_bouteille_resolution
after update on incidents_bouteille
for each row execute function fn_incident_bouteille_resolution();

-- 4. Re-doter une chambre depuis la réserve, hors incident (après inventaire).
create function fn_redoter_emplacement(
  p_emplacement_id uuid,
  p_bouteille_type_id uuid,
  p_quantite int,
  p_utilisateur_id uuid default null
) returns uuid
language plpgsql as $$
declare
  v_id uuid;
begin
  insert into mouvements_bouteilles (
    type, bouteille_type_id, quantite,
    de_lieu, vers_lieu, vers_emplacement_id, utilisateur_id, commentaire)
  values (
    'dotation', p_bouteille_type_id, p_quantite,
    'reserve', 'emplacement', p_emplacement_id, p_utilisateur_id,
    'Re-dotation de la chambre')
  returning id into v_id;
  return v_id;
end;
$$;

-- 5. Le statut de l'anomalie suit la dernière validation enregistrée.
--    La gouvernante dispose de ses trois issues : FAIT, EN COURS, A FAIRE.
--    Le matériel déjà sorti reste consommé : il n'est jamais annulé par un refus.
create function fn_validation_maj_anomalie() returns trigger
language plpgsql as $$
declare
  v_anomalie_id uuid;
begin
  select anomalie_id into v_anomalie_id from interventions where id = new.intervention_id;

  update anomalies set
    statut = case
      when new.acteur = 'technicien'  and new.decision = 'fait'      then 'attente_validation'::statut_anomalie
      when new.acteur = 'technicien'  and new.decision = 'non_fait'  then 'en_cours'::statut_anomalie
      when new.acteur = 'gouvernante' and new.decision = 'validee'   then 'validee'::statut_anomalie
      when new.acteur = 'gouvernante' and new.decision = 'en_cours'  then 'en_cours'::statut_anomalie
      when new.acteur = 'gouvernante' and new.decision = 'a_refaire' then 'a_faire'::statut_anomalie
      else statut
    end,
    cloture_le = case
      when new.acteur = 'gouvernante' and new.decision = 'validee' then new.decide_le
      else null
    end,
    maj_le = now()
  -- Une anomalie annulée le reste : une validation arrivée après coup ne doit
  -- pas la ramener à la vie, sinon le même problème redeviendrait ouvert deux
  -- fois au même endroit.
  where id = v_anomalie_id and statut <> 'annulee';

  return new;
end;
$$;

create trigger tg_validation_maj_anomalie
after insert on validations
for each row execute function fn_validation_maj_anomalie();

-- 6. Réceptionner une commande écrit les entrées de stock, et rien d'autre.
--    C'est le seul moment où une commande touche au stock : tant qu'elle est
--    en brouillon ou envoyée, elle n'a rien ajouté. Ce qui est compté, c'est ce
--    qui est arrivé (`quantite_recue`), pas ce qui avait été commandé.
create function fn_receptionner_commande() returns trigger
language plpgsql as $$
begin
  if new.statut = 'recue' and old.statut is distinct from 'recue' then
    insert into mouvements_stock (
      produit_id, type, quantite, date_mouvement, utilisateur_id, commentaire)
    select cl.produit_id, 'entree', coalesce(cl.quantite_recue, cl.quantite),
           new.recue_le, new.saisie_par,
           'Commande n° ' || new.reference
    from commande_lignes cl
    where cl.commande_id = new.id
      and cl.produit_id is not null
      and coalesce(cl.quantite_recue, cl.quantite) > 0;

    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, vers_lieu,
      date_mouvement, utilisateur_id, commentaire)
    select 'entree', cl.bouteille_type_id, coalesce(cl.quantite_recue, cl.quantite),
           'hors_parc', 'reserve', new.recue_le, new.saisie_par,
           'Commande n° ' || new.reference
    from commande_lignes cl
    where cl.commande_id = new.id
      and cl.bouteille_type_id is not null
      and coalesce(cl.quantite_recue, cl.quantite) > 0;
  end if;
  return new;
end;
$$;

create trigger tg_receptionner_commande
after update on commandes
for each row execute function fn_receptionner_commande();

-- 7. Valider un inventaire matériel écrit les régularisations correspondantes.
--    Le stock est recalé par un mouvement tracé, jamais par une écriture directe.
create function fn_valider_inventaire_materiel() returns trigger
language plpgsql as $$
begin
  if new.statut = 'valide' and old.statut = 'brouillon' and new.type = 'materiel' then
    insert into mouvements_stock (
      produit_id, type, motif, quantite, date_mouvement,
      utilisateur_id, inventaire_id, commentaire)
    select
      l.produit_id, 'regularisation', 'inventaire', l.ecart, new.valide_le,
      new.valide_par, new.id,
      'Régularisation d''inventaire (théorique ' || l.quantite_theorique ||
      ', compté ' || l.quantite_comptee || ')'
    from inventaire_lignes_produit l
    where l.inventaire_id = new.id and l.ecart <> 0;
  end if;
  return new;
end;
$$;

create trigger tg_valider_inventaire_materiel
after update on inventaires
for each row execute function fn_valider_inventaire_materiel();

-- 7bis. Valider un inventaire de bouteilles écrit les régularisations.
--       Un écart ne se corrige jamais par une écriture directe : il produit un
--       mouvement, daté, signé, et annulable. Une bouteille trouvée en trop
--       entre dans le parc ; une bouteille manquante en sort.
create function fn_valider_inventaire_bouteilles() returns trigger
language plpgsql as $$
begin
  if new.statut = 'valide' and old.statut = 'brouillon' and new.type = 'bouteilles' then
    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, de_emplacement_id,
      vers_lieu, vers_emplacement_id, date_mouvement, utilisateur_id,
      inventaire_id, commentaire)
    select
      'regularisation', l.bouteille_type_id, abs(l.ecart),
      -- Un écart positif vient de nulle part ; un écart négatif y retourne.
      case when l.ecart > 0 then 'hors_parc'
           when l.emplacement_id is null then 'reserve'
           else 'emplacement' end::lieu_bouteille,
      case when l.ecart < 0 then l.emplacement_id end,
      case when l.ecart < 0 then 'hors_parc'
           when l.emplacement_id is null then 'reserve'
           else 'emplacement' end::lieu_bouteille,
      case when l.ecart > 0 then l.emplacement_id end,
      new.valide_le, new.valide_par, new.id,
      'Régularisation d''inventaire (théorique ' || l.quantite_theorique ||
      ', compté ' || l.quantite_comptee || ')'
    from inventaire_lignes_bouteille l
    where l.inventaire_id = new.id and l.ecart <> 0;
  end if;
  return new;
end;
$$;

create trigger tg_valider_inventaire_bouteilles
after update on inventaires
for each row execute function fn_valider_inventaire_bouteilles();

-- 8. Préparer une demande de devis par fournisseur, regroupant tous ses articles
--    sous le seuil. Une seule demande par fournisseur, donc un seul mail.
create function fn_preparer_demandes_devis(p_utilisateur_id uuid default null)
returns setof demandes_devis
language plpgsql as $$
declare
  v_fournisseur record;
  v_demande     demandes_devis;
begin
  for v_fournisseur in
    select distinct fournisseur_id from v_reappro_necessaire where fournisseur_id is not null
  loop
    -- Ne pas rouvrir un devis déjà en cours pour ce fournisseur
    if exists (
      select 1 from demandes_devis
      where fournisseur_id = v_fournisseur.fournisseur_id
        and statut in ('brouillon', 'envoyee')
    ) then
      continue;
    end if;

    insert into demandes_devis (fournisseur_id, cree_par, destinataires)
    select v_fournisseur.fournisseur_id, p_utilisateur_id,
           array_remove(array[f.email, f.email_2], null)
    from fournisseurs f where f.id = v_fournisseur.fournisseur_id
    returning * into v_demande;

    insert into demande_devis_lignes (
      demande_id, produit_id, bouteille_type_id, libelle,
      stock_actuel, seuil, quantite_demandee)
    select distinct on (r.nature, r.article_id)
      v_demande.id,
      case when r.nature = 'produit'   then r.article_id end,
      case when r.nature = 'bouteille' then r.article_id end,
      r.libelle, r.stock_actuel, r.seuil, r.quantite_suggeree
    from v_reappro_necessaire r
    where r.fournisseur_id = v_fournisseur.fournisseur_id;

    return next v_demande;
  end loop;
end;
$$;

-- 9. Le digest du soir a envoyé : on horodate, pour ne pas renvoyer demain.
create function fn_marquer_envois(p_categorie text, p_tournees uuid[])
returns int
language plpgsql as $$
declare v_nb int;
begin
  if p_categorie = 'recap_technicien' then
    update tournees set mail_technicien_envoye_le = now()
     where id = any (p_tournees) and mail_technicien_envoye_le is null;
  elsif p_categorie = 'recap_intervention' then
    update tournees set mail_recap_envoye_le = now()
     where id = any (p_tournees) and mail_recap_envoye_le is null;
  else
    raise exception 'catégorie d''envoi inconnue : %', p_categorie;
  end if;
  get diagnostics v_nb = row_count;
  return v_nb;
end;
$$;

-- 10. Recherche du catalogue par mots-clés, depuis le téléphone de la gouvernante.
--    Tolérante : elle ne lève jamais d'erreur de syntaxe quel que soit le texte
--    saisi, contrairement à une requête plein-texte construite à la volée.
create function fn_rechercher_catalogue(p_terme text default null)
returns setof catalogue_anomalies
language sql stable as $$
  select c.*
  from catalogue_anomalies c
  where c.actif
    and (
      coalesce(btrim(p_terme), '') = ''
      or c.libelle ilike '%' || btrim(p_terme) || '%'
      or exists (
        select 1 from unnest(c.mots_cles) m
        where m ilike btrim(p_terme) || '%'
      )
    )
  -- Les libellés les plus utilisés remontent en tête : sur un téléphone, la
  -- bonne réponse doit être dans les premiers résultats.
  order by c.occurrences desc, c.libelle;
$$;

-- Le catalogue vu depuis un lieu : chaque libellé porte son état ici. Celui qui
-- est déjà ouvert n'est pas proposé à la saisie ; les autres affichent combien
-- de fois le problème est déjà revenu, ce qui est une information, pas un
-- obstacle.
create function fn_catalogue_pour_lieu(
  p_emplacement_id uuid,
  p_terme text default null
) returns table (
  id              uuid,
  libelle         text,
  occurrences     int,
  deja_ouverte    boolean,
  ouverte_depuis  int,
  nb_fois_ici     int,
  derniere_fois   date
)
language sql stable as $$
  select
    c.id,
    c.libelle,
    c.occurrences,
    coalesce(f.ouvertes, 0) > 0,
    o.jours_depuis,
    coalesce(f.nb_fois, 0),
    f.derniere_fois
  from fn_rechercher_catalogue(p_terme) c
  left join v_frequence_anomalie_lieu f
         on f.emplacement_id = p_emplacement_id and f.catalogue_id = c.id
  left join lateral (
    select v.jours_depuis from v_anomalies_du_lieu v
    where v.emplacement_id = p_emplacement_id and v.catalogue_id = c.id and v.ouverte
    order by v.declare_le desc limit 1
  ) o on true
  order by coalesce(f.ouvertes, 0) > 0, c.occurrences desc, c.libelle;
$$;

-- -----------------------------------------------------------------------------
-- Contrôle des données reprises de SharePoint.
-- Les anomalies douteuses sont importées telles quelles puis listées ici, pour
-- être corrigées en connaissance de cause plutôt que devinées à l'import.
-- -----------------------------------------------------------------------------
create view v_controle_donnees as
select
  'date_future'::text  as anomalie_donnee,
  a.id                 as anomalie_id,
  a.reference,
  e.code               as emplacement,
  a.description,
  'Déclarée le ' || to_char(a.declare_le, 'DD/MM/YYYY') || ', soit dans le futur' as detail
from anomalies a
join emplacements e on e.id = a.emplacement_id
where a.declare_le::date > current_date
union all
select
  'localisation_incertaine',
  a.id,
  a.reference,
  e.code,
  a.description,
  coalesce(
    (select c.texte from commentaires c
      where c.anomalie_id = a.id and c.origine = 'reprise'
      order by c.ecrit_le limit 1),
    'Localisation d''origine inconnue')
from anomalies a
join emplacements e on e.id = a.emplacement_id
where e.code = 'General'
union all
select
  'stock_negatif',
  null::uuid,
  null::bigint,
  sp.code,
  sp.designation,
  'Stock calculé à ' || sp.stock || ' : à recaler au comptage physique'
from v_stock_produits sp
where sp.stock < 0
union all
select
  'intervention_future',
  a.id,
  a.reference,
  e.code,
  a.description,
  'Intervention datée du ' || to_char(i.date_intervention, 'DD/MM/YYYY')
from interventions i
join anomalies a    on a.id = i.anomalie_id
join emplacements e on e.id = a.emplacement_id
where i.date_intervention > current_date;

-- ===== supabase/migrations/0003_securite.sql =====
-- =============================================================================
-- Migration 0003 : sécurité au niveau des lignes (RLS)
-- Toute lecture/écriture passe par ces règles, y compris depuis le navigateur.
--
-- Attention : plusieurs politiques permissives sur une même table s'ADDITIONNENT.
-- Les tables portant une règle restrictive (anomalies, validations) ne reçoivent
-- donc jamais de politique « for all », qui l'annulerait.
-- =============================================================================

create function fn_role_courant() returns role_utilisateur
language sql stable security definer set search_path = public as $$
  select role from utilisateurs where auth_id = auth.uid() and actif limit 1;
$$;

create function fn_utilisateur_courant_id() returns uuid
language sql stable security definer set search_path = public as $$
  select id from utilisateurs where auth_id = auth.uid() and actif limit 1;
$$;

create function fn_est_connecte() returns boolean
language sql stable as $$ select fn_role_courant() is not null; $$;

create function fn_peut_ecrire() returns boolean
language sql stable as $$
  select fn_role_courant() in ('technicien','gouvernante','operations','admin');
$$;

create function fn_peut_valider() returns boolean
language sql stable as $$ select fn_role_courant() in ('gouvernante','operations','admin'); $$;

-- Supprimer une anomalie efface une trace : réservé à la chargée des
-- opérations et à l'administrateur.
create function fn_peut_supprimer() returns boolean
language sql stable as $$ select fn_role_courant() in ('operations','admin'); $$;

create function fn_est_admin() returns boolean
language sql stable as $$ select fn_role_courant() = 'admin'; $$;

-- -----------------------------------------------------------------------------
-- Lecture : tout utilisateur connecté et actif voit les données de l'hôtel.
-- -----------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array[
    'utilisateurs','specialites_intervenant','etages','emplacements',
    'types_intervention','prestataires','fournisseurs','catalogue_anomalies',
    'anomalies','tournees','interventions','validations','commentaires','photos_anomalie',
    'factures','facture_interventions','commandes','commande_lignes',
    'produits','article_fournisseurs','photos_produit','mouvements_stock',
    'inventaires','inventaire_lignes_produit',
    'bouteille_types','dotations','incidents_bouteille','incident_lignes_bouteille',
    'mouvements_bouteilles',
    'inventaire_lignes_bouteille',
    'demandes_devis','demande_devis_lignes',
    'recap_abonnements','alertes_destinataires','emails_envoyes','parametres','journal'
  ] loop
    execute format('alter table %I enable row level security', t);
    execute format('grant select on %I to authenticated', t);
    execute format(
      'create policy lecture_connectes on %I for select to authenticated using (fn_est_connecte())', t);
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- Écriture opérationnelle : techniciens, gouvernantes et admins.
-- -----------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array[
    'tournees','interventions','commentaires','photos_anomalie','photos_produit',
    'factures','facture_interventions','commandes','commande_lignes',
    'mouvements_stock','inventaires','inventaire_lignes_produit',
    'incidents_bouteille','incident_lignes_bouteille',
    'mouvements_bouteilles','inventaire_lignes_bouteille',
    'demandes_devis','demande_devis_lignes'
  ] loop
    execute format('grant insert, update, delete on %I to authenticated', t);
    execute format(
      'create policy ecriture_operationnelle on %I for all to authenticated
         using (fn_peut_ecrire()) with check (fn_peut_ecrire())', t);
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- Anomalies : la gouvernante déclare depuis son téléphone en choisissant dans le
-- catalogue. Une anomalie hors catalogue ne peut être créée que par un admin,
-- depuis un ordinateur — c'est la règle demandée, appliquée ici et pas seulement
-- dans l'interface.
-- -----------------------------------------------------------------------------
grant insert, update, delete on anomalies to authenticated;

create policy creation_depuis_catalogue on anomalies
  for insert to authenticated
  with check (fn_peut_ecrire() and (catalogue_id is not null or fn_est_admin()));

create policy modification_anomalies on anomalies
  for update to authenticated
  using (fn_peut_ecrire()) with check (fn_peut_ecrire());

create policy suppression_anomalies on anomalies
  for delete to authenticated
  using (fn_peut_supprimer());

-- -----------------------------------------------------------------------------
-- Validations : un technicien ne peut pas signer à la place de la gouvernante.
-- Elles ne sont ni modifiables ni supprimables : l'historique des avis est figé.
-- -----------------------------------------------------------------------------
grant insert on validations to authenticated;

create policy ecriture_validations on validations
  for insert to authenticated
  with check (
    (acteur = 'technicien'  and fn_peut_ecrire()) or
    (acteur = 'gouvernante' and fn_peut_valider())
  );

-- -----------------------------------------------------------------------------
-- Référentiels et paramétrage : admin uniquement.
-- -----------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array[
    'utilisateurs','specialites_intervenant','etages','emplacements',
    'types_intervention','prestataires','fournisseurs','catalogue_anomalies',
    'produits','article_fournisseurs','bouteille_types','dotations',
    'recap_abonnements','alertes_destinataires','parametres'
  ] loop
    execute format('grant insert, update, delete on %I to authenticated', t);
    execute format(
      'create policy ecriture_admin on %I for all to authenticated
         using (fn_est_admin()) with check (fn_est_admin())', t);
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- La file des courriels : l'application y DÉPOSE un message rédigé, mais ne le
-- modifie ni ne l'efface. C'est le service d'envoi qui horodate le départ.
-- -----------------------------------------------------------------------------
grant insert on emails_envoyes to authenticated;
create policy depot_courriels on emails_envoyes for insert to authenticated
  with check (fn_peut_ecrire() and envoye_le is null);

-- -----------------------------------------------------------------------------
-- Le journal d'audit n'est jamais écrit depuis l'application.
-- -----------------------------------------------------------------------------
revoke insert, update, delete on journal, emails_envoyes from authenticated;

-- -----------------------------------------------------------------------------
-- Les vues appliquent les droits de l'appelant, et non ceux de leur propriétaire :
-- sans cela, une vue contournerait silencieusement les règles ci-dessus.
-- -----------------------------------------------------------------------------
do $$
declare v text;
begin
  foreach v in array array[
    'v_stock_produits','v_cout_prestataire','v_interventions_cout',
    'v_recap_interventions','v_tournees','v_fil_commentaires','v_intervenants',
    'v_interventions_sans_facture','v_envois_en_attente','v_anomalies_du_lieu','v_frequence_anomalie_lieu',
    'v_recurrences_emplacement','v_bouteilles_positions',
    'v_stock_bouteilles','v_bouteilles_par_emplacement','v_incidents_bouteille',
    'v_reappro_necessaire','v_controle_donnees'
  ] loop
    execute format('alter view %I set (security_invoker = on)', v);
    execute format('grant select on %I to authenticated', v);
  end loop;
end $$;

-- ===== supabase/seed/01_referentiels.sql =====
-- =============================================================================
-- Référentiels de départ — Hôtel Parisianer
-- Repris de App.OnStart / colChambres de l'application Power Apps.
-- Idempotent : peut être rejoué sans créer de doublon.
-- =============================================================================

insert into etages (code, nom, ordre) values
  ('RDC',       'Rez-de-chaussée', 0),
  ('1er',       '1er étage',       1),
  ('2eme',      '2ème étage',      2),
  ('3eme',      '3ème étage',      3),
  ('4eme',      '4ème étage',      4),
  ('5eme',      '5ème étage',      5),
  ('Sous-Sol',  'Sous-sol',        6),
  ('Autres',    'Extérieurs',      7)
on conflict (code) do nothing;

-- Emplacements : reprise de la liste fournie, codes compris, y compris sa
-- convention — un escalier appartient à l'étage d'où l'on part. Seules les
-- chambres, aux codes numériques, reçoivent la dotation Purezza.
-- L'entrée d'ordre 90 ne figurait pas dans la liste mais recueille les lignes
-- de l'export qui disent seulement « sous sol » : à confirmer.
with source (etage, code, type, rang) as (values
  ('RDC','01','chambre',0),
  ('RDC','02','chambre',1),
  ('RDC','03','chambre',2),
  ('RDC','PDJ','commun',3),
  ('RDC','Réception','commun',4),
  ('RDC','Lobby','commun',5),
  ('RDC','Entrée','commun',6),
  ('RDC','Cuisine','technique',7),
  ('RDC','Bagagerie','technique',8),
  ('RDC','Ascenseur','technique',9),
  ('RDC','COUR intèrieure','exterieur',10),
  ('RDC','Parties communes','commun',11),
  ('1er','Palier 1er','commun',0),
  ('1er','11','chambre',1),
  ('1er','12','chambre',2),
  ('1er','14','chambre',3),
  ('1er','15','chambre',4),
  ('1er','16','chambre',5),
  ('1er','18','chambre',6),
  ('2eme','2eme étage','commun',0),
  ('2eme','21','chambre',1),
  ('2eme','22','chambre',2),
  ('2eme','24','chambre',3),
  ('2eme','25','chambre',4),
  ('2eme','26','chambre',5),
  ('2eme','27','chambre',6),
  ('2eme','28','chambre',7),
  ('3eme','3eme étage','commun',0),
  ('3eme','31','chambre',1),
  ('3eme','32','chambre',2),
  ('3eme','34','chambre',3),
  ('3eme','35','chambre',4),
  ('3eme','36','chambre',5),
  ('3eme','37','chambre',6),
  ('3eme','38','chambre',7),
  ('3eme','escalier qui mène au 4ème','commun',8),
  ('4eme','4eme étage','commun',0),
  ('4eme','41','chambre',1),
  ('4eme','42','chambre',2),
  ('4eme','44','chambre',3),
  ('4eme','45','chambre',4),
  ('4eme','46','chambre',5),
  ('4eme','47','chambre',6),
  ('4eme','48','chambre',7),
  ('4eme','escalier qui mène au 5ème','commun',8),
  ('5eme','Palier 5ème','commun',0),
  ('5eme','Office 5 ème étage','technique',1),
  ('5eme','51','chambre',2),
  ('5eme','52','chambre',3),
  ('5eme','54','chambre',4),
  ('5eme','55','chambre',5),
  ('5eme','56','chambre',6),
  ('5eme','57','chambre',7),
  ('5eme','58','chambre',8),
  ('Sous-Sol','Salle de sport','commun',0),
  ('Sous-Sol','Sas de sécurité','commun',1),
  ('Sous-Sol','WC Clients','commun',2),
  ('Sous-Sol','WC Femmes','commun',3),
  ('Sous-Sol','WC Hommes','commun',4),
  ('Sous-Sol','Escalier qui mène au RDC','commun',5),
  ('Sous-Sol','Salle de repos','commun',6),
  ('Sous-Sol','Vestiaire Hommes','technique',7),
  ('Sous-Sol','Vestiaire Femmes','technique',8),
  ('Sous-Sol','Lingerie','technique',9),
  ('Sous-Sol','Local TGBT','technique',10),
  ('Sous-Sol','Local Technique','technique',11),
  ('Sous-Sol','Local poubelle','technique',12),
  ('Sous-Sol','Chaufferie','technique',13),
  ('Autres','Toit','exterieur',0),
  ('Sous-Sol','Sous-sol divers','commun',90)
)
insert into emplacements (code, nom, etage_id, type, dote_bouteilles, ordre)
select s.code, s.code, e.id, s.type::type_emplacement, s.type = 'chambre', s.rang
from source s join etages e on e.code = s.etage
on conflict (code) do nothing;

-- Les quatre types réellement utilisés dans la liste d'origine.
insert into types_intervention (code, nom) values
  ('TECHNIQUE',   'Technique'),
  ('ELECTRIQUE',  'Électrique'),
  ('PLOMBERIE',   'Plomberie'),
  ('ACHATS',      'Achats')
on conflict (code) do nothing;

-- Fournisseur des bouteilles. Purezza est la marque des bouteilles ; le
-- fournisseur, celui qui facture et à qui l'on commande, est Culligan. Le
-- contact y change souvent : c'est pour cela que le nom de la personne est un
-- champ libre, révisable, et non un référentiel à part.
insert into fournisseurs (nom, delai_livraison_jours) values ('Culligan', 7)
on conflict (nom) do nothing;

-- Bouteilles Purezza : 17,50 € facturés au client, 8 € de coût d'achat.
-- `seuil_alerte` porte sur la RÉSERVE — le nombre de bouteilles encore
-- disponibles pour re-doter une chambre. Valeurs à ajuster à l'usage.
insert into bouteille_types (code, libelle, prix_vente, prix_achat, seuil_alerte, quantite_reappro, couleur) values
  ('filtree',    'Eau filtrée',    17.50, 8.00, 10, 24, '#3A6499'),
  ('petillante', 'Eau gazeuse',    17.50, 8.00, 10, 24, '#9E3538')
on conflict (code) do nothing;

-- Culligan fournit les deux types. D'autres fournisseurs peuvent être ajoutés
-- sur le même article : la demande de devis partira alors vers chacun.
insert into article_fournisseurs (bouteille_type_id, fournisseur_id, prefere)
select bt.id, f.id, true
from bouteille_types bt, fournisseurs f where f.nom = 'Culligan'
on conflict do nothing;

-- Le libellé a changé après coup : sur une base déjà installée, on le corrige
-- plutôt que de créer un doublon. « Gazeuse » est le mot employé dans l'hôtel.
update bouteille_types set libelle = 'Eau gazeuse' where code = 'petillante';

-- Dotation permanente : 1 filtrée + 1 gazeuse dans chaque chambre.
insert into dotations (emplacement_id, bouteille_type_id, quantite)
select e.id, bt.id, 1
from emplacements e
cross join bouteille_types bt
where e.dote_bouteilles
on conflict (emplacement_id, bouteille_type_id) do nothing;

-- Destinataires des alertes automatiques. À compléter depuis l'écran
-- d'administration. L'alerte bouteille est destinée à la réception, qui
-- recontacte le client ; la gouvernante, elle, ne reçoit aucun mail.
insert into alertes_destinataires (evenement, destinataires, actif) values
  ('incident_bouteille', '{fom@contacthotelparisianer.com}', true),
  ('seuil_stock',        '{}', false)
on conflict (evenement) do update
  set destinataires = excluded.destinataires, actif = excluded.actif
  where alertes_destinataires.evenement = 'incident_bouteille';

-- ===== supabase/seed/02_catalogue_anomalies.sql =====
-- =============================================================================
-- Catalogue d'anomalies — généré depuis l'export de « TEST Tech 3 »
--   795 lignes  ->  268 libellés distincts
--
-- Ne pas modifier à la main : régénérer avec
--   python3 outils/generer_catalogue.py <export.xlsx> > supabase/seed/02_catalogue_anomalies.sql
--
-- La gouvernante déclare en cherchant ici par mots-clés ; elle ne peut pas
-- saisir de texte libre. Ajouter une entrée est réservé à l'admin (voir RLS).
-- `occurrences` sert à trier les plus courantes en tête de liste.
-- =============================================================================

with source (libelle, mots_cles, type_code, occurrences) as (values
  ('Demande de vérification s''il y a la présence de punaises', array['demande', 'verification', 'presence', 'punaises']::text[], 'TECHNIQUE', 75),
  ('Nettoyage des filtres prévu dans le contrat avec Avir', array['nettoyage', 'filtres', 'prevu', 'contrat', 'avir']::text[], 'TECHNIQUE', 40),
  ('Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', array['changement', 'circuits', 'electriques', 'eteigne', 'quand', 'carte', 'retiree']::text[], 'ELECTRIQUE', 37),
  ('lavabo bouché', array['lavabo', 'bouche']::text[], 'TECHNIQUE', 26),
  ('serrer le bras liseuse côté droit', array['serrer', 'bras', 'liseuse', 'cote', 'droit']::text[], 'TECHNIQUE', 16),
  ('remplacer l''économiseur d''énergie pour éclairage principal', array['remplacer', 'economiseur', 'energie', 'eclairage', 'principal']::text[], 'ELECTRIQUE', 15),
  ('lit côté gauche cassé', array['lit', 'cote', 'gauche', 'casse']::text[], 'TECHNIQUE', 14),
  ('flexible douche à changer', array['flexible', 'douche', 'changer']::text[], 'TECHNIQUE', 13),
  ('Spot à changer', array['spot', 'changer']::text[], 'ELECTRIQUE', 13),
  ('serrer le bras liseuse côté gauche', array['serrer', 'bras', 'liseuse', 'cote', 'gauche']::text[], 'TECHNIQUE', 12),
  ('Miroir plateau à changé', array['miroir', 'plateau', 'change']::text[], 'TECHNIQUE', 11),
  ('Changement des rideaux', array['changement', 'rideaux']::text[], 'TECHNIQUE', 10),
  ('Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', array['voir', 'possible', 'espace', 'entre', 'mitigeur', 'mur']::text[], 'TECHNIQUE', 10),
  ('bloc secour/batterie a changer', array['bloc', 'secour', 'batterie', 'changer']::text[], 'TECHNIQUE', 9),
  ('Détection de punaises de lit au niveau de la tête de lit constaté le 11/10/24 par la societe Ecoflair', array['detection', 'punaises', 'lit', 'niveau', 'tete', 'constate', 'societe', 'ecoflair']::text[], 'TECHNIQUE', 8),
  ('joint sillicone dans le bac à douche', array['joint', 'sillicone', 'bac', 'douche']::text[], 'TECHNIQUE', 8),
  ('Lit côté droit cassé', array['lit', 'cote', 'droit', 'casse']::text[], 'TECHNIQUE', 8),
  ('bouton mitigeur douche manquant', array['bouton', 'mitigeur', 'douche', 'manquant']::text[], 'TECHNIQUE', 7),
  ('flexible fuit au niveau du pommeau de douche', array['flexible', 'fuit', 'niveau', 'pommeau', 'douche']::text[], 'TECHNIQUE', 7),
  ('refixer la liseuse de droite', array['refixer', 'liseuse', 'droite']::text[], 'TECHNIQUE', 7),
  ('Refixer la liseuse de gauche', array['refixer', 'liseuse', 'gauche']::text[], 'TECHNIQUE', 7),
  ('Refixer le miroir grossissant', array['refixer', 'miroir', 'grossissant']::text[], 'TECHNIQUE', 7),
  ('Changement du séche cheveux', array['changement', 'seche', 'cheveux']::text[], 'TECHNIQUE', 6),
  ('lampe bureau à réparer', array['lampe', 'bureau', 'reparer']::text[], 'TECHNIQUE', 6),
  ('Mettre une vis pour l''aimant de la porte dorée armoire (haut)', array['mettre', 'vis', 'aimant', 'porte', 'doree', 'armoire', 'haut']::text[], 'TECHNIQUE', 6),
  ('Télérupteur à changer (repris de l''ancien tableau technique )', array['telerupteur', 'changer', 'repris', 'ancien', 'tableau', 'technique']::text[], 'ELECTRIQUE', 6),
  ('urgent - joints sillicone douche - lavabo et wc à refaire complètement', array['urgent', 'joints', 'sillicone', 'douche', 'lavabo', 'refaire', 'completement']::text[], 'TECHNIQUE', 6),
  ('Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', array['verifier', 'tous', 'joints', 'douche', 'salle', 'bain', 'presentent', 'aucun']::text[], 'TECHNIQUE', 6),
  ('Ascenseur en panne - Il faut contacter KONE', array['ascenseur', 'panne', 'faut', 'contacter', 'kone']::text[], 'TECHNIQUE', 5),
  ('barriere de douche à fixer', array['barriere', 'douche', 'fixer']::text[], 'TECHNIQUE', 5),
  ('flexible douche qui fuit', array['flexible', 'douche', 'fuit']::text[], 'TECHNIQUE', 5),
  ('Télérupteur à changer - appliques murales sautent', array['telerupteur', 'changer', 'appliques', 'murales', 'sautent']::text[], 'ELECTRIQUE', 5),
  ('Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs', array['verification', 'contractuelle', 'verifier', 'presence', 'rongeurs']::text[], 'TECHNIQUE', 5),
  ('changer connecteur lumiéres miroir SDB', array['changer', 'connecteur', 'lumieres', 'miroir', 'sdb']::text[], 'ELECTRIQUE', 4),
  ('deboucher l''evier', array['deboucher', 'evier']::text[], 'PLOMBERIE', 4),
  ('flexible de douche à changer', array['flexible', 'douche', 'changer']::text[], 'TECHNIQUE', 4),
  ('flexible liseuse côté droit à changer', array['flexible', 'liseuse', 'cote', 'droit', 'changer']::text[], 'TECHNIQUE', 4),
  ('L''eau coule dans la cuvette des WC', array['eau', 'coule', 'cuvette']::text[], 'TECHNIQUE', 4),
  ('Support gel douche à changer', array['support', 'gel', 'douche', 'changer']::text[], 'TECHNIQUE', 4),
  ('Télérupteur à changer - spot et leds', array['telerupteur', 'changer', 'spot', 'leds']::text[], 'ELECTRIQUE', 4),
  ('urgent - joints sillicone douche', array['urgent', 'joints', 'sillicone', 'douche']::text[], 'TECHNIQUE', 4),
  ('URGENT - Joints sillicone douche et lavabo à refaire complètement', array['urgent', 'joints', 'sillicone', 'douche', 'lavabo', 'refaire', 'completement']::text[], 'TECHNIQUE', 4),
  ('Vérifier s''il ne faut pas changer entièrement la colonne de douche', array['verifier', 'faut', 'changer', 'entierement', 'colonne', 'douche']::text[], 'TECHNIQUE', 4),
  ('Bouton pour le mitigeur douche à acheter car il n''y en a plus', array['bouton', 'mitigeur', 'douche', 'acheter', 'car']::text[], 'ACHATS', 3),
  ('Changement des rideaux - salle de bain', array['changement', 'rideaux', 'salle', 'bain']::text[], 'TECHNIQUE', 3),
  ('Changement flexible liseuse droite', array['changement', 'flexible', 'liseuse', 'droite']::text[], 'TECHNIQUE', 3),
  ('flexible liseuse côté gauche à changer', array['flexible', 'liseuse', 'cote', 'gauche', 'changer']::text[], 'TECHNIQUE', 3),
  ('Fuite depuis joint d’évacuation en dessous d’évier', array['fuite', 'depuis', 'joint', 'evacuation', 'dessous', 'evier']::text[], 'TECHNIQUE', 3),
  ('Il faut changer la bouilloire', array['faut', 'changer', 'bouilloire']::text[], 'TECHNIQUE', 3),
  ('Il manque des crochets pour faire tenir le rideau', array['manque', 'crochets', 'tenir', 'rideau']::text[], 'TECHNIQUE', 3),
  ('joint étanchéité pare douche', array['joint', 'etancheite', 'pare', 'douche']::text[], 'TECHNIQUE', 3),
  ('Joint pare douche', array['joint', 'pare', 'douche']::text[], 'TECHNIQUE', 3),
  ('Joint pour faire tenir le pommeau de douche', array['joint', 'tenir', 'pommeau', 'douche']::text[], 'TECHNIQUE', 3),
  ('La poignée de la fenêtre s''enlève', array['poignee', 'fenetre', 'enleve']::text[], 'TECHNIQUE', 3),
  ('Lavabo qui coule', array['lavabo', 'coule']::text[], 'TECHNIQUE', 3),
  ('Mettre une vis pour l''aimant de la porte dorée armoire (bas)', array['mettre', 'vis', 'aimant', 'porte', 'doree', 'armoire', 'bas']::text[], 'TECHNIQUE', 3),
  ('Moisissure présente sans la salle de bain', array['moisissure', 'presente', 'sans', 'salle', 'bain']::text[], 'TECHNIQUE', 3),
  ('porte d''entrée qui ne se verouille pas - urgent', array['porte', 'entree', 'verouille', 'urgent']::text[], 'ELECTRIQUE', 3),
  ('prise arrachée du mur sdb', array['prise', 'arrachee', 'mur', 'sdb']::text[], 'ELECTRIQUE', 3),
  ('remplacement bras de liseuse (coté gauche)', array['remplacement', 'bras', 'liseuse', 'cote', 'gauche']::text[], 'ELECTRIQUE', 3),
  ('Spot à coté de l''ascenseur à changer', array['spot', 'cote', 'ascenseur', 'changer']::text[], 'TECHNIQUE', 3),
  ('télécommande clim à remplacer', array['telecommande', 'clim', 'remplacer']::text[], 'TECHNIQUE', 3),
  ('voir avec miroitier pour miroir placard cassé en bas (grand)', array['voir', 'miroitier', 'miroir', 'placard', 'casse', 'bas', 'grand']::text[], 'TECHNIQUE', 3),
  ('Bac de douche à changer', array['bac', 'douche', 'changer']::text[], 'TECHNIQUE', 2),
  ('Bac de douche à changer - URGENT', array['bac', 'douche', 'changer', 'urgent']::text[], 'TECHNIQUE', 2),
  ('batterie du bloc secours changé (celui au dessus de la porte d''entrée)', array['batterie', 'bloc', 'secours', 'change', 'celui', 'dessus', 'porte', 'entree']::text[], 'TECHNIQUE', 2),
  ('cale porte à refixer (la piece est encore dans la chambre)', array['cale', 'porte', 'refixer', 'piece', 'encore', 'chambre']::text[], 'TECHNIQUE', 2),
  ('changement support lait corporel', array['changement', 'support', 'lait', 'corporel']::text[], 'TECHNIQUE', 2),
  ('difficulté à fermer la porte de chambre -', array['difficulte', 'fermer', 'porte', 'chambre']::text[], 'TECHNIQUE', 2),
  ('flexible liseuse côté droit à resserer', array['flexible', 'liseuse', 'cote', 'droit', 'resserer']::text[], 'TECHNIQUE', 2),
  ('flexible liseuse côté gauche à fixer', array['flexible', 'liseuse', 'cote', 'gauche', 'fixer']::text[], 'TECHNIQUE', 2),
  ('Fuite syphon Lavabo SDB', array['fuite', 'syphon', 'lavabo', 'sdb']::text[], 'PLOMBERIE', 2),
  ('Grand miroir côté armoire cassé', array['grand', 'miroir', 'cote', 'armoire', 'casse']::text[], 'TECHNIQUE', 2),
  ('Il faut refaire les joints mitigeur de douche', array['faut', 'refaire', 'joints', 'mitigeur', 'douche']::text[], 'TECHNIQUE', 2),
  ('joint pare douche à remplacer', array['joint', 'pare', 'douche', 'remplacer']::text[], 'TECHNIQUE', 2),
  ('Joint porte sdb', array['joint', 'porte', 'sdb']::text[], 'TECHNIQUE', 2),
  ('La porte principale ne se fermait pas bien', array['porte', 'principale', 'fermait', 'bien']::text[], 'TECHNIQUE', 2),
  ('Lèvre de douche à changer sur le côté pare douche', array['levre', 'douche', 'changer', 'cote', 'pare']::text[], 'TECHNIQUE', 2),
  ('Liseuse côté droit à changer', array['liseuse', 'cote', 'droit', 'changer']::text[], 'TECHNIQUE', 2),
  ('Liseuse côté gauche à changer', array['liseuse', 'cote', 'gauche', 'changer']::text[], 'TECHNIQUE', 2),
  ('lit cassé côté gauche', array['lit', 'casse', 'cote', 'gauche']::text[], 'TECHNIQUE', 2),
  ('lit côté droit cassé - à agrafer', array['lit', 'cote', 'droit', 'casse', 'agrafer']::text[], 'TECHNIQUE', 2),
  ('Manque porte placard ( grande) / visser aimant', array['manque', 'porte', 'placard', 'grande', 'visser', 'aimant']::text[], 'TECHNIQUE', 2),
  ('Mur gauche côté fenêtre endommagé', array['mur', 'gauche', 'cote', 'fenetre', 'endommage']::text[], 'TECHNIQUE', 2),
  ('Neon salle de repos à changer', array['neon', 'salle', 'repos', 'changer']::text[], 'TECHNIQUE', 2),
  ('Objet coincé dans la prise électrique', array['objet', 'coince', 'prise', 'electrique']::text[], 'TECHNIQUE', 2),
  ('porte du frigo à fixer', array['porte', 'frigo', 'fixer']::text[], 'TECHNIQUE', 2),
  ('recoller les cornières dorées sur les deux pilliers', array['recoller', 'cornieres', 'dorees', 'deux', 'pilliers']::text[], 'TECHNIQUE', 2),
  ('Refixer correctement le miroir grossissant au mur SDB', array['refixer', 'correctement', 'miroir', 'grossissant', 'mur', 'sdb']::text[], 'TECHNIQUE', 2),
  ('refixer la prise', array['refixer', 'prise']::text[], 'TECHNIQUE', 2),
  ('Sol du bac de douche decoller (pour montrer à l''inspecteur) puis recoller de nouveau)', array['sol', 'bac', 'douche', 'decoller', 'montrer', 'inspecteur', 'puis', 'recoller']::text[], 'PLOMBERIE', 2),
  ('spot chambre à remplacer', array['spot', 'chambre', 'remplacer']::text[], 'TECHNIQUE', 2),
  ('spot du couloir a changer', array['spot', 'couloir', 'changer']::text[], 'ELECTRIQUE', 2),
  ('télérupteur lumière néons et spots plafond sautent', array['telerupteur', 'lumiere', 'neons', 'spots', 'plafond', 'sautent']::text[], 'ELECTRIQUE', 2),
  ('télérupteur pour spots plafond à changer', array['telerupteur', 'spots', 'plafond', 'changer']::text[], 'ELECTRIQUE', 2),
  ('urgent! priorite coffre à reprogrammer', array['urgent', 'priorite', 'coffre', 'reprogrammer']::text[], 'TECHNIQUE', 2),
  ('2 Spot SDB à changer', array['spot', 'sdb', 'changer']::text[], 'ELECTRIQUE', 1),
  ('4 eme spot plafond couloir du fond à changer', array['eme', 'spot', 'plafond', 'couloir', 'fond', 'changer']::text[], 'TECHNIQUE', 1),
  ('acheter crépines pour les 2 gouttières sur le toit terrasse', array['acheter', 'crepines', 'gouttieres', 'toit', 'terrasse']::text[], 'TECHNIQUE', 1),
  ('Ampoule de l''applique à changer', array['ampoule', 'applique', 'changer']::text[], 'ELECTRIQUE', 1),
  ('Ampoule de la suspension lumineuse à côté de l''ascenseur qui clignote parfois', array['ampoule', 'suspension', 'lumineuse', 'cote', 'ascenseur', 'clignote', 'parfois']::text[], 'ELECTRIQUE', 1),
  ('Applique coté entrée à refixer correctement', array['applique', 'cote', 'entree', 'refixer', 'correctement']::text[], 'TECHNIQUE', 1),
  ('Attache mural de la porte de secours devant la porte des escaliers à fixer', array['attache', 'mural', 'porte', 'secours', 'devant', 'escaliers', 'fixer']::text[], 'TECHNIQUE', 1),
  ('Baguette d''angle noir a recollé - mur entree chambre', array['baguette', 'angle', 'noir', 'recolle', 'mur', 'entree', 'chambre']::text[], 'TECHNIQUE', 1),
  ('barre de pare douche à refixer', array['barre', 'pare', 'douche', 'refixer']::text[], 'TECHNIQUE', 1),
  ('Barrre de douche à refixer', array['barrre', 'douche', 'refixer']::text[], 'TECHNIQUE', 1),
  ('Batterie du bloc secours à changer (celui en face de l''ascenseur)', array['batterie', 'bloc', 'secours', 'changer', 'celui', 'face', 'ascenseur']::text[], 'ELECTRIQUE', 1),
  ('Batterie du bloc secours à changer (celui en face de la chambre 28)', array['batterie', 'bloc', 'secours', 'changer', 'celui', 'face', 'chambre']::text[], 'TECHNIQUE', 1),
  ('Batterie du bloc secours à changer (celui en face de la chambre 44)', array['batterie', 'bloc', 'secours', 'changer', 'celui', 'face', 'chambre']::text[], 'ELECTRIQUE', 1),
  ('Batterie du bloc secours à changer (celui en face de la chambre 48)', array['batterie', 'bloc', 'secours', 'changer', 'celui', 'face', 'chambre']::text[], 'ELECTRIQUE', 1),
  ('Batterie du bloc secours à changer (celui en face de la chambre 58)', array['batterie', 'bloc', 'secours', 'changer', 'celui', 'face', 'chambre']::text[], 'ELECTRIQUE', 1),
  ('Batterie du bloc secours à changer (celui en face de la sortie de secours)', array['batterie', 'bloc', 'secours', 'changer', 'celui', 'face', 'sortie']::text[], 'ELECTRIQUE', 1),
  ('bloc secour/batterie a changer (en face de la chambre 14)', array['bloc', 'secour', 'batterie', 'changer', 'face', 'chambre']::text[], 'ELECTRIQUE', 1),
  ('Bouton on/off pour regler la temperature non fonctionnel', array['bouton', 'off', 'regler', 'temperature', 'non', 'fonctionnel']::text[], 'TECHNIQUE', 1),
  ('Bouton pour le mitigeur douche à changer', array['bouton', 'mitigeur', 'douche', 'changer']::text[], 'TECHNIQUE', 1),
  ('Bruit provenant du panneau électrique', array['bruit', 'provenant', 'panneau', 'electrique']::text[], 'ELECTRIQUE', 1),
  ('Cache pile du coffre manquant', array['cache', 'pile', 'coffre', 'manquant']::text[], 'TECHNIQUE', 1),
  ('Cache Rosace de la poignée (exterieure) de porte à changer', array['cache', 'rosace', 'poignee', 'exterieure', 'porte', 'changer']::text[], 'TECHNIQUE', 1),
  ('Cadre de la porte de la salle de bain à fixer', array['cadre', 'porte', 'salle', 'bain', 'fixer']::text[], 'TECHNIQUE', 1),
  ('Cadre porte SDB bois - décollé du mur', array['cadre', 'porte', 'sdb', 'bois', 'decolle', 'mur']::text[], 'TECHNIQUE', 1),
  ('change bonde lavabo', array['change', 'bonde', 'lavabo']::text[], 'TECHNIQUE', 1),
  ('Changement ampoule lampe bureau', array['changement', 'ampoule', 'lampe', 'bureau']::text[], 'TECHNIQUE', 1),
  ('changement du flexible de la liseuse de droite', array['changement', 'flexible', 'liseuse', 'droite']::text[], 'TECHNIQUE', 1),
  ('changer la bonde du lavabo', array['changer', 'bonde', 'lavabo']::text[], 'PLOMBERIE', 1),
  ('Changer le miroir SDB car rouillé de l''interieur', array['changer', 'miroir', 'sdb', 'car', 'rouille', 'interieur']::text[], 'TECHNIQUE', 1),
  ('Charnière de la porte du bas à changer', array['charniere', 'porte', 'bas', 'changer']::text[], 'TECHNIQUE', 1),
  ('Coffre fort HS', array['coffre', 'fort']::text[], 'TECHNIQUE', 1),
  ('coller deux baguettes d''angle noires dans l''encadrement porte DAES', array['coller', 'deux', 'baguettes', 'angle', 'noires', 'encadrement', 'porte', 'daes']::text[], 'TECHNIQUE', 1),
  ('De l''eau coule à l''interier depuis la fenetre', array['eau', 'coule', 'interier', 'depuis', 'fenetre']::text[], 'TECHNIQUE', 1),
  ('demander à Hedi de contrôler l''état des crépines, des gouttières et de la descente de pluie et les dégager si beoin', array['demander', 'hedi', 'controler', 'etat', 'crepines', 'gouttieres', 'descente', 'pluie']::text[], 'TECHNIQUE', 1),
  ('Détection de punaises de lit au niveau de la tête de lit constaté le 30/09/25 par la societe Ecoflair', array['detection', 'punaises', 'lit', 'niveau', 'tete', 'constate', 'societe', 'ecoflair']::text[], 'TECHNIQUE', 1),
  ('ecoulement faible eau chasse d''eau vestiaire femme', array['ecoulement', 'faible', 'eau', 'chasse', 'vestiaire', 'femme']::text[], 'TECHNIQUE', 1),
  ('Evier qui coule', array['evier', 'coule']::text[], 'TECHNIQUE', 1),
  ('évier salle de pause qui fuit', array['evier', 'salle', 'pause', 'fuit']::text[], 'TECHNIQUE', 1),
  ('Faire installer la machine café -', array['installer', 'machine', 'cafe']::text[], 'TECHNIQUE', 1),
  ('Faire la pose du Lino afin d''éviter toute fuite en chambre 41', array['pose', 'lino', 'afin', 'eviter', 'toute', 'fuite', 'chambre']::text[], 'TECHNIQUE', 1),
  ('faire un trou et ensuite avec un fil de fer tirer les fils pour installer la prise pour le nouveau cadre', array['trou', 'ensuite', 'fil', 'fer', 'tirer', 'fils', 'installer', 'prise']::text[], 'ELECTRIQUE', 1),
  ('fenêtre se ferme mal', array['fenetre', 'ferme', 'mal']::text[], 'TECHNIQUE', 1),
  ('Fil de d''aspirateur à changer', array['fil', 'aspirateur', 'changer']::text[], 'TECHNIQUE', 1),
  ('Fissure constaté au plafond', array['fissure', 'constate', 'plafond']::text[], 'TECHNIQUE', 1),
  ('Flexible à changer', array['flexible', 'changer']::text[], 'TECHNIQUE', 1),
  ('flexible liseuse côté gauche à resserer', array['flexible', 'liseuse', 'cote', 'gauche', 'resserer']::text[], 'TECHNIQUE', 1),
  ('flexible liseuse côté SDB à changer', array['flexible', 'liseuse', 'cote', 'sdb', 'changer']::text[], 'TECHNIQUE', 1),
  ('Fortes odeurs constaté au niveau de la colonne, il faut trouver une solution pour reboucher', array['fortes', 'odeurs', 'constate', 'niveau', 'colonne', 'faut', 'trouver', 'solution']::text[], 'TECHNIQUE', 1),
  ('frein de chute abattant WC non fonctionnel -', array['frein', 'chute', 'abattant', 'non', 'fonctionnel']::text[], 'TECHNIQUE', 1),
  ('Fuite au niveau du bac de douche', array['fuite', 'niveau', 'bac', 'douche']::text[], 'TECHNIQUE', 1),
  ('Fuite au niveau du lave-vaisselle', array['fuite', 'niveau', 'lave', 'vaisselle']::text[], 'TECHNIQUE', 1),
  ('Fuite au niveau du spot dans la douche', array['fuite', 'niveau', 'spot', 'douche']::text[], 'TECHNIQUE', 1),
  ('Fuite constatée au niveau du deuxième lustre.', array['fuite', 'constatee', 'niveau', 'deuxieme', 'lustre']::text[], 'TECHNIQUE', 1),
  ('fuite mitigeur douche', array['fuite', 'mitigeur', 'douche']::text[], 'TECHNIQUE', 1),
  ('Il faut changer le fil du Chafing dish rond (réchaud de buffet)', array['faut', 'changer', 'fil', 'chafing', 'dish', 'rond', 'rechaud', 'buffet']::text[], 'ELECTRIQUE', 1),
  ('Il faut changer le sèche-main', array['faut', 'changer', 'seche', 'main']::text[], 'ELECTRIQUE', 1),
  ('Il faut faire les joints', array['faut', 'joints']::text[], 'TECHNIQUE', 1),
  ('Il faut fixer la barre de douche au support mural', array['faut', 'fixer', 'barre', 'douche', 'support', 'mural']::text[], 'TECHNIQUE', 1),
  ('Il faut rattacher le support du lustre au plafond.', array['faut', 'rattacher', 'support', 'lustre', 'plafond']::text[], 'TECHNIQUE', 1),
  ('Il faut repeindre les deux pots de fleurs', array['faut', 'repeindre', 'deux', 'pots', 'fleurs']::text[], 'TECHNIQUE', 1),
  ('Il manque juste le petit papier qui va à l''interieur et non le cache', array['manque', 'juste', 'petit', 'papier', 'interieur', 'non', 'cache']::text[], 'TECHNIQUE', 1),
  ('Il manque la porte du placard du bas', array['manque', 'porte', 'placard', 'bas']::text[], 'TECHNIQUE', 1),
  ('Il manque un joint sur la porte de la salle de bain et elle est désaxée', array['manque', 'joint', 'porte', 'salle', 'bain', 'elle', 'desaxee']::text[], 'TECHNIQUE', 1),
  ('Installer un interupteur', array['installer', 'interupteur']::text[], 'ELECTRIQUE', 1),
  ('inverser la VMC pour un meilleur fonctionnement', array['inverser', 'vmc', 'meilleur', 'fonctionnement']::text[], 'TECHNIQUE', 1),
  ('Joint de pare douche à changer', array['joint', 'pare', 'douche', 'changer']::text[], 'TECHNIQUE', 1),
  ('Joint de silicone à enlever pour ensuite poser des nouveaux au niveau du bac à douche', array['joint', 'silicone', 'enlever', 'ensuite', 'poser', 'nouveaux', 'niveau', 'bac']::text[], 'TECHNIQUE', 1),
  ('Joint pare douche à changer', array['joint', 'pare', 'douche', 'changer']::text[], 'TECHNIQUE', 1),
  ('Joint pare douche à changer car laisse passer l''eau', array['joint', 'pare', 'douche', 'changer', 'car', 'laisse', 'passer', 'eau']::text[], 'TECHNIQUE', 1),
  ('joint sillicone dans le bac à douche et lavabo', array['joint', 'sillicone', 'bac', 'douche', 'lavabo']::text[], 'TECHNIQUE', 1),
  ('joint sillicone lavabo', array['joint', 'sillicone', 'lavabo']::text[], 'TECHNIQUE', 1),
  ('joint sillicone lavabo douche et WC', array['joint', 'sillicone', 'lavabo', 'douche']::text[], 'TECHNIQUE', 1),
  ('joint sillicone lavabo et douche', array['joint', 'sillicone', 'lavabo', 'douche']::text[], 'TECHNIQUE', 1),
  ('La base du fauteuil doit être visée', array['base', 'fauteuil', 'doit', 'etre', 'visee']::text[], 'TECHNIQUE', 1),
  ('La chasse d''eau ne fonctionne pas', array['chasse', 'eau', 'fonctionne']::text[], 'TECHNIQUE', 1),
  ('La lumiere du miroir ne s''allume pas', array['lumiere', 'miroir', 'allume']::text[], 'ELECTRIQUE', 1),
  ('La lumiere du plafond saute - Télérupteur à changer', array['lumiere', 'plafond', 'saute', 'telerupteur', 'changer']::text[], 'ELECTRIQUE', 1),
  ('La moquette de la premiere marche en partant du haut est decollée', array['moquette', 'premiere', 'marche', 'partant', 'haut', 'decollee']::text[], 'TECHNIQUE', 1),
  ('La prise derrière la télévision ne fonctionne pas (à confirmer)', array['prise', 'derriere', 'television', 'fonctionne', 'confirmer']::text[], 'ELECTRIQUE', 1),
  ('La serrure électronique de chez dormakaba ne fonctionne plus', array['serrure', 'electronique', 'chez', 'dormakaba', 'fonctionne']::text[], 'TECHNIQUE', 1),
  ('Lampe bureau cassée - faire réparer comme M Negroni', array['lampe', 'bureau', 'cassee', 'reparer', 'comme', 'negroni']::text[], 'TECHNIQUE', 1),
  ('Lave-main à installer', array['lave', 'main', 'installer']::text[], 'ELECTRIQUE', 1),
  ('Le scratch du rideau est défaillant', array['scratch', 'rideau', 'defaillant']::text[], 'TECHNIQUE', 1),
  ('Le scratch du rideau est défaillant (SDB)', array['scratch', 'rideau', 'defaillant', 'sdb']::text[], 'TECHNIQUE', 1),
  ('liseuse gauche à resserer', array['liseuse', 'gauche', 'resserer']::text[], 'TECHNIQUE', 1),
  ('Lumière grand miroir SDB', array['lumiere', 'grand', 'miroir', 'sdb']::text[], 'ELECTRIQUE', 1),
  ('Lumiere miroir à vérifier', array['lumiere', 'miroir', 'verifier']::text[], 'ELECTRIQUE', 1),
  ('Lumiéres miroir SDB', array['lumieres', 'miroir', 'sdb']::text[], 'ELECTRIQUE', 1),
  ('Lumiéres miroir SDB à changer', array['lumieres', 'miroir', 'sdb', 'changer']::text[], 'TECHNIQUE', 1),
  ('Lumieres SDB à changer', array['lumieres', 'sdb', 'changer']::text[], 'ELECTRIQUE', 1),
  ('Lunette des WC à changer', array['lunette', 'changer']::text[], 'TECHNIQUE', 1),
  ('Manque porte placard du haut', array['manque', 'porte', 'placard', 'haut']::text[], 'TECHNIQUE', 1),
  ('mettre des cornieres noires à l''entrée de la chambe', array['mettre', 'cornieres', 'noires', 'entree', 'chambe']::text[], 'TECHNIQUE', 1),
  ('Mettre feutrine découpée sur mesure au dos de la table de chevet pour protéger le mur', array['mettre', 'feutrine', 'decoupee', 'mesure', 'dos', 'table', 'chevet', 'proteger']::text[], 'TECHNIQUE', 1),
  ('Mettre le tableau pour l''affichage obligatoire', array['mettre', 'tableau', 'affichage', 'obligatoire']::text[], 'TECHNIQUE', 1),
  ('Mettre un joint pare douche à la bonne taille car pas assez long et l''eau passe', array['mettre', 'joint', 'pare', 'douche', 'bonne', 'taille', 'car', 'assez']::text[], 'TECHNIQUE', 1),
  ('Mettre une vise sur la Porte dorée armoire (haut)', array['mettre', 'vise', 'porte', 'doree', 'armoire', 'haut']::text[], 'TECHNIQUE', 1),
  ('Nettoyage du tuyau d''évacuation du séche linge', array['nettoyage', 'tuyau', 'evacuation', 'seche', 'linge']::text[], 'TECHNIQUE', 1),
  ('passer le produit sur le parquet ( même dessoous les bacs à plantes) - produit dans la bagagerie', array['passer', 'produit', 'parquet', 'meme', 'dessoous', 'bacs', 'plantes', 'bagagerie']::text[], 'TECHNIQUE', 1),
  ('Pièce qui sert à ajuster la hauteur du pommeau de douche à viser', array['piece', 'sert', 'ajuster', 'hauteur', 'pommeau', 'douche', 'viser']::text[], 'TECHNIQUE', 1),
  ('plafond douche SDB cloqué - voir avec Kamel', array['plafond', 'douche', 'sdb', 'cloque', 'voir', 'kamel']::text[], 'TECHNIQUE', 1),
  ('Plainte rose coté lit SDB à recoller', array['plainte', 'rose', 'cote', 'lit', 'sdb', 'recoller']::text[], 'TECHNIQUE', 1),
  ('Plinthe bois chambre (Mur a gauche du lit) à recoller', array['plinthe', 'bois', 'chambre', 'mur', 'gauche', 'lit', 'recoller']::text[], 'TECHNIQUE', 1),
  ('Plinthe de la fenêtre à recoller', array['plinthe', 'fenetre', 'recoller']::text[], 'TECHNIQUE', 1),
  ('poignée porte principale à resserrer', array['poignee', 'porte', 'principale', 'resserrer']::text[], 'TECHNIQUE', 1),
  ('Pommeau de douche à changer', array['pommeau', 'douche', 'changer']::text[], 'TECHNIQUE', 1),
  ('Porte d''entrée qui grince', array['porte', 'entree', 'grince']::text[], 'TECHNIQUE', 1),
  ('Porte placard du haut à remettre / se trouve dans le local technique', array['porte', 'placard', 'haut', 'remettre', 'trouve', 'local', 'technique']::text[], 'TECHNIQUE', 1),
  ('problème de joint sur la paroi de douche car l''eau coule à travers -', array['probleme', 'joint', 'paroi', 'douche', 'car', 'eau', 'coule', 'travers']::text[], 'TECHNIQUE', 1),
  ('Rebranchement de la commande pour la tête de lit', array['rebranchement', 'commande', 'tete', 'lit']::text[], 'ELECTRIQUE', 1),
  ('Recoller la plinthe bois noire porte SDB côté SDB', array['recoller', 'plinthe', 'bois', 'noire', 'porte', 'sdb', 'cote']::text[], 'TECHNIQUE', 1),
  ('Refixer liseuse gauche', array['refixer', 'liseuse', 'gauche']::text[], 'TECHNIQUE', 1),
  ('remettre le joint noir porte coulissante SDB qui est decollé', array['remettre', 'joint', 'noir', 'porte', 'coulissante', 'sdb', 'decolle']::text[], 'TECHNIQUE', 1),
  ('Remettre le joint porte coulissante de la salle de bains', array['remettre', 'joint', 'porte', 'coulissante', 'salle', 'bains']::text[], 'TECHNIQUE', 1),
  ('Remettre le joint porte coulissante de la salle de bains - côté chambre', array['remettre', 'joint', 'porte', 'coulissante', 'salle', 'bains', 'cote', 'chambre']::text[], 'TECHNIQUE', 1),
  ('Remplacement de la bonde lavabo', array['remplacement', 'bonde', 'lavabo']::text[], 'TECHNIQUE', 1),
  ('Remplacement du télérupteur (SPOT)', array['remplacement', 'telerupteur', 'spot']::text[], 'ELECTRIQUE', 1),
  ('Remplacement du télérupteur (TETE DE LIT)', array['remplacement', 'telerupteur', 'tete', 'lit']::text[], 'ELECTRIQUE', 1),
  ('Remplacement du télérupteur (TETE DE LIT appliques)', array['remplacement', 'telerupteur', 'tete', 'lit', 'appliques']::text[], 'ELECTRIQUE', 1),
  ('Réparation de la poignée de porte du TGBT', array['reparation', 'poignee', 'porte', 'tgbt']::text[], 'TECHNIQUE', 1),
  ('réparation enduit mur blanc niveau lingerie + peinture Farid + baguettes plastiques larges et resistantes car les livreurs abîment les angles avec leurs charriots', array['reparation', 'enduit', 'mur', 'blanc', 'niveau', 'lingerie', 'peinture', 'farid']::text[], 'TECHNIQUE', 1),
  ('Réparer fissure cadre fenêtre chambre avec pâte à bois et repeindre', array['reparer', 'fissure', 'cadre', 'fenetre', 'chambre', 'pate', 'bois', 'repeindre']::text[], 'TECHNIQUE', 1),
  ('repeindre porte chambre côté extèrieur', array['repeindre', 'porte', 'chambre', 'cote', 'exterieur']::text[], 'TECHNIQUE', 1),
  ('reprendre peinture cause éclat mur dessous TV', array['reprendre', 'peinture', 'cause', 'eclat', 'mur', 'dessous']::text[], 'TECHNIQUE', 1),
  ('Resserer liseuse côté droit', array['resserer', 'liseuse', 'cote', 'droit']::text[], 'TECHNIQUE', 1),
  ('Resserer liseuse gauche', array['resserer', 'liseuse', 'gauche']::text[], 'TECHNIQUE', 1),
  ('Resserrer la poignée', array['resserrer', 'poignee']::text[], 'TECHNIQUE', 1),
  ('Resserrer la poignée de la porte d''entrée', array['resserrer', 'poignee', 'porte', 'entree']::text[], 'TECHNIQUE', 1),
  ('Robinet à changer + flexible', array['robinet', 'changer', 'flexible']::text[], 'TECHNIQUE', 1),
  ('Sèche serviette à refixer -', array['seche', 'serviette', 'refixer']::text[], 'TECHNIQUE', 1),
  ('Seche Serviette non fonctionnel', array['seche', 'serviette', 'non', 'fonctionnel']::text[], 'ELECTRIQUE', 1),
  ('sol parquet abîmé – mettre pate à bois', array['sol', 'parquet', 'abime', 'mettre', 'pate', 'bois']::text[], 'TECHNIQUE', 1),
  ('Sport à changer', array['sport', 'changer']::text[], 'TECHNIQUE', 1),
  ('Spot à changer (celui de droite)', array['spot', 'changer', 'celui', 'droite']::text[], 'ELECTRIQUE', 1),
  ('Spot à changer (celui du milieu) côté machine à café', array['spot', 'changer', 'celui', 'milieu', 'cote', 'machine', 'cafe']::text[], 'ELECTRIQUE', 1),
  ('spot à changer (celui en face de la fenêtre et a cote de l''enceinte Bose)', array['spot', 'changer', 'celui', 'face', 'fenetre', 'cote', 'enceinte', 'bose']::text[], 'ELECTRIQUE', 1),
  ('Spot à changer - côté du miroir', array['spot', 'changer', 'cote', 'miroir']::text[], 'TECHNIQUE', 1),
  ('spot à changer (le premier devant la porte d’entrée)', array['spot', 'changer', 'premier', 'devant', 'porte', 'entree']::text[], 'ELECTRIQUE', 1),
  ('Spot côté à changer à côté du miroir', array['spot', 'cote', 'changer', 'miroir']::text[], 'ELECTRIQUE', 1),
  ('Spot côté à changer derriere la réception', array['spot', 'cote', 'changer', 'derriere', 'reception']::text[], 'ELECTRIQUE', 1),
  ('Spot côté à changer devant la camera', array['spot', 'cote', 'changer', 'devant', 'camera']::text[], 'ELECTRIQUE', 1),
  ('Spot côté gauche du bar à changer', array['spot', 'cote', 'gauche', 'bar', 'changer']::text[], 'TECHNIQUE', 1),
  ('Spot dans la salle de bain', array['spot', 'salle', 'bain']::text[], 'TECHNIQUE', 1),
  ('spot dans le lobby devant la cuisine', array['spot', 'lobby', 'devant', 'cuisine']::text[], 'ELECTRIQUE', 1),
  ('Spot devant la chambre 34 à changer', array['spot', 'devant', 'chambre', 'changer']::text[], 'TECHNIQUE', 1),
  ('Spot du couloir a changer à coté de la chambre 18', array['spot', 'couloir', 'changer', 'cote', 'chambre']::text[], 'ELECTRIQUE', 1),
  ('Spot noir à changer - en face de la chambre 38', array['spot', 'noir', 'changer', 'face', 'chambre']::text[], 'TECHNIQUE', 1),
  ('Spot plafond au fond à changer', array['spot', 'plafond', 'fond', 'changer']::text[], 'ELECTRIQUE', 1),
  ('Spot plafond derrière la réception à changer', array['spot', 'plafond', 'derriere', 'reception', 'changer']::text[], 'ELECTRIQUE', 1),
  ('Spot plafond entrée HS', array['spot', 'plafond', 'entree']::text[], 'TECHNIQUE', 1),
  ('Spot plafond niveau armoire à changer', array['spot', 'plafond', 'niveau', 'armoire', 'changer']::text[], 'TECHNIQUE', 1),
  ('Spots salle de bain à changer', array['spots', 'salle', 'bain', 'changer']::text[], 'TECHNIQUE', 1),
  ('support de douche à viser', array['support', 'douche', 'viser']::text[], 'TECHNIQUE', 1),
  ('Support lait pour le corps à changer car cassé', array['support', 'lait', 'corps', 'changer', 'car', 'casse']::text[], 'TECHNIQUE', 1),
  ('Système carte pour lumière chambre cassé', array['systeme', 'carte', 'lumiere', 'chambre', 'casse']::text[], 'TECHNIQUE', 1),
  ('tablette miroir cassée pendant le remplacement + casse du grand miroir intèrieur placard', array['tablette', 'miroir', 'cassee', 'pendant', 'remplacement', 'casse', 'grand', 'interieur']::text[], 'TECHNIQUE', 1),
  ('Télérupteur à changer appliques', array['telerupteur', 'changer', 'appliques']::text[], 'ELECTRIQUE', 1),
  ('Télérupteur à changer lumière appliques murales saute', array['telerupteur', 'changer', 'lumiere', 'appliques', 'murales', 'saute']::text[], 'ELECTRIQUE', 1),
  ('Télérupteur appliques changé', array['telerupteur', 'appliques', 'change']::text[], 'TECHNIQUE', 1),
  ('Télérupteur spot et led à changer', array['telerupteur', 'spot', 'led', 'changer']::text[], 'ELECTRIQUE', 1),
  ('Toilettes bouchés', array['toilettes', 'bouches']::text[], 'TECHNIQUE', 1),
  ('trappe au plafond à refermer', array['trappe', 'plafond', 'refermer']::text[], 'ELECTRIQUE', 1),
  ('Un client suspecte la présence de punaises', array['client', 'suspecte', 'presence', 'punaises']::text[], 'TECHNIQUE', 1),
  ('URGENT - Difficulté à fermer la porte qui mene à la cour', array['urgent', 'difficulte', 'fermer', 'porte', 'mene', 'cour']::text[], 'TECHNIQUE', 1),
  ('URGENT - Joints sillicone douche - lavabo', array['urgent', 'joints', 'sillicone', 'douche', 'lavabo']::text[], 'TECHNIQUE', 1),
  ('URGENT - Joints sillicone douche - lavabo & WC', array['urgent', 'joints', 'sillicone', 'douche', 'lavabo']::text[], 'TECHNIQUE', 1),
  ('Vis du haut de la gâche à changer', array['vis', 'haut', 'gache', 'changer']::text[], 'TECHNIQUE', 1),
  ('Vis seche serviette à la reception', array['vis', 'seche', 'serviette', 'reception']::text[], 'TECHNIQUE', 1),
  ('Vis tombé de la douche à la reception - à la reception', array['vis', 'tombe', 'douche', 'reception']::text[], 'TECHNIQUE', 1),
  ('Visite contractuelle afin de vérifier si tout fonctionne correctement - Kone', array['visite', 'contractuelle', 'afin', 'verifier', 'tout', 'fonctionne', 'correctement', 'kone']::text[], 'TECHNIQUE', 1),
  ('Voilages dechirés', array['voilages', 'dechires']::text[], 'ACHATS', 1),
  ('voir comment rendre le boitier élec étanche en cas de nouvelle fuite', array['voir', 'comment', 'rendre', 'boitier', 'elec', 'etanche', 'cas', 'nouvelle']::text[], 'ELECTRIQUE', 1)
)
insert into catalogue_anomalies (libelle, mots_cles, type_id, occurrences)
select s.libelle, s.mots_cles, t.id, s.occurrences
from source s
left join types_intervention t on t.code = s.type_code
where not exists (
  select 1 from catalogue_anomalies c where c.libelle = s.libelle
);
