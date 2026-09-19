import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { Entete } from "@/app/composants/ui";
import { ComptageProduits, type LigneProduit } from "@/app/composants/comptage-produits";

export const dynamic = "force-dynamic";

type Precedent = {
  id: string;
  libelle: string | null;
  statut: string;
  valide_le: string | null;
  ouvert_le: string;
  ouvert_par: string | null;
  lignes: number;
  ecarts: number;
};

export default async function InventaireMateriel() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  const lignes = await sql<LigneProduit[]>`
    select id, designation, code,
           coalesce(categorie, 'Sans catégorie') as categorie,
           unite, stock as theorique, photo_principale as photo
    from v_stock_produits
    where actif
    order by coalesce(categorie, 'Sans catégorie'), designation`;

  const precedents = await sql<Precedent[]>`
    select i.id, i.libelle, i.statut::text, i.valide_le, i.ouvert_le, u.nom as ouvert_par,
           (select count(*) from inventaire_lignes_produit l
             where l.inventaire_id = i.id)::int as lignes,
           (select count(*) from inventaire_lignes_produit l
             where l.inventaire_id = i.id and l.ecart <> 0)::int as ecarts
    from inventaires i
    left join utilisateurs u on u.id = i.ouvert_par
    where i.type = 'materiel'
    order by i.ouvert_le desc limit 6`;

  async function enregistrer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");

    const comptees: { produit: string; compte: number }[] = [];
    for (const [cle, valeur] of donnees.entries()) {
      if (!cle.startsWith("p-")) continue;
      const texte = String(valeur).trim();
      if (texte === "") continue;
      comptees.push({ produit: cle.slice(2), compte: Number(texte) });
    }
    if (comptees.length === 0) return;

    const [inv] = await sql<{ id: string }[]>`
      insert into inventaires (type, libelle, ouvert_par)
      values ('materiel', ${String(donnees.get("libelle") ?? "").trim() || null}, ${profil_.id})
      returning id`;

    // Le théorique est relu au moment de l'écriture : c'est lui qui fait
    // l'écart, et il doit être celui de l'instant, pas celui de l'affichage.
    for (const l of comptees) {
      await sql`
        insert into inventaire_lignes_produit (inventaire_id, produit_id,
                                               quantite_theorique, quantite_comptee)
        select ${inv.id}, ${l.produit},
               coalesce((select stock from v_stock_produits where id = ${l.produit}), 0),
               ${l.compte}`;
    }

    redirect(`/stock/inventaire/${inv.id}` as Route);
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Inventaire" sous_titre="Compter le matériel" retour="/stock" />

      <form action={enregistrer} className="px-5 py-4 flex flex-col gap-5">
        <p className="text-[13px] text-ink-soft text-pretty leading-snug">
          Comptez ce que vous voyez. Rien n’est corrigé directement : l’écart entre le compté et
          le théorique produit une régularisation, datée et signée, que l’on pourra relire.
        </p>

        <ComptageProduits lignes={lignes} />

        <label className="flex flex-col gap-1.5">
          <span className="etiquette">Nom du comptage (facultatif)</span>
          <input
            name="libelle"
            autoComplete="off"
            placeholder="Inventaire de fin d’année"
            className="w-full carte px-4 h-[48px] text-[16px] placeholder:text-ink-faint"
          />
        </label>

        <button className="h-[54px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]">
          Enregistrer le comptage
        </button>
        <p className="text-[11.5px] text-ink-faint text-pretty text-center -mt-2">
          Le comptage s’enregistre en brouillon. Les écarts se relisent avant d’être validés.
        </p>

        {precedents.length > 0 && (
          <section className="flex flex-col gap-2 border-t border-line pt-5">
            <h2 className="etiquette">Comptages précédents</h2>
            <ul className="flex flex-col gap-1.5">
              {precedents.map((p) => (
                <li key={p.id}>
                  <Link
                    href={`/stock/inventaire/${p.id}` as Route}
                    className="px-3.5 py-2.5 rounded-card bg-surface-muted border border-line flex items-center gap-3"
                  >
                    <span className="grow min-w-0">
                      <span className="block text-[13.5px]">
                        {p.libelle ?? "Comptage"} ·{" "}
                        {new Date(p.valide_le ?? p.ouvert_le).toLocaleDateString("fr-FR")}
                      </span>
                      <span className="block text-[11.5px] text-ink-faint">
                        {p.ouvert_par ?? "—"} · {p.lignes} produit{p.lignes > 1 ? "s" : ""} ·{" "}
                        {p.ecarts === 0 ? "aucun écart" : `${p.ecarts} écart${p.ecarts > 1 ? "s" : ""}`}
                      </span>
                    </span>
                    {p.statut === "brouillon" && (
                      <span className="shrink-0 px-2 py-0.5 rounded-md bg-amber-soft text-amber text-[11px]">
                        brouillon
                      </span>
                    )}
                  </Link>
                </li>
              ))}
            </ul>
          </section>
        )}
      </form>
    </main>
  );
}
