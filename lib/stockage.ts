import { randomUUID } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

/**
 * Où vivent les photos.
 *
 * En développement, sur le disque, sous `donnees/photos`. En production ce sera
 * Supabase Storage : seules les deux fonctions ci-dessous changent, le reste de
 * l'application ne connaît qu'un chemin.
 */
const RACINE = path.join(process.cwd(), "donnees", "photos");

const EXTENSIONS: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
  "image/heic": "heic",
};

/** 12 Mo : une photo de téléphone non redimensionnée tient largement dedans. */
export const TAILLE_MAX = 12 * 1024 * 1024;

export async function enregistrerPhoto(fichier: File): Promise<string | null> {
  if (!fichier || fichier.size === 0) return null;
  if (fichier.size > TAILLE_MAX) return null;
  const extension = EXTENSIONS[fichier.type];
  if (!extension) return null;

  const nom = `${randomUUID()}.${extension}`;
  await mkdir(RACINE, { recursive: true });
  await writeFile(path.join(RACINE, nom), Buffer.from(await fichier.arrayBuffer()));
  return nom;
}

export async function lirePhoto(nom: string): Promise<Buffer | null> {
  // Un nom de fichier, jamais un chemin : rien ne doit pouvoir remonter
  // au-dessus du dossier des photos.
  if (nom !== path.basename(nom)) return null;
  try {
    return await readFile(path.join(RACINE, nom));
  } catch {
    return null;
  }
}

export function typeMime(nom: string): string {
  const extension = nom.split(".").pop() ?? "";
  return (
    Object.entries(EXTENSIONS).find(([, e]) => e === extension)?.[0] ??
    "application/octet-stream"
  );
}
