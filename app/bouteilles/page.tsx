import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, peutValider } from "@/lib/domaine";
import { Entete, Tuile } from "@/app/composants/ui";

export const dynamic = "force-dynamic";

type Parc = {
  bouteille_type_id: string;
  code: string;
  libelle: string;
  couleur: string | null;
  en_reserve: number;
  en_chambre: number;
  chez_clients: number;
  parc_detenu: number;
  parc_theorique: number;
  dotation_theorique: number;
  seuil_alerte: number;
  sous_seuil: boolean;
};

export default async function Bouteilles({
  searchParams,
}: {
  searchParams: Promise<{ fait?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { fait } = await searchParams;

  const parc = await sql<Parc[]>`
    select bouteille_type_id, code, libelle, couleur,
           en_reserve::int, en_chambre::int, chez_clients::int,
           parc_detenu::int, parc_theorique::int, dotation_theorique::int,
           seuil_alerte::int, sous_seuil
    from v_stock_bouteilles order by libelle`;

  // Tout le monde voit tout : ce qui change, c'est l'ordre. Les trois gestes de
  // la gouvernante viennent d'abord, le suivi et l'analyse ensuite.

  const [c] = await sql<
    { ouverts: number; urgents: number; du_mois: number; en_jeu: number; commandes: number }[]
  >`
    select
      (select count(*) from v_dossiers_bouteille where famille = 'ouvert')::int as ouverts,
      (select count(*) from v_dossiers_bouteille where urgent)::int             as urgents,
      (select count(*) from v_dossiers_bouteille
        where constate_le >= date_trunc('month', current_date))::int            as du_mois,
      (select coalesce(sum(montant), 0) from v_dossiers_bouteille
        where famille = 'ouvert')                                               as en_jeu,
      (select count(*) from commandes where statut in ('brouillon','envoyee'))::int as commandes`;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Bouteilles" sous_titre="Purezza" retour="/" />

      <div className="px-5 py-5 flex flex-col gap-5">
        {fait && (
          <p className="rounded-card bg-green-soft px-4 py-3 text-[13px] text-green text-pretty">
            {fait === "remplacement"
              ? "Remplacement enregistré : les bouteilles ont quitté la réserve pour la chambre."
              : "Dossier enregistré. La chambre est re-dotée, et la réception a ce qu’il lui faut."}
          </p>
        )}

        {/* Le parc, tel qu'il est vraiment */}
        <section className="flex flex-col gap-2.5">
          <h2 className="etiquette">Le parc</h2>
          {parc.map((b) => (
            <article key={b.bouteille_type_id} className="carte px-4 py-3.5 flex flex-col gap-3">
              <div className="flex items-center gap-2.5">
                <span
                  className="w-2.5 h-2.5 rounded-full shrink-0"
                  style={{ background: b.couleur ?? "#8E8AA3" }}
                />
                <h3 className="font-display font-semibold text-[16px] grow">{b.libelle}</h3>
                <span className="font-display font-semibold text-[20px] tabular-nums">
                  {b.parc_detenu}
                </span>
              </div>

              {/* Réserve et chambres se lisent séparément : l'une se recharge,
                  l'autre est la dotation qui doit rester servie. */}
              <div className="flex gap-2">
                <div
                  className={`flex-1 rounded-[11px] px-3 py-2 ${
                    b.sous_seuil ? "bg-red-soft" : "bg-surface-muted"
                  }`}
                >
                  <div
                    className={`font-display font-semibold text-[17px] tabular-nums ${
                      b.sous_seuil ? "text-red" : ""
                    }`}
                  >
                    {b.en_reserve}
                  </div>
                  <div className="etiquette text-[8.5px]">En réserve</div>
                </div>
                <div className="flex-1 rounded-[11px] px-3 py-2 bg-surface-muted">
                  <div className="font-display font-semibold text-[17px] tabular-nums">
                    {b.en_chambre}
                    <span className="text-[11px] text-ink-faint font-sans font-normal">
                      {" "}
                      / {b.dotation_theorique}
                    </span>
                  </div>
                  <div className="etiquette text-[8.5px]">En chambre</div>
                </div>
                <div className="flex-1 rounded-[11px] px-3 py-2 bg-amber-soft">
                  <div className="font-display font-semibold text-[17px] tabular-nums text-amber">
                    {b.chez_clients}
                  </div>
                  <div className="etiquette text-[8.5px]">Chez clients</div>
                </div>
              </div>

              {b.sous_seuil && (
                <p className="text-[12px] text-red leading-snug text-pretty">
                  La réserve est sous le seuil de {b.seuil_alerte} : il faut recommander.
                </p>
              )}
              <p className="text-[11.5px] text-ink-faint leading-snug text-pretty">
                {b.parc_detenu} détenues — réserve et chambres. {b.chez_clients} encore chez des
                clients, qui peuvent revenir.
              </p>
            </article>
          ))}
        </section>

        <div className="flex flex-col gap-3">
          <Tuile
            href="/bouteilles/signaler"
            titre="Perte"
            detail="Une bouteille emportée par le client"
            ton="bg-amber-soft"
          />
          <Tuile
            href="/bouteilles/signaler?mode=casse"
            titre="Casse"
            detail="Une bouteille cassée, elle sort du parc"
            ton="bg-red-soft"
          />
          <Tuile
            href="/bouteilles/signaler?mode=remplacement"
            titre="Remplacement"
            detail="Re-doter une chambre depuis la réserve"
            badge={parc.reduce((n, b) => n + Math.max(0, b.dotation_theorique - b.en_chambre), 0)}
            ton="bg-blue-soft"
          />
          <Tuile
            href="/bouteilles/inventaire"
            titre="Inventaire"
            detail="Compter la réserve et les chambres"
            ton="bg-green-soft"
          />

          <>
              <Tuile
                href="/bouteilles/dossiers"
                titre="Dossiers"
                detail={
                  c.ouverts === 0
                    ? "Rien en cours"
                    : `${c.ouverts} en cours · ${euros(c.en_jeu)} en jeu`
                }
                badge={c.ouverts}
                ton="bg-plum-soft"
              />
              <Tuile
                href="/bouteilles/commandes"
                titre="Commandes"
                detail="Livraisons, prix, factures"
                badge={c.commandes}
                ton="bg-blue-soft"
              />
              <Tuile
                href="/bouteilles/tableau"
                titre="Tableau de bord"
                detail={`${c.du_mois} dossier${c.du_mois > 1 ? "s" : ""} ce mois-ci`}
                ton="bg-surface"
              />
          </>
        </div>

        {peutValider(profil.role) && (
          <Link
            href={"/administration/equipe" as Route}
            className="text-[12.5px] text-plum underline underline-offset-4 self-start"
          >
            Gérer les prénoms — l’étage et la réception
          </Link>
        )}

        {c.urgents > 0 && (
          <Link
            href={"/bouteilles/dossiers?filtre=urgent" as Route}
            className="rounded-card bg-red-soft border border-red/20 px-4 py-3 flex items-center gap-3"
          >
            <span className="font-display font-semibold text-[18px] text-red tabular-nums">
              {c.urgents}
            </span>
            <span className="text-[13px] text-red leading-snug text-pretty">
              dossier{c.urgents > 1 ? "s" : ""} ouvert{c.urgents > 1 ? "s" : ""} depuis plus d’une
              semaine — le client est parti.
            </span>
          </Link>
        )}
      </div>
    </main>
  );
}
