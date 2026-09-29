-- Vérification (lecture seule, rien n'est modifié) de la note manuscrite de
-- la gouvernante du 11/05/2026 : « stock de 39 bleues et 40 rouges », six
-- chambres nommées, et « 128 € facturés depuis la dernière livraison mais
-- perte de 21 bouteilles, soit 136 € ». À jouer une requête à la fois dans
-- l'éditeur SQL de Supabase — il n'affiche que le résultat de la DERNIÈRE
-- requête d'un bloc, donc coller les cinq d'un coup ne montre que la
-- cinquième.
--
-- Conservé ici comme modèle : la même méthode (reconstituer une position à
-- une date passée à partir des mouvements, jamais lire une vue qui ne connaît
-- que l'instant présent) ressert à chaque rapprochement d'un relevé papier.

-- ---------------------------------------------------------------------------
-- 1. Le stock RECONSTITUÉ à une date donnée — pas le stock d'aujourd'hui.
--    Même logique que v_stock_bouteilles (réserve, chambre, chez le client,
--    parc détenu), mais en ne comptant que les mouvements survenus jusqu'à
--    cette date, et en écartant les chambres d'essai (06, 07) comme le fait
--    v_mouvements_bouteilles_reels. Remplacer la date au besoin.
-- ---------------------------------------------------------------------------
with mvt as (
  select m.*
    from mouvements_bouteilles m
    left join emplacements e_de   on e_de.id = m.de_emplacement_id
    left join emplacements e_vers on e_vers.id = m.vers_emplacement_id
   where not coalesce(e_de.essai, false)
     and not coalesce(e_vers.essai, false)
     and m.date_mouvement <= timestamptz '2026-05-11 23:59:59+02'
),
pos as (
  select m.bouteille_type_id, f.lieu, f.qte
    from mvt m
    cross join lateral (values
      (m.vers_lieu,  m.quantite),
      (m.de_lieu,   -m.quantite)
    ) as f (lieu, qte)
   where f.lieu <> 'hors_parc'
)
select bt.code,
       coalesce(sum(p.qte) filter (where p.lieu = 'reserve'), 0)                     as en_reserve,
       coalesce(sum(p.qte) filter (where p.lieu = 'emplacement'), 0)                 as en_chambre,
       coalesce(sum(p.qte) filter (where p.lieu = 'chez_client'), 0)                 as chez_clients,
       coalesce(sum(p.qte) filter (where p.lieu in ('reserve', 'emplacement')), 0)   as parc_detenu_a_la_date
  from bouteille_types bt
  left join pos p on p.bouteille_type_id = bt.id
 group by bt.code
 order by bt.code;

-- ---------------------------------------------------------------------------
-- 2. Les six situations nommées, chambre par chambre — pour voir si
--    l'application dit la même chose que la note.
-- ---------------------------------------------------------------------------
select e.code                                as chambre,
       i.reference,
       i.constate_le::date                   as constate_le,
       i.nature,
       i.responsable,
       i.statut,
       string_agg(bt.libelle, ' + ' order by bt.libelle) as bouteilles,
       i.montant,
       i.commentaire
  from incidents_bouteille i
  join emplacements e on e.id = i.emplacement_id
  join incident_lignes_bouteille li on li.incident_id = i.id
  join bouteille_types bt on bt.id = li.bouteille_type_id
 where e.code in ('18', '22', '42', '46', '48', '35')
   and i.constate_le::date between date '2026-04-01' and date '2026-05-11'
 group by e.code, i.id, i.reference, i.constate_le, i.nature, i.responsable,
          i.statut, i.montant, i.commentaire
 order by e.code, i.constate_le;

-- ---------------------------------------------------------------------------
-- 3. Ce qui reste ouvert AUJOURD'HUI, toutes chambres.
-- ---------------------------------------------------------------------------
select e.code                                as chambre,
       i.reference,
       i.constate_le::date                   as constate_le,
       i.statut,
       string_agg(bt.libelle, ' + ' order by bt.libelle) as bouteilles,
       i.commentaire
  from incidents_bouteille i
  join emplacements e on e.id = i.emplacement_id
  join incident_lignes_bouteille li on li.incident_id = i.id
  join bouteille_types bt on bt.id = li.bouteille_type_id
 where i.statut in ('signale', 'transmis', 'client_contacte')
 group by e.code, i.id, i.reference, i.constate_le, i.statut, i.commentaire
 order by i.constate_le;

-- ---------------------------------------------------------------------------
-- 4. Les dernières entrées enregistrées DANS L'APPLICATION jusqu'à une date
--    donnée. Ne montre jamais une livraison tenue sur papier avant la reprise
--    (~30/03/2026) : tout ce qui précède est absorbé dans le solde de départ.
-- ---------------------------------------------------------------------------
select m.date_mouvement::date as entree_le, bt.code, m.quantite, m.commentaire
  from mouvements_bouteilles m
  join bouteille_types bt on bt.id = m.bouteille_type_id
 where m.type = 'entree'
   and m.date_mouvement <= timestamptz '2026-05-11 23:59:59+02'
 order by m.date_mouvement desc
 limit 4;

-- ---------------------------------------------------------------------------
-- 5. Depuis la dernière entrée connue de l'application jusqu'à une date
--    donnée : ce qui a été FACTURÉ, ce qui est classé PERTE SÈCHE, et ce qui
--    reste OUVERT (donc ni l'un ni l'autre pour l'instant).
-- ---------------------------------------------------------------------------
with depuis as (
  select max(date_mouvement)::date as d
    from mouvements_bouteilles
   where type = 'entree' and date_mouvement <= timestamptz '2026-05-11 23:59:59+02'
)
select 'facture'    as categorie,
       count(*)     as nb_dossiers,
       sum(li.quantite)::int as nb_bouteilles,
       sum(i.montant)        as montant_total
  from incidents_bouteille i
  join incident_lignes_bouteille li on li.incident_id = i.id
  cross join depuis
 where i.statut = 'facture'
   and i.constate_le::date between depuis.d and date '2026-05-11'
union all
select 'non_facture (perte sèche)',
       count(distinct i.id),
       sum(li.quantite)::int,
       sum(coalesce(i.montant, 0))
  from incidents_bouteille i
  join incident_lignes_bouteille li on li.incident_id = i.id
  cross join depuis
 where i.statut = 'non_facture'
   and i.constate_le::date between depuis.d and date '2026-05-11'
union all
select 'ouvert (ni facturé ni classé perte)',
       count(distinct i.id),
       sum(li.quantite)::int,
       null
  from incidents_bouteille i
  join incident_lignes_bouteille li on li.incident_id = i.id
  cross join depuis
 where i.statut in ('signale', 'transmis', 'client_contacte')
   and i.constate_le::date between depuis.d and date '2026-05-11';
