-- =============================================================================
-- Migration 0002 : vues de calcul et règles métier
-- Tout ce qui se calcule est calculé ici. Aucune valeur de stock n'est stockée
-- en dur : ni Stock_Initial, ni StockActuel, ni EstHistorique, et donc aucun
-- bouton « recalculer le stock » — il n'y a rien à recalculer.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Stock matériel — alimente aussi la fiche produit
-- (Initial / Entrées / Sorties / Ajustements / Stock actuel)
-- -----------------------------------------------------------------------------
-- Le prix payé, dans le temps
--
-- Chaque entrée de stock porte le prix payé POUR CETTE livraison. Rien de plus
-- n'est nécessaire : l'évolution du prix se lit dans les mouvements, elle ne se
-- stocke pas. `produits.prix_unitaire` reste le prix de référence — celui qui
-- valorise le stock — et ces vues disent s'il est encore d'actualité.
-- -----------------------------------------------------------------------------
create view v_achats_produit as
select
  m.produit_id,
  m.id                        as mouvement_id,
  m.date_mouvement,
  m.quantite,
  m.prix_unitaire,
  f.nom                       as fournisseur,
  fa.reference                as facture,
  fa.fichier_url              as facture_fichier,
  fa.id                       as facture_id,
  -- Le prix payé la fois d'avant, pour lire la variation sans la calculer deux fois.
  lag(m.prix_unitaire) over (partition by m.produit_id order by m.date_mouvement,
                                                                m.id) as prix_precedent
from mouvements_stock m
left join factures fa     on fa.id = m.facture_id
left join fournisseurs f  on f.id = fa.fournisseur_id
where m.type = 'entree' and m.prix_unitaire is not null;

-- Ce qu'il faut savoir d'un coup d'œil : le dernier prix payé, sa variation, et
-- l'écart avec le prix de référence. Un prix qui a augmenté depuis la dernière
-- commande est une information d'achat, pas un détail comptable.
create view v_prix_produit as
select
  p.id                                  as produit_id,
  p.prix_unitaire                       as prix_reference,
  d.prix_unitaire                       as dernier_prix,
  d.date_mouvement                      as dernier_achat,
  d.fournisseur                         as dernier_fournisseur,
  d.prix_precedent,
  case when d.prix_precedent is not null and d.prix_precedent > 0
       then round((d.prix_unitaire - d.prix_precedent) / d.prix_precedent * 100, 1)
  end                                   as variation_pct,
  case when p.prix_unitaire is not null and p.prix_unitaire > 0 and d.prix_unitaire is not null
       then round((d.prix_unitaire - p.prix_unitaire) / p.prix_unitaire * 100, 1)
  end                                   as ecart_reference_pct,
  s.nb_achats,
  s.prix_min,
  s.prix_max,
  s.prix_moyen
from produits p
left join lateral (
  select * from v_achats_produit a
  where a.produit_id = p.id
  order by a.date_mouvement desc, a.mouvement_id desc limit 1
) d on true
left join lateral (
  select count(*)::int as nb_achats, min(prix_unitaire) as prix_min,
         max(prix_unitaire) as prix_max, round(avg(prix_unitaire), 2) as prix_moyen
  from v_achats_produit a where a.produit_id = p.id
) s on true;

-- -----------------------------------------------------------------------------
create view v_stock_produits as
select
  p.id,
  p.code,
  p.designation,
  p.categorie,
  p.categorie_lieu,
  p.unite,
  p.prix_unitaire,
  p.prix_unitaire is null                              as prix_inconnu,
  p.seuil_alerte,
  p.quantite_reappro,
  ph.chemin                                            as photo_principale,
  (select count(*) from photos_produit x where x.produit_id = p.id) as nb_photos,
  p.actif,
  coalesce(sum(m.quantite) filter (where m.type = 'entree'), 0)          as total_entrees,
  coalesce(-sum(m.quantite) filter (where m.type = 'sortie'), 0)         as total_sorties,
  coalesce(sum(m.quantite) filter (where m.type = 'regularisation'), 0)  as total_ajustements,
  coalesce(sum(m.quantite), 0)                         as stock,
  coalesce(sum(m.quantite), 0) * p.prix_unitaire       as valeur_stock,
  coalesce(sum(m.quantite), 0) <= p.seuil_alerte       as sous_seuil,
  max(m.date_mouvement)                                as dernier_mouvement,
  pr.dernier_prix,
  pr.variation_pct,
  -- Le fournisseur préféré, et son adresse : c'est à lui que part la demande.
  fo.fournisseur,
  fo.email_fournisseur,
  fo.nb_fournisseurs
from produits p
left join mouvements_stock m on m.produit_id = p.id
left join v_prix_produit pr  on pr.produit_id = p.id
left join lateral (
  select chemin from photos_produit x
  where x.produit_id = p.id order by x.principale desc, x.ordre limit 1
) ph on true
left join lateral (
  select f.nom as fournisseur, f.email as email_fournisseur,
         (select count(*)::int from article_fournisseurs y where y.produit_id = p.id)
           as nb_fournisseurs
  from article_fournisseurs af
  join fournisseurs f on f.id = af.fournisseur_id
  where af.produit_id = p.id
  order by af.prefere desc, f.nom limit 1
) fo on true
group by p.id, ph.chemin, pr.dernier_prix, pr.variation_pct,
         fo.fournisseur, fo.email_fournisseur, fo.nb_fournisseurs;

-- -----------------------------------------------------------------------------
-- Coût d'une intervention
--   matériel   : calculé depuis les sorties de stock rattachées
--   prestataire: issu du rapprochement de facture, réparti à parts égales entre
--                les interventions de la facture si aucun montant n'est affecté
--   divers     : seul montant saisi, par la gouvernante ou l'admin
-- Le technicien ne saisit ni ne voit aucun prix.
-- -----------------------------------------------------------------------------
create view v_cout_prestataire as
select
  fi.intervention_id,
  sum(coalesce(fi.montant_affecte, f.montant_ht / n.nb)) as cout_prestataire
from facture_interventions fi
join factures f on f.id = fi.facture_id
cross join lateral (
  select greatest(count(*), 1) as nb
  from facture_interventions x where x.facture_id = fi.facture_id
) n
group by fi.intervention_id;

create view v_interventions_cout as
select
  i.id                                     as intervention_id,
  i.anomalie_id,
  coalesce(mat.cout_materiel, 0)           as cout_materiel,
  coalesce(mat.articles_sans_prix, 0)      as articles_sans_prix,
  coalesce(cp.cout_prestataire, 0)         as cout_prestataire,
  i.cout_divers,
  coalesce(mat.cout_materiel, 0) + coalesce(cp.cout_prestataire, 0) + i.cout_divers as cout_total,
  -- Vrai quand du matériel sans prix connu a été utilisé : le total affiché est
  -- alors un minimum, ce que l'interface doit dire explicitement.
  coalesce(mat.articles_sans_prix, 0) > 0  as cout_incomplet
from interventions i
left join lateral (
  -- Les sorties sont négatives : on reprend la valeur absolue pour obtenir un coût
  select
    sum(abs(m.quantite) * p.prix_unitaire) filter (where p.prix_unitaire is not null) as cout_materiel,
    count(*) filter (where p.prix_unitaire is null)                                   as articles_sans_prix
  from mouvements_stock m
  join produits p on p.id = m.produit_id
  where m.intervention_id = i.id and m.type = 'sortie'
) mat on true
left join v_cout_prestataire cp on cp.intervention_id = i.id;

-- -----------------------------------------------------------------------------
-- Récapitulatif d'intervention : les deux avis côte à côte
-- -----------------------------------------------------------------------------
create view v_recap_interventions as
select
  i.id                        as intervention_id,
  t.reference                 as tournee,
  a.id                        as anomalie_id,
  a.reference                 as anomalie_reference,
  e.code                      as emplacement,
  et.nom                      as etage,
  ti.nom                      as type_intervention,
  a.description,
  a.statut                    as statut_anomalie,
  uc.nom                      as constate_par,
  us.nom                      as saisie_par,
  i.date_intervention,
  coalesce(ut.nom, pr.nom)    as intervenant,
  pr.nom                      as prestataire,
  vt.decision                 as decision_technicien,
  vt.decide_le                as declare_fait_le,
  vt.commentaire              as commentaire_technicien,
  ug.nom                      as gouvernante,
  vg.decision                 as decision_gouvernante,
  vg.decide_le                as decide_gouvernante_le,
  vg.commentaire              as commentaire_gouvernante,
  -- Ce drapeau est ce qui doit apparaître en clair dans le récapitulatif envoyé :
  -- le technicien a déclaré l'anomalie faite, la gouvernante ne l'a pas validée.
  (vt.decision = 'fait' and vg.decision is distinct from 'validee'
     and vg.decision is not null)         as non_validee_par_gouvernante,
  (vt.decision = 'fait' and vg.decision is null) as en_attente_gouvernante,
  c.cout_materiel,
  c.articles_sans_prix,
  c.cout_prestataire,
  c.cout_divers,
  c.cout_total,
  c.cout_incomplet,
  i.cree_le
from interventions i
join anomalies a           on a.id = i.anomalie_id
join emplacements e        on e.id = a.emplacement_id
join etages et             on et.id = e.etage_id
left join tournees t       on t.id = i.tournee_id
left join types_intervention ti on ti.id = a.type_id
left join utilisateurs uc  on uc.id = a.constate_par
left join utilisateurs us  on us.id = a.saisie_par
left join utilisateurs ut  on ut.id = i.technicien_id
left join prestataires pr  on pr.id = i.prestataire_id
left join v_interventions_cout c on c.intervention_id = i.id
left join lateral (
  select * from validations v
  where v.intervention_id = i.id and v.acteur = 'technicien'
  order by v.decide_le desc limit 1
) vt on true
left join lateral (
  select * from validations v
  where v.intervention_id = i.id and v.acteur = 'gouvernante'
  order by v.decide_le desc limit 1
) vg on true
left join utilisateurs ug on ug.id = vg.utilisateur_id;

-- -----------------------------------------------------------------------------
-- État d'une tournée. `prete_pour_recap` remplace la logique « plus aucune ligne
-- EnAttente pour cet InterventionID » : le mail récap part quand elle devient
-- vraie et que mail_recap_envoye_le est encore nul.
-- -----------------------------------------------------------------------------
create view v_tournees as
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
  count(*) filter (where r.intervention_id is not null
                     and r.decision_gouvernante is null)                    as nb_en_attente,
  count(*) filter (where r.decision_gouvernante = 'validee')                as nb_validees,
  count(*) filter (where r.decision_gouvernante = 'a_refaire')              as nb_a_refaire,
  count(*) filter (where r.decision_gouvernante = 'en_cours')               as nb_en_cours,
  coalesce(sum(r.cout_total), 0)                                            as cout_total,
  bool_or(r.cout_incomplet)                                                 as cout_incomplet,
  count(r.intervention_id) > 0
    and count(*) filter (where r.intervention_id is not null
                           and r.decision_gouvernante is null) = 0          as prete_pour_recap
from tournees t
left join utilisateurs u  on u.id = t.technicien_id
left join prestataires p  on p.id = t.prestataire_id
left join v_recap_interventions r on r.tournee = t.reference
group by t.id, u.nom, p.nom;

-- Fil chronologique des commentaires d'une anomalie. Remplace l'empilement de
-- texte « NOM · date \n contenu » : chaque commentaire garde son auteur, sa date
-- et son rôle, donc rien ne peut être écrasé ni mal découpé à la relecture.
-- Journées candidates au rapprochement d'une facture de prestation.
--
-- Le numéro de tournée ne sert PAS ici. Dans l'application d'origine,
-- l'InterventionID changeait à chaque anomalie validée : un même passage
-- produisait plusieurs identifiants qu'il fallait recoller à la main, et il en
-- reste des coquilles dans les données reprises. Ce qui identifie réellement un
-- passage, c'est le couple **qui est venu / quel jour** — les colonnes `PAR` et
-- `FAIT LE`. On regroupe donc par journée d'intervenant.
--
-- Une facture arrive une à deux semaines après et peut couvrir plusieurs
-- journées : quand elle porte une période, c'est elle qui fait foi ; sinon on
-- remonte `p_jours` en arrière depuis sa date, puisque la facture suit toujours
-- l'intervention. Une journée dont une intervention est déjà prise par une
-- AUTRE facture n'est jamais proposée.
create function fn_journees_rapprochables(
  p_facture_id uuid,
  p_jours int default 30
) returns table (
  date_intervention  date,
  intervenant        text,
  nb_anomalies       int,
  emplacements       text,
  apercu             text,
  cout_materiel      numeric,
  ecart_jours        int,
  interventions      uuid[],
  deja_rapprochee    boolean
)
language sql stable as $$
  select
    i.date_intervention,
    coalesce(pr.nom, ut.nom)                              as intervenant,
    count(*)::int                                         as nb_anomalies,
    string_agg(distinct e.code, ', ' order by e.code)     as emplacements,
    -- Chaque anomalie reste collée à son lieu. Séparer les deux listes laissait
    -- croire qu'il y avait un lave-vaisselle dans la chambre 57.
    string_agg(e.code || ' — ' || a.description, E'\n' order by e.code, a.reference)
                                                          as apercu,
    coalesce(sum(c.cout_materiel), 0)                     as cout_materiel,
    (f.date_reference - i.date_intervention)::int         as ecart_jours,
    array_agg(i.id order by a.reference)                  as interventions,
    bool_or(fi.facture_id is not null)                    as deja_rapprochee
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
    -- pas déjà pris par une autre facture
    and not exists (
      select 1 from facture_interventions x
      where x.intervention_id = i.id and x.facture_id <> f.id)
  group by i.date_intervention, coalesce(pr.nom, ut.nom), f.date_reference
  order by i.date_intervention desc;
$$;

-- Le détail d'une journée, quand on veut voir ce qu'elle contient avant de la
-- rattacher — ou en retirer une ligne qui n'appartient pas à cette facture.
create function fn_anomalies_de_la_journee(
  p_prestataire_id uuid,
  p_date date
) returns table (
  intervention_id    uuid,
  anomalie_reference bigint,
  emplacement        text,
  description        text,
  cout_materiel      numeric,
  facture_id         uuid
)
language sql stable as $$
  select i.id, a.reference, e.code, a.description,
         coalesce(c.cout_materiel, 0), fi.facture_id
  from interventions i
  join anomalies a    on a.id = i.anomalie_id
  join emplacements e on e.id = a.emplacement_id
  left join v_interventions_cout c   on c.intervention_id = i.id
  left join facture_interventions fi on fi.intervention_id = i.id
  where i.prestataire_id = p_prestataire_id
    and i.date_intervention = p_date
  order by a.reference;
$$;

-- Le filet de sécurité : ce qu'un prestataire a fait et qu'aucune facture ne
-- couvre encore. Une intervention qui vieillit ici est une facture qu'on
-- attend, ou qu'on a oublié de rapprocher.
create view v_interventions_sans_facture as
select
  pr.id                                as prestataire_id,
  pr.nom                               as prestataire,
  i.id                                 as intervention_id,
  a.reference                          as anomalie_reference,
  e.code                               as emplacement,
  a.description,
  i.date_intervention,
  (current_date - i.date_intervention)::int as jours_ecoules
from interventions i
join prestataires pr on pr.id = i.prestataire_id
join anomalies a     on a.id = i.anomalie_id
join emplacements e  on e.id = a.emplacement_id
where not exists (
  select 1 from facture_interventions fi where fi.intervention_id = i.id);

-- Liste des intervenants pour le filtre à avatars de l'écran technicien.
-- `specialites` vide = polyvalent : on lui propose toutes les anomalies.
-- Sinon sa section ne montre que les types listés.
create view v_intervenants as
select
  u.id                  as utilisateur_id,
  null::uuid            as prestataire_id,
  u.nom,
  'interne'::text       as origine,
  u.actif,
  coalesce(array_remove(array_agg(t.code), null), '{}')::text[] as specialites
from utilisateurs u
left join specialites_intervenant s on s.utilisateur_id = u.id
left join types_intervention t      on t.id = s.type_intervention_id
-- Qui intervient ne se déduit pas d'un rôle : la chargée des opérations
-- n'intervient pas, et le réceptionniste qui donne un coup de main, si. La
-- liste est donnée par l'hôtel et posée par `outils/equipe.py`.
where u.intervient_technique
group by u.id
union all
select
  null::uuid,
  p.id,
  p.nom,
  'externe'::text,
  p.actif,
  coalesce(array_remove(array_agg(t.code), null), '{}')::text[]
from prestataires p
left join specialites_intervenant s on s.prestataire_id = p.id
left join types_intervention t      on t.id = s.type_intervention_id
group by p.id;

-- Anomalies qu'un intervenant donné doit voir dans sa section : toutes s'il est
-- polyvalent, sinon celles de ses seuls types.
create function fn_anomalies_pour_intervenant(p_nom text)
returns setof anomalies
language sql stable as $$
  select a.*
  from anomalies a
  left join types_intervention t on t.id = a.type_id
  cross join lateral (
    select specialites from v_intervenants where nom = p_nom limit 1
  ) i
  where a.statut in ('a_faire', 'en_cours')
    and (cardinality(i.specialites) = 0 or t.code = any (i.specialites))
  order by a.emplacement_id, a.declare_le;
$$;

-- Ce que le digest du soir doit envoyer. Rien ne part à la validation : les
-- lignes s'accumulent ici et un seul envoi les reprend à l'heure dite, pour
-- éviter un mail par anomalie validée.
create view v_envois_en_attente as
select
  'recap_technicien'::text as categorie,
  t.id                     as tournee_id,
  t.reference,
  t.date_tournee,
  coalesce(u.nom, p.nom)   as intervenant,
  v.nb_interventions,
  v.nb_validees,
  v.nb_a_refaire,
  v.cout_total,
  t.cloturee_le            as pret_depuis
from tournees t
join v_tournees v         on v.id = t.id
left join utilisateurs u  on u.id = t.technicien_id
left join prestataires p  on p.id = t.prestataire_id
where not t.reprise
  and t.cloturee_le is not null and t.mail_technicien_envoye_le is null
union all
select
  'recap_intervention',
  t.id,
  t.reference,
  t.date_tournee,
  coalesce(u.nom, p.nom),
  v.nb_interventions,
  v.nb_validees,
  v.nb_a_refaire,
  v.cout_total,
  t.cloturee_le
from tournees t
join v_tournees v         on v.id = t.id
left join utilisateurs u  on u.id = t.technicien_id
left join prestataires p  on p.id = t.prestataire_id
where not t.reprise
  and v.prete_pour_recap and t.mail_recap_envoye_le is null;

-- Le fil d'une anomalie : les commentaires libres et ceux attachés à une
-- décision, dans l'ordre. Rien n'écrase rien — celui du technicien reste
-- lisible sous celui de la gouvernante, et inversement.
create view v_fil_commentaires as
select
  c.anomalie_id,
  c.id                as commentaire_id,
  case when c.origine = 'reprise' then 'reprise' else 'commentaire' end as source,
  c.ecrit_le          as date_commentaire,
  u.nom               as auteur,
  c.texte,
  null::decision_validation as decision
from commentaires c
left join utilisateurs u on u.id = c.auteur_id
union all
select
  i.anomalie_id,
  v.id,
  v.acteur::text,
  v.decide_le,
  coalesce(u.nom, p.nom),
  v.commentaire,
  v.decision
from validations v
join interventions i      on i.id = v.intervention_id
left join utilisateurs u  on u.id = v.utilisateur_id
left join prestataires p  on p.id = i.prestataire_id
where coalesce(btrim(v.commentaire), '') <> '';

-- Ce qui a déjà été déclaré dans un lieu. La gouvernante la consulte AVANT de
-- saisir : sans ça, la même fuite est déclarée trois fois en une semaine.
-- Les anomalies ouvertes remontent d'abord, l'historique récent ensuite —
-- une anomalie close il y a peu qui réapparaît n'est pas un doublon, c'est une
-- réparation qui n'a pas tenu, et cela se voit ici.
create view v_anomalies_du_lieu as
select
  a.emplacement_id,
  e.code                       as emplacement,
  a.id                         as anomalie_id,
  a.reference,
  a.catalogue_id,
  a.description,
  a.statut,
  a.statut in ('a_faire', 'en_cours', 'attente_validation', 'a_acheter') as ouverte,
  a.declare_le,
  a.cloture_le,
  (current_date - a.declare_le::date)::int as jours_depuis,
  uc.nom                       as constate_par,
  ti.nom                       as type_intervention,
  (select count(*) from photos_anomalie ph where ph.anomalie_id = a.id)::int as nb_photos,
  (select count(*) from v_fil_commentaires f where f.anomalie_id = a.id)::int as nb_commentaires
from anomalies a
join emplacements e             on e.id = a.emplacement_id
left join utilisateurs uc       on uc.id = a.constate_par
left join types_intervention ti on ti.id = a.type_id;

-- Combien de fois un même problème est revenu à un même endroit. C'est ce que
-- le catalogue fermé rend possible : sans libellés normalisés, ce comptage
-- n'aurait aucun sens. Les doublons annulés n'y figurent pas — ils n'ont pas eu
-- lieu deux fois, ils ont été saisis deux fois.
create view v_frequence_anomalie_lieu as
select
  a.emplacement_id,
  e.code               as emplacement,
  a.catalogue_id,
  c.libelle,
  count(*)::int                                    as nb_fois,
  max(a.declare_le)::date                          as derniere_fois,
  min(a.declare_le)::date                          as premiere_fois,
  count(*) filter (
    where a.statut in ('a_faire','en_cours','attente_validation','a_acheter')
  )::int                                           as ouvertes
from anomalies a
join emplacements e        on e.id = a.emplacement_id
join catalogue_anomalies c on c.id = a.catalogue_id
where a.statut <> 'annulee'
group by a.emplacement_id, e.code, a.catalogue_id, c.libelle;

-- Chambres qui reviennent trop souvent. Le drapeau reprend le seuil de la
-- maquette : 3 interventions ou plus sur les six derniers mois.
create view v_recurrences_emplacement as
select
  e.id                as emplacement_id,
  e.code              as emplacement,
  et.nom              as etage,
  count(a.id) filter (where a.declare_le > now() - interval '6 months') as nb_6_mois,
  count(a.id)                                                          as nb_total,
  max(a.declare_le)                                                    as derniere_anomalie,
  count(a.id) filter (where a.declare_le > now() - interval '6 months') >= 3 as recurrent
from emplacements e
join etages et on et.id = e.etage_id
left join anomalies a on a.emplacement_id = e.id
group by e.id, et.nom;

-- -----------------------------------------------------------------------------
-- Bouteilles : positions réelles
-- Chaque mouvement est éclaté en deux demi-lignes (+ à l'arrivée, − au départ).
-- Les demi-lignes « hors parc » sont ignorées : ce qui reste est le parc vivant.
-- -----------------------------------------------------------------------------
create view v_bouteilles_positions as
select
  m.bouteille_type_id,
  f.lieu,
  f.emplacement_id,
  f.qte
from mouvements_bouteilles m
cross join lateral (values
  (m.vers_lieu, m.vers_emplacement_id,  m.quantite),
  (m.de_lieu,   m.de_emplacement_id,   -m.quantite)
) as f (lieu, emplacement_id, qte)
where f.lieu <> 'hors_parc';

create view v_stock_bouteilles as
select
  bt.id                as bouteille_type_id,
  bt.code,
  bt.libelle,
  bt.couleur,
  bt.photo,
  bt.prix_vente,
  bt.prix_achat,
  bt.seuil_alerte,
  -- Le chiffre opérationnel : ce qu'il reste pour re-doter une chambre.
  coalesce(sum(p.qte) filter (where p.lieu = 'reserve'), 0)      as en_reserve,
  coalesce(sum(p.qte) filter (where p.lieu = 'emplacement'), 0)  as en_chambre,
  -- Emportée par un client : elle n'est plus à nous tant qu'elle n'est pas
  -- rendue. Elle ne compte donc PAS dans le parc détenu.
  coalesce(sum(p.qte) filter (where p.lieu = 'chez_client'), 0)  as chez_clients,
  -- Ce que l'hôtel a réellement, réserve et chambres réunies. C'est ce chiffre
  -- qui baisse dès qu'un client emporte une bouteille.
  coalesce(sum(p.qte) filter (where p.lieu in ('reserve', 'emplacement')), 0) as parc_detenu,
  -- Détenu + en attente de retour : sert au rapprochement d'inventaire, pas au
  -- pilotage quotidien.
  coalesce(sum(p.qte), 0)                                        as parc_theorique,
  coalesce(d.dotation_theorique, 0)                              as dotation_theorique,
  coalesce(sum(p.qte) filter (where p.lieu = 'reserve'), 0) <= bt.seuil_alerte as sous_seuil
from bouteille_types bt
left join v_bouteilles_positions p on p.bouteille_type_id = bt.id
left join lateral (
  select sum(quantite) as dotation_theorique
  from dotations d2 where d2.bouteille_type_id = bt.id
) d on true
group by bt.id, d.dotation_theorique;

create view v_bouteilles_par_emplacement as
select
  e.id            as emplacement_id,
  e.code          as emplacement,
  bt.id           as bouteille_type_id,
  bt.code         as bouteille,
  coalesce(d.quantite, 0)                     as quantite_theorique,
  coalesce(sum(p.qte), 0)                     as quantite_reelle
from emplacements e
cross join bouteille_types bt
left join dotations d on d.emplacement_id = e.id and d.bouteille_type_id = bt.id
left join v_bouteilles_positions p
       on p.emplacement_id = e.id and p.bouteille_type_id = bt.id and p.lieu = 'emplacement'
where e.dote_bouteilles
group by e.id, bt.id, d.quantite;

-- Dossiers en cours et clos, avec le montant retenu ou, à défaut, le montant
-- théorique selon qui est responsable. Les lignes sont agrégées : un dossier qui
-- porte la filtrée ET la gazeuse reste UN dossier, un montant, un mail.
create view v_incidents_bouteille as
select
  i.id,
  i.reference,
  i.emplacement_id,
  e.code                                   as emplacement,
  l.libelles                               as bouteille,
  coalesce(l.quantite, 0)                  as quantite,
  coalesce(l.detail, '[]'::jsonb)          as lignes,
  i.nature,
  i.responsable,
  i.client_nom,
  uc.nom                                   as constate_par,
  ut.nom                                   as transmis_a,
  i.constate_le,
  i.statut,
  i.notifie_le,
  i.transmis_le,
  i.client_contacte_le,
  i.resolu_le,
  -- Les quatre étapes du dossier, pour la frise de l'écran de suivi.
  i.constate_le is not null                as etape_constate,
  i.transmis_le is not null                as etape_transmis,
  i.client_contacte_le is not null         as etape_client_contacte,
  i.statut in ('restitue', 'facture', 'non_facture', 'clos') as etape_resolue,
  -- Le montant retenu s'il a été saisi ; sinon le prix du barème, ligne à ligne.
  coalesce(i.montant, l.montant_theorique, 0) as montant,
  i.responsable = 'client'                 as facturable_client,
  i.statut in ('signale', 'transmis', 'client_contacte') as dossier_ouvert,
  i.commentaire
from incidents_bouteille i
join emplacements e     on e.id = i.emplacement_id
left join utilisateurs uc on uc.id = i.constate_par
left join utilisateurs ut on ut.id = i.transmis_a
left join lateral (
  select
    string_agg(bt.libelle, ' + ' order by bt.libelle)                as libelles,
    sum(li.quantite)::int                                            as quantite,
    sum(li.quantite * case when i.responsable = 'client'
                           then bt.prix_vente else bt.prix_achat end) as montant_theorique,
    jsonb_agg(jsonb_build_object(
      'code', bt.code, 'libelle', bt.libelle, 'quantite', li.quantite,
      'prix', case when i.responsable = 'client' then bt.prix_vente else bt.prix_achat end)
      order by bt.libelle)                                           as detail
  from incident_lignes_bouteille li
  join bouteille_types bt on bt.id = li.bouteille_type_id
  where li.incident_id = i.id
) l on true;

-- -----------------------------------------------------------------------------
-- Réapprovisionnement : articles sous seuil, regroupés par fournisseur.
-- Un seul devis, donc un seul mail, même si trois articles tombent le même jour.
-- -----------------------------------------------------------------------------
-- Une ligne par couple article / fournisseur : un produit qui a trois
-- fournisseurs apparaît trois fois, et part donc en consultation chez les trois.
-- Un article sans aucun fournisseur apparaît quand même, avec `fournisseur_id`
-- nul : il doit rester visible dans l'écran d'alerte.
create view v_reappro_necessaire as
select
  af.fournisseur_id,
  f.nom                                as fournisseur,
  f.email                              as email_fournisseur,
  'produit'::text                      as nature,
  p.id                                 as article_id,
  p.designation                        as libelle,
  af.reference_fournisseur,
  s.stock::numeric                     as stock_actuel,
  p.seuil_alerte::numeric              as seuil,
  coalesce(p.quantite_reappro, greatest(p.seuil_alerte * 2 - s.stock, 1))::numeric as quantite_suggeree
from v_stock_produits s
join produits p on p.id = s.id
left join article_fournisseurs af on af.produit_id = p.id
left join fournisseurs f          on f.id = af.fournisseur_id
where p.actif and s.stock <= p.seuil_alerte
union all
select
  af.fournisseur_id,
  f.nom,
  f.email,
  'bouteille'::text,
  bt.id,
  bt.libelle,
  af.reference_fournisseur,
  b.en_reserve::numeric,
  bt.seuil_alerte::numeric,
  coalesce(bt.quantite_reappro, greatest(bt.seuil_alerte * 2 - b.en_reserve, 1))::numeric
from v_stock_bouteilles b
join bouteille_types bt on bt.id = b.bouteille_type_id
left join article_fournisseurs af on af.bouteille_type_id = bt.id
left join fournisseurs f          on f.id = af.fournisseur_id
where b.en_reserve <= bt.seuil_alerte;

-- -----------------------------------------------------------------------------
-- Commandes fournisseur
-- -----------------------------------------------------------------------------
create view v_commandes as
select
  c.id,
  c.reference,
  f.nom                                   as fournisseur,
  c.fournisseur_id,
  c.date_commande,
  c.date_livraison,
  c.recue_le,
  c.statut,
  c.montant_ht,
  c.montant_ttc,
  -- Ce que la TVA représente, quand les deux montants sont là. Rien n'est
  -- stocké : c'est une soustraction, elle se refait à chaque lecture.
  case when c.montant_ht is not null and c.montant_ttc is not null
       then c.montant_ttc - c.montant_ht end as montant_tva,
  c.facture_id,
  fa.fichier_url                          as facture_fichier,
  fa.reference                            as facture_reference,
  coalesce(l.nb_lignes, 0)                as nb_lignes,
  coalesce(l.nb_articles, 0)              as nb_articles,
  l.articles,
  -- Le total des lignes, quand les prix unitaires sont renseignés. Il sert à
  -- signaler un écart avec le montant saisi, jamais à le remplacer.
  l.total_lignes_ht,
  c.commentaire,
  u.nom                                   as saisie_par
from commandes c
join fournisseurs f      on f.id = c.fournisseur_id
left join factures fa    on fa.id = c.facture_id
left join utilisateurs u on u.id = c.saisie_par
left join lateral (
  select
    count(*)::int                                   as nb_lignes,
    sum(cl.quantite)::int                           as nb_articles,
    string_agg(
      coalesce(p.designation, bt.libelle) || ' × ' || cl.quantite,
      ', ' order by coalesce(p.designation, bt.libelle))  as articles,
    sum(cl.quantite * cl.prix_unitaire_ht)          as total_lignes_ht
  from commande_lignes cl
  left join produits p         on p.id = cl.produit_id
  left join bouteille_types bt on bt.id = cl.bouteille_type_id
  where cl.commande_id = c.id
) l on true;

-- -----------------------------------------------------------------------------
-- Dossiers bouteille : la même chose que `v_incidents_bouteille`, mais rangée
-- pour l'écran de suivi — un statut lisible, un axe de tri, et de quoi filtrer.
-- -----------------------------------------------------------------------------
create view v_dossiers_bouteille as
select
  i.*,
  -- Trois familles suffisent aux filtres : à traiter, réglé, abandonné.
  case
    when i.statut in ('signale', 'transmis', 'client_contacte') then 'ouvert'
    when i.statut in ('restitue', 'facture')                    then 'resolu'
    else 'perdu'
  end                                              as famille,
  (current_date - i.constate_le::date)::int        as jours_ouvert,
  -- Un dossier client ouvert depuis plus d'une semaine : le client est parti,
  -- la bouteille ne reviendra pas toute seule.
  i.statut in ('signale', 'transmis', 'client_contacte')
    and (current_date - i.constate_le::date) >= 7  as urgent,
  -- De quoi chercher sans se soucier de la casse ni des accents.
  lower(coalesce(i.client_nom, '') || ' ' || i.emplacement || ' ' ||
        coalesce(i.bouteille, '') || ' ' || coalesce(i.commentaire, '') || ' ' ||
        i.reference::text)                         as recherche
from v_incidents_bouteille i;

-- Ce que les bouteilles ont coûté, mois par mois : la matière du tableau de
-- bord. Un dossier compte dans le mois où il a été constaté.
create view v_bouteilles_par_mois as
select
  date_trunc('month', i.constate_le)::date          as mois,
  count(*)::int                                     as nb_dossiers,
  count(*) filter (where i.nature = 'emport')::int  as nb_emports,
  count(*) filter (where i.nature = 'casse')::int   as nb_casses,
  count(*) filter (where i.statut = 'restitue')::int    as nb_restituees,
  count(*) filter (where i.statut = 'facture')::int     as nb_facturees,
  count(*) filter (where i.statut = 'non_facture')::int as nb_perdues,
  sum(i.quantite)::int                              as nb_bouteilles,
  sum(i.montant)                                    as montant_en_jeu,
  sum(i.montant) filter (where i.statut = 'facture')     as montant_facture,
  sum(i.montant) filter (where i.statut = 'non_facture') as perte_seche
from v_incidents_bouteille i
group by 1;

-- Les emplacements qui perdent le plus de bouteilles. « Top chambres à risque »
-- du tableau de bord : c'est une information d'exploitation, pas un palmarès.
create view v_bouteilles_par_emplacement_couts as
select
  i.emplacement,
  count(*)::int          as nb_dossiers,
  sum(i.quantite)::int   as nb_bouteilles,
  sum(i.montant)         as montant,
  max(i.constate_le)     as dernier_dossier
from v_incidents_bouteille i
group by i.emplacement;

-- Ce qui est rédigé et attend de partir. Le service d'envoi lit cette vue,
-- envoie, puis horodate `envoye_le`.
create view v_courriels_en_attente as
select id, categorie, reference_id, destinataires, sujet, corps, cree_le
from emails_envoyes
where envoye_le is null
order by cree_le;

-- =============================================================================
-- Règles métier
-- =============================================================================

-- 1. Ouvrir une tournée. La référence reprend le format actuel (INT-<TECH>-...)
--    avec un suffixe aléatoire : deux tournées ouvertes dans la même seconde ne
--    peuvent pas entrer en collision.
create function fn_creer_tournee(
  p_technicien_id uuid default null,
  p_prestataire_id uuid default null
) returns tournees
language plpgsql as $$
declare
  v_nom text;
  v_tournee tournees;
begin
  select upper(regexp_replace(coalesce(u.nom, pr.nom, 'INT'), '[^A-Za-z0-9]', '', 'g'))
    into v_nom
  from (select 1) x
  left join utilisateurs u   on u.id = p_technicien_id
  left join prestataires pr  on pr.id = p_prestataire_id;

  insert into tournees (reference, technicien_id, prestataire_id)
  values (
    'INT-' || left(v_nom, 10) || '-' || to_char(now(), 'YYYYMMDD-HH24MISS')
           || '-' || substr(md5(random()::text), 1, 4),
    p_technicien_id, p_prestataire_id)
  returning * into v_tournee;

  return v_tournee;
end;
$$;

-- 2. Une LIGNE de dossier enregistre les mouvements physiques de son type.
--    Emport : la bouteille part « chez le client », d'où elle peut revenir.
--    Casse  : la bouteille sort définitivement du parc.
--    Dans les deux cas la chambre est re-dotée depuis la réserve, ce qui déplace
--    une bouteille sans en retirer une seconde du parc.
--    Le déclencheur est sur la ligne, pas sur le dossier : c'est la ligne qui
--    dit quel type et combien, et elle arrive toujours après l'en-tête.
create function fn_incident_bouteille_mouvements() returns trigger
language plpgsql as $$
declare
  d incidents_bouteille%rowtype;
begin
  select * into d from incidents_bouteille where id = new.incident_id;

  insert into mouvements_bouteilles (
    type, bouteille_type_id, quantite, de_lieu, de_emplacement_id, vers_lieu,
    date_mouvement, utilisateur_id, incident_id, commentaire)
  values (
    case when d.nature = 'emport' then 'emport' else 'casse' end::type_mouvement_bouteille,
    new.bouteille_type_id, new.quantite, 'emplacement', d.emplacement_id,
    case when d.nature = 'emport' then 'chez_client' else 'hors_parc' end::lieu_bouteille,
    d.constate_le, d.constate_par, d.id,
    case when d.nature = 'emport' then 'Bouteille emportée — dossier n° '
         else 'Bouteille cassée — dossier n° ' end || d.reference);

  if d.redoter then
    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, vers_lieu, vers_emplacement_id,
      date_mouvement, utilisateur_id, incident_id, commentaire)
    values (
      'dotation', new.bouteille_type_id, new.quantite, 'reserve', 'emplacement', d.emplacement_id,
      d.constate_le, d.constate_par, d.id,
      'Re-dotation de la chambre — dossier n° ' || d.reference);
  end if;

  return new;
end;
$$;

create trigger tg_incident_bouteille_mouvements
after insert on incident_lignes_bouteille
for each row execute function fn_incident_bouteille_mouvements();

-- 3. La résolution d'un emport décide du sort des bouteilles en attente.
--    Restituées => elles rejoignent la RÉSERVE (la chambre a déjà été re-dotée).
--    Facturées  => sortie définitive du parc.
--    Le garde-fou empêche de compter deux fois un dossier déjà tranché.
create function fn_incident_bouteille_resolution() returns trigger
language plpgsql as $$
begin
  if new.statut = old.statut or new.nature <> 'emport' then
    return new;
  end if;

  if exists (
    select 1 from mouvements_bouteilles
    where incident_id = new.id and type in ('retour', 'perte')
  ) then
    return new;
  end if;

  if new.statut = 'restitue' then
    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, vers_lieu,
      date_mouvement, utilisateur_id, incident_id, commentaire)
    select 'retour', l.bouteille_type_id, l.quantite, 'chez_client', 'reserve',
           coalesce(new.resolu_le, now()), new.resolu_par, new.id,
           'Bouteille restituée, remise en réserve — dossier n° ' || new.reference
    from incident_lignes_bouteille l where l.incident_id = new.id;

  elsif new.statut in ('facture', 'non_facture') then
    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, vers_lieu,
      date_mouvement, utilisateur_id, incident_id, commentaire)
    select 'perte', l.bouteille_type_id, l.quantite, 'chez_client', 'hors_parc',
           coalesce(new.resolu_le, now()), new.resolu_par, new.id,
           'Bouteille non restituée — dossier n° ' || new.reference
    from incident_lignes_bouteille l where l.incident_id = new.id;
  end if;

  return new;
end;
$$;

create trigger tg_incident_bouteille_resolution
after update on incidents_bouteille
for each row execute function fn_incident_bouteille_resolution();

-- 4. Re-doter une chambre depuis la réserve, hors incident (après inventaire).
create function fn_redoter_emplacement(
  p_emplacement_id uuid,
  p_bouteille_type_id uuid,
  p_quantite int,
  p_utilisateur_id uuid default null
) returns uuid
language plpgsql as $$
declare
  v_id uuid;
begin
  insert into mouvements_bouteilles (
    type, bouteille_type_id, quantite,
    de_lieu, vers_lieu, vers_emplacement_id, utilisateur_id, commentaire)
  values (
    'dotation', p_bouteille_type_id, p_quantite,
    'reserve', 'emplacement', p_emplacement_id, p_utilisateur_id,
    'Re-dotation de la chambre')
  returning id into v_id;
  return v_id;
end;
$$;

-- 5. Le statut de l'anomalie suit la dernière validation enregistrée.
--    La gouvernante dispose de ses trois issues : FAIT, EN COURS, A FAIRE.
--    Le matériel déjà sorti reste consommé : il n'est jamais annulé par un refus.
create function fn_validation_maj_anomalie() returns trigger
language plpgsql as $$
declare
  v_anomalie_id uuid;
begin
  select anomalie_id into v_anomalie_id from interventions where id = new.intervention_id;

  update anomalies set
    statut = case
      when new.acteur = 'technicien'  and new.decision = 'fait'      then 'attente_validation'::statut_anomalie
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

create trigger tg_validation_maj_anomalie
after insert on validations
for each row execute function fn_validation_maj_anomalie();

-- 6. Réceptionner une commande écrit les entrées de stock, et rien d'autre.
--    C'est le seul moment où une commande touche au stock : tant qu'elle est
--    en brouillon ou envoyée, elle n'a rien ajouté. Ce qui est compté, c'est ce
--    qui est arrivé (`quantite_recue`), pas ce qui avait été commandé.
create function fn_receptionner_commande() returns trigger
language plpgsql as $$
begin
  if new.statut = 'recue' and old.statut is distinct from 'recue' then
    insert into mouvements_stock (
      produit_id, type, quantite, date_mouvement, utilisateur_id, commande_id,
      prix_unitaire, commentaire)
    select cl.produit_id, 'entree', coalesce(cl.quantite_recue, cl.quantite),
           new.recue_le, new.saisie_par, new.id, cl.prix_unitaire_ht,
           'Commande n° ' || new.reference
    from commande_lignes cl
    where cl.commande_id = new.id
      and cl.produit_id is not null
      and coalesce(cl.quantite_recue, cl.quantite) > 0;

    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, vers_lieu,
      date_mouvement, utilisateur_id, commande_id, commentaire)
    select 'entree', cl.bouteille_type_id, coalesce(cl.quantite_recue, cl.quantite),
           'hors_parc', 'reserve', new.recue_le, new.saisie_par, new.id,
           'Commande n° ' || new.reference
    from commande_lignes cl
    where cl.commande_id = new.id
      and cl.bouteille_type_id is not null
      and coalesce(cl.quantite_recue, cl.quantite) > 0;
  end if;
  return new;
end;
$$;

create trigger tg_receptionner_commande
after update on commandes
for each row execute function fn_receptionner_commande();

-- 6bis. Antidater une réception déplace les mouvements qu'elle a produits.
--       Une entrée de stock porte la date de la livraison, pas celle de sa
--       saisie : corriger l'une sans l'autre fausserait l'historique du prix.
create function fn_redater_reception() returns trigger
language plpgsql as $$
begin
  if new.statut = 'recue' and old.statut = 'recue'
     and new.recue_le is distinct from old.recue_le then
    update mouvements_stock      set date_mouvement = new.recue_le
     where commande_id = new.id and type = 'entree';
    update mouvements_bouteilles set date_mouvement = new.recue_le
     where commande_id = new.id and type = 'entree';
  end if;
  return new;
end;
$$;

create trigger tg_redater_reception
after update on commandes
for each row execute function fn_redater_reception();

-- 7. Valider un inventaire matériel écrit les régularisations correspondantes.
--    Le stock est recalé par un mouvement tracé, jamais par une écriture directe.
create function fn_valider_inventaire_materiel() returns trigger
language plpgsql as $$
begin
  if new.statut = 'valide' and old.statut = 'brouillon' and new.type = 'materiel' then
    insert into mouvements_stock (
      produit_id, type, motif, quantite, date_mouvement,
      utilisateur_id, inventaire_id, commentaire)
    select
      l.produit_id, 'regularisation', 'inventaire', l.ecart, new.valide_le,
      new.valide_par, new.id,
      'Régularisation d''inventaire (théorique ' || l.quantite_theorique ||
      ', compté ' || l.quantite_comptee || ')'
    from inventaire_lignes_produit l
    where l.inventaire_id = new.id and l.ecart <> 0;
  end if;
  return new;
end;
$$;

create trigger tg_valider_inventaire_materiel
after update on inventaires
for each row execute function fn_valider_inventaire_materiel();

-- 7bis. Valider un inventaire de bouteilles écrit les régularisations.
--       Un écart ne se corrige jamais par une écriture directe : il produit un
--       mouvement, daté, signé, et annulable. Une bouteille trouvée en trop
--       entre dans le parc ; une bouteille manquante en sort.
create function fn_valider_inventaire_bouteilles() returns trigger
language plpgsql as $$
begin
  if new.statut = 'valide' and old.statut = 'brouillon' and new.type = 'bouteilles' then
    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, de_emplacement_id,
      vers_lieu, vers_emplacement_id, date_mouvement, utilisateur_id,
      inventaire_id, commentaire)
    select
      'regularisation', l.bouteille_type_id, abs(l.ecart),
      -- Un écart positif vient de nulle part ; un écart négatif y retourne.
      case when l.ecart > 0 then 'hors_parc'
           when l.emplacement_id is null then 'reserve'
           else 'emplacement' end::lieu_bouteille,
      case when l.ecart < 0 then l.emplacement_id end,
      case when l.ecart < 0 then 'hors_parc'
           when l.emplacement_id is null then 'reserve'
           else 'emplacement' end::lieu_bouteille,
      case when l.ecart > 0 then l.emplacement_id end,
      new.valide_le, new.valide_par, new.id,
      'Régularisation d''inventaire (théorique ' || l.quantite_theorique ||
      ', compté ' || l.quantite_comptee || ')'
    from inventaire_lignes_bouteille l
    where l.inventaire_id = new.id and l.ecart <> 0;
  end if;
  return new;
end;
$$;

create trigger tg_valider_inventaire_bouteilles
after update on inventaires
for each row execute function fn_valider_inventaire_bouteilles();

-- 8. Préparer une demande de devis par fournisseur, regroupant tous ses articles
--    sous le seuil. Une seule demande par fournisseur, donc un seul mail.
create function fn_preparer_demandes_devis(p_utilisateur_id uuid default null)
returns setof demandes_devis
language plpgsql as $$
declare
  v_fournisseur record;
  v_demande     demandes_devis;
begin
  for v_fournisseur in
    select distinct fournisseur_id from v_reappro_necessaire where fournisseur_id is not null
  loop
    -- Ne pas rouvrir un devis déjà en cours pour ce fournisseur
    if exists (
      select 1 from demandes_devis
      where fournisseur_id = v_fournisseur.fournisseur_id
        and statut in ('brouillon', 'envoyee')
    ) then
      continue;
    end if;

    insert into demandes_devis (fournisseur_id, cree_par, destinataires)
    select v_fournisseur.fournisseur_id, p_utilisateur_id,
           array_remove(array[f.email, f.email_2], null)
    from fournisseurs f where f.id = v_fournisseur.fournisseur_id
    returning * into v_demande;

    insert into demande_devis_lignes (
      demande_id, produit_id, bouteille_type_id, libelle,
      stock_actuel, seuil, quantite_demandee)
    select distinct on (r.nature, r.article_id)
      v_demande.id,
      case when r.nature = 'produit'   then r.article_id end,
      case when r.nature = 'bouteille' then r.article_id end,
      r.libelle, r.stock_actuel, r.seuil, r.quantite_suggeree
    from v_reappro_necessaire r
    where r.fournisseur_id = v_fournisseur.fournisseur_id;

    return next v_demande;
  end loop;
end;
$$;

-- 9. Le digest du soir a envoyé : on horodate, pour ne pas renvoyer demain.
create function fn_marquer_envois(p_categorie text, p_tournees uuid[])
returns int
language plpgsql as $$
declare v_nb int;
begin
  if p_categorie = 'recap_technicien' then
    update tournees set mail_technicien_envoye_le = now()
     where id = any (p_tournees) and mail_technicien_envoye_le is null;
  elsif p_categorie = 'recap_intervention' then
    update tournees set mail_recap_envoye_le = now()
     where id = any (p_tournees) and mail_recap_envoye_le is null;
  else
    raise exception 'catégorie d''envoi inconnue : %', p_categorie;
  end if;
  get diagnostics v_nb = row_count;
  return v_nb;
end;
$$;

-- 10. Recherche du catalogue par mots-clés, depuis le téléphone de la gouvernante.
--    Tolérante : elle ne lève jamais d'erreur de syntaxe quel que soit le texte
--    saisi, contrairement à une requête plein-texte construite à la volée.
create function fn_rechercher_catalogue(p_terme text default null)
returns setof catalogue_anomalies
language sql stable as $$
  select c.*
  from catalogue_anomalies c
  where c.actif
    and (
      coalesce(btrim(p_terme), '') = ''
      or c.libelle ilike '%' || btrim(p_terme) || '%'
      or exists (
        select 1 from unnest(c.mots_cles) m
        where m ilike btrim(p_terme) || '%'
      )
    )
  -- Les libellés les plus utilisés remontent en tête : sur un téléphone, la
  -- bonne réponse doit être dans les premiers résultats.
  order by c.occurrences desc, c.libelle;
$$;

-- Le catalogue vu depuis un lieu : chaque libellé porte son état ici. Celui qui
-- est déjà ouvert n'est pas proposé à la saisie ; les autres affichent combien
-- de fois le problème est déjà revenu, ce qui est une information, pas un
-- obstacle.
create function fn_catalogue_pour_lieu(
  p_emplacement_id uuid,
  p_terme text default null
) returns table (
  id              uuid,
  libelle         text,
  occurrences     int,
  deja_ouverte    boolean,
  ouverte_depuis  int,
  nb_fois_ici     int,
  derniere_fois   date
)
language sql stable as $$
  select
    c.id,
    c.libelle,
    c.occurrences,
    coalesce(f.ouvertes, 0) > 0,
    o.jours_depuis,
    coalesce(f.nb_fois, 0),
    f.derniere_fois
  from fn_rechercher_catalogue(p_terme) c
  left join v_frequence_anomalie_lieu f
         on f.emplacement_id = p_emplacement_id and f.catalogue_id = c.id
  left join lateral (
    select v.jours_depuis from v_anomalies_du_lieu v
    where v.emplacement_id = p_emplacement_id and v.catalogue_id = c.id and v.ouverte
    order by v.declare_le desc limit 1
  ) o on true
  order by coalesce(f.ouvertes, 0) > 0, c.occurrences desc, c.libelle;
$$;

-- -----------------------------------------------------------------------------
-- Contrôle des données reprises de SharePoint.
-- Les anomalies douteuses sont importées telles quelles puis listées ici, pour
-- être corrigées en connaissance de cause plutôt que devinées à l'import.
-- -----------------------------------------------------------------------------
create view v_controle_donnees as
select
  'date_future'::text  as anomalie_donnee,
  a.id                 as anomalie_id,
  a.reference,
  e.code               as emplacement,
  a.description,
  'Déclarée le ' || to_char(a.declare_le, 'DD/MM/YYYY') || ', soit dans le futur' as detail
from anomalies a
join emplacements e on e.id = a.emplacement_id
where a.declare_le::date > current_date
union all
select
  'localisation_incertaine',
  a.id,
  a.reference,
  e.code,
  a.description,
  coalesce(
    (select c.texte from commentaires c
      where c.anomalie_id = a.id and c.origine = 'reprise'
      order by c.ecrit_le limit 1),
    'Localisation d''origine inconnue')
from anomalies a
join emplacements e on e.id = a.emplacement_id
where e.code = 'General'
union all
select
  'stock_negatif',
  null::uuid,
  null::bigint,
  sp.code,
  sp.designation,
  'Stock calculé à ' || sp.stock || ' : à recaler au comptage physique'
from v_stock_produits sp
where sp.stock < 0
union all
select
  'intervention_future',
  a.id,
  a.reference,
  e.code,
  a.description,
  'Intervention datée du ' || to_char(i.date_intervention, 'DD/MM/YYYY')
from interventions i
join anomalies a    on a.id = i.anomalie_id
join emplacements e on e.id = a.emplacement_id
where i.date_intervention > current_date;
