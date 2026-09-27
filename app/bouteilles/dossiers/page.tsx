import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { vueContient } from "@/lib/schema";
import { depuis, euros } from "@/lib/domaine";
import { Confirmation, Entete, Vide } from "@/app/composants/ui";
import { Frise, Recherche, Stat } from "@/app/composants/suivi";
import { MarquerApresSuppression } from "@/app/composants/quitter-si-revenu";
import { MenuFiltre } from "@/app/composants/menu-filtre";

export const dynamic = "force-dynamic";

type Dossier = {
  id: string;
  reference: number;
  emplacement: string;
  bouteille: string;
  quantite: number;
  nature: string;
  responsable: string;
  client_nom: string | null;
  constate_par: string | null;
  constate_le: string;
  statut: string;
  famille: string;
  jours_ouvert: number;
  urgent: boolean;
  montant: number;
  facturable_client: boolean;
  etape_constate: boolean;
  etape_transmis: boolean;
  etape_client_contacte: boolean;
  etape_resolue: boolean;
  commentaire: string | null;
  /** `null` tant que la migration 0027 n'est pas jouée : la colonne n'existe pas encore. */
  redoter: boolean | null;
};

const LIBELLE: Record<string, string> = {
  signale: "Signalé",
  transmis: "Transmis",
  client_contacte: "Client contacté",
  restitue: "Restituée",
  facture: "Facturé",
  non_facture: "Perte sèche",
  clos: "Clos",
};

const TON: Record<string, { fond: string; texte: string; barre: string }> = {
  signale: { fond: "bg-amber-soft", texte: "text-amber", barre: "bg-amber" },
  transmis: { fond: "bg-amber-soft", texte: "text-amber", barre: "bg-amber" },
  client_contacte: { fond: "bg-blue-soft", texte: "text-blue", barre: "bg-blue" },
  restitue: { fond: "bg-green-soft", texte: "text-green", barre: "bg-green" },
  facture: { fond: "bg-green-soft", texte: "text-green", barre: "bg-green" },
  non_facture: { fond: "bg-red-soft", texte: "text-red", barre: "bg-red" },
  clos: { fond: "bg-surface-muted", texte: "text-ink-faint", barre: "bg-line" },
};

export default async function Dossiers({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; filtre?: string; fait?: string; tri?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { q = "", filtre = "ouvert", fait, tri = "date" } = await searchParams;

  const [c] = await sql<
    { ouverts: number; urgents: number; du_mois: number; resolus: number; perdus: number;
      tous: number; en_jeu: number; perte: number }[]
  >`
    select
      count(*) filter (where famille = 'ouvert')::int as ouverts,
      count(*) filter (where urgent)::int             as urgents,
      count(*) filter (where constate_le >= date_trunc('month', current_date))::int as du_mois,
      count(*) filter (where famille = 'resolu')::int as resolus,
      count(*) filter (where famille = 'perdu')::int  as perdus,
      count(*)::int                                   as tous,
      coalesce(sum(montant) filter (where famille = 'ouvert'), 0)  as en_jeu,
      coalesce(sum(montant) filter (where statut = 'non_facture'), 0) as perte
    from v_dossiers_bouteille`;

  // Un seul passage : le filtre choisit la famille, la recherche porte sur le
  // client, la chambre, le type et le commentaire — tout ce qu'on retient d'un
  // dossier quand on le cherche des semaines plus tard.
  const terme = q.trim().toLowerCase();
  // La colonne n'existe dans la vue que depuis la migration 0027 : deux
  // requêtes, jamais une condition booléenne dans le SQL.
  const remplacementVisible = await vueContient("v_incidents_bouteille", "i.redoter");
  const dossiers = remplacementVisible
    ? await sql<Dossier[]>`
        select id, reference, emplacement, bouteille, quantite, nature::text,
               responsable::text, client_nom, constate_par, constate_le, statut::text,
               famille, jours_ouvert, urgent, montant, facturable_client,
               etape_constate, etape_transmis, etape_client_contacte, etape_resolue,
               commentaire, redoter
        from v_dossiers_bouteille
        where (${filtre} = 'tous'
            or (${filtre} = 'urgent' and urgent)
            or famille = ${filtre})
          and (${terme} = '' or recherche like ${"%" + terme + "%"})
        order by ${
          tri === "alpha"
            ? sql`emplacement asc, constate_le desc`
            : tri === "nom"
              ? sql`client_nom nulls last, constate_le desc`
              : sql`constate_le desc`
        }
        limit 60`
    : await sql<Dossier[]>`
        select id, reference, emplacement, bouteille, quantite, nature::text,
               responsable::text, client_nom, constate_par, constate_le, statut::text,
               famille, jours_ouvert, urgent, montant, facturable_client,
               etape_constate, etape_transmis, etape_client_contacte, etape_resolue,
               commentaire, null::boolean as redoter
        from v_dossiers_bouteille
        where (${filtre} = 'tous'
            or (${filtre} = 'urgent' and urgent)
            or famille = ${filtre})
          and (${terme} = '' or recherche like ${"%" + terme + "%"})
        order by ${
          tri === "alpha"
            ? sql`emplacement asc, constate_le desc`
            : tri === "nom"
              ? sql`client_nom nulls last, constate_le desc`
              : sql`constate_le desc`
        }
        limit 60`;

  async function avancer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");
    const id = String(donnees.get("dossier"));
    const etape = String(donnees.get("etape"));

    // Chaque bouton pose une date, jamais un statut seul : c'est la date qui
    // fait la frise, et c'est elle qu'on relit des mois plus tard.
    if (etape === "transmis") {
      await sql`
        update incidents_bouteille
           set statut = 'transmis', transmis_le = now(), transmis_a = ${profil_.id}
         where id = ${id} and statut = 'signale'`;
    } else if (etape === "contacte") {
      await sql`
        update incidents_bouteille
           set statut = 'client_contacte', client_contacte_le = now(),
               transmis_le = coalesce(transmis_le, now())
         where id = ${id} and statut in ('signale', 'transmis')`;
    } else if (etape === "restitue" || etape === "facture" || etape === "non_facture") {
      await sql`
        update incidents_bouteille
           set statut = ${etape}::statut_incident_bouteille,
               resolu_le = now(), resolu_par = ${profil_.id}
         where id = ${id} and statut in ('signale', 'transmis', 'client_contacte')`;
    }
    revalidatePath("/bouteilles/dossiers");
  }

  async function nommer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");
    const id = String(donnees.get("dossier"));
    const nom = String(donnees.get("client") ?? "").trim();
    if (nom) {
      await sql`update incidents_bouteille set client_nom = ${nom} where id = ${id}`;
    }
    revalidatePath("/bouteilles/dossiers");
  }

  const lien = (f: string) =>
    `/bouteilles/dossiers?${new URLSearchParams({
      filtre: f,
      ...(tri !== "date" ? { tri } : {}),
      ...(q ? { q } : {}),
    })}` as Route;
  const lienTri = (t: string) =>
    `/bouteilles/dossiers?${new URLSearchParams({
      filtre,
      ...(t !== "date" ? { tri: t } : {}),
      ...(q ? { q } : {}),
    })}` as Route;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Dossiers" sous_titre="Bouteilles emportées et cassées" retour="/bouteilles" />

      <div className="px-5 py-4 flex flex-col gap-3.5">
        {/* On arrive ici après avoir supprimé un dossier : sans un mot, on ne
            sait pas si la suppression a eu lieu ou si l'on s'est trompé
            d'écran. */}
        <Confirmation quoi={fait} />
        {fait === "dossier-supprime" && (
          <MarquerApresSuppression vers="/bouteilles/dossiers" />
        )}

        <div className="flex gap-2">
          <Stat valeur={c.ouverts} libelle="En cours" />
          <Stat valeur={c.urgents} libelle="Urgents" ton={c.urgents > 0 ? "alerte" : undefined} />
          <Stat valeur={c.du_mois} libelle="Ce mois" />
          <Stat valeur={euros(c.en_jeu)} libelle="En jeu" />
        </div>

        <Recherche
          valeur={q}
          placeholder="Nom du client, chambre, n° de dossier…"
          caches={{ filtre, tri }}
        />

        {/* Deux icônes plutôt que deux rangées de boutons toujours affichées :
            le choix se change rarement, il n'a pas besoin d'une ligne entière
            en permanence. Chacune montre le choix actuel en clair. */}
        <div className="flex gap-2">
          <MenuFiltre
            icone="filtre"
            titre="Filtrer les dossiers"
            actif={filtre}
            choix={[
              { valeur: "ouvert", libelle: "En cours", nombre: c.ouverts, href: lien("ouvert") },
              { valeur: "urgent", libelle: "Urgents", nombre: c.urgents, href: lien("urgent") },
              { valeur: "resolu", libelle: "Réglés", nombre: c.resolus, href: lien("resolu") },
              { valeur: "perdu", libelle: "Perte sèche", nombre: c.perdus, href: lien("perdu") },
              { valeur: "tous", libelle: "Tous", nombre: c.tous, href: lien("tous") },
            ]}
          />
          {/* Par date par défaut — c'est l'ordre dans lequel les dossiers
              arrivent. Chambre et nom ne servent qu'à retrouver un dossier
              précis sans se souvenir de sa date. */}
          <MenuFiltre
            icone="tri"
            titre="Trier les dossiers"
            actif={tri}
            choix={[
              { valeur: "date", libelle: "Par date", href: lienTri("date") },
              { valeur: "alpha", libelle: "Par chambre (A → Z)", href: lienTri("alpha") },
              { valeur: "nom", libelle: "Par nom de client (A → Z)", href: lienTri("nom") },
            ]}
          />
        </div>

        {dossiers.length === 0 ? (
          <Vide>
            {terme
              ? `Aucun dossier ne correspond à « ${q} ».`
              : "Aucun dossier dans cette catégorie."}
          </Vide>
        ) : (
          <ul className="flex flex-col gap-2.5">
            {dossiers.map((d) => {
              const ton = TON[d.statut] ?? TON.clos;
              const ouvert = d.famille === "ouvert";
              return (
                <li key={d.id} className="carte overflow-hidden">
                  <div className={`h-[3px] ${d.urgent ? "bg-red" : ton.barre}`} />
                  <Link
                    href={`/bouteilles/dossier/${d.id}` as Route}
                    className="px-4 pt-3 pb-2.5 flex flex-col gap-2.5 active:bg-surface-muted"
                  >
                    <div className="flex items-start gap-3">
                      <div className="grow min-w-0">
                        <p className="flex items-center gap-2">
                          <span className="px-2 py-0.5 rounded-md bg-plum-soft text-plum text-[11.5px] font-medium">
                            {d.emplacement}
                          </span>
                          <span className="text-[10.5px] text-ink-faint tabular-nums">
                            dossier n° {d.reference}
                          </span>
                        </p>
                        <p className="text-[14.5px] leading-snug mt-1">
                          {d.client_nom ?? (
                            <span className="text-ink-faint italic">Client non nommé</span>
                          )}
                        </p>
                        <p className="text-[11.5px] text-ink-faint">
                          {d.bouteille} · {d.nature === "casse" ? "cassée" : "emportée"} ·{" "}
                          {depuis(d.jours_ouvert, d.constate_le)}
                          {/* Le remplacement, invisible jusqu'ici : sans lui,
                              deux dossiers qui re-dotent la même chambre le
                              même jour ne se distinguent pas l'un de l'autre. */}
                          {d.redoter !== null && (
                            <>
                              {" · "}
                              <span className={d.redoter ? undefined : "text-amber"}>
                                {d.redoter ? "re-dotée" : "non re-dotée"}
                              </span>
                            </>
                          )}
                        </p>
                      </div>
                      <div className="shrink-0 text-right flex flex-col items-end gap-1">
                        <span className={`px-2 py-0.5 rounded-md text-[11px] ${ton.fond} ${ton.texte}`}>
                          {LIBELLE[d.statut]}
                        </span>
                        <span className="font-display font-semibold text-[15px] tabular-nums">
                          {euros(d.montant)}
                        </span>
                        {d.urgent && (
                          <span className="text-[10.5px] text-red">
                            ouvert depuis {d.jours_ouvert} j
                          </span>
                        )}
                      </div>
                    </div>

                    <Frise
                      etapes={[
                        { libelle: "Constaté", faite: d.etape_constate },
                        { libelle: "Transmis", faite: d.etape_transmis },
                        { libelle: "Contacté", faite: d.etape_client_contacte },
                        { libelle: "Réglé", faite: d.etape_resolue },
                      ]}
                    />

                    {d.commentaire && (
                      <p className="text-[12.5px] text-ink-soft leading-snug text-pretty">
                        {d.commentaire}
                      </p>
                    )}
                  </Link>

                  {ouvert && (
                    <div className="bg-surface-muted border-t border-line px-3 py-2.5 flex flex-col gap-2">
                      {!d.client_nom && (
                        <form action={nommer} className="flex gap-2">
                          <input type="hidden" name="dossier" value={d.id} />
                          <input
                            name="client"
                            autoComplete="off"
                            placeholder="Nom du client…"
                            className="grow h-[38px] px-3 rounded-[10px] border border-line bg-surface text-[14px] placeholder:text-ink-faint"
                          />
                          <button className="px-3 h-[38px] rounded-[10px] bg-surface border border-line text-[12.5px]">
                            Nommer
                          </button>
                        </form>
                      )}
                      <form action={avancer} className="flex flex-wrap gap-1.5">
                        <input type="hidden" name="dossier" value={d.id} />
                        {d.statut === "signale" && (
                          <button
                            name="etape"
                            value="transmis"
                            className="grow h-[38px] px-2 rounded-[10px] bg-plum-soft text-plum text-[12px] font-medium"
                          >
                            Transmis
                          </button>
                        )}
                        {d.statut !== "client_contacte" && d.nature === "emport" && (
                          <button
                            name="etape"
                            value="contacte"
                            className="grow h-[38px] px-2 rounded-[10px] bg-blue-soft text-blue text-[12px] font-medium"
                          >
                            Client contacté
                          </button>
                        )}
                        {d.nature === "emport" && (
                          <button
                            name="etape"
                            value="restitue"
                            className="grow h-[38px] px-2 rounded-[10px] bg-green-soft text-green text-[12px] font-medium"
                          >
                            Restituée
                          </button>
                        )}
                        {d.facturable_client && (
                          <button
                            name="etape"
                            value="facture"
                            className="grow h-[38px] px-2 rounded-[10px] bg-green text-white text-[12px] font-medium"
                          >
                            Facturé
                          </button>
                        )}
                        <button
                          name="etape"
                          value="non_facture"
                          className="grow h-[38px] px-2 rounded-[10px] bg-red-soft text-red text-[12px] font-medium"
                        >
                          Perte sèche
                        </button>
                      </form>
                    </div>
                  )}
                </li>
              );
            })}
          </ul>
        )}

        <Link
          href={"/bouteilles/signaler" as Route}
          className="h-[52px] rounded-[15px] bg-plum text-white font-display font-semibold text-[15.5px] grid place-items-center"
        >
          Signaler une bouteille
        </Link>
      </div>
    </main>
  );
}
