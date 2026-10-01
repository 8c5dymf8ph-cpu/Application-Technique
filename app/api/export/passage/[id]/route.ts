import { NextResponse } from "next/server";
import { profilActif } from "@/lib/profil";
import { aujourdhuiISO, peutValider } from "@/lib/domaine";
import { genererPdfPassage } from "@/lib/pdf-passage";

export const dynamic = "force-dynamic";

/**
 * Le PDF d'un passage : mêmes données que l'écran, pour le garder, l'imprimer
 * ou le joindre à un échange. Réservé à l'encadrement, comme l'écran lui-même
 * (`exigerEncadrement` sur `/technique/tournee/[id]`).
 */
export async function GET(
  _requete: Request,
  { params }: { params: Promise<{ id: string }> },
) {
  const profil = await profilActif();
  if (!peutValider(profil?.role)) {
    return new NextResponse("Réservé à l’encadrement.", { status: 403 });
  }

  const { id } = await params;
  let pdf: Uint8Array;
  try {
    pdf = await genererPdfPassage(id);
  } catch {
    return new NextResponse("Passage introuvable.", { status: 404 });
  }

  return new NextResponse(Buffer.from(pdf), {
    headers: {
      "content-type": "application/pdf",
      "content-disposition": `attachment; filename="passage-${aujourdhuiISO()}.pdf"`,
      "cache-control": "no-store",
    },
  });
}
