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

-- Emplacements : référentiel canonique reconstruit à partir des 86 orthographes
-- relevées dans l'export de « TEST Tech 3 ». La table de correspondance entre
-- ces orthographes et ces codes vit dans outils/referentiel_lieux.py.
-- Les chambres (37) reçoivent la dotation Purezza, rien d'autre.
with source (etage, code, nom, type) as (values
  ('RDC','01','Chambre 01','chambre'),
  ('RDC','02','Chambre 02','chambre'),
  ('RDC','03','Chambre 03','chambre'),
  ('RDC','Bagagerie','Bagagerie','technique'),
  ('RDC','Bureau','Bureau','technique'),
  ('RDC','Cuisine','Cuisine','technique'),
  ('RDC','Entree','Entrée','commun'),
  ('RDC','Escalier-RDC','Escalier de secours RDC','commun'),
  ('RDC','Lobby','Lobby','commun'),
  ('RDC','PDJ','Salle petit-déjeuner','commun'),
  ('RDC','Reception','Réception','commun'),
  ('1er','11','Chambre 11','chambre'),
  ('1er','12','Chambre 12','chambre'),
  ('1er','14','Chambre 14','chambre'),
  ('1er','15','Chambre 15','chambre'),
  ('1er','16','Chambre 16','chambre'),
  ('1er','18','Chambre 18','chambre'),
  ('1er','Escalier-1','Escalier du 1er','commun'),
  ('1er','Etage-1','1er étage — général','commun'),
  ('1er','Palier-1','Palier 1er','commun'),
  ('2eme','21','Chambre 21','chambre'),
  ('2eme','22','Chambre 22','chambre'),
  ('2eme','24','Chambre 24','chambre'),
  ('2eme','25','Chambre 25','chambre'),
  ('2eme','26','Chambre 26','chambre'),
  ('2eme','27','Chambre 27','chambre'),
  ('2eme','28','Chambre 28','chambre'),
  ('2eme','Etage-2','2ème étage — général','commun'),
  ('3eme','31','Chambre 31','chambre'),
  ('3eme','32','Chambre 32','chambre'),
  ('3eme','34','Chambre 34','chambre'),
  ('3eme','35','Chambre 35','chambre'),
  ('3eme','36','Chambre 36','chambre'),
  ('3eme','37','Chambre 37','chambre'),
  ('3eme','38','Chambre 38','chambre'),
  ('3eme','Etage-3','3ème étage — général','commun'),
  ('3eme','Palier-3','Palier 3ème','commun'),
  ('4eme','41','Chambre 41','chambre'),
  ('4eme','42','Chambre 42','chambre'),
  ('4eme','44','Chambre 44','chambre'),
  ('4eme','45','Chambre 45','chambre'),
  ('4eme','46','Chambre 46','chambre'),
  ('4eme','47','Chambre 47','chambre'),
  ('4eme','48','Chambre 48','chambre'),
  ('4eme','Escalier-4','Escalier du 4ème','commun'),
  ('4eme','Etage-4','4ème étage — général','commun'),
  ('5eme','51','Chambre 51','chambre'),
  ('5eme','52','Chambre 52','chambre'),
  ('5eme','54','Chambre 54','chambre'),
  ('5eme','55','Chambre 55','chambre'),
  ('5eme','56','Chambre 56','chambre'),
  ('5eme','57','Chambre 57','chambre'),
  ('5eme','58','Chambre 58','chambre'),
  ('5eme','Escalier-5','Escalier du 5ème','commun'),
  ('5eme','Etage-5','5ème étage — général','commun'),
  ('5eme','Office-5','Office 5ème étage','technique'),
  ('5eme','Palier-5','Palier 5ème','commun'),
  ('Sous-Sol','Chaufferie','Chaufferie','technique'),
  ('Sous-Sol','Escalier-SS','Escalier du sous-sol','commun'),
  ('Sous-Sol','Lingerie','Lingerie','technique'),
  ('Sous-Sol','Local-TGBT','Local TGBT','technique'),
  ('Sous-Sol','Local-Technique','Local technique','technique'),
  ('Sous-Sol','Salle-Repos','Salle de repos','commun'),
  ('Sous-Sol','Salle-Sport','Salle de sport','commun'),
  ('Sous-Sol','Sous-Sol','Sous-sol — général','commun'),
  ('Sous-Sol','WC-Clients','WC clients','commun'),
  ('Sous-Sol','WC-Femmes','WC femmes','commun'),
  ('Sous-Sol','WC-Hommes','WC hommes','commun'),
  ('Autres','Ascenseur','Ascenseur','technique'),
  ('Autres','Communs','Parties communes','commun'),
  ('Autres','Cour','Cour intérieure','exterieur'),
  ('Autres','Exterieur','Extérieur de l''hôtel','exterieur'),
  ('Autres','General','Général / non localisé','commun'),
  ('Autres','Toit','Toit','exterieur')
)
insert into emplacements (code, nom, etage_id, type, dote_bouteilles, ordre)
select s.code, s.nom, e.id, s.type::type_emplacement, s.type = 'chambre',
       row_number() over (partition by s.etage order by s.code)
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
