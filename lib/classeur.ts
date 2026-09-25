import ExcelJS from "exceljs";
import { EXPORTS } from "./export";

/**
 * Toutes les données, dans un seul classeur.
 *
 * Les huit — puis seize — tableaux de `lib/export.ts` sortent très bien un par
 * un en CSV, pour qui veut UNE donnée précise. Mais une sauvegarde, c'est
 * autre chose : c'est le jour où on n'a plus accès à rien, et où il faut
 * pouvoir reprendre à la main. Ce jour-là, seize fichiers à retrouver et à
 * ouvrir un par un ne servent à personne — un seul fichier, un onglet par
 * tableau, ouvert d'un double-clic.
 *
 * Le format natif d'Excel (`.xlsx`) est aussi ce qui manquait au CSV : une
 * vraie date, triable et filtrable, sans le bricolage BOM/virgule-décimale
 * nécessaire pour qu'Excel lise un CSV français.
 */
export async function construireClasseur() {
  const classeur = new ExcelJS.Workbook();
  classeur.creator = "Application Technique — Hôtel Parisianer";
  classeur.created = new Date();

  for (const e of EXPORTS) {
    const lignes = await e.lignes();
    const feuille = classeur.addWorksheet(nomFeuille(e.titre));

    if (lignes.length === 0) {
      feuille.addRow(["Aucune ligne"]);
      continue;
    }

    const colonnes = Object.keys(lignes[0]);
    feuille.columns = colonnes.map((c) => ({
      header: c,
      key: c,
      width: largeurColonne(c, lignes, c),
    }));
    feuille.getRow(1).font = { bold: true };
    feuille.views = [{ state: "frozen", ySplit: 1 }];
    feuille.autoFilter = {
      from: { row: 1, column: 1 },
      to: { row: 1, column: colonnes.length },
    };

    for (const ligne of lignes) {
      const rangee = feuille.addRow({});
      colonnes.forEach((c, i) => ecrireCellule(rangee.getCell(i + 1), ligne[c]));
    }
  }

  return classeur.xlsx.writeBuffer();
}

/** Excel refuse « : \ / ? * [ ] » dans un nom d'onglet, et le limite à 31 signes. */
function nomFeuille(titre: string): string {
  return titre.replace(/[:\\/?*[\]]/g, " ").slice(0, 31);
}

function largeurColonne(
  colonne: string,
  lignes: Record<string, unknown>[],
  cle: string,
): number {
  let plusLong = colonne.length;
  for (const l of lignes.slice(0, 200)) {
    const v = l[cle];
    const texte = v instanceof Date ? "24/12/2024 12:00" : String(v ?? "");
    if (texte.length > plusLong) plusLong = texte.length;
  }
  return Math.min(Math.max(plusLong + 2, 10), 48);
}

/**
 * Une valeur telle qu'Excel la comprend nativement — pas de bricolage de
 * séparateur ni de guillemets, contrairement au CSV.
 *
 * ExcelJS sérialise une date via son horodatage (`getTime()`, en UTC) : une
 * date Postgres construite en heure LOCALE (celle que lisent `getFullYear`,
 * `getMonth`, `getDate` — voir `jourISO()` dans `lib/domaine.ts`) doit donc
 * être reconstruite en UTC à partir de CES MÊMES composants, sinon un serveur
 * qui ne tourne pas en UTC ferait reculer la date d'un jour dans le tableur.
 */
function ecrireCellule(cellule: ExcelJS.Cell, v: unknown): void {
  if (v === null || v === undefined) return;
  if (v instanceof Date) {
    const journee =
      v.getHours() === 0 && v.getMinutes() === 0 && v.getSeconds() === 0;
    cellule.value = new Date(
      Date.UTC(
        v.getFullYear(),
        v.getMonth(),
        v.getDate(),
        journee ? 0 : v.getHours(),
        journee ? 0 : v.getMinutes(),
      ),
    );
    cellule.numFmt = journee ? "dd/mm/yyyy" : "dd/mm/yyyy hh:mm";
    return;
  }
  if (typeof v === "number" || typeof v === "boolean") {
    cellule.value = v;
    return;
  }
  cellule.value = String(v);
}
