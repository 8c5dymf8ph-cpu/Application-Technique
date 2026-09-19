-- =============================================================================
-- Migration 0006 : rendre à l'historique les passages qui y manquaient
-- =============================================================================
-- L'import de l'ancienne application n'a créé une tournée que pour les lignes
-- qui portaient un InterventionID exploitable : 419 interventions sur 528 sont
-- restées sans passage. L'historique, qui liste les passages, n'en montrait
-- donc qu'un cinquième — et un coût ne peut pas se rattacher à un passage qui
-- n'existe pas.
--
-- Règle 16 : ce qui identifie un passage, c'est QUI est venu et QUEL JOUR.
-- C'est exactement ce qu'on reconstitue ici. Les tournées créées portent
-- `reprise` : le travail a eu lieu, il garde sa trace, mais aucun récapitulatif
-- ne part pour elles — sans quoi le premier envoi déverserait deux ans
-- d'historique.

-- 1. Rattacher d'abord à une tournée qui existe déjà pour ce même intervenant
--    ce même jour : inutile d'en créer une seconde à côté.
update interventions i
   set tournee_id = t.id
  from tournees t
 where i.tournee_id is null
   and t.date_tournee = i.date_intervention
   and t.technicien_id  is not distinct from i.technicien_id
   and t.prestataire_id is not distinct from i.prestataire_id;

-- 2. Créer les passages manquants, un par intervenant et par jour.
with manquants as (
  select distinct i.technicien_id, i.prestataire_id, i.date_intervention
    from interventions i
   where i.tournee_id is null
     and (i.technicien_id is not null or i.prestataire_id is not null)
),
nommes as (
  select m.*,
         upper(regexp_replace(coalesce(u.nom, p.nom, 'INCONNU'), '[^A-Za-z0-9]+', '', 'g'))
           as etiquette
    from manquants m
    left join utilisateurs u on u.id = m.technicien_id
    left join prestataires p on p.id = m.prestataire_id
)
insert into tournees (reference, technicien_id, prestataire_id, date_tournee,
                      cloturee_le, mail_technicien_envoye_le, mail_recap_envoye_le,
                      reprise, commentaire)
select 'INT-REPRISE-' || etiquette || '-' || to_char(date_intervention, 'YYYYMMDD'),
       technicien_id, prestataire_id, date_intervention,
       date_intervention::timestamptz,   -- le passage a eu lieu, il est clos
       date_intervention::timestamptz,   -- rien ne part : c'est de l'historique
       date_intervention::timestamptz,
       true,
       'Passage reconstitué depuis les interventions reprises.'
  from nommes
on conflict (reference) do nothing;

-- 3. Y accrocher les interventions.
update interventions i
   set tournee_id = t.id
  from tournees t
 where i.tournee_id is null
   and t.date_tournee = i.date_intervention
   and t.technicien_id  is not distinct from i.technicien_id
   and t.prestataire_id is not distinct from i.prestataire_id;
