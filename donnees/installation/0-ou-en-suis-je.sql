-- -----------------------------------------------------------------------------
-- Où en suis-je ? — à jouer quand on ne sait plus quel fichier a été passé.
-- -----------------------------------------------------------------------------
-- Ne modifie rien. Se rejoue à volonté. Produit par
-- outils/finaliser_installation.py : la liste suit les fichiers réellement
-- livrés, elle ne se recopie pas à la main.
do $$
begin
  if to_regclass('public.installation_journal') is null then
    create temp table if not exists installation_journal (
      fichier text primary key, joue_le timestamptz
    );
    delete from installation_journal;
  end if;
end $$;

with attendus (rang, fichier) as (
  values
      (1, '1-schema-et-referentiels.sql'),
      (2, '2-anomalies-a.sql'),
      (3, '2-anomalies-b.sql'),
      (4, '2-anomalies-c.sql'),
      (5, '2-anomalies-d.sql'),
      (6, '2-anomalies-e.sql'),
      (7, '2-anomalies-f.sql'),
      (8, '2-anomalies-g.sql'),
      (9, '2-anomalies-h.sql'),
      (10, '2-anomalies-i.sql'),
      (11, '3-stock-a.sql'),
      (12, '3-stock-b.sql'),
      (13, '4-bouteilles.sql'),
      (14, '5-equipe.sql'),
      (15, '6-passages.sql')
),
faits as (
  select fichier from installation_journal
  union
  -- Une base commencée avant l'existence du journal : le schéma prouve à lui
  -- seul que le fichier 1 est passé, et il refuserait d'être rejoué.
  select '1-schema-et-referentiels.sql'
   where to_regclass('public.emplacements') is not null
),
etat as (
  select a.rang, a.fichier, (f.fichier is not null) as joue,
         min(a.rang) filter (where f.fichier is null) over () as prochain
    from attendus a left join faits f on f.fichier = a.fichier
)
select fichier as "Fichier",
       case when joue              then 'joué'
            when rang = prochain   then '>>> À JOUER MAINTENANT <<<'
            else                        'à venir'
       end as "État"
  from etat
 order by rang;
