import { sql } from "./db";
import { viderLaFileEnFond } from "./envoi";
import { colonneExiste } from "./schema";
import {
  corpsRecapTournee,
  corpsRecapTourneeHtml,
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

  /**
   * Un même message n'est jamais déposé deux fois — sauf demande explicite :
   * « renvoyer » est une décision, elle se distingue d'un doublon accidentel.
   *
   * Le doublon se juge sur la tournée, pas sur `emails_envoyes` : cette table
   * garde TOUT, y compris un message réellement parti pour un cycle déjà
   * clos — « ce qui est parti reste parti » (règle 10septies). Compter ses
   * lignes empêchait alors, pour toujours, le complément que la reprise
   * promet explicitement (« un complément suivra ») : `mail_recap_envoye_le`
   * / `mail_technicien_envoye_le` est la seule colonne que
   * `annulerRecap(Complet)NonParti` remet à nul quand un fait nouveau rouvre
   * le cycle, donc la seule à interroger ici.
   */
  if (!renvoi) {
    const [t0] = await sql<{ deja: string | null; deja_technicien: string | null }[]>`
      select mail_recap_envoye_le as deja, mail_technicien_envoye_le as deja_technicien
      from tournees where id = ${tournee}`;
    if (complet ? t0?.deja : t0?.deja_technicien) return;
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
  // Le code part en ligne avant la migration 0035 : tant que la colonne
  // n'existe pas encore, on écrit sans elle plutôt que de casser le dépôt.
  if (await colonneExiste("emails_envoyes", "corps_html")) {
    await sql`
      insert into emails_envoyes (categorie, reference_id, destinataires, sujet, corps, corps_html)
      values (${categorie}, ${tournee}, ${destinataires.liste},
              ${objetRecapTournee(recap, complet)}, ${corpsRecapTournee(recap, complet)},
              ${corpsRecapTourneeHtml(recap, complet)})`;
  } else {
    await sql`
      insert into emails_envoyes (categorie, reference_id, destinataires, sujet, corps)
      values (${categorie}, ${tournee}, ${destinataires.liste},
              ${objetRecapTournee(recap, complet)}, ${corpsRecapTournee(recap, complet)})`;
  }

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

/**
 * Reprendre un passage rendu par erreur.
 *
 * On appuie sur « Fin d'intervention » avec deux anomalies sur douze — et le
 * récapitulatif annonce deux. Le passage, lui, n'est pas fini : c'est la même
 * journée, donc le même lot (règle 16).
 *
 * Ce qui n'est pas parti s'efface : un message en file n'est pas un message
 * envoyé, et le supprimer ne cache rien. Ce qui EST parti reste parti — on ne
 * le retire pas de l'horodatage, ce serait prétendre qu'il n'a pas eu lieu ;
 * le passage rendu à nouveau enverra alors un complément.
 *
 * Rend `true` si le message a pu être retiré de la file avant son départ.
 */
export async function annulerRecapNonParti(tournee: string): Promise<boolean> {
  const effaces = await sql<{ id: string }[]>`
    delete from emails_envoyes
     where reference_id = ${tournee}
       and categorie = 'recap_technicien'
       and envoye_le is null
    returning id`;

  // Un message réellement parti n'est jamais effacé — sa ligne reste, pour
  // de bon. Mais que quelque chose soit déjà parti ou non pour ce cycle, ce
  // cycle est rouvert : l'horodatage de la TOURNÉE, lui, se remet à nul dans
  // tous les cas, sinon `deposerRecap` refuserait pour toujours le
  // complément qu'elle promet (« à la fin de la journée, un complément
  // suivra »).
  const [parti] = await sql<{ n: number }[]>`
    select count(*)::int as n from emails_envoyes
     where reference_id = ${tournee} and categorie = 'recap_technicien' and envoye_le is not null`;
  await sql`update tournees set mail_technicien_envoye_le = null where id = ${tournee}`;
  return effaces.length > 0 && parti.n === 0;
}

/**
 * Le même geste, pour le récapitulatif complet — celui de la gouvernante.
 *
 * Une reprise après refus (migration 0033) rouvre une anomalie déjà
 * récapitulée : « à refaire » y figurait, mais ce que la gouvernante en
 * décide maintenant est un fait nouveau. `deposerRecap` refuse pourtant un
 * second dépôt pour la même tournée — c'est voulu, contre un double envoi
 * accidentel — et poser `mail_recap_envoye_le` à nul sans toucher à
 * `emails_envoyes` ne suffit donc pas : le message déjà déposé (part cette
 * fois ou non) bloque toujours le suivant. Mêmes règles qu'au-dessus : ce
 * qui n'est pas parti s'efface, ce qui EST parti reste parti.
 */
export async function annulerRecapCompletNonParti(tournee: string): Promise<boolean> {
  const effaces = await sql<{ id: string }[]>`
    delete from emails_envoyes
     where reference_id = ${tournee}
       and categorie = 'recap_intervention'
       and envoye_le is null
    returning id`;

  // Même geste que `annulerRecapNonParti` : l'historique d'un envoi réel ne
  // bouge pas, mais l'horodatage de la tournée se remet à nul dans tous les
  // cas, pour que le complément promis par la reprise reste possible.
  const [parti] = await sql<{ n: number }[]>`
    select count(*)::int as n from emails_envoyes
     where reference_id = ${tournee} and categorie = 'recap_intervention' and envoye_le is not null`;
  await sql`update tournees set mail_recap_envoye_le = null where id = ${tournee}`;
  return effaces.length > 0 && parti.n === 0;
}
