import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { exigerEncadrement } from "@/lib/acces";
import { suitLesDossiers } from "@/lib/domaine";
import { colonneExiste } from "@/lib/schema";
import { codeDepuis } from "@/lib/suivis";
import { Confirmation, Entete } from "@/app/composants/ui";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { Depliant } from "@/app/composants/depliant";

export const dynamic = "force-dynamic";

type Etape = {
  id: string;
  libelle: string;
  est_verification: boolean;
  porte_sur_lieux: boolean;
  actif: boolean;
  nb_actes: number;
};

/**
 * Régler un dossier est réservé à qui suit les dossiers. Au niveau du MODULE :
 * une action serveur qui se refermerait sur une fonction déclarée à côté
 * d'elle ne ferait rien, sans un mot (règle 7duodecies).
 */
async function exigerReglage(ici: string) {
  const p = await exigerEncadrement();
  if (!suitLesDossiers(p.role)) redirect(ici as Route);
}

/**
 * Les étapes d'un dossier de suivi — le « quoi » de ses actes.
 *
 * Elles étaient posées par la migration, pour les punaises seulement :
 * détection canine, traitement chimique… Un contrat de désenfumage ou la
 * vérification des extincteurs n'a rien de tout ça. « J'aimerais pouvoir
 * éditer moi-même le quoi » : renommer, ajouter, retirer, et dire pour
 * chacune si elle est LA visite du contrat (celle qui fixe le rythme) et si
 * elle porte sur des lieux.
 *
 * Retirer n'efface pas : une étape qu'un acte a déjà utilisée sort de la
 * liste « Quoi », mais la chronologie passée garde son mot. Seule une étape
 * jamais utilisée se supprime.
 */
export default async function Etapes({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ fait?: string }>;
}) {
  const profil = await exigerEncadrement();
  if (!suitLesDossiers(profil.role)) redirect("/suivis" as Route);
  const { id } = await params;
  const { fait } = await searchParams;

  const [dossier] = await sql<
    { titre: string; parent_id: string | null; nature_code: string; nature: string;
      periodicite_jours: number | null }[]
  >`
    select s.titre, s.parent_id, s.nature_code, n.libelle as nature, n.periodicite_jours
      from suivis s join natures_suivi n on n.code = s.nature_code
     where s.id = ${id}`;
  if (!dossier) notFound();

  // `actif` arrive avec la 0041 : avant, toutes les étapes sont actives et
  // une étape utilisée ne peut pas se retirer.
  const retirable = await colonneExiste("types_acte", "actif");
  const etapes = await sql<Etape[]>`
    select t.id, t.libelle, t.est_verification, t.porte_sur_lieux,
           ${retirable ? sql`t.actif` : sql`true`} as actif,
           (select count(*) from actes a where a.type_acte_id = t.id)::int as nb_actes
      from types_acte t
     where t.nature_code = ${dossier.nature_code}
     order by t.ordre, t.libelle`;
  const actives = etapes.filter((e) => e.actif);
  const retirees = etapes.filter((e) => !e.actif);

  const ici = `/suivis/${id}/etapes`;

  async function reglerDossier(donnees: FormData) {
    "use server";
    await exigerReglage(ici);
    const nom = String(donnees.get("nom") ?? "").trim();
    if (nom.length < 3) return;
    const mois = Number(String(donnees.get("mois") ?? "").replace(",", "."));
    await sql`
      update natures_suivi
         set libelle = ${nom},
             periodicite_jours = ${mois > 0 ? Math.round((mois * 365) / 12) : null}
       where code = ${dossier.nature_code}`;
    // Le dossier permanent porte le nom du contrat : il suit le renommage.
    if (!dossier.parent_id) await sql`update suivis set titre = ${nom} where id = ${id}`;
    revalidatePath(ici);
    redirect(`${ici}?fait=enregistre` as Route);
  }

  async function modifierEtape(donnees: FormData) {
    "use server";
    await exigerReglage(ici);
    const etape = String(donnees.get("etape") ?? "");
    const libelle = String(donnees.get("libelle") ?? "").trim();
    if (!etape || !libelle) return;
    await sql`
      update types_acte
         set libelle = ${libelle},
             est_verification = ${donnees.get("visite") === "on"},
             porte_sur_lieux = ${donnees.get("lieux") === "on"}
       where id = ${etape} and nature_code = ${dossier.nature_code}`;
    revalidatePath(ici);
    redirect(`${ici}?fait=enregistre` as Route);
  }

  async function ajouterEtape(donnees: FormData) {
    "use server";
    await exigerReglage(ici);
    const libelle = String(donnees.get("libelle") ?? "").trim();
    if (!libelle) return;
    const existants = await sql<{ code: string }[]>`
      select code from types_acte where nature_code = ${dossier.nature_code}`;
    let code = codeDepuis(libelle);
    while (existants.some((e) => e.code === code)) code += "-bis";
    await sql`
      insert into types_acte (nature_code, code, libelle, est_verification, est_traitement,
                              porte_sur_lieux, ordre)
      values (${dossier.nature_code}, ${code}, ${libelle}, ${donnees.get("visite") === "on"},
              false, ${donnees.get("lieux") === "on"},
              (select coalesce(max(ordre), 0) + 1 from types_acte
                where nature_code = ${dossier.nature_code}))`;
    revalidatePath(ici);
    redirect(`${ici}?fait=etape-ajoutee` as Route);
  }

  async function retirerEtape(donnees: FormData) {
    "use server";
    await exigerReglage(ici);
    const etape = String(donnees.get("etape") ?? "");
    const [u] = await sql<{ n: number }[]>`
      select count(*)::int as n from actes where type_acte_id = ${etape}`;
    if (!u) return;
    if (u.n === 0) {
      await sql`delete from types_acte where id = ${etape} and nature_code = ${dossier.nature_code}`;
      revalidatePath(ici);
      redirect(`${ici}?fait=etape-supprimee` as Route);
    }
    if (!retirable) redirect(`${ici}?fait=etape-utilisee` as Route);
    await sql`
      update types_acte set actif = false
       where id = ${etape} and nature_code = ${dossier.nature_code}`;
    revalidatePath(ici);
    redirect(`${ici}?fait=etape-retiree` as Route);
  }

  async function remettreEtape(donnees: FormData) {
    "use server";
    await exigerReglage(ici);
    if (!retirable) return;
    await sql`
      update types_acte set actif = true
       where id = ${String(donnees.get("etape") ?? "")} and nature_code = ${dossier.nature_code}`;
    revalidatePath(ici);
    redirect(`${ici}?fait=enregistre` as Route);
  }

  const mois = dossier.periodicite_jours
    ? Math.round((dossier.periodicite_jours * 12) / 365)
    : null;

  const caseACocher = (nom: string, libelle: string, coche: boolean, aide: string) => (
    <label className="flex items-start gap-2.5 cursor-pointer">
      <input
        type="checkbox"
        name={nom}
        defaultChecked={coche}
        className="mt-0.5 w-[18px] h-[18px] shrink-0 accent-[#453A6E]"
      />
      <span className="flex flex-col">
        <span className="text-[14px]">{libelle}</span>
        <span className="text-[11.5px] text-ink-faint text-pretty leading-snug">{aide}</span>
      </span>
    </label>
  );

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Les étapes" sous_titre={dossier.titre} retour={`/suivis/${id}`} />

      <div className="px-5 py-4 flex flex-col gap-4">
        <Confirmation quoi={fait} />

        {/* Le dossier lui-même : son nom et le rythme de ses visites. */}
        <form action={reglerDossier} className="carte px-4 py-3.5 flex flex-col gap-3">
          <h2 className="titre text-[15.5px]">Le dossier</h2>
          <label className="flex flex-col gap-1">
            <span className="etiquette">Nom</span>
            <input
              name="nom"
              required
              minLength={3}
              defaultValue={dossier.nature}
              className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[15.5px]"
            />
          </label>
          <label className="flex flex-col gap-1">
            <span className="etiquette">Une visite tous les… (facultatif)</span>
            <span className="flex items-center gap-2">
              <input
                name="mois"
                type="number"
                min={1}
                step={1}
                inputMode="numeric"
                defaultValue={mois ?? ""}
                placeholder="—"
                className="w-[96px] h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[16px] tabular-nums"
              />
              <span className="text-[14px] text-ink-soft">mois</span>
            </span>
          </label>
          <BoutonEnvoi
            pendant="Enregistrement…"
            className="h-[46px] rounded-[12px] bg-surface-muted border border-line font-display font-semibold text-[14.5px]"
          >
            Enregistrer
          </BoutonEnvoi>
        </form>

        <section className="flex flex-col gap-2">
          <h2 className="titre text-[15.5px]">Le « quoi » · {actives.length}</h2>
          <p className="text-[12.5px] text-ink-faint text-pretty leading-snug">
            Ce qu’on choisit en premier en ajoutant un acte. Chaque étape se renomme ; elle
            peut compter comme la visite du contrat, et porter sur des lieux.
          </p>

          {actives.map((e) => (
            <div key={e.id} className="carte px-4 py-3.5 flex flex-col gap-2.5">
              <form action={modifierEtape} className="flex flex-col gap-2.5">
                <input type="hidden" name="etape" value={e.id} />
                <input
                  name="libelle"
                  required
                  defaultValue={e.libelle}
                  aria-label="Nom de l’étape"
                  className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[15.5px] font-display font-semibold"
                />
                {caseACocher(
                  "visite",
                  "C’est la visite du contrat",
                  e.est_verification,
                  "Elle fixe le rythme : le dossier dit quand la suivante est en retard.",
                )}
                {caseACocher(
                  "lieux",
                  "Elle porte sur des lieux",
                  e.porte_sur_lieux,
                  "On coche les chambres ou les locaux concernés, avec un résultat.",
                )}
                <BoutonEnvoi
                  pendant="…"
                  className="h-[42px] rounded-[11px] bg-surface-muted border border-line text-[14px]"
                >
                  Enregistrer
                </BoutonEnvoi>
              </form>
              <form action={retirerEtape} className="flex items-center gap-2">
                <input type="hidden" name="etape" value={e.id} />
                <span className="grow text-[11.5px] text-ink-faint">
                  {e.nb_actes === 0
                    ? "Jamais utilisée"
                    : `Utilisée par ${e.nb_actes} acte${e.nb_actes > 1 ? "s" : ""}`}
                </span>
                <button className="h-[38px] min-h-0 px-3 rounded-[10px] text-[13px] text-red">
                  {e.nb_actes === 0 ? "Supprimer" : "Retirer"}
                </button>
              </form>
            </div>
          ))}

          <Depliant titre="Ajouter une étape">
            <form action={ajouterEtape} className="flex flex-col gap-2.5">
              <input
                name="libelle"
                required
                autoComplete="off"
                placeholder="Remplacement d’un extincteur…"
                className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[15.5px] placeholder:text-ink-faint"
              />
              {caseACocher(
                "visite",
                "C’est la visite du contrat",
                false,
                "Elle fixe le rythme : le dossier dit quand la suivante est en retard.",
              )}
              {caseACocher(
                "lieux",
                "Elle porte sur des lieux",
                false,
                "On coche les chambres ou les locaux concernés, avec un résultat.",
              )}
              <BoutonEnvoi
                pendant="Ajout…"
                className="h-[46px] rounded-[12px] bg-plum text-white font-display font-semibold text-[15px]"
              >
                Ajouter
              </BoutonEnvoi>
            </form>
          </Depliant>

          {retirees.length > 0 && (
            <Depliant titre="Étapes retirées" indice={`${retirees.length}`}>
              <div className="flex flex-col gap-2">
                {retirees.map((e) => (
                  <form
                    key={e.id}
                    action={remettreEtape}
                    className="flex items-center gap-2 px-1"
                  >
                    <input type="hidden" name="etape" value={e.id} />
                    <span className="grow text-[14px] text-ink-soft">{e.libelle}</span>
                    <button className="h-[38px] min-h-0 px-3 rounded-[10px] bg-surface-muted text-[13px]">
                      Remettre
                    </button>
                  </form>
                ))}
              </div>
            </Depliant>
          )}
        </section>
      </div>
    </main>
  );
}
