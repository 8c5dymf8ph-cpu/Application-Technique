import { notFound } from "next/navigation";
import { sql } from "@/lib/db";
import { jours, LIBELLE_STATUT, TON_STATUT, type StatutAnomalie } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";

export const dynamic = "force-dynamic";

type Ligne = {
  anomalie_id: string;
  description: string;
  statut: StatutAnomalie;
  jours_depuis: number;
  constate_par: string | null;
  declare_le: string;
};

type Frequence = { libelle: string; nb_fois: number; derniere_fois: string };

export default async function HistoriqueDuLieu({
  params,
}: {
  params: Promise<{ code: string }>;
}) {
  const lieu = decodeURIComponent((await params).code);

  const [emplacement] = await sql<{ id: string; code: string; etage: string }[]>`
    select e.id, e.code, et.nom as etage
    from emplacements e join etages et on et.id = e.etage_id where e.code = ${lieu}`;
  if (!emplacement) notFound();

  // Ce qui revient le plus souvent, en tête : c'est l'information qui sert
  // vraiment quand on regarde l'historique d'une chambre.
  const recurrences = await sql<Frequence[]>`
    select libelle, nb_fois, derniere_fois from v_frequence_anomalie_lieu
    where emplacement_id = ${emplacement.id} and nb_fois > 1
    order by nb_fois desc, derniere_fois desc`;

  const lignes = await sql<Ligne[]>`
    select anomalie_id, description, statut, jours_depuis, constate_par, declare_le
    from v_anomalies_du_lieu
    where emplacement_id = ${emplacement.id} and statut <> 'annulee'
    order by declare_le desc`;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={emplacement.code}
        sous_titre={`Historique · ${emplacement.etage}`}
        retour={`/gouvernante/declarer/${encodeURIComponent(lieu)}`}
      />

      <div className="px-5 py-5 flex flex-col gap-6">
        {recurrences.length > 0 && (
          <section className="flex flex-col gap-2.5">
            <h2 className="etiquette">Ce qui revient</h2>
            <ul className="flex flex-col gap-1.5">
              {recurrences.map((r) => (
                <li
                  key={r.libelle}
                  className="carte px-4 py-3 flex items-center gap-3"
                >
                  <span className="text-[14px] leading-snug grow text-pretty">{r.libelle}</span>
                  <span className="shrink-0 px-2.5 py-1 rounded-lg bg-blue-soft text-blue text-[12.5px] tabular-nums">
                    {r.nb_fois} fois
                  </span>
                </li>
              ))}
            </ul>
          </section>
        )}

        <section className="flex flex-col gap-2.5">
          <h2 className="etiquette">Tout l’historique · {lignes.length}</h2>
          {lignes.length === 0 ? (
            <Vide>Rien n’a jamais été déclaré ici.</Vide>
          ) : (
            <ul className="flex flex-col gap-1.5">
              {lignes.map((l) => (
                <li key={l.anomalie_id} className="carte px-4 py-3 flex flex-col gap-1">
                  <p className="text-[14px] leading-snug text-pretty">{l.description}</p>
                  <p className="flex flex-wrap items-center gap-2 text-[11.5px]">
                    <span
                      className={`px-2 py-0.5 rounded-md ${TON_STATUT[l.statut].fond} ${TON_STATUT[l.statut].texte}`}
                    >
                      {LIBELLE_STATUT[l.statut]}
                    </span>
                    <span className="text-ink-faint">
                      {l.constate_par ? `${l.constate_par}, ` : ""}
                      {jours(l.jours_depuis)}
                    </span>
                  </p>
                </li>
              ))}
            </ul>
          )}
        </section>
      </div>
    </main>
  );
}
