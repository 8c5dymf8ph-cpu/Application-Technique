import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { aujourdhuiISO, jourISO, peutValider } from "@/lib/domaine";
import { colonneExiste } from "@/lib/schema";
import { Entete, Vide } from "@/app/composants/ui";
import { Depliant } from "@/app/composants/depliant";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { MarquerValide } from "@/app/composants/quitter-si-revenu";

export const dynamic = "force-dynamic";

type Inventaire = {
  id: string;
  libelle: string | null;
  statut: string;
  ouvert_par: string | null;
  ouvert_le: string;
  compte_le: string;
  valide_par: string | null;
  valide_le: string | null;
};

type Ligne = {
  id: string;
  ou: string;
  bouteille: string;
  quantite_theorique: number;
  quantite_comptee: number;
  ecart: number;
};

export default async function DetailInventaire({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ neuf?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { id } = await params;
  const { neuf } = await searchParams;

  // La colonne part en ligne avant la migration qui l'ajoute (0039) : deux
  // requêtes, choisies ici, jamais une condition booléenne dans le SQL.
  const comptePretes = await colonneExiste("inventaires", "compte_le");

  const [inv] = await sql<Inventaire[]>`
    select i.id, i.libelle, i.statut::text, uo.nom as ouvert_par, i.ouvert_le,
           ${comptePretes ? sql`i.compte_le` : sql`i.ouvert_le::date`} as compte_le,
           uv.nom as valide_par, i.valide_le
    from inventaires i
    left join utilisateurs uo on uo.id = i.ouvert_par
    left join utilisateurs uv on uv.id = i.valide_par
    where i.id = ${id} and i.type = 'bouteilles'`;
  if (!inv) notFound();

  const lignes = await sql<Ligne[]>`
    select l.id, coalesce(e.code, 'Réserve') as ou, bt.libelle as bouteille,
           l.quantite_theorique, l.quantite_comptee, l.ecart
    from inventaire_lignes_bouteille l
    join bouteille_types bt on bt.id = l.bouteille_type_id
    left join emplacements e on e.id = l.emplacement_id
    where l.inventaire_id = ${id}
    order by (l.emplacement_id is not null), coalesce(e.code, ''), bt.libelle`;

  const ecarts = lignes.filter((l) => l.ecart !== 0);
  const manquantes = ecarts.filter((l) => l.ecart < 0).reduce((n, l) => n - l.ecart, 0);
  const trouvees = ecarts.filter((l) => l.ecart > 0).reduce((n, l) => n + l.ecart, 0);

  async function valider() {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");
    await sql`
      update inventaires
         set statut = 'valide', valide_le = now(), valide_par = ${profil_.id}
       where id = ${id} and statut = 'brouillon'`;
    revalidatePath(`/bouteilles/inventaire/${id}`);
  }

  async function annuler() {
    "use server";
    await sql`delete from inventaires where id = ${id} and statut = 'brouillon'`;
    redirect("/bouteilles/inventaire" as Route);
  }

  // La date saisie en base (ouvert_le) n'est pas forcément celle du vrai
  // comptage — un brouillon repris plus tard, un comptage retapé après une
  // correction. Réglable tant que rien n'est validé : c'est cette date qui
  // part sur les régularisations à la validation (migration 0039).
  async function corrigerDate(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");
    const date = String(donnees.get("compte_le") ?? "").trim();
    if (!date) return;
    await sql`
      update inventaires set compte_le = ${date}::date
       where id = ${id} and statut = 'brouillon'`;
    revalidatePath(`/bouteilles/inventaire/${id}`);
  }

  /**
   * Défaire un comptage déjà validé.
   *
   * Un ajustement saisi à la main se corrige ou se supprime depuis
   * /administration/bouteilles — mais un comptage, une fois validé, n'avait
   * AUCUN chemin : pas de ligne à corriger, pas de suppression, rien. Une
   * erreur de comptage restait pour toujours, ou obligeait à poser un
   * ajustement À CÔTÉ pour la compenser — sans lien visible avec le
   * comptage fautif.
   *
   * Supprimer l'inventaire plutôt qu'une ligne : règle 4bis, « un comptage
   * reste vrai quand le théorique change » — on ne retouche pas un chiffre
   * compté, on défait le comptage entier s'il était faux, et on en refait
   * un. `on delete cascade` (migration 0001) emporte les régularisations
   * qu'il avait posées : le parc redevient ce qu'il était avant.
   */
  async function supprimerValide() {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/bouteilles");
    await sql`delete from inventaires where id = ${id} and statut = 'valide'`;
    redirect("/bouteilles/inventaire?fait=comptage-supprime" as Route);
  }

  const brouillon = inv.statut === "brouillon";

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      {neuf && <MarquerValide key={id} cle="inventaire-bouteilles" />}
      <Entete
        titre={inv.libelle ?? "Comptage"}
        sous_titre={
          brouillon
            ? `Brouillon · ${inv.ouvert_par ?? "—"} · compté le ${new Date(inv.compte_le).toLocaleDateString("fr-FR")}`
            : `Compté le ${new Date(inv.compte_le).toLocaleDateString("fr-FR")} · validé le ${new Date(inv.valide_le!).toLocaleDateString("fr-FR")} par ${inv.valide_par ?? "—"}`
        }
        retour="/bouteilles/inventaire"
      />

      <div className="px-5 py-4 flex flex-col gap-4">
        {brouillon && comptePretes && (
          <form action={corrigerDate} className="carte px-4 py-3 flex items-center gap-2.5">
            <span className="etiquette shrink-0">Compté le</span>
            <input
              name="compte_le"
              type="date"
              max={aujourdhuiISO()}
              defaultValue={jourISO(inv.compte_le)}
              className="flex-1 min-w-0 h-[40px] px-3 rounded-[11px] border border-line bg-surface text-[14px]"
            />
            <BoutonEnvoi className="shrink-0 h-[40px] px-3.5 rounded-[10px] bg-surface-muted border border-line text-[12.5px] font-medium">
              Corriger
            </BoutonEnvoi>
          </form>
        )}

        <div className="flex gap-2">
          <div className="flex-1 carte px-3 py-2.5 text-center">
            <div className="font-display font-semibold text-[21px] leading-none tabular-nums">
              {lignes.length}
            </div>
            <div className="etiquette mt-1 text-[8.5px]">Lignes comptées</div>
          </div>
          <div
            className={`flex-1 rounded-card border px-3 py-2.5 text-center ${
              manquantes > 0 ? "bg-red-soft border-red/20" : "carte"
            }`}
          >
            <div
              className={`font-display font-semibold text-[21px] leading-none tabular-nums ${
                manquantes > 0 ? "text-red" : ""
              }`}
            >
              {manquantes}
            </div>
            <div className="etiquette mt-1 text-[8.5px]">Manquantes</div>
          </div>
          <div className="flex-1 carte px-3 py-2.5 text-center">
            <div className="font-display font-semibold text-[21px] leading-none tabular-nums">
              {trouvees}
            </div>
            <div className="etiquette mt-1 text-[8.5px]">En trop</div>
          </div>
        </div>

        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Les écarts</h2>
          {ecarts.length === 0 ? (
            <Vide>
              Aucun écart : le compté correspond au théorique partout. Rien ne sera régularisé.
            </Vide>
          ) : (
            <ul className="carte divide-y divide-line">
              {ecarts.map((l) => (
                <li key={l.id} className="px-3.5 py-2.5 flex items-center gap-3">
                  <span className="grow min-w-0">
                    <span className="block text-[14px]">
                      {l.ou} · {l.bouteille}
                    </span>
                    <span className="block text-[11.5px] text-ink-faint tabular-nums">
                      théorique {l.quantite_theorique} · compté {l.quantite_comptee}
                    </span>
                  </span>
                  <span
                    className={`shrink-0 px-2 py-0.5 rounded-md text-[13px] tabular-nums ${
                      l.ecart < 0 ? "bg-red-soft text-red" : "bg-green-soft text-green"
                    }`}
                  >
                    {l.ecart > 0 ? "+" : "−"}
                    {Math.abs(l.ecart)}
                  </span>
                </li>
              ))}
            </ul>
          )}
        </section>

        {brouillon ? (
          <div className="flex flex-col gap-2">
            <form action={valider}>
              <BoutonEnvoi
                pendant="Enregistrement…"
                className="w-full h-[54px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]"
              >
                Valider — écrire les régularisations
              </BoutonEnvoi>
            </form>
            <p className="text-[11.5px] text-ink-faint text-pretty text-center">
              Chaque écart devient un mouvement tracé, rattaché à ce comptage. Rien n’est écrit
              directement dans un stock, et tout reste relisible.
            </p>
            <form action={annuler}>
              <button className="w-full h-[44px] rounded-[12px] bg-surface border border-line text-[13px] text-ink-faint">
                Supprimer ce brouillon
              </button>
            </form>
          </div>
        ) : (
          <>
            <p className="rounded-card bg-green-soft px-4 py-3 text-[13px] text-green text-pretty">
              {ecarts.length === 0
                ? "Validé sans écart : rien n’a été régularisé."
                : `Validé : ${ecarts.length} régularisation${ecarts.length > 1 ? "s" : ""} écrite${ecarts.length > 1 ? "s" : ""}, visible${ecarts.length > 1 ? "s" : ""} dans l’historique des mouvements.`}
            </p>

            {/* Un ajustement saisi à la main se corrige depuis
                /administration/bouteilles ; un comptage validé n'avait
                aucun chemin — ni ligne à corriger, ni suppression. */}
            {peutValider(profil.role) && (
              <Depliant
                titre="Supprimer ce comptage"
                aide="Pour un comptage faux, validé par erreur"
              >
                <p className="text-[13px] text-ink-soft text-pretty leading-snug">
                  {ecarts.length > 0
                    ? `Les ${ecarts.length} régularisation${ecarts.length > 1 ? "s" : ""} que ce comptage a posée${ecarts.length > 1 ? "s" : ""} ${ecarts.length > 1 ? "disparaissent" : "disparaît"} avec lui : le parc redevient ce qu’il était avant ce comptage.`
                    : "Ce comptage n’avait posé aucune régularisation ; le supprimer ne change rien au parc."}
                </p>
                <p className="text-[13px] text-ink-soft text-pretty leading-snug">
                  Un chiffre compté ne se corrige pas ligne à ligne (règle : un comptage reste
                  vrai quand le théorique change) — on défait le comptage entier, et on en
                  refait un bon.
                </p>
                <form action={supprimerValide}>
                  <BoutonEnvoi
                    pendant="Suppression…"
                    className="w-full h-[48px] rounded-[12px] bg-red-soft text-red font-medium text-[14.5px]"
                  >
                    Supprimer ce comptage
                  </BoutonEnvoi>
                </form>
              </Depliant>
            )}
          </>
        )}

        <Link
          href={"/bouteilles/inventaire" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Nouveau comptage
        </Link>
      </div>
    </main>
  );
}
