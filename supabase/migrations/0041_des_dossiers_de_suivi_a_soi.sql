-- =============================================================================
-- Migration 0041 : des dossiers de suivi qu'on crée et qu'on règle soi-même
-- =============================================================================
-- Le modèle de la 0023 est déjà général : `natures_suivi` porte le genre de
-- dossier, `types_acte` ce qu'on peut y consigner (le « quoi »), et
-- `pieces_suivi.nature_piece` est un texte libre. Mais une seule nature
-- existait — les punaises — posée par la migration, et rien ne permettait d'en
-- créer une autre : « je souhaite créer un dossier de suivi pour deux
-- contrats, le désenfumage et la vérification des extincteurs, et que ce soit
-- moi qui le fasse ».
--
-- Les écrans créent désormais une nature, ses étapes, et les corrigent. Une
-- étape qui ne sert plus se RETIRE au lieu de se supprimer dès qu'un acte
-- l'a utilisée : la chronologie passée doit garder son mot.
alter table types_acte
  add column if not exists actif boolean not null default true;

comment on column types_acte.actif is
  'Faux : l''étape n''est plus proposée pour un nouvel acte, mais les actes '
  'qui l''ont utilisée la gardent. Une étape jamais utilisée se supprime.';
