import { cookies } from "next/headers";
import { sql } from "./db";
import { colonneExiste } from "./schema";
import type { RoleUtilisateur } from "./domaine";

export type Profil = {
  id: string;
  nom: string;
  role: RoleUtilisateur;
};

const COOKIE = "profil";

/**
 * Le profil actif.
 *
 * L'hôtel partage un seul compte : l'application enregistre donc qui déclare
 * agir, sans pouvoir le vérifier. Toute écriture porte ce profil ET le compte
 * qui a réellement saisi — c'est la trace qui compte, et la limite est assumée.
 */
export async function profilActif(): Promise<Profil | null> {
  const id = (await cookies()).get(COOKIE)?.value;
  if (!id) return null;
  const [p] = await sql<Profil[]>`
    select id, nom, role from utilisateurs where id = ${id} and actif`;
  return p ?? null;
}

/**
 * Les profils que l'on peut endosser.
 *
 * Les femmes de chambre et la réception sont citées dans les déclarations —
 * qui a constaté, à qui c'est remonté — mais elles n'utilisent pas
 * l'application : elles n'apparaissent donc pas ici.
 */
export async function profilsDisponibles(): Promise<Profil[]> {
  // `peut_se_connecter` est un réglage, tenu depuis /administration/equipe :
  // l'hôtel change d'intervenants, et deux techniciens ne doivent pas
  // apparaître d'office parce qu'ils se trouvaient dans cette table.
  const colonne = await colonneExiste("utilisateurs", "peut_se_connecter");
  return colonne
    ? sql<Profil[]>`
        select id, nom, role from utilisateurs
        where actif and peut_se_connecter and role not in ('menage', 'reception')
        order by
          case role when 'admin' then 0 when 'gouvernante' then 1 else 2 end, nom`
    : sql<Profil[]>`
        select id, nom, role from utilisateurs
        where actif and role not in ('menage', 'reception')
        order by
          case role when 'admin' then 0 when 'gouvernante' then 1 else 2 end, nom`;
}

/** Qui peut être désigné comme ayant constaté, et à qui l'on transmet. */
export async function personnes(roles: RoleUtilisateur[]): Promise<Profil[]> {
  return sql<Profil[]>`
    select id, nom, role from utilisateurs
    where actif and role = any(${roles}) order by nom`;
}

export async function choisirProfil(id: string) {
  (await cookies()).set(COOKIE, id, {
    httpOnly: true,
    sameSite: "lax",
    maxAge: 60 * 60 * 24 * 90,
    path: "/",
  });
}
