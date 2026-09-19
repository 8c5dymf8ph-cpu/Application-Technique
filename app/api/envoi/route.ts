import { envoyerCourrielsEnAttente } from "@/lib/envoi";

export const dynamic = "force-dynamic";
export const maxDuration = 60;

/**
 * Le passage qui vide la file des courriels.
 *
 * Appelé par la tâche planifiée de Vercel (voir `vercel.json`), ou à la main
 * depuis l'écran de paramétrage. L'accès est protégé par un secret partagé :
 * sans lui, l'adresse est publique et n'importe qui pourrait déclencher des
 * envois.
 */
function autorise(requete: Request): boolean {
  const secret = process.env.CRON_SECRET;
  if (!secret) return false;
  const entete = requete.headers.get("authorization") ?? "";
  return entete === `Bearer ${secret}`;
}

export async function GET(requete: Request) {
  if (!autorise(requete)) {
    return Response.json({ erreur: "non autorisé" }, { status: 401 });
  }
  const resultat = await envoyerCourrielsEnAttente();
  return Response.json(resultat);
}

export async function POST(requete: Request) {
  return GET(requete);
}
