-- -----------------------------------------------------------------------------
-- Où en suis-je ? — à jouer quand on ne sait plus quel fichier a été passé.
-- -----------------------------------------------------------------------------
-- Ne modifie rien : compte ce qui est en place et nomme le fichier suivant.
-- Se rejoue autant de fois qu'on veut, à n'importe quel moment.
do $$
declare
  n_anom bigint := 0;
  n_prod bigint := 0;
  n_bout bigint := 0;
  equipe_faite boolean := false;
begin
  create temp table if not exists etat_installation (
    ordre int, etape text, constat text, a_faire text
  );
  delete from etat_installation;

  if to_regclass('public.anomalies') is null then
    insert into etat_installation values
      (1, 'Le schéma', 'ABSENT',
          'Commencer par 1-schema-et-referentiels.sql');
    return;
  end if;

  execute 'select count(*) from public.anomalies'        into n_anom;
  execute 'select count(*) from public.produits'         into n_prod;
  execute 'select count(*) from public.incidents_bouteille' into n_bout;
  -- 5-equipe.sql corrige l'orthographe reprise des exports : tant qu'il reste
  -- un « ALAIN » en capitales, il n'est pas passé.
  execute 'select not exists (select 1 from public.prestataires where nom = ''ALAIN'')'
    into equipe_faite;

  insert into etat_installation values
    (1, 'Le schéma', 'en place', 'rien — 1-schema-et-referentiels.sql est passé');

  -- Les paliers du fichier des anomalies, morceau par morceau.
  insert into etat_installation values (2, 'Les anomalies',
    n_anom || ' sur 670',
    case n_anom
      when 0   then 'Jouer 2-anomalies-a.sql'
      when 144 then 'Jouer 2-anomalies-b.sql'
      when 284 then 'Jouer 2-anomalies-c.sql'
      when 420 then 'Jouer 2-anomalies-d.sql'
      when 568 then 'Jouer 2-anomalies-e.sql'
      when 670 then 'rien — les cinq morceaux sont passés'
      else 'Compte inattendu. Reprendre à zéro avec 0-tout-effacer.sql, '
           || 'puis 1-schema-et-referentiels.sql'
    end);

  insert into etat_installation values (3, 'Le stock',
    n_prod || ' produits sur 36',
    case when n_prod = 0 and n_anom = 670 then 'Jouer 3-stock.sql'
         when n_prod = 36 then 'rien — 3-stock.sql est passé'
         when n_prod = 0 then 'plus tard, après les anomalies'
         else 'Compte inattendu pour 3-stock.sql' end);

  insert into etat_installation values (4, 'Les bouteilles',
    n_bout || ' dossiers sur 17',
    case when n_bout = 0 and n_prod = 36 then 'Jouer 4-bouteilles.sql'
         when n_bout = 17 then 'rien — 4-bouteilles.sql est passé'
         when n_bout = 0 then 'plus tard, après le stock'
         else 'Compte inattendu pour 4-bouteilles.sql' end);

  insert into etat_installation values (5, 'L''équipe',
    case when equipe_faite then 'noms corrigés' else 'noms bruts de l''export' end,
    case when equipe_faite then 'rien — 5-equipe.sql est passé'
         when n_bout = 17 then 'Jouer 5-equipe.sql, et l''installation est finie'
         else 'plus tard, en dernier' end);
end $$;

select etape as "Étape", constat as "Où ça en est", a_faire as "À faire maintenant"
  from etat_installation order by ordre;
