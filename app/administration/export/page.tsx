import { redirect } from "next/navigation";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { suitLesDossiers } from "@/lib/domaine";
import { EXPORTS } from "@/lib/export";
import { Entete } from "@/app/composants/ui";

export const dynamic = "force-dynamic";

/**
 * Sortir ses données.
 *
 * L'ancienne application était un tableau : on l'ouvrait, on triait, on
 * bricolait une somme. Celle-ci range mieux — mais des données qu'on ne peut
 * pas sortir ne sont pas vraiment à soi. Un appui, un fichier, ouvert d'un
 * double-clic dans Excel ou Numbers.
 */
export default async function Exporter() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!suitLesDossiers(profil.role)) redirect("/");

  // Le volume, pour que le fichier ne soit pas une surprise. Une seule requête :
  // ce sont des comptages, pas les données elles-mêmes.
  const [n] = await sql<
    {
      anomalies: number;
      interventions: number;
      passages: number;
      mouvements: number;
      produits: number;
      bouteilles: number;
      factures: number;
      commentaires: number;
    }[]
  >`
    select (select count(*) from anomalies)::int             as anomalies,
           (select count(*) from interventions)::int         as interventions,
           (select count(*) from tournees)::int              as passages,
           (select count(*) from mouvements_stock)::int      as mouvements,
           (select count(*) from produits)::int              as produits,
           (select count(*) from incidents_bouteille)::int   as bouteilles,
           (select count(*) from factures)::int              as factures,
           (select count(*) from v_fil_commentaires)::int    as commentaires`;

  const compte = n as unknown as Record<string, number>;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Exporter"
        sous_titre="Vos données, dans un tableur"
        retour="/administration"
      />

      <div className="px-5 py-4 flex flex-col gap-4">
        <p className="text-[13px] text-ink-soft text-pretty leading-snug">
          Chaque fichier est un tableau prêt à l’emploi : une ligne par fait, les codes
          remplacés par les noms, les colonnes en français. Il s’ouvre d’un double-clic dans
          Excel, Numbers ou Google Sheets — accents, dates et montants compris.
        </p>

        <ul className="flex flex-col gap-2">
          {EXPORTS.map((e) => (
            <li key={e.cle}>
              <a
                href={`/api/export/${e.cle}`}
                download
                className="carte px-4 py-3.5 flex items-center gap-3"
              >
                <span className="grow min-w-0">
                  <span className="block text-[15.5px] font-display font-semibold">
                    {e.titre}
                  </span>
                  <span className="block text-[12px] text-ink-faint text-pretty leading-snug mt-0.5">
                    {e.aide}
                  </span>
                  <span className="block text-[11.5px] text-ink-faint tabular-nums mt-1">
                    {compte[e.cle] ?? 0} ligne{(compte[e.cle] ?? 0) > 1 ? "s" : ""}
                  </span>
                </span>
                <span className="shrink-0 w-10 h-10 rounded-full bg-plum-soft text-plum grid place-items-center">
                  <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                       strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
                    <path d="M12 4v11m0 0l-4-4m4 4l4-4M5 19h14" />
                  </svg>
                </span>
              </a>
            </li>
          ))}
        </ul>

        <p className="text-[12px] text-ink-faint text-pretty leading-snug">
          Le nom du fichier porte la date du jour : gardez-en un par mois et vous avez votre
          propre sauvegarde, indépendante de l’application. Le fichier contient des noms de
          clients — il se range comme un document de l’hôtel.
        </p>
      </div>
    </main>
  );
}
