import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { Entete, Vide } from "@/app/composants/ui";
import { Recherche } from "@/app/composants/suivi";
import { Depliant } from "@/app/composants/depliant";

export const dynamic = "force-dynamic";

/**
 * L'historique, par lieu.
 *
 * Cet écran disait « arrive dans la prochaine étape » : la tuile de l'accueil
 * y menait, avec son compte de lieux récurrents, et on tombait sur une page
 * vide. C'est la pire impasse qui soit — celle qui annonce quelque chose.
 *
 * Il répond à deux questions, et pas à d'autres. **Où est-ce que ça revient ?**
 * — c'est la raison d'être du catalogue fermé : sans libellés normalisés, ce
 * comptage n'existe pas, et c'est lui qui dit qu'un mitigeur a été repris
 * quatre fois dans la même chambre. Et **que s'est-il passé ici ?** — le
 * chemin vers l'historique d'un lieu, qui existait déjà mais qu'on ne pouvait
 * atteindre qu'en passant par l'écran de déclaration.
 *
 * L'ordre est celui du bâtiment, comme partout : on descend un étage, on ne
 * saute pas de la 41 à la 05.
 */

type Lieu = {
  emplacement_id: string;
  emplacement: string;
  etage: string;
  ordre_etage: number;
  nb_total: number;
  nb_6_mois: number;
  recurrent: boolean;
  derniere_anomalie: string | null;
  ouvertes: number;
};

type Revient = {
  emplacement: string;
  libelle: string;
  nb_fois: number;
  derniere_fois: string;
  ouvertes: number;
};

export default async function Historique({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { q = "" } = await searchParams;
  const terme = q.trim().toLowerCase();

  // Ce qui revient au même endroit, tout l'hôtel confondu. Une anomalie ne
  // peut pas être ouverte deux fois au même endroit — mais elle peut revenir
  // dix fois dans l'année, et c'est ça qu'on vient lire ici.
  const revient = await sql<Revient[]>`
    select emplacement, libelle, nb_fois, derniere_fois, ouvertes
      from v_frequence_anomalie_lieu
     where nb_fois > 1
     order by nb_fois desc, derniere_fois desc
     limit 40`;

  const lieux = await sql<Lieu[]>`
    select r.emplacement_id, r.emplacement, r.etage, et.ordre as ordre_etage,
           r.nb_total, r.nb_6_mois, r.recurrent, r.derniere_anomalie,
           (select count(*) from anomalies a
             where a.emplacement_id = r.emplacement_id
               -- Les états ouverts, tels que l'énumération les nomme.
               -- Validée et annulée sont les deux seuls qui ferment.
               and a.statut in ('a_faire', 'en_cours', 'attente_validation',
                                'a_acheter'))::int as ouvertes
      from v_recurrences_emplacement r
      join emplacements e on e.id = r.emplacement_id
      join etages et      on et.id = e.etage_id
     where r.nb_total > 0
       and (${terme} = '' or lower(r.emplacement) like ${"%" + terme + "%"}
                          or lower(r.etage) like ${"%" + terme + "%"})
     -- L'ordre du bâtiment, comme partout ailleurs.
     order by et.ordre, e.ordre, e.code`;

  const recurrents = lieux.filter((l) => l.recurrent).length;

  // Les lieux se regroupent par étage : trente-neuf lignes à la file, c'est un
  // rouleau, et on ne sait plus à quel étage on lit.
  const etages: { nom: string; lieux: Lieu[] }[] = [];
  for (const l of lieux) {
    const dernier = etages[etages.length - 1];
    if (dernier && dernier.nom === l.etage) dernier.lieux.push(l);
    else etages.push({ nom: l.etage, lieux: [l] });
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Historique"
        sous_titre={`${lieux.length} lieu${lieux.length > 1 ? "x" : ""} · ${recurrents} récurrent${
          recurrents > 1 ? "s" : ""
        }`}
        retour="/gouvernante"
      />

      <div className="px-5 py-4 flex flex-col gap-4">
        <Recherche valeur={q} placeholder="Une chambre, un étage…" />

        {/* Ce qui revient, en premier : c'est l'information qu'on ne peut
            trouver nulle part ailleurs. Un lieu, on sait où le chercher ; un
            problème qui revient, non. */}
        {revient.length > 0 && terme === "" && (
          <Depliant
            titre="Ce qui revient"
            aide="Le même problème, plusieurs fois au même endroit"
            indice={`${revient.length}`}
          >
            <ul className="flex flex-col gap-1.5">
              {revient.map((r) => (
                <li key={`${r.emplacement}-${r.libelle}`}>
                  <Link
                    href={`/gouvernante/historique/${encodeURIComponent(r.emplacement)}` as Route}
                    className="flex items-center gap-3 py-2 active:bg-surface-muted rounded-[10px]"
                  >
                    {/* Une anomalie ne se montre jamais séparée de son lieu. */}
                    <span className="shrink-0 min-w-[42px] h-[26px] px-2 rounded-md bg-plum-soft text-plum text-[12.5px] grid place-items-center">
                      {r.emplacement}
                    </span>
                    <span className="grow min-w-0 flex flex-col">
                      <span className="text-[14px] leading-snug text-pretty">{r.libelle}</span>
                      <span className="text-[11.5px] text-ink-faint">
                        dernière fois le{" "}
                        {new Date(r.derniere_fois).toLocaleDateString("fr-FR")}
                        {r.ouvertes > 0 ? " · ouverte en ce moment" : ""}
                      </span>
                    </span>
                    <span className="shrink-0 font-display font-semibold text-[16px] tabular-nums text-plum">
                      ×{r.nb_fois}
                    </span>
                  </Link>
                </li>
              ))}
            </ul>
          </Depliant>
        )}

        {lieux.length === 0 ? (
          <Vide>
            {terme
              ? `Aucun lieu ne correspond à « ${q} ».`
              : "Aucune anomalie déclarée pour l’instant."}
          </Vide>
        ) : (
          <div className="flex flex-col gap-4">
            {etages.map((e) => (
              <section key={e.nom} className="flex flex-col gap-1.5">
                <h2 className="etiquette">{e.nom}</h2>
                <ul className="carte divide-y divide-line">
                  {e.lieux.map((l) => (
                    <li key={l.emplacement_id}>
                      <Link
                        href={
                          `/gouvernante/historique/${encodeURIComponent(l.emplacement)}` as Route
                        }
                        className="px-3.5 py-2.5 flex items-center gap-3 active:bg-surface-muted"
                      >
                        <span className="grow min-w-0 flex flex-col">
                          <span className="text-[15.5px] flex items-center gap-2">
                            {l.emplacement}
                            {l.recurrent && (
                              <span className="text-[10.5px] px-1.5 py-0.5 rounded-md bg-amber-soft text-amber">
                                récurrent
                              </span>
                            )}
                          </span>
                          <span className="text-[11.5px] text-ink-faint">
                            {l.nb_total} anomalie{l.nb_total > 1 ? "s" : ""}
                            {l.nb_6_mois > 0 && ` · ${l.nb_6_mois} sur six mois`}
                            {l.derniere_anomalie &&
                              ` · dernière le ${new Date(
                                l.derniere_anomalie,
                              ).toLocaleDateString("fr-FR")}`}
                          </span>
                        </span>
                        {l.ouvertes > 0 && (
                          <span
                            className="shrink-0 min-w-[26px] h-[26px] px-1.5 rounded-md bg-plum-soft text-plum text-[12.5px] grid place-items-center tabular-nums"
                            aria-label={`${l.ouvertes} en cours`}
                          >
                            {l.ouvertes}
                          </span>
                        )}
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
                             stroke="#8C86A8" strokeWidth="2.2" strokeLinecap="round"
                             strokeLinejoin="round" aria-hidden className="shrink-0">
                          <path d="M9 5l7 7-7 7" />
                        </svg>
                      </Link>
                    </li>
                  ))}
                </ul>
              </section>
            ))}
          </div>
        )}
      </div>
    </main>
  );
}
