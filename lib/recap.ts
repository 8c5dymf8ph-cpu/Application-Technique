import { sql } from "./db";
import { viderLaFileEnFond } from "./envoi";
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

  // Les adresses se règlent depuis /administration, comme celles de l'alerte
  // bouteille. À défaut, celles des administrateurs inscrits — mais personne
  // n'a d'adresse dans `utilisateurs` tant qu'on ne l'y met pas, et rien ne le
  // signalait : le récapitulatif ne partait jamais en silence.
  const [destinataires] = await sql<{ liste: string[] }[]>`
    select coalesce(
      (select d.destinataires from alertes_destinataires d
        where d.evenement = ${categorie} and d.actif
          and cardinality(d.destinataires) > 0),
      (select coalesce(array_agg(u.email) filter (where u.email is not null), '{}')
         from utilisateurs u where u.role = 'admin' and u.actif)
    ) as liste`;
  /**
   * L'intervenant reçoit son propre récapitulatif de fin de passage.
   *
   * C'est le message « lot rendu » : ce qu'il déclare avoir fait. Miguel reste
   * destinataire — il est en copie de ce qui part, jamais court-circuité. Le
   * récapitulatif complet, lui, ne concerne que l'hôtel : il porte l'avis de
   * la gouvernante, y compris ce qu'elle n'a pas validé.
   */
  const sien = complet
    ? []
    : (
        await sql<{ email: string }[]>`
          select coalesce(u.email, p.email) as email
            from tournees t
            left join utilisateurs u on u.id = t.technicien_id
            left join prestataires p on p.id = t.prestataire_id
           where t.id = ${tournee}
             and coalesce(u.email, p.email) is not null`
      ).map((r) => r.email);

  destinataires.liste = [...new Set([...destinataires.liste, ...sien])];
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

  // Deux messages, deux moments : ils partent quand l'événement a lieu, pas
  // au prochain passage planifié.
  viderLaFileEnFond();

  // L'horodatage sur la tournée dit qu'elle n'attend plus son message.
  if (complet) {
    await sql`update tournees set mail_recap_envoye_le = now() where id = ${tournee}`;
  } else {
    await sql`update tournees set mail_technicien_envoye_le = now() where id = ${tournee}`;
  }
}

/** Le récapitulatif complet part dès que plus aucune ligne n'attend un avis. */
export async function deposerRecapSiComplet(tournee: string) {
  const [t] = await sql<{ prete: boolean; deja: string | null; reprise: boolean }[]>`
    select prete_pour_recap as prete, mail_recap_envoye_le as deja, reprise
    from v_tournees where id = ${tournee}`;
  // Un passage repris de l'ancienne application n'envoie rien : le travail a
  // eu lieu il y a des mois, et un récapitulatif arrivant aujourd'hui pour
  // avril ne se comprend pas. `v_tournees_a_recap` posait déjà la règle, mais
  // aucun code ne la lisait — donner un avis sur une ligne reprise aurait
  // suffi à déclencher le message.
  if (t?.prete && !t.deja && !t.reprise) await deposerRecap(tournee, true);
}
