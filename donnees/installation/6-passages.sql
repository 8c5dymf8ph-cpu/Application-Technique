-- Un passage par intervenant et par jour, une fois les interventions en place.
-- Rejouable : un second passage ne recrée rien.
select * from fn_regrouper_les_passages();


-- Trace de passage : c'est elle que lit 0-ou-en-suis-je.sql.
create table if not exists installation_journal (
  fichier  text primary key,
  joue_le  timestamptz not null default now()
);
insert into installation_journal (fichier) values ('6-passages.sql')
  on conflict (fichier) do update set joue_le = now();

select '6-passages.sql' as "Fichier joué", (select count(*) || ' passages reconstitués' from tournees where reprise) as "Où ça en est";
