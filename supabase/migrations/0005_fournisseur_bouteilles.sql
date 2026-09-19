-- =============================================================================
-- Migration 0005 : un fournisseur de bouteilles n'est pas un fournisseur de
-- matériel
-- =============================================================================
-- Culligan livre les bouteilles Purezza et rien d'autre. Il apparaissait
-- pourtant dans « fournisseurs connus » en ouvrant la fiche d'un joint ou d'une
-- applique : on pouvait lui rattacher un article, et lui envoyer une demande de
-- devis pour du matériel qu'il ne vend pas.

alter table fournisseurs
  add column if not exists pour_bouteilles boolean not null default false;

comment on column fournisseurs.pour_bouteilles is
  'Fournisseur du parc Purezza. Il ne se propose pas sur une fiche produit, et '
  'un fournisseur de matériel ne se propose pas pour une commande de bouteilles.';

update fournisseurs set pour_bouteilles = true where nom = 'Culligan';
