import { readFile, readdir } from "node:fs/promises";
import path from "node:path";
import { sql } from "./db";

/**
 * Mettre la base à jour depuis l'application.
 *
 * Jusqu'ici une migration s'appliquait depuis GitHub, onglet Actions. Ça
 * marche — quand on y pense, qu'on trouve le bon bouton, et qu'on lit le
 * journal pour savoir si c'est passé. Entre-temps l'application affiche des
 * écrans à moitié morts et personne ne sait pourquoi : « donner un profil ne
 * fonctionne pas » a duré trois allers-retours.
 *
 * L'application a déjà la chaîne de connexion — c'est elle qui lit et écrit
 * toute la journée. Elle peut donc jouer les fichiers manquants elle-même, et
 * dire ce qu'elle a fait. Un bouton, une ligne par fichier, le verdict à
 * l'écran.
 *
 * Trois garde-fous :
 * — seul un administrateur peut le lancer (l'écran s'en charge) ;
 * — chaque fichier est joué DANS UNE TRANSACTION : il passe entièrement ou
 *   pas du tout, et le suivant n'est pas tenté ;
 * — `migrations_appliquees` retient ce qui est passé, donc rien n'est rejoué.
 *
 * Les fichiers sont écrits pour être rejouables (`if not exists`,
 * `create or replace`) : les rejouer sur une base à jour ne casse rien. Mais
 * on ne les rejoue pas pour autant — le journal est là pour ça.
 */

export type Jouee = {
  fichier: string;
  etat: "déjà appliquée" | "appliquée" | "échec" | "non tentée";
  erreur?: string;
};

/** Le dossier des migrations, tel qu'il est déployé. */
function dossier(): string {
  return path.join(process.cwd(), "supabase", "migrations");
}

/**
 * Les trois premiers fichiers posent le schéma d'un bloc.
 *
 * Une base installée avant l'existence du journal les porte déjà : les
 * rejouer tenterait de recréer des types qui existent. On les inscrit donc
 * sans les jouer, exactement comme le fait le script de GitHub.
 */
const INITIALES = [
  "0001_schema_initial.sql",
  "0002_vues_et_regles.sql",
  "0003_securite.sql",
];

async function preparerLeJournal() {
  await sql`
    create table if not exists migrations_appliquees (
      fichier  text primary key,
      jouee_le timestamptz not null default now()
    )`;
  const [deja] = await sql<{ pose: boolean }[]>`
    select to_regclass('public.anomalies') is not null as pose`;
  if (deja.pose) {
    await sql`
      insert into migrations_appliquees (fichier)
      select unnest(${INITIALES}::text[])
      on conflict do nothing`;
  }
}

/** Les fichiers qui restent à jouer, dans l'ordre. */
export async function migrationsEnAttente(): Promise<string[]> {
  let fichiers: string[];
  try {
    fichiers = (await readdir(dossier())).filter((f) => f.endsWith(".sql")).sort();
  } catch {
    // Les fichiers ne sont pas dans le déploiement : on ne prétend pas pouvoir
    // mettre à jour. L'écran le dira.
    return [];
  }
  await preparerLeJournal();
  const jouees = await sql<{ fichier: string }[]>`select fichier from migrations_appliquees`;
  const faites = new Set(jouees.map((j) => j.fichier));
  return fichiers.filter((f) => !faites.has(f));
}

/**
 * Jouer ce qui manque.
 *
 * Un échec arrête la série : les migrations se suivent, et jouer la suivante
 * sur une base à moitié migrée ferait pire. Le message d'erreur est rendu tel
 * quel — c'est lui qui dit quoi corriger.
 */
export async function appliquerLesMigrations(): Promise<Jouee[]> {
  const restantes = await migrationsEnAttente();
  const resultats: Jouee[] = [];
  let arrete = false;

  for (const fichier of restantes) {
    if (arrete) {
      resultats.push({ fichier, etat: "non tentée" });
      continue;
    }
    const contenu = await readFile(path.join(dossier(), fichier), "utf8");
    try {
      await sql.begin(async (tx) => {
        await tx.unsafe(contenu);
        await tx`insert into migrations_appliquees (fichier) values (${fichier})`;
      });
      resultats.push({ fichier, etat: "appliquée" });
    } catch (e) {
      resultats.push({
        fichier,
        etat: "échec",
        erreur: e instanceof Error ? e.message : String(e),
      });
      arrete = true;
    }
  }
  return resultats;
}
