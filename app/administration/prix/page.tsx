import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { peutValider, euros, depuis } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";

export const dynamic = "force-dynamic";

type Ligne = {
  produit_id: string;
  designation: string;
  code: string;
  dernier_prix: number;
  prix_precedent: number;
  variation_pct: number;
  dernier_fournisseur: string | null;
  dernier_achat: string;
  jours_depuis: number;
};

/**
 * Les variations de prix, vues de l'administration — pas seulement sur la
 * fiche d'un produit qu'on a pensé à ouvrir.
 *
 * « Le prix » de chaque fiche affiche déjà la variation, mais seulement si
 * on sait QUEL produit regarder : sans savoir depuis quand un prix a bougé,
 * on peut passer à côté d'une hausse pendant des mois. Cet écran retourne le
 * problème — il liste tous les produits dont le DERNIER achat diffère du
 * précédent, la date à laquelle c'est arrivé en tête, pour qu'une hausse se
 * voie le jour même plutôt que le jour où quelqu'un ouvre la bonne fiche.
 */
export default async function VariationsPrix() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!peutValider(profil.role)) redirect("/");

  const lignes = await sql<Ligne[]>`
    select
      v.produit_id, p.designation, p.code,
      v.dernier_prix, v.prix_precedent, v.variation_pct, v.dernier_fournisseur,
      v.dernier_achat,
      extract(day from now() - v.dernier_achat)::int as jours_depuis
    from v_prix_produit v
    join produits p on p.id = v.produit_id
    where v.variation_pct is not null and v.variation_pct <> 0
    order by v.dernier_achat desc`;

  const hausses = lignes.filter((l) => Number(l.variation_pct) > 0);
  const baisses = lignes.filter((l) => Number(l.variation_pct) < 0);

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Variations de prix"
        sous_titre={`${lignes.length} produit${lignes.length > 1 ? "s" : ""} dont le dernier prix diffère du précédent`}
        retour="/administration"
      />

      <div className="px-5 py-4 flex flex-col gap-5">
        <p className="text-[13px] text-ink-soft text-pretty leading-snug">
          Chaque ligne compare les deux DERNIERS achats du produit — dès que le suivant confirme
          le nouveau prix, la ligne disparaît d'ici. La plus récente en tête, pour voir une hausse
          le jour où elle arrive plutôt que le jour où l'on ouvre par hasard la bonne fiche.
        </p>

        {lignes.length === 0 ? (
          <Vide>Aucune variation à signaler : les derniers prix payés confirment les précédents.</Vide>
        ) : (
          <>
            {hausses.length > 0 && (
              <section className="flex flex-col gap-2">
                <div className="flex items-baseline justify-between gap-3">
                  <h2 className="etiquette text-red">Prix en hausse</h2>
                  <span className="text-[12px] text-ink-faint tabular-nums">{hausses.length}</span>
                </div>
                <LigneVariations lignes={hausses} />
              </section>
            )}
            {baisses.length > 0 && (
              <section className="flex flex-col gap-2">
                <div className="flex items-baseline justify-between gap-3">
                  <h2 className="etiquette text-green">Prix en baisse</h2>
                  <span className="text-[12px] text-ink-faint tabular-nums">{baisses.length}</span>
                </div>
                <LigneVariations lignes={baisses} />
              </section>
            )}
          </>
        )}

        <Link
          href={"/administration" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Retour
        </Link>
      </div>
    </main>
  );
}

function LigneVariations({ lignes }: { lignes: Ligne[] }) {
  return (
    <ul className="carte divide-y divide-line">
      {lignes.map((l) => {
        const hausse = Number(l.variation_pct) > 0;
        return (
          <li key={l.produit_id}>
            <Link
              href={`/stock/produit/${l.produit_id}` as Route}
              className="px-3.5 py-2.5 flex items-center gap-3 active:bg-surface-muted"
            >
              <span className="grow min-w-0">
                <span className="block text-[13.5px] leading-snug text-pretty truncate">
                  {l.designation}
                </span>
                <span className="block text-[11.5px] text-ink-faint text-pretty mt-0.5">
                  {euros(l.prix_precedent)} → {euros(l.dernier_prix)}
                  {l.dernier_fournisseur && ` · ${l.dernier_fournisseur}`}
                  {" · "}
                  {depuis(l.jours_depuis, l.dernier_achat)}
                </span>
              </span>
              <span
                className={`shrink-0 px-2 py-1 rounded-md text-[12.5px] tabular-nums ${
                  hausse ? "bg-red-soft text-red" : "bg-green-soft text-green"
                }`}
              >
                {hausse ? "+" : "−"}
                {Math.abs(Number(l.variation_pct)).toLocaleString("fr-FR")} %
              </span>
            </Link>
          </li>
        );
      })}
    </ul>
  );
}
