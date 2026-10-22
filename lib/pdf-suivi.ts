import { PDFDocument, StandardFonts, rgb } from "pdf-lib";
import { sql } from "./db";
import { lireFichier, typeMime } from "./stockage";
import { euros } from "./domaine";
import { tableExiste } from "./schema";
import {
  Curseur,
  HAUTEUR,
  LARGEUR,
  LARGEUR_UTILE,
  MARGE,
  dateCourte,
  dateLongue,
  ecrivable,
} from "./pdf-mise-en-page";

/**
 * Le récapitulatif d'un dossier de suivi : toute son histoire en un PDF, à
 * transmettre (à la direction, à un auditeur, à la société sous contrat) ou à
 * classer — et, à la fin, les documents qu'on a choisi d'y joindre.
 *
 * « Pouvoir ajouter ou non certains PDF que j'aurais préalablement ajoutés au
 * cours de mes étapes » : un rapport de visite oui, toutes les factures non.
 * Les PDF choisis sont recopiés page par page ; une photo prend une page à
 * elle. Un fichier illisible (PDF protégé, abîmé) est NOMMÉ dans la liste des
 * annexes plutôt que de faire échouer tout le document.
 */

type Dossier = {
  id: string;
  titre: string;
  nature: string;
  permanent: boolean;
  ouvert_le: string | Date;
  clos_le: string | Date | null;
  commentaire: string | null;
  periodicite_jours: number | null;
  derniere_verification_nature: string | Date | null;
};

type Acte = {
  id: string;
  date_acte: string | Date;
  type: string;
  qui: string | null;
  commentaire: string | null;
  montant_ht: number | null;
  gratuit: boolean;
  hors_contrat: boolean;
  positifs: string[];
  negatifs: string[];
  autres: string[];
  verification: boolean;
};

const GRIS = rgb(0.45, 0.43, 0.5);
const PRUNE = rgb(0.271, 0.227, 0.431);

async function actesDe(suiviId: string): Promise<Acte[]> {
  return sql<Acte[]>`
    select a.id, a.date_acte, t.libelle as type, t.est_verification as verification,
           coalesce(u.nom, p.nom) as qui, a.commentaire, a.montant_ht, a.gratuit, a.hors_contrat,
           coalesce((select array_agg(e.code order by e.code) from acte_lieux al
                      join emplacements e on e.id = al.emplacement_id
                     where al.acte_id = a.id and al.resultat = 'positif'), '{}') as positifs,
           coalesce((select array_agg(e.code order by e.code) from acte_lieux al
                      join emplacements e on e.id = al.emplacement_id
                     where al.acte_id = a.id and al.resultat = 'negatif'), '{}') as negatifs,
           coalesce((select array_agg(e.code order by e.code) from acte_lieux al
                      join emplacements e on e.id = al.emplacement_id
                     where al.acte_id = a.id
                       and (al.resultat is null or al.resultat = 'non_concluant')), '{}') as autres
      from actes a
      join types_acte t on t.id = a.type_acte_id
      left join utilisateurs u on u.id = a.utilisateur_id
      left join prestataires p on p.id = a.prestataire_id
     where a.suivi_id = ${suiviId}
     order by a.date_acte, a.cree_le`;
}

export async function genererPdfSuivi(
  suiviId: string,
  piecesChoisies: string[],
): Promise<{ pdf: Uint8Array; titre: string }> {
  const [dossier] = await sql<Dossier[]>`
    select id, titre, nature, permanent, ouvert_le, clos_le, commentaire,
           periodicite_jours, derniere_verification_nature
      from v_suivis where id = ${suiviId}`;
  if (!dossier) throw new Error("Dossier introuvable");

  const episodes = dossier.permanent
    ? await sql<Dossier[]>`
        select id, titre, nature, permanent, ouvert_le, clos_le, commentaire,
               periodicite_jours, derniere_verification_nature
          from v_suivis where parent_id = ${suiviId} order by ouvert_le`
    : [];
  const sections = [dossier, ...episodes];
  const ids = sections.map((s) => s.id);

  const avecConsequences = await tableExiste("consequences_acte");
  const consequences = avecConsequences
    ? await sql<{ acte_id: string; libelle: string; lieu: string | null; montant_ht: number | null }[]>`
        select c.acte_id, tc.libelle, e.code as lieu, c.montant_ht
          from consequences_acte c
          join types_consequence tc on tc.id = c.type_consequence_id
          join actes a on a.id = c.acte_id
          left join emplacements e on e.id = c.emplacement_id
         where a.suivi_id = any(${ids}::uuid[])
         order by tc.ordre, e.code`
    : [];

  const pieces = await sql<
    { id: string; acte_id: string | null; suivi_id: string; nom: string | null;
      nature_piece: string; chemin: string }[]
  >`
    select id, acte_id, suivi_id, nom, nature_piece, chemin
      from pieces_suivi where suivi_id = any(${ids}::uuid[])
     order by ajoute_le`;

  const doc = await PDFDocument.create();
  doc.setTitle(ecrivable(`Récapitulatif — ${dossier.titre}`));
  const regular = await doc.embedFont(StandardFonts.Helvetica);
  const bold = await doc.embedFont(StandardFonts.HelveticaBold);
  const c = new Curseur(doc, regular, bold);

  // ---------------------------------------------------------------- en-tête
  c.texte(dossier.titre, { taille: 20, gras: true });
  c.texte(dossier.permanent ? `Dossier · ${dossier.nature}` : `Épisode · ${dossier.nature}`, {
    taille: 11,
    couleur: GRIS,
  });
  c.espace(4);
  c.texte(
    `Ouvert le ${dateCourte(dossier.ouvert_le)}` +
      (dossier.clos_le ? ` · clos le ${dateCourte(dossier.clos_le)}` : ""),
    { taille: 10 },
  );
  if (dossier.periodicite_jours) {
    const mois = Math.round((dossier.periodicite_jours * 12) / 365);
    const derniere = dossier.derniere_verification_nature;
    const jours = derniere
      ? Math.round((Date.now() - new Date(derniere).getTime()) / 86_400_000)
      : null;
    c.texte(
      `Une visite tous les ${mois} mois` +
        (derniere
          ? ` · dernière le ${dateCourte(derniere)}${
              jours !== null && jours > dossier.periodicite_jours ? " — en retard" : ""
            }`
          : " · aucune visite enregistrée"),
      { taille: 10 },
    );
  }
  if (dossier.commentaire) c.texte(dossier.commentaire, { taille: 10, couleur: GRIS });
  c.texte(`Édité le ${dateLongue(new Date())}`, { taille: 9, couleur: GRIS });
  c.espace(6);
  c.trait();

  // ------------------------------------------------------------- chronologie
  let total = 0;
  for (const section of sections) {
    const actes = await actesDe(section.id);
    if (section.id !== dossier.id) {
      c.espace(6);
      c.texte(section.titre, { taille: 14, gras: true, couleur: PRUNE });
      c.texte(
        `Épisode ouvert le ${dateCourte(section.ouvert_le)}` +
          (section.clos_le ? ` · clos le ${dateCourte(section.clos_le)}` : " · en cours"),
        { taille: 9.5, couleur: GRIS },
      );
      c.espace(4);
    } else if (dossier.permanent && episodes.length > 0) {
      c.texte("Le dossier", { taille: 14, gras: true, couleur: PRUNE });
      c.espace(2);
    }

    if (actes.length === 0) {
      c.texte("Aucun acte enregistré.", { taille: 10, couleur: GRIS });
    }
    for (const a of actes) {
      c.assurer(40);
      c.texte(`${dateCourte(a.date_acte)} — ${a.type}`, { taille: 11.5, gras: true });
      const details: string[] = [];
      if (a.qui) details.push(`Par ${a.qui}`);
      if (a.montant_ht !== null) {
        total += a.gratuit ? 0 : Number(a.montant_ht);
        details.push(a.gratuit ? `${euros(a.montant_ht)} — offert` : euros(a.montant_ht));
      } else if (a.gratuit) {
        details.push("offert");
      }
      if (a.hors_contrat) details.push("hors contrat");
      if (details.length) c.texte(details.join(" · "), { taille: 10, retrait: 12 });

      if (a.positifs.length)
        c.texte(`${a.verification ? "Relevé" : "Concerné"} : ${a.positifs.join(", ")}`, {
          taille: 10,
          retrait: 12,
        });
      if (a.negatifs.length)
        c.texte(`Vérifié, rien relevé : ${a.negatifs.join(", ")}`, { taille: 10, retrait: 12 });
      if (a.autres.length)
        c.texte(`${a.verification ? "Sans résultat" : "Lieux"} : ${a.autres.join(", ")}`, {
          taille: 10,
          retrait: 12,
        });

      for (const cq of consequences.filter((x) => x.acte_id === a.id)) {
        c.texte(
          `${cq.libelle}${cq.lieu ? ` — ${cq.lieu}` : ""}` +
            (cq.montant_ht !== null ? ` · ${euros(cq.montant_ht)}` : ""),
          { taille: 10, retrait: 12 },
        );
        if (cq.montant_ht !== null) total += Number(cq.montant_ht);
      }
      if (a.commentaire) c.texte(a.commentaire, { taille: 10, retrait: 12, couleur: GRIS });
      const pj = pieces.filter((p) => p.acte_id === a.id);
      if (pj.length) {
        c.texte(`Pièces : ${pj.map((p) => `${p.nature_piece} (${p.nom ?? "sans nom"})`).join(", ")}`, {
          taille: 9.5,
          retrait: 12,
          couleur: GRIS,
        });
      }
      c.espace(6);
    }

    const docs = pieces.filter((p) => !p.acte_id && p.suivi_id === section.id);
    if (docs.length) {
      c.texte("Documents du dossier", { taille: 11, gras: true });
      for (const p of docs) {
        c.texte(`${p.nature_piece} — ${p.nom ?? "sans nom"}`, { taille: 10, retrait: 12 });
      }
      c.espace(4);
    }
    c.trait();
  }

  if (total > 0) {
    c.texte(`Montants annoncés au total : ${euros(total)}`, { taille: 11, gras: true });
  }

  // ----------------------------------------------------------------- annexes
  // Seules les pièces de CE dossier (ou de ses épisodes), dans l'ordre choisi.
  const annexes = piecesChoisies
    .map((id) => pieces.find((p) => p.id === id))
    .filter((p): p is (typeof pieces)[number] => Boolean(p));
  if (annexes.length > 0) {
    // Deux temps : préparer chaque annexe et écrire leur liste, PUIS ajouter
    // leurs pages. Écrire la liste après coup pouvait la faire déborder sur
    // une page ajoutée derrière les annexes.
    type Prete =
      | { genre: "pdf"; nom: string; source: PDFDocument }
      | { genre: "image"; nom: string; image: Awaited<ReturnType<typeof doc.embedJpg>> };
    const pretes: Prete[] = [];
    const lignesIndex: string[] = [];

    for (const [i, p] of annexes.entries()) {
      const nom = `${i + 1}. ${p.nature_piece} — ${p.nom ?? "sans nom"}`;
      const octets = await lireFichier(p.chemin);
      if (!octets) {
        lignesIndex.push(`${nom} (introuvable dans le dépôt)`);
        continue;
      }
      const mime = typeMime(p.chemin);
      try {
        if (mime === "application/pdf") {
          const source = await PDFDocument.load(octets, { ignoreEncryption: true });
          const n = source.getPageCount();
          pretes.push({ genre: "pdf", nom, source });
          lignesIndex.push(`${nom} (${n} page${n > 1 ? "s" : ""})`);
        } else if (mime === "image/jpeg" || mime === "image/png") {
          const image =
            mime === "image/jpeg" ? await doc.embedJpg(octets) : await doc.embedPng(octets);
          pretes.push({ genre: "image", nom, image });
          lignesIndex.push(nom);
        } else {
          lignesIndex.push(`${nom} (format non joignable)`);
        }
      } catch {
        lignesIndex.push(`${nom} (illisible — non joint)`);
      }
    }

    c.espace(10);
    c.texte(`Annexes · ${annexes.length}`, { taille: 14, gras: true, couleur: PRUNE });
    for (const l of lignesIndex) c.texte(l, { taille: 10, retrait: 12 });

    for (const a of pretes) {
      if (a.genre === "pdf") {
        try {
          const pages = await doc.copyPages(a.source, a.source.getPageIndices());
          for (const page of pages) doc.addPage(page);
        } catch {
          // Une page qui ne se recopie pas ne fait pas échouer le reste.
        }
        continue;
      }
      const page = doc.addPage([LARGEUR, HAUTEUR]);
      page.drawText(ecrivable(a.nom), {
        x: MARGE,
        y: HAUTEUR - MARGE - 11,
        size: 11,
        font: bold,
        color: rgb(0.1, 0.09, 0.15),
      });
      const hauteurDispo = HAUTEUR - MARGE * 2 - 24;
      const echelle = Math.min(LARGEUR_UTILE / a.image.width, hauteurDispo / a.image.height, 1);
      const w = a.image.width * echelle;
      const h = a.image.height * echelle;
      page.drawImage(a.image, {
        x: MARGE + (LARGEUR_UTILE - w) / 2,
        y: HAUTEUR - MARGE - 24 - h,
        width: w,
        height: h,
      });
    }
  }

  return { pdf: await doc.save(), titre: dossier.titre };
}
