-- =============================================================================
-- Migration 0023 : suivre une histoire — suivi, portée, acte
-- =============================================================================
-- Certaines anomalies ne sont pas des anomalies : ce sont des histoires. Les
-- punaises de lit en sont l'exemple net — un client se plaint, on vérifie, une
-- société passe avec des chiens, on traite, on revérifie, et le schéma
-- recommence jusqu'à ce que ce soit réglé. Ça traverse des chambres et des
-- semaines.
--
-- Mesuré sur l'export de l'hôtel : l'histoire complète tient en QUATORZE actes
-- sur vingt-sept mois, et UN SEUL est correctement en base. Deux sont dans
-- l'export jamais importé, quatre ne sont que des phrases dans un commentaire,
-- et cinq n'existent que sur des notes de facture — dont celui qui clôt
-- l'histoire. L'application savait que le problème avait commencé et ignorait
-- qu'il était résolu.
--
-- Trois objets, et pas un de plus :
--
--   le SUIVI    une histoire. Permanent (il ne se clôt jamais, il a un rythme)
--               ou épisode (il s'ouvre et se ferme), rattaché au permanent.
--   la PORTÉE   les lieux concernés, avec la date d'entrée : on s'élargit en
--               cours de route, et il faut savoir quand.
--   l'ACTE      l'unité de la chronologie. Une ligne = un fait daté, avec sa
--               propre portée et UN RÉSULTAT PAR LIEU — c'est ce qui permet à
--               un balayage de 38 chambres d'être UNE ligne et non 38.
--
-- Ce qu'on ne fait pas : aucune machine à états. L'ordre des traitements varie
-- (chimique puis froid, l'inverse, ou les deux), une contre-visite peut
-- s'ajouter, une chambre voisine peut entrer. On enregistre ce qui a eu lieu ;
-- on ne dicte jamais la suite. L'état se CALCULE (règle 1).

-- ----------------------------------------------------------------- les types
do $$ begin
  create type resultat_verification as enum ('positif', 'negatif', 'non_concluant');
exception when duplicate_object then null; end $$;

do $$ begin
  create type declencheur_suivi as enum
    ('client', 'prevention', 'personnel', 'reglementaire', 'autre');
exception when duplicate_object then null; end $$;

-- --------------------------------------------------------------- les natures
-- Ce qu'on suit. Pour l'instant : les punaises. La table existe pour que
-- l'ascenseur, les rongeurs ou le désenfumage s'ajoutent sans migration.
create table if not exists natures_suivi (
  code              text primary key,
  libelle           text not null,
  -- Le rythme attendu, quand il y en a un. Sert à dire « la campagne est en
  -- retard » : 354 jours entre les deux balayages de l'hôtel.
  periodicite_jours int,
  actif             boolean not null default true,
  ordre             int not null default 0
);

insert into natures_suivi (code, libelle, periodicite_jours, ordre) values
  ('punaises', 'Punaises de lit', 365, 1)
on conflict (code) do nothing;

-- ---------------------------------------------------------------- les suivis
create table if not exists suivis (
  id          uuid primary key default gen_random_uuid(),
  nature_code text not null references natures_suivi (code),
  -- Un épisode appartient au dossier permanent de sa nature. Le permanent n'a
  -- pas de parent, et ne se clôt jamais : les épisodes se ferment, la
  -- surveillance continue.
  parent_id   uuid references suivis (id) on delete cascade,
  titre       text not null,
  declencheur declencheur_suivi,
  ouvert_le   date not null default current_date,
  clos_le     date,
  commentaire text,
  cree_par    uuid references utilisateurs (id),
  cree_le     timestamptz not null default now(),
  -- Une clé naturelle, pour que la reprise de l'historique soit rejouable.
  reference   text unique,
  constraint le_permanent_ne_se_clot_pas
    check (parent_id is not null or clos_le is null)
);
create index if not exists suivis_nature on suivis (nature_code, ouvert_le desc);
create index if not exists suivis_parent on suivis (parent_id);

comment on table suivis is
  'Une histoire : un dossier permanent (sans parent, jamais clos) ou un '
  'épisode qui s''ouvre et se ferme dedans.';

-- ---------------------------------------------------------------- la portée
create table if not exists suivi_lieux (
  suivi_id       uuid not null references suivis (id) on delete cascade,
  emplacement_id uuid not null references emplacements (id),
  -- Quand ce lieu est entré dans la surveillance, et pourquoi. Sans la date,
  -- on ne sait plus quand on s'est élargi aux chambres voisines.
  entre_le       date not null default current_date,
  motif          text,
  primary key (suivi_id, emplacement_id)
);

-- ------------------------------------------------------------ les actes, typés
create table if not exists types_acte (
  id               uuid primary key default gen_random_uuid(),
  nature_code      text not null references natures_suivi (code),
  code             text not null,
  libelle          text not null,
  -- Les deux seuls drapeaux dont la règle de clôture a besoin. Pas d'ordre
  -- imposé, pas de transition : juste « ceci vérifie » et « ceci traite ».
  est_verification boolean not null default false,
  est_traitement   boolean not null default false,
  -- Un acte qui porte sur des lieux (un balayage) vs un acte administratif
  -- (un devis, un geste commercial) qui n'en porte pas.
  porte_sur_lieux  boolean not null default true,
  ordre            int not null default 0,
  unique (nature_code, code)
);

insert into types_acte (nature_code, code, libelle, est_verification, est_traitement, porte_sur_lieux, ordre) values
  ('punaises','constat_client',      'Un client signale',                    false,false,true, 1),
  ('punaises','constat_personnel',   'Constat du personnel',                 false,false,true, 2),
  ('punaises','verification_interne','Vérification à l''œil nu',             true, false,true, 3),
  ('punaises','detection_canine',    'Détection canine',                     true, false,true, 4),
  ('punaises','traitement_chimique', 'Traitement chimique',                  false,true, true, 5),
  ('punaises','traitement_froid',    'Traitement à froid',                   false,true, true, 6),
  ('punaises','traitement_autre',    'Traitement (autre)',                   false,true, true, 7),
  ('punaises','devis',               'Devis reçu ou validé',                 false,false,false,8),
  ('punaises','chambre_bloquee',     'Chambre bloquée',                      false,false,true, 9),
  ('punaises','remise_en_service',   'Remise en service',                    false,false,true, 10),
  ('punaises','geste_commercial',    'Geste commercial au client',           false,false,true, 11),
  ('punaises','note',                'Note',                                 false,false,false,12)
on conflict (nature_code, code) do nothing;

create table if not exists actes (
  id              uuid primary key default gen_random_uuid(),
  suivi_id        uuid not null references suivis (id) on delete cascade,
  type_acte_id    uuid not null references types_acte (id),
  -- La date du GESTE, jamais celle de la saisie. On reprend de l'historique.
  date_acte       date not null,
  -- Qui : un salarié OU une entreprise. EcoFlair détecte, Stop Nuisible
  -- traite — ne jamais supposer que l'intervenant est de l'un ou l'autre.
  utilisateur_id  uuid references utilisateurs (id),
  prestataire_id  uuid references prestataires (id),
  commentaire     text,
  -- Ce que la pièce annonce. Ce n'est pas la comptabilité : c'est de quoi
  -- dire ce qu'un épisode a coûté, en attendant mieux.
  montant_ht      numeric(10,2) check (montant_ht >= 0),
  -- Le 26/11/2025, EcoFlair a OFFERT la vérification. L'inverse existe aussi :
  -- une société sous contrat qui facture un passage ponctuel.
  gratuit         boolean not null default false,
  hors_contrat    boolean not null default false,
  -- Quand l'acte correspond à un passage déjà enregistré, on pointe dessus :
  -- le matériel, le coût et la facture restent où ils sont.
  intervention_id uuid references interventions (id) on delete set null,
  saisie_par      uuid references utilisateurs (id),
  cree_le         timestamptz not null default now()
);
create index if not exists actes_suivi on actes (suivi_id, date_acte);

comment on table actes is
  'L''unité de la chronologie : un fait daté. L''ordre n''est jamais imposé — '
  'chimique puis froid, l''inverse, ou les deux : ce sont trois actes.';

create table if not exists acte_lieux (
  acte_id        uuid not null references actes (id) on delete cascade,
  emplacement_id uuid not null references emplacements (id),
  -- Renseigné pour les actes de vérification. « Vérifiée, rien trouvé » et
  -- « pas vérifiée » ne sont pas la même chose : c'est tout l'intérêt.
  resultat       resultat_verification,
  primary key (acte_id, emplacement_id)
);

-- ------------------------------------------------------------- les documents
create table if not exists pieces_suivi (
  id           uuid primary key default gen_random_uuid(),
  suivi_id     uuid not null references suivis (id) on delete cascade,
  acte_id      uuid references actes (id) on delete cascade,
  chemin       text not null,
  nom          text,
  nature_piece text not null default 'facture',
  ajoute_le    timestamptz not null default now(),
  ajoute_par   uuid references utilisateurs (id)
);
create index if not exists pieces_suivi_suivi on pieces_suivi (suivi_id, ajoute_le desc);

-- =============================================================================
-- L'état se CALCULE. Rien n'est stocké (règle 1).
-- =============================================================================
-- La règle, et elle suffit à décrire toute la boucle sans jamais l'imposer :
--
--   Un lieu est RÉGLÉ quand il existe, pour lui, une vérification NÉGATIVE
--   postérieure à tous ses traitements et à toute vérification positive.
--
-- Il est À CONTRÔLER quand il a été traité et qu'aucune vérification n'a eu
-- lieu depuis : c'est l'état qui manquait, celui qui dit « rappelez la
-- société ». Sinon il est EN COURS.

create or replace view v_suivi_lieux_etat as
with faits as (
  select a.suivi_id, al.emplacement_id, a.date_acte,
         t.est_verification, t.est_traitement, al.resultat
    from actes a
    join acte_lieux al on al.acte_id = a.id
    join types_acte t  on t.id = a.type_acte_id
)
select sl.suivi_id,
       sl.emplacement_id,
       e.code                                                      as emplacement,
       sl.entre_le,
       max(f.date_acte) filter (where f.est_traitement)             as dernier_traitement,
       -- Une vérification NON CONCLUANTE ne conclut rien : elle ne compte pas
       -- comme « on a revérifié ». La contre-visite du 05/11/2024 est
       -- exactement ce cas — elle a eu lieu, son résultat n'a jamais été écrit,
       -- et les chambres restent donc à contrôler.
       max(f.date_acte) filter (where f.est_verification
                                  and f.resultat in ('positif','negatif'))
                                                                    as derniere_verification,
       max(f.date_acte) filter (where f.est_verification
                                  and f.resultat = 'negatif')       as derniere_negative,
       max(f.date_acte) filter (where f.est_verification
                                  and f.resultat = 'positif')       as derniere_positive,
       count(*) filter (where f.est_traitement)::int                as nb_traitements,
       count(*) filter (where f.est_verification)::int              as nb_verifications
  from suivi_lieux sl
  join emplacements e on e.id = sl.emplacement_id
  left join faits f on f.suivi_id = sl.suivi_id
                   and f.emplacement_id = sl.emplacement_id
 group by sl.suivi_id, sl.emplacement_id, e.code, sl.entre_le;

create or replace view v_suivi_lieux as
select x.*,
       (x.derniere_negative is not null
        and x.derniere_negative >= coalesce(x.dernier_traitement, date '0001-01-01')
        and x.derniere_negative >= coalesce(x.derniere_positive,  date '0001-01-01'))
         as regle,
       (x.dernier_traitement is not null
        and (x.derniere_verification is null
             or x.derniere_verification < x.dernier_traitement))
         as a_controler
  from v_suivi_lieux_etat x;

create or replace view v_suivis as
select s.id, s.nature_code, n.libelle as nature, s.parent_id, s.titre,
       s.declencheur::text, s.ouvert_le, s.clos_le, s.commentaire, s.reference,
       s.parent_id is null                                          as permanent,
       n.periodicite_jours,
       (select count(*) from suivis f where f.parent_id = s.id)::int as nb_episodes,
       (select count(*) from actes a where a.suivi_id = s.id)::int   as nb_actes,
       (select count(*) from suivi_lieux l where l.suivi_id = s.id)::int as nb_lieux,
       (select count(*) from pieces_suivi p where p.suivi_id = s.id)::int as nb_pieces,
       (select min(a.date_acte) from actes a where a.suivi_id = s.id) as premier_acte,
       (select max(a.date_acte) from actes a where a.suivi_id = s.id) as dernier_acte,
       (select coalesce(sum(a.montant_ht), 0) from actes a
         where a.suivi_id = s.id and not a.gratuit)                  as montant,
       -- Un dossier permanent ne se « règle » pas : il porte le périmètre
       -- surveillé, pas un problème à résoudre. Seuls les épisodes ont un état.
       case when s.parent_id is null then 0 else
         (select count(*) from v_suivi_lieux v
           where v.suivi_id = s.id and not v.regle) end::int         as nb_non_regles,
       case when s.parent_id is null then 0 else
         (select count(*) from v_suivi_lieux v
           where v.suivi_id = s.id and v.a_controler) end::int       as nb_a_controler,
       -- La dernière vérification de la nature, tous suivis confondus : c'est
       -- elle qui dit si la campagne est en retard.
       (select max(a.date_acte)
          from actes a
          join types_acte t on t.id = a.type_acte_id
          join suivis s2 on s2.id = a.suivi_id
         where t.est_verification and s2.nature_code = s.nature_code) as derniere_verification_nature
  from suivis s
  join natures_suivi n on n.code = s.nature_code;

-- ------------------------------------------------------------------ sécurité
alter table natures_suivi enable row level security;
alter table suivis        enable row level security;
alter table suivi_lieux   enable row level security;
alter table types_acte    enable row level security;
alter table actes         enable row level security;
alter table acte_lieux    enable row level security;
alter table pieces_suivi  enable row level security;

do $$
declare t text;
begin
  foreach t in array array['natures_suivi','suivis','suivi_lieux','types_acte',
                           'actes','acte_lieux','pieces_suivi'] loop
    execute format('drop policy if exists lecture_connectes on %I', t);
    execute format(
      'create policy lecture_connectes on %I for select to authenticated using (fn_est_connecte())', t);
    execute format('drop policy if exists ecriture_encadrement on %I', t);
    -- Ouvrir une histoire et y poser des actes est une décision d'encadrement
    -- (règle 10ter) : Victoria, Sarah P, Miguel.
    execute format(
      'create policy ecriture_encadrement on %I for all to authenticated
         using (fn_peut_valider()) with check (fn_peut_valider())', t);
    execute format('grant select on %I to authenticated', t);
    execute format('grant insert, update, delete on %I to authenticated', t);
  end loop;
end $$;

grant select on v_suivis, v_suivi_lieux, v_suivi_lieux_etat to authenticated;

-- =============================================================================
-- La reprise : les deux épisodes de punaises, tels que les sources les disent
-- =============================================================================
-- Reconstitués depuis l'export « TEST Tech 3 », les phrases datées de ses
-- commentaires, et les notes de facture de l'hôtel. Rejouable : la clé est
-- `suivis.reference`, et le bloc entier ne fait rien si elle existe déjà.
--
-- Deux résultats restent INCONNUS et sont enregistrés comme tels
-- (`non_concluant`) : la contre-visite du 05/11/2024 et la vérification
-- offerte du 26/11/2025. Aucune date n'est inventée — le deuxième passage de
-- Rachid d'octobre 2025, dont l'existence est certaine mais la date nulle
-- part, est dit dans un commentaire et non posé sur un jour au hasard.

do $$
declare
  v_permanent uuid; v_e1 uuid; v_e2 uuid; v_acte uuid;
  v_victoria uuid; v_sarah uuid; v_rachid uuid; v_ecoflair uuid;
  -- Les 38 lieux du balayage du 11/10/2024, les 4 positifs d'abord.
  c2024_pos text[] := array['15','28','46','48'];
  c2024_neg text[] := array['01','02','03','11','12','14','16','18','21','22','24','25',
                            '26','27','31','32','34','35','36','37','38','41','42','44',
                            '45','47','51','52','54','55','56','57','58','Parties communes'];
  c2025_pos text[] := array['54'];
  c2025_neg text[] := array['01','02','03','11','12','14','15','16','18','21','22','24',
                            '25','26','27','28','31','32','34','35','36','37','38','41',
                            '42','44','45','46','47','48','51','52','55','56','57','58'];
begin
  if exists (select 1 from suivis where reference = 'PUNAISES') then return; end if;

  select id into v_victoria from utilisateurs where nom ilike 'victoria' limit 1;
  select id into v_sarah    from utilisateurs where nom ilike 'sarah%'   limit 1;
  select id into v_rachid   from utilisateurs where nom ilike 'rachid'   limit 1;
  select id into v_ecoflair from prestataires where nom ilike 'ecoflair' limit 1;

  -- ----------------------------------------------------- le dossier permanent
  insert into suivis (nature_code, titre, ouvert_le, reference, commentaire)
  values ('punaises', 'Punaises de lit', date '2024-09-20', 'PUNAISES',
          'Dossier permanent. Les épisodes se ferment ; la surveillance continue. '
          || 'Le Lobby fait partie du périmètre vérifié.')
  returning id into v_permanent;

  -- Le périmètre surveillé : tout ce qui a déjà été balayé, plus le Lobby.
  insert into suivi_lieux (suivi_id, emplacement_id, entre_le, motif)
  select v_permanent, e.id, date '2024-10-11', 'périmètre des campagnes'
    from emplacements e
   where e.code = any (c2024_pos || c2024_neg) or e.code in ('Lobby')
  on conflict do nothing;

  -- ============================== ÉPISODE 2024 ==============================
  insert into suivis (nature_code, parent_id, titre, declencheur, ouvert_le, reference, commentaire)
  values ('punaises', v_permanent, 'Automne 2024 — chambres 15, 28, 46, 48',
          'client', date '2024-09-20', 'PUNAISES-2024',
          'La contre-visite du 05/11/2024 n''a jamais eu de résultat écrit. '
          || 'Le balayage du 30/09/2025 a retrouvé les quatre chambres négatives.')
  returning id into v_e1;

  insert into suivi_lieux (suivi_id, emplacement_id, entre_le, motif)
  select v_e1, e.id, date '2024-09-20', 'un client se plaint'
    from emplacements e where e.code = '46';
  insert into suivi_lieux (suivi_id, emplacement_id, entre_le, motif)
  select v_e1, e.id, date '2024-10-11', 'détection canine positive'
    from emplacements e where e.code = any (array['15','28','48'])
  on conflict do nothing;

  -- 20/09/2024 — un client signale
  insert into actes (suivi_id, type_acte_id, date_acte, utilisateur_id, commentaire)
  select v_e1, t.id, date '2024-09-20', v_sarah,
         'Un client suspecte la présence de punaises. Constaté par Sarah P.'
    from types_acte t where t.nature_code='punaises' and t.code='constat_client'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id)
  select v_acte, e.id from emplacements e where e.code = '46';

  -- 20/09/2024 — vérification à l'œil nu : rien
  insert into actes (suivi_id, type_acte_id, date_acte, utilisateur_id, commentaire)
  select v_e1, t.id, date '2024-09-20', v_victoria,
         'Après vérification à l''œil nu par Victoria, aucune trace de punaises.'
    from types_acte t where t.nature_code='punaises' and t.code='verification_interne'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id, resultat)
  select v_acte, e.id, 'negatif' from emplacements e where e.code = '46';

  -- 11/10/2024 — détection canine, 38 chambres, 4 positives
  insert into actes (suivi_id, type_acte_id, date_acte, prestataire_id, commentaire)
  select v_e1, t.id, date '2024-10-11', v_ecoflair,
         'Campagne de détection par chiens renifleurs. 38 lieux vérifiés, '
         || '4 positifs à la tête de lit — dont la 46, celle du client, trois '
         || 'semaines après une vérification à l''œil nu négative.'
    from types_acte t where t.nature_code='punaises' and t.code='detection_canine'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id, resultat)
  select v_acte, e.id, 'positif' from emplacements e where e.code = any (c2024_pos);
  insert into acte_lieux (acte_id, emplacement_id, resultat)
  select v_acte, e.id, 'negatif' from emplacements e where e.code = any (c2024_neg)
  on conflict do nothing;

  -- 12/10/2024 — traitement chimique
  insert into actes (suivi_id, type_acte_id, date_acte, utilisateur_id, commentaire)
  select v_e1, t.id, date '2024-10-12', v_rachid, 'Premier passage.'
    from types_acte t where t.nature_code='punaises' and t.code='traitement_chimique'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id)
  select v_acte, e.id from emplacements e where e.code = any (c2024_pos);

  -- 21/10/2024 — traitement à froid
  insert into actes (suivi_id, type_acte_id, date_acte, utilisateur_id, commentaire)
  select v_e1, t.id, date '2024-10-21', v_rachid,
         'Deuxième passage : cette fois un traitement à froid.'
    from types_acte t where t.nature_code='punaises' and t.code='traitement_froid'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id)
  select v_acte, e.id from emplacements e where e.code = any (c2024_pos);

  -- 05/11/2024 — contre-visite, résultat jamais écrit
  insert into actes (suivi_id, type_acte_id, date_acte, prestataire_id, commentaire)
  select v_e1, t.id, date '2024-11-05', v_ecoflair,
         'Demande de vérification pour voir si le traitement chimique et le '
         || 'traitement à froid ont fonctionné. LE RÉSULTAT N''A JAMAIS ÉTÉ ÉCRIT.'
    from types_acte t where t.nature_code='punaises' and t.code='detection_canine'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id, resultat)
  select v_acte, e.id, 'non_concluant' from emplacements e where e.code = any (c2024_pos);

  -- ============================== ÉPISODE 2025 ==============================
  insert into suivis (nature_code, parent_id, titre, declencheur, ouvert_le, clos_le,
                      reference, commentaire)
  values ('punaises', v_permanent, 'Automne 2025 — chambre 54', 'prevention',
          date '2025-09-30', date '2025-12-15', 'PUNAISES-2025',
          'Quatre traitements, quatre vérifications, 76 jours. Réglé le 15/12/2025.')
  returning id into v_e2;

  insert into suivi_lieux (suivi_id, emplacement_id, entre_le, motif)
  select v_e2, e.id, date '2025-09-30', 'détection canine positive'
    from emplacements e where e.code = '54';

  -- 30/09/2025 — détection canine, 37 chambres, 1 positive
  insert into actes (suivi_id, type_acte_id, date_acte, prestataire_id, commentaire)
  select v_e2, t.id, date '2025-09-30', v_ecoflair,
         'Campagne de détection par chiens renifleurs. 37 lieux vérifiés, '
         || 'punaises constatées à la tête de lit en chambre 54.'
    from types_acte t where t.nature_code='punaises' and t.code='detection_canine'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id, resultat)
  select v_acte, e.id, 'positif' from emplacements e where e.code = any (c2025_pos);
  insert into acte_lieux (acte_id, emplacement_id, resultat)
  select v_acte, e.id, 'negatif' from emplacements e where e.code = any (c2025_neg)
  on conflict do nothing;

  -- 01/10/2025 — premier traitement
  insert into actes (suivi_id, type_acte_id, date_acte, utilisateur_id, commentaire)
  select v_e2, t.id, date '2025-10-01', v_rachid,
         'Premier passage de Rachid (Stop Nuisible).'
    from types_acte t where t.nature_code='punaises' and t.code='traitement_autre'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id)
  select v_acte, e.id from emplacements e where e.code = '54';

  -- 04/11/2025 — vérification : toujours infestée
  insert into actes (suivi_id, type_acte_id, date_acte, prestataire_id, commentaire)
  select v_e2, t.id, date '2025-11-04', v_ecoflair,
         'Vérification après les DEUX passages de Rachid — le second a bien eu '
         || 'lieu en octobre, mais sa date n''est écrite nulle part et n''a pas '
         || 'été inventée. Les punaises sont toujours présentes en chambre 54.'
    from types_acte t where t.nature_code='punaises' and t.code='detection_canine'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id, resultat)
  select v_acte, e.id, 'positif' from emplacements e where e.code = '54';

  -- 06/11/2025 — nouveau traitement
  insert into actes (suivi_id, type_acte_id, date_acte, utilisateur_id, commentaire)
  select v_e2, t.id, date '2025-11-06', v_rachid, 'Rachid intervient de nouveau.'
    from types_acte t where t.nature_code='punaises' and t.code='traitement_autre'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id)
  select v_acte, e.id from emplacements e where e.code = '54';

  -- 26/11/2025 — vérification OFFERTE, résultat non écrit
  insert into actes (suivi_id, type_acte_id, date_acte, prestataire_id, gratuit, commentaire)
  select v_e2, t.id, date '2025-11-26', v_ecoflair, true,
         'Vérification offerte par EcoFlair. Le résultat n''est pas écrit — '
         || 'un traitement a suivi le 04/12, la présence était donc probablement '
         || 'confirmée.'
    from types_acte t where t.nature_code='punaises' and t.code='detection_canine'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id, resultat)
  select v_acte, e.id, 'non_concluant' from emplacements e where e.code = '54';

  -- 04/12/2025 — celui qui a fonctionné
  insert into actes (suivi_id, type_acte_id, date_acte, utilisateur_id, commentaire)
  select v_e2, t.id, date '2025-12-04', v_rachid,
         'Devis validé par Sarah P. Intervention de Rachid (Stop Nuisible) : la '
         || 'toile de lit a été retirée, puis un traitement à froid appliqué.'
    from types_acte t where t.nature_code='punaises' and t.code='traitement_froid'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id)
  select v_acte, e.id from emplacements e where e.code = '54';

  -- 15/12/2025 — plus de punaises
  insert into actes (suivi_id, type_acte_id, date_acte, prestataire_id, commentaire)
  select v_e2, t.id, date '2025-12-15', v_ecoflair,
         'Après vérification, la chambre 54 n''est plus infestée.'
    from types_acte t where t.nature_code='punaises' and t.code='detection_canine'
  returning id into v_acte;
  insert into acte_lieux (acte_id, emplacement_id, resultat)
  select v_acte, e.id, 'negatif' from emplacements e where e.code = '54';
end $$;
