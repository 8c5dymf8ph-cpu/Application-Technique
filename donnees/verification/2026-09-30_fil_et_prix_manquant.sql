-- Deux points restés ouverts après la session du 29-30/09/2026, à vérifier
-- ensemble avant d'aller plus loin — je ne peux pas les lire moi-même, je
-- n'ai pas d'accès direct à la base de production.
--
-- À jouer une requête à la fois dans l'éditeur SQL de Supabase — il
-- n'affiche que le résultat de la DERNIÈRE requête d'un bloc.

-- ---------------------------------------------------------------------------
-- 1. D'où vient EXACTEMENT le mot affiché dans la bulle du fil de
--    l'anomalie 832 (et, pour comparer, 823 et 839) : la table
--    `commentaires` (un mot écrit par quelqu'un) ou `validations`
--    (un avis de décision, sans texte en principe pour une reprise) ?
--    Si la ligne montre une provenance='commentaires' pour la 832 avec un
--    texte, c'est une donnée réellement en base — reste à savoir si elle
--    vient d'une COMMENTAIRES non vide dans l'export original, ou d'ailleurs.
-- ---------------------------------------------------------------------------
select a.sharepoint_id, 'commentaires' as provenance, c.origine, c.texte,
       u.nom as auteur, c.ecrit_le
  from commentaires c
  join anomalies a on a.id = c.anomalie_id
  left join utilisateurs u on u.id = c.auteur_id
 where a.sharepoint_id in (823, 832, 839)
union all
select a.sharepoint_id, 'validations' as provenance, v.acteur::text, v.commentaire,
       coalesce(u.nom, p.nom), v.decide_le
  from validations v
  join interventions i on i.id = v.intervention_id
  join anomalies a on a.id = i.anomalie_id
  left join utilisateurs u on u.id = v.utilisateur_id
  left join prestataires p on p.id = v.utilisateur_id
 where a.sharepoint_id in (823, 832, 839)
 order by 1, 6;

-- ---------------------------------------------------------------------------
-- 2. L'entrée du 02/01/2026 (Miguel, +5) sur la batterie NI-Cd : porte-t-elle
--    bien un prix ? Si prix_unitaire est NULL alors que facture_id ne l'est
--    pas, c'est qu'une facture a été jointe (au crayon, sans doute) SANS
--    ressaisir le prix à ce moment-là — v_achats_produit exige les deux, et
--    c'est pour ça qu'elle manque dans « Le prix ». Repasser par le crayon
--    et remplir le prix suffira à la faire réapparaître.
-- ---------------------------------------------------------------------------
select m.id, m.date_mouvement, m.quantite, m.prix_unitaire, m.facture_id,
       fa.reference, fa.fichier_url, fa.fournisseur_id
  from mouvements_stock m
  join produits pr on pr.id = m.produit_id
  left join factures fa on fa.id = m.facture_id
 where pr.code = 'NI-Cd 2,4V 1,5AH (URA)'
   and m.type = 'entree'
   and m.date_mouvement::date = date '2026-01-02'
   and m.quantite = 5;
