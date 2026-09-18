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
