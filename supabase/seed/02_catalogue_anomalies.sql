-- =============================================================================
-- Catalogue d'anomalies — amorce
--
-- La gouvernante déclare depuis son téléphone en cherchant par mots-clés dans ce
-- catalogue ; elle ne peut pas saisir de texte libre. Ajouter une entrée est
-- réservé à l'admin, depuis un ordinateur (règle appliquée par la RLS).
--
-- Ce fichier n'est qu'une amorce : le catalogue définitif sera généré à partir
-- des libellés réellement utilisés dans la colonne AnomaliesCommentaires de la
-- liste « TEST Tech 3 », une fois l'export CSV disponible.
-- =============================================================================

insert into catalogue_anomalies (libelle, mots_cles, type_id)
select v.libelle, v.mots_cles, t.id
from (values
  ('Fuite lavabo',                 array['fuite','lavabo','eau','robinet'],        'plomberie'),
  ('Fuite douche',                 array['fuite','douche','eau'],                  'plomberie'),
  ('WC bouché',                    array['wc','bouche','toilette','evacuation'],   'plomberie'),
  ('Chasse d''eau défectueuse',    array['chasse','wc','toilette','eau'],          'plomberie'),
  ('Écoulement lent',              array['ecoulement','lent','evacuation','bonde'],'plomberie'),
  ('Ampoule grillée',              array['ampoule','lumiere','grillee','eclairage'],'electricite'),
  ('Prise hors service',           array['prise','courant','electricite'],         'electricite'),
  ('Interrupteur cassé',           array['interrupteur','lumiere','casse'],        'electricite'),
  ('Porte qui grince',             array['porte','grince','bruit'],                'menuiserie'),
  ('Poignée de porte cassée',      array['poignee','porte','casse'],               'menuiserie'),
  ('Volet bloqué',                 array['volet','bloque','store'],                'menuiserie'),
  ('Serrure défectueuse',          array['serrure','cle','badge','porte'],         'serrurerie'),
  ('Peinture écaillée',            array['peinture','mur','ecaillee','trace'],     'peinture'),
  ('Trou ou trace sur mur',        array['mur','trou','trace','peinture'],         'peinture'),
  ('Climatisation en panne',       array['clim','climatisation','froid','chaud'],  'climatisation'),
  ('Radiateur froid',              array['radiateur','chauffage','froid'],         'climatisation'),
  ('Télévision sans signal',       array['tv','television','signal','chaine'],     'multimedia'),
  ('Télécommande hors service',    array['telecommande','tv','pile'],              'multimedia'),
  ('Meuble abîmé',                 array['meuble','abime','casse','mobilier'],     'mobilier'),
  ('Miroir cassé',                 array['miroir','casse','glace'],                'mobilier')
) as v (libelle, mots_cles, type_code)
left join types_intervention t on t.code = v.type_code
where not exists (select 1 from catalogue_anomalies c where c.libelle = v.libelle);
