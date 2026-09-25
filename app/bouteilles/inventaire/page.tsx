import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { Entete } from "@/app/composants/ui";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { Comptage, type LigneComptage } from "@/app/composants/comptage";
import { QuitterSiRevenu } from "@/app/composants/quitter-si-revenu";

export const dynamic = "force-dynamic";

type Reserve = { id: string; libelle: string; en_reserve: number };
type Lieu = { emplacement_id: string; code: string; etage: string };
type Type = { id: string; libelle: string };
type Precedent = {
  id: string;
  libelle: string | null;
  valide_le: string;
  valide_par: string | null;
  ecarts: number;
};

export default async function Inventaire() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  const reserve = await sql<Reserve[]>`
    select bouteille_type_id as id, libelle, en_reserve::int
    from v_stock_bouteilles order by libelle`;

  const types = await sql<Type[]>`
    select id, libelle from bouteille_types order by libelle`;

  const lieux = await sql<Lieu[]>`
    select e.id as emplacement_id, e.code, et.nom as etage
    from emplacements e join etages et on et.id = e.etage_id
    where e.actif and e.dote_bouteilles
    order by et.ordre, e.ordre, e.code`;

  // Le théorique de chaque chambre, pour que le comptage ait un point de
  // comparaison plutôt qu'une page blanche.
  const theoriques = await sql<
    { emplacement_id: string; bouteille_type_id: string; quantite_reelle: number }[]
  >`
    select emplacement_id, bouteille_type_id, quantite_reelle::int
    from v_bouteilles_par_emplacement`;

  const precedents = await sql<Precedent[]>`
    select i.id, i.libelle, i.valide_le, u.nom as valide_par,
           (select count(*) from inventaire_lignes_bouteille l
             where l.inventaire_id = i.id and l.ecart <> 0)::int as ecarts
    from inventaires i
    left join utilisateurs u on u.id = i.valide_par
    where i.type = 'bouteilles' and i.statut = 'valide'
    order by i.valide_le desc limit 5`;

  const chambres = lieux.map((l) => ({
    code: l.code,
    etage: l.etage,
    lignes: types.map<LigneComptage>((t) => ({
      // Un séparateur qui ne peut pas apparaître dans un identifiant :
      // ceux-ci contiennent des tirets, et une découpe sur le tiret
      // renverrait un morceau d'identifiant.
      cle: `c__${l.emplacement_id}__${t.id}`,
      emplacement_id: l.emplacement_id,
      bouteille_type_id: t.id,
      bouteille: t.libelle,
      theorique:
        theoriques.find(
          (x) => x.emplacement_id === l.emplacement_id && x.bouteille_type_id === t.id,
        )?.quantite_reelle ?? 0,
    })),
  }));

  async function enregistrer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");

    type Ligne = { emplacement: string | null; type: string; compte: number };
    const comptees: Ligne[] = [];
    for (const [cle, valeur] of donnees.entries()) {
      const texte = String(valeur).trim();
      if (texte === "") continue;
      if (cle.startsWith("r__")) {
        comptees.push({ emplacement: null, type: cle.slice(3), compte: Number(texte) });
      } else if (cle.startsWith("c__")) {
        const [, emplacement, type] = cle.split("__");
        comptees.push({ emplacement, type, compte: Number(texte) });
      }
    }
    if (comptees.length === 0) return;

    const [inv] = await sql<{ id: string }[]>`
      insert into inventaires (type, libelle, ouvert_par)
      values ('bouteilles',
              ${String(donnees.get("libelle") ?? "").trim() || null},
              ${profil_.id})
      returning id`;

    // Le théorique est relu au moment de l'écriture : c'est lui qui fait l'écart,
    // et il doit être celui de l'instant, pas celui de l'affichage.
    for (const l of comptees) {
      await sql`
        insert into inventaire_lignes_bouteille (inventaire_id, bouteille_type_id,
                                                 emplacement_id, quantite_theorique,
                                                 quantite_comptee)
        select ${inv.id}, ${l.type}, ${l.emplacement},
               coalesce((
                 select sum(p.qte)::int from v_bouteilles_positions p
                 where p.bouteille_type_id = ${l.type}
                   and p.lieu = ${l.emplacement === null ? "reserve" : "emplacement"}
                   and p.emplacement_id is not distinct from ${l.emplacement}
               ), 0),
               ${l.compte}`;
    }

    redirect(`/bouteilles/inventaire/${inv.id}?neuf=1` as Route);
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <QuitterSiRevenu cle="inventaire-bouteilles" vers="/bouteilles/inventaire" />
      <Entete titre="Inventaire" sous_titre="Compter les bouteilles" retour="/bouteilles" />

      <form action={enregistrer} className="px-5 py-4 flex flex-col gap-5">
        <p className="text-[13px] text-ink-soft text-pretty leading-snug">
          Comptez ce que vous voyez. Rien n’est corrigé directement : l’écart entre le compté et
          le théorique produit une régularisation, datée et signée, que l’on pourra relire.
        </p>

        <section className="flex flex-col gap-2">
          <h2 className="etiquette">La réserve</h2>
          <div className="flex gap-2">
            {reserve.map((r) => (
              <label key={r.id} className="flex-1 min-w-0 carte px-3 py-3 flex flex-col gap-1.5">
                <span className="text-[14px] leading-tight">{r.libelle}</span>
                <span className="text-[11.5px] text-ink-faint tabular-nums">
                  théorique&nbsp;: {r.en_reserve}
                </span>
                <input
                  name={`r__${r.id}`}
                  type="number"
                  min={0}
                  inputMode="numeric"
                  placeholder={String(r.en_reserve)}
                  className="w-full h-[48px] px-3 rounded-[11px] border border-line bg-surface-muted text-[17px] tabular-nums text-center placeholder:text-ink-faint/60"
                />
              </label>
            ))}
          </div>
        </section>

        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Les chambres</h2>
          <Comptage lieux={chambres} />
        </section>

        <label className="flex flex-col gap-1.5">
          <span className="etiquette">Nom du comptage (facultatif)</span>
          <input
            name="libelle"
            autoComplete="off"
            placeholder="Inventaire du mois"
            className="w-full carte px-4 h-[48px] text-[16px] placeholder:text-ink-faint"
          />
        </label>

        <BoutonEnvoi
                pendant="Ouverture…"
                className="h-[54px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]"
              >
          Enregistrer le comptage
        </BoutonEnvoi>
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
                    href={`/bouteilles/inventaire/${p.id}` as Route}
                    className="px-3.5 py-2.5 rounded-card bg-surface-muted border border-line flex items-center gap-3"
                  >
                    <span className="grow min-w-0">
                      <span className="block text-[13.5px]">
                        {p.libelle ?? "Comptage"} ·{" "}
                        {new Date(p.valide_le).toLocaleDateString("fr-FR")}
                      </span>
                      <span className="block text-[11.5px] text-ink-faint">
                        {p.valide_par ?? "—"} ·{" "}
                        {p.ecarts === 0
                          ? "aucun écart"
                          : `${p.ecarts} écart${p.ecarts > 1 ? "s" : ""}`}
                      </span>
                    </span>
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
