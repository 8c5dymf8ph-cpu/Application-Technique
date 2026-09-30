-- Diagnostic avant le chantier de standardisation — ne modifie rien.
-- À jouer une requête à la fois dans l'éditeur SQL de Supabase.

-- ---------------------------------------------------------------------------
-- 1. Les catégories de produits (categorie / categorie_lieu) qui ne
--    diffèrent que par la casse ou les accents — ce sont les mêmes rangs
--    pour l'utilisateur, mais deux lignes pour la base.
-- ---------------------------------------------------------------------------
select 'categorie' as colonne, lower(categorie) as version_normalisee,
       array_agg(distinct categorie order by categorie) as variantes,
       count(distinct categorie) as nb_variantes
  from produits
 where categorie is not null
 group by lower(categorie)
having count(distinct categorie) > 1
union all
select 'categorie_lieu', lower(categorie_lieu),
       array_agg(distinct categorie_lieu order by categorie_lieu),
       count(distinct categorie_lieu)
  from produits
 where categorie_lieu is not null
 group by lower(categorie_lieu)
having count(distinct categorie_lieu) > 1;

-- ---------------------------------------------------------------------------
-- 2. Des noms d'intervenants, fournisseurs ou prestataires qui ne diffèrent
--    que par la casse — une contrainte `unique` actuelle ne les empêche pas
--    de coexister comme deux personnes différentes.
-- ---------------------------------------------------------------------------
select 'utilisateurs' as table_, lower(nom) as version_normalisee,
       array_agg(nom order by nom) as variantes
  from utilisateurs group by lower(nom) having count(*) > 1
union all
select 'fournisseurs', lower(nom), array_agg(nom order by nom)
  from fournisseurs group by lower(nom) having count(*) > 1
union all
select 'prestataires', lower(nom), array_agg(nom order by nom)
  from prestataires group by lower(nom) having count(*) > 1;

-- ---------------------------------------------------------------------------
-- 3. Les mouvements de stock orphelins au commentaire synthétique
--    (« Intervention — … ») — reliquats d'anomalies supprimées AVANT la
--    migration 0022, qui détachait le mouvement au lieu de l'emporter.
--    Juste pour mesurer l'ampleur : combien, sur quels produits, sur
--    quelle période.
-- ---------------------------------------------------------------------------
select count(*) as nb_lignes,
       count(distinct produit_id) as nb_produits,
       min(date_mouvement)::date as plus_ancien,
       max(date_mouvement)::date as plus_recent
  from mouvements_stock
 where type = 'sortie' and intervention_id is null
   and commentaire like 'Intervention — %';
