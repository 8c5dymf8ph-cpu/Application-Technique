-- =============================================================================
-- Migration 0019 : une journée se rattache ligne à ligne, et se détache aussi
-- =============================================================================
-- `fn_journees_rapprochables` rendait un seul drapeau par journée :
-- `deja_rapprochee = bool_or(...)`. Il suffisait qu'UNE intervention de la
-- journée soit rattachée pour que la journée entière soit marquée « déjà
-- rattachée » — et l'écran retirait alors le seul bouton qui permettait
-- d'ajouter les autres.
--
-- Conséquence, vécue : on retire une ligne d'une facture avec le bouton « − »,
-- et elle DISPARAÎT. Elle n'est plus dans la facture, et la journée qui la
-- contient se présente comme déjà traitée : plus aucun chemin ne la ramène.
-- « Je ne sais pas où sont passées ces anomalies, et je ne peux pas revenir en
-- arrière. » Un geste réversible qui ne se défait pas n'est pas réversible.
--
-- La fonction dit désormais ce qu'elle sait vraiment : combien de lignes la
-- journée porte, combien sont DÉJÀ sur cette facture, et surtout `restantes`
-- — celles qui ne le sont pas. C'est ce tableau que le bouton rattache, donc
-- il rattache toujours exactement ce qui manque.
--
-- `interventions` garde toutes les lignes de la journée : l'écran s'en sert
-- pour montrer ce que la journée contient.

drop function if exists fn_journees_rapprochables(uuid, int);

create function fn_journees_rapprochables(
  p_facture_id uuid,
  p_jours int default 30
) returns table (
  date_intervention  date,
  intervenant        text,
  nb_anomalies       int,
  nb_rattachees      int,
  emplacements       text,
  apercu             text,
  cout_materiel      numeric,
  ecart_jours        int,
  interventions      uuid[],
  restantes          uuid[],
  deja_rapprochee    boolean
)
language sql stable as $$
  select
    i.date_intervention,
    coalesce(pr.nom, ut.nom)                              as intervenant,
    count(*)::int                                         as nb_anomalies,
    count(fi.facture_id)::int                             as nb_rattachees,
    string_agg(distinct e.code, ', ' order by e.code)     as emplacements,
    -- Chaque anomalie reste collée à son lieu. Séparer les deux listes laissait
    -- croire qu'il y avait un lave-vaisselle dans la chambre 57.
    string_agg(e.code || ' — ' || a.description, E'\n' order by e.code, a.reference)
                                                          as apercu,
    coalesce(sum(c.cout_materiel), 0)                     as cout_materiel,
    (f.date_reference - i.date_intervention)::int         as ecart_jours,
    array_agg(i.id order by a.reference)                  as interventions,
    -- Ce qui manque à la facture : c'est ce que le bouton rattache. Une journée
    -- à moitié rattachée reste donc actionnable, et une ligne retirée revient.
    array_remove(array_agg(
      case when fi.facture_id is null then i.id end order by a.reference), null)
                                                          as restantes,
    count(fi.facture_id) = count(*)                       as deja_rapprochee
  from factures f
  join interventions i on i.prestataire_id = f.prestataire_id
  join anomalies a     on a.id = i.anomalie_id
  join emplacements e  on e.id = a.emplacement_id
  left join prestataires pr on pr.id = i.prestataire_id
  left join utilisateurs ut on ut.id = i.technicien_id
  left join v_interventions_cout c   on c.intervention_id = i.id
  left join facture_interventions fi on fi.facture_id = f.id and fi.intervention_id = i.id
  where f.id = p_facture_id
    and f.type = 'prestation'
    and case
          when f.periode_debut is not null and f.periode_fin is not null
            then i.date_intervention between f.periode_debut and f.periode_fin
          else i.date_intervention between f.date_reference - p_jours and f.date_reference
        end
    -- pas déjà pris par une AUTRE facture
    and not exists (
      select 1 from facture_interventions x
      where x.intervention_id = i.id and x.facture_id <> f.id)
  group by i.date_intervention, coalesce(pr.nom, ut.nom), f.date_reference
  order by i.date_intervention desc;
$$;

comment on function fn_journees_rapprochables(uuid, int) is
  'Les journées d''intervenant qu''une facture peut couvrir. `restantes` porte '
  'les lignes qui ne sont PAS encore sur cette facture : c''est ce que le '
  'bouton rattache, pour qu''une journée à moitié rattachée reste actionnable '
  'et qu''une ligne retirée puisse revenir.';
