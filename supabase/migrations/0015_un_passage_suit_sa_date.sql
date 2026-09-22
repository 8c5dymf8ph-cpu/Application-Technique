-- =============================================================================
-- Migration 0015 : un passage suit la date de ses interventions
-- =============================================================================
-- L'ancien export donnait les dates en TEXTE, dans deux formats mélangés :
-- « 17/12/2024 » d'un côté, « 2025-09-12 » de l'autre. L'import devait deviner,
-- et il s'est trompé — 270 dates de déclaration et 229 dates d'intervention
-- avaient le jour et le mois inversés. Le nettoyage de l'export les rend en
-- vraies dates, sans ambiguïté, et il faut donc pouvoir les corriger en base.
--
-- Or corriger la date d'une intervention ne suffit pas : ce qui identifie un
-- passage, c'est QUI est venu et QUEL JOUR (règle 16). Une intervention qui
-- change de jour change donc de passage — sinon la tournée du 12 septembre
-- contient une intervention du 9 décembre, et la facture ne se rapproche plus.
--
-- La 0006 avait fait ce regroupement une fois, pour les interventions orphelines.
-- Ici on en fait une **règle rejouable** : après chaque reprise d'export, on
-- rappelle la fonction et les passages se remettent d'aplomb.
--
-- Ce qu'elle ne touche JAMAIS : les interventions saisies dans l'application.
-- Elles n'ont pas d'`InterventionID` d'origine et leur anomalie n'a pas de
-- `sharepoint_id` ; leur tournée est celle que le technicien a ouverte, et la
-- déplacer effacerait son passage du jour.

create or replace function fn_regrouper_les_passages()
returns table (deplacees int, creees int, videes int)
language plpgsql as $$
declare
  v_deplacees int := 0;
  v_creees    int := 0;
  v_videes    int := 0;
begin
  -- 1. Les passages qui manquent, un par intervenant et par jour.
  --    `on conflict` rend l'appel rejouable : un second passage ne recrée rien.
  with attendus as (
    select distinct i.technicien_id, i.prestataire_id, i.date_intervention
      from interventions i
      join anomalies a on a.id = i.anomalie_id
     where a.sharepoint_id is not null
       and (i.technicien_id is not null or i.prestataire_id is not null)
       and not exists (
         select 1 from tournees t
          where t.date_tournee = i.date_intervention
            and t.technicien_id  is not distinct from i.technicien_id
            and t.prestataire_id is not distinct from i.prestataire_id)
  ),
  nommes as (
    select v.*,
           upper(regexp_replace(coalesce(u.nom, p.nom, 'INCONNU'), '[^A-Za-z0-9]+', '', 'g'))
             as etiquette
      from attendus v
      left join utilisateurs u on u.id = v.technicien_id
      left join prestataires p on p.id = v.prestataire_id
  ),
  posees as (
    insert into tournees (reference, technicien_id, prestataire_id, date_tournee,
                          cloturee_le, mail_technicien_envoye_le, mail_recap_envoye_le,
                          reprise, commentaire)
    select 'INT-REPRISE-' || etiquette || '-' || to_char(date_intervention, 'YYYYMMDD'),
           technicien_id, prestataire_id, date_intervention,
           date_intervention::timestamptz,  -- le passage a eu lieu, il est clos
           date_intervention::timestamptz,  -- rien ne part : c'est de l'historique
           date_intervention::timestamptz,
           true,
           'Passage reconstitué depuis les interventions reprises.'
      from nommes
    on conflict (reference) do nothing
    returning 1
  )
  select count(*)::int into v_creees from posees;

  -- 2. Chaque intervention reprise rejoint le passage de SON jour et de SON
  --    intervenant. C'est ici que la correction d'une date déplace le travail.
  with bougees as (
    update interventions i
       set tournee_id = t.id
      from tournees t, anomalies a
     where a.id = i.anomalie_id
       and a.sharepoint_id is not null
       and t.date_tournee = i.date_intervention
       and t.technicien_id  is not distinct from i.technicien_id
       and t.prestataire_id is not distinct from i.prestataire_id
       and i.tournee_id is distinct from t.id
    returning 1
  )
  select count(*)::int into v_deplacees from bougees;

  -- 3. Les passages reconstitués que plus rien n'habite s'effacent : une
  --    tournée vide apparaîtrait dans l'historique sans rien à montrer.
  --    Seuls les `reprise` : une tournée ouverte dans l'application peut être
  --    vide parce que le technicien vient de la commencer.
  with videes as (
    delete from tournees t
     where t.reprise
       and not exists (select 1 from interventions i where i.tournee_id = t.id)
    returning 1
  )
  select count(*)::int into v_videes from videes;

  return query select v_deplacees, v_creees, v_videes;
end;
$$;

comment on function fn_regrouper_les_passages() is
  'Remet les passages d''aplomb après une reprise d''export : un passage par '
  'intervenant et par jour, les interventions reprises accrochées au bon, et '
  'les passages reconstitués devenus vides effacés. Ne touche jamais une '
  'intervention saisie dans l''application.';

-- On l'applique tout de suite : la base porte déjà les dates devinées.
select * from fn_regrouper_les_passages();
