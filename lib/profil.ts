import { cookies } from "next/headers";
import { sql } from "./db";
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

export async function profilsDisponibles(): Promise<Profil[]> {
  return sql<Profil[]>`
    select id, nom, role from utilisateurs
    where actif order by
      case role when 'admin' then 0 when 'gouvernante' then 1 else 2 end, nom`;
}

export async function choisirProfil(id: string) {
  (await cookies()).set(COOKIE, id, {
    httpOnly: true,
    sameSite: "lax",
    maxAge: 60 * 60 * 24 * 90,
    path: "/",
  });
}
