-- Généré par outils/importer_stock.py — ne pas modifier à la main.
-- À jouer après donnees/import_anomalies.sql.
-- Produits ------------------------------------------------------------
-- Morceau 2 sur 2 — à jouer dans l'ordre des lettres.

begin;

insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-10-12', u.id, pt.id, e.id, i.id, 'Batterie du bloc secours changé (celui au dessus de la porte d''entrée)'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Lobby'
  left join anomalies a     on a.sharepoint_id = 864
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-30', u.id, pt.id, e.id, i.id, 'Télérupteur à changer (repris de l''ancien tableau technique )'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '12'
  left join anomalies a     on a.sharepoint_id = 419
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'entree', null, 2.0, timestamptz '2024-04-11', u.id, pt.id, e.id, i.id, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'AP-1902-B0002';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'entree', null, 15.0, timestamptz '2024-04-11', u.id, pt.id, e.id, i.id, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'entree', null, 4.0, timestamptz '2024-10-25', u.id, pt.id, e.id, i.id, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-12-10', u.id, pt.id, e.id, i.id, 'Détection de punaises de lit au niveau de la tête de lit constaté le 11/10/24 par la societe Ecoflair'
  from produits pr
  left join utilisateurs u  on u.nom = 'Rachid'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '15'
  left join anomalies a     on a.sharepoint_id = 445
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Stop nuisibles';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-12-10', u.id, pt.id, e.id, i.id, 'Détection de punaises de lit au niveau de la tête de lit constaté le 11/10/24 par la societe Ecoflair'
  from produits pr
  left join utilisateurs u  on u.nom = 'Rachid'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '28'
  left join anomalies a     on a.sharepoint_id = 543
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Stop nuisibles';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-12-10', u.id, pt.id, e.id, i.id, 'Détection de punaises de lit au niveau de la tête de lit constaté le 11/10/24 par la societe Ecoflair'
  from produits pr
  left join utilisateurs u  on u.nom = 'Rachid'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '46'
  left join anomalies a     on a.sharepoint_id = 682
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Stop nuisibles';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-12-10', u.id, pt.id, e.id, i.id, 'Détection de punaises de lit au niveau de la tête de lit constaté le 11/10/24 par la societe Ecoflair'
  from produits pr
  left join utilisateurs u  on u.nom = 'Rachid'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '48'
  left join anomalies a     on a.sharepoint_id = 714
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Stop nuisibles';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'entree', null, 37.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '01'
  left join anomalies a     on a.sharepoint_id = 375
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '02'
  left join anomalies a     on a.sharepoint_id = 383
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '03'
  left join anomalies a     on a.sharepoint_id = 393
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '11'
  left join anomalies a     on a.sharepoint_id = 405
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '12'
  left join anomalies a     on a.sharepoint_id = 418
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '14'
  left join anomalies a     on a.sharepoint_id = 432
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '15'
  left join anomalies a     on a.sharepoint_id = 437
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '16'
  left join anomalies a     on a.sharepoint_id = 451
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '18'
  left join anomalies a     on a.sharepoint_id = 464
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '21'
  left join anomalies a     on a.sharepoint_id = 479
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '22'
  left join anomalies a     on a.sharepoint_id = 487
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '24'
  left join anomalies a     on a.sharepoint_id = 499
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '25'
  left join anomalies a     on a.sharepoint_id = 513
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '26'
  left join anomalies a     on a.sharepoint_id = 519
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '27'
  left join anomalies a     on a.sharepoint_id = 526
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '28'
  left join anomalies a     on a.sharepoint_id = 540
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '31'
  left join anomalies a     on a.sharepoint_id = 555
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '32'
  left join anomalies a     on a.sharepoint_id = 562
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '34'
  left join anomalies a     on a.sharepoint_id = 569
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '35'
  left join anomalies a     on a.sharepoint_id = 580
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '36'
  left join anomalies a     on a.sharepoint_id = 596
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '37'
  left join anomalies a     on a.sharepoint_id = 604
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '38'
  left join anomalies a     on a.sharepoint_id = 617
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '41'
  left join anomalies a     on a.sharepoint_id = 630
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '42'
  left join anomalies a     on a.sharepoint_id = 639
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '44'
  left join anomalies a     on a.sharepoint_id = 647
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '45'
  left join anomalies a     on a.sharepoint_id = 660
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '46'
  left join anomalies a     on a.sharepoint_id = 679
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '47'
  left join anomalies a     on a.sharepoint_id = 696
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '48'
  left join anomalies a     on a.sharepoint_id = 711
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '51'
  left join anomalies a     on a.sharepoint_id = 721
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '52'
  left join anomalies a     on a.sharepoint_id = 735
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '54'
  left join anomalies a     on a.sharepoint_id = 753
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '55'
  left join anomalies a     on a.sharepoint_id = 768
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '56'
  left join anomalies a     on a.sharepoint_id = 781
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '57'
  left join anomalies a     on a.sharepoint_id = 794
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '58'
  left join anomalies a     on a.sharepoint_id = 810
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-07-10', u.id, pt.id, e.id, i.id, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = 'Cuisine'
  left join anomalies a     on a.sharepoint_id = 832
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-07-10', u.id, pt.id, e.id, i.id, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Parties communes'
  left join anomalies a     on a.sharepoint_id = 836
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-07-10', u.id, pt.id, e.id, i.id, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Escalier qui mène au RDC'
  left join anomalies a     on a.sharepoint_id = 841
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-07-10', u.id, pt.id, e.id, i.id, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Palier 1er'
  left join anomalies a     on a.sharepoint_id = 856
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-07-10', u.id, pt.id, e.id, i.id, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Palier 5ème'
  left join anomalies a     on a.sharepoint_id = 857
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-07-10', u.id, pt.id, e.id, i.id, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Salle de sport'
  left join anomalies a     on a.sharepoint_id = 874
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'entree', null, 10.0, timestamptz '2024-09-30', u.id, pt.id, e.id, i.id, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-09-21', u.id, pt.id, e.id, i.id, 'Télérupteur à changer (repris de l''ancien tableau technique )'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '11'
  left join anomalies a     on a.sharepoint_id = 406
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-09-21', u.id, pt.id, e.id, i.id, 'Télérupteur à changer (repris de l''ancien tableau technique )'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '31'
  left join anomalies a     on a.sharepoint_id = 554
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-09-21', u.id, pt.id, e.id, i.id, 'Télérupteur à changer (repris de l''ancien tableau technique )'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '47'
  left join anomalies a     on a.sharepoint_id = 695
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-09-21', u.id, pt.id, e.id, i.id, 'Télérupteur à changer (repris de l''ancien tableau technique )'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '57'
  left join anomalies a     on a.sharepoint_id = 792
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-08-08', u.id, pt.id, e.id, i.id, 'Télérupteur à changer (repris de l''ancien tableau technique )'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '41'
  left join anomalies a     on a.sharepoint_id = 629
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'entree', null, 10.0, timestamptz '2024-06-08', u.id, pt.id, e.id, i.id, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'entree', null, 4.0, timestamptz '2024-06-08', u.id, pt.id, e.id, i.id, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW05';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'entree', null, 7.0, timestamptz '2024-06-08', u.id, pt.id, e.id, i.id, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2024-07-26', u.id, pt.id, e.id, i.id, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = '900259NUM';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2000-01-20', u.id, pt.id, e.id, i.id, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Aliseo (160162) Steamwororks';

commit;


-- Trace de passage : c'est elle que lit 0-ou-en-suis-je.sql.
create table if not exists installation_journal (
  fichier  text primary key,
  joue_le  timestamptz not null default now()
);
insert into installation_journal (fichier) values ('3-stock-b.sql')
  on conflict (fichier) do update set joue_le = now();

select '3-stock-b.sql' as "Fichier joué", (select count(*) || ' produits sur 36' from produits) as "Où ça en est";
