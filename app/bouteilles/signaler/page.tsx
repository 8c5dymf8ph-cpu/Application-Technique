import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { personnes, profilActif } from "@/lib/profil";
import { euros, suitLesDossiers } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { ChampCommentaire } from "@/app/composants/fil";
import { TotalBouteilles } from "@/app/composants/total-bouteilles";
import { ChoixPrenom } from "@/app/composants/prenom";

export const dynamic = "force-dynamic";

type Chambre = { id: string; code: string; etage: string; en_place: number; dotation: number };
type Type = {
  id: string;
  code: string;
  libelle: string;
  couleur: string | null;
  prix_vente: number;
  prix_achat: number;
  en_reserve: number;
};

export default async function Signaler({
  searchParams,
}: {
  searchParams: Promise<{ lieu?: string; mode?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { lieu, mode = "perte" } = await searchParams;
  const remplacement = mode === "remplacement";
  const casse = mode === "casse";

  // Qui a vu, et à qui c'est remonté. Ce n'est presque jamais la gouvernante
  // qui constate, et ce n'est jamais elle qui écrit au client.
  // Celles qui constatent : les femmes de chambre et la gouvernante. Plus, le
  // cas échéant, la personne connectée — Miguel peut avoir vu lui-même.
  const equipe = await personnes(["menage", "gouvernante"]);
  const constatants = equipe.some((p) => p.id === profil.id)
    ? equipe
    : [...equipe, { id: profil.id, nom: profil.nom, role: profil.role }];
  // Ceux à qui l'on transmet : la réception, et l'administration.
  const destinataires = await personnes(["reception", "admin"]);

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
    select bouteille_type_id as id, code, libelle, couleur, prix_vente, prix_achat,
           en_reserve::int
    from v_stock_bouteilles order by libelle`;

  const chambre = chambres.find((c) => c.code === lieu);

  async function enregistrer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");

    const emplacement = String(donnees.get("emplacement"));
    const estRemplacement = donnees.get("mode") === "remplacement";

    // Combien de chaque type — zéro veut dire « pas celle-là ».
    const choisies = types
      .map((t) => ({ id: t.id, quantite: Number(donnees.get(`qte-${t.id}`) ?? 0) }))
      .filter((l) => l.quantite > 0);
    if (choisies.length === 0) return;

    // Une date passée est permise : tout n'a pas été déclaré depuis l'application,
    // et les reprises à la main doivent porter leur vraie date.
    const saisie = String(donnees.get("date") ?? "").trim();
    const quand = saisie ? `${saisie} 11:00` : null;

    if (estRemplacement) {
      // Re-doter la chambre depuis la réserve : un déplacement, jamais une
      // seconde sortie de parc.
      for (const l of choisies) {
        await sql`
          insert into mouvements_bouteilles (type, bouteille_type_id, quantite,
                                             de_lieu, vers_lieu, vers_emplacement_id,
                                             date_mouvement, utilisateur_id, commentaire)
          values ('dotation', ${l.id}, ${l.quantite}, 'reserve', 'emplacement',
                  ${emplacement}, ${quand ?? new Date().toISOString()},
                  ${String(donnees.get("constate_par") ?? "") || profil_.id},
                  'Remplacement en chambre')`;
      }
      redirect("/bouteilles?fait=remplacement" as Route);
    }

    const nature = String(donnees.get("nature"));
    const responsable = String(donnees.get("responsable"));
    const client = String(donnees.get("client") ?? "").trim() || null;
    const vu_par = String(donnees.get("constate_par") ?? "") || profil_.id;
    const remonte_a = String(donnees.get("transmis_a") ?? "") || null;
    const mot = String(donnees.get("commentaire") ?? "").trim() || null;

    // La chambre n'est re-dotée que s'il reste de quoi la re-doter : sinon on
    // enregistre le dossier sans re-dotation plutôt que de créer une réserve
    // négative. Le remplacement se déclarera plus tard, après livraison.
    const stock = await sql<{ bouteille_type_id: string; en_reserve: number }[]>`
      select bouteille_type_id, en_reserve::int from v_stock_bouteilles`;
    const redoter = choisies.every(
      (l) => (stock.find((s) => s.bouteille_type_id === l.id)?.en_reserve ?? 0) >= l.quantite,
    );

    // `constate_par` est la personne qui a vu ; `saisie_par` reste implicite —
    // c'est le profil actif, et la trace en base le dit déjà.
    const [dossier] = await sql<{ id: string }[]>`
      insert into incidents_bouteille (emplacement_id, nature, responsable, client_nom,
                                       constate_par, constate_le, redoter, commentaire,
                                       transmis_a, transmis_le, statut, notifie_le)
      values (${emplacement}, ${nature}::nature_incident_bouteille,
              ${responsable}::responsable_incident, ${client}, ${vu_par},
              ${quand ?? new Date().toISOString()}, ${redoter}, ${mot},
              ${remonte_a},
              ${remonte_a ? (quand ?? new Date().toISOString()) : null},
              ${remonte_a ? "transmis" : "signale"}::statut_incident_bouteille,
              ${remonte_a ? new Date().toISOString() : null})
      returning id`;

    // Les lignes déclenchent les mouvements, une fois l'en-tête posé.
    for (const l of choisies) {
      await sql`
        insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
        values (${dossier.id}, ${l.id}, ${l.quantite})`;
    }

    // Le suivi du dossier est le travail de l'administration : la gouvernante
    // revient à ses gestes, elle n'a rien à faire sur cet écran-là.
    redirect(
      (suitLesDossiers(profil_.role)
        ? `/bouteilles/dossier/${dossier.id}`
        : "/bouteilles?fait=perte") as Route,
    );
  }

  const etages = [...new Set(chambres.map((c) => c.etage))];
  const lien = (extra: Record<string, string>) =>
    `/bouteilles/signaler?${new URLSearchParams({
      ...(lieu ? { lieu } : {}),
      mode,
      ...extra,
    })}` as Route;

  const aujourdhui = new Date().toISOString().slice(0, 10);

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={remplacement ? "Remplacer" : casse ? "Casse" : "Perte"}
        sous_titre={chambre ? `${chambre.code} · ${chambre.etage}` : "Choisir la chambre"}
        retour="/bouteilles"
      />

      <div className="px-5 py-4 flex flex-col gap-5">
        {/* Perte ou remplacement — le même écran, deux intentions */}
        <div className="flex gap-2">
          {[
            { v: "perte", l: "Perte", d: "Emportée par le client" },
            { v: "casse", l: "Casse", d: "Cassée, elle sort du parc" },
            { v: "remplacement", l: "Remplacer", d: "Re-doter la chambre" },
          ].map((m) => (
            <Link
              key={m.v}
              href={lien({ mode: m.v })}
              className={`flex-1 min-w-0 rounded-card border px-2.5 py-2.5 flex flex-col gap-0.5 ${
                mode === m.v ? "border-plum bg-plum-soft" : "border-line bg-surface"
              }`}
            >
              <span className="text-[13.5px] font-medium leading-tight">{m.l}</span>
              <span className="text-[10.5px] text-ink-faint leading-tight text-pretty">{m.d}</span>
            </Link>
          ))}
        </div>

        {!chambre ? (
          <div className="flex flex-col gap-2">
            {etages.map((etage) => {
              const dedans = chambres.filter((c) => c.etage === etage);
              const incompletes = dedans.filter((c) => c.en_place < c.dotation).length;
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
                    {incompletes > 0 && (
                      <span className="min-w-[26px] h-[26px] px-1.5 rounded-lg bg-amber-soft text-amber text-[12.5px] grid place-items-center tabular-nums">
                        {incompletes}
                      </span>
                    )}
                    <span className="text-[12.5px] text-ink-faint tabular-nums">
                      {dedans.length}
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
              En ambre : une chambre dont la dotation n’est pas complète — il y manque une
              bouteille, elle attend son remplacement.
            </p>
          </div>
        ) : (
          <form action={enregistrer} className="flex flex-col gap-5">
            <input type="hidden" name="emplacement" value={chambre.id} />
            <input type="hidden" name="mode" value={mode} />

            {/* Les deux bouteilles, ensemble : une chambre peut perdre les deux */}
            <section className="flex flex-col gap-2">
              <div className="flex items-baseline justify-between">
                <h2 className="etiquette">Quelles bouteilles&nbsp;?</h2>
                <Link
                  href={lien({ lieu: "" })}
                  className="text-[12.5px] text-plum underline underline-offset-4"
                >
                  Changer de chambre
                </Link>
              </div>
              <TotalBouteilles
                libelle={
                  remplacement
                    ? `Coût du remplacement · chambre ${chambre.code}`
                    : casse
                      ? `Valeur au prix d’achat · chambre ${chambre.code}`
                      : `Total à facturer · chambre ${chambre.code}`
                }
                types={types.map((t) => ({
                  id: t.id,
                  libelle: `${t.libelle} · ${t.en_reserve} en réserve`,
                  prix: Number(remplacement || casse ? t.prix_achat : t.prix_vente),
                }))}
              />
              <p className="text-[11.5px] text-ink-faint text-pretty">
                Laisser à zéro la bouteille qui n’est pas concernée. Les deux peuvent l’être
                dans la même déclaration : c’est un seul dossier, un seul montant.
              </p>
            </section>

            {!remplacement && (
              <>
                <input type="hidden" name="nature" value={casse ? "casse" : "emport"} />

                <ChoixPrenom
                  nom="constate_par"
                  libelle="Qui l’a constaté ?"
                  personnes={constatants}
                  defaut={profil.id}
                  aide="Le nom reste attaché au dossier, et figure dans le mail de la réception."
                />

                <ChoixPrenom
                  nom="transmis_a"
                  libelle="À qui l’avez-vous dit ?"
                  personnes={destinataires}
                  facultatif
                  aide="Renseigné, le dossier passe directement en « transmis » — sinon il reste signalé."
                />

                <fieldset className="flex flex-col gap-2">
                  <legend className="etiquette mb-2">Qui en est la cause&nbsp;?</legend>
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
                               defaultChecked={r.v === (casse ? "personnel" : "client")}
                               className="sr-only" />
                        {r.l}
                      </label>
                    ))}
                  </div>
                  <p className="text-[11.5px] text-ink-faint text-pretty">
                    {casse
                      ? `Une casse du personnel n’est jamais facturée : elle est valorisée au prix d’achat, ${euros(types[0]?.prix_achat ?? 0)}. Imputée au client, c’est ${euros(types[0]?.prix_vente ?? 0)} l’unité.`
                      : `Facturée au client, la bouteille vaut ${euros(types[0]?.prix_vente ?? 0)}. Imputée au personnel, elle est valorisée au prix d’achat, ${euros(types[0]?.prix_achat ?? 0)}.`}
                  </p>
                </fieldset>

                <label className="flex flex-col gap-1.5">
                  <span className="etiquette">Nom du client (facultatif)</span>
                  <input
                    name="client"
                    autoComplete="off"
                    placeholder="Il pourra être ajouté plus tard"
                    className="w-full carte px-4 h-[48px] text-[16px] placeholder:text-ink-faint"
                  />
                </label>
              </>
            )}

            {remplacement && (
              <ChoixPrenom
                nom="constate_par"
                libelle="Qui a remplacé ?"
                personnes={constatants}
                defaut={profil.id}
              />
            )}

            <label className="flex flex-col gap-1.5">
              <span className="etiquette">
                {remplacement ? "Date du remplacement" : "Date du constat"}
              </span>
              <input
                name="date"
                type="date"
                max={aujourdhui}
                defaultValue={aujourdhui}
                className="w-full carte px-4 h-[48px] text-[16px]"
              />
              <span className="text-[11.5px] text-ink-faint text-pretty">
                Une date passée est acceptée : c’est ainsi qu’on rattrape une déclaration qui
                n’avait pas été faite dans l’application.
              </span>
            </label>

            {!remplacement && <ChampCommentaire libelle="Précision (facultatif)" lignes={2} />}

            <button className="h-[54px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]">
              {remplacement ? "Enregistrer le remplacement" : "Enregistrer le dossier"}
            </button>
            <p className="text-[11.5px] text-ink-faint text-pretty text-center -mt-2">
              {remplacement
                ? "Les bouteilles sortent de la réserve et rejoignent la chambre."
                : casse
                  ? "La bouteille sort du parc, et la chambre est re-dotée depuis la réserve."
                  : "La chambre est re-dotée depuis la réserve, et le mail pour la réception est préparé."}
            </p>
          </form>
        )}
      </div>
    </main>
  );
}
