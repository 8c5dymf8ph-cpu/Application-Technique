-- =============================================================================
-- Migration 0036 : supprimer un passage entier défait son travail, sans
-- toucher aux anomalies elles-mêmes
-- =============================================================================
-- « Je souhaite pouvoir supprimer un passage définitivement. Les anomalies
-- restent, mais tout ce que ce passage a fait est défait. »
--
-- Différent de la suppression d'une anomalie (migrations 0021/0022) : là, la
-- ligne elle-même disparaît. Ici, c'est l'inverse — on efface un PASSAGE saisi
-- de travers (mauvais intervenant, doublon de saisie historique), et les
-- anomalies qu'il portait doivent redevenir ce qu'elles étaient avant lui :
-- `a_faire`, comme si ce passage n'avait jamais eu lieu.
--
-- `interventions.tournee_id` se détache seul à la suppression d'une tournée
-- (`on delete set null`, posé dès la 0001) : il faut donc explicitement
-- supprimer les interventions pour que leurs avis et leurs sorties de stock
-- partent avec elles — la cascade de la 0022 fait le reste, le matériel
-- revient en réserve exactement comme pour une anomalie supprimée.
--
-- Réservé à Sarah P et Miguel (`suitLesDossiers`, operations+admin) : un
-- passage mal saisi est une correction d'encadrement sur de l'historique, pas
-- un geste de terrain — le même cercle que corriger la date d'un passage ou
-- supprimer une facture. Plus étroit que la suppression d'une anomalie
-- (qui inclut la gouvernante) : la table porte déjà une politique large
-- (`ecriture_operationnelle`, ouverte à tout technicien pour que décocher sa
-- propre déclaration continue de fonctionner) — une politique RESTRICTIVE est
-- donc nécessaire ici, les politiques permissives s'additionnant entre elles.

create table if not exists tournees_supprimees (
  id                uuid primary key,
  reference         text,
  date_tournee      date,
  intervenant       text,
  nb_interventions  int not null default 0,
  nb_mouvements     int not null default 0,
  -- Les anomalies que ce passage touchait : ELLES RESTENT en base, intactes.
  -- Ce tableau dit lesquelles, pour pouvoir les retrouver — la suppression
  -- d'un passage n'efface pas la mémoire de ce qu'il concernait.
  anomalies         jsonb not null default '[]'::jsonb,
  supprimee_le      timestamptz not null default now(),
  supprimee_par     uuid references utilisateurs (id)
);

create index if not exists tournees_supprimees_date
  on tournees_supprimees (supprimee_le desc);

comment on table tournees_supprimees is
  'Un passage supprimé, et ce qu''il touchait. Les anomalies listées ici '
  'restent dans la table anomalies, remises à a_faire : seul le passage a '
  'disparu, pas le travail à refaire.';

create or replace function fn_journal_suppression_tournee() returns trigger
language plpgsql as $$
begin
  -- Compté et listé AVANT toute suppression : le déclencheur est `before
  -- delete`, et rien n'a encore bougé sous les interventions de ce passage.
  insert into tournees_supprimees (
    id, reference, date_tournee, intervenant, nb_interventions, nb_mouvements,
    anomalies, supprimee_par)
  select
    old.id, old.reference, old.date_tournee, coalesce(u.nom, p.nom),
    (select count(*) from interventions i where i.tournee_id = old.id),
    (select count(*) from mouvements_stock m
       join interventions i on i.id = m.intervention_id
      where i.tournee_id = old.id),
    (select coalesce(jsonb_agg(jsonb_build_object(
               'id', a.id, 'reference', a.reference, 'description', a.description)), '[]'::jsonb)
       from interventions i join anomalies a on a.id = i.anomalie_id
      where i.tournee_id = old.id),
    (select x.id from utilisateurs x where x.auth_id = auth.uid())
  from (select 1) z
  left join utilisateurs u  on u.id = old.technicien_id
  left join prestataires p  on p.id = old.prestataire_id
  on conflict (id) do nothing;

  -- Les anomalies restent, mais sans intervention pour les porter, leur
  -- statut retombe à a_faire — exactement l'état d'avant ce passage. Une
  -- anomalie annulée ailleurs ne doit pas être ranimée par ce geste.
  update anomalies a set statut = 'a_faire', maj_le = now()
    from interventions i
   where i.tournee_id = old.id and i.anomalie_id = a.id and a.statut <> 'annulee';

  -- Supprime explicitement ce qui ne se détacherait pas tout seul : la
  -- cascade de la 0022 (mouvements_stock), celle déjà posée sur validations
  -- et facture_interventions font ensuite tout le reste.
  delete from interventions where tournee_id = old.id;

  return old;
end;
$$;

drop trigger if exists tg_journal_suppression_tournee on tournees;
create trigger tg_journal_suppression_tournee
before delete on tournees
for each row execute function fn_journal_suppression_tournee();

alter table tournees_supprimees enable row level security;
drop policy if exists lecture_suppressions_tournee on tournees_supprimees;
create policy lecture_suppressions_tournee on tournees_supprimees
  for select to authenticated using (fn_est_connecte());
grant select on tournees_supprimees to authenticated;

create or replace function fn_peut_supprimer_passage() returns boolean
language sql stable as $$
  select fn_role_courant() in ('operations','admin');
$$;

comment on function fn_peut_supprimer_passage() is
  'Supprimer un passage entier défait son travail (avis, sorties de stock) '
  'sans toucher aux anomalies : réservé à Sarah P et Miguel, comme corriger '
  'la date d''un passage ou supprimer une facture.';

-- `tournees` porte déjà la politique large ecriture_operationnelle (tout
-- technicien, pour que décocher sa propre déclaration continue de marcher) :
-- une politique RESTRICTIVE s'y ajoute, elle ne la remplace pas.
drop policy if exists suppression_passage on tournees;
create policy suppression_passage on tournees
  as restrictive
  for delete to authenticated
  using (fn_peut_supprimer_passage());
