import { PDFDocument, StandardFonts, rgb, type PDFFont, type PDFPage } from "pdf-lib";
import { sql } from "./db";
import { lireFichier, typeMime } from "./stockage";
import { euros } from "./domaine";

/**
 * Le PDF d'un passage : de quoi le garder, l'imprimer, le joindre à un
 * échange — sans dépendre de l'application pour le relire.
 *
 * Mêmes données que l'écran du passage (`/technique/tournee/[id]`) : les
 * lignes de `v_recap_interventions`, le fil de chaque anomalie, les photos
 * des deux moments. Les photos s'ajoutent quand le format le permet —
 * `ChampPhotos` réencode toujours en JPEG avant l'envoi (règle de
 * `app/composants/champ-photos.tsx`), donc c'est le cas presque partout ;
 * une image dans un autre format est juste nommée, pas perdue.
 */

type Lot = {
  reference: string;
  intervenant: string | null;
  date_tournee: string | Date;
  cout_total: number;
};

type Ligne = {
  anomalie_id: string;
  emplacement: string;
  description: string;
  decision_technicien: string | null;
  commentaire_technicien: string | null;
  decision_gouvernante: string | null;
  gouvernante: string | null;
  commentaire_gouvernante: string | null;
  materiel: string | null;
  cout_total: number | null;
};

type Commentaire = {
  anomalie_id: string;
  auteur: string | null;
  texte: string;
  date_commentaire: string | Date;
};

type Photo = { anomalie_id: string; chemin: string; moment: string };

const DECISION_TECHNICIEN: Record<string, string> = {
  fait: "Fait",
  a_acheter: "À acheter",
};
const DECISION_GOUVERNANTE: Record<string, string> = {
  validee: "Validée",
  en_cours: "Remise en cours",
  a_refaire: "À refaire",
};

const MARGE = 48;
const LARGEUR = 595.28;
const HAUTEUR = 841.89;
const LARGEUR_UTILE = LARGEUR - MARGE * 2;

/** Découpe un texte en lignes qui tiennent dans `largeur`, à la police donnée. */
function decouper(texte: string, police: PDFFont, taille: number, largeur: number): string[] {
  const mots = texte.replace(/\s+/g, " ").trim().split(" ");
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

function dateLongue(v: string | Date): string {
  const d = v instanceof Date ? v : new Date(v);
  return new Intl.DateTimeFormat("fr-FR", {
    timeZone: "Europe/Paris",
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  }).format(d);
}

function dateCourte(v: string | Date): string {
  const d = v instanceof Date ? v : new Date(v);
  return new Intl.DateTimeFormat("fr-FR", { timeZone: "Europe/Paris" }).format(d);
}

/** Un classeur de pages, qui sait passer à la suivante quand la place manque. */
class Curseur {
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
    { taille = 10, gras = false, couleur = rgb(0.1, 0.09, 0.15), interligne = 1.35 }:
      { taille?: number; gras?: boolean; couleur?: ReturnType<typeof rgb>; interligne?: number } = {},
  ) {
    const police = gras ? this.bold : this.regular;
    const lignes = decouper(contenu, police, taille, LARGEUR_UTILE);
    for (const ligne of lignes) {
      this.assurer(taille * interligne);
      this.page.drawText(ligne, { x: MARGE, y: this.y - taille, size: taille, font: police, color: couleur });
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

async function genererPdfPassage(tourneeId: string): Promise<Uint8Array> {
  const [lot] = await sql<Lot[]>`
    select reference, intervenant, date_tournee, cout_total
      from v_tournees where id = ${tourneeId}`;
  if (!lot) throw new Error("Passage introuvable");

  const lignes = await sql<Ligne[]>`
    select r.anomalie_id, r.emplacement, r.description,
           r.decision_technicien::text, r.commentaire_technicien,
           r.decision_gouvernante::text, r.gouvernante, r.commentaire_gouvernante,
           (select string_agg(p.designation || ' × ' || abs(m.quantite), ', ')
              from mouvements_stock m join produits p on p.id = m.produit_id
             where m.intervention_id = r.intervention_id and m.type = 'sortie') as materiel,
           r.cout_total
      from v_recap_interventions r
     where r.tournee = ${lot.reference}
     order by r.emplacement`;

  const ids = lignes.map((l) => l.anomalie_id);
  const commentaires = ids.length
    ? await sql<Commentaire[]>`
        select anomalie_id, auteur, texte, date_commentaire
          from v_fil_commentaires
         where anomalie_id = any(${ids}::uuid[])
         order by date_commentaire`
    : [];
  const photos = ids.length
    ? await sql<Photo[]>`
        select anomalie_id, chemin, moment::text
          from photos_anomalie
         where anomalie_id = any(${ids}::uuid[])
         order by prise_le`
    : [];

  const doc = await PDFDocument.create();
  const regular = await doc.embedFont(StandardFonts.Helvetica);
  const bold = await doc.embedFont(StandardFonts.HelveticaBold);
  const c = new Curseur(doc, regular, bold);

  c.texte(`Passage du ${dateLongue(lot.date_tournee)}`, { taille: 18, gras: true });
  c.texte(lot.intervenant ?? "Intervenant inconnu", { taille: 12 });
  c.texte(
    `${lignes.length} anomalie${lignes.length === 1 ? "" : "s"} · coût du passage : ${euros(lot.cout_total)}`,
    { taille: 10, couleur: rgb(0.45, 0.43, 0.5) },
  );
  c.espace(14);
  c.trait();
  c.espace(6);

  for (const l of lignes) {
    c.assurer(60);
    c.texte(`${l.emplacement} — ${l.description}`, { taille: 12.5, gras: true });

    if (l.decision_technicien) {
      c.texte(
        `Technicien : ${DECISION_TECHNICIEN[l.decision_technicien] ?? l.decision_technicien}` +
          (l.commentaire_technicien ? ` — ${l.commentaire_technicien}` : ""),
      );
    }
    if (l.decision_gouvernante) {
      c.texte(
        `Gouvernante (${l.gouvernante ?? "?"}) : ` +
          (DECISION_GOUVERNANTE[l.decision_gouvernante] ?? l.decision_gouvernante) +
          (l.commentaire_gouvernante ? ` — ${l.commentaire_gouvernante}` : ""),
      );
    }
    c.texte(`Matériel : ${l.materiel ?? "aucun"}`);
    if (l.cout_total !== null) c.texte(`Coût : ${euros(l.cout_total)}`);

    const fil = commentaires.filter((m) => m.anomalie_id === l.anomalie_id);
    for (const m of fil) {
      c.texte(`· ${dateCourte(m.date_commentaire)} — ${m.auteur ?? "?"} : ${m.texte}`, {
        taille: 9.5,
        couleur: rgb(0.45, 0.43, 0.5),
      });
    }

    // Les photos des deux moments, si le format s'y prête (JPEG — ce que
    // `ChampPhotos` écrit toujours). Les autres sont nommées plutôt que
    // tues : un fichier qu'on ne peut pas montrer ne doit pas disparaître
    // en silence (même esprit que la règle sur un échec d'enregistrement).
    for (const moment of ["constat", "apres"] as const) {
      const cliches = photos.filter((p) => p.anomalie_id === l.anomalie_id && p.moment === moment);
      if (cliches.length === 0) continue;
      c.espace(4);
      c.texte(moment === "constat" ? "Photos au constat :" : "Photos après intervention :", {
        taille: 9.5,
        gras: true,
      });

      const HAUTEUR_VIGNETTE = 110;
      let x = MARGE;
      c.assurer(HAUTEUR_VIGNETTE + 6);
      const yLigne = c.y - HAUTEUR_VIGNETTE;
      for (const p of cliches) {
        if (typeMime(p.chemin) !== "image/jpeg") {
          c.texte(`(photo non affichable — ${p.chemin})`, { taille: 8.5, couleur: rgb(0.6, 0.3, 0.1) });
          continue;
        }
        const octets = await lireFichier(p.chemin);
        if (!octets) continue;
        try {
          const image = await doc.embedJpg(octets);
          const largeur = (HAUTEUR_VIGNETTE * image.width) / image.height;
          if (x + largeur > LARGEUR - MARGE) {
            x = MARGE;
            c.y -= HAUTEUR_VIGNETTE + 6;
            c.assurer(HAUTEUR_VIGNETTE + 6);
          }
          c.page.drawImage(image, { x, y: c.y - HAUTEUR_VIGNETTE, width: largeur, height: HAUTEUR_VIGNETTE });
          x += largeur + 8;
        } catch {
          // Un fichier corrompu ou illisible ne doit pas faire échouer tout
          // le PDF : on saute cette photo-là.
          continue;
        }
      }
      c.y = yLigne - 6;
    }

    c.espace(8);
    c.trait();
    c.espace(6);
  }

  return doc.save();
}

export { genererPdfPassage };
