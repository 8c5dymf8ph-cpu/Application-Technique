-- Généré par outils/importer_anomalies.py — ne pas modifier à la main.
-- Import de la liste « TEST Tech 3 » vers anomalies / tournees /
-- interventions / validations. Rejouable : rien n'est inséré deux fois.
-- Morceau 1 sur 5 — à jouer dans l'ordre des lettres.

begin;
alter table validations disable trigger tg_validation_maj_anomalie;

-- Personnes rencontrées dans l'export ---------------------------------
insert into utilisateurs (nom, role) values ('FARID', 'technicien') on conflict do nothing;
insert into utilisateurs (nom, role) values ('Miguel', 'admin') on conflict do nothing;
insert into utilisateurs (nom, role) values ('Rachid', 'technicien') on conflict do nothing;
insert into utilisateurs (nom, role) values ('Sarah P', 'operations') on conflict do nothing;
insert into utilisateurs (nom, role) values ('Victoria', 'gouvernante') on conflict do nothing;
insert into prestataires (nom) values ('ALAIN') on conflict do nothing;
insert into prestataires (nom) values ('EcoFlair') on conflict do nothing;
insert into prestataires (nom) values ('Hedi') on conflict do nothing;
insert into prestataires (nom) values ('Juan') on conflict do nothing;
insert into prestataires (nom) values ('MR NEGRONI') on conflict do nothing;
insert into prestataires (nom) values ('Serafino') on conflict do nothing;
insert into prestataires (nom) values ('Technicien AVIR') on conflict do nothing;
insert into prestataires (nom) values ('Technicien EUROPROH') on conflict do nothing;
insert into prestataires (nom) values ('Technicien Kone') on conflict do nothing;
insert into prestataires (nom) values ('Technicien TELEC') on conflict do nothing;

-- Spécialités : une section qui ne montre que son métier -------------
insert into specialites_intervenant (utilisateur_id, prestataire_id, type_intervention_id)
  select u.id, p.id, t.id from types_intervention t
  left join utilisateurs u  on u.nom = 'ALAIN'
  left join prestataires p  on p.nom = 'ALAIN'
  where t.code = 'ELECTRIQUE'
    and num_nonnulls(u.id, p.id) = 1 on conflict do nothing;

-- Tournées (InterventionID d'origine) ---------------------------------
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-ALAIN-20260429160344684', date '2026-04-29', date '2026-04-29', true, (select id from prestataires where nom = 'ALAIN')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-LEGACY-Alain-20260416', date '2026-04-16', date '2026-04-16', true, (select id from prestataires where nom = 'ALAIN')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-LEGACY-Alain-20260422', date '2026-04-22', date '2026-04-22', true, (select id from prestataires where nom = 'ALAIN')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, technicien_id) values ('INT-Miguel-20260503135251788', date '2026-03-05', date '2026-03-05', true, (select id from utilisateurs where nom = 'Miguel')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, technicien_id) values ('INT-Miguel-20260616120540016', date '2026-06-16', date '2026-06-16', true, (select id from utilisateurs where nom = 'Miguel')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, technicien_id) values ('INT-Miguel-20260616153517575', date '2026-06-16', date '2026-06-16', true, (select id from utilisateurs where nom = 'Miguel')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, technicien_id) values ('INT-Rachid-260526123456', date '2026-05-26', date '2026-05-26', true, (select id from utilisateurs where nom = 'Rachid')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260511103458060', date '2026-04-23', date '2026-04-23', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260511114443975', date '2026-11-05', date '2026-11-05', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260513173803397', date '2026-05-13', date '2026-05-13', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260515181906844', date '2026-05-15', date '2026-05-15', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260519145131393', date '2026-05-19', date '2026-05-19', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260520160006749', date '2026-05-20', date '2026-05-20', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260602100648666', date '2026-02-06', date '2026-02-06', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260602104100283', date '2026-02-06', date '2026-02-06', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260602111132223', date '2026-02-06', date '2026-02-06', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260602115516048', date '2026-02-06', date '2026-02-06', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260602120212808', date '2026-02-06', date '2026-02-06', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260602123353973', date '2026-02-06', date '2026-02-06', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260602123616656', date '2026-02-06', date '2026-02-06', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260602124118036', date '2026-02-06', date '2026-02-06', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260602125318070', date '2026-02-06', date '2026-02-06', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260602130907557', date '2026-02-06', date '2026-02-06', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260602131132280', date '2026-02-06', date '2026-02-06', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260602140724598', date '2026-02-06', date '2026-02-06', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260615121923728', date '2026-06-15', date '2026-06-15', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260615131234028', date '2026-06-15', date '2026-06-15', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260615131453958', date '2026-06-15', date '2026-06-15', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
insert into tournees (reference, date_tournee, cloturee_le, reprise, prestataire_id) values ('INT-Serafino-20260625142445177', date '2026-06-25', date '2026-06-25', true, (select id from prestataires where nom = 'Serafino')) on conflict (reference) do nothing;
-- Anomalies -----------------------------------------------------------
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1262, e.id, c.id, t.id, 'porte du frigo à fixer', 'a_faire', u1.id, u2.id, timestamptz '2026-07-09', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'porte du frigo à fixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '44' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1256, e.id, c.id, t.id, 'flexible fuit au niveau du pommeau de douche', 'a_faire', u1.id, u2.id, timestamptz '2026-03-09', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible fuit au niveau du pommeau de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1257, e.id, c.id, t.id, 'serrer le bras liseuse côté droit', 'a_faire', u1.id, u2.id, timestamptz '2026-03-09', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1258, e.id, c.id, t.id, 'lavabo bouché', 'a_faire', u1.id, u2.id, timestamptz '2026-03-09', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1259, e.id, c.id, t.id, 'lavabo bouché', 'a_faire', u1.id, u2.id, timestamptz '2026-03-09', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1260, e.id, c.id, t.id, 'remplacement bras de liseuse (coté gauche)', 'a_faire', u1.id, u2.id, timestamptz '2026-03-09', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacement bras de liseuse (coté gauche)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1261, e.id, c.id, t.id, 'spot du couloir a changer', 'a_faire', u1.id, u2.id, timestamptz '2026-03-09', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'spot du couloir a changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = 'Office 5 ème étage' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1255, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'a_faire', u1.id, u2.id, timestamptz '2026-08-30', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1253, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'a_faire', u1.id, u2.id, timestamptz '2026-11-08', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1248, e.id, c.id, t.id, 'flexible fuit au niveau du pommeau de douche', 'a_faire', u1.id, u2.id, timestamptz '2026-05-08', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible fuit au niveau du pommeau de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1249, e.id, c.id, t.id, 'flexible fuit au niveau du pommeau de douche', 'a_faire', u1.id, u2.id, timestamptz '2026-05-08', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible fuit au niveau du pommeau de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1250, e.id, c.id, t.id, 'flexible fuit au niveau du pommeau de douche', 'a_faire', u1.id, u2.id, timestamptz '2026-05-08', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible fuit au niveau du pommeau de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1251, e.id, c.id, t.id, 'lavabo bouché', 'a_faire', u1.id, u2.id, timestamptz '2026-05-08', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1252, e.id, c.id, t.id, 'refixer la liseuse de droite', 'a_faire', u1.id, u2.id, timestamptz '2026-05-08', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'refixer la liseuse de droite'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1246, e.id, c.id, t.id, 'flexible douche à changer', 'a_faire', u1.id, u2.id, timestamptz '2026-03-08', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1247, e.id, c.id, t.id, 'flexible fuit au niveau du pommeau de douche', 'a_faire', u1.id, u2.id, timestamptz '2026-03-08', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible fuit au niveau du pommeau de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1161, e.id, c.id, t.id, 'Attache mural de la porte de secours devant la porte des escaliers à fixer', 'a_faire', u1.id, u2.id, timestamptz '2026-07-27', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Attache mural de la porte de secours devant la porte des escaliers à fixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1240, e.id, c.id, t.id, 'lit côté gauche cassé', 'a_faire', u1.id, u2.id, timestamptz '2026-07-24', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté gauche cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1241, e.id, c.id, t.id, 'changement support lait corporel', 'a_faire', u1.id, u2.id, timestamptz '2026-07-24', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'changement support lait corporel'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1242, e.id, c.id, t.id, 'Spot du couloir a changer', 'a_faire', u1.id, u2.id, timestamptz '2026-07-24', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'spot du couloir a changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '2eme étage' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1243, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'a_faire', u1.id, u2.id, timestamptz '2026-07-24', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '02' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1244, e.id, c.id, t.id, 'Lunette des WC à changer', 'a_faire', u1.id, u2.id, timestamptz '2026-07-24', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lunette des WC à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1239, e.id, c.id, t.id, 'Il faut changer le fil du Chafing dish rond (réchaud de buffet)', 'validee', u1.id, u2.id, timestamptz '2026-07-22', '2026-07-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il faut changer le fil du Chafing dish rond (réchaud de buffet)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-07-23', timestamptz '2026-07-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 1239
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-07-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1239
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-07-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1239
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1160, e.id, c.id, t.id, 'Lave-main à installer', 'a_faire', u1.id, u2.id, timestamptz '2026-07-20', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lave-main à installer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'WC Clients' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1229, e.id, c.id, t.id, 'Il faut changer le sèche-main', 'validee', u1.id, u2.id, timestamptz '2026-07-19', '2026-07-20'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il faut changer le sèche-main'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'WC Clients' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Le sèche-main fonctionne après qu''Alain ait nettoyé le capteur qui était plein de poussière', 'utilisateur', u.id, timestamptz '2026-07-19'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1229
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Le sèche-main fonctionne après qu''Alain ait nettoyé le capteur qui était plein de poussière');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-07-20', timestamptz '2026-07-20'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 1229
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-07-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1229
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-07-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1229
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1225, e.id, c.id, t.id, 'lit côté gauche cassé', 'a_faire', u1.id, u2.id, timestamptz '2026-01-07', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté gauche cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1226, e.id, c.id, t.id, 'lit côté droit cassé', 'a_faire', u1.id, u2.id, timestamptz '2026-01-07', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lit côté droit cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1227, e.id, c.id, t.id, 'Spot à changer (celui du milieu) côté machine à café', 'a_faire', u1.id, u2.id, timestamptz '2026-01-07', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à changer (celui du milieu) côté machine à café'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1223, e.id, c.id, t.id, 'Il faut refaire les joints mitigeur de douche', 'a_faire', u1.id, u2.id, timestamptz '2026-06-25', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il faut refaire les joints mitigeur de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1224, e.id, c.id, t.id, 'Il faut refaire les joints mitigeur de douche', 'a_faire', u1.id, u2.id, timestamptz '2026-06-25', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il faut refaire les joints mitigeur de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1158, e.id, c.id, t.id, 'Il faut repeindre les deux pots de fleurs', 'a_faire', u1.id, u2.id, timestamptz '2026-06-23', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il faut repeindre les deux pots de fleurs'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'COUR intèrieure' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1148, e.id, c.id, t.id, 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', u1.id, u2.id, timestamptz '2026-06-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1149, e.id, c.id, t.id, 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', u1.id, u2.id, timestamptz '2026-06-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1150, e.id, c.id, t.id, 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', u1.id, u2.id, timestamptz '2026-06-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1151, e.id, c.id, t.id, 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', u1.id, u2.id, timestamptz '2026-06-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1152, e.id, c.id, t.id, 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', u1.id, u2.id, timestamptz '2026-06-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '26' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1153, e.id, c.id, t.id, 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', u1.id, u2.id, timestamptz '2026-06-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1154, e.id, c.id, t.id, 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', u1.id, u2.id, timestamptz '2026-06-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1155, e.id, c.id, t.id, 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', u1.id, u2.id, timestamptz '2026-06-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1156, e.id, c.id, t.id, 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', u1.id, u2.id, timestamptz '2026-06-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '55' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1157, e.id, c.id, t.id, 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', u1.id, u2.id, timestamptz '2026-06-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1159, e.id, c.id, t.id, 'Il faut faire les joints', 'a_faire', u1.id, u2.id, timestamptz '2026-06-16', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il faut faire les joints'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1214, e.id, c.id, t.id, 'flexible douche à changer', 'validee', u1.id, u2.id, timestamptz '2026-06-16', '2026-06-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-16', timestamptz '2026-06-16'
  from anomalies a
  left join tournees t on t.reference = 'INT-Miguel-20260616120540016'
  left join utilisateurs u on u.nom = 'Miguel'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1214
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1214
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1214
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1215, e.id, c.id, t.id, 'voir avec miroitier pour miroir placard cassé en bas (grand)', 'a_faire', u1.id, u2.id, timestamptz '2026-06-16', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'voir avec miroitier pour miroir placard cassé en bas (grand)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1216, e.id, c.id, t.id, 'lit côté gauche cassé', 'validee', u1.id, u2.id, timestamptz '2026-06-16', '2026-01-07'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté gauche cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '02' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-25', timestamptz '2026-06-25'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260625142445177'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1216
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-25'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1216
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-01-07'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1216
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1217, e.id, c.id, t.id, 'urgent - joints sillicone douche', 'validee', u1.id, u2.id, timestamptz '2026-06-16', '2026-01-07'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'urgent - joints sillicone douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-25', timestamptz '2026-06-25'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260625142445177'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1217
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-25'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1217
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-01-07'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1217
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1218, e.id, c.id, t.id, 'urgent - joints sillicone douche', 'validee', u1.id, u2.id, timestamptz '2026-06-16', '2026-01-07'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'urgent - joints sillicone douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '44' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-25', timestamptz '2026-06-25'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260625142445177'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1218
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-25'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1218
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-01-07'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1218
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1219, e.id, c.id, t.id, 'refixer la liseuse de droite', 'validee', u1.id, u2.id, timestamptz '2026-06-16', '2026-01-07'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'refixer la liseuse de droite'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-25', timestamptz '2026-06-25'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260625142445177'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1219
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-25'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1219
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-01-07'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1219
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1205, e.id, c.id, t.id, 'lavabo bouché', 'a_faire', u1.id, u2.id, timestamptz '2026-06-15', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615131234028'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1205
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1205
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1205
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1206, e.id, c.id, t.id, 'lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2026-06-15', '2026-06-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '55' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615131234028'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1206
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1206
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1206
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1207, e.id, c.id, t.id, 'flexible douche à changer', 'validee', u1.id, u2.id, timestamptz '2026-06-15', '2026-06-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615131453958'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1207
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1207
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1207
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1208, e.id, c.id, t.id, 'flexible douche à changer', 'validee', u1.id, u2.id, timestamptz '2026-06-15', '2026-06-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '44' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615131453958'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1208
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1208
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1208
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1209, e.id, c.id, t.id, 'lavabo bouché', 'a_faire', u1.id, u2.id, timestamptz '2026-06-15', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '4eme étage' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1210, e.id, c.id, t.id, 'lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2026-06-15', '2026-06-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '44' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615131234028'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1210
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1210
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1210
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1211, e.id, c.id, t.id, 'lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2026-06-15', '2026-06-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615131234028'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1211
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1211
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1211
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1212, e.id, c.id, t.id, 'lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2026-06-15', '2026-06-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615131234028'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1212
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1212
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1212
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1213, e.id, c.id, t.id, 'lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2026-06-15', '2026-06-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '21' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615131234028'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1213
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1213
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1213
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1202, e.id, c.id, t.id, 'flexible douche à changer', 'validee', u1.id, u2.id, timestamptz '2026-09-06', '2026-06-15'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615121923728'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1202
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1202
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1202
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1203, e.id, c.id, t.id, 'serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2026-09-06', '2026-06-15'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615121923728'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1203
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1203
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1203
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1204, e.id, c.id, t.id, 'miroir plateau à changé', 'a_faire', u1.id, u2.id, timestamptz '2026-09-06', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Miroir plateau à changé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1192, e.id, c.id, t.id, 'lit côté gauche cassé', 'validee', u1.id, u2.id, timestamptz '2026-02-06', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté gauche cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '34' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602100648666'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1192
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1192
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1192
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1193, e.id, c.id, t.id, 'lit côté gauche cassé', 'validee', u1.id, u2.id, timestamptz '2026-02-06', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté gauche cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '34' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602100648666'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1193
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1193
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1193
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1194, e.id, c.id, t.id, 'lit côté droit cassé', 'validee', u1.id, u2.id, timestamptz '2026-02-06', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lit côté droit cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602120212808'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1194
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1194
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1194
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1195, e.id, c.id, t.id, 'urgent - joints sillicone douche - lavabo et wc à refaire complètement', 'a_faire', u1.id, u2.id, timestamptz '2026-02-06', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'urgent - joints sillicone douche - lavabo et wc à refaire complètement'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615131234028'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1195
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1195
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1195
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1196, e.id, c.id, t.id, 'lit côté gauche cassé', 'validee', u1.id, u2.id, timestamptz '2026-02-06', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté gauche cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602125318070'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1196
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1196
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1196
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1197, e.id, c.id, t.id, 'flexible douche à changer', 'validee', u1.id, u2.id, timestamptz '2026-02-06', '2026-06-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '21' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615131453958'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1197
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1197
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1197
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1198, e.id, c.id, t.id, 'recoller les cornières dorées sur les deux pilliers', 'validee', u1.id, u2.id, timestamptz '2026-02-06', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'recoller les cornières dorées sur les deux pilliers'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602115516048'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1198
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1198
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1198
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1199, e.id, c.id, t.id, 'lit côté gauche cassé', 'validee', u1.id, u2.id, timestamptz '2026-02-06', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté gauche cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602120212808'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1199
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1199
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1199
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1200, e.id, c.id, t.id, 'serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2026-02-06', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602131132280'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1200
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1200
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1200
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1201, e.id, c.id, t.id, 'serrer le bras liseuse côté gauche', 'validee', u1.id, u2.id, timestamptz '2026-02-06', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602140724598'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1201
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1201
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1201
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1190, e.id, c.id, t.id, 'télécommande clim à remplacer', 'a_faire', u1.id, u2.id, timestamptz '2026-05-28', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'télécommande clim à remplacer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1191, e.id, c.id, t.id, 'télécommande clim à remplacer', 'a_faire', u1.id, u2.id, timestamptz '2026-05-28', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'télécommande clim à remplacer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1133, e.id, c.id, t.id, 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs', 'validee', u1.id, u2.id, timestamptz '2026-05-26', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'RAS', 'utilisateur', u.id, timestamptz '2026-05-26'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1133
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-26', timestamptz '2026-05-26'
  from anomalies a
  left join tournees t on t.reference = 'INT-Rachid-260526123456'
  left join utilisateurs u on u.nom = 'Rachid'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1133
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Rachid'
  where a.sharepoint_id = 1133
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1133
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1144, e.id, c.id, t.id, 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs', 'validee', u1.id, u2.id, timestamptz '2026-05-26', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'RAS', 'utilisateur', u.id, timestamptz '2026-05-26'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1144
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-26', timestamptz '2026-05-26'
  from anomalies a
  left join tournees t on t.reference = 'INT-Rachid-260526123456'
  left join utilisateurs u on u.nom = 'Rachid'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1144
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Rachid'
  where a.sharepoint_id = 1144
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1144
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1145, e.id, c.id, t.id, 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs', 'validee', u1.id, u2.id, timestamptz '2026-05-26', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Cuisine' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'RAS', 'utilisateur', u.id, timestamptz '2026-05-26'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1145
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-26', timestamptz '2026-05-26'
  from anomalies a
  left join tournees t on t.reference = 'INT-Rachid-260526123456'
  left join utilisateurs u on u.nom = 'Rachid'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1145
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Rachid'
  where a.sharepoint_id = 1145
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1145
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1146, e.id, c.id, t.id, 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs', 'validee', u1.id, u2.id, timestamptz '2026-05-26', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Local TGBT' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'RAS', 'utilisateur', u.id, timestamptz '2026-05-26'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1146
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-26', timestamptz '2026-05-26'
  from anomalies a
  left join tournees t on t.reference = 'INT-Rachid-260526123456'
  left join utilisateurs u on u.nom = 'Rachid'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1146
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Rachid'
  where a.sharepoint_id = 1146
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1146
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1147, e.id, c.id, t.id, 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs', 'validee', u1.id, u2.id, timestamptz '2026-05-26', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lingerie' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'RAS', 'utilisateur', u.id, timestamptz '2026-05-26'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1147
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-26', timestamptz '2026-05-26'
  from anomalies a
  left join tournees t on t.reference = 'INT-Rachid-260526123456'
  left join utilisateurs u on u.nom = 'Rachid'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1147
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Rachid'
  where a.sharepoint_id = 1147
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1147
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1185, e.id, c.id, t.id, 'spot à changer', 'validee', u1.id, u2.id, timestamptz '2026-05-26', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '2eme étage' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602130907557'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1185
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1185
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1185
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1186, e.id, c.id, t.id, 'serrer le bras liseuse côté gauche', 'validee', u1.id, u2.id, timestamptz '2026-05-26', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602104100283'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1186
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1186
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1186
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1187, e.id, c.id, t.id, 'serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2026-05-26', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602104100283'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1187
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1187
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1187
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1188, e.id, c.id, t.id, 'lit cassé côté gauche', 'validee', u1.id, u2.id, timestamptz '2026-05-26', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit cassé côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602104100283'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1188
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1188
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1188
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1136, e.id, c.id, t.id, 'La chasse d''eau ne fonctionne pas', 'validee', u1.id, u2.id, timestamptz '2026-05-20', '2026-05-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'La chasse d''eau ne fonctionne pas'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1136
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1136
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1136
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1137, e.id, c.id, t.id, 'Faire la pose du Lino afin d''éviter toute fuite en chambre 41', 'a_faire', u1.id, u2.id, timestamptz '2026-05-20', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Faire la pose du Lino afin d''éviter toute fuite en chambre 41'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1138, e.id, c.id, t.id, 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', 'validee', u1.id, u2.id, timestamptz '2026-05-20', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1138
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1138
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1138
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1139, e.id, c.id, t.id, 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', 'validee', u1.id, u2.id, timestamptz '2026-05-20', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1139
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1139
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1139
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1140, e.id, c.id, t.id, 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', 'validee', u1.id, u2.id, timestamptz '2026-05-20', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1140
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1140
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1140
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1141, e.id, c.id, t.id, 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', 'validee', u1.id, u2.id, timestamptz '2026-05-20', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '15' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1141
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1141
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1141
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1142, e.id, c.id, t.id, 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', 'validee', u1.id, u2.id, timestamptz '2026-05-20', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'SERAFINO · 20/05/2026 Joint défaillant côté mur droit', 'utilisateur', u.id, timestamptz '2026-05-20'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 1142
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'SERAFINO · 20/05/2026 Joint défaillant côté mur droit');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1142
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1142
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1142
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1143, e.id, c.id, t.id, 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', 'validee', u1.id, u2.id, timestamptz '2026-05-20', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1143
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1143
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1143
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1182, e.id, c.id, t.id, 'serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2026-05-20', '2026-05-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1182
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1182
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1182
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1183, e.id, c.id, t.id, 'Joint de silicone à enlever pour ensuite poser des nouveaux au niveau du bac à douche', 'validee', u1.id, u2.id, timestamptz '2026-05-20', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Joint de silicone à enlever pour ensuite poser des nouveaux au niveau du bac à douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1183
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1183
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1183
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1184, e.id, c.id, t.id, 'voir avec miroitier pour miroir placard cassé en bas (grand)', 'a_faire', u1.id, u2.id, timestamptz '2026-05-20', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'voir avec miroitier pour miroir placard cassé en bas (grand)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1093, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-19', '2026-05-19'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '15' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-19', timestamptz '2026-05-19'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1093
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1093
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1093
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1102, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-19', '2026-05-19'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-19', timestamptz '2026-05-19'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1102
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1102
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1102
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1110, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-19', '2026-05-19'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '41' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-19', timestamptz '2026-05-19'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1110
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1110
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1110
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1112, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-19', '2026-05-19'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '44' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-19', timestamptz '2026-05-19'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1112
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1112
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1112
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1114, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-19', '2026-05-19'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-19', timestamptz '2026-05-19'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1114
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1114
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1114
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1126, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-19', '2026-05-19'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Parties communes' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Localisation d''origine : Bureau', 'reprise', u.id, timestamptz '2026-05-19'
  from anomalies a left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1126
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Localisation d''origine : Bureau');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-19', timestamptz '2026-05-19'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1126
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1126
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1126
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1087, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1087
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1087
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1087
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1088, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '02' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1088
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1088
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1088
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1089, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1089
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1089
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1089
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1090, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1090
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1090
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1090
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1091, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1091
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1091
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1091
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1092, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1092
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1092
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1092
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1094, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1094
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1094
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1094
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1095, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1095
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1095
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1095
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1096, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '21' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1096
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1096
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1096
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1097, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1097
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1097
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1097
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1098, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1098
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1098
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1098
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1099, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1099
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1099
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1099
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1100, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '26' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1100
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1100
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1100
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1101, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1101
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1101
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1101
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1103, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '31' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1103
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1103
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1103
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1104, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '32' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1104
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1104
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1104
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1105, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '34' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1105
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1105
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1105
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1106, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1106
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1106
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1106
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1107, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1107
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1107
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1107
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1108, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1108
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1108
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1108
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1109, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1109
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1109
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1109
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1111, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1111
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1111
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1111
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1113, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1113
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1113
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1113
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1115, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1115
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1115
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1115
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1116, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1116
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1116
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1116
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1117, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1117
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1117
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1117
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1118, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1118
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1118
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1118
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1119, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '55' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1119
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1119
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1119
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1120, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1120
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1120
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1120
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1121, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1121
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1121
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1121
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1122, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1122
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1122
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1122
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1123, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1123
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1123
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1123
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1124, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Salle de sport' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1124
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1124
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1124
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1130, e.id, c.id, t.id, 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', u1.id, u2.id, timestamptz '2026-05-18', '2026-05-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage des filtres prévu dans le contrat avec Avir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-18', timestamptz '2026-05-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien AVIR'
  where a.sharepoint_id = 1130
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1130
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1130
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1081, e.id, c.id, t.id, 'cale porte à refixer (la piece est encore dans la chambre)', 'a_faire', u1.id, u2.id, timestamptz '2026-05-16', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'cale porte à refixer (la piece est encore dans la chambre)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1080, e.id, c.id, t.id, 'Fuite au niveau du lave-vaisselle', 'en_cours', u1.id, u2.id, timestamptz '2026-05-15', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Fuite au niveau du lave-vaisselle'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Cuisine' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Après le depart de Serafino le 15/05/26, la fuite est revenue. Le 16/05/26 Serafino est de nouveau intervenu et il pense que la fuite à cause de la pompe', 'utilisateur', u.id, timestamptz '2026-05-15'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1080
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Après le depart de Serafino le 15/05/26, la fuite est revenue. Le 16/05/26 Serafino est de nouveau intervenu et il pense que la fuite à cause de la pompe');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-15', timestamptz '2026-05-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260515181906844'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1080
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1080
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1080
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1046, e.id, c.id, t.id, 'changer connecteur lumiéres miroir sdb', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'changer connecteur lumiéres miroir SDB'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1047, e.id, c.id, t.id, 'urgent - joints sillicone douche - lavabo et wc à refaire complètement', 'validee', u1.id, u2.id, timestamptz '2026-05-14', '2026-06-15'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'urgent - joints sillicone douche - lavabo et wc à refaire complètement'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '44' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615121923728'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1047
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1047
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1047
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1048, e.id, c.id, t.id, 'lit côté gauche cassé', 'validee', u1.id, u2.id, timestamptz '2026-05-14', '2026-06-15'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté gauche cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '02' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615121923728'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1048
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1048
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1048
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1049, e.id, c.id, t.id, 'miroir plateau à changé', 'en_cours', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Miroir plateau à changé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '32' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'SERAFINO · 20/05/2026 Serafino a cassé le miroir', 'utilisateur', u.id, timestamptz '2026-05-14'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1049
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'SERAFINO · 20/05/2026 Serafino a cassé le miroir');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1049
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1049
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1049
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1050, e.id, c.id, t.id, 'miroir plateau à changé', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Miroir plateau à changé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1051, e.id, c.id, t.id, 'bouton mitigeur douche manquant', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'bouton mitigeur douche manquant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '02' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1052, e.id, c.id, t.id, 'bouton mitigeur douche manquant', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'bouton mitigeur douche manquant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '26' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1053, e.id, c.id, t.id, 'bouton mitigeur douche manquant', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'bouton mitigeur douche manquant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1054, e.id, c.id, t.id, 'urgent - joints sillicone douche - lavabo et wc à refaire complètement', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'urgent - joints sillicone douche - lavabo et wc à refaire complètement'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615131234028'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1054
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1054
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1054
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1055, e.id, c.id, t.id, 'urgent - joints sillicone douche - lavabo et wc à refaire complètement', 'validee', u1.id, u2.id, timestamptz '2026-05-14', '2026-01-07'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'urgent - joints sillicone douche - lavabo et wc à refaire complètement'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '46' on conflict (sharepoint_id) do nothing;

alter table validations enable trigger tg_validation_maj_anomalie;
commit;
