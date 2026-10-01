-- =============================================================================
-- Migration 0030 : le catalogue se fusionne, et son compte de popularité
-- redevient vrai
-- =============================================================================
-- Deux défauts trouvés en préparant le chantier de standardisation des
-- libellés (« je ne veux pas plus de 3/4 propositions pour "télérupteur" »).
--
-- 1. `catalogue_anomalies.occurrences` est posé UNE FOIS, à l'import
--    (`generer_catalogue.py` compte les lignes de l'export), et n'a jamais
--    été incrémenté depuis : une déclaration faite depuis l'application ne
--    change jamais ce chiffre. `fn_rechercher_catalogue` trie dessus et
--    l'affiche (« vu N fois dans l'hôtel ») — les libellés nés ou devenus
--    courants après le lancement ne remontent jamais en tête, et le nombre
--    affiché est faux dès le premier jour d'usage réel. Rien n'est stocké
--    ailleurs dans l'application pour ce qui se compte (règle 1) ; ce
--    comptage ne doit pas faire exception. `fn_rechercher_catalogue` compte
--    désormais en direct, sur `anomalies.catalogue_id` — ce qui compte aussi
--    bien l'historique repris que ce qui vient d'être déclaré.
--
-- 2. Rien ne permet de fusionner deux libellés qui disent la même chose avec
--    des mots différents : un catalogue qui ne peut que grossir (règle 9bis)
--    finit par proposer quatre graphies pour « télérupteur à changer » alors
--    qu'il n'y a que deux vraies réponses (spots/LED, appliques). La
--    normalisation à l'import ne lisse que la casse et les accents
--    (`generer_catalogue.py`) ; elle ne peut pas deviner que deux phrases
--    différentes désignent le même geste — c'est un jugement humain, pas un
--    algorithme.
--
--    `fn_fusionner_catalogue` fait ce qu'un admin déciderait à la main :
--    toutes les anomalies des libellés fusionnés rejoignent le libellé
--    survivant — avec SON libellé en description, pour que la rédaction
--    devienne identique — et les libellés fusionnés sont retirés du choix
--    (`actif = false`) sans être supprimés, comme un produit retiré
--    (règle 14ter) : leur historique, lui, ne bouge pas de nature, il
--    change seulement de nom pour que le prochain comptage tombe juste.
--
--    Le type (métier) n'est touché que là où il manque : une anomalie dont
--    le métier a déjà été corrigé à la main (règle du métier d'une anomalie)
--    garde ce choix plutôt que de se faire écraser par celui du survivant.
--
--    Réservé à ceux qui peuvent déjà enrichir le catalogue (règle 9bis,
--    `fn_peut_enrichir_le_catalogue`) : fusionner deux libellés, c'est
--    corriger le catalogue, pas un geste de terrain.
-- =============================================================================

create or replace function fn_rechercher_catalogue(p_terme text default null)
returns setof catalogue_anomalies
language sql stable as $$
  select c.id, c.libelle, c.mots_cles, c.type_id,
         (select count(*)::int from anomalies a where a.catalogue_id = c.id) as occurrences,
         c.actif, c.cree_par, c.cree_le
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
   order by (select count(*) from anomalies a where a.catalogue_id = c.id) desc, c.libelle;
$$;

create function fn_fusionner_catalogue(p_survivant uuid, p_autres uuid[])
returns int
language plpgsql as $$
declare
  v_libelle text;
  v_type_id uuid;
  v_n       int;
begin
  if not fn_peut_enrichir_le_catalogue() then
    raise exception 'Fusionner le catalogue est réservé à ceux qui peuvent l''enrichir';
  end if;

  select libelle, type_id into v_libelle, v_type_id
    from catalogue_anomalies where id = p_survivant and actif;
  if v_libelle is null then
    raise exception 'Le libellé survivant est introuvable ou retiré';
  end if;

  with maj as (
    update anomalies
       set catalogue_id = p_survivant,
           description   = v_libelle,
           -- Un métier déjà posé à la main reste : seul celui qui manque se
           -- comble avec celui du survivant.
           type_id        = coalesce(type_id, v_type_id),
           maj_le         = now()
     where catalogue_id = any(p_autres)
    returning 1
  )
  select count(*) into v_n from maj;

  update catalogue_anomalies set actif = false where id = any(p_autres);

  return v_n;
end;
$$;

comment on function fn_fusionner_catalogue(uuid, uuid[]) is
  $$Fusionne p_autres dans p_survivant : les anomalies suivent, avec la description et (si absent) le type du survivant ; p_autres sont retirés du catalogue sans être supprimés. Réservé à fn_peut_enrichir_le_catalogue().$$;
