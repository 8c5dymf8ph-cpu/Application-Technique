-- =============================================================================
-- Migration 0007 : un intervenant de l'hôtel ne facture pas, les autres si
-- =============================================================================
-- Le code confondait « émet une facture » avec « est une entreprise
-- extérieure ». Farid et Rachid ne sont pas salariés de l'hôtel : ils
-- interviennent et ils facturent, alors qu'ils sont inscrits comme
-- utilisateurs. Taibi, Victoria et Miguel, eux, sont de la maison : leur
-- passage coûte le matériel sorti, et rien d'autre.
--
-- Deux choses manquaient : dire qui facture, et pouvoir attacher une facture à
-- quelqu'un qui n'est pas un prestataire.

alter table utilisateurs
  add column if not exists emet_des_factures boolean not null default false;

comment on column utilisateurs.emet_des_factures is
  'Intervenant non salarié : son passage donne lieu à une facture. Un employé '
  'de l''hôtel n''en émet pas — son passage ne coûte que le matériel sorti.';

update utilisateurs set emet_des_factures = true
 where nom in ('Farid', 'Rachid') and intervient_technique;

alter table factures
  add column if not exists technicien_id uuid references utilisateurs (id);

comment on column factures.technicien_id is
  'L''intervenant non salarié qui a émis la facture, quand ce n''est pas une '
  'entreprise extérieure.';

-- Une prestation vient d'un intervenant : entreprise extérieure OU personne
-- inscrite qui facture — jamais les deux, jamais aucune.
alter table factures drop constraint if exists emetteur_coherent_avec_type;
alter table factures add constraint emetteur_coherent_avec_type check (
  (type = 'prestation'
     and fournisseur_id is null
     and (prestataire_id is not null) <> (technicien_id is not null))
  or
  (type = 'achat'
     and fournisseur_id is not null
     and prestataire_id is null and technicien_id is null)
);

create index if not exists idx_factures_technicien on factures (technicien_id);

-- -----------------------------------------------------------------------------
-- Les récapitulatifs cherchaient l'adresse d'un administrateur dans
-- `utilisateurs.email` — où personne n'en a, et qu'aucun écran ne permet de
-- renseigner. Résultat : ils ne partaient jamais, sans que rien ne le dise.
-- Ils passent par les destinataires paramétrables, comme l'alerte bouteille,
-- et se règlent donc depuis /administration.
-- Inactives tant qu'aucune adresse n'est saisie : la table l'exige, et c'est
-- juste — une ligne active sans destinataire est une promesse en l'air.
insert into alertes_destinataires (evenement, destinataires, actif)
select v.e, '{}', false from (values ('recap_technicien'), ('recap_intervention')) as v (e)
 where not exists (select 1 from alertes_destinataires a where a.evenement = v.e);
