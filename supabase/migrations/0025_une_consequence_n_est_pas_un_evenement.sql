-- =============================================================================
-- Migration 0025 : une conséquence n'est pas un événement
-- =============================================================================
-- « Chambre bloquée », « remise en vente », « geste commercial » étaient des
-- TYPES D'ACTE, à côté de « détection canine » et « traitement à froid ». Or
-- ce ne sont pas des choses qui arrivent : ce sont des choses qu'on DÉCIDE
-- parce qu'autre chose est arrivé. « Ces options sont plus la conséquence que
-- des événements. »
--
-- Les mélanger coûtait deux fois :
--   — la chronologie se remplissait de lignes qui ne racontent rien. « Chambre
--     bloquée » seule ne dit pas pourquoi ; c'est le constat de la veille qui
--     le dit, et il est trois lignes plus haut.
--   — la liste « Quoi » comptait douze entrées dont trois qui ne répondaient
--     pas à la question posée.
--
-- Une conséquence pend donc à son acte : elle porte les lieux qu'elle touche
-- (une chambre se bloque, pas un dossier) et, pour un geste commercial, son
-- montant. Elle n'a pas de date propre — c'est celle du fait qui l'a causée,
-- et c'est exactement ce qu'on veut lire : « le 04/11, constat client, et la
-- chambre a été bloquée ».
--
-- Ce qui ne change pas : aucune machine à états (règle 18bis). Une conséquence
-- ne « ferme » rien, ne débloque rien, n'impose aucune suite. On enregistre ce
-- qui a été décidé.

create table if not exists types_consequence (
  id              uuid primary key default gen_random_uuid(),
  nature_code     text not null references natures_suivi (code),
  code            text not null,
  libelle         text not null,
  -- Une chambre se bloque ; un geste commercial va au client, pas à une porte.
  porte_sur_lieux boolean not null default true,
  porte_montant   boolean not null default false,
  ordre           int not null default 0,
  unique (nature_code, code)
);

insert into types_consequence
  (nature_code, code, libelle, porte_sur_lieux, porte_montant, ordre) values
  ('punaises','chambre_bloquee', 'Chambre bloquée',   true,  false, 1),
  ('punaises','remise_en_vente', 'Remise en vente',   true,  false, 2),
  ('punaises','geste_commercial','Geste commercial',  false, true,  3),
  ('punaises','client_deloge',   'Client relogé',     true,  false, 4)
on conflict (nature_code, code) do nothing;

create table if not exists consequences_acte (
  id                  uuid primary key default gen_random_uuid(),
  acte_id             uuid not null references actes (id) on delete cascade,
  type_consequence_id uuid not null references types_consequence (id),
  -- Nul quand la conséquence ne porte pas sur un lieu (un geste commercial).
  emplacement_id      uuid references emplacements (id),
  montant_ht          numeric(10,2) check (montant_ht >= 0),
  commentaire         text
);

-- Deux fois la même conséquence au même endroit sur le même acte n'a pas de
-- sens. `null` étant distinct de `null` pour un index ordinaire, il en faut
-- deux : un pour ce qui porte un lieu, un pour ce qui n'en porte pas.
create unique index if not exists consequence_unique_par_lieu
  on consequences_acte (acte_id, type_consequence_id, emplacement_id)
  where emplacement_id is not null;
create unique index if not exists consequence_unique_sans_lieu
  on consequences_acte (acte_id, type_consequence_id)
  where emplacement_id is null;
create index if not exists consequences_acte_acte on consequences_acte (acte_id);

comment on table consequences_acte is
  'Ce qui a été DÉCIDÉ parce qu''un acte a eu lieu : une chambre bloquée, une '
  'remise en vente, un geste commercial. Pas de date propre — celle de l''acte '
  'qui l''a causée. Ne ferme rien et n''impose aucune suite (règle 18bis).';

-- Les trois types d'acte qui n'en étaient pas s'en vont — mais seulement si
-- personne ne s'en est servi. Effacer un acte existant serait perdre un fait
-- pour corriger un rangement : on préfère laisser le doublon visible.
delete from types_acte t
 where t.nature_code = 'punaises'
   and t.code in ('chambre_bloquee','remise_en_service','geste_commercial')
   and not exists (select 1 from actes a where a.type_acte_id = t.id);

-- ------------------------------------------------------------------ sécurité
alter table types_consequence  enable row level security;
alter table consequences_acte  enable row level security;

do $$
declare t text;
begin
  foreach t in array array['types_consequence','consequences_acte'] loop
    execute format('drop policy if exists lecture_connectes on %I', t);
    execute format(
      'create policy lecture_connectes on %I for select to authenticated using (fn_est_connecte())', t);
    execute format('drop policy if exists ecriture_encadrement on %I', t);
    execute format(
      'create policy ecriture_encadrement on %I for all to authenticated
         using (fn_peut_valider()) with check (fn_peut_valider())', t);
    execute format('grant select on %I to authenticated', t);
    execute format('grant insert, update, delete on %I to authenticated', t);
  end loop;
end $$;

-- Le montant d'un geste commercial est de l'argent sorti : il compte dans ce
-- que l'épisode a coûté, au même titre qu'une facture de traitement.
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
         where a.suivi_id = s.id and not a.gratuit)
       + (select coalesce(sum(c.montant_ht), 0)
            from consequences_acte c
            join actes a on a.id = c.acte_id
           where a.suivi_id = s.id)                                  as montant,
       case when s.parent_id is null then 0 else
         (select count(*) from v_suivi_lieux v
           where v.suivi_id = s.id and not v.regle) end::int         as nb_non_regles,
       case when s.parent_id is null then 0 else
         (select count(*) from v_suivi_lieux v
           where v.suivi_id = s.id and v.a_controler) end::int       as nb_a_controler,
       (select max(a.date_acte)
          from actes a
          join types_acte t on t.id = a.type_acte_id
          join suivis s2 on s2.id = a.suivi_id
         where t.est_verification and s2.nature_code = s.nature_code) as derniere_verification_nature
  from suivis s
  join natures_suivi n on n.code = s.nature_code;

grant select on v_suivis to authenticated;
