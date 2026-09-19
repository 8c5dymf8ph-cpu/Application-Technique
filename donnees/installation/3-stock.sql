-- Généré par outils/importer_stock.py — ne pas modifier à la main.
-- À jouer après donnees/import_anomalies.sql.

begin;

-- Produits ------------------------------------------------------------
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Transfo Spot', 'Transfo pour Spot', 'Électricité', 'Chambre', null, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Applique', 'Applique Murale étage', 'Equipments', 'Chambre', null, 7.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('NI-Cd 2,4V 1,5AH (URA)', 'Batteries Telec', 'Électricité', 'General', 74.0, 6.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('NI-Cd 2,4V 1,5AH (URA) - Local TGBT', 'Batteries Telec (LOCAL TGBT)', 'Électricité', 'General', 165.0, 3.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('ALI170281 (Aficom)', 'BOUILLOIRE BONJOUR 600ML NOIR MAT ALISEO', 'Equipments', 'Chambre', 55.25, 6.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Butée (dorée)', 'Butée de porte', 'Serrurerie', 'Chambre', null, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('CABLE1532MM', 'Cable aspirateur 15 mètres - 32 mm (pour Nupro)', 'Equipments', 'General', 30.36, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('DAIKIN', 'Cache qui se fixe sur le panneau de contrôle du boîtier de la climatisation', 'Électricité', 'Chambre', null, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('EURO W4 (EUROPROH)', 'Coffre-Fort (EUROPROH)', 'Equipments', 'Chambre', 109.0, 3.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Ecoflair', 'Détection Canine', 'Divers', 'General', 34.0, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('EFA21031 (économisseur)', 'Économisseur d''énergie', 'Électricité', 'Chambre', 10.17, 5.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('EFA90731TPM (enjoliveur porte carte)', 'Enjoliveur Noir (Porte carte)', 'Électricité', 'Chambre', 6.66, 5.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Aliseo (160162) Steamwororks', 'Fer à repasser', 'Equipments', 'General', null, 4.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Inconnu', 'Flexible (Fournis par Serafino)', 'Plomberie', 'Salle de Bain', null, 4.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('DORNBRACHT-28322970-33', 'Flexible de douche (stockB)', 'Plomberie', 'Salle de Bain', 142.5, 6.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Modélé inconnu (flexible)', 'flexibles douche ( noirs )', 'Plomberie', 'Salle de Bain', null, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Interupteur', 'Interupteur', 'Électricité', 'General', null, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('8222107', 'JVD - seche cheveux - Filfa', 'Equipments', 'Salle de Bain', 94.05, 3.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('AP-1902-B0002', 'Liseuses  (flexibles)', 'Électricité', 'Chambre', 216.0, 8.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('SE1241LTB', 'Liseuses (Flexible + Source) - Brossier Saderne', 'Électricité', 'Chambre', 25.0, 8.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('900259NUM', 'NUMATIC - Pro NUV 180 Reflo - Aspirateur (Filfa)', 'Equipments', 'General', 129.0, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Aliseo (030692)', 'Petite poubelle de 3L (Aficom)', 'Equipments', 'Chambre', null, 1.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('DORN-0000', 'Piéce Detachée pour Thermostatique en noir matt (Stock B)', 'Électricité', 'Chambre', null, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Hansgrohe', 'Pommeau de douche', 'Equipments', 'Salle de Bain', null, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Silva', 'Silva - Rideaux', 'Equipments', 'Chambre', 75.0, 5.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('DO54505', 'Spot étanche (Yess Electrique)', 'Électricité', 'General', 15.95, 4.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('11017B', 'Spot Spider 8W (Eva Lighting)', 'Électricité', 'General', null, 1.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('DO467WW30', 'spots blanc (yess electrique)', 'Électricité', 'General', 37.4, 4.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('DO467WW05', 'spots noir (yess electrique)', 'Électricité', 'General', 37.4, 4.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Inconnu-2', 'Support gel douche', 'Equipments', 'Salle de Bain', null, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('AMS Brass Toilet roll holder (ams-sw034-PB)', 'Support papier toilette', 'Equipments', 'Salle de Bain', null, 3.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Aliseo (030706)', 'Support Savon triangle', 'Equipments', 'Salle de Bain', null, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Rousseau', 'Système complet bonde lavabo', 'Plomberie', 'Salle de Bain', null, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('EPS410B', 'Télérupteur électrique (YesssElectrique)', 'Électricité', 'Chambre', 40.92, 0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('EPN510', 'Télérupteurs (Mécaniques) Paris Elec ou YesssElectrique', 'Électricité', 'Chambre', 37.02, 6.0) on conflict (code) do nothing;
insert into produits (code, designation, categorie, categorie_lieu, prix_unitaire, seuil_alerte) values ('Stop nuisibles', 'Traitement chimique', 'Divers', 'General', 80.0, 0) on conflict (code) do nothing;

-- Inventaire de reprise ------------------------------------------------
insert into inventaires (id, type, libelle, statut, ouvert_par, valide_par, valide_le, commentaire) select 'cccccccc-0000-0000-0000-000000000001', 'materiel', 'Reprise de l''ancienne application', 'valide', u.id, u.id, now(), 'Recale chaque produit sur le stock affiché avant la bascule, sans effacer l''historique des mouvements.'
  from utilisateurs u where u.nom = 'Miguel' on conflict (id) do nothing;

-- Mouvements de stock --------------------------------------------------
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-06-16', u.id, pt.id, e.id, i.id, null, 'Intervention 56 - flexible douche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = 'Miguel'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '56'
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Inconnu';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-06-16', u.id, pt.id, e.id, i.id, null, 'Intervention 46 - Vérifier s''il ne faut pas changer entièrement la colonne de douche'
  from produits pr
  left join utilisateurs u  on u.nom = 'Miguel'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '46'
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Inconnu';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-06-15', u.id, pt.id, e.id, i.id, null, 'Intervention 46 - Flexible de douche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '46'
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Inconnu';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-06-15', u.id, pt.id, e.id, i.id, null, 'Intervention 44 - flexible douche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '44'
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Inconnu';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 10.0, timestamptz '2026-03-06', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 10.0, timestamptz '2026-03-06', u.id, pt.id, e.id, i.id, null, '2131130'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-02-06', u.id, pt.id, e.id, i.id, null, 'Intervention 18 - flexible douche qui fuit'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '18'
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Inconnu';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-02-06', u.id, pt.id, e.id, i.id, null, 'Intervention 2eme étage - spot à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '2eme étage'
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW05';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'regularisation', 'inventaire', -1.0, timestamptz '2026-05-28', u.id, pt.id, e.id, i.id, 'cccccccc-0000-0000-0000-000000000001', 'Il en reste que 5'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Inconnu';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2026-05-28', u.id, pt.id, e.id, i.id, null, 'Intervention 06 - Spot à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Inconnu';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-05-21', u.id, pt.id, e.id, i.id, null, 'Flexible à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = 'WC Clients'
  left join anomalies a     on a.sharepoint_id = 1040
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Inconnu';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 5.0, timestamptz '2026-05-20', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Inconnu';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-03-05', u.id, pt.id, e.id, i.id, null, 'changement du séche cheveux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Miguel'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '14'
  left join anomalies a     on a.sharepoint_id = 1036
  left join interventions i on i.anomalie_id = a.id
  where pr.code = '8222107';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-04-29', u.id, pt.id, e.id, i.id, null, 'spot à changer (le premier devant la porte d’entrée)'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Lobby'
  left join anomalies a     on a.sharepoint_id = 1034
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-04-23', u.id, pt.id, e.id, i.id, null, 'remplacement bras de liseuse (coté gauche)'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '54'
  left join anomalies a     on a.sharepoint_id = 992
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-04-23', u.id, pt.id, e.id, i.id, null, 'Flexible douche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '25'
  left join anomalies a     on a.sharepoint_id = 1002
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Modélé inconnu (flexible)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-04-23', u.id, pt.id, e.id, i.id, null, 'flexible douche qui fuit'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '22'
  left join anomalies a     on a.sharepoint_id = 1019
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Inconnu';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-04-23', u.id, pt.id, e.id, i.id, null, 'flexible douche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '26'
  left join anomalies a     on a.sharepoint_id = 1031
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Inconnu';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-04-22', u.id, pt.id, e.id, i.id, null, 'remplacer l''économiseur d''énergie pour éclairage principal'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '16'
  left join anomalies a     on a.sharepoint_id = 455
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-04-22', u.id, pt.id, e.id, i.id, null, 'remplacer l''économiseur d''énergie pour éclairage principal'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '03'
  left join anomalies a     on a.sharepoint_id = 984
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-04-22', u.id, pt.id, e.id, i.id, null, 'remplacer l''économiseur d''énergie pour éclairage principal'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '57'
  left join anomalies a     on a.sharepoint_id = 1018
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-04-17', u.id, pt.id, e.id, i.id, null, 'Pommeau de douche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = 'Miguel'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '37'
  left join anomalies a     on a.sharepoint_id = 1016
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Hansgrohe';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-04-16', u.id, pt.id, e.id, i.id, null, 'remplacer l''économiseur d''énergie pour éclairage principal'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '56'
  left join anomalies a     on a.sharepoint_id = 784
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-04-16', u.id, pt.id, e.id, i.id, null, 'remplacer l''économiseur d''énergie pour éclairage principal'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '12'
  left join anomalies a     on a.sharepoint_id = 996
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-04-16', u.id, pt.id, e.id, i.id, null, 'télérupteur à changer - spot et leds'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '52'
  left join anomalies a     on a.sharepoint_id = 1003
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-03-31', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '03'
  left join anomalies a     on a.sharepoint_id = 983
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-03-17', u.id, pt.id, e.id, i.id, null, 'Spot à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = 'Lobby'
  left join anomalies a     on a.sharepoint_id = 845
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-03-17', u.id, pt.id, e.id, i.id, null, 'spot à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = 'Réception'
  left join anomalies a     on a.sharepoint_id = 976
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-03-17', u.id, pt.id, e.id, i.id, null, 'Batterie du bloc secours à changer (celui en face de la sortie de secours)'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = 'Lobby'
  left join anomalies a     on a.sharepoint_id = 977
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-02-23', u.id, pt.id, e.id, i.id, null, 'Liseuse côté gauche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '37'
  left join anomalies a     on a.sharepoint_id = 946
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'AP-1902-B0002';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 10.0, timestamptz '2026-02-20', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-05-02', u.id, pt.id, e.id, i.id, null, 'Flexible à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'MR NEGRONI'
  left join emplacements e  on e.code = 'WC Clients'
  left join anomalies a     on a.sharepoint_id = 901
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Modélé inconnu (flexible)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-01-13', u.id, pt.id, e.id, i.id, null, 'Changement flexible liseuse droite'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '22'
  left join anomalies a     on a.sharepoint_id = 483
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'AP-1902-B0002';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-01-13', u.id, pt.id, e.id, i.id, null, 'Changement flexible liseuse droite'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '24'
  left join anomalies a     on a.sharepoint_id = 504
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'AP-1902-B0002';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-01-13', u.id, pt.id, e.id, i.id, null, 'Changement flexible liseuse droite'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '25'
  left join anomalies a     on a.sharepoint_id = 516
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'AP-1902-B0002';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-01-13', u.id, pt.id, e.id, i.id, null, 'Télérupteur appliques changé'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '25'
  left join anomalies a     on a.sharepoint_id = 517
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-01-13', u.id, pt.id, e.id, i.id, null, 'spot chambre à remplacer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '42'
  left join anomalies a     on a.sharepoint_id = 643
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-01-13', u.id, pt.id, e.id, i.id, null, 'spot chambre à remplacer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '47'
  left join anomalies a     on a.sharepoint_id = 703
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2026-08-01', u.id, pt.id, e.id, i.id, null, 'Il faut changer la bouilloire'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '35'
  left join anomalies a     on a.sharepoint_id = 588
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'ALI170281 (Aficom)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 6.0, timestamptz '2025-12-27', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 6.0, timestamptz '2025-12-26', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA90731TPM (enjoliveur porte carte)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-12-23', u.id, pt.id, e.id, i.id, null, 'Liseuse côté gauche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '57'
  left join anomalies a     on a.sharepoint_id = 788
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'AP-1902-B0002';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-12-23', u.id, pt.id, e.id, i.id, null, 'Serrer le bras liseuse côté droit'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = 'WC Femmes'
  left join anomalies a     on a.sharepoint_id = 882
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-12', u.id, pt.id, e.id, i.id, null, 'Spot à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '12'
  left join anomalies a     on a.sharepoint_id = 412
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-12', u.id, pt.id, e.id, i.id, null, 'Télérupteur à changer - appliques murales sautent'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '21'
  left join anomalies a     on a.sharepoint_id = 473
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-12', u.id, pt.id, e.id, i.id, null, 'Télérupteur à changer - spot et leds'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '22'
  left join anomalies a     on a.sharepoint_id = 484
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-12', u.id, pt.id, e.id, i.id, null, 'Télérupteur à changer - spot et leds'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '25'
  left join anomalies a     on a.sharepoint_id = 507
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-12', u.id, pt.id, e.id, i.id, null, 'Spot à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '25'
  left join anomalies a     on a.sharepoint_id = 508
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-12', u.id, pt.id, e.id, i.id, null, 'Télérupteur à changer - appliques murales sautent'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '47'
  left join anomalies a     on a.sharepoint_id = 691
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-12', u.id, pt.id, e.id, i.id, null, 'Télérupteur à changer - appliques murales sautent'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '56'
  left join anomalies a     on a.sharepoint_id = 773
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-12', u.id, pt.id, e.id, i.id, null, 'Spot à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '56'
  left join anomalies a     on a.sharepoint_id = 774
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-03-12', u.id, pt.id, e.id, i.id, null, 'Liseuse côté droit à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '54'
  left join anomalies a     on a.sharepoint_id = 745
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-03-12', u.id, pt.id, e.id, i.id, null, 'Spot noir à changer - en face de la chambre 38'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Serafino'
  left join emplacements e  on e.code = '3eme étage'
  left join anomalies a     on a.sharepoint_id = 820
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-11-26', u.id, pt.id, e.id, i.id, null, 'Changement du séche cheveux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '35'
  left join anomalies a     on a.sharepoint_id = 576
  left join interventions i on i.anomalie_id = a.id
  where pr.code = '8222107';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-11-26', u.id, pt.id, e.id, i.id, null, 'Il faut changer la bouilloire'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '52'
  left join anomalies a     on a.sharepoint_id = 729
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'ALI170281 (Aficom)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-11-16', u.id, pt.id, e.id, i.id, null, 'flexible douche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Hedi'
  left join emplacements e  on e.code = '15'
  left join anomalies a     on a.sharepoint_id = 443
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DORNBRACHT-28322970-33';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-11-16', u.id, pt.id, e.id, i.id, null, 'flexible douche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Hedi'
  left join emplacements e  on e.code = '18'
  left join anomalies a     on a.sharepoint_id = 469
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DORNBRACHT-28322970-33';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-11-16', u.id, pt.id, e.id, i.id, null, 'Refixer la liseuse de gauche'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Hedi'
  left join emplacements e  on e.code = '28'
  left join anomalies a     on a.sharepoint_id = 544
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-11-16', u.id, pt.id, e.id, i.id, null, 'flexible liseuse côté droit à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Hedi'
  left join emplacements e  on e.code = '38'
  left join anomalies a     on a.sharepoint_id = 615
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'AP-1902-B0002';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-11-16', u.id, pt.id, e.id, i.id, null, 'flexible liseuse côté droit à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Hedi'
  left join emplacements e  on e.code = '48'
  left join anomalies a     on a.sharepoint_id = 709
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'AP-1902-B0002';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-11-16', u.id, pt.id, e.id, i.id, null, 'flexible liseuse côté droit à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Hedi'
  left join emplacements e  on e.code = '52'
  left join anomalies a     on a.sharepoint_id = 728
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'AP-1902-B0002';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 3.0, timestamptz '2025-03-11', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EURO W4 (EUROPROH)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-03-11', u.id, pt.id, e.id, i.id, null, 'URGENT! PRIORITE Coffre à reprogrammer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Technicien EUROPROH'
  left join emplacements e  on e.code = '18'
  left join anomalies a     on a.sharepoint_id = 457
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EURO W4 (EUROPROH)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-03-11', u.id, pt.id, e.id, i.id, null, 'Coffre fort HS'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Technicien EUROPROH'
  left join emplacements e  on e.code = '25'
  left join anomalies a     on a.sharepoint_id = 510
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EURO W4 (EUROPROH)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 7.0, timestamptz '2025-10-23', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2025-10-23', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA) - Local TGBT';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-10-23', u.id, pt.id, e.id, i.id, null, 'Batterie du bloc secours à changer (celui en face de l''ascenseur)'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Technicien TELEC'
  left join emplacements e  on e.code = '4eme étage'
  left join anomalies a     on a.sharepoint_id = 823
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-10-23', u.id, pt.id, e.id, i.id, null, 'Batterie du bloc secours à changer (celui en face de la chambre 44)'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Technicien TELEC'
  left join emplacements e  on e.code = '4eme étage'
  left join anomalies a     on a.sharepoint_id = 824
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-10-23', u.id, pt.id, e.id, i.id, null, 'bloc secour/batterie à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Technicien TELEC'
  left join emplacements e  on e.code = 'escalier qui mène au 4ème'
  left join anomalies a     on a.sharepoint_id = 839
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-10-23', u.id, pt.id, e.id, i.id, null, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Technicien TELEC'
  left join emplacements e  on e.code = 'escalier qui mène au 5ème'
  left join anomalies a     on a.sharepoint_id = 840
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-10-23', u.id, pt.id, e.id, i.id, null, 'bloc secour/batterie a changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Technicien TELEC'
  left join emplacements e  on e.code = 'Local TGBT'
  left join anomalies a     on a.sharepoint_id = 848
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA) - Local TGBT';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-01-10', u.id, pt.id, e.id, i.id, null, 'Détection de punaises de lit au niveau de la tête de lit constaté le 30/09/25 par la societe Ecoflair'
  from produits pr
  left join utilisateurs u  on u.nom = 'Rachid'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '54'
  left join anomalies a     on a.sharepoint_id = 759
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Stop nuisibles';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 37.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '01'
  left join anomalies a     on a.sharepoint_id = 376
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '02'
  left join anomalies a     on a.sharepoint_id = 384
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '03'
  left join anomalies a     on a.sharepoint_id = 394
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '11'
  left join anomalies a     on a.sharepoint_id = 407
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '12'
  left join anomalies a     on a.sharepoint_id = 420
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '14'
  left join anomalies a     on a.sharepoint_id = 433
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '15'
  left join anomalies a     on a.sharepoint_id = 444
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '16'
  left join anomalies a     on a.sharepoint_id = 452
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '18'
  left join anomalies a     on a.sharepoint_id = 465
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '21'
  left join anomalies a     on a.sharepoint_id = 480
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '22'
  left join anomalies a     on a.sharepoint_id = 488
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '24'
  left join anomalies a     on a.sharepoint_id = 500
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '25'
  left join anomalies a     on a.sharepoint_id = 514
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '26'
  left join anomalies a     on a.sharepoint_id = 520
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '27'
  left join anomalies a     on a.sharepoint_id = 527
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '28'
  left join anomalies a     on a.sharepoint_id = 542
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '31'
  left join anomalies a     on a.sharepoint_id = 556
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '32'
  left join anomalies a     on a.sharepoint_id = 563
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '34'
  left join anomalies a     on a.sharepoint_id = 570
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '35'
  left join anomalies a     on a.sharepoint_id = 581
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '36'
  left join anomalies a     on a.sharepoint_id = 597
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '37'
  left join anomalies a     on a.sharepoint_id = 605
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '38'
  left join anomalies a     on a.sharepoint_id = 618
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '41'
  left join anomalies a     on a.sharepoint_id = 631
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '42'
  left join anomalies a     on a.sharepoint_id = 640
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '44'
  left join anomalies a     on a.sharepoint_id = 648
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '45'
  left join anomalies a     on a.sharepoint_id = 661
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '46'
  left join anomalies a     on a.sharepoint_id = 681
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '47'
  left join anomalies a     on a.sharepoint_id = 697
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '48'
  left join anomalies a     on a.sharepoint_id = 713
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '51'
  left join anomalies a     on a.sharepoint_id = 722
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '52'
  left join anomalies a     on a.sharepoint_id = 736
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '54'
  left join anomalies a     on a.sharepoint_id = 760
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '55'
  left join anomalies a     on a.sharepoint_id = 769
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '56'
  left join anomalies a     on a.sharepoint_id = 782
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '57'
  left join anomalies a     on a.sharepoint_id = 795
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-30', u.id, pt.id, e.id, i.id, null, 'Demande de vérification s''il y a la présence de punaises'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'EcoFlair'
  left join emplacements e  on e.code = '58'
  left join anomalies a     on a.sharepoint_id = 811
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Ecoflair';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 8.0, timestamptz '2025-09-25', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 8.0, timestamptz '2025-09-25', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 8.0, timestamptz '2025-09-25', u.id, pt.id, e.id, i.id, null, 'échange de télérupteur électrique contre des télérupteurs mécaniques effectué avec YesssElectrique'
  from produits pr
  left join utilisateurs u  on u.nom = 'Miguel'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-22', u.id, pt.id, e.id, i.id, null, 'Il faut changer la bouilloire'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '47'
  left join anomalies a     on a.sharepoint_id = 693
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'ALI170281 (Aficom)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-18', u.id, pt.id, e.id, i.id, null, 'Flexible fuit au niveau du pommeau de douche'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Hedi'
  left join emplacements e  on e.code = '12'
  left join anomalies a     on a.sharepoint_id = 421
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DORNBRACHT-28322970-33';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-18', u.id, pt.id, e.id, i.id, null, 'flexible douche qui fuit'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Hedi'
  left join emplacements e  on e.code = '34'
  left join anomalies a     on a.sharepoint_id = 571
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DORNBRACHT-28322970-33';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-09-18', u.id, pt.id, e.id, i.id, null, 'Flexible de douche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Hedi'
  left join emplacements e  on e.code = '46'
  left join anomalies a     on a.sharepoint_id = 686
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DORNBRACHT-28322970-33';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 2.0, timestamptz '2025-09-15', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-12-09', u.id, pt.id, e.id, i.id, null, 'Spot plafond au fond à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '18'
  left join anomalies a     on a.sharepoint_id = 463
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-12-09', u.id, pt.id, e.id, i.id, null, 'remplacer l''économiseur d''énergie pour éclairage principal'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '21'
  left join anomalies a     on a.sharepoint_id = 478
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-12-09', u.id, pt.id, e.id, i.id, null, 'télérupteur pour spots plafond à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '46'
  left join anomalies a     on a.sharepoint_id = 676
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-12-09', u.id, pt.id, e.id, i.id, null, 'télérupteur pour spots plafond à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '52'
  left join anomalies a     on a.sharepoint_id = 733
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-12-09', u.id, pt.id, e.id, i.id, null, 'Spot plafond derrière la réception à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Réception'
  left join anomalies a     on a.sharepoint_id = 869
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 10.0, timestamptz '2025-09-09', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 7.0, timestamptz '2025-07-08', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DORNBRACHT-28322970-33';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2025-07-08', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DORN-0000';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 10.0, timestamptz '2025-04-08', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO54505';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 6.0, timestamptz '2025-04-08', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW05';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 14.0, timestamptz '2025-04-08', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-04-08', u.id, pt.id, e.id, i.id, null, 'remplacer l''économiseur d''énergie pour éclairage principal'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '22'
  left join anomalies a     on a.sharepoint_id = 486
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-04-08', u.id, pt.id, e.id, i.id, null, 'remplacer l''économiseur d''énergie pour éclairage principal'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '35'
  left join anomalies a     on a.sharepoint_id = 579
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-04-08', u.id, pt.id, e.id, i.id, null, 'remplacer l''économiseur d''énergie pour éclairage principal'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '58'
  left join anomalies a     on a.sharepoint_id = 809
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-04-08', u.id, pt.id, e.id, i.id, null, 'Spot à changer (celui de droite)'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'PDJ'
  left join anomalies a     on a.sharepoint_id = 828
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-04-08', u.id, pt.id, e.id, i.id, null, 'Spot côté à changer devant la camera'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Entrée'
  left join anomalies a     on a.sharepoint_id = 835
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-04-08', u.id, pt.id, e.id, i.id, null, 'bloc secour/batterie a changer (en face de la chambre 14)'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Palier 1er'
  left join anomalies a     on a.sharepoint_id = 855
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'NI-Cd 2,4V 1,5AH (URA)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-04-08', u.id, pt.id, e.id, i.id, null, 'Spot côté à changer à côté du miroir'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Réception'
  left join anomalies a     on a.sharepoint_id = 866
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-04-08', u.id, pt.id, e.id, i.id, null, 'Spot côté à changer derriere la réception'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = 'Réception'
  left join anomalies a     on a.sharepoint_id = 867
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW30';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-07-22', u.id, pt.id, e.id, i.id, null, 'Changement du séche cheveux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '56'
  left join anomalies a     on a.sharepoint_id = 780
  left join interventions i on i.anomalie_id = a.id
  where pr.code = '8222107';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-06-24', u.id, pt.id, e.id, i.id, null, 'remplacer l''économiseur d''énergie pour éclairage principal'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Hedi'
  left join emplacements e  on e.code = '35'
  left join anomalies a     on a.sharepoint_id = 577
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-06-24', u.id, pt.id, e.id, i.id, null, 'Fil de d''aspirateur à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Hedi'
  left join emplacements e  on e.code = 'Parties communes'
  left join anomalies a     on a.sharepoint_id = 833
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'CABLE1532MM';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2025-06-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'CABLE1532MM';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-05-30', u.id, pt.id, e.id, i.id, null, 'Flexible douche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Hedi'
  left join emplacements e  on e.code = '01'
  left join anomalies a     on a.sharepoint_id = 373
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Modélé inconnu (flexible)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-05-20', u.id, pt.id, e.id, i.id, null, 'remplacer l''économiseur d''énergie pour éclairage principal'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '45'
  left join anomalies a     on a.sharepoint_id = 659
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-05-14', u.id, pt.id, e.id, i.id, null, 'remplacer l''économiseur d''énergie pour éclairage principal'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '46'
  left join anomalies a     on a.sharepoint_id = 678
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 7.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Hansgrohe';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 10.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'AMS Brass Toilet roll holder (ams-sw034-PB)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 3.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Aliseo (030706)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 3.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DO467WW05';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 3.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Transfo Spot';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 10.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Interupteur';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 10.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Inconnu-2';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Applique';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Butée (dorée)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Rousseau';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Aliseo (030692)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DORNBRACHT-28322970-33';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 1.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'DAIKIN';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 15.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EFA21031 (économisseur)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 3.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Modélé inconnu (flexible)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, 'télérupteur lumière néons et spots plafond sautent'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '31'
  left join anomalies a     on a.sharepoint_id = 553
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-04-18', u.id, pt.id, e.id, i.id, null, 'télérupteur lumière néons et spots plafond sautent'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '54'
  left join anomalies a     on a.sharepoint_id = 758
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-08-04', u.id, pt.id, e.id, i.id, null, 'flexible liseuse côté droit à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Juan'
  left join emplacements e  on e.code = '26'
  left join anomalies a     on a.sharepoint_id = 523
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-08-04', u.id, pt.id, e.id, i.id, null, 'flexible liseuse côté gauche à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'Juan'
  left join emplacements e  on e.code = '38'
  left join anomalies a     on a.sharepoint_id = 614
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 20.0, timestamptz '2025-03-22', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 24.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '24'
  left join anomalies a     on a.sharepoint_id = 498
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux - salle de bain'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '34'
  left join anomalies a     on a.sharepoint_id = 568
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '46'
  left join anomalies a     on a.sharepoint_id = 677
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '51'
  left join anomalies a     on a.sharepoint_id = 720
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '52'
  left join anomalies a     on a.sharepoint_id = 734
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '54'
  left join anomalies a     on a.sharepoint_id = 754
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux - salle de bain'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '54'
  left join anomalies a     on a.sharepoint_id = 755
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '55'
  left join anomalies a     on a.sharepoint_id = 767
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '56'
  left join anomalies a     on a.sharepoint_id = 779
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '57'
  left join anomalies a     on a.sharepoint_id = 793
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '58'
  left join anomalies a     on a.sharepoint_id = 807
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -2.0, timestamptz '2025-03-14', u.id, pt.id, e.id, i.id, null, 'Changement des rideaux - salle de bain'
  from produits pr
  left join utilisateurs u  on u.nom = 'Victoria'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '58'
  left join anomalies a     on a.sharepoint_id = 808
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'Silva';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-02-17', u.id, pt.id, e.id, i.id, null, 'change bonde lavabo'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '24'
  left join anomalies a     on a.sharepoint_id = 497
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPS410B';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 4.0, timestamptz '2025-01-30', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'ALI170281 (Aficom)';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-01-30', u.id, pt.id, e.id, i.id, null, 'flexible liseuse côté SDB à changer'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '41'
  left join anomalies a     on a.sharepoint_id = 627
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-01-22', u.id, pt.id, e.id, i.id, null, 'La lumiere du plafond saute - Télérupteur à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '21'
  left join anomalies a     on a.sharepoint_id = 476
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-01-22', u.id, pt.id, e.id, i.id, null, 'Télérupteur spot et led à changer'
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = 'ALAIN'
  left join emplacements e  on e.code = '32'
  left join anomalies a     on a.sharepoint_id = 560
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-01-21', u.id, pt.id, e.id, i.id, null, 'changement du flexible de la liseuse de droite'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '11'
  left join anomalies a     on a.sharepoint_id = 411
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'sortie', null, -1.0, timestamptz '2025-01-21', u.id, pt.id, e.id, i.id, null, 'flexible liseuse côté gauche à resserer'
  from produits pr
  left join utilisateurs u  on u.nom = 'FARID'
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = '26'
  left join anomalies a     on a.sharepoint_id = 524
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'SE1241LTB';
insert into mouvements_stock (produit_id, type, motif, quantite, date_mouvement, utilisateur_id, prestataire_id, emplacement_id, intervention_id, inventaire_id, commentaire) select pr.id, 'entree', null, 4.0, timestamptz '2025-01-20', u.id, pt.id, e.id, i.id, null, null
  from produits pr
  left join utilisateurs u  on u.nom = null
  left join prestataires pt on pt.nom = null
  left join emplacements e  on e.code = null
  left join anomalies a     on a.sharepoint_id = null
  left join interventions i on i.anomalie_id = a.id
  where pr.code = 'EPN510';
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


select '3-stock.sql' as "Fichier joué",
       count(*) || ' produits sur 36' as "Où ça en est"
  from produits;
