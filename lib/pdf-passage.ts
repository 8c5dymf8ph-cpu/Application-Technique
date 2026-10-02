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

  // Trois couleurs, une par moment — mêmes teintes que les vignettes de
  // l'application (text-blue / text-green / text-plum), pour reconnaître
  // d'un coup d'œil laquelle est laquelle sans que chacune ait sa propre
  // ligne de titre.
  const COULEUR_MOMENT: Record<string, ReturnType<typeof rgb>> = {
    constat: rgb(0.227, 0.388, 0.6),
    apres: rgb(0.122, 0.478, 0.302),
    validation: rgb(0.271, 0.227, 0.431),
  };
  const TAILLE_VIGNETTE = 26;
  const ESPACE_VIGNETTE = 4;

  for (const l of lignes) {
    const titre = `${l.emplacement} — ${l.description}`;

    /**
     * Les vignettes se tiennent SUR LA LIGNE DU TITRE, pas les unes en
     * dessous des autres : une photo au constat, une après intervention et
     * une de vérification faisaient trois blocs de 110 points chacun — un
     * passage de quinze anomalies avec photos tenait en dix pages. Elles
     * sont minuscules (26 points) et toutes ensemble, bordées de la couleur
     * de leur moment ; seule une photo illisible garde une ligne à elle,
     * parce que rien ne doit disparaître en silence.
     */
    const illisibles: string[] = [];
    const vignettes: { image: Awaited<ReturnType<typeof doc.embedJpg>>; largeur: number; couleur: ReturnType<typeof rgb> }[] = [];
    for (const moment of ["constat", "apres", "validation"] as const) {
      for (const p of photos.filter((x) => x.anomalie_id === l.anomalie_id && x.moment === moment)) {
        if (typeMime(p.chemin) !== "image/jpeg") {
          illisibles.push(p.chemin);
          continue;
        }
        const octets = await lireFichier(p.chemin);
        if (!octets) continue;
        try {
          const image = await doc.embedJpg(octets);
          const largeur = (TAILLE_VIGNETTE * image.width) / image.height;
          vignettes.push({ image, largeur, couleur: COULEUR_MOMENT[moment] });
        } catch {
          // Un fichier corrompu ou illisible ne doit pas faire échouer tout
          // le PDF : on saute cette photo-là.
          continue;
        }
      }
    }
    const largeurVignettes =
      vignettes.reduce((s, v) => s + v.largeur, 0) +
      Math.max(0, vignettes.length - 1) * ESPACE_VIGNETTE;

    const policeTitre = c.bold;
    const titreTientSurUneLigne = policeTitre.widthOfTextAtSize(titre, 12.5) <= LARGEUR_UTILE;
    const reserveVignettesSurLaLigne =
      titreTientSurUneLigne &&
      vignettes.length > 0 &&
      policeTitre.widthOfTextAtSize(titre, 12.5) + 14 + largeurVignettes <= LARGEUR_UTILE;

    c.assurer(Math.max(12.5 * 1.35, TAILLE_VIGNETTE) + 4);

    const dessinerVignettes = (xDepart: number, yHaut: number) => {
      let x = xDepart;
      for (const v of vignettes) {
        c.page.drawRectangle({
          x: x - 1,
          y: yHaut - TAILLE_VIGNETTE - 1,
          width: v.largeur + 2,
          height: TAILLE_VIGNETTE + 2,
          borderColor: v.couleur,
          borderWidth: 1,
        });
        c.page.drawImage(v.image, { x, y: yHaut - TAILLE_VIGNETTE, width: v.largeur, height: TAILLE_VIGNETTE });
        x += v.largeur + ESPACE_VIGNETTE;
      }
    };

    if (titreTientSurUneLigne) {
      // Le titre tient sur une ligne : les vignettes (s'il y en a assez de
      // place) viennent flush à droite, sur cette même ligne.
      c.page.drawText(titre, { x: MARGE, y: c.y - 12.5, size: 12.5, font: policeTitre, color: rgb(0.1, 0.09, 0.15) });
      if (reserveVignettesSurLaLigne) {
        dessinerVignettes(LARGEUR - MARGE - largeurVignettes, c.y);
        c.y -= Math.max(12.5 * 1.35, TAILLE_VIGNETTE + 4);
      } else {
        c.y -= 12.5 * 1.35;
        if (vignettes.length > 0) {
          c.assurer(TAILLE_VIGNETTE + 4);
          dessinerVignettes(MARGE, c.y);
          c.y -= TAILLE_VIGNETTE + 4;
        }
      }
    } else {
      // Une description longue a déjà besoin de plusieurs lignes : les
      // vignettes suivent sur une ligne à elles, mais toujours compacte —
      // jamais un bloc par moment.
      c.texte(titre, { taille: 12.5, gras: true });
      if (vignettes.length > 0) {
        c.assurer(TAILLE_VIGNETTE + 4);
        dessinerVignettes(MARGE, c.y);
        c.y -= TAILLE_VIGNETTE + 4;
      }
    }
    for (const chemin of illisibles) {
      c.texte(`(photo non affichable — ${chemin})`, { taille: 8.5, couleur: rgb(0.6, 0.3, 0.1) });
    }

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

    c.espace(8);
    c.trait();
    c.espace(6);
  }

  return doc.save();
}

export { genererPdfPassage };
