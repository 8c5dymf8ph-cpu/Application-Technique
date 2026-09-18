import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";
import { Filtres, Recherche, Stat } from "@/app/composants/suivi";
import { EtatStock, JaugeStock, VignetteProduit } from "@/app/composants/produit";

export const dynamic = "force-dynamic";

type Produit = {
  id: string;
  code: string;
  designation: string;
  categorie: string | null;
  categorie_lieu: string | null;
  unite: string;
  prix_unitaire: number | null;
  prix_inconnu: boolean;
  seuil_alerte: number;
  photo_principale: string | null;
  stock: number;
  valeur_stock: number | null;
  sous_seuil: boolean;
  dernier_mouvement: string | null;
};

export default async function Stock({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; lieu?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { q = "", lieu = "tous" } = await searchParams;
  const terme = q.trim().toLowerCase();

  const [c] = await sql<
    { alertes: number; produits: number; valeur: number; sans_prix: number; rupture: number }[]
  >`
    select
      count(*) filter (where sous_seuil)::int          as alertes,
      count(*)::int                                    as produits,
      coalesce(sum(valeur_stock), 0)                   as valeur,
      count(*) filter (where prix_inconnu)::int        as sans_prix,
      count(*) filter (where stock <= 0)::int          as rupture
    from v_stock_produits where actif`;

  // Les familles de lieu viennent des données, pas d'une liste écrite en dur :
  // le référentiel peut changer sans qu'on retouche l'écran.
  const familles = await sql<{ lieu: string; nombre: number }[]>`
    select coalesce(categorie_lieu, 'Sans catégorie') as lieu, count(*)::int as nombre
    from v_stock_produits where actif
    group by 1 order by 2 desc, 1`;

  const produits = await sql<Produit[]>`
    select id, code, designation, categorie, categorie_lieu, unite,
           prix_unitaire, prix_inconnu, seuil_alerte, photo_principale,
           stock, valeur_stock, sous_seuil, dernier_mouvement
    from v_stock_produits
    where actif
      and (${lieu} = 'tous'
        or (${lieu} = 'alertes' and sous_seuil)
        or coalesce(categorie_lieu, 'Sans catégorie') = ${lieu})
      and (${terme} = ''
        or lower(designation) like ${"%" + terme + "%"}
        or lower(code) like ${"%" + terme + "%"}
        or lower(coalesce(categorie, '')) like ${"%" + terme + "%"})
    order by sous_seuil desc, designation`;

  const lien = (l: string) =>
    `/stock?${new URLSearchParams({ lieu: l, ...(q ? { q } : {}) })}` as Route;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Stock"
        sous_titre={`${c.produits} produits · ${euros(c.valeur)}`}
        retour="/"
      />

      <div className="px-5 py-4 flex flex-col gap-3.5">
        <div className="flex gap-2">
          <Stat
            valeur={c.alertes}
            libelle="Sous le seuil"
            ton={c.alertes > 0 ? "alerte" : undefined}
          />
          <Stat valeur={c.rupture} libelle="À zéro" ton={c.rupture > 0 ? "alerte" : undefined} />
          <Stat valeur={c.produits} libelle="Produits" />
          <Stat valeur={euros(c.valeur)} libelle="Valeur HT" />
        </div>

        {c.sans_prix > 0 && (
          <p className="text-[11.5px] text-amber text-pretty leading-snug">
            {c.sans_prix} produit{c.sans_prix > 1 ? "s" : ""} sans prix : ils ne sont pas comptés
            dans la valeur, et ils ne le sont pas non plus pour zéro.
          </p>
        )}

        <Recherche valeur={q} placeholder="Chercher un produit…" caches={{ lieu }} />

        <Filtres
          actif={lieu}
          lien={lien}
          choix={[
            { valeur: "tous", libelle: "Tous", nombre: c.produits },
            { valeur: "alertes", libelle: "Sous le seuil", nombre: c.alertes },
            ...familles.map((f) => ({ valeur: f.lieu, libelle: f.lieu, nombre: f.nombre })),
          ]}
        />

        {produits.length === 0 ? (
          <Vide>
            {terme ? `Aucun produit ne correspond à « ${q} ».` : "Aucun produit ici."}
          </Vide>
        ) : (
          <ul className="flex flex-col gap-2">
            {produits.map((p) => (
              <li key={p.id}>
                <Link
                  href={`/stock/produit/${p.id}` as Route}
                  className="carte overflow-hidden flex active:bg-surface-muted"
                >
                  {/* Le liseré dit l'état avant même qu'on lise le chiffre. */}
                  <span
                    aria-hidden
                    className={`w-[5px] shrink-0 ${
                      p.stock <= 0 ? "bg-red" : p.sous_seuil ? "bg-amber" : "bg-green"
                    }`}
                  />
                  <span className="grow min-w-0 px-3 py-3 flex items-center gap-3">
                    <VignetteProduit photo={p.photo_principale} taille={52} />
                    <span className="grow min-w-0 flex flex-col gap-1.5">
                      <span className="text-[14.5px] leading-snug text-pretty">
                        {p.designation}
                      </span>
                      {p.categorie && (
                        <span className="text-[11px] text-ink-faint truncate">{p.categorie}</span>
                      )}
                      <JaugeStock
                        stock={Number(p.stock)}
                        seuil={Number(p.seuil_alerte)}
                        unite={p.unite}
                        avecChiffre={false}
                      />
                    </span>
                    <span className="shrink-0 flex flex-col items-end gap-1">
                      <span
                        className={`font-display font-semibold text-[21px] leading-none tabular-nums ${
                          p.stock <= 0
                            ? "text-red"
                            : p.sous_seuil
                              ? "text-amber"
                              : "text-ink"
                        }`}
                      >
                        {p.stock}
                      </span>
                      <EtatStock stock={Number(p.stock)} seuil={Number(p.seuil_alerte)} />
                    </span>
                  </span>
                </Link>
              </li>
            ))}
          </ul>
        )}
      </div>
    </main>
  );
}
