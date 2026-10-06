-- =============================================================================
-- Migration 0039 : un inventaire porte la date où il a été COMPTÉ
-- =============================================================================
-- Ira a compté le 04/10/26, à la demande de Miguel — mais la seule date que
-- l'écran pouvait écrire, `valide_le`, se pose au moment où Miguel clique
-- sur « Valider », parfois des jours plus tard. Les régularisations posées à
-- la validation (`fn_valider_inventaire_materiel`, `fn_valider_inventaire_
-- bouteilles`) héritaient de cette date — c'est elle qui sort dans le
-- récapitulatif, le mauvais jour.
--
-- `compte_le` distingue donc trois moments qui n'ont pas à coïncider :
-- `ouvert_le` (quand le brouillon a été créé en base), `compte_le` (quand on
-- a réellement compté — ce qui doit apparaître partout où la date compte),
-- et `valide_le` (quand on a validé). Backfill sur `ouvert_le::date` pour
-- l'historique : c'est la meilleure approximation disponible, et un
-- brouillon encore ouvert peut la corriger avant de valider.
alter table inventaires
  add column compte_le date;

update inventaires set compte_le = ouvert_le::date where compte_le is null;

alter table inventaires
  alter column compte_le set not null,
  alter column compte_le set default current_date;

comment on column inventaires.compte_le is
  'Le jour où le comptage a eu lieu — distinct de ouvert_le (saisie en base) '
  'et valide_le (validation). C''est cette date, pas valide_le, qui doit '
  'apparaître dans les récapitulatifs et sur les mouvements de régularisation.';

create or replace function fn_valider_inventaire_materiel() returns trigger
language plpgsql as $$
begin
  if new.statut = 'valide' and old.statut = 'brouillon' and new.type = 'materiel' then
    insert into mouvements_stock (
      produit_id, type, motif, quantite, date_mouvement,
      utilisateur_id, inventaire_id, commentaire)
    select
      l.produit_id, 'regularisation', 'inventaire', l.ecart,
      (new.compte_le::text || ' 12:00')::timestamptz,
      new.valide_par, new.id,
      'Régularisation d''inventaire (théorique ' || l.quantite_theorique ||
      ', compté ' || l.quantite_comptee || ')'
    from inventaire_lignes_produit l
    where l.inventaire_id = new.id and l.ecart <> 0;
  end if;
  return new;
end;
$$;

create or replace function fn_valider_inventaire_bouteilles() returns trigger
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
      (new.compte_le::text || ' 12:00')::timestamptz, new.valide_par, new.id,
      'Régularisation d''inventaire (théorique ' || l.quantite_theorique ||
      ', compté ' || l.quantite_comptee || ')'
    from inventaire_lignes_bouteille l
    where l.inventaire_id = new.id and l.ecart <> 0;
  end if;
  return new;
end;
$$;
