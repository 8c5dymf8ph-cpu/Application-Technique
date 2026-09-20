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
