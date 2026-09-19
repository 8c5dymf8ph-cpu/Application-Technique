import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";
import { Filtres, Recherche, Stat } from "@/app/composants/suivi";

export const dynamic = "force-dynamic";

type Lot = {
  id: string;
  reference: string;
  intervenant: string | null;
  date_tournee: string;
  cloturee_le: string | null;
  nb_interventions: number;
  nb_en_attente: number;
  nb_validees: number;
  nb_a_refaire: number;
  cout_total: number;
  cout_incomplet: boolean;
  reprise: boolean;
  mail_recap_envoye_le: string | null;
  emplacements: string | null;
};

export default async function Historique({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; qui?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { q = "", qui = "tous" } = await searchParams;
  const terme = q.trim().toLowerCase();

  const [c] = await sql<
    { lots: number; anomalies: number; cout_annee: number; incomplets: number }[]
  >`
    select count(*) filter (where nb_interventions > 0)::int    as lots,
           coalesce(sum(nb_interventions), 0)::int              as anomalies,
           coalesce(sum(cout_total) filter (
             where date_tournee >= date_trunc('year', current_date)), 0) as cout_annee,
           count(*) filter (where cout_incomplet)::int          as incomplets
    from v_tournees`;

  const gens = await sql<{ intervenant: string; nombre: number }[]>`
    select intervenant, count(*)::int as nombre
    from v_tournees
    where nb_interventions > 0 and intervenant is not null
    group by 1 order by 2 desc, 1 limit 12`;

  // Une tournée se retrouve par l'intervenant, la chambre, ou un mot de
  // l'anomalie : on cherche rarement par référence.
  const lots = await sql<Lot[]>`
    select t.id, t.reference, t.intervenant, t.date_tournee, t.cloturee_le,
           t.nb_interventions::int, t.nb_en_attente::int, t.nb_validees::int,
           t.nb_a_refaire::int, t.cout_total,
           coalesce(t.cout_incomplet, false) as cout_incomplet,
           t.reprise, t.mail_recap_envoye_le,
           (select string_agg(distinct r.emplacement, ', ' order by r.emplacement)
              from v_recap_interventions r where r.tournee = t.reference) as emplacements
    from v_tournees t
    where t.nb_interventions > 0
      and (${qui} = 'tous' or t.intervenant = ${qui})
      and (${terme} = '' or exists (
            select 1 from v_recap_interventions r
            where r.tournee = t.reference
              and (lower(r.description) like ${"%" + terme + "%"}
                or lower(r.emplacement) like ${"%" + terme + "%"}
                or lower(coalesce(r.intervenant, '')) like ${"%" + terme + "%"})))
    order by t.date_tournee desc, t.cloturee_le desc nulls last
    limit 50`;

  const lien = (v: string) =>
    `/technique/historique?${new URLSearchParams({ qui: v, ...(q ? { q } : {}) })}` as Route;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Historique"
        sous_titre={`${c.lots} passages · ${c.anomalies} anomalies`}
        retour="/technique"
      />

      <div className="px-5 py-4 flex flex-col gap-3.5">
        <div className="flex gap-2">
          <Stat valeur={c.lots} libelle="Passages" />
          <Stat valeur={c.anomalies} libelle="Anomalies" />
          <Stat valeur={euros(c.cout_annee)} libelle="Coût cette année" />
        </div>

        {c.incomplets > 0 && (
          <p className="text-[11.5px] text-amber text-pretty leading-snug">
            {c.incomplets} passage{c.incomplets > 1 ? "s" : ""} au coût incomplet : au moins un
            article utilisé n’a pas de prix renseigné.
          </p>
        )}

        <Recherche valeur={q} placeholder="Une chambre, un mot, un nom…" caches={{ qui }} />

        <Filtres
          actif={qui}
          lien={lien}
          choix={[
            { valeur: "tous", libelle: "Tous", nombre: c.lots },
            ...gens.map((g) => ({
              valeur: g.intervenant,
              libelle: g.intervenant,
              nombre: g.nombre,
            })),
          ]}
        />

        {lots.length === 0 ? (
          <Vide>
            {terme ? `Aucun passage ne correspond à « ${q} ».` : "Aucun passage enregistré."}
          </Vide>
        ) : (
          <ul className="flex flex-col gap-2">
            {lots.map((l) => (
              <li key={l.id}>
                <Link
                  href={`/technique/tournee/${l.id}` as Route}
                  className="carte px-4 py-3.5 flex flex-col gap-1.5 active:bg-surface-muted"
                >
                  <span className="flex items-baseline gap-3">
                    <span className="grow min-w-0">
                      <span className="block font-display font-semibold text-[15.5px]">
                        {l.intervenant ?? "Intervenant inconnu"}
                      </span>
                      <span className="block text-[11.5px] text-ink-faint">
                        {new Date(l.date_tournee).toLocaleDateString("fr-FR", {
                          weekday: "long",
                          day: "numeric",
                          month: "long",
                          year: "numeric",
                        })}
                      </span>
                    </span>
                    <span className="shrink-0 text-right">
                      <span className="block font-display font-semibold text-[15px] tabular-nums">
                        {euros(l.cout_total)}
                      </span>
                      {l.cout_incomplet && (
                        <span className="block text-[10px] text-red">incomplet</span>
                      )}
                    </span>
                  </span>

                  {l.emplacements && (
                    <span className="text-[12px] text-ink-soft truncate">{l.emplacements}</span>
                  )}

                  <span className="flex flex-wrap gap-2 text-[11px]">
                    <span className="text-ink-faint">
                      {l.nb_interventions} anomalie{l.nb_interventions > 1 ? "s" : ""}
                    </span>
                    {l.nb_validees > 0 && (
                      <span className="text-green">{l.nb_validees} validée{l.nb_validees > 1 ? "s" : ""}</span>
                    )}
                    {l.nb_a_refaire > 0 && (
                      <span className="text-red">{l.nb_a_refaire} à refaire</span>
                    )}
                    {l.nb_en_attente > 0 && (
                      <span className="text-amber">{l.nb_en_attente} sans avis</span>
                    )}
                    {l.reprise ? (
                      <span className="text-ink-faint">repris de l’ancienne application</span>
                    ) : l.mail_recap_envoye_le ? (
                      <span className="text-ink-faint">récapitulatif envoyé</span>
                    ) : null}
                  </span>
                </Link>
              </li>
            ))}
          </ul>
        )}
      </div>
    </main>
  );
}
