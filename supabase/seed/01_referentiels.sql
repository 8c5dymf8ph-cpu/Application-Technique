-- =============================================================================
-- Référentiels de départ — Hôtel Parisianer
-- Repris de App.OnStart / colChambres de l'application Power Apps.
-- Idempotent : peut être rejoué sans créer de doublon.
-- =============================================================================

insert into etages (code, nom, ordre) values
  ('RDC',       'Rez-de-chaussée', 0),
  ('1er',       '1er étage',       1),
  ('2eme',      '2ème étage',      2),
  ('3eme',      '3ème étage',      3),
  ('4eme',      '4ème étage',      4),
  ('5eme',      '5ème étage',      5),
  ('Sous-Sol',  'Sous-sol',        6),
  ('Autres',    'Extérieurs',      7)
on conflict (code) do nothing;

-- Emplacements : reprise de la liste fournie, codes compris, y compris sa
-- convention — un escalier appartient à l'étage d'où l'on part. Seules les
-- chambres, aux codes numériques, reçoivent la dotation Purezza.
-- L'entrée d'ordre 90 ne figurait pas dans la liste mais recueille les lignes
-- de l'export qui disent seulement « sous sol » : à confirmer.
with source (etage, code, type, rang) as (values
  ('RDC','01','chambre',0),
  ('RDC','02','chambre',1),
  ('RDC','03','chambre',2),
  ('RDC','PDJ','commun',3),
  ('RDC','Réception','commun',4),
  ('RDC','Lobby','commun',5),
  ('RDC','Entrée','commun',6),
  ('RDC','Cuisine','technique',7),
  ('RDC','Bagagerie','technique',8),
  ('RDC','Ascenseur','technique',9),
  ('RDC','COUR intèrieure','exterieur',10),
  ('RDC','Parties communes','commun',11),
  ('1er','Palier 1er','commun',0),
  ('1er','11','chambre',1),
  ('1er','12','chambre',2),
  ('1er','14','chambre',3),
  ('1er','15','chambre',4),
  ('1er','16','chambre',5),
  ('1er','18','chambre',6),
  ('2eme','2eme étage','commun',0),
  ('2eme','21','chambre',1),
  ('2eme','22','chambre',2),
  ('2eme','24','chambre',3),
  ('2eme','25','chambre',4),
  ('2eme','26','chambre',5),
  ('2eme','27','chambre',6),
  ('2eme','28','chambre',7),
  ('3eme','3eme étage','commun',0),
  ('3eme','31','chambre',1),
  ('3eme','32','chambre',2),
  ('3eme','34','chambre',3),
  ('3eme','35','chambre',4),
  ('3eme','36','chambre',5),
  ('3eme','37','chambre',6),
  ('3eme','38','chambre',7),
  ('3eme','escalier qui mène au 4ème','commun',8),
  ('4eme','4eme étage','commun',0),
  ('4eme','41','chambre',1),
  ('4eme','42','chambre',2),
  ('4eme','44','chambre',3),
  ('4eme','45','chambre',4),
  ('4eme','46','chambre',5),
  ('4eme','47','chambre',6),
  ('4eme','48','chambre',7),
  ('4eme','escalier qui mène au 5ème','commun',8),
  ('5eme','Palier 5ème','commun',0),
  ('5eme','Office 5 ème étage','technique',1),
  ('5eme','51','chambre',2),
  ('5eme','52','chambre',3),
  ('5eme','54','chambre',4),
  ('5eme','55','chambre',5),
  ('5eme','56','chambre',6),
  ('5eme','57','chambre',7),
  ('5eme','58','chambre',8),
  ('Sous-Sol','Salle de sport','commun',0),
  ('Sous-Sol','Sas de sécurité','commun',1),
  ('Sous-Sol','WC Clients','commun',2),
  ('Sous-Sol','WC Femmes','commun',3),
  ('Sous-Sol','WC Hommes','commun',4),
  ('Sous-Sol','Escalier qui mène au RDC','commun',5),
  ('Sous-Sol','Salle de repos','commun',6),
  ('Sous-Sol','Vestiaire Hommes','technique',7),
  ('Sous-Sol','Vestiaire Femmes','technique',8),
  ('Sous-Sol','Lingerie','technique',9),
  ('Sous-Sol','Local TGBT','technique',10),
  ('Sous-Sol','Local Technique','technique',11),
  ('Sous-Sol','Local poubelle','technique',12),
  ('Sous-Sol','Chaufferie','technique',13),
  ('Autres','Toit','exterieur',0),
  ('Sous-Sol','Sous-sol divers','commun',90)
)
insert into emplacements (code, nom, etage_id, type, dote_bouteilles, ordre)
select s.code, s.code, e.id, s.type::type_emplacement, s.type = 'chambre', s.rang
from source s join etages e on e.code = s.etage
on conflict (code) do nothing;

-- Les quatre types réellement utilisés dans la liste d'origine.
insert into types_intervention (code, nom) values
  ('TECHNIQUE',   'Technique'),
  ('ELECTRIQUE',  'Électrique'),
  ('PLOMBERIE',   'Plomberie'),
  ('ACHATS',      'Achats')
on conflict (code) do nothing;

-- Fournisseur des bouteilles. Purezza est la marque des bouteilles ; le
-- fournisseur, celui qui facture et à qui l'on commande, est Culligan. Le
-- contact y change souvent : c'est pour cela que le nom de la personne est un
-- champ libre, révisable, et non un référentiel à part.
insert into fournisseurs (nom, delai_livraison_jours) values ('Culligan', 7)
on conflict (nom) do nothing;

-- Bouteilles Purezza : 17,50 € facturés au client, 8 € de coût d'achat.
-- `seuil_alerte` porte sur la RÉSERVE — le nombre de bouteilles encore
-- disponibles pour re-doter une chambre. Valeurs à ajuster à l'usage.
insert into bouteille_types (code, libelle, prix_vente, prix_achat, seuil_alerte, quantite_reappro, couleur) values
  ('filtree',    'Eau filtrée',    17.50, 8.00, 10, 24, '#3A6499'),
  ('petillante', 'Eau gazeuse',    17.50, 8.00, 10, 24, '#9E3538')
on conflict (code) do nothing;

-- Culligan fournit les deux types. D'autres fournisseurs peuvent être ajoutés
-- sur le même article : la demande de devis partira alors vers chacun.
insert into article_fournisseurs (bouteille_type_id, fournisseur_id, prefere)
select bt.id, f.id, true
from bouteille_types bt, fournisseurs f where f.nom = 'Culligan'
on conflict do nothing;

-- Le libellé a changé après coup : sur une base déjà installée, on le corrige
-- plutôt que de créer un doublon. « Gazeuse » est le mot employé dans l'hôtel.
update bouteille_types set libelle = 'Eau gazeuse' where code = 'petillante';

-- Dotation permanente : 1 filtrée + 1 gazeuse dans chaque chambre.
insert into dotations (emplacement_id, bouteille_type_id, quantite)
select e.id, bt.id, 1
from emplacements e
cross join bouteille_types bt
where e.dote_bouteilles
on conflict (emplacement_id, bouteille_type_id) do nothing;

-- Destinataires des alertes automatiques. À compléter depuis l'écran
-- d'administration. L'alerte bouteille est destinée à la réception, qui
-- recontacte le client ; la gouvernante, elle, ne reçoit aucun mail.
insert into alertes_destinataires (evenement, destinataires, actif) values
  ('incident_bouteille', '{fom@contacthotelparisianer.com}', true),
  ('seuil_stock',        '{}', false)
on conflict (evenement) do update
  set destinataires = excluded.destinataires, actif = excluded.actif
  where alertes_destinataires.evenement = 'incident_bouteille';
