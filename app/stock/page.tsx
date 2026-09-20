import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, peutValider } from "@/lib/domaine";
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
  actif: boolean;
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
  const administre = peutValider(profil.role);
  const terme = q.trim().toLowerCase();

  const [c] = await sql<
    { alertes: number; produits: number; valeur: number; sans_prix: number; rupture: number }[]
  >`
    -- Les alertes ne portent que sur ce qu'on rachète encore : un produit
    -- retiré est à zéro pour de bon, ce n'est pas une rupture. Sa valeur en
    -- stock, elle, compte toujours — les pièces sont là, sur l'étagère.
    select
      count(*) filter (where sous_seuil and actif)::int as alertes,
      count(*)::int                                     as produits,
      coalesce(sum(valeur_stock), 0)                    as valeur,
      count(*) filter (where prix_inconnu and actif)::int as sans_prix,
      count(*) filter (where stock <= 0 and actif)::int   as rupture
    from v_stock_produits`;

  // Les familles de lieu viennent des données, pas d'une liste écrite en dur :
  // le référentiel peut changer sans qu'on retouche l'écran.
  const familles = await sql<{ lieu: string; nombre: number }[]>`
    select coalesce(categorie_lieu, 'Sans catégorie') as lieu, count(*)::int as nombre
    from v_stock_produits
    group by 1 order by 2 desc, 1`;

  // Les produits qu'on ne rachète plus ne disparaissent pas : ils sortent du
  // choix du technicien et se retrouvent ici, dans leur propre filtre. Leur
  // stock et leurs mouvements sont intacts.
  const [{ retires }] = await sql<{ retires: number }[]>`
    select count(*)::int as retires from v_stock_produits where not actif`;

  // Un produit retiré reste DANS la liste, dit « retiré », et passe en bas.
  // Le sortir de la vue le faisait disparaître : on le cherchait en croyant
  // l'avoir perdu. Ce qu'il ne fait plus, c'est se proposer au technicien et
  // compter dans les alertes.
  const produits = await sql<Produit[]>`
    select id, code, designation, categorie, categorie_lieu, unite,
           prix_unitaire, prix_inconnu, seuil_alerte, photo_principale,
           stock, valeur_stock, sous_seuil, actif, dernier_mouvement
    from v_stock_produits
    where (${lieu} <> 'retires' or not actif)
      and (${lieu} = 'tous'
        or ${lieu} = 'retires'
        or (${lieu} = 'alertes' and sous_seuil and actif)
        or coalesce(categorie_lieu, 'Sans catégorie') = ${lieu})
      and (${terme} = ''
        or lower(designation) like ${"%" + terme + "%"}
        or lower(code) like ${"%" + terme + "%"}
        or lower(coalesce(categorie, '')) like ${"%" + terme + "%"})
    order by actif desc, sous_seuil desc, designation`;

  // Les familles déjà employées, pour ne pas réinventer une catégorie à chaque
  // produit créé : le référentiel se construit par l'usage, pas par un écran.
  const metiers = await sql<{ valeur: string }[]>`
    select distinct categorie as valeur from produits
    where categorie is not null order by 1`;

  async function creer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/stock" as Route);

    const designation = String(donnees.get("designation") ?? "").trim();
    if (!designation) return;

    // Le code identifie l'article chez nous. Laissé vide, il se déduit de la
    // désignation — et un suffixe évite la collision plutôt que de rejeter.
    const saisi = String(donnees.get("code") ?? "").trim().toUpperCase();
    const base =
      saisi ||
      designation
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .toUpperCase()
        .replace(/[^A-Z0-9]+/g, "-")
        .replace(/^-|-$/g, "")
        .slice(0, 14) ||
      "ARTICLE";

    const [libre] = await sql<{ code: string }[]>`
      select case when not exists (select 1 from produits where code = ${base})
                  then ${base}
                  else ${base} || '-' || (
                    select count(*) + 1 from produits where code like ${base + "%"})
             end as code`;

    const [cree] = await sql<{ id: string }[]>`
      insert into produits (code, designation, categorie, categorie_lieu, unite,
                            prix_unitaire, seuil_alerte, quantite_reappro)
      values (${libre.code}, ${designation},
              ${String(donnees.get("categorie") ?? "").trim() || null},
              ${String(donnees.get("categorie_lieu") ?? "").trim() || null},
              ${String(donnees.get("unite") ?? "").trim() || "unité"},
              ${donnees.get("prix") ? Number(donnees.get("prix")) : null},
              ${Number(donnees.get("seuil") ?? 0)},
              ${donnees.get("reappro") ? Number(donnees.get("reappro")) : null})
      returning id`;

    // On arrive sur sa fiche : c'est là qu'on met la photo, le fournisseur et
    // la première entrée de stock.
    redirect(`/stock/produit/${cree.id}?neuf=1` as Route);
  }

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

        <div className="flex gap-2">
          <Link
            href={"/stock/inventaire" as Route}
            className="flex-1 h-[46px] rounded-card bg-plum-soft text-plum text-[14px] grid place-items-center font-medium"
          >
            Inventaire
          </Link>
          <Link
            href={"/bouteilles/commandes" as Route}
            className="flex-1 h-[46px] rounded-card bg-surface border border-line text-[14px] grid place-items-center"
          >
            Commandes
          </Link>
        </div>

        <Recherche valeur={q} placeholder="Chercher un produit…" caches={{ lieu }} />

        <Filtres
          actif={lieu}
          lien={lien}
          choix={[
            { valeur: "tous", libelle: "Tous", nombre: c.produits },
            { valeur: "alertes", libelle: "Sous le seuil", nombre: c.alertes },
            ...familles.map((f) => ({ valeur: f.lieu, libelle: f.lieu, nombre: f.nombre })),
            ...(retires > 0
              ? [{ valeur: "retires", libelle: "Retirés", nombre: retires }]
              : []),
          ]}
        />

        {administre && (
          <details className="carte px-4 py-3">
            <summary
              data-cible
              className="flex items-center gap-2 cursor-pointer list-none text-[14.5px]"
            >
              <span className="w-7 h-7 rounded-full bg-plum-soft grid place-items-center shrink-0">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#453A6E"
                     strokeWidth="2.2" strokeLinecap="round">
                  <path d="M6 12h12" /><path d="M12 6v12" />
                </svg>
              </span>
              Ajouter un produit
            </summary>

            <form action={creer} className="flex flex-col gap-2.5 pt-3">
              <label className="flex flex-col gap-1">
                <span className="etiquette">Désignation</span>
                <input
                  name="designation"
                  required
                  autoComplete="off"
                  placeholder="Ce qu’on dit en le demandant"
                  className="w-full h-[48px] px-3 rounded-[11px] border border-line bg-surface text-[16px] placeholder:text-ink-faint"
                />
              </label>

              <div className="flex gap-2">
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Métier</span>
                  <input
                    name="categorie"
                    list="metiers"
                    autoComplete="off"
                    placeholder="Électricité…"
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px] placeholder:text-ink-faint"
                  />
                  <datalist id="metiers">
                    {metiers.map((m) => (
                      <option key={m.valeur} value={m.valeur} />
                    ))}
                  </datalist>
                </label>
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Où il sert</span>
                  <input
                    name="categorie_lieu"
                    list="lieux"
                    autoComplete="off"
                    placeholder="Chambre…"
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px] placeholder:text-ink-faint"
                  />
                  <datalist id="lieux">
                    {familles.map((f) => (
                      <option key={f.lieu} value={f.lieu} />
                    ))}
                  </datalist>
                </label>
              </div>

              <div className="flex gap-2">
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Seuil d’alerte</span>
                  <input
                    name="seuil"
                    type="number"
                    step="0.01"
                    min={0}
                    inputMode="decimal"
                    defaultValue={0}
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
                  />
                </label>
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Prix unitaire</span>
                  <input
                    name="prix"
                    type="number"
                    step="0.01"
                    min={0}
                    inputMode="decimal"
                    placeholder="—"
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums placeholder:text-ink-faint"
                  />
                </label>
              </div>

              <details className="rounded-[11px] bg-surface-muted px-3 py-2">
                <summary className="text-[12.5px] text-plum cursor-pointer list-none underline underline-offset-4">
                  Code, unité, quantité à recommander
                </summary>
                <div className="flex flex-col gap-2 pt-2">
                  <div className="flex gap-2">
                    <label className="flex-1 min-w-0 flex flex-col gap-1">
                      <span className="etiquette">Code</span>
                      <input
                        name="code"
                        autoComplete="off"
                        placeholder="déduit du nom"
                        className="w-full h-[44px] px-3 rounded-[10px] border border-line bg-surface text-[15px] placeholder:text-ink-faint"
                      />
                    </label>
                    <label className="flex-1 min-w-0 flex flex-col gap-1">
                      <span className="etiquette">Unité</span>
                      <input
                        name="unite"
                        autoComplete="off"
                        placeholder="unité"
                        className="w-full h-[44px] px-3 rounded-[10px] border border-line bg-surface text-[15px] placeholder:text-ink-faint"
                      />
                    </label>
                  </div>
                  <label className="flex flex-col gap-1">
                    <span className="etiquette">Quantité à recommander</span>
                    <input
                      name="reappro"
                      type="number"
                      step="0.01"
                      min={0}
                      inputMode="decimal"
                      placeholder="—"
                      className="w-full h-[44px] px-3 rounded-[10px] border border-line bg-surface text-[15px] tabular-nums placeholder:text-ink-faint"
                    />
                  </label>
                </div>
              </details>

              <button className="h-[50px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15px]">
                Créer le produit
              </button>
              <p className="text-[11px] text-ink-faint text-pretty leading-snug">
                La photo, le fournisseur et la première entrée de stock se règlent ensuite sur
                sa fiche — on y arrive directement.
              </p>
            </form>
          </details>
        )}

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
                      !p.actif
                        ? "bg-line"
                        : p.stock <= 0
                          ? "bg-red"
                          : p.sous_seuil
                            ? "bg-amber"
                            : "bg-green"
                    }`}
                  />
                  <span className="grow min-w-0 px-3 py-3 flex items-center gap-3">
                    <VignetteProduit photo={p.photo_principale} taille={52} />
                    <span className="grow min-w-0 flex flex-col gap-1.5">
                      <span className="text-[14.5px] leading-snug text-pretty">
                        {p.designation}
                        {!p.actif && (
                          <span className="ml-1.5 align-middle px-1.5 py-0.5 rounded-md bg-surface-muted border border-line text-[10.5px] uppercase tracking-[0.06em] text-ink-faint whitespace-nowrap">
                            retiré
                          </span>
                        )}
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
