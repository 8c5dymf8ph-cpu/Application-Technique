-- ==========================================================================
-- Import des bouteilles Purezza — produit par outils/importer_bouteilles.py
-- Ne pas éditer à la main : régénérer depuis l'export.
-- ==========================================================================
begin;

-- Personnes citées dans l'export des bouteilles ------------------------
insert into utilisateurs (nom, role) values ('Cristina', 'menage') on conflict (nom) do update set role = excluded.role;
insert into utilisateurs (nom, role) values ('Daria', 'menage') on conflict (nom) do update set role = excluded.role;
insert into utilisateurs (nom, role) values ('Ira', 'menage') on conflict (nom) do update set role = excluded.role;
insert into utilisateurs (nom, role) values ('Luca', 'reception') on conflict (nom) do update set role = excluded.role;
insert into utilisateurs (nom, role) values ('Miguel', 'admin') on conflict (nom) do update set role = excluded.role;
insert into utilisateurs (nom, role) values ('Rodica', 'menage') on conflict (nom) do update set role = excluded.role;
insert into utilisateurs (nom, role) values ('Taibi', 'reception') on conflict (nom) do update set role = excluded.role;
insert into utilisateurs (nom, role) values ('Victoria', 'gouvernante') on conflict (nom) do update set role = excluded.role;

-- Parc constaté à la reprise : chaque chambre dotée avait ses bouteilles.
-- Écrit comme une régularisation tracée, jamais comme un stock posé.
insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, vers_emplacement_id, date_mouvement, commentaire)
select 'regularisation', d.bouteille_type_id, d.quantite, 'hors_parc', 'emplacement',
       d.emplacement_id, timestamptz '2026-03-30 08:00+02',
       'Parc constaté à la reprise de l''ancienne application'
from dotations d join emplacements e on e.id = d.emplacement_id
where e.actif and e.dote_bouteilles;

-- Opérations reprises, dans l'ordre chronologique ----------------------

-- Entrée en réserve du 31/03/2026 — 46 filtrées, 44 gazeuses
insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, date_mouvement, commentaire)
select 'entree', bt.id, 46, 'hors_parc', 'reserve',
       timestamptz '2026-03-31 10:00+02', 'Livraison reprise de l''ancienne application'
from bouteille_types bt where bt.code = 'filtree';
insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, date_mouvement, commentaire)
select 'entree', bt.id, 44, 'hors_parc', 'reserve',
       timestamptz '2026-03-31 10:00+02', 'Livraison reprise de l''ancienne application'
from bouteille_types bt where bt.code = 'petillante';

-- PERTE-35-060420260,45633681 — chambre 35, 06/04/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Braileaunu',
         (select id from utilisateurs where nom = 'Daria'),
         timestamptz '2026-04-06 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Luca'),
         timestamptz '2026-04-06 11:30+02',
         timestamptz '2026-04-06 11:30+02',
         35.0, null
  from emplacements e where e.code = '35'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 1), ('petillante', 1)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille
   set statut = 'restitue', resolu_le = timestamptz '2026-04-06 17:00+02',
       resolu_par = (select id from utilisateurs where nom = 'Luca')
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '35')
                and constate_le = timestamptz '2026-04-06 11:00+02'
              order by reference desc limit 1);

-- PERTE-46-080420260,12306499 — chambre 46, 08/04/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Gomet',
         (select id from utilisateurs where nom = 'Rodica'),
         timestamptz '2026-04-08 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Miguel'),
         timestamptz '2026-04-10 11:30+02',
         timestamptz '2026-04-10 11:30+02',
         17.5, null
  from emplacements e where e.code = '46'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 0), ('petillante', 1)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille set statut = 'client_contacte'
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '46')
                and constate_le = timestamptz '2026-04-08 11:00+02'
              order by reference desc limit 1);

-- Remplacement en chambre 46 le 08/04/2026
insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, vers_emplacement_id, date_mouvement, utilisateur_id, commentaire)
select 'dotation', bt.id, 1, 'reserve', 'emplacement', e.id,
       timestamptz '2026-04-08 12:00+02',
       (select id from utilisateurs where nom = 'Victoria'),
       'Remplacement repris — REMPL-46-080420260,5197314'
from bouteille_types bt, emplacements e
where bt.code = 'petillante' and e.code = '46';

-- PERTE-11-130420260,60525226 — chambre 11, 13/04/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Bertrand',
         (select id from utilisateurs where nom = 'Rodica'),
         timestamptz '2026-04-13 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Luca'),
         timestamptz '2026-04-13 11:30+02',
         timestamptz '2026-04-13 11:30+02',
         17.5, null
  from emplacements e where e.code = '11'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 0), ('petillante', 1)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille
   set statut = 'non_facture', resolu_le = timestamptz '2026-04-13 17:00+02',
       resolu_par = (select id from utilisateurs where nom = 'Luca')
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '11')
                and constate_le = timestamptz '2026-04-13 11:00+02'
              order by reference desc limit 1);

-- Remplacement en chambre 11 le 13/04/2026
insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, vers_emplacement_id, date_mouvement, utilisateur_id, commentaire)
select 'dotation', bt.id, 1, 'reserve', 'emplacement', e.id,
       timestamptz '2026-04-13 12:00+02',
       (select id from utilisateurs where nom = 'Victoria'),
       'Remplacement repris — REMPL-11-130420260,43524213'
from bouteille_types bt, emplacements e
where bt.code = 'petillante' and e.code = '11';

-- PERTE-35-150420260,92641367 — chambre 35, 15/04/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Arifin',
         (select id from utilisateurs where nom = 'Daria'),
         timestamptz '2026-04-15 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Taibi'),
         timestamptz '2026-04-15 11:30+02',
         timestamptz '2026-04-15 11:30+02',
         35.0, null
  from emplacements e where e.code = '35'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 1), ('petillante', 1)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille
   set statut = 'facture', resolu_le = timestamptz '2026-04-15 17:00+02',
       resolu_par = (select id from utilisateurs where nom = 'Taibi')
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '35')
                and constate_le = timestamptz '2026-04-15 11:00+02'
              order by reference desc limit 1);

-- Remplacement en chambre 35 le 15/04/2026
insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, vers_emplacement_id, date_mouvement, utilisateur_id, commentaire)
select 'dotation', bt.id, 1, 'reserve', 'emplacement', e.id,
       timestamptz '2026-04-15 12:00+02',
       (select id from utilisateurs where nom = 'Victoria'),
       'Remplacement repris — REMPL-35-150420260,7616837'
from bouteille_types bt, emplacements e
where bt.code = 'filtree' and e.code = '35';
insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, vers_emplacement_id, date_mouvement, utilisateur_id, commentaire)
select 'dotation', bt.id, 1, 'reserve', 'emplacement', e.id,
       timestamptz '2026-04-15 12:00+02',
       (select id from utilisateurs where nom = 'Victoria'),
       'Remplacement repris — REMPL-35-150420260,7616837'
from bouteille_types bt, emplacements e
where bt.code = 'petillante' and e.code = '35';

-- PERTE-14-250420260,67570158 — chambre 14, 25/04/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Laura Dunn',
         (select id from utilisateurs where nom = 'Rodica'),
         timestamptz '2026-04-25 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Luca'),
         timestamptz '2026-04-25 11:30+02',
         timestamptz '2026-04-25 11:30+02',
         17.5, null
  from emplacements e where e.code = '14'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 1), ('petillante', 0)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille
   set statut = 'restitue', resolu_le = timestamptz '2026-04-25 17:00+02',
       resolu_par = (select id from utilisateurs where nom = 'Luca')
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '14')
                and constate_le = timestamptz '2026-04-25 11:00+02'
              order by reference desc limit 1);

-- PERTE-18-050520260,15906899 — chambre 18, 05/05/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Minchenberg',
         (select id from utilisateurs where nom = 'Cristina'),
         timestamptz '2026-05-05 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Miguel'),
         timestamptz '2026-05-05 11:30+02',
         timestamptz '2026-05-05 11:30+02',
         17.5, null
  from emplacements e where e.code = '18'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 1), ('petillante', 0)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille set statut = 'client_contacte'
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '18')
                and constate_le = timestamptz '2026-05-05 11:00+02'
              order by reference desc limit 1);

-- PERTE-22-050520260,61069498 — chambre 22, 05/05/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Seltzer',
         (select id from utilisateurs where nom = 'Cristina'),
         timestamptz '2026-05-05 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Miguel'),
         timestamptz '2026-05-05 11:30+02',
         timestamptz '2026-05-05 11:30+02',
         17.5, null
  from emplacements e where e.code = '22'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 1), ('petillante', 0)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille set statut = 'client_contacte'
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '22')
                and constate_le = timestamptz '2026-05-05 11:00+02'
              order by reference desc limit 1);

-- PERTE-44-120520260,84878266 — chambre 44, 12/05/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Brown Jillian',
         (select id from utilisateurs where nom = 'Ira'),
         timestamptz '2026-05-12 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Miguel'),
         timestamptz '2026-05-12 11:30+02',
         timestamptz '2026-05-15 11:30+02',
         17.5, null
  from emplacements e where e.code = '44'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 0), ('petillante', 1)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille set statut = 'client_contacte'
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '44')
                and constate_le = timestamptz '2026-05-12 11:00+02'
              order by reference desc limit 1);

-- PERTE-18-140520260,15333112 — chambre 18, 13/05/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Coulet',
         (select id from utilisateurs where nom = 'Victoria'),
         timestamptz '2026-05-13 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Miguel'),
         timestamptz '2026-05-13 11:30+02',
         timestamptz '2026-05-15 11:30+02',
         17.5, null
  from emplacements e where e.code = '18'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 0), ('petillante', 1)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille
   set statut = 'non_facture', resolu_le = timestamptz '2026-05-27 17:00+02',
       resolu_par = (select id from utilisateurs where nom = 'Miguel')
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '18')
                and constate_le = timestamptz '2026-05-13 11:00+02'
              order by reference desc limit 1);

-- Remplacement en chambre 18 le 19/05/2026
insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, vers_emplacement_id, date_mouvement, utilisateur_id, commentaire)
select 'dotation', bt.id, 1, 'reserve', 'emplacement', e.id,
       timestamptz '2026-05-19 12:00+02',
       (select id from utilisateurs where nom = 'Victoria'),
       'Remplacement repris — REMPL-18-190520260,51746711'
from bouteille_types bt, emplacements e
where bt.code = 'petillante' and e.code = '18';

-- PERTE-41-270520260,02073614 — chambre 41, 27/05/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Parker Stephen',
         (select id from utilisateurs where nom = 'Daria'),
         timestamptz '2026-05-27 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Taibi'),
         timestamptz '2026-05-27 11:30+02',
         timestamptz '2026-06-22 11:30+02',
         17.5, null
  from emplacements e where e.code = '41'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 0), ('petillante', 1)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille
   set statut = 'facture', resolu_le = timestamptz '2026-06-22 17:00+02',
       resolu_par = (select id from utilisateurs where nom = 'Taibi')
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '41')
                and constate_le = timestamptz '2026-05-27 11:00+02'
              order by reference desc limit 1);

-- PERTE-27-270520260,31715272 — chambre 27, 27/05/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Taylor Brian',
         (select id from utilisateurs where nom = 'Daria'),
         timestamptz '2026-05-27 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Taibi'),
         timestamptz '2026-05-27 11:30+02',
         timestamptz '2026-06-22 11:30+02',
         17.5, null
  from emplacements e where e.code = '27'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 0), ('petillante', 1)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille
   set statut = 'non_facture', resolu_le = timestamptz '2026-06-22 17:00+02',
       resolu_par = (select id from utilisateurs where nom = 'Taibi')
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '27')
                and constate_le = timestamptz '2026-05-27 11:00+02'
              order by reference desc limit 1);

-- PERTE-26-090620260,99269038 — chambre 26, 09/06/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Barlow',
         (select id from utilisateurs where nom = 'Daria'),
         timestamptz '2026-06-09 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Taibi'),
         timestamptz '2026-06-09 11:30+02',
         timestamptz '2026-06-09 11:30+02',
         17.5, null
  from emplacements e where e.code = '26'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 1), ('petillante', 0)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille
   set statut = 'facture', resolu_le = timestamptz '2026-06-09 17:00+02',
       resolu_par = (select id from utilisateurs where nom = 'Taibi')
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '26')
                and constate_le = timestamptz '2026-06-09 11:00+02'
              order by reference desc limit 1);

-- PERTE-44-120620260,60899175 — chambre 44, 12/06/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Agence chinoise',
         (select id from utilisateurs where nom = 'Rodica'),
         timestamptz '2026-06-12 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Taibi'),
         timestamptz '2026-06-12 11:30+02',
         timestamptz '2026-06-22 11:30+02',
         17.5, null
  from emplacements e where e.code = '44'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 1), ('petillante', 0)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille set statut = 'client_contacte'
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '44')
                and constate_le = timestamptz '2026-06-12 11:00+02'
              order by reference desc limit 1);

-- PERTE-52-010720260,37728873 — chambre 52, 01/07/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Troxler-Egan',
         (select id from utilisateurs where nom = 'Ira'),
         timestamptz '2026-07-01 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Miguel'),
         timestamptz '2026-07-01 11:30+02',
         timestamptz '2026-07-01 11:30+02',
         35.0, null
  from emplacements e where e.code = '52'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 1), ('petillante', 1)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille
   set statut = 'facture', resolu_le = timestamptz '2026-07-01 17:00+02',
       resolu_par = (select id from utilisateurs where nom = 'Miguel')
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '52')
                and constate_le = timestamptz '2026-07-01 11:00+02'
              order by reference desc limit 1);

-- PERTE-36-150920260,55003261 — chambre 36, 15/09/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', 'Aziz Abdoul',
         (select id from utilisateurs where nom = 'Daria'),
         timestamptz '2026-09-15 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Taibi'),
         timestamptz '2026-09-15 11:30+02',
         timestamptz '2026-09-15 11:30+02',
         35.0, null
  from emplacements e where e.code = '36'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 1), ('petillante', 1)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille
   set statut = 'restitue', resolu_le = timestamptz '2026-09-15 17:00+02',
       resolu_par = (select id from utilisateurs where nom = 'Taibi')
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '36')
                and constate_le = timestamptz '2026-09-15 11:00+02'
              order by reference desc limit 1);

-- Remplacement en chambre 36 le 15/09/2026
insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, vers_emplacement_id, date_mouvement, utilisateur_id, commentaire)
select 'dotation', bt.id, 1, 'reserve', 'emplacement', e.id,
       timestamptz '2026-09-15 12:00+02',
       (select id from utilisateurs where nom = 'Victoria'),
       'Remplacement repris — REMPL-36-150920260,2648282'
from bouteille_types bt, emplacements e
where bt.code = 'filtree' and e.code = '36';
insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
       de_lieu, vers_lieu, vers_emplacement_id, date_mouvement, utilisateur_id, commentaire)
select 'dotation', bt.id, 1, 'reserve', 'emplacement', e.id,
       timestamptz '2026-09-15 12:00+02',
       (select id from utilisateurs where nom = 'Victoria'),
       'Remplacement repris — REMPL-36-150920260,2648282'
from bouteille_types bt, emplacements e
where bt.code = 'petillante' and e.code = '36';

-- PERTE-46-160920260,26356118 — chambre 46, 16/09/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', null,
         (select id from utilisateurs where nom = 'Ira'),
         timestamptz '2026-09-16 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Miguel'),
         timestamptz '2026-09-16 11:30+02',
         timestamptz '2026-09-17 11:30+02',
         35.0, null
  from emplacements e where e.code = '46'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 1), ('petillante', 1)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille
   set statut = 'restitue', resolu_le = timestamptz '2026-09-17 17:00+02',
       resolu_par = (select id from utilisateurs where nom = 'Miguel')
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '46')
                and constate_le = timestamptz '2026-09-16 11:00+02'
              order by reference desc limit 1);

-- PERTE-38-160920260,6432857 — chambre 38, 16/09/2026
with dossier as (
  insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                   constate_par, constate_le, statut, redoter,
                                   transmis_a, transmis_le, client_contacte_le,
                                   montant, commentaire)
  select e.id, 'emport', 'client', null,
         (select id from utilisateurs where nom = 'Victoria'),
         timestamptz '2026-09-16 11:00+02', 'signale', false,
         (select id from utilisateurs where nom = 'Miguel'),
         timestamptz '2026-09-16 11:30+02',
         null,
         17.5, null
  from emplacements e where e.code = '38'
  returning id
)
insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
select dossier.id, bt.id, v.qte
from dossier, (values ('filtree', 1), ('petillante', 0)) as v (code, qte)
join bouteille_types bt on bt.code = v.code
where v.qte > 0;
update incidents_bouteille set statut = 'transmis'
 where id = (select id from incidents_bouteille
              where emplacement_id = (select id from emplacements where code = '38')
                and constate_le = timestamptz '2026-09-16 11:00+02'
              order by reference desc limit 1);

commit;
