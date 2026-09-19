-- =============================================================================
-- Migration 0008 : des lieux pour essayer, sans salir les vrais chiffres
-- =============================================================================
-- Les chambres 06 et 07 servaient d'essai dans l'ancienne application ; elles
-- ont été écartées à l'import, à juste titre — leurs lignes n'étaient pas de
-- vraies interventions. Mais sans elles, il n'existe plus nulle part où
-- essayer : déclarer, intervenir, valider, perdre une bouteille, sortir du
-- matériel. On teste alors sur une vraie chambre, et les chiffres de l'hôtel
-- s'en ressentent.
--
-- Un lieu d'essai est un lieu comme un autre : tous les écrans l'acceptent.
-- Ce qui change, c'est qu'il se voit — et qu'il ne compte pas.

alter table emplacements
  add column if not exists essai boolean not null default false;

comment on column emplacements.essai is
  'Lieu d''entraînement. Les écrans le marquent, et ce qui s''y passe est exclu '
  'des compteurs de l''accueil : on doit pouvoir essayer sans fausser le suivi.';

-- Deux chambres d'essai, au rez-de-chaussée pour ne pas s'intercaler dans la
-- numérotation réelle des étages.
--
-- Sur une base neuve, cette migration passe AVANT les référentiels : il n'y a
-- pas encore d'étage où les poser. C'est alors le référentiel qui les crée
-- (supabase/seed/01_referentiels.sql). Ici, on sert les bases déjà installées.
insert into emplacements (code, nom, etage_id, type, dote_bouteilles, essai, ordre)
select v.code, v.nom, (select id from etages order by ordre limit 1),
       'chambre', true, true, 900
  from (values ('06', 'Chambre 06 — essai'),
               ('07', 'Chambre 07 — essai')) as v (code, nom)
 where exists (select 1 from etages)
   and not exists (select 1 from emplacements e where e.code = v.code);

-- Elles reçoivent la même dotation qu'une vraie chambre, sinon l'essai côté
-- bouteilles ne veut rien dire.
insert into dotations (emplacement_id, bouteille_type_id, quantite)
select e.id, b.id, 1
  from emplacements e cross join bouteille_types b
 where e.essai
   and not exists (select 1 from dotations d
                    where d.emplacement_id = e.id and d.bouteille_type_id = b.id);
