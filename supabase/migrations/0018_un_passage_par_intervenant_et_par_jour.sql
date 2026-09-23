-- =============================================================================
-- Migration 0018 : un passage par intervenant et par jour, à la racine
-- =============================================================================
-- La règle 16 dit ce qu'est un passage : QUI est venu et QUEL JOUR. La 0015 la
-- faisait respecter pour l'historique repris. Mais l'application, elle,
-- continuait d'en créer plusieurs : `tourneeEnCours` ne rendait la tournée du
-- jour que si elle était ENCORE OUVERTE. Le technicien rendait son lot le
-- matin, revenait l'après-midi — et un second passage naissait.
--
-- Trois conséquences, toutes visibles :
--   · l'historique montre trois passages là où il y a eu une journée ;
--   · le récapitulatif part trois fois, et celui de la gouvernante aussi —
--     c'est le « dix mails par jour » de l'ancienne application ;
--   · une facture ne se rapproche plus de rien de net, alors que c'est
--     exactement par (intervenant, journée) qu'elle se rapproche.
--
-- On ferme la porte en base plutôt que dans l'écran : un index unique. Ce qui
-- est interdit ici ne peut pas revenir par une autre porte.
--
-- Et puisqu'un passage se rouvre (il revient, il a oublié une chambre), la
-- clôture a maintenant son miroir : rouvrir retire de la file de la
-- gouvernante ce qu'elle n'a pas encore tranché. Le lot n'existe pour elle
-- qu'une fois rendu — dans les deux sens.

-- -----------------------------------------------------------------------------
-- 1. Fusionner ce qui existe déjà
-- -----------------------------------------------------------------------------
-- Rejouable : sur une base déjà d'aplomb elle ne trouve rien à fusionner.
create or replace function fn_fusionner_les_passages_du_jour()
returns table (fusionnes int, deplacees int)
language plpgsql as $$
declare
  g            record;
  v_garde      uuid;
  v_fusionnes  int := 0;
  v_deplacees  int := 0;
  n            int;
begin
  for g in
    select coalesce(technicien_id,  '00000000-0000-0000-0000-000000000000') as t,
           coalesce(prestataire_id, '00000000-0000-0000-0000-000000000000') as p,
           date_tournee
      from tournees
     group by 1, 2, 3
    having count(*) > 1
  loop
    -- Celle qu'on garde : une vraie tournée plutôt qu'une reprise (le drapeau
    -- `reprise` éteint les envois, l'hériter ferait taire un passage réel),
    -- puis la plus ancienne — c'est elle qui porte la référence qu'on a pu
    -- citer ailleurs.
    select id into v_garde
      from tournees
     where coalesce(technicien_id,  '00000000-0000-0000-0000-000000000000') = g.t
       and coalesce(prestataire_id, '00000000-0000-0000-0000-000000000000') = g.p
       and date_tournee = g.date_tournee
     order by reprise, cree_le
     limit 1;

    with bougees as (
      update interventions i set tournee_id = v_garde
        from tournees t
       where i.tournee_id = t.id
         and t.id <> v_garde
         and coalesce(t.technicien_id,  '00000000-0000-0000-0000-000000000000') = g.t
         and coalesce(t.prestataire_id, '00000000-0000-0000-0000-000000000000') = g.p
         and t.date_tournee = g.date_tournee
      returning 1)
    select count(*)::int into n from bougees;
    v_deplacees := v_deplacees + n;

    -- La journée garde ce qui s'y est réellement passé : elle est close si
    -- toutes l'étaient, et elle porte la date du dernier envoi — sinon un
    -- récapitulatif déjà parti repartirait.
    update tournees g2 set
      cloturee_le = (select max(x.cloturee_le) from tournees x
                      where coalesce(x.technicien_id,  '00000000-0000-0000-0000-000000000000') = g.t
                        and coalesce(x.prestataire_id, '00000000-0000-0000-0000-000000000000') = g.p
                        and x.date_tournee = g.date_tournee
                        and not exists (select 1 from tournees y
                                         where y.id = x.id and y.cloturee_le is null)),
      mail_technicien_envoye_le = greatest(g2.mail_technicien_envoye_le,
        (select max(x.mail_technicien_envoye_le) from tournees x
          where coalesce(x.technicien_id,  '00000000-0000-0000-0000-000000000000') = g.t
            and coalesce(x.prestataire_id, '00000000-0000-0000-0000-000000000000') = g.p
            and x.date_tournee = g.date_tournee)),
      mail_recap_envoye_le = greatest(g2.mail_recap_envoye_le,
        (select max(x.mail_recap_envoye_le) from tournees x
          where coalesce(x.technicien_id,  '00000000-0000-0000-0000-000000000000') = g.t
            and coalesce(x.prestataire_id, '00000000-0000-0000-0000-000000000000') = g.p
            and x.date_tournee = g.date_tournee)),
      reprise = (select bool_and(x.reprise) from tournees x
                  where coalesce(x.technicien_id,  '00000000-0000-0000-0000-000000000000') = g.t
                    and coalesce(x.prestataire_id, '00000000-0000-0000-0000-000000000000') = g.p
                    and x.date_tournee = g.date_tournee)
    where g2.id = v_garde;

    with effacees as (
      delete from tournees t
       where t.id <> v_garde
         and coalesce(t.technicien_id,  '00000000-0000-0000-0000-000000000000') = g.t
         and coalesce(t.prestataire_id, '00000000-0000-0000-0000-000000000000') = g.p
         and t.date_tournee = g.date_tournee
      returning 1)
    select count(*)::int into n from effacees;
    v_fusionnes := v_fusionnes + n;
  end loop;

  return query select v_fusionnes, v_deplacees;
end;
$$;

comment on function fn_fusionner_les_passages_du_jour() is
  'Ramène à UN passage ce qui a été ouvert plusieurs fois pour le même '
  'intervenant le même jour. Rejouable : sans doublon, elle ne fait rien.';

select * from fn_fusionner_les_passages_du_jour();

-- -----------------------------------------------------------------------------
-- 2. La porte se ferme : un seul passage par intervenant et par jour
-- -----------------------------------------------------------------------------
-- `coalesce` plutôt que `nulls not distinct` : deux NULL sont distincts pour un
-- index unique, et une tournée de prestataire a toujours `technicien_id` nul —
-- sans cela la contrainte ne retiendrait rien.
drop index if exists passage_unique_par_intervenant_et_jour;
create unique index passage_unique_par_intervenant_et_jour on tournees (
  coalesce(technicien_id,  '00000000-0000-0000-0000-000000000000'),
  coalesce(prestataire_id, '00000000-0000-0000-0000-000000000000'),
  date_tournee);

-- -----------------------------------------------------------------------------
-- 3. Créer une tournée, c'est retrouver celle du jour
-- -----------------------------------------------------------------------------
-- Ouverte ou déjà rendue : c'est la même journée, donc le même passage. C'est
-- ici que se joue la racine — l'écran n'a plus à y penser, et un autre écran
-- écrit plus tard ne pourra pas se tromper.
-- La signature gagne une date : on saisit des passages anciens (règle 16sexies,
-- et Miguel reprend de l'historique). `create or replace` ne remplace pas une
-- fonction dont la signature change — il en AJOUTE une seconde, et l'appel à
-- deux arguments devient ambigu : « function is not unique ». On retire donc
-- l'ancienne d'abord.
drop function if exists fn_creer_tournee(uuid, uuid);

create or replace function fn_creer_tournee(
  p_technicien_id uuid default null,
  p_prestataire_id uuid default null,
  p_date date default null
) returns tournees
language plpgsql as $$
declare
  v_nom     text;
  v_jour    date := coalesce(p_date, current_date);
  v_tournee tournees;
begin
  select * into v_tournee from tournees t
   where t.date_tournee = v_jour
     and t.technicien_id  is not distinct from p_technicien_id
     and t.prestataire_id is not distinct from p_prestataire_id;
  if found then
    return v_tournee;
  end if;

  select upper(regexp_replace(coalesce(u.nom, pr.nom, 'INT'), '[^A-Za-z0-9]', '', 'g'))
    into v_nom
  from (select 1) x
  left join utilisateurs u   on u.id = p_technicien_id
  left join prestataires pr  on pr.id = p_prestataire_id;

  insert into tournees (reference, technicien_id, prestataire_id, date_tournee)
  values (
    'INT-' || left(v_nom, 10) || '-' || to_char(v_jour, 'YYYYMMDD')
           || '-' || substr(md5(random()::text), 1, 4),
    p_technicien_id, p_prestataire_id, v_jour)
  returning * into v_tournee;

  return v_tournee;
end;
$$;

comment on function fn_creer_tournee(uuid, uuid, date) is
  'La tournée de cet intervenant ce jour-là, existante ou neuve. Un passage, '
  'c''est qui est venu et quel jour : on n''en ouvre jamais un second.';

-- -----------------------------------------------------------------------------
-- 4. Rouvrir un passage retire de la file ce qui n'est pas tranché
-- -----------------------------------------------------------------------------
-- Le miroir de `tg_cloture_tournee`. Sans lui, rouvrir laisserait la
-- gouvernante devant un lot que le technicien est en train de reprendre — et
-- elle validerait un travail qu'il n'a pas fini de déclarer.
--
-- Ce qu'elle a DÉJÀ tranché ne bouge pas : sa décision est un fait.
create or replace function fn_reouverture_tournee_maj_anomalies() returns trigger
language plpgsql as $$
begin
  update anomalies a set statut = 'en_cours', maj_le = now()
   from interventions i
  where i.tournee_id = new.id
    and i.anomalie_id = a.id
    and a.statut = 'attente_validation'
    and not exists (
      select 1 from validations v
       where v.intervention_id = i.id and v.acteur = 'gouvernante');
  return new;
end;
$$;

drop trigger if exists tg_reouverture_tournee on tournees;
create trigger tg_reouverture_tournee
  after update of cloturee_le on tournees
  for each row
  when (old.cloturee_le is not null and new.cloturee_le is null)
  execute function fn_reouverture_tournee_maj_anomalies();
