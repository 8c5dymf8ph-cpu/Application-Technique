import { sql } from "./db";
import { viderLaFileEnFond } from "./envoi";
import {
  corpsAlerteBouteille,
  objetAlerteBouteille,
  type LigneBouteille,
} from "./courriel";

/**
 * Déposer l'alerte « bouteille manquante » pour un dossier.
 *
 * Elle part à la RÉCEPTION dès le constat, sans attendre que quelqu'un la
 * transmette : le client est peut-être encore là. Jamais au client lui-même —
 * c'est la réception qui lui parle, avec le texte préparé.
 *
 * Ce code vivait en double : une fois dans l'écran de déclaration, une fois
 * dans celui du dossier. Et dans le second, il était écrit comme une fonction
 * `"use server"` imbriquée, appelée par une autre action du même écran —
 * `avancer` changeait le statut, puis appelait `mettreEnFile`, qui n'existait
 * pas à l'exécution. Le dossier passait donc à « transmis » et **aucun message
 * n'était déposé**. En silence : l'action plantait après l'écriture, et on
 * croyait la réception prévenue.
 *
 * Une fonction de module, appelée par l'action, n'a pas ce problème : elle
 * n'est pas une action, elle n'a pas à en être une.
 */

type Dossier = {
  reference: number;
  emplacement: string;
  client_nom: string | null;
  constate_par: string | null;
  transmis_a: string | null;
  constate_le: string;
  lignes: LigneBouteille[];
  montant: number;
};

/**
 * Laquelle des quatre situations s'applique.
 *
 * Une alerte qui ne part pas doit le dire sur-le-champ : l'écran se taisait, et
 * on croyait la réception prévenue alors que rien n'avait bougé.
 */
export type Verdict =
  | "alerte-partie"
  | "alerte-sans-destinataire"
  | "alerte-eteinte"
  | "alerte-sans-cle";

export async function deposerAlerteBouteille(dossier: string): Promise<Verdict> {
  const [alerte] = await sql<{ destinataires: string[]; actif: boolean }[]>`
    select destinataires, actif from alertes_destinataires
    where evenement = 'incident_bouteille'`;

  if (!alerte?.actif) return "alerte-eteinte";
  if (alerte.destinataires.length === 0) return "alerte-sans-destinataire";

  const [d] = await sql<Dossier[]>`
    select reference, emplacement, client_nom, constate_par, transmis_a,
           constate_le, lignes, montant
    from v_dossiers_bouteille where id = ${dossier}`;
  if (!d) return "alerte-sans-destinataire";

  // Une seule mise en file par dossier : on ne renvoie pas le même message
  // parce que quelqu'un a rouvert l'écran.
  await sql`
    insert into emails_envoyes (categorie, reference_id, destinataires, sujet, corps)
    select 'alerte_bouteille', ${dossier}::uuid, ${alerte.destinataires},
           ${objetAlerteBouteille(d)}, ${corpsAlerteBouteille(d)}
    where not exists (
      select 1 from emails_envoyes e
       where e.reference_id = ${dossier}::uuid and e.categorie = 'alerte_bouteille')`;

  // La réception doit l'avoir tout de suite. On ne fait pas attendre l'écran
  // pour autant : la file se vide après la réponse.
  viderLaFileEnFond();

  return process.env.RESEND_API_KEY ? "alerte-partie" : "alerte-sans-cle";
}
