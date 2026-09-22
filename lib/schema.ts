import { sql } from "./db";

/**
 * Ce que la base porte déjà.
 *
 * Le code part en ligne dès qu'il est poussé ; une migration, elle, s'applique
 * à la main. Entre les deux, l'application tourne sur un schéma plus ancien que
 * le code — et une requête qui nomme une colonne absente ne renvoie pas une
 * liste vide : elle casse l'écran. C'est arrivé sur la fiche produit et sur les
 * commandes de bouteilles.
 *
 * On demande donc à la base ce qu'elle a, une fois, et on s'adapte.
 */
/**
 * On ne retient que les réponses POSITIVES.
 *
 * Une colonne qui existe n'est jamais retirée : la retenir est sans risque.
 * Retenir une absence, en revanche, rend l'application aveugle à la migration
 * qui vient de l'ajouter — l'écran continue de dire « en attente » alors que la
 * base est à jour, jusqu'au redémarrage du serveur. C'est exactement ce qui est
 * arrivé après la migration 0010.
 */
const presentes = new Set<string>();

export async function colonneExiste(table: string, colonne: string): Promise<boolean> {
  const cle = `${table}.${colonne}`;
  if (presentes.has(cle)) return true;

  const [r] = await sql<{ presente: boolean }[]>`
    select count(*) > 0 as presente
      from information_schema.columns
     where table_schema = 'public'
       and table_name = ${table}
       and column_name = ${colonne}`;
  if (r.presente) presentes.add(cle);
  return r.presente;
}

/**
 * Une règle de sécurité porte-t-elle déjà ce mot ?
 *
 * Certaines migrations ne posent pas de colonne : la 0011 réécrit seulement
 * `fn_peut_supprimer` pour y ajouter la gouvernante. `colonneExiste` ne peut
 * rien en dire. On lit donc la définition de la fonction — et comme pour les
 * colonnes, on ne retient que les réponses positives : une règle appliquée ne
 * se retire pas, une absence retenue rendrait l'écran aveugle à la migration
 * qui vient de l'appliquer.
 */
export async function regleContient(fonction: string, mot: string): Promise<boolean> {
  const cle = `fn:${fonction}:${mot}`;
  if (presentes.has(cle)) return true;

  const [r] = await sql<{ presente: boolean }[]>`
    select count(*) > 0 as presente
      from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.proname = ${fonction}
       and p.prosrc like ${"%" + mot + "%"}`;
  if (r.presente) presentes.add(cle);
  return r.presente;
}

/**
 * Cette vue est-elle déjà là ?
 *
 * Certaines migrations ne posent ni colonne ni règle : la 0013 réécrit les
 * vues de stock et de coût pour écarter les lieux d'essai, et pose
 * `v_mouvements_reels`. Son existence suffit à dire que la base sait déjà ne
 * pas compter un essai. Même prudence que plus haut : on ne retient que les
 * réponses positives.
 */
export async function vueExiste(vue: string): Promise<boolean> {
  const cle = `vue:${vue}`;
  if (presentes.has(cle)) return true;

  const [r] = await sql<{ presente: boolean }[]>`
    select count(*) > 0 as presente
      from information_schema.views
     where table_schema = 'public' and table_name = ${vue}`;
  if (r.presente) presentes.add(cle);
  return r.presente;
}

/**
 * Cette vue porte-t-elle déjà cette condition ?
 *
 * Certaines migrations ne posent rien de nouveau : la 0016 se contente de
 * réécrire `v_tournees` pour ne plus compter comme « à valider » ce que
 * personne n'attend. `vueExiste` répond oui avant comme après. On lit donc sa
 * définition. Même prudence : on ne retient que les réponses positives.
 */
export async function vueContient(vue: string, mot: string): Promise<boolean> {
  const cle = `vue:${vue}:${mot}`;
  if (presentes.has(cle)) return true;

  const [r] = await sql<{ presente: boolean }[]>`
    select count(*) > 0 as presente
      from pg_views
     where schemaname = 'public' and viewname = ${vue}
       and definition like ${"%" + mot + "%"}`;
  if (r.presente) presentes.add(cle);
  return r.presente;
}

/**
 * Le recalage de reprise a-t-il été retiré ?
 *
 * La 0017 ne pose ni colonne, ni règle, ni vue : elle efface des données —
 * les vingt-deux régularisations qui visaient le stock affiché par l'ancienne
 * application. La capacité se lit donc à une ABSENCE.
 *
 * On peut la retenir quand même, et pour la même raison que les autres : une
 * fois l'inventaire de reprise effacé, rien ne le recrée. C'est la réponse
 * « pas encore fait » qu'il ne faut jamais garder.
 */
export async function inventaireDeRepriseRetire(): Promise<boolean> {
  const cle = "inventaire:reprise:retire";
  if (presentes.has(cle)) return true;

  const [r] = await sql<{ retire: boolean }[]>`
    select not exists (
      select 1 from inventaires
       where id = 'cccccccc-0000-0000-0000-000000000001') as retire`;
  if (r.retire) presentes.add(cle);
  return r.retire;
}
