/**
 * Les courriels de l'application.
 *
 * Rien n'est envoyé d'ici : ces fonctions produisent le texte. L'envoi partira
 * du digest du soir ou de l'alerte immédiate, et toujours vers l'interne —
 * jamais vers un client, jamais depuis le téléphone de la gouvernante.
 */

export type LigneBouteille = {
  code: string;
  libelle: string;
  quantite: number;
  prix: number;
};

export type DossierBouteille = {
  reference: number;
  emplacement: string;
  client_nom: string | null;
  constate_par: string | null;
  transmis_a: string | null;
  constate_le: string;
  lignes: LigneBouteille[];
  montant: number;
};

const eur = (n: number) =>
  Number(n).toLocaleString("fr-FR", { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + "€";

const jour = (d: string) => new Date(d).toLocaleDateString("fr-FR");

/** « Bouteille filtrée », « Bouteille gazeuse » — le mot de l'hôtel. */
function nomCourt(l: LigneBouteille): string {
  return "Bouteille " + l.libelle.replace(/^Eau\s+/i, "").toLowerCase();
}

export function objetAlerteBouteille(d: DossierBouteille): string {
  return `[A ENVOYER CLIENT] Bouteille(s) Purezza manquante(s) — Chambre ${d.emplacement}`;
}

/**
 * Le corps du mail, tel qu'il part à la réception.
 *
 * C'est la réception qui écrit au client : le message est donc rédigé prêt à
 * être transféré, en français puis en anglais, avec en tête les trois lignes qui
 * disent d'où il sort — qui a constaté, à qui c'est remonté, quand.
 */
export function corpsAlerteBouteille(d: DossierBouteille): string {
  const detail = d.lignes
    .map((l) => `${nomCourt(l)} : ${l.quantite > 1 ? `Oui (${l.quantite})` : "Oui"}`)
    .join("\n");

  // Le prix unitaire n'est rappelé que s'il est le même pour toutes les lignes :
  // annoncer « 17,50€ l'unité » quand deux tarifs coexistent serait faux.
  const prix = [...new Set(d.lignes.map((l) => Number(l.prix)))];
  const phrasePrix =
    prix.length === 1
      ? `Conformément à nos conditions, toute bouteille manquante est facturée ${eur(prix[0])} l’unité.`
      : `Conformément à nos conditions, toute bouteille manquante est facturée selon nos tarifs.`;
  const phrasePrixEn =
    prix.length === 1
      ? `In accordance with our policy, any missing bottle is charged at €${Number(prix[0]).toFixed(2)} per unit.`
      : `In accordance with our policy, any missing bottle is charged according to our rates.`;

  return `📧 Mail prêt à envoyer au client — Chambre ${d.emplacement}

Constaté par : ${d.constate_par ?? "—"} · Transmis à : ${d.transmis_a ?? "—"} · Date : ${jour(d.constate_le)}

Bonjour,

Suite à votre séjour au Parisianer, notre équipe a constaté qu'une ou plusieurs bouteilles Purezza étaient manquantes dans votre chambre.

Détail :
Chambre : ${d.emplacement}
${detail}
Montant total : ${eur(d.montant)}

${phrasePrix} Un lien de paiement sécurisé vous sera transmis prochainement.

Nous restons à votre disposition pour toute question.

Bien cordialement,
L'équipe du Parisianer

Dear Guest,

Following your recent stay at Le Parisianer, our housekeeping team has noticed that one or more Purezza bottles were missing from your room.

${phrasePrixEn} The total amount regarding your stay is €${Number(d.montant).toFixed(2)}.

A secure payment link will be sent to you shortly to settle this balance.

Kind regards,
The Parisianer Team`;
}

export type LigneRecap = {
  emplacement: string;
  description: string;
  decision_technicien: string | null;
  commentaire_technicien: string | null;
  decision_gouvernante: string | null;
  commentaire_gouvernante: string | null;
  materiel: string | null;
  cout_total: number | null;
  cout_incomplet: boolean;
};

export type Recap = {
  reference: string;
  intervenant: string | null;
  date_tournee: string;
  lignes: LigneRecap[];
  cout_total: number;
  cout_incomplet: boolean;
};

const DECISION_G: Record<string, string> = {
  validee: "validée",
  en_cours: "remise en cours",
  a_refaire: "à refaire",
};

/**
 * Le récapitulatif d'une tournée.
 *
 * Un mail par anomalie validée noierait Miguel : un technicien qui coche dix
 * lignes enverrait dix mails. Le lot est donc l'unité d'envoi — c'est déjà ce
 * que le technicien rend d'un coup.
 *
 * Deux moments, deux messages : à la clôture, ce que le technicien déclare
 * avoir fait ; quand la gouvernante a tout tranché, les deux avis côte à côte.
 * Le second dit explicitement ce qu'elle n'a PAS validé — c'est l'information
 * qui manquait à l'ancienne application.
 */
export function objetRecapTournee(r: Recap, complet: boolean): string {
  const quoi = complet ? "Récapitulatif" : "Intervention rendue";
  return `[${quoi}] ${r.intervenant ?? "Intervenant"} — ${r.lignes.length} anomalie${
    r.lignes.length > 1 ? "s" : ""
  } le ${jour(r.date_tournee)}`;
}

export function corpsRecapTournee(r: Recap, complet: boolean): string {
  const ligne = (l: LigneRecap) => {
    const bouts = [`• ${l.emplacement} — ${l.description}`];
    bouts.push(`  ${l.materiel ?? "Aucun matériel"}`);
    if (l.commentaire_technicien) bouts.push(`  « ${l.commentaire_technicien} »`);
    if (complet) {
      bouts.push(
        l.decision_gouvernante
          ? `  Gouvernante : ${DECISION_G[l.decision_gouvernante] ?? l.decision_gouvernante}`
          : "  Gouvernante : pas encore vue",
      );
      if (l.commentaire_gouvernante) bouts.push(`  « ${l.commentaire_gouvernante} »`);
    }
    if (l.cout_total !== null && Number(l.cout_total) > 0) {
      bouts.push(`  ${eur(Number(l.cout_total))}${l.cout_incomplet ? " (incomplet)" : ""}`);
    }
    return bouts.join("\n");
  };

  const refusees = r.lignes.filter(
    (l) => l.decision_gouvernante && l.decision_gouvernante !== "validee",
  );
  const attente = r.lignes.filter((l) => !l.decision_gouvernante);

  const tete = complet
    ? `${r.intervenant ?? "L'intervenant"} est passé le ${jour(r.date_tournee)}. La gouvernante a revu ce qui suit.`
    : `${r.intervenant ?? "L'intervenant"} vient de rendre son intervention du ${jour(r.date_tournee)}. La gouvernante n'a pas encore revu ces lignes.`;

  const alerte =
    complet && refusees.length > 0
      ? `\n⚠ ${refusees.length} déclarée${refusees.length > 1 ? "s" : ""} faite${
          refusees.length > 1 ? "s" : ""
        } mais non validée${refusees.length > 1 ? "s" : ""} par la gouvernante :\n` +
        refusees
          .map(
            (l) =>
              `• ${l.emplacement} — ${l.description} (${
                DECISION_G[l.decision_gouvernante!] ?? l.decision_gouvernante
              })`,
          )
          .join("\n")
      : "";

  const reste =
    attente.length > 0 && complet
      ? `\n${attente.length} ligne${attente.length > 1 ? "s" : ""} sans avis de la gouvernante.`
      : "";

  return `${tete}

${r.lignes.map(ligne).join("\n\n")}
${alerte}${reste}

Coût du lot : ${eur(r.cout_total)}${
    r.cout_incomplet ? "\n(incomplet : au moins un article n'a pas de prix renseigné)" : ""
  }

Référence : ${r.reference}`;
}
