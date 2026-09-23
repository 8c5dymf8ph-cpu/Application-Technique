import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { exigerEncadrement } from "@/lib/acces";
import { euros } from "@/lib/domaine";
import { Entete, Tuile } from "@/app/composants/ui";

export const dynamic = "force-dynamic";

type Lot = {
  id: string;
  reference: string;
  intervenant: string | null;
  date_tournee: string;
  nb_interventions: number;
  nb_en_attente: number;
  cout_total: number;
  cout_incomplet: boolean;
};

export default async function HubTechnique() {
  const profil = await exigerEncadrement();

  const [c] = await sql<
    {
      a_faire: number;
      en_cours: number;
      a_valider: number;
      sans_facture: number;
      alertes: number;
      cout_mois: number;
    }[]
  >`
    select
      (select count(*) from anomalies where statut = 'a_faire')::int      as a_faire,
      (select count(*) from anomalies where statut = 'en_cours')::int     as en_cours,
      (select coalesce(sum(nb_en_attente), 0) from v_tournees)::int       as a_valider,
      (select count(distinct prestataire_id) from v_interventions_sans_facture)::int
                                                                          as sans_facture,
      (select count(*) from v_stock_produits where actif and sous_seuil)::int as alertes,
      (select coalesce(sum(cout_total), 0) from v_tournees
        where date_tournee >= date_trunc('month', current_date))          as cout_mois`;

  // Les derniers lots rendus : ce qui s'est passé dans l'hôtel, en un regard.
  const derniers = await sql<Lot[]>`
    select id, reference, intervenant, date_tournee, nb_interventions::int,
           nb_en_attente::int, cout_total, coalesce(cout_incomplet, false) as cout_incomplet
    from v_tournees
    where nb_interventions > 0 and cloturee_le is not null
    order by date_tournee desc, cloturee_le desc
    limit 5`;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Technique"
        sous_titre={`${c.a_faire + c.en_cours} anomalies ouvertes · ${euros(c.cout_mois)} ce mois-ci`}
        retour="/"
      />

      <div className="px-5 py-5 flex flex-col gap-5">
        <div className="flex flex-col gap-3">
          <Tuile
            href="/technique/intervenants"
            titre="Intervenir"
            detail="Traiter les anomalies, dire le matériel utilisé"
            badge={c.a_faire}
            ton="bg-plum-soft"
          />
          <Tuile
            href="/technique/historique"
            titre="Historique"
            detail="Les passages, leur coût, renvoyer un récapitulatif"
            ton="bg-blue-soft"
          />
          <Tuile
            href="/technique/factures"
            titre="Factures"
            detail="Rapprocher une facture des journées qu’elle couvre"
            badge={c.sans_facture}
            ton="bg-amber-soft"
          />
          <Tuile
            href="/stock"
            titre="Stock matériel"
            detail="Produits, prix, seuils, entrées"
            badge={c.alertes}
            ton="bg-green-soft"
          />
          {/* En dernier : c'est de l'analyse, elle vient après les gestes. */}
          <Tuile
            href="/technique/tableau"
            titre="Tableau de bord"
            detail="Ce qui arrive, ce que ça coûte, ce qui part de la réserve"
            ton="bg-surface"
          />
        </div>

        {c.a_valider > 0 && (
          <Link
            href={"/gouvernante/valider" as Route}
            className="rounded-card bg-surface border border-line px-4 py-3 flex items-center gap-3"
          >
            <span className="font-display font-semibold text-[18px] text-amber tabular-nums">
              {c.a_valider}
            </span>
            <span className="text-[13px] text-ink-soft leading-snug text-pretty grow">
              anomalie{c.a_valider > 1 ? "s" : ""} déclarée
              {c.a_valider > 1 ? "s" : ""} faite{c.a_valider > 1 ? "s" : ""}, en attente de la
              gouvernante
            </span>
          </Link>
        )}

        {derniers.length > 0 && (
          <section className="flex flex-col gap-2">
            <h2 className="etiquette">Derniers passages</h2>
            <ul className="flex flex-col gap-2">
              {derniers.map((l) => (
                <li key={l.id}>
                  <Link
                    href={`/technique/tournee/${l.id}` as Route}
                    className="carte px-4 py-3 flex items-center gap-3 active:bg-surface-muted"
                  >
                    <span className="grow min-w-0">
                      <span className="block text-[14.5px]">
                        {l.intervenant ?? "Intervenant inconnu"}
                      </span>
                      <span className="block text-[11.5px] text-ink-faint">
                        {new Date(l.date_tournee).toLocaleDateString("fr-FR", {
                          day: "numeric",
                          month: "long",
                        })}{" "}
                        · {l.nb_interventions} anomalie{l.nb_interventions > 1 ? "s" : ""}
                        {l.nb_en_attente > 0 && ` · ${l.nb_en_attente} sans avis`}
                      </span>
                    </span>
                    <span className="shrink-0 text-right">
                      <span className="block text-[13.5px] tabular-nums">
                        {euros(l.cout_total)}
                      </span>
                      {l.cout_incomplet && (
                        <span className="block text-[10px] text-red">incomplet</span>
                      )}
                    </span>
                  </Link>
                </li>
              ))}
            </ul>
            <Link
              href={"/technique/historique" as Route}
              className="text-[12.5px] text-plum underline underline-offset-4 self-start"
            >
              Tout l’historique
            </Link>
          </section>
        )}
      </div>
    </main>
  );
}
