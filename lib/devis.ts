import { sql } from "./db";
import { viderLaFileEnFond } from "./envoi";
import { euros } from "./domaine";

/**
 * La demande de devis, pour UNE bouteille, sur demande.
 *
 * Le schéma porte `demandes_devis` / `demande_devis_lignes` depuis le début —
 * pensés pour regrouper tous les articles d'un même fournisseur, un seul mail
 * chacun (règle 7) — mais rien ne les remplit jamais : `fn_preparer_demandes_devis`
 * n'était appelée nulle part. Plutôt que de rouvrir tout ce mécanisme pour un
 * geste ponctuel, cette fonction dépose directement dans `emails_envoyes`,
 * comme `alerterSiSousSeuil` le fait déjà pour le matériel — même schéma,
 * même chemin d'envoi, mais adressé AU fournisseur (pas seulement un bloc
 * prêt à transmettre) : c'est la demande elle-même qui part.
 *
 * Un article peut avoir plusieurs fournisseurs (règle 7) : un mail par
 * fournisseur lié, pour comparer.
 */

type Fournisseur = {
  id: string;
  nom: string;
  email: string | null;
  email_2: string | null;
};

export type ResultatDevis = {
  envoyes: { fournisseur: string }[];
  sansAdresse: { fournisseur: string }[];
};

export async function demanderDevisBouteille(bouteilleTypeId: string): Promise<ResultatDevis | null> {
  const [bouteille] = await sql<
    { libelle: string; en_reserve: number; seuil_alerte: number; quantite_reappro: number | null }[]
  >`
    select bt.libelle, s.en_reserve::int, bt.seuil_alerte, bt.quantite_reappro
      from bouteille_types bt
      join v_stock_bouteilles s on s.bouteille_type_id = bt.id
     where bt.id = ${bouteilleTypeId}`;
  if (!bouteille) return null;

  const fournisseurs = await sql<Fournisseur[]>`
    select f.id, f.nom, f.email, f.email_2
      from article_fournisseurs af
      join fournisseurs f on f.id = af.fournisseur_id
     where af.bouteille_type_id = ${bouteilleTypeId} and f.actif
     order by af.prefere desc, f.nom`;

  const resultat: ResultatDevis = { envoyes: [], sansAdresse: [] };
  const quantite = bouteille.quantite_reappro ?? bouteille.seuil_alerte * 2;

  for (const f of fournisseurs) {
    const destinataires = [f.email, f.email_2].filter((e): e is string => !!e);
    if (destinataires.length === 0) {
      resultat.sansAdresse.push({ fournisseur: f.nom });
      continue;
    }
    await sql`
      insert into emails_envoyes (categorie, reference_id, destinataires, sujet, corps)
      values ('devis', ${bouteilleTypeId}, ${destinataires},
              ${`Demande de devis — ${bouteille.libelle}`},
              ${corpsDevis(bouteille.libelle, bouteille.en_reserve, quantite)})`;
    resultat.envoyes.push({ fournisseur: f.nom });
  }

  if (resultat.envoyes.length > 0) viderLaFileEnFond();
  return resultat;
}

function corpsDevis(libelle: string, enReserve: number, quantite: number): string {
  return [
    "Bonjour,",
    "",
    `Pourriez-vous nous indiquer votre délai et votre tarif pour une commande de ${libelle} ` +
      `— environ ${quantite} bouteilles ?`,
    "",
    `Notre réserve actuelle : ${enReserve} bouteilles.`,
    "",
    "Merci d'avance,",
    "L'Hôtel Parisianer",
  ].join("\n");
}

/**
 * La demande de devis, pour UN produit du stock technique — même mécanisme
 * que `demanderDevisBouteille` (dépôt direct dans `emails_envoyes`, un mail
 * par fournisseur lié, règle 7).
 *
 * Le mail rappelle le prix le plus bas déjà obtenu (`v_prix_produit.prix_min`,
 * règle 15bis : le prix payé se lit dans les mouvements) — pas pour l'exiger,
 * mais pour que le fournisseur sache d'emblée à quoi se comparer, plutôt que
 * de repartir d'une proposition plus haute que ce qu'on a déjà payé.
 */
export async function demanderDevisProduit(produitId: string): Promise<ResultatDevis | null> {
  const [produit] = await sql<
    { designation: string; stock: number; seuil_alerte: number; quantite_reappro: number | null;
      prix_min: number | null }[]
  >`
    select p.designation, s.stock::numeric, p.seuil_alerte, p.quantite_reappro, pr.prix_min
      from produits p
      join v_stock_produits s on s.id = p.id
      left join v_prix_produit pr on pr.produit_id = p.id
     where p.id = ${produitId}`;
  if (!produit) return null;

  const fournisseurs = await sql<Fournisseur[]>`
    select f.id, f.nom, f.email, f.email_2
      from article_fournisseurs af
      join fournisseurs f on f.id = af.fournisseur_id
     where af.produit_id = ${produitId} and f.actif
     order by af.prefere desc, f.nom`;

  const resultat: ResultatDevis = { envoyes: [], sansAdresse: [] };
  const quantite = produit.quantite_reappro ?? Math.max(produit.seuil_alerte * 2, 1);

  for (const f of fournisseurs) {
    const destinataires = [f.email, f.email_2].filter((e): e is string => !!e);
    if (destinataires.length === 0) {
      resultat.sansAdresse.push({ fournisseur: f.nom });
      continue;
    }
    await sql`
      insert into emails_envoyes (categorie, reference_id, destinataires, sujet, corps)
      values ('devis', ${produitId}, ${destinataires},
              ${`Demande de devis — ${produit.designation}`},
              ${corpsDevisProduit(produit.designation, quantite, produit.prix_min)})`;
    resultat.envoyes.push({ fournisseur: f.nom });
  }

  if (resultat.envoyes.length > 0) viderLaFileEnFond();
  return resultat;
}

function corpsDevisProduit(designation: string, quantite: number, prixMin: number | null): string {
  return [
    "Bonjour,",
    "",
    `Pourriez-vous nous indiquer votre délai et votre tarif pour une commande de ${designation} ` +
      `— environ ${quantite} unités ?`,
    ...(prixMin !== null
      ? ["", `Le tarif le plus bas obtenu jusqu'ici pour cet article était de ${euros(prixMin)} l'unité.`]
      : []),
    "",
    "Merci d'avance,",
    "L'Hôtel Parisianer",
  ].join("\n");
}
