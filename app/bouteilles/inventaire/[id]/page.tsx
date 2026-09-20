import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { Entete, Vide } from "@/app/composants/ui";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";

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
  ou: string;
  bouteille: string;
  quantite_theorique: number;
  quantite_comptee: number;
  ecart: number;
};

export default async function DetailInventaire({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { id } = await params;

  const [inv] = await sql<Inventaire[]>`
    select i.id, i.libelle, i.statut::text, uo.nom as ouvert_par, i.ouvert_le,
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

  const brouillon = inv.statut === "brouillon";

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={inv.libelle ?? "Comptage"}
        sous_titre={
          brouillon
            ? `Brouillon · ${inv.ouvert_par ?? "—"}`
            : `Validé le ${new Date(inv.valide_le!).toLocaleDateString("fr-FR")} par ${inv.valide_par ?? "—"}`
        }
        retour="/bouteilles/inventaire"
      />

      <div className="px-5 py-4 flex flex-col gap-4">
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
          <p className="rounded-card bg-green-soft px-4 py-3 text-[13px] text-green text-pretty">
            {ecarts.length === 0
              ? "Validé sans écart : rien n’a été régularisé."
              : `Validé : ${ecarts.length} régularisation${ecarts.length > 1 ? "s" : ""} écrite${ecarts.length > 1 ? "s" : ""}, visible${ecarts.length > 1 ? "s" : ""} dans l’historique des mouvements.`}
          </p>
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
