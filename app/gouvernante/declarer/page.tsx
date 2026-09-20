import Link from "next/link";
import { sql } from "@/lib/db";
import { colonneExiste } from "@/lib/schema";
import { Confirmation, Entete } from "../../composants/ui";

export const dynamic = "force-dynamic";

type Lieu = { code: string; etage: string; ordre_etage: number; ouvertes: number; essai: boolean };

export default async function ChoixLieu({
  searchParams,
}: {
  searchParams: Promise<{ fait?: string; ou?: string }>;
}) {
  const { fait, ou } = await searchParams;
  // Le nombre d'anomalies encore ouvertes s'affiche dès le choix du lieu :
  // c'est le premier signal, avant même d'entrer dans la chambre.
  // `essai` n'existe qu'après la migration 0008 : d'ici là, aucun lieu n'est
  // marqué, ce qui est exactement l'état d'avant.
  const marque = await colonneExiste("emplacements", "essai");
  const lieux = await sql<Lieu[]>`
    select e.code, et.nom as etage, et.ordre as ordre_etage,
           ${marque ? sql`e.essai` : sql`false`} as essai,
           count(a.id) filter (
             where a.statut in ('a_faire','en_cours','a_acheter')
           )::int as ouvertes
    from emplacements e
    join etages et on et.id = e.etage_id
    left join anomalies a on a.emplacement_id = e.id
    where e.actif
    group by e.id, et.nom, et.ordre, e.ordre, e.code
    order by et.ordre, e.ordre, e.code`;

  const etages = [...new Set(lieux.map((l) => l.etage))];

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Déclarer" sous_titre="Choisir le lieu" retour="/gouvernante" />
      {fait && (
        <div className="px-5 pt-4">
          <Confirmation quoi={fait} />
          {ou && fait.startsWith("declare") && (
            <p className="text-[12.5px] text-ink-faint pt-1">En {ou}.</p>
          )}
        </div>
      )}
      <div className="px-5 py-4 flex flex-col gap-2">
        {etages.map((etage) => {
          const dedans = lieux.filter((l) => l.etage === etage);
          const ouvertes = dedans.reduce((n, l) => n + l.ouvertes, 0);
          return (
            // Un étage par ligne, replié : la liste complète faisait défiler
            // sur trois écrans avant d'atteindre le cinquième.
            <details key={etage} className="carte overflow-hidden group">
              <summary
                data-cible
                className="px-4 flex items-center gap-3 cursor-pointer list-none select-none"
              >
                <svg
                  width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8E8AA3"
                  strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                  className="shrink-0 transition-transform group-open:rotate-90"
                >
                  <path d="M9 5l7 7-7 7" />
                </svg>
                <span className="font-display font-semibold text-[17px] grow">{etage}</span>
                <span className="text-[12.5px] text-ink-faint tabular-nums">
                  {dedans.length} lieux
                </span>
                {ouvertes > 0 && (
                  <span className="min-w-[26px] h-[26px] px-1.5 rounded-lg bg-amber-soft text-amber text-[13px] grid place-items-center tabular-nums">
                    {ouvertes}
                  </span>
                )}
              </summary>
              <div className="flex flex-wrap gap-2 px-4 pb-4 pt-1">
                {dedans.map((l) => (
                  <Link
                    key={l.code}
                    href={`/gouvernante/declarer/${encodeURIComponent(l.code)}`}
                    data-cible
                    className={`relative px-3.5 flex items-center justify-center min-w-[54px] rounded-pill border text-[15px] active:bg-plum-soft ${
                      l.essai
                        ? "border-dashed border-plum bg-plum-soft text-plum"
                        : "border-line bg-surface-muted"
                    }`}
                  >
                    {l.code}
                    {/* Un lieu d'essai se voit : on y fait ce qu'on veut, et
                        rien de ce qu'on y fait ne compte dans les chiffres. */}
                    {l.essai && <span className="ml-1.5 text-[11px]">essai</span>}
                    {l.ouvertes > 0 && (
                      <span
                        className="absolute -top-1.5 -right-1.5 min-w-[20px] h-5 px-1 rounded-full bg-amber text-white text-[11px] grid place-items-center tabular-nums"
                        aria-label={`${l.ouvertes} en cours`}
                      >
                        {l.ouvertes}
                      </span>
                    )}
                  </Link>
                ))}
              </div>
            </details>
          );
        })}
      </div>
    </main>
  );
}
