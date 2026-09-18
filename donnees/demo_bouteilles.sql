-- =============================================================================
-- Jeu de démonstration — bouteilles Purezza
--
-- Ces données sont INVENTÉES. Elles servent à regarder les écrans avec quelque
-- chose dedans, pas à alimenter la production. Ne jamais jouer ce fichier sur la
-- base de l'hôtel : l'export Purezza réel prendra sa place.
-- =============================================================================
begin;

-- Un parc de départ : deux entrées en réserve, tracées comme des mouvements.
insert into mouvements_bouteilles (type, bouteille_type_id, quantite, de_lieu, vers_lieu,
                                   date_mouvement, commentaire)
select 'entree', bt.id, 60, 'hors_parc', 'reserve',
       current_date - interval '13 months', 'Stock de départ (démonstration)'
from bouteille_types bt;

-- Chaque chambre dotée reçoit sa dotation depuis la réserve.
insert into mouvements_bouteilles (type, bouteille_type_id, quantite, de_lieu, vers_lieu,
                                   vers_emplacement_id, date_mouvement, commentaire)
select 'dotation', d.bouteille_type_id, d.quantite, 'reserve', 'emplacement',
       d.emplacement_id, current_date - interval '13 months' + interval '1 hour',
       'Dotation initiale (démonstration)'
from dotations d
join emplacements e on e.id = d.emplacement_id
where e.actif and e.dote_bouteilles;

-- Des dossiers étalés sur douze mois, plus denses l'été, avec des issues variées.
do $$
declare
  v_lieux  uuid[];
  v_types  uuid[];
  v_victoria uuid;
  v_n int;
  v_i int;
  v_mois int;
  v_lieu uuid;
  v_type uuid;
  v_date timestamptz;
  v_incident uuid;
  v_sort int;
  v_noms text[] := array['M. Lefèvre','Mme Bernard','M. Da Silva','Mme Chen','M. Okonkwo',
                         'Mme Rossi','M. Haddad','Mme Nowak','M. Tanaka','Mme Diallo'];
begin
  select array_agg(e.id) into v_lieux
  from emplacements e where e.actif and e.dote_bouteilles;
  select array_agg(id) into v_types from bouteille_types;
  select id into v_victoria from utilisateurs where nom = 'Victoria';

  for v_mois in 0..11 loop
    -- Entre 2 et 7 dossiers par mois, davantage en été.
    v_n := 2 + ((v_mois * 7) % 4) + case when v_mois between 4 and 7 then 2 else 0 end;
    for v_i in 1..v_n loop
      v_lieu := v_lieux[1 + ((v_mois * 13 + v_i * 7) % array_length(v_lieux, 1))];
      v_type := v_types[1 + ((v_mois + v_i) % 2)];
      v_date := date_trunc('month', current_date) - (11 - v_mois) * interval '1 month'
                + (v_i * 3) * interval '1 day' + interval '14 hours';
      if v_date > now() then continue; end if;

      insert into incidents_bouteille (emplacement_id, bouteille_type_id, quantite, nature,
                                       responsable, client_nom, constate_par, constate_le,
                                       commentaire)
      values (v_lieu, v_type, 1,
              case when (v_i % 5) = 0 then 'casse' else 'emport' end::nature_incident_bouteille,
              case when (v_i % 7) = 0 then 'personnel' else 'client' end::responsable_incident,
              case when (v_i % 4) = 0 then null
                   else v_noms[1 + ((v_mois * 3 + v_i) % 10)] end,
              v_victoria, v_date,
              case when (v_i % 6) = 0
                   then 'Chambre libérée avant le contrôle, constaté au recouchage.' end)
      returning id into v_incident;

      -- Les dossiers récents restent ouverts ; les anciens se règlent.
      v_sort := (v_mois * 5 + v_i) % 10;
      if v_mois >= 10 and v_sort < 6 then
        if v_sort >= 3 then
          update incidents_bouteille
             set statut = 'transmis', transmis_le = v_date + interval '2 hours',
                 transmis_a = v_victoria
           where id = v_incident;
        end if;
        continue;
      end if;

      update incidents_bouteille
         set transmis_le = v_date + interval '2 hours', transmis_a = v_victoria,
             client_contacte_le = v_date + interval '1 day'
       where id = v_incident;

      if v_sort < 4 then
        update incidents_bouteille
           set statut = 'facture', resolu_le = v_date + interval '2 days', resolu_par = v_victoria
         where id = v_incident and responsable = 'client';
        update incidents_bouteille
           set statut = 'non_facture', resolu_le = v_date + interval '2 days', resolu_par = v_victoria
         where id = v_incident and responsable <> 'client';
      elsif v_sort < 7 then
        update incidents_bouteille
           set statut = 'restitue', resolu_le = v_date + interval '3 days', resolu_par = v_victoria
         where id = v_incident and nature = 'emport';
        update incidents_bouteille
           set statut = 'non_facture', resolu_le = v_date + interval '3 days', resolu_par = v_victoria
         where id = v_incident and nature = 'casse';
      elsif v_sort < 9 then
        update incidents_bouteille
           set statut = 'non_facture', resolu_le = v_date + interval '4 days', resolu_par = v_victoria
         where id = v_incident;
      else
        update incidents_bouteille
           set statut = 'client_contacte'
         where id = v_incident;
      end if;
    end loop;
  end loop;
end $$;

-- Deux commandes Purezza : une reçue, une en cours.
do $$
declare
  v_purezza uuid;
  v_miguel  uuid;
  v_cmd     uuid;
  v_type    uuid;
begin
  select id into v_purezza from fournisseurs where nom = 'Purezza';
  select id into v_miguel  from utilisateurs where nom = 'Miguel';
  if v_purezza is null then return; end if;

  insert into commandes (fournisseur_id, date_commande, montant_ht, montant_ttc, saisie_par)
  values (v_purezza, current_date - 45, 384.00, 460.80, v_miguel)
  returning id into v_cmd;
  for v_type in select id from bouteille_types loop
    insert into commande_lignes (commande_id, bouteille_type_id, quantite, prix_unitaire_ht)
    values (v_cmd, v_type, 24, 8.00);
  end loop;
  update commandes set statut = 'recue', recue_le = current_date - 38,
                       date_livraison = current_date - 38
   where id = v_cmd;

  insert into commandes (fournisseur_id, date_commande, statut, montant_ht, montant_ttc, saisie_par)
  values (v_purezza, current_date - 4, 'envoyee', 192.00, 230.40, v_miguel)
  returning id into v_cmd;
  insert into commande_lignes (commande_id, bouteille_type_id, quantite, prix_unitaire_ht)
  select v_cmd, id, 12, 8.00 from bouteille_types;
end $$;

commit;
