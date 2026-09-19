-- Généré par outils/importer_anomalies.py — ne pas modifier à la main.
-- Import de la liste « TEST Tech 3 » vers anomalies / tournees /
-- interventions / validations. Rejouable : rien n'est inséré deux fois.
-- Morceau 4 sur 5 — à jouer dans l'ordre des lettres.

begin;
alter table validations disable trigger tg_validation_maj_anomalie;

insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'qqun présent en chambre connecteur pas changé / juste', 'utilisateur', u.id, timestamptz '2025-11-09'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 621
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'qqun présent en chambre connecteur pas changé / juste');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-29', timestamptz '2026-04-29'
  from anomalies a
  left join tournees t on t.reference = 'INT-ALAIN-20260429160344684'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 621
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 621
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 621
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 685, e.id, c.id, t.id, 'changer connecteur lumiéres miroir SDB', 'validee', u1.id, u2.id, timestamptz '2025-11-09', '2025-12-09'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'changer connecteur lumiéres miroir SDB'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-09', timestamptz '2025-12-09'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 685
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-09'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 685
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 869, e.id, c.id, t.id, 'Spot plafond derrière la réception à changer', 'validee', u1.id, u2.id, timestamptz '2025-11-09', '2025-12-09'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot plafond derrière la réception à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Réception' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-09', timestamptz '2025-12-09'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 869
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-09'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 869
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 619, e.id, c.id, t.id, 'Refixer la liseuse de gauche', 'validee', u1.id, u2.id, timestamptz '2025-09-09', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer la liseuse de gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1129, e.id, c.id, t.id, 'Ascenseur en panne - Il faut contacter KONE', 'validee', u1.id, u2.id, timestamptz '2025-09-09', '2025-09-13'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Ascenseur en panne - Il faut contacter KONE'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Ascenseur' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Le problème était lié à de la poussière', 'utilisateur', u.id, timestamptz '2025-09-09'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1129
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Le problème était lié à de la poussière');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-13', timestamptz '2025-09-13'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien Kone'
  where a.sharepoint_id = 1129
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1129
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2025-09-13'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 1129
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 478, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', u1.id, u2.id, timestamptz '2025-07-09', '2025-12-09'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '21' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-09', timestamptz '2025-12-09'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 478
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-09'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 478
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 591, e.id, c.id, t.id, 'L''eau coule dans la cuvette des WC', 'validee', u1.id, u2.id, timestamptz '2025-07-09', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'L''eau coule dans la cuvette des WC'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'nécéssite le changement complet du mécanisme de chasse d''eau selon passage Hedi du 18.09 - Finalement joints effectués lors du passage du 20.09', 'utilisateur', u.id, timestamptz '2025-07-09'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 591
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'nécéssite le changement complet du mécanisme de chasse d''eau selon passage Hedi du 18.09 - Finalement joints effectués lors du passage du 20.09');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 591
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 591
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 669, e.id, c.id, t.id, 'barriere de douche à fixer', 'validee', u1.id, u2.id, timestamptz '2025-07-09', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'barriere de douche à fixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 669
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 669
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 730, e.id, c.id, t.id, 'Refixer correctement le miroir grossissant au mur SDB', 'validee', u1.id, u2.id, timestamptz '2025-07-09', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer correctement le miroir grossissant au mur SDB'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 730
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 730
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 747, e.id, c.id, t.id, 'barriere de douche à fixer', 'validee', u1.id, u2.id, timestamptz '2025-07-09', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'barriere de douche à fixer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 747
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 747
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 834, e.id, c.id, t.id, 'Porte d''entrée qui ne se verouille pas - URGENT', 'validee', u1.id, u2.id, timestamptz '2025-02-09', '2025-12-09'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'porte d''entrée qui ne se verouille pas - urgent'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Entrée' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-09', timestamptz '2025-12-09'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 834
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-09'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 834
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 831, e.id, c.id, t.id, 'Spot à changer', 'validee', u1.id, u2.id, timestamptz '2025-08-31', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Cuisine' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 426, e.id, c.id, t.id, 'L''eau coule dans la cuvette des WC', 'validee', u1.id, u2.id, timestamptz '2025-08-28', '2025-09-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'L''eau coule dans la cuvette des WC'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-26', timestamptz '2025-09-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 426
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 426
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 448, e.id, c.id, t.id, 'L''eau coule dans la cuvette des WC', 'validee', u1.id, u2.id, timestamptz '2025-08-28', '2025-09-20'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'L''eau coule dans la cuvette des WC'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Selon passage Hedi du 18.09, changelment total du système de chasse d''eau - suite passage du 20/09 - joints effectués', 'utilisateur', u.id, timestamptz '2025-08-28'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 448
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Selon passage Hedi du 18.09, changelment total du système de chasse d''eau - suite passage du 20/09 - joints effectués');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-20', timestamptz '2025-09-20'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 448
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 448
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 475, e.id, c.id, t.id, 'L''eau coule dans la cuvette des WC', 'validee', u1.id, u2.id, timestamptz '2025-08-28', '2025-09-20'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'L''eau coule dans la cuvette des WC'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '21' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'nécéssite le changement complet du mécanisme de chasse d''eau selon passage Hedi le 18.09 Finalement joints effectués passage Hedi du 20.09', 'utilisateur', u.id, timestamptz '2025-08-28'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 475
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'nécéssite le changement complet du mécanisme de chasse d''eau selon passage Hedi le 18.09 Finalement joints effectués passage Hedi du 20.09');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-20', timestamptz '2025-09-20'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 475
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 475
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 838, e.id, c.id, t.id, 'Ampoule de l''applique à changer', 'validee', u1.id, u2.id, timestamptz '2025-08-28', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Ampoule de l''applique à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Parties communes' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Localisation d''origine : escalier qui mène au 1er', 'reprise', u.id, timestamptz '2025-08-28'
  from anomalies a left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 838
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Localisation d''origine : escalier qui mène au 1er');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 840, e.id, c.id, t.id, 'bloc secour/batterie a changer', 'validee', u1.id, u2.id, timestamptz '2025-08-28', '2025-10-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'bloc secour/batterie a changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'escalier qui mène au 5ème' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-10-23', timestamptz '2025-10-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien TELEC'
  where a.sharepoint_id = 840
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-10-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 840
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 848, e.id, c.id, t.id, 'bloc secour/batterie a changer', 'validee', u1.id, u2.id, timestamptz '2025-08-28', '2025-10-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'bloc secour/batterie a changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Local TGBT' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-10-23', timestamptz '2025-10-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien TELEC'
  where a.sharepoint_id = 848
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-10-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 848
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1131, e.id, c.id, t.id, 'Ascenseur en panne - Il faut contacter KONE', 'validee', u1.id, u2.id, timestamptz '2025-08-18', '2025-08-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Ascenseur en panne - Il faut contacter KONE'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Ascenseur' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-18', timestamptz '2025-08-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien Kone'
  where a.sharepoint_id = 1131
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1131
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2025-08-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 1131
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 421, e.id, c.id, t.id, 'Flexible fuit au niveau du pommeau de douche', 'validee', u1.id, u2.id, timestamptz '2025-08-15', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible fuit au niveau du pommeau de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'flexible remplacé', 'utilisateur', u.id, timestamptz '2025-08-15'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 421
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'flexible remplacé');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 421
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 421
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 425, e.id, c.id, t.id, 'Lit cassé côté gauche', 'validee', u1.id, u2.id, timestamptz '2025-08-15', '2025-09-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit cassé côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-26', timestamptz '2025-09-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 425
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 425
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 709, e.id, c.id, t.id, 'flexible liseuse côté droit à changer', 'validee', u1.id, u2.id, timestamptz '2025-08-15', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible liseuse côté droit à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 709
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 709
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 875, e.id, c.id, t.id, 'ecoulement faible eau chasse d''eau vestiaire femme', 'validee', u1.id, u2.id, timestamptz '2025-08-15', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'ecoulement faible eau chasse d''eau vestiaire femme'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'WC Femmes' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 875
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 875
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 879, e.id, c.id, t.id, 'évier salle de pause qui fuit', 'a_acheter', u1.id, u2.id, timestamptz '2025-08-15', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'évier salle de pause qui fuit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Sous-sol divers' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Il faut acheter un robinet', 'utilisateur', u.id, timestamptz '2025-08-15'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 879
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Il faut acheter un robinet');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 733, e.id, c.id, t.id, 'télérupteur pour spots plafond à changer', 'validee', u1.id, u2.id, timestamptz '2025-11-08', '2025-12-09'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'télérupteur pour spots plafond à changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Erreur lors de la commande du 09/09/25 - Télérupteur électrique au lieu de mécaniques', 'utilisateur', u.id, timestamptz '2025-11-08'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 733
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Erreur lors de la commande du 09/09/25 - Télérupteur électrique au lieu de mécaniques');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-09', timestamptz '2025-12-09'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 733
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-09'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 733
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 839, e.id, c.id, t.id, 'bloc secour/batterie à changer', 'validee', u1.id, u2.id, timestamptz '2025-04-08', '2025-10-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'bloc secour/batterie a changer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'escalier qui mène au 4ème' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Alain l''a déconnecté et reconnecté le 4/08 - clignote en vert pour dire qu''il se charge. Normalement clignotement disparaît sous 24h - le clignotement est encore', 'utilisateur', u.id, timestamptz '2025-04-08'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 839
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Alain l''a déconnecté et reconnecté le 4/08 - clignote en vert pour dire qu''il se charge. Normalement clignotement disparaît sous 24h - le clignotement est encore');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-10-23', timestamptz '2025-10-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien TELEC'
  where a.sharepoint_id = 839
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-10-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 839
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 852, e.id, c.id, t.id, 'trappe au plafond à refermer', 'en_cours', u1.id, u2.id, timestamptz '2025-02-08', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'trappe au plafond à refermer'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Office 5 ème étage' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'OK par Alain attention, la peinture a été abîmée par el plombier - à refaire', 'utilisateur', u.id, timestamptz '2025-02-08'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 852
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'OK par Alain attention, la peinture a été abîmée par el plombier - à refaire');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-08', timestamptz '2025-04-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 852
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 852
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 853, e.id, c.id, t.id, 'voir comment rendre le boitier élec étanche en cas de nouvelle fuite', 'en_cours', u1.id, u2.id, timestamptz '2025-02-08', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'voir comment rendre le boitier élec étanche en cas de nouvelle fuite'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Office 5 ème étage' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Système de tube avec trous pour évac de l''eau avant d''arriver au boîtier - att retour Alain début Sept avec achat du matériel - Hedi a bouché des trous avec un plastique noir et il n''arrive pas à accéder côté clim - voir si M Negroni est ok avec les photos - Le 12/09/25 Alain a installé un tuyau qui dévie l''eau mais le tuyau n''est pas assez long donc lors de sa prochaine intervention il apportera un plus grand', 'utilisateur', u.id, timestamptz '2025-02-08'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 853
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Système de tube avec trous pour évac de l''eau avant d''arriver au boîtier - att retour Alain début Sept avec achat du matériel - Hedi a bouché des trous avec un plastique noir et il n''arrive pas à accéder côté clim - voir si M Negroni est ok avec les photos - Le 12/09/25 Alain a installé un tuyau qui dévie l''eau mais le tuyau n''est pas assez long donc lors de sa prochaine intervention il apportera un plus grand');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 496, e.id, c.id, t.id, 'La porte principale ne se fermait pas bien', 'validee', u1.id, u2.id, timestamptz '2025-01-08', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'La porte principale ne se fermait pas bien'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Refait le 8/08 car porte ne ferme toujours pas en date du 8/08 ( vu avec Taïbi) refait le 18/09 par Hedi', 'utilisateur', u.id, timestamptz '2025-01-08'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 496
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Refait le 8/08 car porte ne ferme toujours pas en date du 8/08 ( vu avec Taïbi) refait le 18/09 par Hedi');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 496
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 496
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 502, e.id, c.id, t.id, 'Il manque un joint sur la porte de la salle de bain et elle est désaxée', 'validee', u1.id, u2.id, timestamptz '2025-01-08', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Il manque un joint sur la porte de la salle de bain et elle est désaxée'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '24' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 502
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 502
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 835, e.id, c.id, t.id, 'Spot côté à changer devant la camera', 'validee', u1.id, u2.id, timestamptz '2025-07-31', '2025-04-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot côté à changer devant la camera'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Entrée' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-08', timestamptz '2025-04-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 835
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 835
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 866, e.id, c.id, t.id, 'Spot côté à changer à côté du miroir', 'validee', u1.id, u2.id, timestamptz '2025-07-31', '2025-04-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot côté à changer à côté du miroir'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Réception' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-08', timestamptz '2025-04-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 866
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 866
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 867, e.id, c.id, t.id, 'Spot côté à changer derriere la réception', 'validee', u1.id, u2.id, timestamptz '2025-07-31', '2025-04-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot côté à changer derriere la réception'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Réception' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-08', timestamptz '2025-04-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 867
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 867
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 409, e.id, c.id, t.id, 'Serrer le bras liseuse côté gauche', 'validee', u1.id, u2.id, timestamptz '2025-07-30', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 409
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 409
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 533, e.id, c.id, t.id, 'deboucher l''evier', 'validee', u1.id, u2.id, timestamptz '2025-07-30', '2025-07-31'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'deboucher l''evier'
  left join types_intervention t on t.code = 'PLOMBERIE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Rodica l''a débouché le 31/07/25', 'utilisateur', u.id, timestamptz '2025-07-30'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 533
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Rodica l''a débouché le 31/07/25');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-07-31', timestamptz '2025-07-31'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 533
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-07-31'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 533
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 572, e.id, c.id, t.id, 'Vis tombé de la douche à la reception - à la reception', 'validee', u1.id, u2.id, timestamptz '2025-07-30', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vis tombé de la douche à la reception - à la reception'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '34' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 572
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 572
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 601, e.id, c.id, t.id, 'Vis seche serviette à la reception', 'validee', u1.id, u2.id, timestamptz '2025-07-30', '2025-09-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vis seche serviette à la reception'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-26', timestamptz '2025-09-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 601
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 601
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 780, e.id, c.id, t.id, 'Changement du séche cheveux', 'validee', u1.id, u2.id, timestamptz '2025-07-27', '2025-07-22'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changement du séche cheveux'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-07-22', timestamptz '2025-07-22'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 780
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-07-22'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 780
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 395, e.id, c.id, t.id, 'bouton mitigeur douche manquant', 'validee', u1.id, u2.id, timestamptz '2025-07-25', '2026-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'bouton mitigeur douche manquant'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Ok mais pour les autres chambres, il n''est pas possible de dévisse - il faudrait changer le mitigeur', 'utilisateur', u.id, timestamptz '2025-07-25'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 395
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Ok mais pour les autres chambres, il n''est pas possible de dévisse - il faudrait changer le mitigeur');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 395
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 395
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 395
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 860, e.id, c.id, t.id, 'Faire installer la machine café -', 'validee', u1.id, u2.id, timestamptz '2025-07-25', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Faire installer la machine café -'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'PDJ' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 860
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 860
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 861, e.id, c.id, t.id, 'demander à Hedi de contrôler l''état des crépines, des gouttières et de la descente de pluie et les dégager si beoin', 'a_faire', u1.id, u2.id, timestamptz '2025-07-25', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'demander à Hedi de contrôler l''état des crépines, des gouttières et de la descente de pluie et les dégager si beoin'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'PDJ' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 880, e.id, c.id, t.id, 'acheter crépines pour les 2 gouttières sur le toit terrasse', 'a_acheter', u1.id, u2.id, timestamptz '2025-07-25', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'acheter crépines pour les 2 gouttières sur le toit terrasse'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Toit' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 372, e.id, c.id, t.id, 'Vis du haut de la gâche à changer', 'validee', u1.id, u2.id, timestamptz '2025-07-24', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Vis du haut de la gâche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 372
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 372
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 486, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', u1.id, u2.id, timestamptz '2025-07-24', '2025-04-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '22' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-08', timestamptz '2025-04-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 486
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 486
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 809, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', u1.id, u2.id, timestamptz '2025-07-24', '2025-04-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-08', timestamptz '2025-04-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 809
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 809
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 855, e.id, c.id, t.id, 'bloc secour/batterie a changer (en face de la chambre 14)', 'validee', u1.id, u2.id, timestamptz '2025-07-24', '2025-04-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'bloc secour/batterie a changer (en face de la chambre 14)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Palier 1er' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-08', timestamptz '2025-04-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 855
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 855
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 635, e.id, c.id, t.id, 'Lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2025-11-07', '2025-11-07'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-07', timestamptz '2025-11-07'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 635
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-07'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 635
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 653, e.id, c.id, t.id, 'Lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2025-11-07', '2025-11-07'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-07', timestamptz '2025-11-07'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 653
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-07'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 653
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 670, e.id, c.id, t.id, 'Lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2025-11-07', '2025-11-07'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-07', timestamptz '2025-11-07'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 670
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-07'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 670
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 827, e.id, c.id, t.id, 'Ampoule de la suspension lumineuse à côté de l''ascenseur qui clignote parfois', 'validee', u1.id, u2.id, timestamptz '2025-08-07', '2025-04-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Ampoule de la suspension lumineuse à côté de l''ascenseur qui clignote parfois'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Bagagerie' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'PB non constaté, changement de l''ampoule par précaution', 'utilisateur', u.id, timestamptz '2025-08-07'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 827
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'PB non constaté, changement de l''ampoule par précaution');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-08', timestamptz '2025-04-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 827
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 827
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 577, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', u1.id, u2.id, timestamptz '2025-06-25', '2025-06-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-24', timestamptz '2025-06-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 577
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 577
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 645, e.id, c.id, t.id, 'Lavabo bouché', 'validee', u1.id, u2.id, timestamptz '2025-06-24', '2025-06-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lavabo bouché'
  left join types_intervention t on t.code = 'PLOMBERIE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '44' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-24', timestamptz '2025-06-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 645
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 645
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 833, e.id, c.id, t.id, 'Fil de d''aspirateur à changer', 'validee', u1.id, u2.id, timestamptz '2025-06-24', '2025-06-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Fil de d''aspirateur à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Parties communes' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Fil acheté sur FILFA', 'utilisateur', u.id, timestamptz '2025-06-24'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 833
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Fil acheté sur FILFA');
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Localisation d''origine : Divers', 'reprise', u.id, timestamptz '2025-06-24'
  from anomalies a left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 833
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Localisation d''origine : Divers');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-24', timestamptz '2025-06-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 833
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 833
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 828, e.id, c.id, t.id, 'Spot à changer (celui de droite)', 'validee', u1.id, u2.id, timestamptz '2025-06-21', '2025-04-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à changer (celui de droite)'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'PDJ' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-08', timestamptz '2025-04-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 828
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 828
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 854, e.id, c.id, t.id, 'Spot à changer', 'validee', u1.id, u2.id, timestamptz '2025-06-21', '2025-06-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Office 5 ème étage' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-24', timestamptz '2025-06-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 854
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 854
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 624, e.id, c.id, t.id, 'Joint pour faire tenir le pommeau de douche', 'validee', u1.id, u2.id, timestamptz '2025-09-06', '2025-09-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Joint pour faire tenir le pommeau de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '41' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-26', timestamptz '2025-09-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 624
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 624
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 599, e.id, c.id, t.id, 'Lumiere miroir à vérifier', 'validee', u1.id, u2.id, timestamptz '2025-04-06', '2026-04-29'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lumiere miroir à vérifier'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'prévoir le changement du connecteur de raccordement car ne tient plus - att retour Alain avec fourniture - vu le 4/08', 'utilisateur', u.id, timestamptz '2025-04-06'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 599
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'prévoir le changement du connecteur de raccordement car ne tient plus - att retour Alain avec fourniture - vu le 4/08');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-29', timestamptz '2026-04-29'
  from anomalies a
  left join tournees t on t.reference = 'INT-ALAIN-20260429160344684'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 599
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 599
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 599
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 579, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', u1.id, u2.id, timestamptz '2025-02-06', '2025-04-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-08', timestamptz '2025-04-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 579
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 579
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 663, e.id, c.id, t.id, 'Mur gauche côté fenêtre endommagé', 'a_faire', u1.id, u2.id, timestamptz '2025-02-06', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mur gauche côté fenêtre endommagé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 688, e.id, c.id, t.id, 'Mur gauche côté fenêtre endommagé', 'a_faire', u1.id, u2.id, timestamptz '2025-02-06', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mur gauche côté fenêtre endommagé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 571, e.id, c.id, t.id, 'flexible douche qui fuit', 'validee', u1.id, u2.id, timestamptz '2025-01-06', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche qui fuit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '34' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'flexible remplacé', 'utilisateur', u.id, timestamptz '2025-01-06'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 571
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'flexible remplacé');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 571
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 571
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 813, e.id, c.id, t.id, 'flexible douche qui fuit', 'validee', u1.id, u2.id, timestamptz '2025-01-06', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche qui fuit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '58' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'joint', 'utilisateur', u.id, timestamptz '2025-01-06'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 813
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'joint');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 813
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 813
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 863, e.id, c.id, t.id, 'Porte d''entrée qui grince', 'validee', u1.id, u2.id, timestamptz '2025-01-06', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Porte d''entrée qui grince'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 863
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 863
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 389, e.id, c.id, t.id, 'joint étanchéité pare douche', 'validee', u1.id, u2.id, timestamptz '2025-05-30', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint étanchéité pare douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = null
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 389
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 389
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 578, e.id, c.id, t.id, 'joint étanchéité pare douche', 'validee', u1.id, u2.id, timestamptz '2025-05-30', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint étanchéité pare douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 578
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 578
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 637, e.id, c.id, t.id, 'joint étanchéité pare douche', 'validee', u1.id, u2.id, timestamptz '2025-05-30', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint étanchéité pare douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 637
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 637
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 862, e.id, c.id, t.id, 'recoller les cornières dorées sur les deux pilliers', 'validee', u1.id, u2.id, timestamptz '2025-05-30', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'recoller les cornières dorées sur les deux pilliers'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Lobby' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 862
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 862
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 881, e.id, c.id, t.id, 'Robinet à changer + flexible', 'validee', u1.id, u2.id, timestamptz '2025-05-30', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Robinet à changer + flexible'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'WC Clients' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Remise en état de la douchette ainsi que le flexible et le robinet - victoria a trouvé un robinet ainsi qu''un flexible en stock', 'utilisateur', u.id, timestamptz '2025-05-30'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 881
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Remise en état de la douchette ainsi que le flexible et le robinet - victoria a trouvé un robinet ainsi qu''un flexible en stock');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 881
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 881
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1132, e.id, c.id, t.id, 'Ascenseur en panne - Il faut contacter KONE', 'validee', u1.id, u2.id, timestamptz '2025-05-29', '2025-05-29'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Ascenseur en panne - Il faut contacter KONE'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Ascenseur' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-29', timestamptz '2025-05-29'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien Kone'
  where a.sharepoint_id = 1132
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1132
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2025-05-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 1132
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 1134, e.id, c.id, t.id, 'Ascenseur en panne - Il faut contacter KONE', 'validee', u1.id, u2.id, timestamptz '2025-05-21', '2025-05-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Ascenseur en panne - Il faut contacter KONE'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Ascenseur' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-23', timestamptz '2025-05-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Technicien Kone'
  where a.sharepoint_id = 1134
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 1134
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2025-05-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 1134
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 559, e.id, c.id, t.id, 'flexible douche à changer', 'validee', u1.id, u2.id, timestamptz '2025-05-20', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '32' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'N''a pas eu besoin de changer le flexible - joint effectué', 'utilisateur', u.id, timestamptz '2025-05-20'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 559
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'N''a pas eu besoin de changer le flexible - joint effectué');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 559
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 559
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 636, e.id, c.id, t.id, 'joint sillicone lavabo et douche', 'validee', u1.id, u2.id, timestamptz '2025-05-20', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint sillicone lavabo et douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '42' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 636
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 636
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 694, e.id, c.id, t.id, 'joint sillicone lavabo douche et WC', 'validee', u1.id, u2.id, timestamptz '2025-05-20', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint sillicone lavabo douche et WC'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 694
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 694
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 708, e.id, c.id, t.id, 'joint sillicone lavabo', 'validee', u1.id, u2.id, timestamptz '2025-05-20', '2025-06-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint sillicone lavabo'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '48' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-24', timestamptz '2025-06-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 708
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 708
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 586, e.id, c.id, t.id, 'Bouton pour le mitigeur douche à changer', 'a_faire', u1.id, u2.id, timestamptz '2025-05-19', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Bouton pour le mitigeur douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '35' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 659, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', u1.id, u2.id, timestamptz '2025-05-18', '2025-05-20'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-20', timestamptz '2025-05-20'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 659
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 659
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 522, e.id, c.id, t.id, 'Refixer la prise', 'validee', u1.id, u2.id, timestamptz '2025-05-16', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'refixer la prise'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '26' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 522
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 522
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 829, e.id, c.id, t.id, 'inverser la VMC pour un meilleur fonctionnement', 'a_faire', u1.id, u2.id, timestamptz '2025-05-05', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'inverser la VMC pour un meilleur fonctionnement'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Chaufferie' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'appeler Kamel - à valider avec Marie & Andrea', 'utilisateur', u.id, timestamptz '2025-05-05'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 829
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'appeler Kamel - à valider avec Marie & Andrea');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 552, e.id, c.id, t.id, 'Serrer le bras liseuse côté gauche', 'validee', u1.id, u2.id, timestamptz '2025-04-29', '2025-04-29'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '31' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-29', timestamptz '2025-04-29'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 552
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 552
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 532, e.id, c.id, t.id, 'support de douche à viser', 'validee', u1.id, u2.id, timestamptz '2025-04-24', '2025-04-25'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'support de douche à viser'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '27' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-25', timestamptz '2025-04-25'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = 'Victoria'
  left join prestataires p on p.nom = null
  where a.sharepoint_id = 532
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-25'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 532
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 598, e.id, c.id, t.id, 'Lit côté droit cassé', 'validee', u1.id, u2.id, timestamptz '2025-04-24', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lit côté droit cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Le 29/04/25 Juan a tenté de le faire mais n''avait pas le materiel necessaire Pas d''agrafeuse lors du passage hedi le 18.09', 'utilisateur', u.id, timestamptz '2025-04-24'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 598
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Le 29/04/25 Juan a tenté de le faire mais n''avait pas le materiel necessaire Pas d''agrafeuse lors du passage hedi le 18.09');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 598
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 598
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 544, e.id, c.id, t.id, 'Refixer la liseuse de gauche', 'validee', u1.id, u2.id, timestamptz '2025-04-23', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer la liseuse de gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 544
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 544
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 546, e.id, c.id, t.id, 'Télérupteur à changer - spot et leds', 'validee', u1.id, u2.id, timestamptz '2025-04-22', '2025-04-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur à changer - spot et leds'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-23', timestamptz '2025-04-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 546
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 546
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 847, e.id, c.id, t.id, 'Cache Rosace de la poignée (exterieure) de porte à changer', 'validee', u1.id, u2.id, timestamptz '2025-04-17', '2025-12-23'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Cache Rosace de la poignée (exterieure) de porte à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Local TGBT' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-12-23', timestamptz '2025-12-23'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 847
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-12-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 847
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 482, e.id, c.id, t.id, 'Fissure constaté au plafond', 'a_faire', u1.id, u2.id, timestamptz '2025-04-15', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Fissure constaté au plafond'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '21' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 758, e.id, c.id, t.id, 'télérupteur lumière néons et spots plafond sautent', 'validee', u1.id, u2.id, timestamptz '2025-04-15', '2025-04-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'télérupteur lumière néons et spots plafond sautent'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-18', timestamptz '2025-04-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 758
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 758
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 678, e.id, c.id, t.id, 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', u1.id, u2.id, timestamptz '2025-04-14', '2025-05-14'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remplacer l''économiseur d''énergie pour éclairage principal'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-14', timestamptz '2025-05-14'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 678
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 678
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 477, e.id, c.id, t.id, 'Télérupteur à changer appliques', 'validee', u1.id, u2.id, timestamptz '2025-04-13', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur à changer appliques'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '21' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'contrôle le 14 Avril 2025, plus de pb apparent', 'utilisateur', u.id, timestamptz '2025-04-13'
  from anomalies a left join utilisateurs u on u.nom = 'Miguel'
  where a.sharepoint_id = 477
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'contrôle le 14 Avril 2025, plus de pb apparent');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 566, e.id, c.id, t.id, 'joint sillicone dans le bac à douche', 'validee', u1.id, u2.id, timestamptz '2025-10-04', '2025-04-29'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint sillicone dans le bac à douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '34' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-29', timestamptz '2025-04-29'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 566
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 566
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 603, e.id, c.id, t.id, 'joint sillicone dans le bac à douche', 'validee', u1.id, u2.id, timestamptz '2025-10-04', '2025-04-29'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint sillicone dans le bac à douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '37' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-29', timestamptz '2025-04-29'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 603
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 603
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 613, e.id, c.id, t.id, 'Joint de pare douche à changer', 'validee', u1.id, u2.id, timestamptz '2025-08-04', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Joint de pare douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 613
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 613
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 646, e.id, c.id, t.id, 'joint pare douche à remplacer', 'validee', u1.id, u2.id, timestamptz '2025-08-04', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint pare douche à remplacer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '44' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 646
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 646
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 656, e.id, c.id, t.id, 'Joint pare douche à changer', 'validee', u1.id, u2.id, timestamptz '2025-08-04', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Joint pare douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 656
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 656
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 657, e.id, c.id, t.id, 'remettre le joint noir porte coulissante SDB qui est decollé', 'validee', u1.id, u2.id, timestamptz '2025-08-04', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'remettre le joint noir porte coulissante SDB qui est decollé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 657
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 657
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 673, e.id, c.id, t.id, 'Joint pare douche à changer car laisse passer l''eau', 'validee', u1.id, u2.id, timestamptz '2025-08-04', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Joint pare douche à changer car laisse passer l''eau'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '46' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 673
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 673
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 749, e.id, c.id, t.id, 'joint pare douche à remplacer', 'validee', u1.id, u2.id, timestamptz '2025-08-04', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'joint pare douche à remplacer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 749
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 749
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 750, e.id, c.id, t.id, 'Resserer liseuse côté droit', 'validee', u1.id, u2.id, timestamptz '2025-08-04', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Resserer liseuse côté droit'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 750
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 750
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 776, e.id, c.id, t.id, 'Refixer correctement le miroir grossissant au mur SDB', 'validee', u1.id, u2.id, timestamptz '2025-08-04', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer correctement le miroir grossissant au mur SDB'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '56' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 776
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 776
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 821, e.id, c.id, t.id, '4 eme spot plafond couloir du fond à changer', 'validee', u1.id, u2.id, timestamptz '2025-08-04', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = '4 eme spot plafond couloir du fond à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '4eme étage' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 821
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 821
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 868, e.id, c.id, t.id, 'Resserer liseuse gauche', 'validee', u1.id, u2.id, timestamptz '2025-08-04', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Resserer liseuse gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Réception' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 868
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 868
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 872, e.id, c.id, t.id, 'Système carte pour lumière chambre cassé', 'validee', u1.id, u2.id, timestamptz '2025-08-04', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Système carte pour lumière chambre cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Réception' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'à commander dormakaba Sarah ? - en déjà en stock', 'utilisateur', u.id, timestamptz '2025-08-04'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 872
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'à commander dormakaba Sarah ? - en déjà en stock');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 373, e.id, c.id, t.id, 'Flexible douche à changer', 'validee', u1.id, u2.id, timestamptz '2025-07-04', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 373
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 373
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 592, e.id, c.id, t.id, 'Refixer la liseuse de gauche', 'validee', u1.id, u2.id, timestamptz '2025-07-04', '2025-04-29'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Refixer la liseuse de gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '36' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-29', timestamptz '2025-04-29'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 592
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 592
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 612, e.id, c.id, t.id, 'Refixer la liseuse de droite', 'validee', u1.id, u2.id, timestamptz '2025-07-04', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'refixer la liseuse de droite'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 612
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 612
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 797, e.id, c.id, t.id, 'Charnière de la porte du bas à changer', 'a_faire', u1.id, u2.id, timestamptz '2025-07-04', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Charnière de la porte du bas à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 424, e.id, c.id, t.id, 'Joint pare douche', 'validee', u1.id, u2.id, timestamptz '2025-01-04', '2025-09-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Joint pare douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-26', timestamptz '2025-09-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 424
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 424
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 443, e.id, c.id, t.id, 'flexible douche à changer', 'validee', u1.id, u2.id, timestamptz '2025-01-04', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'flexible douche à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '15' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Apres verification par Victoria, il faut fixer de nouveau le flexible parce que ça fuit encore - Victoria l''a changé le 15/04/25 il faut juste verifier si c''est bien fait', 'utilisateur', u.id, timestamptz '2025-01-04'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 443
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Apres verification par Victoria, il faut fixer de nouveau le flexible parce que ça fuit encore - Victoria l''a changé le 15/04/25 il faut juste verifier si c''est bien fait');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 443
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 443
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 699, e.id, c.id, t.id, 'repeindre porte chambre côté extèrieur', 'a_faire', u1.id, u2.id, timestamptz '2025-01-04', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'repeindre porte chambre côté extèrieur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-11-05', timestamptz '2026-11-05'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511114443975'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 699
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-11-05'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 699
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-14'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 699
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 748, e.id, c.id, t.id, 'Joint pare douche', 'validee', u1.id, u2.id, timestamptz '2025-01-04', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Joint pare douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 748
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 748
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 761, e.id, c.id, t.id, 'Réparer fissure cadre fenêtre chambre avec pâte à bois et repeindre', 'a_faire', u1.id, u2.id, timestamptz '2025-01-04', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Réparer fissure cadre fenêtre chambre avec pâte à bois et repeindre'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 796, e.id, c.id, t.id, 'reprendre peinture cause éclat mur dessous TV', 'a_faire', u1.id, u2.id, timestamptz '2025-01-04', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'reprendre peinture cause éclat mur dessous TV'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = '57' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 871, e.id, c.id, t.id, 'spot dans le lobby devant la cuisine', 'validee', u1.id, u2.id, timestamptz '2025-01-04', '2025-05-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'spot dans le lobby devant la cuisine'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Réception' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Pb d''electricité - pas de jus, voir avec Alain - le 21/05/25 alain a changé le transfo', 'utilisateur', u.id, timestamptz '2025-01-04'
  from anomalies a left join utilisateurs u on u.nom = 'Sarah P'
  where a.sharepoint_id = 871
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Pb d''electricité - pas de jus, voir avec Alain - le 21/05/25 alain a changé le transfo');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-21', timestamptz '2025-05-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 871
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 871
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 545, e.id, c.id, t.id, 'Télérupteur à changer - appliques murales sautent', 'validee', u1.id, u2.id, timestamptz '2025-03-25', '2025-05-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur à changer - appliques murales sautent'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '28' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'att commande et livraison télérupteurs Alain - le 21/05/25 alain a ramener les télérupteurs (aucune sortie de stock), ils seront peut etre inclus dans la facture', 'utilisateur', u.id, timestamptz '2025-03-25'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 545
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'att commande et livraison télérupteurs Alain - le 21/05/25 alain a ramener les télérupteurs (aucune sortie de stock), ils seront peut etre inclus dans la facture');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-21', timestamptz '2025-05-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 545
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 545
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 553, e.id, c.id, t.id, 'télérupteur lumière néons et spots plafond sautent', 'validee', u1.id, u2.id, timestamptz '2025-03-25', '2025-04-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'télérupteur lumière néons et spots plafond sautent'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '31' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-04-18', timestamptz '2025-04-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 553
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-04-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 553
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 740, e.id, c.id, t.id, 'Télérupteur à changer lumière appliques murales saute', 'validee', u1.id, u2.id, timestamptz '2025-03-25', '2025-05-21'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Télérupteur à changer lumière appliques murales saute'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '52' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'le 21/05/25 alain a ramener les télérupteurs (aucune sortie de stock), ils seront peut etre inclus dans la facture', 'utilisateur', u.id, timestamptz '2025-03-25'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 740
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'le 21/05/25 alain a ramener les télérupteurs (aucune sortie de stock), ils seront peut etre inclus dans la facture');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-21', timestamptz '2025-05-21'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 740
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-21'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 740
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 870, e.id, c.id, t.id, 'Spot côté gauche du bar à changer', 'validee', u1.id, u2.id, timestamptz '2025-03-24', '2025-01-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot côté gauche du bar à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Sarah P'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Réception' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-04', timestamptz '2025-01-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 870
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 870
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 978, e.id, c.id, t.id, 'Lavabo qui coule', 'validee', u1.id, u2.id, timestamptz '2025-03-23', '2026-04-27'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lavabo qui coule'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Miguel'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '38' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-23', timestamptz '2026-04-23'
  from anomalies a
  left join tournees t on t.reference = 'INT-Serafino-20260511103458060'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Serafino'
  where a.sharepoint_id = 978
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-23'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 978
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-27'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 978
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 849, e.id, c.id, t.id, 'Réparation de la poignée de porte du TGBT', 'validee', u1.id, u2.id, timestamptz '2025-03-20', '2025-03-20'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Réparation de la poignée de porte du TGBT'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'MR NEGRONI'
  left join utilisateurs u2 on u2.nom = 'Sarah P'
  where e.code = 'Local TGBT' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-03-20', timestamptz '2025-03-20'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'MR NEGRONI'
  where a.sharepoint_id = 849
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-03-20'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 849
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 757, e.id, c.id, t.id, 'Evier qui coule', 'validee', u1.id, u2.id, timestamptz '2025-12-03', '2025-05-08'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Evier qui coule'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '54' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-08', timestamptz '2025-05-08'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 757
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-08'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 757
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 378, e.id, c.id, t.id, 'changer connecteur lumiéres miroir SDB', 'validee', u1.id, u2.id, timestamptz '2025-11-03', '2026-04-29'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'changer connecteur lumiéres miroir SDB'
  left join types_intervention t on t.code = 'ELECTRIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2026-04-29', timestamptz '2026-04-29'
  from anomalies a
  left join tournees t on t.reference = 'INT-ALAIN-20260429160344684'
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'ALAIN'
  where a.sharepoint_id = 378
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2026-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 378
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-04-29'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 378
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 381, e.id, c.id, t.id, 'Lit côté gauche cassé', 'validee', u1.id, u2.id, timestamptz '2025-11-03', '2025-09-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'lit côté gauche cassé'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '02' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'pas d''agrafeuse sur lui le 18.09 - prochain passage', 'utilisateur', u.id, timestamptz '2025-11-03'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 381
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'pas d''agrafeuse sur lui le 18.09 - prochain passage');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-26', timestamptz '2025-09-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 381
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 381
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 390, e.id, c.id, t.id, 'Serrer le bras liseuse côté gauche', 'validee', u1.id, u2.id, timestamptz '2025-11-03', '2025-08-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'serrer le bras liseuse côté gauche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-08-04', timestamptz '2025-08-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 390
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-08-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 390
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 436, e.id, c.id, t.id, 'Joint pare douche', 'validee', u1.id, u2.id, timestamptz '2025-11-03', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Joint pare douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '15' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Pas besoin selon visite HEDI le 5/08 -Pas de solution perenne / baghuette propre', 'utilisateur', u.id, timestamptz '2025-11-03'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 436
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Pas besoin selon visite HEDI le 5/08 -Pas de solution perenne / baghuette propre');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 655, e.id, c.id, t.id, 'Lavabo qui coule', 'validee', u1.id, u2.id, timestamptz '2025-11-03', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Lavabo qui coule'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '45' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Aucune fuite constatée lors du passage du 08/04/25', 'utilisateur', u.id, timestamptz '2025-11-03'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 655
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Aucune fuite constatée lors du passage du 08/04/25');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 818, e.id, c.id, t.id, 'Spot à coté de l''ascenseur à changer', 'validee', u1.id, u2.id, timestamptz '2025-11-03', '2025-01-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot à coté de l''ascenseur à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = 'Palier 1er' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-04', timestamptz '2025-01-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 818
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 818
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 858, e.id, c.id, t.id, 'Spot devant la chambre 34 à changer', 'validee', u1.id, u2.id, timestamptz '2025-11-03', '2025-01-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot devant la chambre 34 à changer'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '3eme étage' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-04', timestamptz '2025-01-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 858
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 858
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 690, e.id, c.id, t.id, 'Mettre une vis pour l''aimant de la porte dorée armoire (bas)', 'validee', u1.id, u2.id, timestamptz '2025-02-21', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre une vis pour l''aimant de la porte dorée armoire (bas)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 690
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 690
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 698, e.id, c.id, t.id, 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)', 'validee', u1.id, u2.id, timestamptz '2025-02-21', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Miguel'
  where e.code = '47' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, '26/09/25 - Hedi dit que quelqu''un l''a lors de son passage,', 'utilisateur', u.id, timestamptz '2025-02-21'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 698
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = '26/09/25 - Hedi dit que quelqu''un l''a lors de son passage,');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 371, e.id, c.id, t.id, 'Recoller la plinthe bois noire porte SDB côté SDB', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-09-18'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Recoller la plinthe bois noire porte SDB côté SDB'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 371
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 371
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 374, e.id, c.id, t.id, 'URGENT - Joints sillicone douche - lavabo et WC à refaire complètement', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'urgent - joints sillicone douche - lavabo et wc à refaire complètement'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 374
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 374
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 377, e.id, c.id, t.id, 'Difficulté à fermer la porte de chambre -', 'validee', u1.id, u2.id, timestamptz '2025-02-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'difficulté à fermer la porte de chambre -'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '01' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 382, e.id, c.id, t.id, 'URGENT - Joints sillicone douche et lavabo à refaire complètement', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'URGENT - Joints sillicone douche et lavabo à refaire complètement'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '02' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 382
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 382
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 388, e.id, c.id, t.id, 'URGENT - Joints sillicone douche - lavabo & WC', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-05-30'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'URGENT - Joints sillicone douche - lavabo & WC'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '03' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-05-30', timestamptz '2025-05-30'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 388
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-05-30'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 388
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 401, e.id, c.id, t.id, 'Remettre le joint porte coulissante de la salle de bains - côté chambre', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-06-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Remettre le joint porte coulissante de la salle de bains - côté chambre'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-24', timestamptz '2025-06-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 401
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 401
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 402, e.id, c.id, t.id, 'URGENT - Joints sillicone douche', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-06-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'urgent - joints sillicone douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-24', timestamptz '2025-06-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 402
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 402
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 408, e.id, c.id, t.id, 'Bouton pour le mitigeur douche à acheter car il n''y en a plus', 'a_acheter', u1.id, u2.id, timestamptz '2025-02-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Bouton pour le mitigeur douche à acheter car il n''y en a plus'
  left join types_intervention t on t.code = 'ACHATS'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'selon Hedi, pas possible de dévisser - il faudrait changer le mitigeur complet', 'utilisateur', u.id, timestamptz '2025-02-18'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 408
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'selon Hedi, pas possible de dévisser - il faudrait changer le mitigeur complet');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 410, e.id, c.id, t.id, 'Changer le miroir SDB car rouillé de l''interieur', 'a_acheter', u1.id, u2.id, timestamptz '2025-02-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Changer le miroir SDB car rouillé de l''interieur'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '11' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'A voir avec Marie & Andrea si on change le miroir', 'utilisateur', u.id, timestamptz '2025-02-18'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 410
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'A voir avec Marie & Andrea si on change le miroir');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 414, e.id, c.id, t.id, 'URGENT - Joints sillicone douche et lavabo à refaire complètement', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-06-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'URGENT - Joints sillicone douche et lavabo à refaire complètement'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-24', timestamptz '2025-06-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 414
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 414
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 422, e.id, c.id, t.id, 'Bouton pour le mitigeur douche à acheter car il n''y en a plus', 'a_acheter', u1.id, u2.id, timestamptz '2025-02-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Bouton pour le mitigeur douche à acheter car il n''y en a plus'
  left join types_intervention t on t.code = 'ACHATS'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '12' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'selon Hedi, pas possible de dévisser - il faudrait changer le mitigeur complet', 'utilisateur', u.id, timestamptz '2025-02-18'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 422
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'selon Hedi, pas possible de dévisser - il faudrait changer le mitigeur complet');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 423, e.id, c.id, t.id, 'URGENT - Joints sillicone douche - lavabo', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-09-26'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'URGENT - Joints sillicone douche - lavabo'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-26', timestamptz '2025-09-26'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 423
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-26'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 423
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 431, e.id, c.id, t.id, 'Remettre le joint porte coulissante de la salle de bains', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2026-05-02'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Remettre le joint porte coulissante de la salle de bains'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '14' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Hedi aurait remis des joints mais pas ce que nous avons demandé - PAS FAIT - vérif le 15 AOUT - le 18/09/25 Hedi indique que le joint n''est pas utile et nécessiterait de retirer toute la porte pour rien - trop d''heures de travail', 'utilisateur', u.id, timestamptz '2025-02-18'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 431
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Hedi aurait remis des joints mais pas ce que nous avons demandé - PAS FAIT - vérif le 15 AOUT - le 18/09/25 Hedi indique que le joint n''est pas utile et nécessiterait de retirer toute la porte pour rien - trop d''heures de travail');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-09-18', timestamptz '2025-09-18'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 431
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-09-18'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 431
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'gouvernante', 'validee', u.id, timestamptz '2026-05-02'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 431
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'gouvernante');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 441, e.id, c.id, t.id, 'URGENT - Joints sillicone douche et lavabo à refaire complètement', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-01-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'URGENT - Joints sillicone douche et lavabo à refaire complètement'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '15' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-01-04', timestamptz '2025-01-04'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Juan'
  where a.sharepoint_id = 441
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-01-04'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 441
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 442, e.id, c.id, t.id, 'Bouton pour le mitigeur douche à acheter car il n''y en a plus', 'a_acheter', u1.id, u2.id, timestamptz '2025-02-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Bouton pour le mitigeur douche à acheter car il n''y en a plus'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '15' on conflict (sharepoint_id) do nothing;
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 449, e.id, c.id, t.id, 'URGENT - Joints sillicone douche et lavabo à refaire complètement', 'validee', u1.id, u2.id, timestamptz '2025-02-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'URGENT - Joints sillicone douche et lavabo à refaire complètement'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'propre selon Hedi pas besoin de refaire - visite le 5 Aout', 'utilisateur', u.id, timestamptz '2025-02-18'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 449
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'propre selon Hedi pas besoin de refaire - visite le 5 Aout');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 450, e.id, c.id, t.id, 'Mettre un joint pare douche à la bonne taille car pas assez long et l''eau passe', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-06-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Mettre un joint pare douche à la bonne taille car pas assez long et l''eau passe'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-24', timestamptz '2025-06-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 450
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 450
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 453, e.id, c.id, t.id, 'Voir avec miroitier pour miroir placard cassé en bas (grand)', 'annulee', u1.id, u2.id, timestamptz '2025-02-18', null
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'voir avec miroitier pour miroir placard cassé en bas (grand)'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'Annulée à la reprise : le même problème était déjà ouvert ici.', 'reprise', u.id, timestamptz '2025-02-18'
  from anomalies a left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 453
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'Annulée à la reprise : le même problème était déjà ouvert ici.');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 454, e.id, c.id, t.id, 'Joint pour faire tenir le pommeau de douche', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-11-16'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Joint pour faire tenir le pommeau de douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '16' on conflict (sharepoint_id) do nothing;
insert into commentaires (anomalie_id, texte, origine, auteur_id, ecrit_le)
  select a.id, 'RAS selon visite HEDI le 5/08 ( à revérifier par Victoria)', 'utilisateur', u.id, timestamptz '2025-02-18'
  from anomalies a left join utilisateurs u on u.nom = 'Victoria'
  where a.sharepoint_id = 454
    and not exists (select 1 from commentaires x where x.anomalie_id = a.id and x.texte = 'RAS selon visite HEDI le 5/08 ( à revérifier par Victoria)');
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-11-16', timestamptz '2025-11-16'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 454
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-11-16'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 454
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 460, e.id, c.id, t.id, 'URGENT - Joints sillicone douche', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-06-24'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'urgent - joints sillicone douche'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '18' on conflict (sharepoint_id) do nothing;
insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, date_intervention, cree_le) select a.id, t.id, u.id, p.id, date '2025-06-24', timestamptz '2025-06-24'
  from anomalies a
  left join tournees t on t.reference = null
  left join utilisateurs u on u.nom = null
  left join prestataires p on p.nom = 'Hedi'
  where a.sharepoint_id = 460
    and not exists (select 1 from interventions i where i.anomalie_id = a.id);
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le) select i.id, 'technicien', 'fait', u.id, timestamptz '2025-06-24'
  from interventions i join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.nom = null
  where a.sharepoint_id = 460
    and not exists (select 1 from validations v where v.intervention_id = i.id and v.acteur = 'technicien');
insert into anomalies (sharepoint_id, emplacement_id, catalogue_id, type_id, description, statut, constate_par, saisie_par, declare_le, cloture_le) select 467, e.id, c.id, t.id, 'Spot plafond entrée HS', 'validee', u1.id, u2.id, timestamptz '2025-02-18', '2025-01-04'
  from emplacements e
  left join catalogue_anomalies c on c.libelle = 'Spot plafond entrée HS'
  left join types_intervention t on t.code = 'TECHNIQUE'
  left join utilisateurs u1 on u1.nom = 'Victoria'
  left join utilisateurs u2 on u2.nom = 'Victoria'
  where e.code = '18' on conflict (sharepoint_id) do nothing;

alter table validations enable trigger tg_validation_maj_anomalie;
commit;
