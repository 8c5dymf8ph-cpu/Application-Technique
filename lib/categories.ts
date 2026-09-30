import { sql } from "./db";

/**
 * Le métier et le rayon d'un produit (`categorie`, `categorie_lieu`) sont du
 * texte libre depuis le début — la reprise a laissé « Salle de Bain » et
 * « Salle de bain » côte à côte, deux rayons pour un seul, et les écrans qui
 * les affichent regroupent déjà sans tenir compte de la casse. Ce qui
 * manquait, c'est d'empêcher une TROISIÈME graphie de naître la prochaine
 * fois qu'on crée ou corrige un produit.
 *
 * Réutilise la casse déjà enregistrée pour une valeur proche (insensible à
 * la casse), sinon garde ce qui vient d'être saisi — la même logique que la
 * reprise applique déjà aux noms d'intervenants (règle 16septies).
 *
 * L'exact prime sur l'insensible à la casse : si ce qui est saisi existe
 * DÉJÀ tel quel (le cas d'un select qu'on n'a pas touché, sur une ligne
 * restée dans sa casse minoritaire), on le garde — reformuler une valeur
 * qu'on n'a pas demandé de changer serait une correction non sollicitée, pas
 * une standardisation.
 */
export async function normaliserCategorie(
  colonne: "categorie" | "categorie_lieu",
  valeur: string | null,
): Promise<string | null> {
  if (!valeur) return null;
  const [existant] =
    colonne === "categorie"
      ? await sql<{ v: string }[]>`
          select categorie as v from produits
           where lower(categorie) = lower(${valeur})
           order by (categorie = ${valeur}) desc limit 1`
      : await sql<{ v: string }[]>`
          select categorie_lieu as v from produits
           where lower(categorie_lieu) = lower(${valeur})
           order by (categorie_lieu = ${valeur}) desc limit 1`;
  return existant?.v ?? valeur;
}

export type Categorie = { valeur: string; nombre: number };

/**
 * Garantit que la valeur EXACTE d'un produit reste dans la liste proposée,
 * même si elle n'est pas la graphie la plus fréquente (`categoriesExistantes`
 * n'en garde qu'une par groupe). Sans ça, un select de correction retombe sur
 * « — » pour toute ligne qui n'a pas « gagné » son groupe — et l'enregistrer
 * sans y toucher effacerait une catégorie qui n'avait rien de faux, juste une
 * casse minoritaire.
 *
 * La comparaison est volontairement SENSIBLE à la casse : une valeur qui ne
 * diffère de l'option existante que par une lettre doit apparaître comme sa
 * PROPRE option, pour que l'écart se voie et se corrige d'un choix plutôt
 * que de rester invisible dans une liste qui prétendrait déjà la contenir.
 */
export function avecValeurActuelle(choix: Categorie[], valeurActuelle: string | null): Categorie[] {
  if (!valeurActuelle) return choix;
  const dejaLa = choix.some((c) => c.valeur === valeurActuelle);
  return dejaLa ? choix : [...choix, { valeur: valeurActuelle, nombre: 1 }];
}

/**
 * Les métiers (ou les rayons) déjà employés, une fois par graphie — la plus
 * fréquente des variantes, comme `familles`/`metiers_filtre` le font déjà
 * pour les filtres de `/stock`. Sert à peupler le choix plutôt que de
 * ressaisir : une liste qui offrirait « Salle de Bain » ET « Salle de bain »
 * comme deux options ne standardiserait rien.
 */
export async function categoriesExistantes(colonne: "categorie" | "categorie_lieu"): Promise<Categorie[]> {
  return colonne === "categorie"
    ? sql<Categorie[]>`
        select (array_agg(t.categorie order by t.n desc))[1] as valeur, sum(t.n)::int as nombre
          from (select categorie, count(*)::int as n from produits
                 where categorie is not null group by categorie) t
         group by lower(t.categorie)
         order by nombre desc, valeur`
    : sql<Categorie[]>`
        select (array_agg(t.categorie_lieu order by t.n desc))[1] as valeur, sum(t.n)::int as nombre
          from (select categorie_lieu, count(*)::int as n from produits
                 where categorie_lieu is not null group by categorie_lieu) t
         group by lower(t.categorie_lieu)
         order by nombre desc, valeur`;
}
