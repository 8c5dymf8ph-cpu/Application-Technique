-- =============================================================================
-- Migration 0029 : les escaliers et offices qui manquaient au référentiel
-- =============================================================================
-- La liste reprise de l'ancienne application n'avait pas tous les paliers
-- intermédiaires ni tous les offices — seuls « escalier qui mène au 4ème » et
-- « escalier qui mène au 5ème » y figuraient, et un seul office (5ème étage).
-- Ces lieux existent pourtant, et une anomalie n'a nulle part où se déclarer
-- tant qu'ils manquent au référentiel. `type = 'technique'` comme les lieux
-- déjà de cette nature (offices, locaux, vestiaires) — ce ne sont pas des
-- chambres, ils ne reçoivent donc pas la dotation Purezza.
--
-- `ordre` place chaque lieu à la fin de son étage, dans l'ordre où il a été
-- demandé : la règle 14octies trie d'abord par etages.ordre, puis par ce
-- champ à l'intérieur de l'étage.
with nouveaux (etage, code, rang) as (values
  ('RDC',  'Escalier qui mène au 1er', 12),
  ('RDC',  'Escalier de secours',      13),
  ('1er',  'Escalier qui mène au 2ème', 7),
  ('1er',  'Office du 1er',             8),
  ('2eme', 'Escalier qui mène au 3ème', 8),
  ('2eme', 'Office du 2ème',            9),
  ('3eme', 'Office du 3ème',            9),
  ('4eme', 'Office du 4ème',            9)
)
insert into emplacements (code, nom, etage_id, type, dote_bouteilles, ordre)
select n.code, n.code, e.id, 'technique', false, n.rang
  from nouveaux n
  join etages e on e.code = n.etage
 where not exists (select 1 from emplacements ex where ex.code = n.code);
