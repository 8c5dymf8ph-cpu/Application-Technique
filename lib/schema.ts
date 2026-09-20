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
