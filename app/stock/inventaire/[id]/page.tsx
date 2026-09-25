import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { MarquerValide } from "@/app/composants/quitter-si-revenu";

export const dynamic = "force-dynamic";

type Inventaire = {
  id: string;
  libelle: string | null;
  statut: string;
  ouvert_par: string | null;
  ouvert_le: string;
  valide_par: string | null;
  valide_le: string | null;
};

type Ligne = {
  id: string;
  designation: string;
  code: string;
  unite: string;
  quantite_theorique: number;
  quantite_comptee: number;
  ecart: number;
  prix_unitaire: number | null;
};

export default async function DetailInventaireMateriel({
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

  const [inv] = await sql<Inventaire[]>`
    select i.id, i.libelle, i.statut::text, uo.nom as ouvert_par, i.ouvert_le,
           uv.nom as valide_par, i.valide_le
    from inventaires i
    left join utilisateurs uo on uo.id = i.ouvert_par
    left join utilisateurs uv on uv.id = i.valide_par
    where i.id = ${id} and i.type = 'materiel'`;
  if (!inv) notFound();

  const lignes = await sql<Ligne[]>`
    select l.id, p.designation, p.code, p.unite,
           l.quantite_theorique, l.quantite_comptee, l.ecart, p.prix_unitaire
    from inventaire_lignes_produit l
    join produits p on p.id = l.produit_id
    where l.inventaire_id = ${id}
    order by (l.ecart = 0), p.designation`;

  const ecarts = lignes.filter((l) => Number(l.ecart) !== 0);
  const manquant = ecarts
    .filter((l) => Number(l.ecart) < 0)
    .reduce((n, l) => n - Number(l.ecart), 0);
  const trouve = ecarts
    .filter((l) => Number(l.ecart) > 0)
    .reduce((n, l) => n + Number(l.ecart), 0);
  // Ce que l'écart représente en argent, quand le prix est connu.
  const valeur = ecarts.reduce(
    (n, l) => n + Number(l.ecart) * Number(l.prix_unitaire ?? 0),
    0,
  );
  const sansPrix = ecarts.filter((l) => l.prix_unitaire === null).length;

  async function valider() {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");
    await sql`
      update inventaires
         set statut = 'valide', valide_le = now(), valide_par = ${profil_.id}
       where id = ${id} and statut = 'brouillon'`;
    revalidatePath(`/stock/inventaire/${id}`);
  }

  async function annuler() {
    "use server";
    await sql`delete from inventaires where id = ${id} and statut = 'brouillon'`;
    redirect("/stock/inventaire" as Route);
  }

  const brouillon = inv.statut === "brouillon";

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      {neuf && <MarquerValide cle="inventaire-materiel" />}
      <Entete
        titre={inv.libelle ?? "Comptage"}
        sous_titre={
          brouillon
            ? `Brouillon · ${inv.ouvert_par ?? "—"}`
            : `Validé le ${new Date(inv.valide_le!).toLocaleDateString("fr-FR")} par ${inv.valide_par ?? "—"}`
        }
        retour="/stock/inventaire"
      />

      <div className="px-5 py-4 flex flex-col gap-4">
        <div className="flex gap-2">
          <div className="flex-1 carte px-3 py-2.5 text-center">
            <div className="font-display font-semibold text-[21px] leading-none tabular-nums">
              {lignes.length}
            </div>
            <div className="etiquette mt-1 text-[8.5px]">Comptés</div>
          </div>
          <div
            className={`flex-1 rounded-card border px-3 py-2.5 text-center ${
              manquant > 0 ? "bg-red-soft border-red/20" : "carte"
            }`}
          >
            <div
              className={`font-display font-semibold text-[21px] leading-none tabular-nums ${
                manquant > 0 ? "text-red" : ""
              }`}
            >
              {manquant}
            </div>
            <div className="etiquette mt-1 text-[8.5px]">Manquants</div>
          </div>
          <div className="flex-1 carte px-3 py-2.5 text-center">
            <div className="font-display font-semibold text-[21px] leading-none tabular-nums">
              {trouve}
            </div>
            <div className="etiquette mt-1 text-[8.5px]">En trop</div>
          </div>
        </div>

        {ecarts.length > 0 && (
          <p
            className={`text-[12.5px] text-pretty leading-snug ${
              valeur < 0 ? "text-red" : "text-ink-soft"
            }`}
          >
            L’écart représente {euros(Math.abs(valeur))} {valeur < 0 ? "de moins" : "de plus"} en
            stock.
            {sansPrix > 0 &&
              ` ${sansPrix} produit${sansPrix > 1 ? "s" : ""} sans prix n’${sansPrix > 1 ? "y sont" : "y est"} pas compté${sansPrix > 1 ? "s" : ""}.`}
          </p>
        )}

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
                    <span className="block text-[14px] leading-snug text-pretty">
                      {l.designation}
                    </span>
                    <span className="block text-[11.5px] text-ink-faint tabular-nums">
                      théorique {l.quantite_theorique} · compté {l.quantite_comptee}
                      {l.prix_unitaire !== null &&
                        ` · ${euros(Math.abs(Number(l.ecart)) * Number(l.prix_unitaire))}`}
                    </span>
                  </span>
                  <span
                    className={`shrink-0 px-2 py-0.5 rounded-md text-[13px] tabular-nums ${
                      Number(l.ecart) < 0 ? "bg-red-soft text-red" : "bg-green-soft text-green"
                    }`}
                  >
                    {Number(l.ecart) > 0 ? "+" : "−"}
                    {Math.abs(Number(l.ecart))}
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
              Chaque écart devient un mouvement tracé, de motif « inventaire », rattaché à ce
              comptage. Rien n’est écrit directement dans un stock.
            </p>
            <form action={annuler}>
              <button className="w-full h-[44px] rounded-[12px] bg-surface border border-line text-[13px] text-ink-faint">
                Supprimer ce brouillon
              </button>
            </form>
          </div>
        ) : (
          <p className="rounded-card bg-green-soft px-4 py-3 text-[13px] text-green text-pretty">
            {ecarts.length === 0
              ? "Validé sans écart : rien n’a été régularisé."
              : `Validé : ${ecarts.length} régularisation${ecarts.length > 1 ? "s" : ""} écrite${ecarts.length > 1 ? "s" : ""}, visible${ecarts.length > 1 ? "s" : ""} dans l’historique de chaque produit.`}
          </p>
        )}

        <Link
          href={"/stock/inventaire" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Nouveau comptage
        </Link>
      </div>
    </main>
  );
}
