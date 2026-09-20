import { NextResponse } from "next/server";
import { profilActif } from "@/lib/profil";
import { aujourdhuiISO, suitLesDossiers } from "@/lib/domaine";
import { EXPORTS, enCSV } from "@/lib/export";

export const dynamic = "force-dynamic";

/**
 * Un export, tel quel.
 *
 * Le fichier porte la date du jour dans son nom : on en garde plusieurs sans
 * les confondre, et on voit d'un coup d'œil de quand date celui qu'on ouvre.
 *
 * C'est l'application entière qui sort par ici : réservé à l'administration.
 */
export async function GET(
  _requete: Request,
  { params }: { params: Promise<{ quoi: string }> },
) {
  const profil = await profilActif();
  if (!suitLesDossiers(profil?.role)) {
    return new NextResponse("Réservé à l’administration.", { status: 403 });
  }

  const { quoi } = await params;
  const choisi = EXPORTS.find((e) => e.cle === quoi);
  if (!choisi) return new NextResponse("Export inconnu.", { status: 404 });

  const csv = enCSV(await choisi.lignes());
  return new NextResponse(csv, {
    headers: {
      "content-type": "text/csv; charset=utf-8",
      "content-disposition": `attachment; filename="${quoi}-${aujourdhuiISO()}.csv"`,
      "cache-control": "no-store",
    },
  });
}
