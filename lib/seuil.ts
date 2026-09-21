import { sql } from "./db";
import { viderLaFileEnFond } from "./envoi";

/**
 * L'alerte « produit sous le seuil ».
 *
 * Le réglage existait dans `/administration` depuis le début — on pouvait y
 * noter des adresses, l'activer, la désactiver — mais **rien n'avait jamais
 * déposé un seul message** : aucune ligne de code ne déclenchait cette
 * catégorie. Un réglage qui ne commande rien est pire qu'un réglage absent :
 * on le règle et on attend.
 *
 * L'alerte part quand une sortie de stock fait passer un article sous son
 * seuil. Elle ne se répète pas tant qu'il y reste : sinon chaque sortie d'un
 * article durablement bas renverrait un message, et on cesserait de les lire.
 * Elle repart quand l'article est remonté puis redescendu.
 */

type SousSeuil = {
  id: string;
  designation: string;
  code: string;
  stock: number;
  seuil: number;
  unite: string;
  fournisseur: string | null;
  quantite_suggeree: number | null;
};

/**
 * Prévenir si des articles viennent de passer sous leur seuil.
 *
 * On ne regarde que les articles touchés par le mouvement : parcourir tout le
 * catalogue à chaque sortie de matériel coûterait pour rien.
 */
export async function alerterSiSousSeuil(produits: string[]): Promise<void> {
  if (produits.length === 0) return;

  const [alerte] = await sql<{ destinataires: string[]; actif: boolean }[]>`
    select destinataires, actif from alertes_destinataires
    where evenement = 'seuil_stock'`;
  if (!alerte?.actif || alerte.destinataires.length === 0) return;

  // Sous le seuil, et pas déjà signalé depuis la dernière remontée. La trace
  // est le message lui-même : `reference_id` porte le produit.
  const franchis = await sql<SousSeuil[]>`
    select s.id, s.designation, s.code, s.stock::numeric as stock,
           s.seuil_alerte::numeric as seuil, s.unite, s.fournisseur,
           coalesce(p.quantite_reappro,
                    greatest(p.seuil_alerte * 2 - s.stock, 1))::numeric
             as quantite_suggeree
      from v_stock_produits s
      join produits p on p.id = s.id
     where s.id = any(${produits})
       and s.actif
       and s.stock <= s.seuil_alerte
       and not exists (
         select 1 from emails_envoyes e
          where e.categorie = 'seuil_stock'
            and e.reference_id = s.id
            -- Un message déjà déposé pour CE passage sous le seuil : on ne le
            -- redouble pas. Une entrée de stock efface la trace (plus bas).
            and e.cree_le > coalesce(
              (select max(m.date_mouvement) from mouvements_stock m
                where m.produit_id = s.id and m.type = 'entree'),
              'epoch'::timestamptz))`;

  if (franchis.length === 0) return;

  for (const f of franchis) {
    await sql`
      insert into emails_envoyes (categorie, reference_id, destinataires, sujet, corps)
      values ('seuil_stock', ${f.id}, ${alerte.destinataires},
              ${objetSeuil(f)}, ${corpsSeuil(f)})`;
  }
  // Comme l'alerte bouteille : le message part dans la foulée du dépôt, sans
  // faire attendre l'écran du technicien.
  viderLaFileEnFond();
}

export function objetSeuil(f: SousSeuil): string {
  return `[STOCK] ${f.designation} — ${f.stock} ${f.unite} en réserve`;
}

export function corpsSeuil(f: SousSeuil): string {
  return [
    `${f.designation} (${f.code}) est passé sous son seuil.`,
    "",
    `En réserve : ${f.stock} ${f.unite}`,
    `Seuil d'alerte : ${f.seuil} ${f.unite}`,
    f.quantite_suggeree ? `À recommander : environ ${f.quantite_suggeree} ${f.unite}` : "",
    f.fournisseur ? `Fournisseur habituel : ${f.fournisseur}` : "Aucun fournisseur enregistré.",
    "",
    "Ce message est envoyé une fois par passage sous le seuil.",
    "Il repartira si l'article remonte puis redescend.",
  ]
    .filter(Boolean)
    .join("\n");
}
