-- Généré par outils/importer_anomalies.py — ne pas modifier à la main.
-- Import de la liste « TEST Tech 3 » vers anomalies / tournees /
-- interventions / validations. Rejouable : rien n'est inséré deux fois.
-- Morceau 9 sur 9 — à jouer dans l'ordre des lettres.

begin;
alter table validations disable trigger tg_validation_maj_anomalie;

insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-07-02', timestamptz '2025-07-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 594
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-07-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 594
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 614, e.id, c.id, t.id, 'flexible liseuse côté gauche à changer', 'validee', u1.id, u2.id, timestamptz '2025-04-02', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté gauche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 614
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 614
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 620, e.id, c.id, t.id, 'Miroir plateau à changé', 'validee', u1.id, u2.id, timestamptz '2025-04-02', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Miroir plateau à changé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'test prévu dans cette chambre avec Serafino lors de son prochain passage - vu avec Sarah & Serafino le 6/01', 'utilisateur', u.id, timestamptz '2025-04-02'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 620
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'test prévu dans cette chambre avec Serafino lors de son prochain passage - vu avec Sarah & Serafino le 6/01');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-11-05', timestamptz '2026-11-05'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511114443975'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 620
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-11-05'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 620
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 620
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 812, e.id, c.id, t.id, 'Miroir plateau à changé', 'validee', u1.id, u2.id, timestamptz '2025-04-02', '2026-05-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Miroir plateau à changé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-02', timestamptz '2026-05-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 812
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 812
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 812
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 873, e.id, c.id, t.id, 'Neon salle de repos à changer', 'validee', u1.id, u2.id, timestamptz '2025-01-02', '2025-03-20'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Neon salle de repos à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Salle de repos' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-20', timestamptz '2025-03-20'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'MR NEGRONI'
  where a.sharepoint_id = 873
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 873
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 983, e.id, c.id, t.id, 'Changement des rideaux', 'validee', u1.id, u2.id, timestamptz '2025-01-29', '2026-03-31'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Dégâts fait par le technicien Avir', 'utilisateur', u.id, timestamptz '2025-01-29'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 983
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Dégâts fait par le technicien Avir');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-03-31', timestamptz '2026-03-31'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 983
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-03-31'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 983
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 457, e.id, c.id, t.id, 'URGENT! PRIORITE Coffre à reprogrammer', 'validee', u1.id, u2.id, timestamptz '2025-01-28', '2025-03-11'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'urgent! priorite coffre à reprogrammer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-11', timestamptz '2025-03-11'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien EUROPROH'
  where a.sharepoint_id = 457
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-11'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 457
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 415, e.id, c.id, t.id, 'Spot plafond niveau armoire à changer', 'validee', u1.id, u2.id, timestamptz '2025-01-27', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot plafond niveau armoire à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Apparemment déjà fait', 'utilisateur', u.id, timestamptz '2025-01-27'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 415
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Apparemment déjà fait');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 415
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 415
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 428, e.id, c.id, t.id, 'Mettre une vis pour l''aimant de la porte dorée armoire (bas)', 'validee', u1.id, u2.id, timestamptz '2025-01-27', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre une vis pour l''aimant de la porte dorée armoire (bas)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'noté fait le 30/01 mais pas fait', 'utilisateur', u.id, timestamptz '2025-01-27'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 428
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'noté fait le 30/01 mais pas fait');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 428
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 428
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 627, e.id, c.id, t.id, 'flexible liseuse côté SDB à changer', 'validee', u1.id, u2.id, timestamptz '2025-01-27', '2025-01-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté SDB à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '41' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-30', timestamptz '2025-01-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 627
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 627
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 650, e.id, c.id, t.id, 'Barrre de douche à refixer', 'validee', u1.id, u2.id, timestamptz '2025-01-27', '2025-01-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Barrre de douche à refixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '44' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-30', timestamptz '2025-01-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 650
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 650
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 814, e.id, c.id, t.id, 'plafond douche SDB cloqué - voir avec Kamel', 'a_faire', u1.id, u2.id, timestamptz '2025-01-27', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'plafond douche SDB cloqué - voir avec Kamel'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Voir avec Serafino pour vérifier l''état de la VMC et s''il trouve le pb lors de son passage du mardi 13 -', 'utilisateur', u.id, timestamptz '2025-01-27'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 814
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Voir avec Serafino pour vérifier l''état de la VMC et s''il trouve le pb lors de son passage du mardi 13 -');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 878, e.id, c.id, t.id, 'réparation enduit mur blanc niveau lingerie + peinture Farid + baguettes plastiques larges et resistantes car les livreurs abîment les angles avec leurs charriots', 'validee', u1.id, u2.id, timestamptz '2025-01-27', '2025-03-20'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'réparation enduit mur blanc niveau lingerie + peinture Farid + baguettes plastiques larges et resistantes car les livreurs abîment les angles avec leurs charriots'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Sous-sol divers' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-20', timestamptz '2025-03-20'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'MR NEGRONI'
  where a.sharepoint_id = 878
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 878
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 584, e.id, c.id, t.id, 'Mettre feutrine découpée sur mesure au dos de la table de chevet pour protéger le mur', 'a_faire', u1.id, u2.id, timestamptz '2025-01-24', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre feutrine découpée sur mesure au dos de la table de chevet pour protéger le mur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 392, e.id, c.id, t.id, 'mettre des cornieres noires à l''entrée de la chambe', 'a_faire', u1.id, u2.id, timestamptz '2025-01-23', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'mettre des cornieres noires à l''entrée de la chambe'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 842, e.id, c.id, t.id, 'Voilages dechirés', 'validee', u1.id, u2.id, timestamptz '2025-01-23', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Voilages dechirés'
  left join types_intervention t on t.code = 'ACHATS'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Parties communes' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'EN COMMANDE PAR ANDREA - reçu le 14/03/25 par Victoria', 'utilisateur', u.id, timestamptz '2025-01-23'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 842
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'EN COMMANDE PAR ANDREA - reçu le 14/03/25 par Victoria');
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Localisation d''origine : GENERAL', 'reprise', u.id, timestamptz '2025-01-23'
  from anomalies a left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 842
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Localisation d''origine : GENERAL');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-23', timestamptz '2025-01-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 842
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 411, e.id, c.id, t.id, 'changement du flexible de la liseuse de droite', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-01-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'changement du flexible de la liseuse de droite'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-21', timestamptz '2025-01-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 411
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 411
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 490, e.id, c.id, t.id, 'Refixer le miroir grossissant', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer le miroir grossissant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Apres verifications le 19/02/25 par Victoria - Le miroir n''a pas été correctement visé - ok Hedi est repassé dessus le 05/08 ( non vérifié)', 'utilisateur', u.id, timestamptz '2025-01-21'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 490
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Apres verifications le 19/02/25 par Victoria - Le miroir n''a pas été correctement visé - ok Hedi est repassé dessus le 05/08 ( non vérifié)');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 490
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 490
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 491, e.id, c.id, t.id, 'problème de joint sur la paroi de douche car l''eau coule à travers -', 'validee', u1.id, u2.id, timestamptz '2025-01-21', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'problème de joint sur la paroi de douche car l''eau coule à travers -'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, '6 baguettes joints neuves déposées par M Negroni le 24/01 pour pare douches dans la lingerie -', 'utilisateur', u.id, timestamptz '2025-01-21'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 491
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = '6 baguettes joints neuves déposées par M Negroni le 24/01 pour pare douches dans la lingerie -');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 521, e.id, c.id, t.id, 'Mettre une vis pour l''aimant de la porte dorée armoire (bas)', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-01-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre une vis pour l''aimant de la porte dorée armoire (bas)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '26' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-21', timestamptz '2025-01-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 521
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 521
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 523, e.id, c.id, t.id, 'flexible liseuse côté droit à changer', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté droit à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '26' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 523
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 523
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 524, e.id, c.id, t.id, 'flexible liseuse côté gauche à resserer', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-01-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté gauche à resserer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '26' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Apres verifications le 19/02/25 par Victoria - resseré le 08/04/25', 'utilisateur', u.id, timestamptz '2025-01-21'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 524
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Apres verifications le 19/02/25 par Victoria - resseré le 08/04/25');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-21', timestamptz '2025-01-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 524
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 524
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 530, e.id, c.id, t.id, 'Refixer la liseuse de droite', 'validee', u1.id, u2.id, timestamptz '2025-01-21', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'refixer la liseuse de droite'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 531, e.id, c.id, t.id, 'Plainte rose coté lit SDB à recoller', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Plainte rose coté lit SDB à recoller'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 531
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 531
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 538, e.id, c.id, t.id, 'La porte principale ne se fermait pas bien', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-01-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'La porte principale ne se fermait pas bien'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-21', timestamptz '2025-01-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 538
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 538
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 582, e.id, c.id, t.id, 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)', 'validee', u1.id, u2.id, timestamptz '2025-01-21', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 607, e.id, c.id, t.id, 'Plinthe bois chambre (Mur a gauche du lit) à recoller', 'validee', u1.id, u2.id, timestamptz '2025-01-21', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Plinthe bois chambre (Mur a gauche du lit) à recoller'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Collé ok - faire le joint et repeindre la plinthe - selon Hedi déjà fait lors du passage du 18.09', 'utilisateur', u.id, timestamptz '2025-01-21'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 607
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Collé ok - faire le joint et repeindre la plinthe - selon Hedi déjà fait lors du passage du 18.09');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 684, e.id, c.id, t.id, 'Fuite syphon Lavabo SDB', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-01-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Fuite syphon Lavabo SDB'
  left join types_intervention t on t.code = 'PLOMBERIE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'fait le 21/01 mais fuit de nouveau le 24/01 - 30/01/25, le joint à été enlevé par Farid et Mr Jacques', 'utilisateur', u.id, timestamptz '2025-01-21'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 684
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'fait le 21/01 mais fuit de nouveau le 24/01 - 30/01/25, le joint à été enlevé par Farid et Mr Jacques');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-21', timestamptz '2025-01-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 684
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 684
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 732, e.id, c.id, t.id, 'Refixer la liseuse de gauche', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer la liseuse de gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Victoria a contaster qu''il fallait de nouveau le faire le 15/02/25', 'utilisateur', u.id, timestamptz '2025-01-21'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 732
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Victoria a contaster qu''il fallait de nouveau le faire le 15/02/25');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 732
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 732
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 737, e.id, c.id, t.id, 'Mettre une vise sur la Porte dorée armoire (haut)', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-01-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre une vise sur la Porte dorée armoire (haut)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-21', timestamptz '2025-01-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 737
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 737
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 738, e.id, c.id, t.id, 'Refixer le miroir grossissant', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer le miroir grossissant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'le miroir a dû être déplacé donc trous apparents, refaire peinture', 'utilisateur', u.id, timestamptz '2025-01-21'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 738
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'le miroir a dû être déplacé donc trous apparents, refaire peinture');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 738
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 738
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 751, e.id, c.id, t.id, 'Refixer le miroir grossissant', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer le miroir grossissant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 751
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 751
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 770, e.id, c.id, t.id, 'Baguette d''angle noir a recollé - mur entree chambre', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-01-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Baguette d''angle noir a recollé - mur entree chambre'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '55' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-21', timestamptz '2025-01-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 770
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 770
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 778, e.id, c.id, t.id, 'Fuite syphon Lavabo SDB', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-01-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Fuite syphon Lavabo SDB'
  left join types_intervention t on t.code = 'PLOMBERIE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-21', timestamptz '2025-01-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 778
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 778
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 865, e.id, c.id, t.id, 'coller deux baguettes d''angle noires dans l''encadrement porte DAES', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-01-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'coller deux baguettes d''angle noires dans l''encadrement porte DAES'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Ascenseur' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-21', timestamptz '2025-01-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 865
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 865
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 877, e.id, c.id, t.id, 'Mettre le tableau pour l''affichage obligatoire', 'validee', u1.id, u2.id, timestamptz '2025-01-21', '2025-01-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre le tableau pour l''affichage obligatoire'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Sous-sol divers' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-21', timestamptz '2025-01-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 877
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 877
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 817, e.id, c.id, t.id, 'Spot du couloir a changer à coté de la chambre 18', 'validee', u1.id, u2.id, timestamptz '2025-01-16', '2025-01-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot du couloir a changer à coté de la chambre 18'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Palier 1er' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-30', timestamptz '2025-01-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 817
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 817
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 440, e.id, c.id, t.id, 'Porte du frigo à fixer', 'validee', u1.id, u2.id, timestamptz '2025-11-01', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'porte du frigo à fixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '15' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 440
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 440
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 649, e.id, c.id, t.id, 'Lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2025-11-01', '2025-01-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'PLOMBERIE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '44' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-16', timestamptz '2025-01-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 649
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 649
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 723, e.id, c.id, t.id, 'Bouton on/off pour regler la temperature non fonctionnel', 'validee', u1.id, u2.id, timestamptz '2025-11-01', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Bouton on/off pour regler la temperature non fonctionnel'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 805, e.id, c.id, t.id, 'La lumiere du miroir ne s''allume pas', 'validee', u1.id, u2.id, timestamptz '2025-11-01', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'La lumiere du miroir ne s''allume pas'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 805
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 805
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 417, e.id, c.id, t.id, 'joint porte sdb', 'validee', u1.id, u2.id, timestamptz '2025-09-01', '2025-11-01'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Joint porte sdb'
  left join types_intervention t on t.code = 'PLOMBERIE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-01', timestamptz '2025-11-01'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 417
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-01'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 417
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 497, e.id, c.id, t.id, 'change bonde lavabo', 'validee', u1.id, u2.id, timestamptz '2025-09-01', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'change bonde lavabo'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 497
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 497
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 511, e.id, c.id, t.id, 'deboucher l''evier', 'validee', u1.id, u2.id, timestamptz '2025-09-01', '2025-11-01'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'deboucher l''evier'
  left join types_intervention t on t.code = 'PLOMBERIE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-01', timestamptz '2025-11-01'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 511
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-01'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 511
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 529, e.id, c.id, t.id, 'deboucher l''evier', 'validee', u1.id, u2.id, timestamptz '2025-09-01', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'deboucher l''evier'
  left join types_intervention t on t.code = 'PLOMBERIE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 560, e.id, c.id, t.id, 'Télérupteur spot et led à changer', 'validee', u1.id, u2.id, timestamptz '2025-09-01', '2025-01-22'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur spot et led à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '32' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'telerupteur mecanique - L''hotel test des télérupteurs mecaniques à la place des télérupteurs electriques', 'utilisateur', u.id, timestamptz '2025-09-01'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 560
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'telerupteur mecanique - L''hotel test des télérupteurs mecaniques à la place des télérupteurs electriques');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-22', timestamptz '2025-01-22'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 560
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-22'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 560
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 731, e.id, c.id, t.id, 'changer la bonde du lavabo', 'validee', u1.id, u2.id, timestamptz '2025-09-01', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'changer la bonde du lavabo'
  left join types_intervention t on t.code = 'PLOMBERIE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 731
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 731
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 783, e.id, c.id, t.id, 'deboucher l''evier', 'validee', u1.id, u2.id, timestamptz '2025-09-01', '2025-01-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'deboucher l''evier'
  left join types_intervention t on t.code = 'PLOMBERIE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-16', timestamptz '2025-01-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 783
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 783
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 387, e.id, c.id, t.id, 'Applique coté entrée à refixer correctement', 'validee', u1.id, u2.id, timestamptz '2025-05-01', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Applique coté entrée à refixer correctement'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 387
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 387
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 822, e.id, c.id, t.id, 'Spot à coté de l''ascenseur à changer', 'validee', u1.id, u2.id, timestamptz '2025-05-01', '2025-01-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à coté de l''ascenseur à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '4eme étage' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-04', timestamptz '2025-01-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 822
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 822
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');

alter table validations enable trigger tg_validation_maj_anomalie;
commit;


-- Trace de passage : c'est elle que lit 0-ou-en-suis-je.sql.
create table if not exists installation_journal (
  fichier  text primary key,
  joue_le  timestamptz not null default now()
);
insert into installation_journal (fichier) values ('2-anomalies-i.sql')
  on conflict (fichier) do update set joue_le = now();

select '2-anomalies-i.sql' as "Fichier joué", (select count(*) || ' anomalies sur 670' from anomalies) as "Où ça en est";
