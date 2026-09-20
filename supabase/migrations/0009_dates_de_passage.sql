-- =============================================================================
-- Migration 0009 : la date d'un passage est celle du travail, pas de son
-- identifiant
-- =============================================================================
-- L'ancienne application nommait ses lots « INT-ALAIN-20260429160344684 » : un
-- horodatage de SAISIE. La date qui compte est celle de la colonne « FAIT LE ».
-- L'import la prend déjà quand elle est là, mais il date la tournée d'après la
-- PREMIÈRE ligne rencontrée : si un même identifiant couvrait deux journées, le
-- passage portait la date de l'une et les interventions celle de l'autre.
--
-- Règle 16 : un passage, c'est qui est venu et quel jour. Deux journées font
-- deux passages, et la date affichée doit être celle du travail.

-- 1. Sortir de leur tournée les interventions faites un autre jour, et leur
--    donner le passage de LEUR journée — en le créant s'il n'existe pas.
with a_deplacer as (
  select i.id,
         i.technicien_id, i.prestataire_id, i.date_intervention,
         upper(regexp_replace(coalesce(u.nom, p.nom, 'INCONNU'), '[^A-Za-z0-9]+', '', 'g'))
           as etiquette
    from interventions i
    join tournees t on t.id = i.tournee_id
    left join utilisateurs u on u.id = i.technicien_id
    left join prestataires p on p.id = i.prestataire_id
   where i.date_intervention <> t.date_tournee
)
insert into tournees (reference, technicien_id, prestataire_id, date_tournee,
                      cloturee_le, mail_technicien_envoye_le, mail_recap_envoye_le,
                      reprise, commentaire)
select distinct
       'INT-REPRISE-' || etiquette || '-' || to_char(date_intervention, 'YYYYMMDD'),
       technicien_id, prestataire_id, date_intervention,
       date_intervention::timestamptz, date_intervention::timestamptz,
       date_intervention::timestamptz, true,
       'Passage reconstitué : la date de travail ne suivait pas son identifiant.'
  from a_deplacer
on conflict (reference) do nothing;

update interventions i
   set tournee_id = t.id
  from tournees t
 where t.date_tournee = i.date_intervention
   and t.technicien_id  is not distinct from i.technicien_id
   and t.prestataire_id is not distinct from i.prestataire_id
   and i.tournee_id is distinct from t.id
   and exists (select 1 from tournees o
                where o.id = i.tournee_id and o.date_tournee <> i.date_intervention);

-- 2. Une tournée dont toutes les interventions sont d'un autre jour prend
--    leur date : c'est l'identifiant qui datait mal, pas le travail.
update tournees t
   set date_tournee = v.jour,
       cloturee_le = coalesce(t.cloturee_le, v.jour::timestamptz)
  from (select i.tournee_id, min(i.date_intervention) as jour
          from interventions i group by i.tournee_id
         having count(distinct i.date_intervention) = 1) v
 where v.tournee_id = t.id and t.date_tournee <> v.jour;

-- 3. Une tournée vidée de ses interventions n'a plus de raison d'être.
delete from tournees t
 where t.reprise
   and not exists (select 1 from interventions i where i.tournee_id = t.id);

-- 4. Filet : une intervention qui aurait perdu son passage en retrouve un.
--    `interventions.tournee_id` est en « on delete set null » — supprimer une
--    tournée détache ses interventions au lieu de les emporter, et elles
--    disparaîtraient de l'historique sans que rien ne le dise.
with orphelines as (
  select distinct i.technicien_id, i.prestataire_id, i.date_intervention,
         upper(regexp_replace(coalesce(u.nom, p.nom, 'INCONNU'), '[^A-Za-z0-9]+', '', 'g'))
           as etiquette
    from interventions i
    left join utilisateurs u on u.id = i.technicien_id
    left join prestataires p on p.id = i.prestataire_id
   where i.tournee_id is null
     and (i.technicien_id is not null or i.prestataire_id is not null)
)
insert into tournees (reference, technicien_id, prestataire_id, date_tournee,
                      cloturee_le, mail_technicien_envoye_le, mail_recap_envoye_le,
                      reprise, commentaire)
select 'INT-REPRISE-' || etiquette || '-' || to_char(date_intervention, 'YYYYMMDD'),
       technicien_id, prestataire_id, date_intervention,
       date_intervention::timestamptz, date_intervention::timestamptz,
       date_intervention::timestamptz, true,
       'Passage reconstitué : intervention retrouvée sans passage.'
  from orphelines
on conflict (reference) do nothing;

update interventions i
   set tournee_id = t.id
  from tournees t
 where i.tournee_id is null
   and t.date_tournee = i.date_intervention
   and t.technicien_id  is not distinct from i.technicien_id
   and t.prestataire_id is not distinct from i.prestataire_id;
