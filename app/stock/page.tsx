import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, peutValider } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";
import { Filtres, Recherche, Stat } from "@/app/composants/suivi";
import { Depliant } from "@/app/composants/depliant";
import { EtatStock, JaugeStock, VignetteProduit } from "@/app/composants/produit";
import { QuitterSiRevenu } from "@/app/composants/quitter-si-revenu";

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
  searchParams: Promise<{ q?: string; lieu?: string; metier?: string; etat?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { q = "", lieu = "tous", metier = "tous", etat = "tous" } = await searchParams;
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
  // Deux orthographes de la même chose sont la même chose. La reprise a laissé
  // « Salle de Bain » et « Salle de bain » : deux pastilles côte à côte pour un
  // seul rayon, et un produit sur quatre invisible dans celle qu'on choisit. On
  // regroupe sans casse, et on affiche l'écriture la plus fréquente.
  const familles = await sql<{ cle: string; lieu: string; nombre: number }[]>`
    select lower(coalesce(categorie_lieu, 'Sans catégorie')) as cle,
           (array_agg(coalesce(categorie_lieu, 'Sans catégorie')
                      order by n desc))[1]                   as lieu,
           sum(n)::int                                       as nombre
      from (select categorie_lieu, count(*)::int as n
              from v_stock_produits group by 1) t
     group by 1 order by 3 desc, 2`;

  // Le métier : l'autre colonne de la liste de Miguel. Électricité, plomberie,
  // serrurerie — on cherche « le mousseur » par le rayon, « un télérupteur »
  // par le métier. Les deux filtres se croisent.
  const metiers_filtre = await sql<{ cle: string; metier: string; nombre: number }[]>`
    select lower(coalesce(categorie, 'Sans métier')) as cle,
           (array_agg(coalesce(categorie, 'Sans métier') order by n desc))[1] as metier,
           sum(n)::int                                                        as nombre
      from (select categorie, count(*)::int as n
              from v_stock_produits group by 1) t
     group by 1 order by 3 desc, 2`;

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
    -- Trois filtres qui se croisent, chacun sur son axe : l'état, le rayon, le
    -- métier. « Tous » ne filtre rien.
    where (${etat} <> 'retires' or not actif)
      and (${etat} = 'tous'
        or ${etat} = 'retires'
        or (${etat} = 'alertes' and sous_seuil and actif)
        or (${etat} = 'rupture' and stock <= 0 and actif))
      and (${lieu} = 'tous'
        or lower(coalesce(categorie_lieu, 'Sans catégorie')) = ${lieu})
      and (${metier} = 'tous'
        or lower(coalesce(categorie, 'Sans métier')) = ${metier})
      and (${terme} = ''
        or lower(designation) like ${"%" + terme + "%"}
        or lower(code) like ${"%" + terme + "%"}
        or lower(coalesce(categorie, '')) like ${"%" + terme + "%"})
    -- Par ordre alphabétique. Mettre les alertes en tête paraissait utile, mais
    -- on cherche un produit par son nom : la place d'un article changeait selon
    -- son stock du jour, et on ne savait plus où le prendre. Les compteurs du
    -- haut et le filtre « sous le seuil » disent l'urgence, la liste dit où
    -- trouver. Les retirés restent en bas.
    --
    -- L'ordre est posé ici, pas laissé à la collation : selon l'installation,
    -- « BOUILLOIRE » passe avant ou après « Batteries », et « Économiseur »
    -- se retrouve après « Z ». On range donc sur une clé sans casse ni accent,
    -- qui donne le même ordre partout.
    order by actif desc, lower(translate(
      designation,
      'ÀÁÂÃÄÅàáâãäåÇçÈÉÊËèéêëÌÍÎÏìíîïÑñÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÝýÿ',
      'AAAAAAaaaaaaCcEEEEeeeeIIIIiiiiNnOOOOOOooooooUUUUuuuuYyy'))`;

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

  // Chaque pastille change UN axe et garde les autres : on affine, on ne
  // recommence pas.
  const lien = (axe: "etat" | "lieu" | "metier", valeur: string) =>
    `/stock?${new URLSearchParams({
      etat,
      lieu,
      metier,
      ...(q ? { q } : {}),
      [axe]: valeur,
    })}` as Route;

  const nomLieu = familles.find((f) => f.cle === lieu)?.lieu;
  const nomMetier = metiers_filtre.find((m) => m.cle === metier)?.metier;
  const affines = [nomLieu, nomMetier].filter(Boolean) as string[];
  // Enlever les DEUX axes d'un coup : n'en relâcher qu'un peut laisser la liste
  // vide, et on appuie une seconde fois sans comprendre.
  const sansAffinage = `/stock?${new URLSearchParams({
    etat,
    lieu: "tous",
    metier: "tous",
    ...(q ? { q } : {}),
  })}` as Route;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <QuitterSiRevenu cle="produit" vers="/stock" />
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

        {/* L'inventaire du matériel, et rien d'autre. « Commandes » menait aux
            commandes de BOUTEILLES : elles ont leur écran, sous Bouteilles.
            Un raccourci vers une autre section depuis une liste de produits
            techniques ne s'explique pas, il se subit. */}
        <Link
          href={"/stock/inventaire" as Route}
          className="h-[46px] rounded-card bg-plum-soft text-plum text-[14px] grid place-items-center font-medium"
        >
          Inventaire
        </Link>

        <Recherche
          valeur={q}
          placeholder="Chercher un produit…"
          caches={{ etat, lieu, metier }}
        />

        {/* L'état de l'article : ce qu'on regarde le plus souvent, donc visible
            sans rien ouvrir. */}
        <Filtres
          actif={etat}
          lien={(v) => lien("etat", v)}
          choix={[
            { valeur: "tous", libelle: "Tous", nombre: c.produits },
            { valeur: "alertes", libelle: "Sous le seuil", nombre: c.alertes },
            { valeur: "rupture", libelle: "À zéro", nombre: c.rupture },
            ...(retires > 0
              ? [{ valeur: "retires", libelle: "Retirés", nombre: retires }]
              : []),
          ]}
        />

        {/* Les deux colonnes de la liste de Miguel : le rayon et le métier.
            Elles se croisent — « plomberie » dans « salle de bain » — et se
            replient, parce qu'on ne s'en sert pas à chaque visite. */}
        <Depliant
          titre="Rayon et métier"
          aide={affines.length === 0 ? "Croiser les deux colonnes de la liste" : undefined}
          ouvert={affines.length > 0}
          indice={
            affines.length > 0 ? (
              <span className="text-plum">{affines.join(" · ")}</span>
            ) : (
              "tout"
            )
          }
        >
          <div className="flex flex-col gap-1">
            <span className="etiquette">Rayon</span>
            <Filtres
              actif={lieu}
              lien={(v) => lien("lieu", v)}
              choix={[
                { valeur: "tous", libelle: "Tous", nombre: c.produits },
                ...familles.map((f) => ({
                  valeur: f.cle,
                  libelle: f.lieu,
                  nombre: f.nombre,
                })),
              ]}
            />
          </div>

          <div className="flex flex-col gap-1">
            <span className="etiquette">Métier</span>
            <Filtres
              actif={metier}
              lien={(v) => lien("metier", v)}
              choix={[
                { valeur: "tous", libelle: "Tous", nombre: c.produits },
                ...metiers_filtre.map((m) => ({
                  valeur: m.cle,
                  libelle: m.metier,
                  nombre: m.nombre,
                })),
              ]}
            />
          </div>
        </Depliant>

        {administre && (
          <Depliant titre="Ajouter un produit">
            <form action={creer} className="flex flex-col gap-2.5">
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
          </Depliant>
        )}

        {produits.length === 0 ? (
          <Vide>
            {/* Trois filtres qui se croisent peuvent se vider l'un l'autre :
                la plomberie n'est rangée qu'en salle de bain. Une liste vide
                doit dire CE QUI la vide, sinon on croit avoir perdu des
                produits. */}
            {terme ? (
              `Aucun produit ne correspond à « ${q} ».`
            ) : affines.length > 0 ? (
              <>
                Aucun produit en {affines.join(" et ")}.{" "}
                <Link href={sansAffinage} className="underline underline-offset-4">
                  {affines.length > 1 ? "Enlever les deux filtres" : "Enlever le filtre"}
                </Link>
              </>
            ) : (
              "Aucun produit ici."
            )}
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
