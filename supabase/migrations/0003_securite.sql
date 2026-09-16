-- =============================================================================
-- Migration 0003 : sécurité au niveau des lignes (RLS)
-- Toute lecture/écriture passe par ces règles, y compris depuis le navigateur.
--
-- Attention : plusieurs politiques permissives sur une même table s'ADDITIONNENT.
-- Les tables portant une règle restrictive (anomalies, validations) ne reçoivent
-- donc jamais de politique « for all », qui l'annulerait.
-- =============================================================================

create function fn_role_courant() returns role_utilisateur
language sql stable security definer set search_path = public as $$
  select role from utilisateurs where auth_id = auth.uid() and actif limit 1;
$$;

create function fn_utilisateur_courant_id() returns uuid
language sql stable security definer set search_path = public as $$
  select id from utilisateurs where auth_id = auth.uid() and actif limit 1;
$$;

create function fn_est_connecte() returns boolean
language sql stable as $$ select fn_role_courant() is not null; $$;

create function fn_peut_ecrire() returns boolean
language sql stable as $$ select fn_role_courant() in ('technicien','gouvernante','admin'); $$;

create function fn_peut_valider() returns boolean
language sql stable as $$ select fn_role_courant() in ('gouvernante','admin'); $$;

create function fn_est_admin() returns boolean
language sql stable as $$ select fn_role_courant() = 'admin'; $$;

-- -----------------------------------------------------------------------------
-- Lecture : tout utilisateur connecté et actif voit les données de l'hôtel.
-- -----------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array[
    'utilisateurs','specialites_intervenant','etages','emplacements',
    'types_intervention','prestataires','fournisseurs','catalogue_anomalies',
    'anomalies','tournees','interventions','validations','photos_anomalie',
    'factures','facture_interventions',
    'produits','article_fournisseurs','photos_produit','mouvements_stock',
    'inventaires','inventaire_lignes_produit',
    'bouteille_types','dotations','incidents_bouteille','mouvements_bouteilles',
    'inventaire_lignes_bouteille',
    'demandes_devis','demande_devis_lignes',
    'recap_abonnements','alertes_destinataires','emails_envoyes','parametres','journal'
  ] loop
    execute format('alter table %I enable row level security', t);
    execute format('grant select on %I to authenticated', t);
    execute format(
      'create policy lecture_connectes on %I for select to authenticated using (fn_est_connecte())', t);
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- Écriture opérationnelle : techniciens, gouvernantes et admins.
-- -----------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array[
    'tournees','interventions','photos_anomalie','photos_produit','factures','facture_interventions',
    'mouvements_stock','inventaires','inventaire_lignes_produit',
    'incidents_bouteille','mouvements_bouteilles','inventaire_lignes_bouteille',
    'demandes_devis','demande_devis_lignes'
  ] loop
    execute format('grant insert, update, delete on %I to authenticated', t);
    execute format(
      'create policy ecriture_operationnelle on %I for all to authenticated
         using (fn_peut_ecrire()) with check (fn_peut_ecrire())', t);
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- Anomalies : la gouvernante déclare depuis son téléphone en choisissant dans le
-- catalogue. Une anomalie hors catalogue ne peut être créée que par un admin,
-- depuis un ordinateur — c'est la règle demandée, appliquée ici et pas seulement
-- dans l'interface.
-- -----------------------------------------------------------------------------
grant insert, update, delete on anomalies to authenticated;

create policy creation_depuis_catalogue on anomalies
  for insert to authenticated
  with check (fn_peut_ecrire() and (catalogue_id is not null or fn_est_admin()));

create policy modification_anomalies on anomalies
  for update to authenticated
  using (fn_peut_ecrire()) with check (fn_peut_ecrire());

create policy suppression_anomalies on anomalies
  for delete to authenticated
  using (fn_est_admin());

-- -----------------------------------------------------------------------------
-- Validations : un technicien ne peut pas signer à la place de la gouvernante.
-- Elles ne sont ni modifiables ni supprimables : l'historique des avis est figé.
-- -----------------------------------------------------------------------------
grant insert on validations to authenticated;

create policy ecriture_validations on validations
  for insert to authenticated
  with check (
    (acteur = 'technicien'  and fn_peut_ecrire()) or
    (acteur = 'gouvernante' and fn_peut_valider())
  );

-- -----------------------------------------------------------------------------
-- Référentiels et paramétrage : admin uniquement.
-- -----------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array[
    'utilisateurs','specialites_intervenant','etages','emplacements',
    'types_intervention','prestataires','fournisseurs','catalogue_anomalies',
    'produits','article_fournisseurs','bouteille_types','dotations',
    'recap_abonnements','alertes_destinataires','parametres'
  ] loop
    execute format('grant insert, update, delete on %I to authenticated', t);
    execute format(
      'create policy ecriture_admin on %I for all to authenticated
         using (fn_est_admin()) with check (fn_est_admin())', t);
  end loop;
end $$;

-- -----------------------------------------------------------------------------
-- Le journal d'audit et l'historique d'envoi ne sont jamais écrits depuis l'app.
-- -----------------------------------------------------------------------------
revoke insert, update, delete on journal, emails_envoyes from authenticated;

-- -----------------------------------------------------------------------------
-- Les vues appliquent les droits de l'appelant, et non ceux de leur propriétaire :
-- sans cela, une vue contournerait silencieusement les règles ci-dessus.
-- -----------------------------------------------------------------------------
do $$
declare v text;
begin
  foreach v in array array[
    'v_stock_produits','v_cout_prestataire','v_interventions_cout',
    'v_recap_interventions','v_tournees','v_fil_commentaires','v_intervenants',
    'v_interventions_sans_facture','v_envois_en_attente','v_recurrences_emplacement','v_bouteilles_positions',
    'v_stock_bouteilles','v_bouteilles_par_emplacement','v_incidents_bouteille',
    'v_reappro_necessaire','v_controle_donnees'
  ] loop
    execute format('alter view %I set (security_invoker = on)', v);
    execute format('grant select on %I to authenticated', v);
  end loop;
end $$;
