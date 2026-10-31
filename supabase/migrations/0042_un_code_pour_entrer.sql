-- -----------------------------------------------------------------------------
-- Un code pour entrer.
--
-- L'application était ouverte à quiconque connaissait son adresse : on arrivait
-- sur le choix du profil, on se disait Miguel, et l'on voyait les coûts, les
-- factures, l'export complet, le bouton qui modifie la base. Un code partagé par
-- l'équipe, demandé une fois par appareil, ferme la porte — avant le choix du
-- profil, qui reste « chacun dit qui il est ».
--
-- On ne garde que l'EMPREINTE du code (scrypt, avec son sel) : la table lue par
-- quelqu'un d'autre ne livre pas le code. `version` change à chaque nouveau
-- code, et avec elle la signature des appareils déjà entrés : changer le code,
-- c'est mettre tout le monde dehors — le geste qu'on veut quand quelqu'un quitte
-- l'hôtel. `secret` signe le jeton posé sur l'appareil ; il est tiré par
-- l'application à la première écriture, et ne quitte jamais le serveur.
--
-- Tant qu'aucun code n'est posé, l'application reste ouverte, comme avant :
-- poser la table ne doit enfermer personne dehors.
-- -----------------------------------------------------------------------------

create table if not exists acces_hotel (
  id               boolean primary key default true check (id),
  code_empreinte   text,
  secret           text,
  version          integer not null default 1,
  change_le        timestamptz,
  change_par       uuid references utilisateurs(id) on delete set null
);

insert into acces_hotel (id) values (true) on conflict (id) do nothing;

-- Les essais, pour qu'on ne puisse pas essayer tous les codes un par un. Un essai
-- est une ligne datée, réussi ou non, par adresse ; le calcul se fait à la
-- lecture, comme le reste (règle 1). Les lignes de plus d'un jour ne servent
-- plus à rien : l'application les efface au passage.
create table if not exists acces_essais (
  id     bigserial primary key,
  ip     text not null,
  le     timestamptz not null default now(),
  reussi boolean not null default false
);

create index if not exists acces_essais_par_ip on acces_essais (ip, le desc);

-- Personne ne lit ces tables par l'API publique de Supabase : RLS sans aucune
-- politique, seul le serveur de l'application y touche.
alter table acces_hotel enable row level security;
alter table acces_essais enable row level security;
