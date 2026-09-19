-- Généré par outils/importer_anomalies.py — ne pas modifier à la main.
-- Import de la liste « TEST Tech 3 » vers anomalies / tournees /
-- interventions / validations. Rejouable : rien n'est inséré deux fois.
-- Morceau 3 sur 5 — à jouer dans l'ordre des lettres.

begin;
alter table validations disable trigger tg_validation_maj_anomalie;

insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 558, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-26', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '32' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 558
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 558
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 551, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-25', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '31' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 551
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 551
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 844, e.id, c.id, t.id, 'URGENT - Difficulté à fermer la porte qui mene à la cour', 'validee', u1.id, u2.id, timestamptz '2025-12-25', '2026-12-01'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'URGENT - Difficulté à fermer la porte qui mene à la cour'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-12-01', timestamptz '2026-12-01'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'MR NEGRONI'
  where a.sharepoint_id = 844
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-12-01'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 844
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 535, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-24', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 535
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 535
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 882, e.id, c.id, t.id, 'Serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2025-12-24', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'WC Femmes' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 882
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 882
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 398, e.id, c.id, t.id, 'Lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2025-12-23', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 398
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 398
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 456, e.id, c.id, t.id, 'Lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2025-12-23', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 456
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 456
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 471, e.id, c.id, t.id, 'Lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2025-12-23', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '21' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 471
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 471
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 472, e.id, c.id, t.id, 'Resserrer la poignée de la porte d''entrée', 'validee', u1.id, u2.id, timestamptz '2025-12-23', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Resserrer la poignée de la porte d''entrée'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '21' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 472
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 472
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 525, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-23', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 525
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 525
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 589, e.id, c.id, t.id, 'Lit côté droit cassé', 'validee', u1.id, u2.id, timestamptz '2025-12-23', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lit côté droit cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Au lieu de les agrafer ensemble, Mr Serafino les a viser', 'utilisateur', u.id, timestamptz '2025-12-23'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 589
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Au lieu de les agrafer ensemble, Mr Serafino les a viser');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 589
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 589
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 595, e.id, c.id, t.id, 'flexible liseuse côté droit à resserer', 'validee', u1.id, u2.id, timestamptz '2025-12-23', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté droit à resserer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 595
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 595
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 667, e.id, c.id, t.id, 'La poignée de la fenêtre s''enlève', 'validee', u1.id, u2.id, timestamptz '2025-12-23', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'La poignée de la fenêtre s''enlève'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 667
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 667
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 801, e.id, c.id, t.id, 'Lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2025-12-23', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 801
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 801
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 802, e.id, c.id, t.id, 'Serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2025-12-23', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 802
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 802
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 518, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-22', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '26' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 518
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 518
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 509, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-21', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 509
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 509
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 495, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-20', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 495
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 495
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 485, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-19', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 485
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 485
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 474, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-18', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '21' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 474
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 474
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 458, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-17', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 458
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 458
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 446, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-16', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 446
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 446
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 435, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-15', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '15' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 435
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 435
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 427, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-14', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 427
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 427
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 413, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-13', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 413
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 413
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 400, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-12-12', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 400
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 400
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 386, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-11-12', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 386
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 386
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1128, e.id, c.id, t.id, 'Ascenseur en panne - Il faut contacter KONE', 'validee', u1.id, u2.id, timestamptz '2025-11-12', '2025-11-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Ascenseur en panne - Il faut contacter KONE'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Ascenseur' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'L’ascenseur indiqué hors service et se trouvait bloqué au niveau 0. Il s’est ensuite remis à fonctionner, mais de manière aléatoire. J’ai donc choisi de le bloquer au niveau -1', 'utilisateur', u.id, timestamptz '2025-11-12'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1128
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'L’ascenseur indiqué hors service et se trouvait bloqué au niveau 0. Il s’est ensuite remis à fonctionner, mais de manière aléatoire. J’ai donc choisi de le bloquer au niveau -1');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-12', timestamptz '2025-11-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien Kone'
  where a.sharepoint_id = 1128
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1128
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2025-11-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1128
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 380, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-10-12', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '02' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 380
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 380
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 573, e.id, c.id, t.id, 'Refixer le miroir grossissant', 'a_faire', u1.id, u2.id, timestamptz '2025-10-12', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer le miroir grossissant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '34' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 622, e.id, c.id, t.id, 'Refixer le miroir grossissant', 'a_faire', u1.id, u2.id, timestamptz '2025-10-12', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer le miroir grossissant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 876, e.id, c.id, t.id, 'Fortes odeurs constaté au niveau de la colonne, il faut trouver une solution pour reboucher', 'validee', u1.id, u2.id, timestamptz '2025-10-12', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Fortes odeurs constaté au niveau de la colonne, il faut trouver une solution pour reboucher'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Sous-sol divers' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 876
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 876
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 370, e.id, c.id, t.id, 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', u1.id, u2.id, timestamptz '2025-09-12', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 370
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 370
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 379, e.id, c.id, t.id, 'Lit côté gauche cassé', 'validee', u1.id, u2.id, timestamptz '2025-09-12', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté gauche cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '02' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Au lieu de les agrafer ensemble, Mr Serafino les a viser', 'utilisateur', u.id, timestamptz '2025-09-12'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 379
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Au lieu de les agrafer ensemble, Mr Serafino les a viser');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 379
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 379
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 412, e.id, c.id, t.id, 'Spot à changer', 'validee', u1.id, u2.id, timestamptz '2025-09-12', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 412
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 412
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 484, e.id, c.id, t.id, 'Télérupteur à changer - spot et leds', 'validee', u1.id, u2.id, timestamptz '2025-09-12', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur à changer - spot et leds'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 484
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 484
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 506, e.id, c.id, t.id, 'Liseuse côté droit à changer', 'validee', u1.id, u2.id, timestamptz '2025-09-12', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Liseuse côté droit à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 507, e.id, c.id, t.id, 'Télérupteur à changer - spot et leds', 'validee', u1.id, u2.id, timestamptz '2025-09-12', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur à changer - spot et leds'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 507
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 507
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 508, e.id, c.id, t.id, 'Spot à changer', 'validee', u1.id, u2.id, timestamptz '2025-09-12', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 508
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 508
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 691, e.id, c.id, t.id, 'Télérupteur à changer - appliques murales sautent', 'validee', u1.id, u2.id, timestamptz '2025-09-12', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur à changer - appliques murales sautent'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 691
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 691
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 773, e.id, c.id, t.id, 'Télérupteur à changer - appliques murales sautent', 'validee', u1.id, u2.id, timestamptz '2025-09-12', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur à changer - appliques murales sautent'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 773
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 773
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 774, e.id, c.id, t.id, 'Spot à changer', 'validee', u1.id, u2.id, timestamptz '2025-09-12', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 774
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 774
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 788, e.id, c.id, t.id, 'Liseuse côté gauche à changer', 'validee', u1.id, u2.id, timestamptz '2025-09-12', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Liseuse côté gauche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 788
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 788
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 459, e.id, c.id, t.id, 'La poignée de la fenêtre s''enlève', 'validee', u1.id, u2.id, timestamptz '2025-02-12', '2025-03-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'La poignée de la fenêtre s''enlève'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-12', timestamptz '2025-03-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 459
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 459
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 462, e.id, c.id, t.id, 'Porte placard du haut à remettre / se trouve dans le local technique', 'a_faire', u1.id, u2.id, timestamptz '2025-02-12', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Porte placard du haut à remettre / se trouve dans le local technique'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 716, e.id, c.id, t.id, 'lit côté droit cassé - à agrafer', 'validee', u1.id, u2.id, timestamptz '2025-02-12', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté droit cassé - à agrafer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Au lieu de les agrafer ensemble, Mr Serafino les a viser', 'utilisateur', u.id, timestamptz '2025-02-12'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 716
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Au lieu de les agrafer ensemble, Mr Serafino les a viser');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 716
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 716
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 744, e.id, c.id, t.id, 'lit côté droit cassé - à agrafer', 'validee', u1.id, u2.id, timestamptz '2025-02-12', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté droit cassé - à agrafer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Au lieu de les agrafer ensemble, Mr Serafino les a viser', 'utilisateur', u.id, timestamptz '2025-02-12'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 744
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Au lieu de les agrafer ensemble, Mr Serafino les a viser');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 744
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 744
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 576, e.id, c.id, t.id, 'Changement du séche cheveux', 'validee', u1.id, u2.id, timestamptz '2025-11-25', '2025-11-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement du séche cheveux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-26', timestamptz '2025-11-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 576
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 576
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 396, e.id, c.id, t.id, 'Fuite au niveau du bac de douche', 'validee', u1.id, u2.id, timestamptz '2025-11-16', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Fuite au niveau du bac de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 396
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 396
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 469, e.id, c.id, t.id, 'flexible douche à changer', 'validee', u1.id, u2.id, timestamptz '2025-11-15', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 469
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 469
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 399, e.id, c.id, t.id, 'Resserrer la poignée', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Resserrer la poignée'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 399
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 399
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 447, e.id, c.id, t.id, 'La poignée de la fenêtre s''enlève', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-03-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'La poignée de la fenêtre s''enlève'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-12', timestamptz '2025-03-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 447
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 447
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 473, e.id, c.id, t.id, 'Télérupteur à changer - appliques murales sautent', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-09-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur à changer - appliques murales sautent'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '21' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-12', timestamptz '2025-09-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 473
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 473
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 493, e.id, c.id, t.id, 'barriere de douche à fixer', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2026-02-25'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'barriere de douche à fixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-25', timestamptz '2026-02-25'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 493
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-25'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 493
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-25'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 493
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 494, e.id, c.id, t.id, 'Lit côté droit cassé', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lit côté droit cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Au lieu de les agrafer ensemble, Mr Serafino les a viser', 'utilisateur', u.id, timestamptz '2025-11-11'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 494
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Au lieu de les agrafer ensemble, Mr Serafino les a viser');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 494
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 494
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 534, e.id, c.id, t.id, 'Plinthe de la fenêtre à recoller', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Plinthe de la fenêtre à recoller'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 534
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 534
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 548, e.id, c.id, t.id, 'Cache pile du coffre manquant', 'a_faire', u1.id, u2.id, timestamptz '2025-11-11', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Cache pile du coffre manquant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 574, e.id, c.id, t.id, 'Serrer le bras liseuse côté gauche', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 574
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 574
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 610, e.id, c.id, t.id, 'Serrer le bras liseuse côté gauche', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 610
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 610
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 626, e.id, c.id, t.id, 'Cale porte à refixer (la piece est encore dans la chambre)', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-03-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'cale porte à refixer (la piece est encore dans la chambre)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '41' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-12', timestamptz '2025-03-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 626
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 626
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 634, e.id, c.id, t.id, 'Refixer le miroir grossissant', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-03-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer le miroir grossissant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-12', timestamptz '2025-03-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 634
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 634
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 641, e.id, c.id, t.id, 'Bac de douche à changer - URGENT', 'en_cours', u1.id, u2.id, timestamptz '2025-11-11', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Bac de douche à changer - URGENT'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 642, e.id, c.id, t.id, 'fenêtre se ferme mal', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2026-01-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'fenêtre se ferme mal'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Changement de la poignée de fenêtre', 'utilisateur', u.id, timestamptz '2025-11-11'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 642
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Changement de la poignée de fenêtre');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-01-13', timestamptz '2026-01-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 642
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-01-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 642
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 689, e.id, c.id, t.id, 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)', 'a_faire', u1.id, u2.id, timestamptz '2025-11-11', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 700, e.id, c.id, t.id, 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)', 'a_faire', u1.id, u2.id, timestamptz '2025-11-11', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-11-05', timestamptz '2026-11-05'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511114443975'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 700
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-11-05'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 700
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 700
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 705, e.id, c.id, t.id, 'Lit côté droit cassé', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lit côté droit cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Au lieu de les agrafer ensemble, Mr Serafino les a viser', 'utilisateur', u.id, timestamptz '2025-11-11'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 705
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Au lieu de les agrafer ensemble, Mr Serafino les a viser');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 705
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 705
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 729, e.id, c.id, t.id, 'Il faut changer la bouilloire', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-11-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il faut changer la bouilloire'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-26', timestamptz '2025-11-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 729
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 729
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 743, e.id, c.id, t.id, 'barriere de douche à fixer', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2026-02-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'barriere de douche à fixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-02-23', timestamptz '2026-02-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 743
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-02-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 743
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-02-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 743
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 745, e.id, c.id, t.id, 'Liseuse côté droit à changer', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-03-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Liseuse côté droit à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-12', timestamptz '2025-03-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 745
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 745
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 763, e.id, c.id, t.id, 'Spot à changer - côté du miroir', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-03-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à changer - côté du miroir'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '55' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-12', timestamptz '2025-03-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 763
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 763
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 800, e.id, c.id, t.id, 'Serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-03-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-12', timestamptz '2025-03-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 800
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 800
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 820, e.id, c.id, t.id, 'Spot noir à changer - en face de la chambre 38', 'validee', u1.id, u2.id, timestamptz '2025-11-11', '2025-03-12'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot noir à changer - en face de la chambre 38'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '3eme étage' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-12', timestamptz '2025-03-12'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 820
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-12'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 820
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 825, e.id, c.id, t.id, 'Batterie du bloc secours à changer (celui en face de la chambre 48)', 'a_faire', u1.id, u2.id, timestamptz '2025-11-11', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Batterie du bloc secours à changer (celui en face de la chambre 48)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '4eme étage' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 826, e.id, c.id, t.id, 'Batterie du bloc secours à changer (celui en face de la chambre 58)', 'a_faire', u1.id, u2.id, timestamptz '2025-11-11', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Batterie du bloc secours à changer (celui en face de la chambre 58)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Palier 5ème' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 850, e.id, c.id, t.id, 'Il manque juste le petit papier qui va à l''interieur et non le cache', 'en_cours', u1.id, u2.id, timestamptz '2025-09-11', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il manque juste le petit papier qui va à l''interieur et non le cache'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Local TGBT' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 455, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', u1.id, u2.id, timestamptz '2025-07-11', '2026-04-22'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Hedi a "réparer l''économisseur" en recollant les piéces defaillantes à la colle forte. Aucun remplacement à été fait', 'utilisateur', u.id, timestamptz '2025-07-11'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 455
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Hedi a "réparer l''économisseur" en recollant les piéces defaillantes à la colle forte. Aucun remplacement à été fait');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-22', timestamptz '2026-04-22'
  from anomalies a
  left join tournees t on t.reference = 'INT-LEGACY-Alain-20260422'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 455
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-22'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 455
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-22'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 455
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 819, e.id, c.id, t.id, 'Batterie du bloc secours à changer (celui en face de la chambre 28)', 'validee', u1.id, u2.id, timestamptz '2025-03-11', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Batterie du bloc secours à changer (celui en face de la chambre 28)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '2eme étage' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Le 16/11/25 Hedi a changé une seule batterie sur les deux et pour l''instant tout semble en ordre - je n''ai pas modifé le stock parce que d''après lui la batterie fonctionne encore à confirmer', 'utilisateur', u.id, timestamptz '2025-03-11'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 819
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Le 16/11/25 Hedi a changé une seule batterie sur les deux et pour l''instant tout semble en ordre - je n''ai pas modifé le stock parce que d''après lui la batterie fonctionne encore à confirmer');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 819
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 819
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 615, e.id, c.id, t.id, 'flexible liseuse côté droit à changer', 'validee', u1.id, u2.id, timestamptz '2025-10-28', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté droit à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 615
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 615
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 616, e.id, c.id, t.id, 'flexible liseuse côté gauche à fixer', 'validee', u1.id, u2.id, timestamptz '2025-10-28', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté gauche à fixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 616
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 616
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 710, e.id, c.id, t.id, 'flexible liseuse côté gauche à fixer', 'validee', u1.id, u2.id, timestamptz '2025-10-28', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté gauche à fixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 710
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 710
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 728, e.id, c.id, t.id, 'flexible liseuse côté droit à changer', 'validee', u1.id, u2.id, timestamptz '2025-10-28', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté droit à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 728
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 728
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 824, e.id, c.id, t.id, 'Batterie du bloc secours à changer (celui en face de la chambre 44)', 'validee', u1.id, u2.id, timestamptz '2025-10-22', '2025-10-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Batterie du bloc secours à changer (celui en face de la chambre 44)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '4eme étage' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-10-23', timestamptz '2025-10-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien TELEC'
  where a.sharepoint_id = 824
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-10-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 824
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 784, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', u1.id, u2.id, timestamptz '2025-10-17', '2026-04-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Hedi passage le 16/11 mais ne fonctionne toujorus pas', 'utilisateur', u.id, timestamptz '2025-10-17'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 784
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Hedi passage le 16/11 mais ne fonctionne toujorus pas');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-16', timestamptz '2026-04-16'
  from anomalies a
  left join tournees t on t.reference = 'INT-LEGACY-Alain-20260416'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 784
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 784
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 784
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 376, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 376
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 376
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 376
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 384, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '02' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 384
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 384
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 384
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 394, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 394
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 394
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 394
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 407, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 407
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 407
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 407
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 420, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 420
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 420
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 420
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 433, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 433
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 433
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 433
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 444, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '15' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 444
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 444
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 444
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 452, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 452
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 452
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 452
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 465, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 465
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 465
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 465
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 480, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '21' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 480
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 480
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 480
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 488, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 488
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 488
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 488
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 500, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 500
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 500
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 500
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 514, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 514
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 514
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 514
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 520, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '26' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 520
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 520
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 520
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 527, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 527
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 527
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 527
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 542, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 542
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 542
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 542
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 556, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '31' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 556
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 556
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 556
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 563, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '32' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 563
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 563
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 563
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 570, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '34' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 570
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 570
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 570
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 581, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 581
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 581
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 581
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 597, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 597
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 597
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 597
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 605, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 605
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 605
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 605
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 618, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 618
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 618
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 618
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 631, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '41' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 631
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 631
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 631
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 640, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 640
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 640
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 640
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 648, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '44' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 648
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 648
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 648
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 661, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 661
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 661
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 661
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 681, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 681
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 681
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 681
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 697, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 697
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 697
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 697
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 713, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 713
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 713
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 713
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 722, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 722
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 722
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 722
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 736, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 736
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 736
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 736
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 759, e.id, c.id, t.id, 'Détection de punaises de lit au niveau de la tête de lit constaté le 30/09/25 par la societe Ecoflair', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-01-10'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Détection de punaises de lit au niveau de la tête de lit constaté le 30/09/25 par la societe Ecoflair'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Le 30/09/25 - Punaises constaté au niveau de la tête de lit - Le 01/10/25 Rachid a fait un traitement', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 759
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Le 30/09/25 - Punaises constaté au niveau de la tête de lit - Le 01/10/25 Rachid a fait un traitement');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-10', timestamptz '2025-01-10'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Rachid'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 759
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-10'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Rachid'
  where a.sharepoint_id = 759
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 760, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - Punaises constaté au niveau de la tête de lit', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 760
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - Punaises constaté au niveau de la tête de lit');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 760
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 760
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 769, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '55' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 769
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 769
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 769
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 782, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 782
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 782
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 782
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 795, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 795
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 795
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 795
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 811, e.id, c.id, t.id, 'Demande de vérification s''il y a la présence de punaises', 'validee', u1.id, u2.id, timestamptz '2025-09-30', '2025-09-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Demande de vérification s''il y a la présence de punaises'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Détection de punaises par la société Ecoflair - RAS', 'utilisateur', u.id, timestamptz '2025-09-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 811
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Détection de punaises par la société Ecoflair - RAS');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-30', timestamptz '2025-09-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'EcoFlair'
  where a.sharepoint_id = 811
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 811
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 510, e.id, c.id, t.id, 'Coffre fort HS', 'validee', u1.id, u2.id, timestamptz '2025-09-28', '2025-03-11'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Coffre fort HS'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Marie le prend chez Europroh dans les jours à venir - devis en cours', 'utilisateur', u.id, timestamptz '2025-09-28'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 510
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Marie le prend chez Europroh dans les jours à venir - devis en cours');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-11', timestamptz '2025-03-11'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien EUROPROH'
  where a.sharepoint_id = 510
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-11'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 510
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 385, e.id, c.id, t.id, 'Serrer le bras liseuse côté gauche', 'validee', u1.id, u2.id, timestamptz '2025-09-26', '2025-09-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-26', timestamptz '2025-09-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 385
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 385
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 503, e.id, c.id, t.id, 'Lit côté gauche cassé', 'validee', u1.id, u2.id, timestamptz '2025-09-26', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté gauche cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'pas d''agrafeuse lors du passage du 18/09 - attente prochain passage', 'utilisateur', u.id, timestamptz '2025-09-26'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 503
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'pas d''agrafeuse lors du passage du 18/09 - attente prochain passage');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 503
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 503
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 550, e.id, c.id, t.id, 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)', 'validee', u1.id, u2.id, timestamptz '2025-09-26', '2025-09-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '31' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-26', timestamptz '2025-09-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 550
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 550
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 843, e.id, c.id, t.id, 'Nettoyage du tuyau d''évacuation du séche linge', 'validee', u1.id, u2.id, timestamptz '2025-09-26', '2025-09-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Nettoyage du tuyau d''évacuation du séche linge'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lingerie' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-26', timestamptz '2025-09-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 843
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 843
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 693, e.id, c.id, t.id, 'Il faut changer la bouilloire', 'validee', u1.id, u2.id, timestamptz '2025-09-22', '2025-09-22'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il faut changer la bouilloire'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-22', timestamptz '2025-09-22'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 693
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-22'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 693
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 686, e.id, c.id, t.id, 'Flexible de douche à changer', 'validee', u1.id, u2.id, timestamptz '2025-09-18', '2026-06-15'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible de douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'selon Hedi, l''eau coule toujours car il faudrait changer tout le mitigeur, pas juste le flexible - passage du 18.09', 'utilisateur', u.id, timestamptz '2025-09-18'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 686
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'selon Hedi, l''eau coule toujours car il faudrait changer tout le mitigeur, pas juste le flexible - passage du 18.09');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615121923728'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 686
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 686
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 686
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 823, e.id, c.id, t.id, 'Batterie du bloc secours à changer (celui en face de l''ascenseur)', 'validee', u1.id, u2.id, timestamptz '2025-09-17', '2025-10-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Batterie du bloc secours à changer (celui en face de l''ascenseur)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '4eme étage' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-10-23', timestamptz '2025-10-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien TELEC'
  where a.sharepoint_id = 823
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-10-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 823
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 676, e.id, c.id, t.id, 'télérupteur pour spots plafond à changer', 'validee', u1.id, u2.id, timestamptz '2025-12-09', '2025-12-09'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'télérupteur pour spots plafond à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Erreur lors de la commande du 09/09/25 - Télérupteur électrique au lieu de mécaniques', 'utilisateur', u.id, timestamptz '2025-12-09'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 676
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Erreur lors de la commande du 09/09/25 - Télérupteur électrique au lieu de mécaniques');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-09', timestamptz '2025-12-09'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 676
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-09'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 676
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 816, e.id, c.id, t.id, 'Spot à coté de l''ascenseur à changer', 'validee', u1.id, u2.id, timestamptz '2025-12-09', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à coté de l''ascenseur à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Palier 1er' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 463, e.id, c.id, t.id, 'Spot plafond au fond à changer', 'validee', u1.id, u2.id, timestamptz '2025-11-09', '2025-12-09'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot plafond au fond à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-09', timestamptz '2025-12-09'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 463
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-09'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 463
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 536, e.id, c.id, t.id, 'Cadre de la porte de la salle de bain à fixer', 'validee', u1.id, u2.id, timestamptz '2025-11-09', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Cadre de la porte de la salle de bain à fixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 536
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 536
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 547, e.id, c.id, t.id, 'Lumiéres miroir SDB', 'validee', u1.id, u2.id, timestamptz '2025-11-09', '2026-04-29'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lumiéres miroir SDB'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'prévoir le changement du connecteur de raccordement car ne tient plus - Le 26/09/25 Hedi ne constacte aucun probléme à confirmer', 'utilisateur', u.id, timestamptz '2025-11-09'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 547
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'prévoir le changement du connecteur de raccordement car ne tient plus - Le 26/09/25 Hedi ne constacte aucun probléme à confirmer');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-29', timestamptz '2026-04-29'
  from anomalies a
  left join tournees t on t.reference = 'INT-ALAIN-20260429160344684'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 547
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 547
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 547
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 587, e.id, c.id, t.id, 'télécommande CLIM à remplacer', 'a_faire', u1.id, u2.id, timestamptz '2025-11-09', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'télécommande clim à remplacer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 621, e.id, c.id, t.id, 'changer connecteur lumiéres miroir SDB', 'validee', u1.id, u2.id, timestamptz '2025-11-09', '2026-04-29'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'changer connecteur lumiéres miroir SDB'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;

alter table validations enable trigger tg_validation_maj_anomalie;
commit;
