import Link from "next/link";
import { sql } from "@/lib/db";
import { Entete } from "../../composants/ui";

export const dynamic = "force-dynamic";

type Lieu = { code: string; etage: string; ordre_etage: number; ouvertes: number };

export default async function ChoixLieu() {
  // Le nombre d'anomalies déjà ouvertes s'affiche dès le choix du lieu :
  // c'est le premier signal contre les doublons, avant même d'entrer.
  const lieux = await sql<Lieu[]>`
    select e.code, et.nom as etage, et.ordre as ordre_etage,
           count(a.id) filter (
             where a.statut in ('a_faire','en_cours','attente_validation','a_acheter')
           )::int as ouvertes
    from emplacements e
    join etages et on et.id = e.etage_id
    left join anomalies a on a.emplacement_id = e.id
    where e.actif
    group by e.id, et.nom, et.ordre, e.ordre
    order by et.ordre, e.ordre, e.code`;

  const etages = [...new Map(lieux.map((l) => [l.etage, l.ordre_etage])).keys()];

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Déclarer" sous_titre="Choisir le lieu" retour="/gouvernante" />
      <div className="px-5 py-5 flex flex-col gap-6">
        {etages.map((etage) => (
          <section key={etage} className="flex flex-col gap-2.5">
            <h2 className="etiquette">{etage}</h2>
            <div className="flex flex-wrap gap-2">
              {lieux
                .filter((l) => l.etage === etage)
                .map((l) => (
                  <Link
                    key={l.code}
                    href={`/gouvernante/declarer/${encodeURIComponent(l.code)}`}
                    data-cible
                    className="carte relative px-3.5 flex items-center justify-center min-w-[54px] text-[15px] active:bg-surface-muted"
                  >
                    {l.code}
                    {l.ouvertes > 0 && (
                      <span
                        className="absolute -top-1.5 -right-1.5 min-w-[20px] h-5 px-1 rounded-full bg-amber text-white text-[11px] grid place-items-center tabular-nums"
                        aria-label={`${l.ouvertes} déjà déclarées`}
                      >
                        {l.ouvertes}
                      </span>
                    )}
                  </Link>
                ))}
            </div>
          </section>
        ))}
      </div>
    </main>
  );
}
