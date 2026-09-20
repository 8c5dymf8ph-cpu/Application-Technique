import { randomUUID } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

/**
 * Où vivent les fichiers — photos d'anomalies, de produits, de bouteilles, et
 * factures en PDF.
 *
 * Deux dépôts, un seul contrat : le reste de l'application ne connaît qu'un nom
 * de fichier, jamais un chemin ni une adresse.
 *
 * - **En production**, Supabase Storage. Le disque de Vercel est en lecture
 *   seule et repart à zéro à chaque déploiement : une photo écrite sur ce
 *   disque serait perdue au déploiement suivant.
 * - **En développement**, le dossier `donnees/photos`, pour n'avoir besoin de
 *   rien d'autre qu'une base locale.
 *
 * Le choix se fait sur la présence des variables Supabase, jamais sur
 * `NODE_ENV` : on peut vouloir tester le dépôt distant depuis un poste.
 */

const RACINE = path.join(process.cwd(), "donnees", "photos");
const SEAU = process.env.SUPABASE_BUCKET ?? "fichiers";

const EXTENSIONS: Record<string, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
  "image/heic": "heic",
  // Une facture arrive en PDF aussi souvent qu'en photo : les deux se rangent
  // au même endroit et se relisent par le même chemin.
  "application/pdf": "pdf",
};

/**
 * 4 Mo : c'est ce que la plateforme laisse passer (elle coupe à 4,5 Mo). Les
 * photos arrivent réduites par le navigateur ; une facture PDF tient dedans.
 */
export const TAILLE_MAX = 4 * 1024 * 1024;

/** Ce que Supabase a répondu la dernière fois qu'il a refusé un fichier. */
let dernierEchec: string | null = null;

function supabase() {
  const url = process.env.SUPABASE_URL;
  // La clé de service contourne les règles de ligne : elle ne doit JAMAIS
  // partir vers le navigateur. Elle n'est lue que dans ce fichier, qui ne
  // s'exécute que sur le serveur.
  //
  // Supabase a renommé ses clés : `sb_secret_…` (SUPABASE_SECRET_KEY) remplace
  // l'ancienne `service_role`. Les deux noms sont acceptés — un projet ancien
  // n'a pas à être repris, un projet neuf n'a pas à traduire.
  const cle =
    process.env.SUPABASE_SECRET_KEY ?? process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url || !cle) return null;
  return { url: url.replace(/\/+$/, ""), cle };
}

/** Le nom d'un fichier, jamais un chemin : rien ne doit remonter au-dessus. */
function sur(nom: string): boolean {
  return nom === path.basename(nom) && !nom.startsWith(".");
}

export async function enregistrerFichier(fichier: File): Promise<string | null> {
  if (!fichier || fichier.size === 0) return null;
  if (fichier.size > TAILLE_MAX) return null;
  const extension = EXTENSIONS[fichier.type];
  if (!extension) return null;

  const nom = `${randomUUID()}.${extension}`;
  const contenu = Buffer.from(await fichier.arrayBuffer());
  const distant = supabase();

  if (distant) {
    const reponse = await fetch(
      `${distant.url}/storage/v1/object/${SEAU}/${nom}`,
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${distant.cle}`,
          // Supabase attend les DEUX en-têtes sur son API de stockage. Avec la
          // seule autorisation, certaines configurations refusent l'écriture
          // sans dire pourquoi.
          apikey: distant.cle,
          "Content-Type": fichier.type,
          "x-upsert": "false",
        },
        body: new Uint8Array(contenu),
      },
    );
    // Un envoi raté ne doit pas laisser croire que la photo est là : on rend
    // null, et l'appelant n'enregistre aucune ligne. Mais on retient pourquoi :
    // « refusé » sans raison ne se corrige pas.
    if (!reponse.ok) {
      dernierEchec = `${reponse.status} ${(await reponse.text()).slice(0, 200)}`;
      return null;
    }
    dernierEchec = null;
    return nom;
  }

  await mkdir(RACINE, { recursive: true });
  await writeFile(path.join(RACINE, nom), contenu);
  return nom;
}

export async function lireFichier(nom: string): Promise<Buffer | null> {
  if (!sur(nom)) return null;
  const distant = supabase();

  if (distant) {
    const reponse = await fetch(
      `${distant.url}/storage/v1/object/${SEAU}/${nom}`,
      { headers: { Authorization: `Bearer ${distant.cle}`, apikey: distant.cle } },
    );
    if (!reponse.ok) return null;
    return Buffer.from(await reponse.arrayBuffer());
  }

  try {
    return await readFile(path.join(RACINE, nom));
  } catch {
    return null;
  }
}

export async function supprimerFichier(nom: string): Promise<void> {
  if (!sur(nom)) return;
  const distant = supabase();
  if (distant) {
    await fetch(`${distant.url}/storage/v1/object/${SEAU}/${nom}`, {
      method: "DELETE",
        headers: { Authorization: `Bearer ${distant.cle}`, apikey: distant.cle },
    });
  }
  // En local on laisse le fichier : il ne gêne personne, et le retrouver rend
  // service quand on s'est trompé.
}

export function typeMime(nom: string): string {
  const extension = nom.split(".").pop() ?? "";
  return (
    Object.entries(EXTENSIONS).find(([, e]) => e === extension)?.[0] ??
    "application/octet-stream"
  );
}

/** Le dépôt réellement utilisé, pour que l'écran d'administration le dise. */
export function depot(): "supabase" | "disque" {
  return supabase() ? "supabase" : "disque";
}

/** Les deux noms d'origine, conservés là où l'on ne manipule que des photos. */
export const enregistrerPhoto = enregistrerFichier;
export const lirePhoto = lireFichier;

export type Verdict = {
  depot: "supabase" | "disque";
  seau: string;
  ecrit: boolean;
  relu: boolean;
  identique: boolean;
  detail: string;
};

/**
 * Le dépôt fonctionne-t-il vraiment ?
 *
 * Une photo peut s'enregistrer et rester introuvable : c'est ce qui arrive
 * quand les variables Supabase manquent. Le fichier part alors sur le disque
 * de la machine qui a traité l'envoi — et la lecture, servie par une autre
 * machine, ne le trouve pas. Rien ne le dit : la ligne existe, l'image est
 * vide.
 *
 * On écrit donc un fichier minuscule, on le relit, on compare, on l'efface.
 * C'est le seul moyen de répondre depuis l'écran, sans deviner.
 */
export async function verifierDepot(): Promise<Verdict> {
  const ou = depot();
  const verdict: Verdict = {
    depot: ou,
    seau: SEAU,
    ecrit: false,
    relu: false,
    identique: false,
    detail: "",
  };

  // Un PNG d'un pixel : le plus petit fichier valide qu'on puisse déposer.
  const pixel = Buffer.from(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==",
    "base64",
  );
  const essai = new File([new Uint8Array(pixel)], "essai.png", { type: "image/png" });

  const nom = await enregistrerFichier(essai);
  if (!nom) {
    verdict.detail =
      ou === "supabase"
        ? `Supabase a refusé l'écriture — ${dernierEchec ?? "sans réponse"}.` +
          (dernierEchec?.startsWith("404")
            ? ` Le seau « ${SEAU} » n'existe pas : créez-le dans Storage, en privé.`
            : dernierEchec?.startsWith("40")
              ? " La clé n'a pas le droit d'écrire : reprenez la clé secrète (sb_secret_…) dans Connect → Server."
              : "")
        : "L'écriture sur le disque a échoué.";
    return verdict;
  }
  verdict.ecrit = true;

  const relu = await lireFichier(nom);
  verdict.relu = relu !== null;
  verdict.identique = relu !== null && relu.equals(pixel);

  await supprimerFichier(nom);

  if (!verdict.relu) {
    verdict.detail = "Le fichier s'écrit mais ne se relit pas.";
  } else if (!verdict.identique) {
    verdict.detail = "Le fichier relu ne correspond pas à celui écrit.";
  } else if (ou === "disque") {
    verdict.detail =
      "Le dépôt fonctionne, mais sur le disque du serveur : en ligne, chaque " +
      "machine a le sien, et une photo enregistrée par l'une est introuvable " +
      "pour l'autre. Renseignez SUPABASE_URL et SUPABASE_SECRET_KEY.";
  } else {
    verdict.detail = "Le dépôt fonctionne : écrit, relu, identique.";
  }
  return verdict;
}
