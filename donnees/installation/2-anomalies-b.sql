-- Généré par outils/importer_anomalies.py — ne pas modifier à la main.
-- Import de la liste « TEST Tech 3 » vers anomalies / tournees /
-- interventions / validations. Rejouable : rien n'est inséré deux fois.
-- Morceau 2 sur 5 — à jouer dans l'ordre des lettres.

begin;
alter table validations disable trigger tg_validation_maj_anomalie;

insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-25', timestamptz '2026-06-25'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260625142445177'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1055
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-25'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1055
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-01-07'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1055
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1056, e.id, c.id, t.id, 'urgent - joints sillicone douche - lavabo et wc à refaire complètement', 'validee', u1.id, u2.id, timestamptz '2026-05-14', '2026-06-15'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'urgent - joints sillicone douche - lavabo et wc à refaire complètement'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615121923728'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1056
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1056
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1056
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1057, e.id, c.id, t.id, 'bouton mitigeur douche manquant', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'bouton mitigeur douche manquant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1059, e.id, c.id, t.id, 'serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2026-05-14', '2026-05-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1059
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1059
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1059
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1060, e.id, c.id, t.id, 'serrer le bras liseuse côté gauche', 'validee', u1.id, u2.id, timestamptz '2026-05-14', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1060
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1060
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1060
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1061, e.id, c.id, t.id, 'difficulté à fermer la porte de chambre -', 'validee', u1.id, u2.id, timestamptz '2026-05-14', '2026-05-15'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'difficulté à fermer la porte de chambre -'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-15', timestamptz '2026-05-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260515181906844'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1061
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1061
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1061
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1062, e.id, c.id, t.id, 'lit côté gauche cassé', 'validee', u1.id, u2.id, timestamptz '2026-05-14', '2026-06-15'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté gauche cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615121923728'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1062
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1062
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1062
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1063, e.id, c.id, t.id, 'bouton mitigeur douche manquant', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'bouton mitigeur douche manquant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1064, e.id, c.id, t.id, 'bouton mitigeur douche manquant', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'bouton mitigeur douche manquant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '15' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1065, e.id, c.id, t.id, 'Le scratch du rideau est défaillant', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Le scratch du rideau est défaillant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '41' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1066, e.id, c.id, t.id, 'Le scratch du rideau est défaillant (SDB)', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Le scratch du rideau est défaillant (SDB)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1067, e.id, c.id, t.id, 'Bruit provenant du panneau électrique', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Bruit provenant du panneau électrique'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '31' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1068, e.id, c.id, t.id, 'Il manque des crochets pour faire tenir le rideau', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il manque des crochets pour faire tenir le rideau'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1069, e.id, c.id, t.id, 'Il manque des crochets pour faire tenir le rideau', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il manque des crochets pour faire tenir le rideau'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1070, e.id, c.id, t.id, 'Il manque des crochets pour faire tenir le rideau', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il manque des crochets pour faire tenir le rideau'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1071, e.id, c.id, t.id, 'Vérifier s''il ne faut pas changer entièrement la colonne de douche', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vérifier s''il ne faut pas changer entièrement la colonne de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1072, e.id, c.id, t.id, 'Vérifier s''il ne faut pas changer entièrement la colonne de douche', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vérifier s''il ne faut pas changer entièrement la colonne de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1073, e.id, c.id, t.id, 'Vérifier s''il ne faut pas changer entièrement la colonne de douche', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vérifier s''il ne faut pas changer entièrement la colonne de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'MIGUEL · 16/06/2026 ont a changé les flexible et pompe', 'utilisateur', u.id, timestamptz '2026-05-14'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1073
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'MIGUEL · 16/06/2026 ont a changé les flexible et pompe');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-16', timestamptz '2026-06-16'
  from anomalies a
  left join tournees t on t.reference = 'INT-Miguel-20260616153517575'
  left join utilisateurs u on u.nom = 'Miguel'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1073
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1073
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1073
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1074, e.id, c.id, t.id, 'Vérifier s''il ne faut pas changer entièrement la colonne de douche', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vérifier s''il ne faut pas changer entièrement la colonne de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1076, e.id, c.id, t.id, 'Moisissure présente sans la salle de bain', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Moisissure présente sans la salle de bain'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1077, e.id, c.id, t.id, 'Moisissure présente sans la salle de bain', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Moisissure présente sans la salle de bain'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1078, e.id, c.id, t.id, 'Moisissure présente sans la salle de bain', 'a_faire', u1.id, u2.id, timestamptz '2026-05-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Moisissure présente sans la salle de bain'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1043, e.id, c.id, t.id, 'lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2026-05-13', '2026-06-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615131234028'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1043
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1043
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1043
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1044, e.id, c.id, t.id, 'Toilettes bouchés', 'validee', u1.id, u2.id, timestamptz '2026-05-13', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Toilettes bouchés'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'WC Clients' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-13', timestamptz '2026-05-13'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260513173803397'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1044
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1044
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1044
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1045, e.id, c.id, t.id, 'Il faut fixer la barre de douche au support mural', 'validee', u1.id, u2.id, timestamptz '2026-05-13', '2026-05-19'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il faut fixer la barre de douche au support mural'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-13', timestamptz '2026-05-13'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260513173803397'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1045
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1045
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-19'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1045
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1041, e.id, c.id, t.id, 'batterie du bloc secours changé (celui au dessus de la porte d''entrée)', 'a_faire', u1.id, u2.id, timestamptz '2026-11-05', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'batterie du bloc secours changé (celui au dessus de la porte d''entrée)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '32' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1042, e.id, c.id, t.id, 'lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2026-11-05', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '32' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-13', timestamptz '2026-05-13'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260513173803397'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1042
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1042
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1042
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1039, e.id, c.id, t.id, 'Fuite au niveau du spot dans la douche', 'en_cours', u1.id, u2.id, timestamptz '2026-10-05', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Fuite au niveau du spot dans la douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '41' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Le 11/05/26 : Serafino a constaté que la fuite était à cause du bac de douche de la chambre 51 - La prochaine fois il va confirmer si la fuite est encore d’actualité', 'utilisateur', u.id, timestamptz '2026-10-05'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1039
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Le 11/05/26 : Serafino a constaté que la fuite était à cause du bac de douche de la chambre 51 - La prochaine fois il va confirmer si la fuite est encore d’actualité');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1040, e.id, c.id, t.id, 'flexible douche à changer', 'validee', u1.id, u2.id, timestamptz '2026-10-05', '2026-05-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = 'WC Clients' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1040
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1040
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1040
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1038, e.id, c.id, t.id, 'flexible fuit au niveau du pommeau de douche', 'validee', u1.id, u2.id, timestamptz '2026-07-05', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible fuit au niveau du pommeau de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-11-05', timestamptz '2026-11-05'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511114443975'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1038
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-11-05'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1038
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1038
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1033, e.id, c.id, t.id, 'La base du fauteuil doit être visée', 'a_faire', u1.id, u2.id, timestamptz '2026-04-05', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'La base du fauteuil doit être visée'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Miguel a enlevé la base et l''a rangé dans le local technique', 'utilisateur', u.id, timestamptz '2026-04-05'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1033
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Miguel a enlevé la base et l''a rangé dans le local technique');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1037, e.id, c.id, t.id, 'Pièce qui sert à ajuster la hauteur du pommeau de douche à viser', 'validee', u1.id, u2.id, timestamptz '2026-04-05', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Pièce qui sert à ajuster la hauteur du pommeau de douche à viser'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'La pièce à viser est dans le local technique', 'utilisateur', u.id, timestamptz '2026-04-05'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1037
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'La pièce à viser est dans le local technique');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602123616656'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1037
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1037
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1037
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1036, e.id, c.id, t.id, 'changement du séche cheveux', 'validee', u1.id, u2.id, timestamptz '2026-03-05', '2026-03-05'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement du séche cheveux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-03-05', timestamptz '2026-03-05'
  from anomalies a
  left join tournees t on t.reference = 'INT-Miguel-20260503135251788'
  left join utilisateurs u on u.nom = 'Miguel'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1036
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-03-05'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1036
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-03-05'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1036
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1034, e.id, c.id, t.id, 'spot à changer (le premier devant la porte d’entrée)', 'validee', u1.id, u2.id, timestamptz '2026-04-29', '2026-04-29'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'spot à changer (le premier devant la porte d’entrée)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-29', timestamptz '2026-04-29'
  from anomalies a
  left join tournees t on t.reference = 'INT-ALAIN-20260429160344684'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 1034
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1034
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1034
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1035, e.id, c.id, t.id, 'spot à changer (celui en face de la fenêtre et a cote de l''enceinte Bose)', 'a_faire', u1.id, u2.id, timestamptz '2026-04-29', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'spot à changer (celui en face de la fenêtre et a cote de l''enceinte Bose)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1028, e.id, c.id, t.id, 'Fuite constatée au niveau du deuxième lustre.', 'en_cours', u1.id, u2.id, timestamptz '2026-04-27', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Fuite constatée au niveau du deuxième lustre.'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'PDJ' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1029, e.id, c.id, t.id, 'Il faut rattacher le support du lustre au plafond.', 'en_cours', u1.id, u2.id, timestamptz '2026-04-27', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il faut rattacher le support du lustre au plafond.'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'PDJ' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Sarah aimerait que les fils soient pas du tout voyants en attendant que le lustre soit installé de nouveau - A la demande de Marie, le lustre a été réinstallé mais le cache est retenu par du scotch parce que Serafino n''a pas réussi à le clipser (quelque chose gêne)', 'utilisateur', u.id, timestamptz '2026-04-27'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1029
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Sarah aimerait que les fils soient pas du tout voyants en attendant que le lustre soit installé de nouveau - A la demande de Marie, le lustre a été réinstallé mais le cache est retenu par du scotch parce que Serafino n''a pas réussi à le clipser (quelque chose gêne)');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-26', timestamptz '2026-04-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1029
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1029
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 1029
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1030, e.id, c.id, t.id, 'lit côté droit cassé', 'validee', u1.id, u2.id, timestamptz '2026-04-27', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lit côté droit cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602123353973'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1030
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1030
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1030
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1031, e.id, c.id, t.id, 'flexible douche à changer', 'validee', u1.id, u2.id, timestamptz '2026-04-27', '2026-04-27'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '26' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1031
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1031
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1031
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1027, e.id, c.id, t.id, 'urgent! priorite coffre à reprogrammer', 'a_faire', u1.id, u2.id, timestamptz '2026-04-24', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'urgent! priorite coffre à reprogrammer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1019, e.id, c.id, t.id, 'flexible douche qui fuit', 'validee', u1.id, u2.id, timestamptz '2026-04-21', '2026-04-27'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche qui fuit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1019
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1019
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1019
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1018, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', u1.id, u2.id, timestamptz '2026-04-20', '2026-04-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-22', timestamptz '2026-04-22'
  from anomalies a
  left join tournees t on t.reference = 'INT-LEGACY-Alain-20260422'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 1018
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-22'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1018
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1018
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1016, e.id, c.id, t.id, 'Pommeau de douche à changer', 'validee', u1.id, u2.id, timestamptz '2026-04-17', '2026-04-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Pommeau de douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Pommeau changé parce qu''il y avait des traces de calcaire', 'utilisateur', u.id, timestamptz '2026-04-17'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1016
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Pommeau changé parce qu''il y avait des traces de calcaire');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-17', timestamptz '2026-04-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Miguel'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1016
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1016
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1016
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1011, e.id, c.id, t.id, 'porte d''entrée qui ne se verouille pas - urgent', 'validee', u1.id, u2.id, timestamptz '2026-04-16', '2026-04-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'porte d''entrée qui ne se verouille pas - urgent'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-17', timestamptz '2026-04-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Miguel'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1011
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1011
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1011
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1012, e.id, c.id, t.id, 'porte d''entrée qui ne se verouille pas - urgent', 'validee', u1.id, u2.id, timestamptz '2026-04-16', '2026-04-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'porte d''entrée qui ne se verouille pas - urgent'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-17', timestamptz '2026-04-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Miguel'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1012
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1012
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1012
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1010, e.id, c.id, t.id, 'La prise derrière la télévision ne fonctionne pas (à confirmer)', 'a_faire', u1.id, u2.id, timestamptz '2026-04-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'La prise derrière la télévision ne fonctionne pas (à confirmer)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1009, e.id, c.id, t.id, 'lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2026-04-13', '2026-04-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-13', timestamptz '2026-04-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Miguel'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1009
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1009
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1009
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1008, e.id, c.id, t.id, 'prise arrachée du mur sdb', 'validee', u1.id, u2.id, timestamptz '2026-11-04', '2026-04-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'prise arrachée du mur sdb'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '15' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-16', timestamptz '2026-04-16'
  from anomalies a
  left join tournees t on t.reference = 'INT-LEGACY-Alain-20260416'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 1008
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1008
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1008
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1003, e.id, c.id, t.id, 'télérupteur à changer - spot et leds', 'validee', u1.id, u2.id, timestamptz '2026-09-04', '2026-04-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur à changer - spot et leds'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-16', timestamptz '2026-04-16'
  from anomalies a
  left join tournees t on t.reference = 'INT-LEGACY-Alain-20260416'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 1003
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1003
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1003
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1004, e.id, c.id, t.id, 'prise arrachée du mur sdb', 'validee', u1.id, u2.id, timestamptz '2026-09-04', '2026-04-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'prise arrachée du mur sdb'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-16', timestamptz '2026-04-16'
  from anomalies a
  left join tournees t on t.reference = 'INT-LEGACY-Alain-20260416'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 1004
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1004
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1004
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1005, e.id, c.id, t.id, 'lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2026-09-04', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1005
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1005
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1005
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1006, e.id, c.id, t.id, 'lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2026-09-04', '2026-04-27'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1006
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1006
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1006
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1007, e.id, c.id, t.id, 'lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2026-09-04', '2026-04-27'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '32' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1007
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1007
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1007
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1001, e.id, c.id, t.id, 'flexible douche qui fuit', 'validee', u1.id, u2.id, timestamptz '2026-05-04', '2026-04-27'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche qui fuit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1001
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1001
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1001
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1002, e.id, c.id, t.id, 'Flexible douche à changer', 'validee', u1.id, u2.id, timestamptz '2026-05-04', '2026-04-27'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Miguel à changé le flexible mais ça fuit encore', 'utilisateur', u.id, timestamptz '2026-05-04'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1002
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Miguel à changé le flexible mais ça fuit encore');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1002
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1002
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1002
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1000, e.id, c.id, t.id, 'serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2026-01-04', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602111132223'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 1000
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1000
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1000
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 985, e.id, c.id, t.id, 'refixer la liseuse de droite', 'validee', u1.id, u2.id, timestamptz '2026-03-31', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'refixer la liseuse de droite'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 985
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 985
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 985
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 986, e.id, c.id, t.id, 'barriere de douche à fixer', 'validee', u1.id, u2.id, timestamptz '2026-03-31', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'barriere de douche à fixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 986
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 986
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 986
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 987, e.id, c.id, t.id, 'refixer le miroir grossissant', 'a_faire', u1.id, u2.id, timestamptz '2026-03-31', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer le miroir grossissant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 988, e.id, c.id, t.id, 'serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2026-03-31', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602125318070'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 988
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 988
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 988
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 989, e.id, c.id, t.id, 'serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2026-03-31', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-11-05', timestamptz '2026-11-05'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511114443975'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 989
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-11-05'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 989
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 989
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 990, e.id, c.id, t.id, 'serrer le bras liseuse côté gauche', 'validee', u1.id, u2.id, timestamptz '2026-03-31', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-11-05', timestamptz '2026-11-05'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511114443975'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 990
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-11-05'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 990
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 990
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 991, e.id, c.id, t.id, 'serrer le bras liseuse côté gauche', 'validee', u1.id, u2.id, timestamptz '2026-03-31', '2026-04-27'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '55' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 991
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 991
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 991
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 992, e.id, c.id, t.id, 'remplacement bras de liseuse (coté gauche)', 'validee', u1.id, u2.id, timestamptz '2026-03-31', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacement bras de liseuse (coté gauche)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 992
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 992
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 992
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 993, e.id, c.id, t.id, 'serrer le bras liseuse côté gauche', 'validee', u1.id, u2.id, timestamptz '2026-03-31', '2026-04-27'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 993
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 993
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 993
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 994, e.id, c.id, t.id, 'serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2026-03-31', '2026-04-27'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 994
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 994
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 994
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 996, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', u1.id, u2.id, timestamptz '2026-03-31', '2026-04-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-16', timestamptz '2026-04-16'
  from anomalies a
  left join tournees t on t.reference = 'INT-LEGACY-Alain-20260416'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 996
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 996
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 996
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 998, e.id, c.id, t.id, 'Sport à changer', 'a_faire', u1.id, u2.id, timestamptz '2026-03-31', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Sport à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'WC Clients' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 999, e.id, c.id, t.id, 'Spot à changer', 'a_faire', u1.id, u2.id, timestamptz '2026-03-31', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = 'WC Hommes' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 984, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', u1.id, u2.id, timestamptz '2026-03-30', '2026-04-22'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Fait par Alain le 16/04/26 mais il faut toujours deux cartes pour que ça fonctionne', 'utilisateur', u.id, timestamptz '2026-03-30'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 984
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Fait par Alain le 16/04/26 mais il faut toujours deux cartes pour que ça fonctionne');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-22', timestamptz '2026-04-22'
  from anomalies a
  left join tournees t on t.reference = 'INT-LEGACY-Alain-20260422'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 984
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-22'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 984
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-22'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 984
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 979, e.id, c.id, t.id, 'refixer la liseuse de droite', 'validee', u1.id, u2.id, timestamptz '2026-03-24', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'refixer la liseuse de droite'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 979
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 979
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 979
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 981, e.id, c.id, t.id, 'Fuite depuis joint d’évacuation en dessous d’évier', 'validee', u1.id, u2.id, timestamptz '2026-03-24', '2026-03-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Fuite depuis joint d’évacuation en dessous d’évier'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '41' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-03-24', timestamptz '2026-03-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 981
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-03-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 981
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-03-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 981
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 982, e.id, c.id, t.id, 'Fuite depuis joint d’évacuation en dessous d’évier', 'validee', u1.id, u2.id, timestamptz '2026-03-24', '2026-05-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Fuite depuis joint d’évacuation en dessous d’évier'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-20', timestamptz '2026-05-20'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260520160006749'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 982
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 982
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 982
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 980, e.id, c.id, t.id, 'Fuite depuis joint d’évacuation en dessous d’évier', 'validee', u1.id, u2.id, timestamptz '2026-03-23', '2026-03-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Fuite depuis joint d’évacuation en dessous d’évier'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-03-24', timestamptz '2026-03-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 980
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-03-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 980
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-03-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 980
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 975, e.id, c.id, t.id, 'télérupteur à changer - appliques murales sautent', 'validee', u1.id, u2.id, timestamptz '2026-10-03', '2026-04-27'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur à changer - appliques murales sautent'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-22', timestamptz '2026-04-22'
  from anomalies a
  left join tournees t on t.reference = 'INT-LEGACY-Alain-20260422'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 975
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-22'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 975
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 975
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 976, e.id, c.id, t.id, 'spot à changer', 'validee', u1.id, u2.id, timestamptz '2026-10-03', '2026-03-31'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = 'Réception' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-03-17', timestamptz '2026-03-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 976
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-03-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 976
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-03-31'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 976
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 974, e.id, c.id, t.id, 'refixer la prise', 'validee', u1.id, u2.id, timestamptz '2026-08-03', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'refixer la prise'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-11-05', timestamptz '2026-11-05'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511114443975'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 974
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-11-05'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 974
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 974
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1086, e.id, c.id, t.id, 'La serrure électronique de chez dormakaba ne fonctionne plus', 'validee', u1.id, u2.id, timestamptz '2026-02-26', '2026-06-03'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'La serrure électronique de chez dormakaba ne fonctionne plus'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Après une assistance téléphonique infructueuse. Nous avons du faire venir un serrurier qui travaillait anciennement chez dormakaba qui a réparer le problème', 'utilisateur', u.id, timestamptz '2026-02-26'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1086
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Après une assistance téléphonique infructueuse. Nous avons du faire venir un serrurier qui travaillait anciennement chez dormakaba qui a réparer le problème');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-03', timestamptz '2026-06-03'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 1086
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-03'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1086
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1127, e.id, c.id, t.id, 'Visite contractuelle afin de vérifier si tout fonctionne correctement - Kone', 'validee', u1.id, u2.id, timestamptz '2026-02-26', '2026-02-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Visite contractuelle afin de vérifier si tout fonctionne correctement - Kone'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Ascenseur' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Passage effectué de 11h40 à 11h45 - Rien à signaler', 'utilisateur', u.id, timestamptz '2026-02-26'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 1127
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Passage effectué de 11h40 à 11h45 - Rien à signaler');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-26', timestamptz '2026-02-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien Kone'
  where a.sharepoint_id = 1127
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1127
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 1127
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 949, e.id, c.id, t.id, 'Objet coincé dans la prise électrique', 'validee', u1.id, u2.id, timestamptz '2026-02-24', '2026-02-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Objet coincé dans la prise électrique'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-24', timestamptz '2026-02-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 949
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 949
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 949
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 950, e.id, c.id, t.id, 'Objet coincé dans la prise électrique', 'validee', u1.id, u2.id, timestamptz '2026-02-24', '2026-02-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Objet coincé dans la prise électrique'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-24', timestamptz '2026-02-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 950
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 950
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 950
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 946, e.id, c.id, t.id, 'Liseuse côté gauche à changer', 'validee', u1.id, u2.id, timestamptz '2026-02-23', '2026-02-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Liseuse côté gauche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-23', timestamptz '2026-02-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 946
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 946
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 946
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 947, e.id, c.id, t.id, 'Sol du bac de douche decoller (pour montrer à l''inspecteur) puis recoller de nouveau)', 'validee', u1.id, u2.id, timestamptz '2026-02-23', '2026-02-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Sol du bac de douche decoller (pour montrer à l''inspecteur) puis recoller de nouveau)'
  left join types_intervention t on t.code = 'PLOMBERIE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-23', timestamptz '2026-02-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 947
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 947
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 947
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 948, e.id, c.id, t.id, 'Sol du bac de douche decoller (pour montrer à l''inspecteur) puis recoller de nouveau)', 'validee', u1.id, u2.id, timestamptz '2026-02-23', '2026-02-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Sol du bac de douche decoller (pour montrer à l''inspecteur) puis recoller de nouveau)'
  left join types_intervention t on t.code = 'PLOMBERIE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-23', timestamptz '2026-02-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 948
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 948
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 948
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 900, e.id, c.id, t.id, 'tablette miroir cassée pendant le remplacement + casse du grand miroir intèrieur placard', 'a_faire', u1.id, u2.id, timestamptz '2026-05-02', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'tablette miroir cassée pendant le remplacement + casse du grand miroir intèrieur placard'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '32' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 901, e.id, c.id, t.id, 'Flexible à changer', 'validee', u1.id, u2.id, timestamptz '2026-05-02', '2026-05-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Flexible à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'WC Clients' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-02', timestamptz '2026-05-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'MR NEGRONI'
  where a.sharepoint_id = 901
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 901
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 901
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 977, e.id, c.id, t.id, 'Batterie du bloc secours à changer (celui en face de la sortie de secours)', 'validee', u1.id, u2.id, timestamptz '2026-05-02', '2026-03-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Batterie du bloc secours à changer (celui en face de la sortie de secours)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-03-17', timestamptz '2026-03-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 977
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-03-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 977
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-03-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 977
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 891, e.id, c.id, t.id, 'sol parquet abîmé – mettre pate à bois', 'validee', u1.id, u2.id, timestamptz '2026-01-29', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'sol parquet abîmé – mettre pate à bois'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 899, e.id, c.id, t.id, 'Neon salle de repos à changer', 'validee', u1.id, u2.id, timestamptz '2026-01-29', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Neon salle de repos à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Salle de repos' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 892, e.id, c.id, t.id, 'passer le produit sur le parquet ( même dessoous les bacs à plantes) - produit dans la bagagerie', 'en_cours', u1.id, u2.id, timestamptz '2026-01-27', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'passer le produit sur le parquet ( même dessoous les bacs à plantes) - produit dans la bagagerie'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'COUR intèrieure' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Fait le 17/03/26 par Serafino, une deuxieme couche doit être appliquée', 'utilisateur', u.id, timestamptz '2026-01-27'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 892
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Fait le 17/03/26 par Serafino, une deuxieme couche doit être appliquée');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 893, e.id, c.id, t.id, 'flexible de douche à changer', 'validee', u1.id, u2.id, timestamptz '2026-01-23', '2026-05-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible de douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '02' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Nouveau flexible acheter par Serafino', 'utilisateur', u.id, timestamptz '2026-01-23'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 893
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Nouveau flexible acheter par Serafino');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-02', timestamptz '2026-05-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 893
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 893
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 893
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 895, e.id, c.id, t.id, 'flexible de douche à changer', 'validee', u1.id, u2.id, timestamptz '2026-01-23', '2026-05-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible de douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Nouveau flexible acheter par Serafino', 'utilisateur', u.id, timestamptz '2026-01-23'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 895
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Nouveau flexible acheter par Serafino');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-02', timestamptz '2026-05-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 895
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 895
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 895
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 896, e.id, c.id, t.id, 'flexible de douche à changer', 'validee', u1.id, u2.id, timestamptz '2026-01-23', '2026-05-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible de douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Nouveau flexible acheter par Serafino', 'utilisateur', u.id, timestamptz '2026-01-23'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 896
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Nouveau flexible acheter par Serafino');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-02', timestamptz '2026-05-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 896
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 896
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 896
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 898, e.id, c.id, t.id, 'flexible douche qui fuit', 'validee', u1.id, u2.id, timestamptz '2026-01-23', '2026-02-06'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche qui fuit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'SERAFINO · 02/06/2026 ça déjà été fait lors d''un précédent passage', 'utilisateur', u.id, timestamptz '2026-01-23'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 898
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'SERAFINO · 02/06/2026 ça déjà été fait lors d''un précédent passage');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-06', timestamptz '2026-02-06'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260602124118036'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 898
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 898
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-06'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 898
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 803, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-01-14', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 803
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 803
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 483, e.id, c.id, t.id, 'Changement flexible liseuse droite', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement flexible liseuse droite'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 483
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 483
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 492, e.id, c.id, t.id, 'Changement ampoule lampe bureau', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement ampoule lampe bureau'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, '1', 'utilisateur', u.id, timestamptz '2026-01-13'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 492
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = '1');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 492
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 492
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 504, e.id, c.id, t.id, 'Changement flexible liseuse droite', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement flexible liseuse droite'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 504
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 504
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 505, e.id, c.id, t.id, 'barre de pare douche à refixer', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'barre de pare douche à refixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 505
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 505
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 516, e.id, c.id, t.id, 'Changement flexible liseuse droite', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement flexible liseuse droite'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 516
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 516
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 517, e.id, c.id, t.id, 'Télérupteur appliques changé', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur appliques changé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 517
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 517
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 609, e.id, c.id, t.id, 'Miroir plateau à changé', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-05-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Miroir plateau à changé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-02', timestamptz '2026-05-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 609
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 609
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 609
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 632, e.id, c.id, t.id, 'Grand miroir côté armoire cassé', 'a_faire', u1.id, u2.id, timestamptz '2026-01-13', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Grand miroir côté armoire cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '41' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 643, e.id, c.id, t.id, 'spot chambre à remplacer', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'spot chambre à remplacer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 643
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 643
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 664, e.id, c.id, t.id, 'frein de chute abattant WC non fonctionnel -', 'a_acheter', u1.id, u2.id, timestamptz '2026-01-13', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'frein de chute abattant WC non fonctionnel -'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Acheter nouvel abattant', 'utilisateur', u.id, timestamptz '2026-01-13'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 664
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Acheter nouvel abattant');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 666, e.id, c.id, t.id, 'Cadre porte SDB bois - décollé du mur', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Cadre porte SDB bois - décollé du mur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 666
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 666
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 701, e.id, c.id, t.id, 'Miroir plateau à changé', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Miroir plateau à changé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-11-05', timestamptz '2026-11-05'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511114443975'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 701
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-11-05'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 701
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 701
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 702, e.id, c.id, t.id, 'Grand miroir côté armoire cassé', 'a_faire', u1.id, u2.id, timestamptz '2026-01-13', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Grand miroir côté armoire cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 703, e.id, c.id, t.id, 'spot chambre à remplacer', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'spot chambre à remplacer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 703
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 703
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 704, e.id, c.id, t.id, 'Lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Petite cuillère trouvée dans le siphon', 'utilisateur', u.id, timestamptz '2026-01-13'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 704
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Petite cuillère trouvée dans le siphon');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 704
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 704
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 725, e.id, c.id, t.id, 'Miroir plateau à changé', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-05-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Miroir plateau à changé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-02', timestamptz '2026-05-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 725
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 725
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 725
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 726, e.id, c.id, t.id, 'Changement support lait corporel', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'changement support lait corporel'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 726
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 726
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 762, e.id, c.id, t.id, 'Miroir plateau à changé', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-05-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Miroir plateau à changé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-02', timestamptz '2026-05-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 762
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 762
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 762
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 772, e.id, c.id, t.id, 'Lèvre de douche à changer sur le côté pare douche', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lèvre de douche à changer sur le côté pare douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '55' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 772
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 772
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 786, e.id, c.id, t.id, 'fuite mitigeur douche', 'a_acheter', u1.id, u2.id, timestamptz '2026-01-13', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'fuite mitigeur douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'voir stock B pour retrouver ref - @ Sarah le 6/01 et relance le 13/01', 'utilisateur', u.id, timestamptz '2026-01-13'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 786
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'voir stock B pour retrouver ref - @ Sarah le 6/01 et relance le 13/01');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 787, e.id, c.id, t.id, 'Lèvre de douche à changer sur le côté pare douche', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lèvre de douche à changer sur le côté pare douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 787
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 787
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 789, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 789
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 789
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 798, e.id, c.id, t.id, 'Refixer liseuse gauche', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer liseuse gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 798
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 798
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 799, e.id, c.id, t.id, 'poignée porte principale à resserrer', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'poignée porte principale à resserrer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 799
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 799
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 815, e.id, c.id, t.id, 'liseuse gauche à resserer', 'validee', u1.id, u2.id, timestamptz '2026-01-13', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'liseuse gauche à resserer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 815
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 815
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 775, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-12-01', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 775
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 775
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 845, e.id, c.id, t.id, 'Spot à changer', 'validee', u1.id, u2.id, timestamptz '2026-12-01', '2026-03-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-03-17', timestamptz '2026-03-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 845
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-03-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 845
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-03-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 845
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 764, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-11-01', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '55' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 764
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 764
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 746, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-10-01', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 746
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 746
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 727, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-09-01', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 727
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 727
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 588, e.id, c.id, t.id, 'Il faut changer la bouilloire', 'validee', u1.id, u2.id, timestamptz '2026-08-01', '2026-08-01'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il faut changer la bouilloire'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-08-01', timestamptz '2026-08-01'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 588
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-08-01'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 588
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 717, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-08-01', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 717
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 717
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 706, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-07-01', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 706
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 706
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 470, e.id, c.id, t.id, 'Sèche serviette à refixer -', 'validee', u1.id, u2.id, timestamptz '2026-06-01', '2026-05-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Sèche serviette à refixer -'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-02', timestamptz '2026-05-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 470
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 470
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 470
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 692, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-06-01', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 692
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 692
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 668, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-05-01', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 668
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 668
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 652, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-04-01', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 652
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 652
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 644, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-03-01', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '44' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 644
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 644
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 623, e.id, c.id, t.id, 'Serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2026-02-01', '2026-04-27'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 623
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 623
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 623
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 633, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-02-01', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 633
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 633
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 625, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2026-01-01', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '41' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 625
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 625
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 611, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-31', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 611
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 611
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 602, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-30', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 602
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 602
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 590, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-29', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 590
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 590
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 575, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-28', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 575
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 575
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 565, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-27', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '34' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 565
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 565
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');

alter table validations enable trigger tg_validation_maj_anomalie;
commit;
