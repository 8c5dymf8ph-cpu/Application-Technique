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
  return `[A ENVOYER CLIENT] Bouteille(s) Purezza manquante(s) — Chambre ${d.emplacement} — Dossier n° ${d.reference}`;
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

  // Le prénom n'est pas toujours connu — un « Bonjour » générique reste la
  // bonne réponse pour un dossier où la gouvernante n'a pas pu le relever.
  const civiliteFr = d.client_nom ? `Bonjour ${d.client_nom},` : "Bonjour,";
  const civiliteEn = d.client_nom ? `Dear ${d.client_nom},` : "Dear Guest,";

  return `📧 Mail prêt à envoyer au client — Chambre ${d.emplacement} — Dossier n° ${d.reference}

Constaté par : ${d.constate_par ?? "—"} · Transmis à : ${d.transmis_a ?? "—"} · Date : ${jour(d.constate_le)}

${civiliteFr}

Suite à votre séjour au Parisianer, notre équipe a constaté qu'une ou plusieurs bouteilles Purezza étaient manquantes dans votre chambre.

Détail :
Dossier n° ${d.reference}
Chambre : ${d.emplacement}
${detail}
Montant total : ${eur(d.montant)}

${phrasePrix} Un lien de paiement sécurisé vous sera transmis prochainement. Merci de nous indiquer le numéro de dossier ci-dessus dans votre réponse, afin que nous puissions le retrouver rapidement.

Nous restons à votre disposition pour toute question.

Bien cordialement,
L'équipe du Parisianer

${civiliteEn}

Following your recent stay at Le Parisianer, our housekeeping team has noticed that one or more Purezza bottles were missing from your room.

Reference: ${d.reference}

${phrasePrixEn} The total amount regarding your stay is €${Number(d.montant).toFixed(2)}.

A secure payment link will be sent to you shortly to settle this balance. Please mention the reference number above in any reply, so we can locate your file quickly.

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
  // Seulement pour le récapitulatif complet : ce que `v_tournees` sait déjà
  // compter, et qui de la gouvernante a tranché en dernier.
  nb_validees?: number;
  nb_en_cours?: number;
  nb_a_refaire?: number;
  valide_par?: string | null;
  valide_le?: string | null;
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

function echapper(texte: string): string {
  return texte.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

const quand = (d: string) =>
  `${jour(d)} à ${new Date(d).toLocaleTimeString("fr-FR", { hour: "2-digit", minute: "2-digit" })}`;

// Le jeu de couleurs de l'application (tailwind.config.ts), repris en dur :
// un mail ne charge pas de feuille de style.
const COULEUR_DECISION: Record<string, { fond: string; texte: string; label: string }> = {
  validee: { fond: "#E3EFE8", texte: "#357051", label: "VALIDÉE" },
  en_cours: { fond: "#F6EEE3", texte: "#A8641F", label: "EN COURS" },
  a_refaire: { fond: "#F7E6E7", texte: "#9E3538", label: "À REFAIRE" },
};

function pastille(texte: string, fond: string, couleur: string): string {
  return (
    `<span style="display:inline-block;padding:3px 10px;background-color:${fond};` +
    `color:${couleur};font-size:11px;font-weight:bold;letter-spacing:.3px;white-space:nowrap;">` +
    `${texte}</span>`
  );
}

function grouperParEmplacement(lignes: LigneRecap[]): { emplacement: string; lignes: LigneRecap[] }[] {
  const groupes: { emplacement: string; lignes: LigneRecap[] }[] = [];
  for (const l of lignes) {
    const dernier = groupes[groupes.length - 1];
    if (dernier && dernier.emplacement === l.emplacement) dernier.lignes.push(l);
    else groupes.push({ emplacement: l.emplacement, lignes: [l] });
  }
  return groupes;
}

function boiteTechnicien(l: LigneRecap): string {
  const bouts = [
    `<span style="color:#3A6499;font-weight:bold;font-size:11px;letter-spacing:.4px;">` +
      `TRAVAIL DU TECHNICIEN</span><br>`,
    `<strong>Matériel :</strong> ${echapper(l.materiel ?? "Aucun matériel")}`,
  ];
  if (l.commentaire_technicien) {
    bouts.push(`<br><strong>Commentaire :</strong> « ${echapper(l.commentaire_technicien)} »`);
  }
  if (l.cout_total !== null && Number(l.cout_total) > 0) {
    bouts.push(
      `<br><strong>Coût :</strong> ${eur(Number(l.cout_total))}${l.cout_incomplet ? " (incomplet)" : ""}`,
    );
  }
  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" ` +
    `style="margin-top:6px;background-color:#E6EDF6;border-left:3px solid #3A6499;">` +
    `<tr><td style="padding:10px 12px;font-size:13px;color:#1a1a1a;line-height:1.7;">` +
    `${bouts.join("")}</td></tr></table>`
  );
}

function boiteGouvernante(l: LigneRecap): string {
  if (!l.decision_gouvernante) return "";
  const c = COULEUR_DECISION[l.decision_gouvernante] ?? {
    fond: "#F4F2F7",
    texte: "#1B1930",
    label: l.decision_gouvernante,
  };
  const bouts = [
    `<span style="color:${c.texte};font-weight:bold;font-size:11px;letter-spacing:.4px;">` +
      `AVIS DE LA GOUVERNANTE — ${c.label}</span>`,
  ];
  if (l.commentaire_gouvernante) bouts.push(`<br>« ${echapper(l.commentaire_gouvernante)} »`);
  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" ` +
    `style="margin-top:6px;background-color:${c.fond};border-left:3px solid ${c.texte};">` +
    `<tr><td style="padding:10px 12px;font-size:13px;color:#1a1a1a;line-height:1.7;">` +
    `${bouts.join("")}</td></tr></table>`
  );
}

function ligneAnomalieHtml(l: LigneRecap, complet: boolean): string {
  const badge =
    l.decision_technicien === "non_fait"
      ? pastille("NON FAIT", "#F7E6E7", "#9E3538")
      : pastille("FAIT", "#E3EFE8", "#357051");
  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-top:14px;">` +
    `<tr>` +
    `<td style="font-size:14px;font-weight:bold;color:#1a1a1a;line-height:1.4;">${echapper(l.description)}</td>` +
    `<td align="right" style="white-space:nowrap;padding-left:8px;">${badge}</td>` +
    `</tr></table>` +
    boiteTechnicien(l) +
    (complet ? boiteGouvernante(l) : "")
  );
}

function sectionChambre(g: { emplacement: string; lignes: LigneRecap[] }, complet: boolean): string {
  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin-top:18px;">` +
    `<tr><td style="background-color:#453A6E;padding:9px 14px;">` +
    `<span style="color:#ffffff;font-size:14px;font-weight:bold;">Chambre ${echapper(g.emplacement)}</span>` +
    `</td></tr></table>` +
    g.lignes.map((l) => ligneAnomalieHtml(l, complet)).join("")
  );
}

function tuile(valeur: number, label: string, fond: string, texte: string): string {
  return (
    `<td width="33%" style="padding:4px;">` +
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background-color:${fond};">` +
    `<tr><td align="center" style="padding:16px 4px;">` +
    `<div style="font-size:26px;font-weight:bold;color:${texte};line-height:1;font-family:Arial,Helvetica,sans-serif;">${valeur}</div>` +
    `<div style="font-size:10.5px;letter-spacing:.5px;color:${texte};margin-top:4px;font-weight:bold;">${label}</div>` +
    `</td></tr></table></td>`
  );
}

/**
 * Le récapitulatif en HTML — une vraie mise en page, pas un dérivé du texte.
 *
 * Deux essais précédents ont échoué dans Outlook, le client de la
 * réception : `white-space: pre-wrap` est ignoré (tout s'écrase en un seul
 * bloc) ; `<br>` seul corrige les sauts de ligne mais reste un paragraphe
 * plat. Le reste de la demande — reproduire l'esprit d'un ancien mail
 * (en-tête, encadré d'identification, compteurs en pastilles, une section
 * par chambre) — ET rester lisible sur un VIEIL Outlook, exclut flexbox et
 * grid (Outlook les ignore et empile tout verticalement) : tout est donc
 * posé en `<table>` imbriquées, avec des styles EN LIGNE sur chaque
 * cellule — la seule mise en forme dont Outlook (moteur Word) tienne compte
 * de façon fiable. Les couleurs reprennent la palette de l'application
 * (tailwind.config.ts), reconstruites ici en dur puisqu'un mail ne charge
 * aucune feuille de style.
 */
export function corpsRecapTourneeHtml(r: Recap, complet: boolean): string {
  const groupes = grouperParEmplacement(r.lignes);
  const refusees = r.lignes.filter(
    (l) => l.decision_gouvernante && l.decision_gouvernante !== "validee",
  );
  const attente = r.lignes.filter((l) => !l.decision_gouvernante);

  const entete =
    `<tr><td style="padding:22px 20px 2px;">` +
    `<div style="font-size:21px;font-weight:bold;color:#453A6E;font-family:Arial,Helvetica,sans-serif;">` +
    `${complet ? "Récapitulatif de validation gouvernante" : "Intervention rendue"}</div>` +
    `<div style="font-size:12.5px;color:#8E8AA3;margin-top:3px;">Hôtel Parisianer · Mail généré automatiquement</div>` +
    `</td></tr>`;

  const infos = [
    `<strong style="color:#453A6E;">N° Intervention :</strong> ${echapper(r.reference)}`,
    `<strong style="color:#453A6E;">Intervenant :</strong> ${echapper(r.intervenant ?? "—")}`,
    `<strong style="color:#453A6E;">Date intervention :</strong> ${jour(r.date_tournee)}`,
  ];
  if (complet && r.valide_par) {
    infos.push(
      `<strong style="color:#453A6E;">Validé par :</strong> ${echapper(r.valide_par)}` +
        (r.valide_le ? ` · ${quand(r.valide_le)}` : ""),
    );
  }
  const boiteInfos =
    `<tr><td style="padding:14px 20px 0;">` +
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" ` +
    `style="background-color:#EDE9F5;border-left:4px solid #453A6E;">` +
    `<tr><td style="padding:14px 16px;font-size:13.5px;color:#1a1a1a;line-height:1.9;font-family:Arial,Helvetica,sans-serif;">` +
    `${infos.join("<br>")}</td></tr></table></td></tr>`;

  const tuiles = complet
    ? `<tr><td style="padding:14px 20px 0;">` +
      `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0"><tr>` +
      tuile(r.nb_validees ?? 0, "VALIDÉES", "#E3EFE8", "#357051") +
      tuile(r.nb_en_cours ?? 0, "EN COURS", "#F6EEE3", "#A8641F") +
      tuile(r.nb_a_refaire ?? 0, "À REFAIRE", "#F7E6E7", "#9E3538") +
      `</tr></table></td></tr>`
    : "";

  const titreDetail =
    `<tr><td style="padding:20px 20px 0;">` +
    `<div style="font-size:15px;font-weight:bold;color:#453A6E;border-bottom:2px solid #E7E4EF;padding-bottom:7px;">` +
    `Détail par chambre</div></td></tr>`;

  const corpsChambres =
    `<tr><td style="padding:0 20px;">` +
    groupes.map((g) => sectionChambre(g, complet)).join("") +
    `</td></tr>`;

  const alerte =
    complet && refusees.length > 0
      ? `<tr><td style="padding:18px 20px 0;">` +
        `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" ` +
        `style="background-color:#F7E6E7;border-left:4px solid #9E3538;">` +
        `<tr><td style="padding:12px 14px;font-size:13px;color:#9E3538;line-height:1.7;">` +
        `<strong>${refusees.length} déclarée${refusees.length > 1 ? "s" : ""} faite${
          refusees.length > 1 ? "s" : ""
        } mais non validée${refusees.length > 1 ? "s" : ""} par la gouvernante :</strong><br>` +
        refusees
          .map(
            (l) =>
              `• ${echapper(l.emplacement)} — ${echapper(l.description)} (${
                DECISION_G[l.decision_gouvernante!] ?? l.decision_gouvernante
              })`,
          )
          .join("<br>") +
        `</td></tr></table></td></tr>`
      : "";

  const reste =
    complet && attente.length > 0
      ? `<tr><td style="padding:12px 20px 0;font-size:12.5px;color:#8E8AA3;font-family:Arial,Helvetica,sans-serif;">` +
        `${attente.length} ligne${attente.length > 1 ? "s" : ""} sans avis de la gouvernante.</td></tr>`
      : "";

  const pied =
    `<tr><td style="padding:22px 20px 26px;border-top:1px solid #E7E4EF;">` +
    `<div style="font-size:14px;font-weight:bold;color:#1a1a1a;font-family:Arial,Helvetica,sans-serif;padding-top:16px;">` +
    `Coût du lot : ${eur(r.cout_total)}` +
    (r.cout_incomplet
      ? ` <span style="color:#A8641F;font-weight:normal;font-size:12px;">` +
        `(incomplet : au moins un article n'a pas de prix renseigné)</span>`
      : "") +
    `</div>` +
    `<div style="font-size:11.5px;color:#8E8AA3;margin-top:8px;font-family:Arial,Helvetica,sans-serif;">` +
    `Référence : ${echapper(r.reference)}</div></td></tr>`;

  return (
    `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" ` +
    `style="max-width:600px;margin:0 auto;font-family:Arial,Helvetica,sans-serif;background-color:#ffffff;">` +
    entete +
    boiteInfos +
    tuiles +
    titreDetail +
    corpsChambres +
    alerte +
    reste +
    pied +
    `</table>`
  );
}
