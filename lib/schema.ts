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
const connues = new Map<string, boolean>();

export async function colonneExiste(table: string, colonne: string): Promise<boolean> {
  const cle = `${table}.${colonne}`;
  const deja = connues.get(cle);
  if (deja !== undefined) return deja;

  const [r] = await sql<{ presente: boolean }[]>`
    select count(*) > 0 as presente
      from information_schema.columns
     where table_schema = 'public'
       and table_name = ${table}
       and column_name = ${colonne}`;
  connues.set(cle, r.presente);
  return r.presente;
}
