-- =============================================================================
-- Migration 0004 : la gouvernante ne voit le lot qu'une fois rendu
-- =============================================================================
-- Le technicien coche ses anomalies au fil de son passage, puis appuie sur
-- « Fin d'intervention ». Entre les deux, il peut se raviser, revenir sur une
-- chambre, ajouter du matériel. Basculer chaque anomalie en attente de
-- validation dès qu'il la coche mettait la gouvernante devant un travail que
-- personne n'avait encore déclaré terminé — et faisait apparaître un lot « à
-- valider » alors que le technicien était encore dans les étages.
--
-- Règle 10 : le technicien rend un LOT, la gouvernante valide à l'unité.
-- L'anomalie cochée reste donc `en_cours` tant que la tournée est ouverte, et
-- passe `attente_validation` à la clôture, toutes ensemble.

create or replace function fn_validation_maj_anomalie() returns trigger
language plpgsql as $$
declare
  v_anomalie_id uuid;
  v_lot_rendu   boolean;
begin
  select i.anomalie_id, (t.cloturee_le is not null)
    into v_anomalie_id, v_lot_rendu
    from interventions i
    left join tournees t on t.id = i.tournee_id
   where i.id = new.intervention_id;

  update anomalies set
    statut = case
      -- Déclarée faite : elle attend la gouvernante seulement si le lot est
      -- rendu. Sinon elle reste en cours, visible du technicien.
      when new.acteur = 'technicien'  and new.decision = 'fait'
        then case when coalesce(v_lot_rendu, true)
                  then 'attente_validation'::statut_anomalie
                  else 'en_cours'::statut_anomalie end
      when new.acteur = 'technicien'  and new.decision = 'non_fait'  then 'en_cours'::statut_anomalie
      when new.acteur = 'gouvernante' and new.decision = 'validee'   then 'validee'::statut_anomalie
      when new.acteur = 'gouvernante' and new.decision = 'en_cours'  then 'en_cours'::statut_anomalie
      when new.acteur = 'gouvernante' and new.decision = 'a_refaire' then 'a_faire'::statut_anomalie
      else statut
    end,
    cloture_le = case
      when new.acteur = 'gouvernante' and new.decision = 'validee' then new.decide_le
      else null
    end,
    maj_le = now()
  -- Une anomalie annulée le reste : une validation arrivée après coup ne doit
  -- pas la ramener à la vie, sinon le même problème redeviendrait ouvert deux
  -- fois au même endroit.
  where id = v_anomalie_id and statut <> 'annulee';

  return new;
end;
$$;

-- La clôture rend le lot : tout ce que le technicien a déclaré fait passe
-- alors, d'un coup, sous les yeux de la gouvernante.
create or replace function fn_cloture_tournee_maj_anomalies() returns trigger
language plpgsql as $$
begin
  update anomalies a set statut = 'attente_validation', maj_le = now()
   from interventions i
  where i.tournee_id = new.id
    and i.anomalie_id = a.id
    and a.statut = 'en_cours'
    and exists (
      select 1 from validations v
       where v.intervention_id = i.id
         and v.acteur = 'technicien' and v.decision = 'fait');
  return new;
end;
$$;

drop trigger if exists tg_cloture_tournee on tournees;
create trigger tg_cloture_tournee
  after update of cloturee_le on tournees
  for each row
  when (old.cloturee_le is null and new.cloturee_le is not null)
  execute function fn_cloture_tournee_maj_anomalies();

-- La vue disait « à valider » dès qu'une intervention n'avait pas encore l'avis
-- de la gouvernante, tournée ouverte ou non : un technicien en train de faire
-- son passage remplissait déjà la file de la gouvernante. Ce qui attend un avis
-- n'existe qu'une fois le lot rendu.
create or replace view v_tournees as
select
  t.id,
  t.reference,
  t.date_tournee,
  coalesce(u.nom, p.nom)                   as intervenant,
  t.cloturee_le,
  t.reprise,
  t.mail_technicien_envoye_le,
  t.mail_recap_envoye_le,
  count(r.intervention_id)                                                  as nb_interventions,
  case when t.cloturee_le is null then 0 else
    count(*) filter (where r.intervention_id is not null
                       and r.decision_gouvernante is null) end              as nb_en_attente,
  count(*) filter (where r.decision_gouvernante = 'validee')                as nb_validees,
  count(*) filter (where r.decision_gouvernante = 'a_refaire')              as nb_a_refaire,
  count(*) filter (where r.decision_gouvernante = 'en_cours')               as nb_en_cours,
  coalesce(sum(r.cout_total), 0)                                            as cout_total,
  bool_or(r.cout_incomplet)                                                 as cout_incomplet,
  t.cloturee_le is not null
    and count(r.intervention_id) > 0
    and count(*) filter (where r.intervention_id is not null
                           and r.decision_gouvernante is null) = 0          as prete_pour_recap
from tournees t
left join utilisateurs u  on u.id = t.technicien_id
left join prestataires p  on p.id = t.prestataire_id
left join v_recap_interventions r on r.tournee = t.reference
group by t.id, u.nom, p.nom;
