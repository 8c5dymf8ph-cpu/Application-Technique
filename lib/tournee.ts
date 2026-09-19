import { sql } from "./db";
import { deposerRecap } from "./recap";

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
 * La tournée du jour d'un intervenant, ou une nouvelle.
 *
 * **Un passage ne s'étale pas sur deux jours.** Un technicien vient le lundi,
 * la gouvernante ne finit de vérifier que le mardi — et le mardi il revient
 * pour autre chose. Ce sont deux passages, qui se valident séparément. Une
 * tournée restée ouverte d'un jour précédent est donc rendue telle quelle : le
 * travail du lundi part chez la gouvernante, celui du mardi commence à neuf.
 *
 * C'est aussi ce que dit la règle 16 : un passage, c'est qui est venu et quel
 * jour.
 */
export async function tourneeEnCours(i: Intervenant): Promise<Tournee> {
  // Ce qu'il a laissé ouvert un autre jour : on le rend pour lui, et le
  // récapitulatif de clôture part comme s'il avait appuyé sur « Fin
  // d'intervention ».
  const oubliees = await sql<{ id: string }[]>`
    update tournees set cloturee_le = now()
     where cloturee_le is null
       and date_tournee < current_date
       and technicien_id  is not distinct from ${i.utilisateur_id}
       and prestataire_id is not distinct from ${i.prestataire_id}
    returning id`;
  for (const t of oubliees) await deposerRecap(t.id, false);

  const [existante] = await sql<Tournee[]>`
    select t.id, t.reference, t.date_tournee,
           (select count(*) from interventions x where x.tournee_id = t.id)::int as nb_interventions
    from tournees t
    where t.cloturee_le is null
      and t.date_tournee = current_date
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
