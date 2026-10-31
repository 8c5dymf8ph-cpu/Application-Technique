import { NextResponse, type NextRequest } from "next/server";
import { COOKIE_ACCES, etatAcces, jetonValide } from "@/lib/acces-hotel";

/**
 * La porte : rien ne passe sans le code de l'hôtel (lib/acces-hotel.ts).
 *
 * Posée ici, devant CHAQUE requête, et pas dans la mise en page : une mise en
 * page ne voit ni les photos, ni les exports, ni les actions, et le routeur
 * peut ne pas la rejouer d'un écran à l'autre. Ce qui reste dehors :
 * l'écran du code lui-même, l'envoi planifié (protégé par son propre secret),
 * et ce que le navigateur charge sans rien révéler — scripts, manifeste,
 * robots.txt.
 *
 * Un écran renvoie vers `/acces`, en gardant l'adresse demandée pour y revenir.
 * Une photo ou un export répond 401 : rediriger une image n'aurait aucun sens.
 */
export async function proxy(requete: NextRequest) {
  let etat;
  try {
    etat = await etatAcces();
  } catch {
    // Sans la base, on ne peut pas savoir si l'appareil a le droit d'entrer :
    // on ne laisse rien passer, et on le dit.
    return new NextResponse("La base ne répond pas — réessayez dans un instant.", {
      status: 503,
      headers: { "content-type": "text/plain; charset=utf-8" },
    });
  }

  if (!etat.actif) return NextResponse.next();
  if (jetonValide(requete.cookies.get(COOKIE_ACCES)?.value, etat)) return NextResponse.next();

  const { pathname, search } = requete.nextUrl;
  if (pathname.startsWith("/api/") || pathname.startsWith("/photo/")) {
    return new NextResponse("Code d’accès requis.", {
      status: 401,
      headers: { "content-type": "text/plain; charset=utf-8" },
    });
  }
  const vers = new URL("/acces", requete.url);
  if (pathname !== "/") vers.searchParams.set("suite", pathname + search);
  return NextResponse.redirect(vers);
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|manifest.webmanifest|robots.txt|icon|apple-icon|acces|api/envoi).*)",
  ],
};
