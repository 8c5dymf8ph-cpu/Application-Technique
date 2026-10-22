import { sql } from "./db";

/**
 * Où tourne le serveur, où est la base, et combien coûte UN aller-retour
 * entre les deux.
 *
 * Un écran fait huit à onze requêtes à la base, l'une après l'autre. Si le
 * serveur et la base sont sur deux continents, chaque requête traverse
 * l'Atlantique (~90 ms) : l'écran met une seconde à venir, et rien dans
 * l'application ne disait pourquoi. Ce relevé le dit en un coup d'œil.
 */

const VERS_VERCEL: Record<string, { lieu: string; vercel: string }> = {
  "eu-west-3": { lieu: "Paris", vercel: "cdg1" },
  "eu-central-1": { lieu: "Francfort", vercel: "fra1" },
  "eu-west-1": { lieu: "Irlande", vercel: "dub1" },
  "eu-west-2": { lieu: "Londres", vercel: "lhr1" },
  "eu-north-1": { lieu: "Stockholm", vercel: "arn1" },
  "us-east-1": { lieu: "Virginie", vercel: "iad1" },
  "us-east-2": { lieu: "Ohio", vercel: "cle1" },
  "us-west-1": { lieu: "Californie", vercel: "sfo1" },
};

const LIEUX_VERCEL: Record<string, string> = {
  cdg1: "Paris",
  fra1: "Francfort",
  dub1: "Dublin",
  lhr1: "Londres",
  arn1: "Stockholm",
  iad1: "Washington",
  cle1: "Cleveland",
  sfo1: "San Francisco",
};

export type Rapidite = {
  serveur: string | null;
  serveurLieu: string | null;
  base: string | null;
  baseLieu: string | null;
  conseil: string | null;
  msParAllerRetour: number;
};

export async function mesurerRapidite(): Promise<Rapidite> {
  // `VERCEL_REGION` n'existe qu'à l'exécution sur Vercel ; en local, null.
  const serveur = process.env.VERCEL_REGION ?? null;

  // Le pooler de Supabase porte la région dans son nom d'hôte :
  // aws-0-eu-west-3.pooler.supabase.com
  let base: string | null = null;
  try {
    const hote = new URL(process.env.DATABASE_URL ?? "").hostname;
    base = /aws-\d+-([a-z0-9-]+)\.pooler\.supabase\.com$/.exec(hote)?.[1] ?? null;
  } catch {
    base = null;
  }

  // Cinq allers-retours, on garde la médiane : le premier paie souvent
  // l'ouverture de la connexion.
  const temps: number[] = [];
  for (let i = 0; i < 5; i++) {
    const t0 = performance.now();
    await sql`select 1`;
    temps.push(performance.now() - t0);
  }
  temps.sort((a, b) => a - b);

  return {
    serveur,
    serveurLieu: serveur ? (LIEUX_VERCEL[serveur] ?? null) : null,
    base,
    baseLieu: base ? (VERS_VERCEL[base]?.lieu ?? null) : null,
    conseil: base ? (VERS_VERCEL[base]?.vercel ?? null) : null,
    msParAllerRetour: Math.round(temps[2]),
  };
}
