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
