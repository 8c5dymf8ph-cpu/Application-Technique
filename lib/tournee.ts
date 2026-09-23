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
  /** Le lot a été rendu. Le passage reste celui du jour : on peut le reprendre. */
  cloturee_le: string | null;
};

export async function intervenants(): Promise<Intervenant[]> {
  return sql<Intervenant[]>`
    select utilisateur_id, prestataire_id, nom, origine, specialites
    -- Un seul ordre : le nom. Trier par origine d'abord laissait croire
    -- à deux catégories, alors qu'ils interviennent tous pareil.
    from v_intervenants where actif order by nom`;
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
export async function tourneeEnCours(
  i: Intervenant,
  /**
   * Le jour du passage. Absent, c'est aujourd'hui.
   *
   * Miguel et Sarah P reprennent de l'historique : un passage d'il y a trois
   * semaines se saisit à SA date, sinon il arrive daté d'aujourd'hui et la
   * facture ne se rapproche plus de rien (règle 16). Réservé à
   * `suitLesDossiers` — un technicien ne date pas son propre passage.
   */
  jour?: string,
): Promise<Tournee> {
  // Ce qu'il a laissé ouvert un autre jour : on le rend pour lui, et le
  // récapitulatif de clôture part comme s'il avait appuyé sur « Fin
  // d'intervention ».
  // Une saisie d'historique ne rend rien pour personne : on ouvre la journée
  // demandée, et le passage d'aujourd'hui reste où il en est.
  if (!jour) {
    const oubliees = await sql<{ id: string }[]>`
      update tournees set cloturee_le = now()
       where cloturee_le is null
         and date_tournee < current_date
         and technicien_id  is not distinct from ${i.utilisateur_id}
         and prestataire_id is not distinct from ${i.prestataire_id}
      returning id`;
    for (const t of oubliees) await deposerRecap(t.id, false);
  }

  // La tournée du jour, RENDUE OU NON. C'est la racine : un passage, c'est qui
  // est venu et quel jour (règle 16). Ne rendre que les tournées ouvertes en
  // ouvrait une seconde dès qu'il revenait l'après-midi — trois passages dans
  // l'historique pour une journée, et autant de récapitulatifs. La base
  // l'interdit désormais (index `passage_unique_par_intervenant_et_jour`),
  // et `fn_creer_tournee` retrouve celle du jour plutôt que d'en ouvrir une.
  const [creee] = await sql<{ id: string }[]>`
    select id from fn_creer_tournee(${i.utilisateur_id}, ${i.prestataire_id},
                                    ${jour ?? null}::date)`;
  const [t] = await sql<Tournee[]>`
    select t.id, t.reference, t.date_tournee, t.cloturee_le,
           (select count(*) from interventions x where x.tournee_id = t.id)::int
             as nb_interventions
    from tournees t where t.id = ${creee.id}`;
  return t;
}
