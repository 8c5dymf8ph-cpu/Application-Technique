-- =============================================================================
-- Migration 0003 : sécurité au niveau des lignes (RLS)
-- Toute lecture/écriture passe par ces règles, y compris depuis le navigateur.
-- =============================================================================

create function fn_utilisateur_courant() returns utilisateurs
language sql stable security definer set search_path = public as $$
  select * from utilisateurs where auth_id = auth.uid() and actif limit 1;
$$;

create function fn_role_courant() returns role_utilisateur
language sql stable security definer set search_path = public as $$
  select role from utilisateurs where auth_id = auth.uid() and actif limit 1;
$$;

create function fn_est_connecte() returns boolean
language sql stable as $$ select fn_role_courant() is not null; $$;

create function fn_peut_ecrire() returns boolean
language sql stable as $$ select fn_role_courant() in ('technicien','gouvernante','admin'); $$;

create function fn_peut_valider() returns boolean
language sql stable as $$ select fn_role_courant() in ('gouvernante','admin'); $$;

create function fn_est_admin() returns boolean
language sql stable as $$ select fn_role_courant() = 'admin'; $$;

do $$
declare t text;
begin
  foreach t in array array[
    'utilisateurs','etages','emplacements','types_intervention','prestataires',
    'anomalies','interventions','validations',
    'produits','mouvements_stock','inventaires','inventaire_lignes_produit',
    'bouteille_types','dotations','incidents_bouteille','mouvements_bouteilles',
    'inventaire_lignes_bouteille','recap_abonnements','recap_envois','journal'
  ] loop
    execute format('alter table %I enable row level security', t);
    -- Tout utilisateur connecté et actif lit l'ensemble des données de l'hôtel.
    execute format(
      'create policy lecture_connectes on %I for select to authenticated using (fn_est_connecte())', t);
  end loop;
end $$;

-- Écriture opérationnelle : techniciens, gouvernantes et admins.
do $$
declare t text;
begin
  foreach t in array array[
    'anomalies','interventions','mouvements_stock','inventaires',
    'inventaire_lignes_produit','incidents_bouteille','mouvements_bouteilles',
    'inventaire_lignes_bouteille'
  ] loop
    execute format(
      'create policy ecriture_operationnelle on %I for all to authenticated
         using (fn_peut_ecrire()) with check (fn_peut_ecrire())', t);
  end loop;
end $$;

-- Une validation n'est insérable que par l'acteur qui en a le droit : un technicien
-- ne peut pas signer à la place de la gouvernante.
create policy ecriture_validations on validations
  for insert to authenticated
  with check (
    (acteur = 'technicien'  and fn_peut_ecrire()) or
    (acteur = 'gouvernante' and fn_peut_valider())
  );

-- Référentiels et paramétrage : admin uniquement.
do $$
declare t text;
begin
  foreach t in array array[
    'utilisateurs','etages','emplacements','types_intervention','prestataires',
    'produits','bouteille_types','dotations','recap_abonnements'
  ] loop
    execute format(
      'create policy ecriture_admin on %I for all to authenticated
         using (fn_est_admin()) with check (fn_est_admin())', t);
  end loop;
end $$;

-- Le journal d'audit et l'historique d'envoi ne sont jamais modifiables depuis l'app.
revoke insert, update, delete on journal, recap_envois from authenticated;
