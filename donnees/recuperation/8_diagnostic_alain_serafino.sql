-- Diagnostic : pourquoi Alain et Serafino — des entreprises extérieures
-- d'après outils/equipe.py — ne peuvent pas recevoir de facture.
--
-- Deux hypothèses, cette requête les départage :
-- 1. Ils n'existent que dans `utilisateurs` (jamais créés comme
--    `prestataires`, ou créés puis effacés) : ils comptent alors comme
--    salariés, et `emet_des_factures` est resté à false. Le réglage
--    « Facture ses passages », ajouté dans /administration/equipe, suffit.
-- 2. Ils existent dans LES DEUX tables : `v_intervenants` les affiche deux
--    fois, et selon celle que l'écran montre, on peut croire que le bon
--    chemin (le `prestataires`, qui facture toujours) n'existe pas.
--
-- Ne modifie rien. À jouer dans l'éditeur SQL de Supabase.

select 'utilisateurs' as table_, id::text, nom, role::text, intervient_technique,
       emet_des_factures, actif
  from utilisateurs where nom in ('Alain', 'Serafino')
union all
select 'prestataires', id::text, nom, null, null, null, actif
  from prestataires where nom in ('Alain', 'Serafino')
order by 2, 1;
