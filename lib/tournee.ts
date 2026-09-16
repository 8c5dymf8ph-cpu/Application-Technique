import { sql } from "./db";

export type Intervenant = {
  utilisateur_id: string | null;
  prestataire_id: string | null;
  nom: string;
  origine: "interne" | "externe";
  specialites: string[];
};

export type Tournee = {
  id: string;
  reference: string;
  date_tournee: string;
  nb_interventions: number;
};

export async function intervenants(): Promise<Intervenant[]> {
  return sql<Intervenant[]>`
    select utilisateur_id, prestataire_id, nom, origine, specialites
    from v_intervenants where actif order by origine, nom`;
}

/**
 * La tournée en cours d'un intervenant, ou une nouvelle.
 *
 * Une tournée est le lot qu'il rendra d'un coup : tant qu'elle n'est pas
 * close, tout ce qu'il traite s'y rattache, même s'il revient le lendemain.
 */
export async function tourneeEnCours(i: Intervenant): Promise<Tournee> {
  const [existante] = await sql<Tournee[]>`
    select t.id, t.reference, t.date_tournee,
           (select count(*) from interventions x where x.tournee_id = t.id)::int as nb_interventions
    from tournees t
    where t.cloturee_le is null
      and (t.technicien_id is not distinct from ${i.utilisateur_id}
       and t.prestataire_id is not distinct from ${i.prestataire_id})
    order by t.cree_le desc limit 1`;
  if (existante) return existante;

  const [creee] = await sql<{ id: string }[]>`
    select id from fn_creer_tournee(${i.utilisateur_id}, ${i.prestataire_id})`;
  const [t] = await sql<Tournee[]>`
    select id, reference, date_tournee, 0::int as nb_interventions
    from tournees where id = ${creee.id}`;
  return t;
}
