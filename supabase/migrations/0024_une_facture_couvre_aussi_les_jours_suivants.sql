-- =============================================================================
-- Migration 0024 : une facture couvre aussi les jours qui SUIVENT, et une
--                  journée déjà prise ailleurs se voit
-- =============================================================================
-- Deux impasses, vécues le même soir, sur la même facture de Serafino.
--
-- 1. « Je ne peux pas ajouter cet ancien passage. » La fenêtre des journées
--    rapprochables était fermée d'un côté : `between date_reference - p_jours
--    and date_reference`. Or `date_reference` est le jour du passage DEPUIS
--    lequel la facture a été saisie — pas la fin de ce qu'elle couvre. La
--    facture saisie sur le passage du 23 février ne pouvait donc jamais
--    couvrir le passage du 25, deux jours plus tard : il n'était nulle part
--    dans la liste, et rien ne disait pourquoi. Serafino facture son MOIS ;
--    la pièce arrive après, et le jour où on la saisit n'a aucune raison
--    d'être le dernier jour couvert. La fenêtre s'ouvre donc des deux côtés.
--
-- 2. « Pareil pour le passage du 29 avril, je ne peux pas le rattacher à une
--    autre facture. » Une journée déjà portée par une AUTRE facture était
--    retirée de la liste — `not exists (… facture_id <> f.id)`. Elle
--    n'existait plus nulle part : ni rattachable, ni détachable, ni même
--    nommée. C'est le même défaut que la 0019 corrigeait à l'intérieur d'une
--    journée, une fois de plus : ce qui est pris ailleurs se DIT, avec le
--    numéro de la pièce qui le porte, et se déplace.
--
-- Trois colonnes de plus, et `restantes` se resserre sur son vrai sens :
--   `restantes` — les lignes libres, qu'aucune facture ne porte. C'est ce que
--                 « + Ajouter » rattache, et c'est tout ce qu'il peut
--                 rattacher : une ligne sur deux factures serait comptée deux
--                 fois dans le coût d'un passage.
--   `ailleurs`  — les lignes portées par une autre pièce. C'est ce que
--                 « Déplacer ici » prend, en les retirant de l'autre.
--   `autre_facture` / `autre_facture_id` — laquelle, pour pouvoir le dire et
--                 y aller.
--
-- Au passage, la fonction ne joignait que sur `prestataire_id` : la facture
-- de Farid ou de Rachid, qui facturent sans être une entreprise (règle
-- 10quinquies), ne trouvait jamais une seule journée.

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
  ailleurs           uuid[],
  autre_facture      text,
  autre_facture_id   uuid,
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
    -- Positif avant la facture, négatif après : la fenêtre n'est plus fermée
    -- d'un côté, l'écart non plus.
    (f.date_reference - i.date_intervention)::int         as ecart_jours,
    array_agg(i.id order by a.reference)                  as interventions,
    -- Ce qui manque à la facture ET que rien d'autre ne porte : c'est ce que
    -- le bouton rattache. Une journée à moitié rattachée reste actionnable, et
    -- une ligne retirée revient (règle 16octies).
    array_remove(array_agg(
      case when fi.facture_id is null and au.facture_id is null then i.id end
      order by a.reference), null)                        as restantes,
    -- Ce qu'une autre pièce porte déjà. Caché, c'était une ligne perdue.
    array_remove(array_agg(
      case when au.facture_id is not null then i.id end
      order by a.reference), null)                        as ailleurs,
    string_agg(distinct
      case when au.facture_id is not null
           then coalesce(au.reference, 'sans numéro') end, ', ')
                                                          as autre_facture,
    (array_agg(au.facture_id) filter (where au.facture_id is not null))[1]
                                                          as autre_facture_id,
    count(fi.facture_id) = count(*)                       as deja_rapprochee
  from factures f
  -- Qui facture ne se déduit pas du fait d'être une entreprise (règle
  -- 10quinquies) : Farid et Rachid facturent sans être des prestataires, et
  -- leur facture porte `technicien_id`. Joindre sur le seul `prestataire_id`
  -- rendait AUCUNE journée pour eux — le bloc « ce que cette facture couvre »
  -- ne s'affichait même pas.
  join interventions i
    on (f.prestataire_id is not null and i.prestataire_id = f.prestataire_id)
    or (f.technicien_id  is not null and i.technicien_id  = f.technicien_id)
  join anomalies a     on a.id = i.anomalie_id
  join emplacements e  on e.id = a.emplacement_id
  left join prestataires pr on pr.id = i.prestataire_id
  left join utilisateurs ut on ut.id = i.technicien_id
  left join v_interventions_cout c   on c.intervention_id = i.id
  left join facture_interventions fi on fi.facture_id = f.id and fi.intervention_id = i.id
  -- L'autre pièce, s'il y en a une. On ne la cache plus : on la nomme.
  left join lateral (
    select x.facture_id, xf.reference
      from facture_interventions x
      join factures xf on xf.id = x.facture_id
     where x.intervention_id = i.id and x.facture_id <> f.id
     limit 1) au on true
  where f.id = p_facture_id
    and f.type = 'prestation'
    and case
          when f.periode_debut is not null and f.periode_fin is not null
            then i.date_intervention between f.periode_debut and f.periode_fin
          -- Des deux côtés : le jour où la pièce est saisie n'est pas le
          -- dernier jour qu'elle couvre.
          else i.date_intervention between f.date_reference - p_jours
                                       and f.date_reference + p_jours
        end
  group by i.date_intervention, coalesce(pr.nom, ut.nom), f.date_reference
  order by i.date_intervention desc;
$$;

comment on function fn_journees_rapprochables(uuid, int) is
  'Les journées d''intervenant qu''une facture peut couvrir, avant comme après '
  'son jour de référence. `restantes` porte les lignes libres — ce que le '
  'bouton rattache ; `ailleurs` celles qu''une AUTRE pièce porte déjà, avec '
  'son numéro, pour pouvoir les déplacer plutôt que de les faire disparaître.';
