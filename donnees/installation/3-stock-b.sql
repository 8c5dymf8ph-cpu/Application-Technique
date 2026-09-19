-- Généré par outils/importer_stock.py — ne pas modifier à la main.
-- À jouer après donnees/import_anomalies.sql.
-- Produits ------------------------------------------------------------
-- Morceau 2 sur 2 — à jouer dans l'ordre des lettres.

begin;

insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 5.0, timestamptz '2024-12-20', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = '8222107';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-12-13', u.id, pt.id, e.id, i.id, null, 'Changement du séche cheveux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '15'
  left join anomalies a     on a.sharepoint_id = 439
  left join interventions i on i.anomalie_id = a.id
  where pr.code = '8222107';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-12-13', u.id, pt.id, e.id, i.id, null, 'Changement du séche cheveux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '28'
  left join anomalies a     on a.sharepoint_id = 539
  left join interventions i on i.anomalie_id = a.id
  where pr.code = '8222107';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-12-13', u.id, pt.id, e.id, i.id, null, 'Changement du séche cheveux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '32'
  left join anomalies a     on a.sharepoint_id = 561
  left join interventions i on i.anomalie_id = a.id
  where pr.code = '8222107';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 3.0, timestamptz '2024-11-12', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = '8222107';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-10-12', u.id, pt.id, e.id, i.id, null, 'Remplacement bras de liseuse (coté gauche)'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '03'
  left join anomalies a     on a.sharepoint_id = 397
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-10-12', u.id, pt.id, e.id, i.id, null, 'Remplacement du télérupteur (TETE DE LIT appliques)'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '25'
  left join anomalies a     on a.sharepoint_id = 512
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-10-12', u.id, pt.id, e.id, i.id, null, 'Remplacement du télérupteur (TETE DE LIT)'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '34'
  left join anomalies a     on a.sharepoint_id = 567
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-10-12', u.id, pt.id, e.id, i.id, null, 'Batterie du bloc secours changé (celui au dessus de la porte d''entrée)'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Lobby'
  left join anomalies a     on a.sharepoint_id = 864
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-30', u.id, pt.id, e.id, i.id, null, 'Télérupteur à changer (repris de l''ancien tableau technique )'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '12'
  left join anomalies a     on a.sharepoint_id = 419
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 2.0, timestamptz '2024-04-11', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'AP-1902-B0002';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 15.0, timestamptz '2024-04-11', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 4.0, timestamptz '2024-10-25', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-12-10', u.id, pt.id, e.id, i.id, null, 'Détection de punaises de lit au niveau de la tête de lit constaté le 11/10/24 par la societe Ecoflair'
  from produits pr
  left join utilisateurs u  on u.nom = 'Rachid'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '15'
  left join anomalies a     on a.sharepoint_id = 445
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Stop nuisibles';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-12-10', u.id, pt.id, e.id, i.id, null, 'Détection de punaises de lit au niveau de la tête de lit constaté le 11/10/24 par la societe Ecoflair'
  from produits pr
  left join utilisateurs u  on u.nom = 'Rachid'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '28'
  left join anomalies a     on a.sharepoint_id = 543
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Stop nuisibles';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-12-10', u.id, pt.id, e.id, i.id, null, 'Détection de punaises de lit au niveau de la tête de lit constaté le 11/10/24 par la societe Ecoflair'
  from produits pr
  left join utilisateurs u  on u.nom = 'Rachid'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '46'
  left join anomalies a     on a.sharepoint_id = 682
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Stop nuisibles';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-12-10', u.id, pt.id, e.id, i.id, null, 'Détection de punaises de lit au niveau de la tête de lit constaté le 11/10/24 par la societe Ecoflair'
  from produits pr
  left join utilisateurs u  on u.nom = 'Rachid'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '48'
  left join anomalies a     on a.sharepoint_id = 714
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Stop nuisibles';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 37.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '01'
  left join anomalies a     on a.sharepoint_id = 375
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '02'
  left join anomalies a     on a.sharepoint_id = 383
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '03'
  left join anomalies a     on a.sharepoint_id = 393
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '11'
  left join anomalies a     on a.sharepoint_id = 405
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '12'
  left join anomalies a     on a.sharepoint_id = 418
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '14'
  left join anomalies a     on a.sharepoint_id = 432
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '15'
  left join anomalies a     on a.sharepoint_id = 437
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '16'
  left join anomalies a     on a.sharepoint_id = 451
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '18'
  left join anomalies a     on a.sharepoint_id = 464
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '21'
  left join anomalies a     on a.sharepoint_id = 479
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '22'
  left join anomalies a     on a.sharepoint_id = 487
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '24'
  left join anomalies a     on a.sharepoint_id = 499
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '25'
  left join anomalies a     on a.sharepoint_id = 513
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '26'
  left join anomalies a     on a.sharepoint_id = 519
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '27'
  left join anomalies a     on a.sharepoint_id = 526
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '28'
  left join anomalies a     on a.sharepoint_id = 540
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '31'
  left join anomalies a     on a.sharepoint_id = 555
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '32'
  left join anomalies a     on a.sharepoint_id = 562
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '34'
  left join anomalies a     on a.sharepoint_id = 569
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '35'
  left join anomalies a     on a.sharepoint_id = 580
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '36'
  left join anomalies a     on a.sharepoint_id = 596
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '37'
  left join anomalies a     on a.sharepoint_id = 604
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '38'
  left join anomalies a     on a.sharepoint_id = 617
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '41'
  left join anomalies a     on a.sharepoint_id = 630
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '42'
  left join anomalies a     on a.sharepoint_id = 639
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '44'
  left join anomalies a     on a.sharepoint_id = 647
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '45'
  left join anomalies a     on a.sharepoint_id = 660
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '46'
  left join anomalies a     on a.sharepoint_id = 679
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '47'
  left join anomalies a     on a.sharepoint_id = 696
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '48'
  left join anomalies a     on a.sharepoint_id = 711
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '51'
  left join anomalies a     on a.sharepoint_id = 721
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '52'
  left join anomalies a     on a.sharepoint_id = 735
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '54'
  left join anomalies a     on a.sharepoint_id = 753
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '55'
  left join anomalies a     on a.sharepoint_id = 768
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '56'
  left join anomalies a     on a.sharepoint_id = 781
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '57'
  left join anomalies a     on a.sharepoint_id = 794
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-11-10', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '58'
  left join anomalies a     on a.sharepoint_id = 810
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-07-10', u.id, pt.id, e.id, i.id, null, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = 'Cuisine'
  left join anomalies a     on a.sharepoint_id = 832
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-07-10', u.id, pt.id, e.id, i.id, null, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Parties communes'
  left join anomalies a     on a.sharepoint_id = 836
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-07-10', u.id, pt.id, e.id, i.id, null, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Escalier qui mène au RDC'
  left join anomalies a     on a.sharepoint_id = 841
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-07-10', u.id, pt.id, e.id, i.id, null, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Palier 1er'
  left join anomalies a     on a.sharepoint_id = 856
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-07-10', u.id, pt.id, e.id, i.id, null, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Palier 5ème'
  left join anomalies a     on a.sharepoint_id = 857
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2024-07-10', u.id, pt.id, e.id, i.id, null, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Salle de sport'
  left join anomalies a     on a.sharepoint_id = 874
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 10.0, timestamptz '2024-09-30', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-09-21', u.id, pt.id, e.id, i.id, null, 'Télérupteur à changer (repris de l''ancien tableau technique )'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '11'
  left join anomalies a     on a.sharepoint_id = 406
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-09-21', u.id, pt.id, e.id, i.id, null, 'Télérupteur à changer (repris de l''ancien tableau technique )'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '31'
  left join anomalies a     on a.sharepoint_id = 554
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-09-21', u.id, pt.id, e.id, i.id, null, 'Télérupteur à changer (repris de l''ancien tableau technique )'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '47'
  left join anomalies a     on a.sharepoint_id = 695
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-09-21', u.id, pt.id, e.id, i.id, null, 'Télérupteur à changer (repris de l''ancien tableau technique )'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '57'
  left join anomalies a     on a.sharepoint_id = 792
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2024-08-08', u.id, pt.id, e.id, i.id, null, 'Télérupteur à changer (repris de l''ancien tableau technique )'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '41'
  left join anomalies a     on a.sharepoint_id = 629
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 10.0, timestamptz '2024-06-08', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 4.0, timestamptz '2024-06-08', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW05';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 7.0, timestamptz '2024-06-08', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2024-07-26', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = '900259NUM';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2000-01-20', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Aliseo (160162) Steamwororks';
-- Recalage de reprise --------------------------------------------------
-- L'ancienne application ignorait les mouvements marqués « historique » ;
-- son stock affiché vaut donc Stock_Initial plus les seuls mouvements
-- récents. On vise ce chiffre, et l'écart devient une régularisation.
with cible (code, stock_vise) as (values
  ('Transfo Spot', 4.0),
  ('Applique', 1.0),
  ('NI-Cd 2,4V 1,5AH (URA)', 3.0),
  ('NI-Cd 2,4V 1,5AH (URA) - Local TGBT', 0),
  ('ALI170281 (Aficom)', 1.0),
  ('Butée (dorée)', 1.0),
  ('CABLE1532MM', 0),
  ('DAIKIN', 2.0),
  ('EURO W4 (EUROPROH)', 1.0),
  ('Ecoflair', 0),
  ('EFA21031 (économisseur)', 20.0),
  ('EFA90731TPM (enjoliveur porte carte)', 3.0),
  ('Aliseo (160162) Steamwororks', 1.0),
  ('Inconnu', -42.0),
  ('DORNBRACHT-28322970-33', 0),
  ('Modélé inconnu (flexible)', 0),
  ('Interupteur', 4.0),
  ('8222107', 2.0),
  ('AP-1902-B0002', 9.0),
  ('SE1241LTB', 2.0),
  ('900259NUM', 0),
  ('Aliseo (030692)', 2.0),
  ('DORN-0000', 0),
  ('Hansgrohe', 2.0),
  ('Silva', 0),
  ('DO54505', 10.0),
  ('11017B', 3.0),
  ('DO467WW30', 0),
  ('DO467WW05', 6.0),
  ('Inconnu-2', 6.0),
  ('AMS Brass Toilet roll holder (ams-sw034-PB)', 10.0),
  ('Aliseo (030706)', 3.0),
  ('Rousseau', 1.0),
  ('EPS410B', 0),
  ('EPN510', 20.0),
  ('Stop nuisibles', 0)
)
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement,
                              utilisateur_id, inventaire_id, commentaire)
select p.id, 'regularisation', 'inventaire',
       c.stock_vise - coalesce(sum(m.quantite), 0),
       now(), u.id, 'cccccccc-0000-0000-0000-000000000001',
       'Reprise : recalage sur le stock affiché avant la bascule'
from produits p
join cible c on c.code = p.code
left join mouvements_stock m on m.produit_id = p.id
left join utilisateurs u on u.nom = 'Miguel'
group by p.id, c.stock_vise, u.id
having c.stock_vise - coalesce(sum(m.quantite), 0) <> 0;

commit;


-- Trace de passage : c'est elle que lit 0-ou-en-suis-je.sql.
create table if not exists installation_journal (
  fichier  text primary key,
  joue_le  timestamptz not null default now()
);
insert into installation_journal (fichier) values ('3-stock-b.sql')
  on conflict (fichier) do update set joue_le = now();

select '3-stock-b.sql' as "Fichier joué", (select count(*) || ' produits sur 36' from produits) as "Où ça en est";
