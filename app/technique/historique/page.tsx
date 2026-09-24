import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { exigerEncadrement } from "@/lib/acces";
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
  /** La facture qui couvre ce passage, et combien de passages elle couvre. */
  facture: string | null;
  facture_id: string | null;
  nb_journees_couvertes: number;
};

export default async function Historique({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; qui?: string }>;
}) {
  const profil = await exigerEncadrement();
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
              from v_recap_interventions r where r.tournee = t.reference) as emplacements,
           -- La facture qui couvre ce passage. Sans ce signe, on ne distingue
           -- pas ce qui est déjà réglé de ce qui attend sa pièce.
           fa.reference as facture, fa.id as facture_id,
           coalesce(fa.nb_journees, 0)::int as nb_journees_couvertes
    from v_tournees t
    left join lateral (
      select f.id, f.reference,
             (select count(distinct i2.date_intervention)
                from facture_interventions fi2
                join interventions i2 on i2.id = fi2.intervention_id
               where fi2.facture_id = f.id) as nb_journees
        from v_recap_interventions r
        join facture_interventions fi on fi.intervention_id = r.intervention_id
        join factures f               on f.id = fi.facture_id
       where r.tournee = t.reference
       limit 1) fa on true
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

                  <span className="flex flex-wrap items-center gap-2 text-[11px]">
                    <span className="text-ink-faint">
                      {l.nb_interventions} anomalie{l.nb_interventions > 1 ? "s" : ""}
                    </span>
                    {/* La facture, d'un coup d'œil : ce qui est couvert et ce
                        qui attend encore sa pièce ne se distinguaient pas. Et
                        quand elle couvre plusieurs journées, on le dit — c'est
                        ce que l'écran des factures sait faire, et c'est
                        l'information qui manquait ici. */}
                    {l.facture_id ? (
                      <span className="flex items-center gap-1 px-1.5 py-0.5 rounded-md bg-green-soft text-green">
                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" strokeWidth="2" strokeLinecap="round"
                             strokeLinejoin="round" aria-hidden>
                          <path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z" />
                          <path d="M14 3v5h5" />
                        </svg>
                        {l.facture ?? "facturé"}
                        {l.nb_journees_couvertes > 1
                          ? ` · ${l.nb_journees_couvertes} journées`
                          : ""}
                      </span>
                    ) : (
                      l.cout_total > 0 && (
                        <span className="px-1.5 py-0.5 rounded-md bg-amber-soft text-amber">
                          sans facture
                        </span>
                      )
                    )}
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
