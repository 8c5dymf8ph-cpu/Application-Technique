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

-- Emplacements : reprise exacte de la liste de l'application d'origine. Le code
-- est la chaîne employée dans son Switch, pour que rien ne se perde à la
-- traduction — un escalier est donc rangé à l'étage d'où l'on part.
-- Les trois derniers (ordre 90) ne figuraient pas dans cette liste mais sont
-- nécessaires pour placer une vingtaine de lignes de l'export : à confirmer.
-- Seules les chambres, aux codes numériques, reçoivent la dotation Purezza.
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
  ('Sous-Sol','WC Clients','commun',0),
  ('Sous-Sol','WC Femmes','commun',1),
  ('Sous-Sol','Chaufferie','technique',2),
  ('Sous-Sol','Local TGBT','technique',3),
  ('Sous-Sol','Local Technique','technique',4),
  ('Sous-Sol','Lingerie','technique',5),
  ('Sous-Sol','Salle de sport','commun',6),
  ('Autres','Toit','exterieur',0),
  ('Autres','COUR intèrieure','exterieur',1),
  ('Autres','Ascenseur','technique',90),
  ('Sous-Sol','Sous-sol divers','commun',90),
  ('Autres','Parties communes','commun',90)
)
insert into emplacements (code, nom, etage_id, type, dote_bouteilles, ordre)
select s.code, s.code, e.id, s.type::type_emplacement, s.type = 'chambre', s.rang
from source s
join etages e on e.code = s.etage
on conflict (code) do nothing;

-- Les quatre types réellement utilisés dans la liste d'origine.
insert into types_intervention (code, nom) values
  ('TECHNIQUE',   'Technique'),
  ('ELECTRIQUE',  'Électrique'),
  ('PLOMBERIE',   'Plomberie'),
  ('ACHATS',      'Achats')
on conflict (code) do nothing;

-- Fournisseur des bouteilles. Les autres fournisseurs seront créés à l'import
-- des produits, ou saisis depuis l'écran d'administration.
insert into fournisseurs (nom, delai_livraison_jours) values ('Purezza', 7)
on conflict (nom) do nothing;

-- Bouteilles Purezza : 17,50 € facturés au client, 8 € de coût d'achat.
-- `seuil_alerte` porte sur la RÉSERVE — le nombre de bouteilles encore
-- disponibles pour re-doter une chambre. Valeurs à ajuster à l'usage.
insert into bouteille_types (code, libelle, prix_vente, prix_achat, seuil_alerte, quantite_reappro, fournisseur_id, couleur)
select v.code, v.libelle, v.prix_vente, v.prix_achat, v.seuil, v.reappro, f.id, v.couleur
from (values
  ('filtree',    'Eau filtrée',    17.50, 8.00, 10, 24, '#2D7FF9'),
  ('petillante', 'Eau pétillante', 17.50, 8.00, 10, 24, '#E5484D')
) as v (code, libelle, prix_vente, prix_achat, seuil, reappro, couleur)
left join fournisseurs f on f.nom = 'Purezza'
on conflict (code) do nothing;

-- Dotation permanente : 1 filtrée + 1 pétillante dans chaque chambre.
insert into dotations (emplacement_id, bouteille_type_id, quantite)
select e.id, bt.id, 1
from emplacements e
cross join bouteille_types bt
where e.dote_bouteilles
on conflict (emplacement_id, bouteille_type_id) do nothing;

-- Destinataires des alertes automatiques. À compléter depuis l'écran
-- d'administration : ce sont ces adresses qui reçoivent le mail lorsqu'une
-- bouteille est signalée manquante ou qu'un stock passe sous son seuil.
insert into alertes_destinataires (evenement, destinataires, actif) values
  ('incident_bouteille', '{}', false),
  ('seuil_stock',        '{}', false)
on conflict (evenement) do nothing;
