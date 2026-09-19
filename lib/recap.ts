import { sql } from "./db";
import {
  corpsRecapTournee,
  objetRecapTournee,
  type LigneRecap,
  type Recap,
} from "./courriel";

/**
 * Mettre en file le récapitulatif d'une tournée.
 *
 * Appelée à deux moments : quand le technicien rend son lot, et quand la
 * gouvernante a tranché toutes ses lignes. Rien n'est envoyé ici — le message
 * est rédigé et déposé ; le service d'envoi vide la file.
 *
 * Un même message n'est jamais déposé deux fois : c'est la catégorie qui le
 * distingue, et la tournée qui l'identifie.
 */
export async function deposerRecap(tournee: string, complet: boolean, renvoi = false) {
  const categorie = complet ? "recap_intervention" : "recap_technicien";

  // Un même message n'est jamais déposé deux fois — sauf demande explicite :
  // « renvoyer » est une décision, elle se distingue d'un doublon accidentel.
  if (!renvoi) {
    const [deja] = await sql<{ n: number }[]>`
      select count(*)::int as n from emails_envoyes
      where reference_id = ${tournee} and categorie = ${categorie}`;
    if (deja.n > 0) return;
  }

  const [destinataires] = await sql<{ liste: string[] }[]>`
    select coalesce(array_agg(u.email) filter (where u.email is not null), '{}') as liste
    from utilisateurs u where u.role = 'admin' and u.actif`;
  if (destinataires.liste.length === 0) return;

  const [t] = await sql<
    {
      reference: string;
      intervenant: string | null;
      date_tournee: string;
      cout_total: number;
      cout_incomplet: boolean;
    }[]
  >`
    select reference, intervenant, date_tournee, cout_total,
           coalesce(cout_incomplet, false) as cout_incomplet
    from v_tournees where id = ${tournee}`;
  if (!t) return;

  const lignes = await sql<LigneRecap[]>`
    select r.emplacement, r.description,
           r.decision_technicien::text  as decision_technicien,
           r.commentaire_technicien,
           r.decision_gouvernante::text as decision_gouvernante,
           r.commentaire_gouvernante,
           (select string_agg(p.designation || ' × ' || abs(m.quantite), ', ')
              from mouvements_stock m join produits p on p.id = m.produit_id
             where m.intervention_id = r.intervention_id and m.type = 'sortie') as materiel,
           r.cout_total,
           coalesce(r.cout_incomplet, false) as cout_incomplet
    from v_recap_interventions r
    where r.tournee = ${t.reference}
    order by r.emplacement`;
  if (lignes.length === 0) return;

  const recap: Recap = { ...t, lignes };
  await sql`
    insert into emails_envoyes (categorie, reference_id, destinataires, sujet, corps)
    values (${categorie}, ${tournee}, ${destinataires.liste},
            ${objetRecapTournee(recap, complet)}, ${corpsRecapTournee(recap, complet)})`;

  // L'horodatage sur la tournée dit qu'elle n'attend plus son message.
  if (complet) {
    await sql`update tournees set mail_recap_envoye_le = now() where id = ${tournee}`;
  } else {
    await sql`update tournees set mail_technicien_envoye_le = now() where id = ${tournee}`;
  }
}

/** Le récapitulatif complet part dès que plus aucune ligne n'attend un avis. */
export async function deposerRecapSiComplet(tournee: string) {
  const [t] = await sql<{ prete: boolean; deja: string | null }[]>`
    select prete_pour_recap as prete, mail_recap_envoye_le as deja
    from v_tournees where id = ${tournee}`;
  if (t?.prete && !t.deja) await deposerRecap(tournee, true);
}
