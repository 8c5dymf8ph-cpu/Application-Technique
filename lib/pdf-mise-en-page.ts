import { rgb, type PDFDocument, type PDFFont, type PDFPage } from "pdf-lib";

/**
 * Ce que partagent les PDF de l'application — celui d'un passage, celui d'un
 * dossier de suivi : une page A4, ses marges, un curseur qui passe à la page
 * suivante quand la place manque, et des dates en français.
 */

export const MARGE = 48;
export const LARGEUR = 595.28;
export const HAUTEUR = 841.89;
export const LARGEUR_UTILE = LARGEUR - MARGE * 2;

/**
 * Ce que les polices standard du PDF savent écrire (WinAnsi : le latin et la
 * ponctuation française). Un émoji ou une flèche tapés dans un commentaire
 * faisaient échouer TOUT le document — le caractère est remplacé, le reste
 * du texte s'imprime.
 */
const WINANSI = /[^\x20-\x7E\xA0-\xFF€‚ƒ„…†‡ˆ‰Š‹ŒŽ‘’“”•–—˜™š›œžŸ\n\r\t]/g;
export function ecrivable(texte: string): string {
  return texte.replace(/→/g, "->").replace(WINANSI, "");
}

/** Découpe un texte en lignes qui tiennent dans `largeur`, à la police donnée. */
export function decouper(texte: string, police: PDFFont, taille: number, largeur: number): string[] {
  const mots = ecrivable(texte).replace(/\s+/g, " ").trim().split(" ");
  const lignes: string[] = [];
  let ligne = "";
  for (const mot of mots) {
    const essai = ligne ? `${ligne} ${mot}` : mot;
    if (police.widthOfTextAtSize(essai, taille) > largeur && ligne) {
      lignes.push(ligne);
      ligne = mot;
    } else {
      ligne = essai;
    }
  }
  if (ligne) lignes.push(ligne);
  return lignes;
}

export function dateLongue(v: string | Date): string {
  const d = v instanceof Date ? v : new Date(v);
  return new Intl.DateTimeFormat("fr-FR", {
    timeZone: "Europe/Paris",
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  }).format(d);
}

export function dateCourte(v: string | Date): string {
  const d = v instanceof Date ? v : new Date(v);
  return new Intl.DateTimeFormat("fr-FR", { timeZone: "Europe/Paris" }).format(d);
}

/** Un classeur de pages, qui sait passer à la suivante quand la place manque. */
export class Curseur {
  doc: PDFDocument;
  page: PDFPage;
  y: number;
  regular: PDFFont;
  bold: PDFFont;

  constructor(doc: PDFDocument, regular: PDFFont, bold: PDFFont) {
    this.doc = doc;
    this.regular = regular;
    this.bold = bold;
    this.page = doc.addPage([LARGEUR, HAUTEUR]);
    this.y = HAUTEUR - MARGE;
  }

  /** Assure qu'il reste au moins `h` points avant le bas de page. */
  assurer(h: number) {
    if (this.y - h < MARGE) {
      this.page = this.doc.addPage([LARGEUR, HAUTEUR]);
      this.y = HAUTEUR - MARGE;
    }
  }

  texte(
    contenu: string,
    {
      taille = 10,
      gras = false,
      couleur = rgb(0.1, 0.09, 0.15),
      interligne = 1.35,
      retrait = 0,
    }: {
      taille?: number;
      gras?: boolean;
      couleur?: ReturnType<typeof rgb>;
      interligne?: number;
      /** Décalage à gauche, pour le détail d'une ligne de chronologie. */
      retrait?: number;
    } = {},
  ) {
    const police = gras ? this.bold : this.regular;
    const lignes = decouper(contenu, police, taille, LARGEUR_UTILE - retrait);
    for (const ligne of lignes) {
      this.assurer(taille * interligne);
      this.page.drawText(ligne, {
        x: MARGE + retrait,
        y: this.y - taille,
        size: taille,
        font: police,
        color: couleur,
      });
      this.y -= taille * interligne;
    }
  }

  espace(h: number) {
    this.y -= h;
  }

  trait() {
    this.assurer(10);
    this.page.drawLine({
      start: { x: MARGE, y: this.y },
      end: { x: LARGEUR - MARGE, y: this.y },
      thickness: 0.75,
      color: rgb(0.85, 0.84, 0.88),
    });
    this.y -= 10;
  }
}
