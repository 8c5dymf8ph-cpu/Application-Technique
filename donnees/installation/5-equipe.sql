-- ==========================================================================
-- L'équipe — produit par outils/equipe.py. Ne pas éditer à la main.
-- À jouer après les imports : il corrige des noms qu'ils ont créés.
-- ==========================================================================
begin;

-- Orthographe des noms repris des exports ------------------------------
update utilisateurs set nom = 'Alain' where nom = 'ALAIN' and not exists (select 1 from utilisateurs x where x.nom = 'Alain');
update prestataires set nom = 'Alain' where nom = 'ALAIN' and not exists (select 1 from prestataires x where x.nom = 'Alain');
update utilisateurs set nom = 'Farid' where nom = 'FARID' and not exists (select 1 from utilisateurs x where x.nom = 'Farid');
update prestataires set nom = 'Farid' where nom = 'FARID' and not exists (select 1 from prestataires x where x.nom = 'Farid');
update utilisateurs set nom = 'Mr Negroni' where nom = 'MR NEGRONI' and not exists (select 1 from utilisateurs x where x.nom = 'Mr Negroni');
update prestataires set nom = 'Mr Negroni' where nom = 'MR NEGRONI' and not exists (select 1 from prestataires x where x.nom = 'Mr Negroni');
update utilisateurs set nom = 'Technicien Avir' where nom = 'Technicien AVIR' and not exists (select 1 from utilisateurs x where x.nom = 'Technicien Avir');
update prestataires set nom = 'Technicien Avir' where nom = 'Technicien AVIR' and not exists (select 1 from prestataires x where x.nom = 'Technicien Avir');
update utilisateurs set nom = 'Technicien Telec' where nom = 'Technicien TELEC' and not exists (select 1 from utilisateurs x where x.nom = 'Technicien Telec');
update prestataires set nom = 'Technicien Telec' where nom = 'Technicien TELEC' and not exists (select 1 from prestataires x where x.nom = 'Technicien Telec');

-- Qui fait partie des intervenants techniques ---------------------------
update utilisateurs set intervient_technique = false;
update utilisateurs set intervient_technique = true where nom in ('Farid', 'Miguel', 'Rachid', 'Victoria', 'Taibi');

commit;


select '5-equipe.sql' as "Fichier joué",
       case when exists (select 1 from prestataires where nom = 'ALAIN')
            then 'noms NON corrigés — le fichier n''a pas tourné' else 'noms corrigés — installation terminée' end as "Où ça en est";
