import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { ChampCommentaire } from "@/app/composants/fil";

export const dynamic = "force-dynamic";

type Chambre = { id: string; code: string; etage: string; en_place: number; dotation: number };
type Type = {
  id: string;
  libelle: string;
  couleur: string | null;
  prix_vente: number;
  prix_achat: number;
  en_reserve: number;
};

export default async function Signaler({
  searchParams,
}: {
  searchParams: Promise<{ lieu?: string; type?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { lieu, type } = await searchParams;

  const chambres = await sql<Chambre[]>`
    select e.id, e.code, et.nom as etage,
           coalesce(sum(b.quantite_reelle), 0)::int    as en_place,
           coalesce(sum(b.quantite_theorique), 0)::int as dotation
    from emplacements e
    join etages et on et.id = e.etage_id
    left join v_bouteilles_par_emplacement b on b.emplacement_id = e.id
    where e.actif and e.dote_bouteilles
    group by e.id, et.nom, et.ordre, e.ordre
    order by et.ordre, e.ordre, e.code`;

  const types = await sql<Type[]>`
    select bouteille_type_id as id, libelle, couleur, prix_vente, prix_achat,
           en_reserve::int
    from v_stock_bouteilles order by libelle`;

  const chambre = chambres.find((c) => c.code === lieu);
  const choisi = types.find((t) => t.id === type);

  async function enregistrer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");

    const emplacement = String(donnees.get("emplacement"));
    const bouteille = String(donnees.get("bouteille"));
    const nature = String(donnees.get("nature"));
    const responsable = String(donnees.get("responsable"));
    const client = String(donnees.get("client") ?? "").trim() || null;
    const mot = String(donnees.get("commentaire") ?? "").trim() || null;
    const quantite = Math.max(1, Number(donnees.get("quantite") ?? 1));

    // La chambre n'est re-dotée que s'il reste de quoi la re-doter : sinon on
    // l'enregistre sans re-dotation plutôt que de créer une réserve négative.
    const [stock] = await sql<{ en_reserve: number }[]>`
      select en_reserve::int from v_stock_bouteilles where bouteille_type_id = ${bouteille}`;

    // Le trigger `tg_incident_bouteille_mouvements` écrit les déplacements :
    // ici on ne décrit que le fait constaté.
    await sql`
      insert into incidents_bouteille (emplacement_id, bouteille_type_id, quantite,
                                       nature, responsable, client_nom, constate_par,
                                       redoter, commentaire)
      values (${emplacement}, ${bouteille}, ${quantite}, ${nature}::nature_incident_bouteille,
              ${responsable}::responsable_incident, ${client}, ${profil_.id},
              ${stock.en_reserve >= quantite}, ${mot})`;

    redirect("/bouteilles/dossiers?fait=1" as Route);
  }

  const etages = [...new Set(chambres.map((c) => c.etage))];
  const lien = (extra: Record<string, string>) =>
    `/bouteilles/signaler?${new URLSearchParams({
      ...(lieu ? { lieu } : {}),
      ...(type ? { type } : {}),
      ...extra,
    })}` as Route;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Signaler"
        sous_titre={chambre ? `${chambre.code} · ${chambre.etage}` : "Choisir la chambre"}
        retour="/bouteilles"
      />

      <div className="px-5 py-4 flex flex-col gap-5">
        {/* 1. Où */}
        {!chambre ? (
          <div className="flex flex-col gap-2">
            {etages.map((etage) => {
              const dedans = chambres.filter((c) => c.etage === etage);
              return (
                <details key={etage} className="carte overflow-hidden group">
                  <summary
                    data-cible
                    className="px-4 flex items-center gap-3 cursor-pointer list-none select-none"
                  >
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8E8AA3"
                         strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                         className="shrink-0 transition-transform group-open:rotate-90">
                      <path d="M9 5l7 7-7 7" />
                    </svg>
                    <span className="font-display font-semibold text-[17px] grow">{etage}</span>
                    <span className="text-[12.5px] text-ink-faint tabular-nums">
                      {dedans.length} chambres
                    </span>
                  </summary>
                  <div className="flex flex-wrap gap-2 px-4 pb-4 pt-1">
                    {dedans.map((c) => (
                      <Link
                        key={c.code}
                        href={lien({ lieu: c.code })}
                        data-cible
                        className={`px-3.5 flex items-center justify-center min-w-[54px] rounded-pill border text-[15px] ${
                          c.en_place < c.dotation
                            ? "border-amber/40 bg-amber-soft text-amber"
                            : "border-line bg-surface-muted"
                        }`}
                      >
                        {c.code}
                      </Link>
                    ))}
                  </div>
                </details>
              );
            })}
            <p className="text-[11.5px] text-ink-faint text-pretty px-1">
              En ambre : une chambre dont la dotation n’est pas complète.
            </p>
          </div>
        ) : (
          <>
            {/* 2. Quelle bouteille */}
            <section className="flex flex-col gap-2">
              <h2 className="etiquette">Quelle bouteille&nbsp;?</h2>
              <div className="flex gap-2">
                {types.map((t) => (
                  <Link
                    key={t.id}
                    href={lien({ type: t.id })}
                    className={`flex-1 rounded-card border px-3 py-3 flex flex-col gap-1 ${
                      t.id === type ? "border-plum bg-plum-soft" : "border-line bg-surface"
                    }`}
                  >
                    <span className="flex items-center gap-2">
                      <span
                        className="w-2.5 h-2.5 rounded-full shrink-0"
                        style={{ background: t.couleur ?? "#8E8AA3" }}
                      />
                      <span className="text-[14px] leading-tight">{t.libelle}</span>
                    </span>
                    <span className="text-[11px] text-ink-faint">
                      {t.en_reserve} en réserve
                    </span>
                  </Link>
                ))}
              </div>
              <Link
                href={"/bouteilles/signaler" as Route}
                className="self-start text-[12.5px] text-plum underline underline-offset-4"
              >
                Changer de chambre
              </Link>
            </section>

            {/* 3. Ce qui s'est passé */}
            {choisi && (
              <form action={enregistrer} className="flex flex-col gap-4">
                <input type="hidden" name="emplacement" value={chambre.id} />
                <input type="hidden" name="bouteille" value={choisi.id} />

                <fieldset className="flex flex-col gap-2">
                  <legend className="etiquette mb-2">Que s’est-il passé&nbsp;?</legend>
                  <div className="flex flex-col gap-2">
                    <label className="carte px-4 py-3 flex items-start gap-3 cursor-pointer has-[:checked]:border-plum has-[:checked]:bg-plum-soft">
                      <input type="radio" name="nature" value="emport" defaultChecked
                             className="mt-1 accent-[#453A6E]" />
                      <span className="flex flex-col gap-0.5">
                        <span className="text-[15px]">Le client l’a emportée</span>
                        <span className="text-[11.5px] text-ink-faint text-pretty">
                          Elle peut encore revenir : le dossier reste ouvert jusqu’à sa
                          restitution ou sa facturation.
                        </span>
                      </span>
                    </label>
                    <label className="carte px-4 py-3 flex items-start gap-3 cursor-pointer has-[:checked]:border-plum has-[:checked]:bg-plum-soft">
                      <input type="radio" name="nature" value="casse"
                             className="mt-1 accent-[#453A6E]" />
                      <span className="flex flex-col gap-0.5">
                        <span className="text-[15px]">Elle est cassée</span>
                        <span className="text-[11.5px] text-ink-faint text-pretty">
                          Elle sort du parc immédiatement, elle ne reviendra pas.
                        </span>
                      </span>
                    </label>
                  </div>
                </fieldset>

                <fieldset className="flex flex-col gap-2">
                  <legend className="etiquette mb-2">Qui&nbsp;?</legend>
                  <div className="grid grid-cols-3 gap-2">
                    {[
                      { v: "client", l: "Le client" },
                      { v: "personnel", l: "Le personnel" },
                      { v: "inconnu", l: "On ne sait pas" },
                    ].map((r) => (
                      <label
                        key={r.v}
                        className="rounded-card border border-line bg-surface h-[46px] grid place-items-center text-[13px] cursor-pointer has-[:checked]:border-plum has-[:checked]:bg-plum-soft"
                      >
                        <input type="radio" name="responsable" value={r.v}
                               defaultChecked={r.v === "client"} className="sr-only" />
                        {r.l}
                      </label>
                    ))}
                  </div>
                  <p className="text-[11.5px] text-ink-faint text-pretty">
                    Une casse du personnel n’est jamais facturée : elle est valorisée au prix
                    d’achat, {euros(choisi.prix_achat)}. Au client, c’est{" "}
                    {euros(choisi.prix_vente)}.
                  </p>
                </fieldset>

                <label className="flex flex-col gap-1.5">
                  <span className="etiquette">Nom du client (facultatif)</span>
                  <input
                    name="client"
                    autoComplete="off"
                    placeholder="Il pourra être ajouté plus tard"
                    className="carte px-4 h-[48px] text-[16px] placeholder:text-ink-faint"
                  />
                </label>

                <label className="flex flex-col gap-1.5">
                  <span className="etiquette">Combien</span>
                  <input
                    name="quantite"
                    type="number"
                    min={1}
                    max={20}
                    defaultValue={1}
                    inputMode="numeric"
                    className="carte px-4 h-[48px] w-[100px] text-[16px] tabular-nums"
                  />
                </label>

                <ChampCommentaire libelle="Précision (facultatif)" lignes={2} />

                {choisi.en_reserve < 1 && (
                  <p className="rounded-card bg-red-soft px-4 py-3 text-[12.5px] text-red text-pretty">
                    Plus rien en réserve : la chambre ne sera pas re-dotée. Le dossier est
                    enregistré quand même, mais il faut recommander.
                  </p>
                )}

                <button className="h-[54px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]">
                  Enregistrer le dossier
                </button>
                <p className="text-[11.5px] text-ink-faint text-pretty text-center">
                  La réception est prévenue, et la chambre re-dotée depuis la réserve.
                </p>
              </form>
            )}
          </>
        )}
      </div>
    </main>
  );
}
