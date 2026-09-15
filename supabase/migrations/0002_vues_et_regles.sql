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
  p.prix_unitaire is null                             as prix_inconnu,
  p.seuil_alerte,
  p.fournisseur_id,
  p.photo_url,
  p.actif,
  coalesce(sum(m.quantite), 0)                        as stock,
  coalesce(sum(m.quantite), 0) * p.prix_unitaire      as valeur_stock,
  coalesce(sum(m.quantite), 0) <= p.seuil_alerte      as sous_seuil
from produits p
left join mouvements_stock m on m.produit_id = p.id
group by p.id;

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
  a.id                        as anomalie_id,
  a.reference                 as anomalie_reference,
  e.code                      as emplacement,
  et.nom                      as etage,
  ti.nom                      as type_intervention,
  a.description,
  a.statut                    as statut_anomalie,
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
  -- Ce drapeau est ce qui doit apparaître en clair dans le récapitulatif envoyé
  (vt.decision = 'fait' and vg.decision = 'refusee') as refusee_par_gouvernante,
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
left join types_intervention ti on ti.id = a.type_id
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

-- Interventions candidates au rapprochement d'une facture : même prestataire,
-- même date. C'est ce que l'écran de rapprochement propose à cocher.
create view v_factures_rapprochement as
select
  f.id              as facture_id,
  f.reference       as facture_reference,
  f.date_intervention,
  f.montant_ht,
  p.nom             as prestataire,
  i.id              as intervention_id,
  a.reference       as anomalie_reference,
  e.code            as emplacement,
  a.description,
  (fi.facture_id is not null) as deja_rapprochee
from factures f
join prestataires p  on p.id = f.prestataire_id
join interventions i on i.prestataire_id = f.prestataire_id
                    and i.date_intervention = f.date_intervention
join anomalies a     on a.id = i.anomalie_id
join emplacements e  on e.id = a.emplacement_id
left join facture_interventions fi on fi.facture_id = f.id and fi.intervention_id = i.id;

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
  bt.prix_vente,
  bt.prix_achat,
  bt.seuil_alerte,
  bt.fournisseur_id,
  -- Le chiffre opérationnel : ce qu'il reste pour re-doter une chambre.
  coalesce(sum(p.qte) filter (where p.lieu = 'reserve'), 0)      as en_reserve,
  coalesce(sum(p.qte) filter (where p.lieu = 'emplacement'), 0)  as en_chambre,
  -- Emportées par un client, pas encore restituées ni facturées.
  coalesce(sum(p.qte) filter (where p.lieu = 'chez_client'), 0)  as chez_clients,
  coalesce(sum(p.qte), 0)                                        as parc_total,
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
-- théorique selon qui est responsable.
create view v_incidents_bouteille as
select
  i.id,
  i.reference,
  e.code                                   as emplacement,
  bt.libelle                               as bouteille,
  i.quantite,
  i.nature,
  i.responsable,
  uc.nom                                   as constate_par,
  i.constate_le,
  i.statut,
  i.client_contacte_le,
  i.resolu_le,
  coalesce(
    i.montant,
    case
      when i.responsable = 'client' then i.quantite * bt.prix_vente
      else i.quantite * bt.prix_achat
    end
  )                                        as montant,
  i.responsable = 'client'                 as facturable_client,
  i.statut in ('signale', 'client_contacte') as dossier_ouvert,
  i.commentaire
from incidents_bouteille i
join emplacements e     on e.id = i.emplacement_id
join bouteille_types bt on bt.id = i.bouteille_type_id
left join utilisateurs uc on uc.id = i.constate_par;

-- -----------------------------------------------------------------------------
-- Réapprovisionnement : articles sous seuil, regroupés par fournisseur.
-- Un seul devis, donc un seul mail, même si trois articles tombent le même jour.
-- -----------------------------------------------------------------------------
create view v_reappro_necessaire as
select
  p.fournisseur_id,
  f.nom                                as fournisseur,
  f.email                              as email_fournisseur,
  'produit'::text                      as nature,
  p.id                                 as article_id,
  p.designation                        as libelle,
  s.stock::numeric                     as stock_actuel,
  p.seuil_alerte::numeric              as seuil,
  coalesce(p.quantite_reappro, greatest(p.seuil_alerte * 2 - s.stock, 1))::numeric as quantite_suggeree
from v_stock_produits s
join produits p      on p.id = s.id
left join fournisseurs f on f.id = p.fournisseur_id
where p.actif and s.stock <= p.seuil_alerte
union all
select
  bt.fournisseur_id,
  f.nom,
  f.email,
  'bouteille'::text,
  bt.id,
  bt.libelle,
  b.en_reserve::numeric,
  bt.seuil_alerte::numeric,
  coalesce(bt.quantite_reappro, greatest(bt.seuil_alerte * 2 - b.en_reserve, 1))::numeric
from v_stock_bouteilles b
join bouteille_types bt  on bt.id = b.bouteille_type_id
left join fournisseurs f on f.id = bt.fournisseur_id
where b.en_reserve <= bt.seuil_alerte;

-- =============================================================================
-- Règles métier
-- =============================================================================

-- 1. Un incident enregistre AUTOMATIQUEMENT les mouvements physiques.
--    Emport : la bouteille part « chez le client », d'où elle peut revenir.
--    Casse  : la bouteille sort définitivement du parc.
--    Dans les deux cas la chambre est re-dotée depuis la réserve, ce qui déplace
--    une bouteille sans en retirer une seconde du parc.
create function fn_incident_bouteille_mouvements() returns trigger
language plpgsql as $$
begin
  if new.nature = 'emport' then
    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, de_emplacement_id, vers_lieu,
      date_mouvement, utilisateur_id, incident_id, commentaire)
    values (
      'emport', new.bouteille_type_id, new.quantite, 'emplacement', new.emplacement_id, 'chez_client',
      new.constate_le, new.constate_par, new.id,
      'Bouteille emportée — incident #' || new.reference);
  else
    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, de_emplacement_id, vers_lieu,
      date_mouvement, utilisateur_id, incident_id, commentaire)
    values (
      'casse', new.bouteille_type_id, new.quantite, 'emplacement', new.emplacement_id, 'hors_parc',
      new.constate_le, new.constate_par, new.id,
      'Bouteille cassée — incident #' || new.reference);
  end if;

  if new.redoter then
    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, vers_lieu, vers_emplacement_id,
      date_mouvement, utilisateur_id, incident_id, commentaire)
    values (
      'dotation', new.bouteille_type_id, new.quantite, 'reserve', 'emplacement', new.emplacement_id,
      new.constate_le, new.constate_par, new.id,
      'Re-dotation de la chambre — incident #' || new.reference);
  end if;

  return new;
end;
$$;

create trigger tg_incident_bouteille_mouvements
after insert on incidents_bouteille
for each row execute function fn_incident_bouteille_mouvements();

-- 2. La résolution d'un emport décide du sort de la bouteille en attente.
--    Restituée  => elle rejoint la RÉSERVE (la chambre a déjà été re-dotée).
--    Facturée   => sortie définitive du parc.
--    Le garde-fou empêche de compter deux fois une bouteille déjà tranchée.
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
    values (
      'retour', new.bouteille_type_id, new.quantite, 'chez_client', 'reserve',
      coalesce(new.resolu_le, now()), new.resolu_par, new.id,
      'Bouteille restituée, remise en réserve — incident #' || new.reference);

  elsif new.statut in ('facture', 'non_facture') then
    insert into mouvements_bouteilles (
      type, bouteille_type_id, quantite, de_lieu, vers_lieu,
      date_mouvement, utilisateur_id, incident_id, commentaire)
    values (
      'perte', new.bouteille_type_id, new.quantite, 'chez_client', 'hors_parc',
      coalesce(new.resolu_le, now()), new.resolu_par, new.id,
      'Bouteille non restituée — incident #' || new.reference);
  end if;

  return new;
end;
$$;

create trigger tg_incident_bouteille_resolution
after update on incidents_bouteille
for each row execute function fn_incident_bouteille_resolution();

-- 3. Re-doter une chambre depuis la réserve, hors incident (après inventaire).
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

-- 4. Le statut de l'anomalie suit la dernière validation enregistrée.
--    Refus de la gouvernante => retour à « à faire », commentaire conservé.
--    Le matériel déjà sorti reste consommé : il n'est jamais annulé par un refus.
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

-- 5. Valider un inventaire matériel écrit les régularisations correspondantes.
--    Le stock est recalé par un mouvement tracé, jamais par une écriture directe.
create function fn_valider_inventaire_materiel() returns trigger
language plpgsql as $$
begin
  if new.statut = 'valide' and old.statut = 'brouillon' and new.type = 'materiel' then
    insert into mouvements_stock (
      produit_id, type, quantite, date_mouvement,
      utilisateur_id, inventaire_id, commentaire)
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

-- 6. Préparer une demande de devis par fournisseur, regroupant tous ses articles
--    sous le seuil. Renvoie les demandes créées — une par fournisseur, donc un
--    seul mail par fournisseur.
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
           coalesce(array_remove(array[f.email], null), '{}')
    from fournisseurs f where f.id = v_fournisseur.fournisseur_id
    returning * into v_demande;

    insert into demande_devis_lignes (
      demande_id, produit_id, bouteille_type_id, libelle,
      stock_actuel, seuil, quantite_demandee)
    select
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

-- 7. Recherche du catalogue par mots-clés, depuis le téléphone de la gouvernante.
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
  order by c.libelle;
$$;
