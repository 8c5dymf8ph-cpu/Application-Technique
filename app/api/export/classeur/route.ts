import { NextResponse } from "next/server";
import { profilActif } from "@/lib/profil";
import { aujourdhuiISO, suitLesDossiers } from "@/lib/domaine";
import { construireClasseur } from "@/lib/classeur";

export const dynamic = "force-dynamic";

/**
 * Toute l'application, dans un seul fichier — la sauvegarde.
 *
 * Même principe que `/api/export/[quoi]` : construit à l'instant où l'on
 * appuie, réservé à l'administration. Un seul fichier `.xlsx`, un onglet par
 * tableau : c'est celui qu'on garde de côté pour le jour où il faut reprendre
 * sans l'application.
 */
export async function GET() {
  const profil = await profilActif();
  if (!suitLesDossiers(profil?.role)) {
    return new NextResponse("Réservé à l’administration.", { status: 403 });
  }

  const classeur = await construireClasseur();
  return new NextResponse(classeur, {
    headers: {
      "content-type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
      "content-disposition": `attachment; filename="sauvegarde-${aujourdhuiISO()}.xlsx"`,
      "cache-control": "no-store",
    },
  });
}
