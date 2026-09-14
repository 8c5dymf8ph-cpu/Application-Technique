-- =============================================================================
-- Migration 0002 : vues de calcul et règles métier
-- Tout ce qui se calcule est calculé ici. Aucune valeur de stock n'est stockée
-- en dur : c'est la garantie qu'elle ne peut pas diverger de son historique.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Stock matériel
-- -----------------------------------------------------------------------------
create view v_stock_produits as
select
  p.id,
  p.code,
  p.designation,
  p.categorie,
  p.unite,
  p.prix_unitaire,
  p.seuil_alerte,
  p.photo_url,
  p.actif,
  coalesce(sum(m.quantite), 0)                       as stock,
  coalesce(sum(m.quantite), 0) * p.prix_unitaire      as valeur_stock,
  coalesce(sum(m.quantite), 0) <= p.seuil_alerte      as sous_seuil
from produits p
left join mouvements_stock m on m.produit_id = p.id
group by p.id;

-- -----------------------------------------------------------------------------
-- Coût d'une intervention
-- -----------------------------------------------------------------------------
create view v_interventions_cout as
select
  i.id                                                        as intervention_id,
  i.anomalie_id,
  coalesce(mat.cout_materiel, 0)                              as cout_materiel,
  i.cout_prestataire,
  i.cout_libre,
  coalesce(mat.cout_materiel, 0) + i.cout_prestataire + i.cout_libre as cout_total
from interventions i
left join lateral (
  -- Les sorties sont négatives : on reprend la valeur absolue pour obtenir un coût
  select sum(abs(m.quantite) * p.prix_unitaire) as cout_materiel
  from mouvements_stock m
  join produits p on p.id = m.produit_id
  where m.intervention_id = i.id
    and m.type = 'sortie'
) mat on true;

-- -----------------------------------------------------------------------------
-- Récapitulatif d'intervention : les deux avis côte à côte
-- -----------------------------------------------------------------------------
create view v_recap_interventions as
select
  i.id                        as intervention_id,
  a.id                        as anomalie_id,
  a.reference                 as anomalie_reference,
  e.code                      as emplacement,
  et.nom                      as etage,
  ti.nom                      as type_intervention,
  a.description,
  a.statut                    as statut_anomalie,
  ut.nom                      as technicien,
  vt.decision                 as decision_technicien,
  vt.decide_le                as declare_fait_le,
  vt.commentaire              as commentaire_technicien,
  ug.nom                      as gouvernante,
  vg.decision                 as decision_gouvernante,
  vg.decide_le                as decide_gouvernante_le,
  vg.commentaire              as commentaire_gouvernante,
  -- Ce drapeau est ce qui doit apparaître en clair dans le récapitulatif envoyé
  (vt.decision = 'fait' and vg.decision = 'refusee') as refusee_par_gouvernante,
  c.cout_materiel,
  c.cout_prestataire,
  c.cout_libre,
  c.cout_total,
  i.cree_le
from interventions i
join anomalies a           on a.id = i.anomalie_id
join emplacements e        on e.id = a.emplacement_id
join etages et             on et.id = e.etage_id
left join types_intervention ti on ti.id = a.type_id
left join utilisateurs ut  on ut.id = i.technicien_id
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
  bt.prix_vente,
  bt.prix_achat,
  coalesce(sum(p.qte) filter (where p.lieu = 'reserve'), 0)     as en_reserve,
  coalesce(sum(p.qte) filter (where p.lieu = 'emplacement'), 0) as en_chambre,
  coalesce(sum(p.qte), 0)                                       as parc_total,
  coalesce(d.dotation_theorique, 0)                             as dotation_theorique
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

-- Suivi des dossiers de perte, avec le montant théorique si l'arbitrage n'a pas
-- encore fixé de montant.
create view v_incidents_bouteille as
select
  i.id,
  i.reference,
  e.code                                   as emplacement,
  bt.libelle                               as bouteille,
  i.quantite,
  i.cause,
  uc.nom                                   as constate_par,
  i.constate_le,
  i.statut,
  ut.nom                                   as transmis_a,
  i.transmis_le,
  coalesce(
    i.montant,
    case
      when i.cause in ('client_perte', 'client_casse') then i.quantite * bt.prix_vente
      else i.quantite * bt.prix_achat
    end
  )                                        as montant,
  i.cause in ('client_perte', 'client_casse') as facturable_client,
  i.commentaire
from incidents_bouteille i
join emplacements e     on e.id = i.emplacement_id
join bouteille_types bt on bt.id = i.bouteille_type_id
left join utilisateurs uc on uc.id = i.constate_par
left join utilisateurs ut on ut.id = i.transmis_a;

-- =============================================================================
-- Règles métier
-- =============================================================================

-- 1. Un incident de bouteille génère AUTOMATIQUEMENT sa sortie de parc — une seule.
--    La re-dotation de la chambre est un mouvement distinct (réserve → chambre)
--    qui ne déduit rien du parc.
create function fn_incident_genere_perte() returns trigger
language plpgsql as $$
begin
  insert into mouvements_bouteilles (
    type, bouteille_type_id, quantite,
    de_lieu, de_emplacement_id, vers_lieu,
    date_mouvement, utilisateur_id, incident_id, commentaire
  ) values (
    'perte', new.bouteille_type_id, new.quantite,
    'emplacement', new.emplacement_id, 'hors_parc',
    new.constate_le, new.constate_par, new.id,
    'Sortie de parc automatique — incident #' || new.reference
  );
  return new;
end;
$$;

create trigger tg_incident_genere_perte
after insert on incidents_bouteille
for each row execute function fn_incident_genere_perte();

-- 2. Re-doter une chambre depuis la réserve, après un incident ou un inventaire.
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
    de_lieu, vers_lieu, vers_emplacement_id, utilisateur_id, commentaire
  ) values (
    'dotation', p_bouteille_type_id, p_quantite,
    'reserve', 'emplacement', p_emplacement_id, p_utilisateur_id,
    'Re-dotation de la chambre'
  )
  returning id into v_id;
  return v_id;
end;
$$;

-- 3. Le statut de l'anomalie suit la dernière validation enregistrée.
--    Refus de la gouvernante => retour à « à faire », commentaire conservé.
create function fn_validation_maj_anomalie() returns trigger
language plpgsql as $$
declare
  v_anomalie_id uuid;
begin
  select anomalie_id into v_anomalie_id from interventions where id = new.intervention_id;

  update anomalies set
    statut = case
      when new.acteur = 'technicien'  and new.decision = 'fait'     then 'attente_validation'::statut_anomalie
      when new.acteur = 'technicien'  and new.decision = 'non_fait' then 'en_cours'::statut_anomalie
      when new.acteur = 'gouvernante' and new.decision = 'validee'  then 'validee'::statut_anomalie
      when new.acteur = 'gouvernante' and new.decision = 'refusee'  then 'a_faire'::statut_anomalie
      else statut
    end,
    cloture_le = case
      when new.acteur = 'gouvernante' and new.decision = 'validee' then new.decide_le
      else null
    end,
    maj_le = now()
  where id = v_anomalie_id;

  return new;
end;
$$;

create trigger tg_validation_maj_anomalie
after insert on validations
for each row execute function fn_validation_maj_anomalie();

-- 4. Valider un inventaire matériel écrit les régularisations correspondantes.
--    Le stock est recalé par un mouvement tracé, jamais par une écriture directe.
create function fn_valider_inventaire_materiel() returns trigger
language plpgsql as $$
begin
  if new.statut = 'valide' and old.statut = 'brouillon' and new.type = 'materiel' then
    insert into mouvements_stock (
      produit_id, type, quantite, date_mouvement,
      utilisateur_id, inventaire_id, commentaire
    )
    select
      l.produit_id, 'regularisation', l.ecart, new.valide_le,
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
