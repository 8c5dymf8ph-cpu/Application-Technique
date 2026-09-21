-- =============================================================================
-- Migration 0014 : corriger ou supprimer un dossier bouteille
-- =============================================================================
-- Un dossier bouteille ne se corrigeait pas. On le déclarait, et c'était dit
-- pour toujours : la mauvaise chambre restait la mauvaise chambre, et on ne
-- pouvait pas saisir un dossier d'il y a trois semaines à sa vraie date — il
-- arrivait daté d'aujourd'hui, au milieu des dossiers en cours.
--
-- Or le parc de bouteilles n'est pas un chiffre stocké : c'est la somme des
-- mouvements. Un dossier PRODUIT des mouvements — l'emport, la re-dotation,
-- plus tard le retour ou la perte. Corriger l'en-tête sans déplacer ses
-- mouvements rendrait le parc faux et l'inventaire incompréhensible : la
-- chambre 27 aurait rendu une bouteille que la 26 n'a jamais perdue.
--
-- Les mouvements suivent donc leur dossier. C'est le même principe que
-- `tg_redater_reception` pour une livraison de matériel : on ne réécrit pas le
-- stock, on redate ce qui l'a produit.
--
-- Ce qui ne se corrige PAS ici : la nature du dossier. Passer d'un emport à
-- une casse ne déplace pas une bouteille, cela change son sort — elle va chez
-- le client ou elle sort du parc, et le dossier peut déjà avoir été résolu
-- dans l'autre logique. Un dossier de la mauvaise nature se supprime et se
-- redéclare ; l'écran le dit.

-- -----------------------------------------------------------------------------
-- 1. L'en-tête : la date et le lieu entraînent leurs mouvements
-- -----------------------------------------------------------------------------
create or replace function fn_corriger_dossier_bouteille() returns trigger
language plpgsql as $$
begin
  -- Les mouvements du CONSTAT portent la date du constat. Ceux de la
  -- résolution portent la date de résolution : deux moments, deux dates.
  if new.constate_le is distinct from old.constate_le then
    update mouvements_bouteilles
       set date_mouvement = new.constate_le
     where incident_id = new.id
       and type in ('emport', 'casse', 'dotation');
  end if;

  if new.resolu_le is distinct from old.resolu_le and new.resolu_le is not null then
    update mouvements_bouteilles
       set date_mouvement = new.resolu_le
     where incident_id = new.id
       and type in ('retour', 'perte');
  end if;

  -- Le lieu : la bouteille part de la chambre, et la re-dotation y revient.
  if new.emplacement_id is distinct from old.emplacement_id then
    update mouvements_bouteilles
       set de_emplacement_id = new.emplacement_id
     where incident_id = new.id
       and type in ('emport', 'casse')
       and de_lieu = 'emplacement';

    update mouvements_bouteilles
       set vers_emplacement_id = new.emplacement_id
     where incident_id = new.id
       and type = 'dotation';
  end if;

  -- Qui a constaté reste attaché aux mouvements du constat : c'est lui qui
  -- signe le déplacement.
  if new.constate_par is distinct from old.constate_par then
    update mouvements_bouteilles
       set utilisateur_id = new.constate_par
     where incident_id = new.id
       and type in ('emport', 'casse', 'dotation');
  end if;

  -- La re-dotation se décide, et se dédit : la réserve était vide, on n'a pas
  -- re-doté. Elle ne se double jamais — une par type concerné.
  if new.redoter is distinct from old.redoter then
    if new.redoter then
      insert into mouvements_bouteilles (
        type, bouteille_type_id, quantite, de_lieu, vers_lieu, vers_emplacement_id,
        date_mouvement, utilisateur_id, incident_id, commentaire)
      select 'dotation', l.bouteille_type_id, l.quantite, 'reserve', 'emplacement',
             new.emplacement_id, new.constate_le, new.constate_par, new.id,
             'Re-dotation de la chambre — dossier n° ' || new.reference
        from incident_lignes_bouteille l
       where l.incident_id = new.id
         and not exists (
           select 1 from mouvements_bouteilles m
            where m.incident_id = new.id and m.type = 'dotation'
              and m.bouteille_type_id = l.bouteille_type_id);
    else
      delete from mouvements_bouteilles
       where incident_id = new.id and type = 'dotation';
    end if;
  end if;

  return new;
end;
$$;

comment on function fn_corriger_dossier_bouteille() is
  'Les mouvements suivent leur dossier quand on le corrige. Sans cela, changer '
  'la chambre ou la date rendrait le parc faux : une chambre aurait rendu une '
  'bouteille qu''une autre a perdue.';

drop trigger if exists tg_corriger_dossier_bouteille on incidents_bouteille;
create trigger tg_corriger_dossier_bouteille
after update on incidents_bouteille
for each row execute function fn_corriger_dossier_bouteille();

-- -----------------------------------------------------------------------------
-- 2. Les lignes : un type retiré ou une quantité corrigée
-- -----------------------------------------------------------------------------
-- Une chambre perd la filtrée ET la gazeuse : c'est un dossier, deux lignes.
-- Si l'on s'est trompé de type, retirer la ligne doit retirer ce qu'elle a
-- déplacé — sinon la bouteille reste partie pour toujours.
create or replace function fn_corriger_ligne_bouteille() returns trigger
language plpgsql as $$
begin
  if tg_op = 'DELETE' then
    delete from mouvements_bouteilles
     where incident_id = old.incident_id
       and bouteille_type_id = old.bouteille_type_id;
    return old;
  end if;

  if new.quantite is distinct from old.quantite then
    update mouvements_bouteilles
       set quantite = new.quantite
     where incident_id = new.incident_id
       and bouteille_type_id = new.bouteille_type_id;
  end if;
  return new;
end;
$$;

drop trigger if exists tg_corriger_ligne_bouteille on incident_lignes_bouteille;
create trigger tg_corriger_ligne_bouteille
after update or delete on incident_lignes_bouteille
for each row execute function fn_corriger_ligne_bouteille();

-- -----------------------------------------------------------------------------
-- 3. Supprimer un dossier : trois personnes, jamais un technicien
-- -----------------------------------------------------------------------------
-- Même règle que pour une anomalie, et pour la même raison : c'est celle qui
-- déclare qui se trompe de chambre ou déclare deux fois la même bouteille.
-- Victoria, Sarah P et Miguel.
--
-- La différence avec une anomalie : ici, TOUT part. Les mouvements sont en
-- `on delete cascade` sur le dossier, et c'est juste — le matériel d'une
-- intervention a réellement quitté l'étagère, alors qu'un dossier déclaré par
-- erreur n'a jamais déplacé la moindre bouteille. Le parc redevient ce qu'il
-- était.
drop policy if exists ecriture_operationnelle on incidents_bouteille;

create policy ecriture_dossiers on incidents_bouteille
  for insert to authenticated with check (fn_peut_ecrire());

create policy modification_dossiers on incidents_bouteille
  for update to authenticated
  using (fn_peut_ecrire()) with check (fn_peut_ecrire());

create policy suppression_dossiers on incidents_bouteille
  for delete to authenticated
  using (fn_peut_supprimer());
