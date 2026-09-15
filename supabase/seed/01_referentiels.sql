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

-- Emplacements. `type` = 'chambre' pour les codes numériques (ils reçoivent la
-- dotation Purezza), 'commun' / 'technique' / 'exterieur' pour le reste.
with source (etage, code, type) as (values
  ('RDC','01','chambre'), ('RDC','02','chambre'), ('RDC','03','chambre'),
  ('RDC','PDJ','commun'), ('RDC','Réception','commun'), ('RDC','Lobby','commun'),
  ('RDC','Entrée','commun'), ('RDC','Cuisine','technique'), ('RDC','Bagagerie','technique'),

  ('1er','11','chambre'), ('1er','12','chambre'), ('1er','14','chambre'),
  ('1er','15','chambre'), ('1er','16','chambre'), ('1er','18','chambre'),

  ('2eme','21','chambre'), ('2eme','22','chambre'), ('2eme','24','chambre'),
  ('2eme','25','chambre'), ('2eme','26','chambre'), ('2eme','27','chambre'), ('2eme','28','chambre'),

  ('3eme','31','chambre'), ('3eme','32','chambre'), ('3eme','34','chambre'),
  ('3eme','35','chambre'), ('3eme','36','chambre'), ('3eme','37','chambre'), ('3eme','38','chambre'),

  ('4eme','41','chambre'), ('4eme','42','chambre'), ('4eme','44','chambre'),
  ('4eme','45','chambre'), ('4eme','46','chambre'), ('4eme','47','chambre'), ('4eme','48','chambre'),

  ('5eme','51','chambre'), ('5eme','52','chambre'), ('5eme','54','chambre'),
  ('5eme','55','chambre'), ('5eme','56','chambre'), ('5eme','57','chambre'), ('5eme','58','chambre'),

  ('Sous-Sol','WC Clients','commun'),   ('Sous-Sol','WC Femmes','commun'),
  ('Sous-Sol','Chaufferie','technique'), ('Sous-Sol','Local TGBT','technique'),
  ('Sous-Sol','Local Technique','technique'), ('Sous-Sol','Lingerie','technique'),
  ('Sous-Sol','Salle de sport','commun'),

  ('Autres','Toit','exterieur'), ('Autres','Cour ext.','exterieur')
)
insert into emplacements (code, nom, etage_id, type, dote_bouteilles, ordre)
select
  s.code,
  s.code,
  e.id,
  s.type::type_emplacement,
  s.type = 'chambre',
  row_number() over (partition by s.etage order by s.code)
from source s
join etages e on e.code = s.etage
on conflict (code) do nothing;

insert into types_intervention (code, nom) values
  ('plomberie',    'Plomberie'),
  ('electricite',  'Électricité'),
  ('menuiserie',   'Menuiserie'),
  ('peinture',     'Peinture'),
  ('mobilier',     'Mobilier'),
  ('climatisation','Climatisation / Chauffage'),
  ('serrurerie',   'Serrurerie'),
  ('multimedia',   'TV / Multimédia'),
  ('autre',        'Autre')
on conflict (code) do nothing;

-- Fournisseur des bouteilles. Les autres fournisseurs seront créés à l'import
-- des produits, ou saisis depuis l'écran d'administration.
insert into fournisseurs (nom) values ('Purezza')
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
