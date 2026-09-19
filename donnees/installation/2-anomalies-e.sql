-- Généré par outils/importer_anomalies.py — ne pas modifier à la main.
-- Import de la liste « TEST Tech 3 » vers anomalies / tournees /
-- interventions / validations. Rejouable : rien n'est inséré deux fois.
-- Morceau 5 sur 5 — à jouer dans l'ordre des lettres.

begin;
alter table validations disable trigger tg_validation_maj_anomalie;

insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-04', timestamptz '2025-01-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 467
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 467
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 468, e.id, c.id, t.id, 'Joint pour faire tenir le pommeau de douche', 'a_acheter', u1.id, u2.id, timestamptz '2025-02-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Joint pour faire tenir le pommeau de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'RAS selon visite HEDI le 5/08 ( à revérifier par Victoria) - il faut acheter un joint pour que nous puissions faire tenir la pomme de douche', 'utilisateur', u.id, timestamptz '2025-02-18'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 468
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'RAS selon visite HEDI le 5/08 ( à revérifier par Victoria) - il faut acheter un joint pour que nous puissions faire tenir la pomme de douche');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 608, e.id, c.id, t.id, 'Lumière grand miroir SDB', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2026-05-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lumière grand miroir SDB'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'prévoir le changement du connecteur de raccordement car ne tient plus - att retour Alain avec fourniture - vu le 4/08', 'utilisateur', u.id, timestamptz '2025-02-18'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 608
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'prévoir le changement du connecteur de raccordement car ne tient plus - att retour Alain avec fourniture - vu le 4/08');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-02', timestamptz '2026-05-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 608
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 608
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 608
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 672, e.id, c.id, t.id, 'Lampe bureau cassée - faire réparer comme M Negroni', 'validee', u1.id, u2.id, timestamptz '2025-02-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lampe bureau cassée - faire réparer comme M Negroni'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-18', timestamptz '2025-02-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'MR NEGRONI'
  where a.sharepoint_id = 672
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 515, e.id, c.id, t.id, 'Refixer la liseuse de gauche', 'validee', u1.id, u2.id, timestamptz '2025-02-17', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer la liseuse de gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '25' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 515
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 515
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 600, e.id, c.id, t.id, 'Manque porte placard du haut', 'a_faire', u1.id, u2.id, timestamptz '2025-02-17', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Manque porte placard du haut'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Récupérée par Farid le 17/02 pour emmener à l''atelier', 'utilisateur', u.id, timestamptz '2025-02-17'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 600
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Récupérée par Farid le 17/02 pour emmener à l''atelier');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 658, e.id, c.id, t.id, 'Remplacement de la bonde lavabo', 'validee', u1.id, u2.id, timestamptz '2025-02-17', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Remplacement de la bonde lavabo'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'FARID'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 658
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 658
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 662, e.id, c.id, t.id, 'De l''eau coule à l''interier depuis la fenetre', 'a_faire', u1.id, u2.id, timestamptz '2025-02-17', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'De l''eau coule à l''interier depuis la fenetre'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 403, e.id, c.id, t.id, 'Serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2025-02-15', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 403
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 403
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 404, e.id, c.id, t.id, 'Spot dans la salle de bain', 'validee', u1.id, u2.id, timestamptz '2025-02-15', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot dans la salle de bain'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'lumière fonctionne lors de la visite de Farid', 'utilisateur', u.id, timestamptz '2025-02-15'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 404
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'lumière fonctionne lors de la visite de Farid');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 404
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 404
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 806, e.id, c.id, t.id, 'Serrer le bras liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2025-02-15', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 806
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 806
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 718, e.id, c.id, t.id, 'joint sillicone dans le bac à douche', 'validee', u1.id, u2.id, timestamptz '2025-02-14', '2025-06-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint sillicone dans le bac à douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-24', timestamptz '2025-06-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 718
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 718
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 741, e.id, c.id, t.id, 'joint sillicone dans le bac à douche', 'validee', u1.id, u2.id, timestamptz '2025-02-14', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint sillicone dans le bac à douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'déjà fait selon visite Hedi le 05/08', 'utilisateur', u.id, timestamptz '2025-02-14'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 741
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'déjà fait selon visite Hedi le 05/08');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 741
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 741
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 756, e.id, c.id, t.id, 'joint sillicone dans le bac à douche et lavabo', 'validee', u1.id, u2.id, timestamptz '2025-02-14', '2025-01-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint sillicone dans le bac à douche et lavabo'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-04', timestamptz '2025-01-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 756
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 756
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 765, e.id, c.id, t.id, 'joint sillicone dans le bac à douche', 'validee', u1.id, u2.id, timestamptz '2025-02-14', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint sillicone dans le bac à douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '55' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Vérifié par Victoria, il n''y avait plus besoin de le faire', 'utilisateur', u.id, timestamptz '2025-02-14'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 765
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Vérifié par Victoria, il n''y avait plus besoin de le faire');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-14', timestamptz '2025-02-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 765
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 785, e.id, c.id, t.id, 'joint sillicone dans le bac à douche', 'validee', u1.id, u2.id, timestamptz '2025-02-14', '2026-06-15'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint sillicone dans le bac à douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-06-15', timestamptz '2026-06-15'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260615121923728'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 785
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 785
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-06-15'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 785
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 790, e.id, c.id, t.id, 'joint sillicone dans le bac à douche', 'validee', u1.id, u2.id, timestamptz '2025-02-14', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint sillicone dans le bac à douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 790
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 790
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 804, e.id, c.id, t.id, 'joint sillicone dans le bac à douche', 'validee', u1.id, u2.id, timestamptz '2025-02-14', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint sillicone dans le bac à douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 804
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 804
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 837, e.id, c.id, t.id, 'La moquette de la premiere marche en partant du haut est decollée', 'a_faire', u1.id, u2.id, timestamptz '2025-02-13', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'La moquette de la premiere marche en partant du haut est decollée'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Palier 1er' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 498, e.id, c.id, t.id, 'Changement des rideaux', 'validee', u1.id, u2.id, timestamptz '2025-12-02', '2025-03-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-14', timestamptz '2025-03-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 498
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 498
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 568, e.id, c.id, t.id, 'Changement des rideaux - salle de bain', 'validee', u1.id, u2.id, timestamptz '2025-12-02', '2025-03-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux - salle de bain'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '34' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-14', timestamptz '2025-03-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 568
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 568
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 677, e.id, c.id, t.id, 'Changement des rideaux', 'validee', u1.id, u2.id, timestamptz '2025-12-02', '2025-03-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-14', timestamptz '2025-03-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 677
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 677
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 720, e.id, c.id, t.id, 'Changement des rideaux', 'validee', u1.id, u2.id, timestamptz '2025-12-02', '2025-03-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-14', timestamptz '2025-03-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 720
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 720
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 734, e.id, c.id, t.id, 'Changement des rideaux', 'validee', u1.id, u2.id, timestamptz '2025-12-02', '2025-03-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-14', timestamptz '2025-03-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 734
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 734
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 754, e.id, c.id, t.id, 'Changement des rideaux', 'validee', u1.id, u2.id, timestamptz '2025-12-02', '2025-03-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-14', timestamptz '2025-03-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 754
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 754
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 755, e.id, c.id, t.id, 'Changement des rideaux - salle de bain', 'validee', u1.id, u2.id, timestamptz '2025-12-02', '2025-03-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux - salle de bain'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-14', timestamptz '2025-03-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 755
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 755
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 767, e.id, c.id, t.id, 'Changement des rideaux', 'validee', u1.id, u2.id, timestamptz '2025-12-02', '2025-03-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '55' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-14', timestamptz '2025-03-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 767
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 767
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 779, e.id, c.id, t.id, 'Changement des rideaux', 'validee', u1.id, u2.id, timestamptz '2025-12-02', '2025-03-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-14', timestamptz '2025-03-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 779
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 779
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 793, e.id, c.id, t.id, 'Changement des rideaux', 'validee', u1.id, u2.id, timestamptz '2025-12-02', '2025-03-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-14', timestamptz '2025-03-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 793
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 793
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 807, e.id, c.id, t.id, 'Changement des rideaux', 'validee', u1.id, u2.id, timestamptz '2025-12-02', '2025-03-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-14', timestamptz '2025-03-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 807
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 807
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 808, e.id, c.id, t.id, 'Changement des rideaux - salle de bain', 'validee', u1.id, u2.id, timestamptz '2025-12-02', '2025-03-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement des rideaux - salle de bain'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-14', timestamptz '2025-03-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 808
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 808
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 416, e.id, c.id, t.id, 'Refixer la liseuse de droite', 'validee', u1.id, u2.id, timestamptz '2025-09-02', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'refixer la liseuse de droite'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 416
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 416
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 429, e.id, c.id, t.id, 'Refixer la liseuse de gauche', 'validee', u1.id, u2.id, timestamptz '2025-09-02', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer la liseuse de gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 429
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 429
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 434, e.id, c.id, t.id, 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)', 'validee', u1.id, u2.id, timestamptz '2025-09-02', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '15' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Repasser dessus car l''aimant vissé ne tient pas, il faut ajouter une vis ou refixer correctement', 'utilisateur', u.id, timestamptz '2025-09-02'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 434
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Repasser dessus car l''aimant vissé ne tient pas, il faut ajouter une vis ou refixer correctement');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 434
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 434
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 585, e.id, c.id, t.id, 'Il manque la porte du placard du bas', 'a_faire', u1.id, u2.id, timestamptz '2025-09-02', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il manque la porte du placard du bas'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 461, e.id, c.id, t.id, 'lampe bureau à réparer', 'validee', u1.id, u2.id, timestamptz '2025-07-02', '2025-06-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lampe bureau à réparer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'OK REMISE EN CHAMBRE', 'utilisateur', u.id, timestamptz '2025-07-02'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 461
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'OK REMISE EN CHAMBRE');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-02', timestamptz '2025-06-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'MR NEGRONI'
  where a.sharepoint_id = 461
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 461
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 537, e.id, c.id, t.id, 'lampe bureau à réparer', 'validee', u1.id, u2.id, timestamptz '2025-07-02', '2025-06-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lampe bureau à réparer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'OK REMISE EN CHAMBRE', 'utilisateur', u.id, timestamptz '2025-07-02'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 537
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'OK REMISE EN CHAMBRE');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-02', timestamptz '2025-06-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'MR NEGRONI'
  where a.sharepoint_id = 537
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 537
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 638, e.id, c.id, t.id, 'lampe bureau à réparer', 'validee', u1.id, u2.id, timestamptz '2025-07-02', '2025-06-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lampe bureau à réparer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'OK REMISE EN CHAMBRE', 'utilisateur', u.id, timestamptz '2025-07-02'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 638
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'OK REMISE EN CHAMBRE');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-02', timestamptz '2025-06-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'MR NEGRONI'
  where a.sharepoint_id = 638
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 638
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 719, e.id, c.id, t.id, 'Manque porte placard ( grande) / visser aimant', 'validee', u1.id, u2.id, timestamptz '2025-07-02', '2025-07-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Manque porte placard ( grande) / visser aimant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '51' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-07-02', timestamptz '2025-07-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 719
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-07-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 719
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 742, e.id, c.id, t.id, 'Manque porte placard ( grande) / visser aimant', 'validee', u1.id, u2.id, timestamptz '2025-07-02', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Manque porte placard ( grande) / visser aimant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'La porte à été remise le 17/02 mais il manque la vis pour faire tenir l''aimant', 'utilisateur', u.id, timestamptz '2025-07-02'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 742
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'La porte à été remise le 17/02 mais il manque la vis pour faire tenir l''aimant');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 742
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 742
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 742
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 752, e.id, c.id, t.id, 'lampe bureau à réparer', 'validee', u1.id, u2.id, timestamptz '2025-07-02', '2025-06-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lampe bureau à réparer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'OK REMISE EN CHAMBRE', 'utilisateur', u.id, timestamptz '2025-07-02'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 752
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'OK REMISE EN CHAMBRE');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-02', timestamptz '2025-06-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'MR NEGRONI'
  where a.sharepoint_id = 752
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 752
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 771, e.id, c.id, t.id, 'lampe bureau à réparer', 'validee', u1.id, u2.id, timestamptz '2025-07-02', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lampe bureau à réparer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '55' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Réparation M Negroni ok, manque juste l''ampoule ( lampe dans le local technique) - @ réception le 18/02 car nous avons trouvé une lampe fonctionnelle en 55... Nous ne savons pas où mettre la lampe qui se trouve au sous sol', 'utilisateur', u.id, timestamptz '2025-07-02'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 771
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Réparation M Negroni ok, manque juste l''ampoule ( lampe dans le local technique) - @ réception le 18/02 car nous avons trouvé une lampe fonctionnelle en 55... Nous ne savons pas où mettre la lampe qui se trouve au sous sol');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 777, e.id, c.id, t.id, 'lampe bureau à réparer', 'validee', u1.id, u2.id, timestamptz '2025-07-02', '2025-06-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lampe bureau à réparer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'OK REMISE EN CHAMBRE', 'utilisateur', u.id, timestamptz '2025-07-02'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 777
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'OK REMISE EN CHAMBRE');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-02', timestamptz '2025-06-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'MR NEGRONI'
  where a.sharepoint_id = 777
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 777
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 791, e.id, c.id, t.id, 'Prise arrachée du mur SDB', 'validee', u1.id, u2.id, timestamptz '2025-07-02', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'prise arrachée du mur sdb'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 791
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 791
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 846, e.id, c.id, t.id, 'Installer un interupteur', 'validee', u1.id, u2.id, timestamptz '2025-06-02', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Installer un interupteur'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'MR NEGRONI'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Local Technique' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'A la demande de Mr Negroni - fait par Alain', 'utilisateur', u.id, timestamptz '2025-06-02'
  from anomalies a left join utilisateurs u on u.nom = 'MR NEGRONI'
  where a.sharepoint_id = 846
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'A la demande de Mr Negroni - fait par Alain');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 851, e.id, c.id, t.id, 'faire un trou et ensuite avec un fil de fer tirer les fils pour installer la prise pour le nouveau cadre', 'validee', u1.id, u2.id, timestamptz '2025-06-02', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'faire un trou et ensuite avec un fil de fer tirer les fils pour installer la prise pour le nouveau cadre'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'MR NEGRONI'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Réception' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Vu entre Marie et Alain pour l''intervention', 'utilisateur', u.id, timestamptz '2025-06-02'
  from anomalies a left join utilisateurs u on u.nom = 'MR NEGRONI'
  where a.sharepoint_id = 851
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Vu entre Marie et Alain pour l''intervention');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 557, e.id, c.id, t.id, 'flexible liseuse côté gauche à changer', 'validee', u1.id, u2.id, timestamptz '2025-05-02', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté gauche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '31' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Suite passage du 08/04/25 pas besoin de changer mais juste à resserer', 'utilisateur', u.id, timestamptz '2025-05-02'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 557
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Suite passage du 08/04/25 pas besoin de changer mais juste à resserer');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 557
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 557
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 654, e.id, c.id, t.id, 'flexible liseuse côté gauche à changer', 'validee', u1.id, u2.id, timestamptz '2025-05-02', '2025-02-17'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté gauche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-02-17', timestamptz '2025-02-17'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'FARID'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 654
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-02-17'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'FARID'
  where a.sharepoint_id = 654
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 671, e.id, c.id, t.id, 'Support gel douche à changer', 'validee', u1.id, u2.id, timestamptz '2025-05-02', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Support gel douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 671
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 671
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 707, e.id, c.id, t.id, 'Joint porte sdb', 'validee', u1.id, u2.id, timestamptz '2025-05-02', '2025-06-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Joint porte sdb'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-24', timestamptz '2025-06-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 707
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 707
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 739, e.id, c.id, t.id, 'Lavabo qui coule', 'validee', u1.id, u2.id, timestamptz '2025-05-02', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lavabo qui coule'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 739
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 739
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 564, e.id, c.id, t.id, 'Miroir plateau à changé', 'validee', u1.id, u2.id, timestamptz '2025-04-02', '2026-05-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Miroir plateau à changé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '32' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-05-02', timestamptz '2026-05-02'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 564
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 564
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 564
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 583, e.id, c.id, t.id, 'flexible liseuse côté droit à resserer', 'validee', u1.id, u2.id, timestamptz '2025-04-02', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté droit à resserer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 583
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 583
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 594, e.id, c.id, t.id, 'Refixer la liseuse de gauche', 'validee', u1.id, u2.id, timestamptz '2025-04-02', '2025-07-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer la liseuse de gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
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
