-- =============================================================================
-- Migration 0010 : tout intervenant peut se connecter, et recevoir son
-- récapitulatif
-- =============================================================================
-- Deux personnes seulement apparaissaient au choix des profils — Farid et
-- Rachid — parce qu'eux seuls étaient inscrits dans `utilisateurs`. Les treize
-- autres sont des `prestataires`, et c'est ce lien-là qui sert au rapprochement
-- des factures : on ne peut pas les recopier ailleurs sans le casser.
--
-- On relie donc les deux. Une personne qui se connecte peut porter le compte
-- d'une entreprise : la tournée qu'elle ouvre reste rattachée au prestataire,
-- et la facture se rapproche comme avant.
--
-- Et qui apparaît au choix des profils devient un réglage, pas une conséquence
-- de la table où l'on se trouve : l'hôtel change d'intervenants, Serafino peut
-- partir et un autre arriver.

alter table utilisateurs
  add column if not exists prestataire_id uuid references prestataires (id),
  add column if not exists peut_se_connecter boolean not null default true;

comment on column utilisateurs.prestataire_id is
  'L''entreprise pour laquelle cette personne intervient. Sa tournée se '
  'rattache au prestataire, pour que la facture se rapproche comme avant.';
comment on column utilisateurs.peut_se_connecter is
  'Apparaît dans le choix des profils. Se règle depuis /administration/equipe.';

create unique index if not exists utilisateur_par_prestataire
  on utilisateurs (prestataire_id) where prestataire_id is not null;

-- Les intervenants ne se connectaient pas jusqu'ici : ils n'apparaissent au
-- choix des profils que si on le demande. Les autres rôles gardent leur accès.
update utilisateurs set peut_se_connecter = false
 where role = 'technicien' and prestataire_id is null;

-- Une adresse par intervenant : c'est là que part son récapitulatif de fin de
-- passage. La colonne existe déjà pour les personnes ; les entreprises en ont
-- désormais une aussi, pour le jour où elles n'ont pas de compte.
alter table prestataires add column if not exists email text;

-- La liste des intervenants ne doit pas compter deux fois quelqu'un qui porte
-- le compte d'une entreprise : c'est l'entreprise qui fait foi.
create or replace view v_intervenants as
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
where u.intervient_technique and u.prestataire_id is null
group by u.id
union all
select
  -- Le compte qui porte l'entreprise, s'il existe : c'est lui qui écrit.
  (select x.id from utilisateurs x where x.prestataire_id = p.id and x.actif),
  p.id,
  p.nom,
  'externe'::text,
  p.actif,
  coalesce(array_remove(array_agg(t.code), null), '{}')::text[]
from prestataires p
left join specialites_intervenant s on s.prestataire_id = p.id
left join types_intervention t      on t.id = s.type_intervention_id
group by p.id;
