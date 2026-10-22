import { NextResponse } from "next/server";
import { profilActif } from "@/lib/profil";
import { aujourdhuiISO, peutValider } from "@/lib/domaine";
import { codeDepuis } from "@/lib/suivis";
import { genererPdfSuivi } from "@/lib/pdf-suivi";

export const dynamic = "force-dynamic";

/**
 * Le récapitulatif PDF d'un dossier de suivi, avec les pièces cochées sur
 * l'écran du dossier (`?piece=…&piece=…`) ajoutées à la fin. Réservé à
 * l'encadrement, comme l'écran lui-même.
 */
export async function GET(
  requete: Request,
  { params }: { params: Promise<{ id: string }> },
) {
  const profil = await profilActif();
  if (!peutValider(profil?.role)) {
    return new NextResponse("Réservé à l’encadrement.", { status: 403 });
  }

  const { id } = await params;
  const pieces = new URL(requete.url).searchParams
    .getAll("piece")
    .filter((p) => /^[0-9a-f-]{36}$/i.test(p));

  let resultat: Awaited<ReturnType<typeof genererPdfSuivi>>;
  try {
    resultat = await genererPdfSuivi(id, pieces);
  } catch {
    return new NextResponse("Dossier introuvable.", { status: 404 });
  }

  return new NextResponse(Buffer.from(resultat.pdf), {
    headers: {
      "content-type": "application/pdf",
      "content-disposition": `attachment; filename="suivi-${codeDepuis(resultat.titre)}-${aujourdhuiISO()}.pdf"`,
      "cache-control": "no-store",
    },
  });
}
