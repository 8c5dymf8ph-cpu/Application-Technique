import { after } from "next/server";
import { sql } from "./db";

/**
 * L'envoi des courriels en attente.
 *
 * L'application ne poste jamais un mail au moment où quelqu'un appuie sur un
 * bouton : elle rédige le message et le dépose dans `emails_envoyes` avec
 * `envoye_le` nul. Cette fonction vide la file. Un échec n'efface rien : la
 * ligne reste, avec son erreur, et repartira au prochain passage.
 *
 * Resend, offre gratuite : 100 messages par jour, 3 000 par mois. L'hôtel en
 * enverra quelques-uns par jour — la marge est large.
 */

type Courriel = {
  id: string;
  categorie: string;
  destinataires: string[];
  sujet: string;
  corps: string | null;
};

export type Resultat = {
  tentes: number;
  envoyes: number;
  echoues: number;
  ignores: number;
  erreurs: string[];
};

/** L'expéditeur, et la clé. Sans clé, rien ne part : c'est dit, pas contourné. */
function reglages() {
  return {
    cle: process.env.RESEND_API_KEY ?? "",
    expediteur: process.env.MAIL_EXPEDITEUR ?? "Parisianer <onboarding@resend.dev>",
  };
}

/**
 * Poster un message. Renvoie l'erreur en clair plutôt que de la masquer : une
 * adresse invalide ou un domaine non vérifié doit se lire dans le journal.
 */
async function poster(c: Courriel, cle: string, expediteur: string): Promise<string | null> {
  const reponse = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${cle}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: expediteur,
      to: c.destinataires,
      subject: c.sujet,
      text: c.corps ?? "",
    }),
  });
  if (reponse.ok) return null;
  const detail = await reponse.text();
  return `${reponse.status} ${detail.slice(0, 300)}`;
}

/**
 * Vider la file.
 *
 * `limite` borne un passage : mieux vaut plusieurs passages courts qu'un seul
 * qui expire au milieu et laisse la moitié des lignes dans un état incertain.
 */
export async function envoyerCourrielsEnAttente(limite = 25): Promise<Resultat> {
  const { cle, expediteur } = reglages();
  const resultat: Resultat = { tentes: 0, envoyes: 0, echoues: 0, ignores: 0, erreurs: [] };

  const attente = await sql<Courriel[]>`
    select id, categorie, destinataires, sujet, corps
    from v_courriels_en_attente limit ${limite}`;
  resultat.tentes = attente.length;
  if (attente.length === 0) return resultat;

  if (!cle) {
    // Pas de clé : on ne prétend pas avoir envoyé. La file reste intacte.
    resultat.ignores = attente.length;
    resultat.erreurs.push("RESEND_API_KEY absente : aucun message n'a été envoyé.");
    return resultat;
  }

  for (const c of attente) {
    // Un message sans destinataire ne partira jamais : on le marque en échec
    // plutôt que de le représenter indéfiniment.
    if (c.destinataires.length === 0) {
      await sql`
        update emails_envoyes
           set envoye_le = now(), succes = false, erreur = 'aucun destinataire'
         where id = ${c.id}`;
      resultat.echoues += 1;
      continue;
    }

    let erreur: string | null;
    try {
      erreur = await poster(c, cle, expediteur);
    } catch (e) {
      erreur = e instanceof Error ? e.message : String(e);
    }

    if (erreur === null) {
      await sql`
        update emails_envoyes set envoye_le = now(), succes = true, erreur = null
         where id = ${c.id}`;
      resultat.envoyes += 1;
    } else {
      // La ligne reste en attente : elle repartira au prochain passage. On garde
      // seulement la trace de ce qui a échoué, pour pouvoir le lire.
      await sql`update emails_envoyes set erreur = ${erreur} where id = ${c.id}`;
      resultat.echoues += 1;
      resultat.erreurs.push(`${c.categorie} : ${erreur}`);
    }
  }

  return resultat;
}

/**
 * Vider la file sans faire attendre celui qui vient de déposer.
 *
 * L'offre gratuite de Vercel n'accepte qu'une tâche planifiée par jour : le
 * passage régulier ne peut plus être le chemin normal. Or l'alerte bouteille
 * doit partir **dès le constat** — le client est peut-être encore là. L'envoi
 * se déclenche donc à la fin de la requête qui a déposé le message, une fois
 * la réponse rendue : l'écran ne ralentit pas.
 *
 * Un échec ici n'a rien de grave et ne remonte pas : la ligne reste dans la
 * file avec son erreur, et le passage quotidien la reprendra.
 */
export function viderLaFileEnFond(): void {
  after(async () => {
    try {
      await envoyerCourrielsEnAttente();
    } catch {
      // La file garde la ligne : le prochain passage réessaiera.
    }
  });
}
