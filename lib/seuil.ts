import { sql } from "./db";
import { viderLaFileEnFond } from "./envoi";
import { euros } from "./domaine";

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
  quantite_suggeree: number | null;
  /** Le plus bas jamais payé (`v_prix_produit`, règle 15bis) — pas pour l'exiger,
   *  mais pour que qui transmet sache d'emblée à quoi se comparer. */
  prix_min: number | null;
};

type FournisseurArticle = {
  nom: string;
  email: string | null;
  prefere: boolean;
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
           s.seuil_alerte::numeric as seuil, s.unite, pr.prix_min,
           coalesce(p.quantite_reappro,
                    greatest(p.seuil_alerte * 2 - s.stock, 1))::numeric
             as quantite_suggeree
      from v_stock_produits s
      join produits p on p.id = s.id
      left join v_prix_produit pr on pr.produit_id = s.id
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
    // Un article peut avoir plusieurs fournisseurs (règle 7) : chacun son
    // bloc, pour comparer avant de transmettre — le préféré en tête.
    const fournisseurs = await sql<FournisseurArticle[]>`
      select f.nom, f.email, af.prefere
        from article_fournisseurs af
        join fournisseurs f on f.id = af.fournisseur_id
       where af.produit_id = ${f.id} and f.actif
       order by af.prefere desc, f.nom`;
    await sql`
      insert into emails_envoyes (categorie, reference_id, destinataires, sujet, corps)
      values ('seuil_stock', ${f.id}, ${alerte.destinataires},
              ${objetSeuil(f)}, ${corpsSeuil(f, fournisseurs)})`;
  }
  // Comme l'alerte bouteille : le message part dans la foulée du dépôt, sans
  // faire attendre l'écran du technicien.
  viderLaFileEnFond();
}

export function objetSeuil(f: SousSeuil): string {
  return `[STOCK] ${f.designation} — ${f.stock} ${f.unite} en réserve`;
}

export function corpsSeuil(f: SousSeuil, fournisseurs: FournisseurArticle[]): string {
  const entete = [
    `${f.designation} (${f.code}) est passé sous son seuil.`,
    "",
    `En réserve : ${f.stock} ${f.unite}`,
    `Seuil d'alerte : ${f.seuil} ${f.unite}`,
    f.quantite_suggeree ? `À recommander : environ ${f.quantite_suggeree} ${f.unite}` : "",
    f.prix_min !== null ? `Prix HT le plus bas déjà payé : ${euros(f.prix_min)} l'unité` : "",
    fournisseurs.length > 0
      ? `Fournisseur${fournisseurs.length > 1 ? "s" : ""} enregistré${fournisseurs.length > 1 ? "s" : ""} : ` +
        fournisseurs.map((fo) => fo.nom).join(", ")
      : "Aucun fournisseur enregistré.",
    "",
    "Ce message est envoyé une fois par passage sous le seuil.",
    "Il repartira si l'article remonte puis redescend.",
  ].filter(Boolean);

  return [...entete, "", ...blocFournisseur(f, fournisseurs)].join("\n");
}

/**
 * Le bloc à transmettre au fournisseur — un par fournisseur enregistré.
 *
 * L'application n'écrit jamais directement au fournisseur — c'est Miguel qui
 * décide s'il commande et à qui. Mais rédiger le mail à chaque alerte est le
 * geste qu'on saute quand on est pressé, et le réapprovisionnement prend du
 * retard. Le bloc est donc déjà écrit, adressé, prêt à transférer tel quel —
 * il ne manque que le geste de transmettre.
 *
 * Un article peut avoir plusieurs fournisseurs (règle 7) : la consultation
 * part alors vers chacun, pour comparer — un seul bloc, avec un seul
 * destinataire, ne disait jamais qu'il y en avait d'autres. La référence et
 * le prix le plus bas déjà payé donnent de quoi négocier sans l'exiger —
 * même trame que la demande de devis (`lib/devis.ts`).
 */
function blocFournisseur(f: SousSeuil, fournisseurs: FournisseurArticle[]): string[] {
  if (fournisseurs.length === 0) {
    return [
      "— Aucun mail à transmettre —",
      "Aucun fournisseur n'est enregistré pour cet article : ajoutez-en un depuis sa " +
        "fiche (/stock) pour qu'un mail prêt à transmettre apparaisse ici la prochaine fois.",
    ];
  }

  const quantiteDemandee = f.quantite_suggeree
    ? ` pour environ ${f.quantite_suggeree} ${f.unite}`
    : "";
  const basePrix =
    f.prix_min !== null
      ? ` Nous avons précédemment acheté cet article à ${euros(f.prix_min)} HT l'unité : pourriez-vous ` +
        "nous confirmer si vous êtes en mesure de vous aligner sur ce tarif, ou nous faire votre " +
        "meilleure proposition ?"
      : " Pourriez-vous nous faire votre meilleure proposition de tarif ?";

  return fournisseurs.flatMap((fo, i) => [
    i > 0 ? "" : null,
    `————————— À transmettre${fo.prefere ? " (fournisseur préféré)" : ""} —————————`,
    fo.email ? `À : ${fo.nom} <${fo.email}>` : `À : ${fo.nom}`,
    `Objet : Réapprovisionnement — ${f.designation}`,
    "",
    "Bonjour,",
    "",
    `Notre stock de ${f.designation} (réf. ${f.code}) est descendu sous notre seuil habituel.` +
      ` Pourriez-vous nous indiquer votre délai de livraison${quantiteDemandee} ?` +
      basePrix,
    "",
    "Merci d'avance,",
    "L'Hôtel Parisianer",
    "—————————————————————————————————————————————————",
    !fo.email
      ? "(Aucune adresse enregistrée pour ce fournisseur : ajoutez-la sur sa fiche pour " +
        "ne plus avoir à la chercher.)"
      : null,
  ].filter((l): l is string => l !== null));
}
