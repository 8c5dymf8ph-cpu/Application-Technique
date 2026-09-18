import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, peutValider } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { EtatStock, JaugeStock, VignetteProduit } from "@/app/composants/produit";
import { enregistrerFichier } from "@/lib/stockage";

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
  quantite_reappro: number | null;
  photo_principale: string | null;
  stock: number;
  valeur_stock: number | null;
  sous_seuil: boolean;
  total_entrees: number;
  total_sorties: number;
  total_ajustements: number;
  dernier_mouvement: string | null;
};

type Mouvement = {
  id: string;
  type: string;
  motif: string | null;
  quantite: number;
  date_mouvement: string;
  qui: string | null;
  emplacement: string | null;
  anomalie: string | null;
  commentaire: string | null;
};

const MOTIFS = [
  { v: "casse", l: "Casse" },
  { v: "perte", l: "Perte" },
  { v: "erreur_saisie", l: "Erreur de saisie" },
  { v: "autre", l: "Autre" },
] as const;

export default async function FicheProduit({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { id } = await params;

  const [p] = await sql<Produit[]>`
    select id, code, designation, categorie, categorie_lieu, unite, prix_unitaire,
           prix_inconnu, seuil_alerte, quantite_reappro, photo_principale,
           stock, valeur_stock, sous_seuil, total_entrees, total_sorties,
           total_ajustements, dernier_mouvement
    from v_stock_produits where id = ${id}`;
  if (!p) notFound();

  const photos = await sql<{ id: string; chemin: string; principale: boolean }[]>`
    select id, chemin, principale from photos_produit
    where produit_id = ${id} order by principale desc, ordre, ajoutee_le`;

  const mouvements = await sql<Mouvement[]>`
    select m.id, m.type::text, m.motif::text, m.quantite, m.date_mouvement,
           coalesce(u.nom, pr.nom)          as qui,
           e.code                            as emplacement,
           a.description                     as anomalie,
           m.commentaire
    from mouvements_stock m
    left join utilisateurs u   on u.id = m.utilisateur_id
    left join prestataires pr  on pr.id = m.prestataire_id
    left join emplacements e   on e.id = m.emplacement_id
    left join interventions i  on i.id = m.intervention_id
    left join anomalies a      on a.id = i.anomalie_id
    where m.produit_id = ${id}
    order by m.date_mouvement desc, m.id
    limit 40`;

  async function entrer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");
    const quantite = Number(donnees.get("quantite") ?? 0);
    if (!(quantite > 0)) return;
    const prix = donnees.get("prix") ? Number(donnees.get("prix")) : null;
    await sql`
      insert into mouvements_stock (produit_id, type, quantite, utilisateur_id,
                                    prix_unitaire, commentaire)
      values (${id}, 'entree', ${quantite}, ${profil_.id}, ${prix},
              ${String(donnees.get("commentaire") ?? "").trim() || null})`;
    revalidatePath(`/stock/produit/${id}`);
  }

  async function ajuster(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");
    const ecart = Number(donnees.get("ecart") ?? 0);
    if (!ecart) return;
    // Un ajustement dit toujours pourquoi : c'est la règle, et c'est ce qui
    // rend l'historique relisible six mois plus tard.
    await sql`
      insert into mouvements_stock (produit_id, type, quantite, motif, utilisateur_id,
                                    commentaire)
      values (${id}, 'regularisation', ${ecart},
              ${String(donnees.get("motif"))}::motif_regularisation, ${profil_.id},
              ${String(donnees.get("commentaire") ?? "").trim() || null})`;
    revalidatePath(`/stock/produit/${id}`);
  }

  async function ajouterPhotos(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");
    const [{ n }] = await sql<{ n: number }[]>`
      select count(*)::int as n from photos_produit where produit_id = ${id}`;
    let rang = n;
    for (const fichier of donnees.getAll("photos")) {
      if (!(fichier instanceof File) || fichier.size === 0) continue;
      const chemin = await enregistrerFichier(fichier);
      if (!chemin) continue;
      await sql`
        insert into photos_produit (produit_id, chemin, principale, ordre, ajoutee_par)
        values (${id}, ${chemin}, ${rang === 0}, ${rang}, ${profil_.id})`;
      rang += 1;
    }
    revalidatePath(`/stock/produit/${id}`);
  }

  async function mettreEnAvant(donnees: FormData) {
    "use server";
    const photo = String(donnees.get("photo"));
    await sql`update photos_produit set principale = false where produit_id = ${id}`;
    await sql`update photos_produit set principale = true where id = ${photo}`;
    revalidatePath(`/stock/produit/${id}`);
  }

  async function retirerPhoto(donnees: FormData) {
    "use server";
    await sql`delete from photos_produit where id = ${String(donnees.get("photo"))}`;
    // S'il reste des photos, la première reprend la place.
    await sql`
      update photos_produit set principale = true
       where id = (select id from photos_produit where produit_id = ${id}
                   order by ordre, ajoutee_le limit 1)
         and not exists (select 1 from photos_produit
                          where produit_id = ${id} and principale)`;
    revalidatePath(`/stock/produit/${id}`);
  }

  async function reglages(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect(`/stock/produit/${id}` as Route);
    await sql`
      update produits
         set designation      = ${String(donnees.get("designation") ?? "").trim()},
             prix_unitaire    = ${donnees.get("prix") ? Number(donnees.get("prix")) : null},
             seuil_alerte     = ${Number(donnees.get("seuil") ?? 0)},
             quantite_reappro = ${
               donnees.get("reappro") ? Number(donnees.get("reappro")) : null
             }
       where id = ${id}`;
    revalidatePath(`/stock/produit/${id}`);
  }

  const LIBELLE_MOUVEMENT: Record<string, string> = {
    entree: "Entrée",
    sortie: "Sortie",
    regularisation: "Ajustement",
  };

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre={p.designation} sous_titre={p.code} retour="/stock" />

      <div className="px-5 py-4 flex flex-col gap-5">
        {/* L'état, d'un coup d'œil */}
        <section className="carte px-4 py-4 flex flex-col gap-3">
          <div className="flex items-center gap-3">
            <VignetteProduit photo={p.photo_principale} taille={68} />
            <div className="grow min-w-0 flex flex-col gap-1.5">
              <span className="flex items-center gap-2 flex-wrap">
                <EtatStock stock={Number(p.stock)} seuil={Number(p.seuil_alerte)} />
                {p.categorie_lieu && (
                  <span className="text-[11.5px] text-ink-faint">{p.categorie_lieu}</span>
                )}
              </span>
              <JaugeStock
                stock={Number(p.stock)}
                seuil={Number(p.seuil_alerte)}
                unite={p.unite}
                hauteur={10}
              />
              <span className="text-[11.5px] text-ink-faint">
                seuil {p.seuil_alerte}
                {p.prix_inconnu
                  ? " · prix inconnu"
                  : ` · ${euros(p.prix_unitaire)} l’unité · ${euros(p.valeur_stock)} en stock`}
              </span>
            </div>
          </div>

          {/* Le stock n'est pas un chiffre posé : c'est la somme de ces trois. */}
          <div className="grid grid-cols-4 gap-2">
            {[
              { n: Number(p.total_entrees), l: "Entrées", t: "text-green" },
              { n: -Number(p.total_sorties), l: "Sorties", t: "text-red" },
              { n: Number(p.total_ajustements), l: "Ajustements", t: "text-ink-soft" },
              { n: Number(p.stock), l: "En stock", t: "text-ink", brut: true },
            ].map((x) => ({
              ...x,
              // Un zéro n'a pas de signe : « −0 » se lit comme une erreur.
              v: x.brut || x.n === 0 ? String(x.n) : `${x.n > 0 ? "+" : "−"}${Math.abs(x.n)}`,
            })).map((s) => (
              <div key={s.l} className="rounded-[11px] bg-surface-muted px-1 py-2 text-center">
                <div
                  className={`font-display font-semibold text-[17px] leading-none tabular-nums ${s.t}`}
                >
                  {s.v}
                </div>
                <div className="etiquette mt-1 text-[8px]">{s.l}</div>
              </div>
            ))}
          </div>
          <p className="text-[11px] text-ink-faint text-pretty leading-snug">
            Le stock n’est pas un chiffre qu’on met à jour : c’est la somme des entrées, des
            sorties et des ajustements. Il n’y a rien à recalculer.
          </p>
        </section>

        {/* Entrer du stock */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Entrée de stock</h2>
          <form action={entrer} className="carte px-3.5 py-3 flex flex-col gap-2.5">
            <div className="flex gap-2">
              <label className="flex-1 min-w-0 flex flex-col gap-1">
                <span className="etiquette">Quantité reçue</span>
                <input
                  name="quantite"
                  type="number"
                  step="0.01"
                  min={0}
                  inputMode="decimal"
                  className="w-full h-[48px] px-3 rounded-[11px] border border-line bg-surface text-[17px] tabular-nums"
                />
              </label>
              <label className="flex-1 min-w-0 flex flex-col gap-1">
                <span className="etiquette">Prix payé (unité)</span>
                <input
                  name="prix"
                  type="number"
                  step="0.01"
                  min={0}
                  inputMode="decimal"
                  placeholder={p.prix_unitaire ? String(p.prix_unitaire) : "—"}
                  className="w-full h-[48px] px-3 rounded-[11px] border border-line bg-surface text-[17px] tabular-nums placeholder:text-ink-faint"
                />
              </label>
            </div>
            <input
              name="commentaire"
              autoComplete="off"
              placeholder="D’où vient-elle ? (facultatif)"
              className="w-full h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[15px] placeholder:text-ink-faint"
            />
            <button className="h-[48px] rounded-[12px] bg-green text-white font-display font-semibold text-[15px]">
              Enregistrer l’entrée
            </button>
          </form>
        </section>

        {/* Ajuster */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Ajustement</h2>
          <form action={ajuster} className="carte px-3.5 py-3 flex flex-col gap-2.5">
            <label className="flex flex-col gap-1">
              <span className="etiquette">Écart — négatif s’il en manque</span>
              <input
                name="ecart"
                type="number"
                step="0.01"
                inputMode="decimal"
                placeholder="−1"
                className="w-full h-[48px] px-3 rounded-[11px] border border-line bg-surface text-[17px] tabular-nums placeholder:text-ink-faint"
              />
            </label>
            <fieldset className="flex flex-col gap-1.5">
              <legend className="etiquette mb-1.5">Pourquoi&nbsp;?</legend>
              <div className="grid grid-cols-2 gap-2">
                {MOTIFS.map((m) => (
                  <label
                    key={m.v}
                    className="rounded-[11px] border border-line bg-surface h-[44px] grid place-items-center text-[13px] cursor-pointer has-[:checked]:border-plum has-[:checked]:bg-plum-soft"
                  >
                    <input type="radio" name="motif" value={m.v}
                           defaultChecked={m.v === "casse"} className="sr-only" />
                    {m.l}
                  </label>
                ))}
              </div>
            </fieldset>
            <input
              name="commentaire"
              autoComplete="off"
              placeholder="Ce qu’il faut savoir (facultatif)"
              className="w-full h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[15px] placeholder:text-ink-faint"
            />
            <button className="h-[48px] rounded-[12px] bg-surface-muted border border-line font-display font-semibold text-[15px]">
              Enregistrer l’ajustement
            </button>
            <p className="text-[11px] text-ink-faint text-pretty leading-snug">
              Un comptage complet se fait depuis l’inventaire. Ici, c’est la correction au fil de
              l’eau — une casse, une erreur — et elle laisse une trace.
            </p>
          </form>
        </section>

        {/* Les photos, ajoutées par vous */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Photos</h2>
          {photos.length > 0 && (
            <ul className="flex flex-wrap gap-2">
              {photos.map((ph) => (
                <li key={ph.id} className="flex flex-col gap-1">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={`/photo/${ph.chemin}`}
                    alt=""
                    className={`w-[84px] h-[84px] object-cover rounded-[11px] border-2 ${
                      ph.principale ? "border-plum" : "border-line"
                    }`}
                  />
                  <span className="flex gap-1">
                    {!ph.principale && (
                      <form action={mettreEnAvant} className="grow">
                        <input type="hidden" name="photo" value={ph.id} />
                        <button className="w-full h-[30px] rounded-[8px] bg-plum-soft text-plum text-[10.5px] min-h-0">
                          En avant
                        </button>
                      </form>
                    )}
                    <form action={retirerPhoto} className={ph.principale ? "grow" : ""}>
                      <input type="hidden" name="photo" value={ph.id} />
                      <button className="w-full h-[30px] px-2 rounded-[8px] bg-surface border border-line text-ink-faint text-[10.5px] min-h-0">
                        Retirer
                      </button>
                    </form>
                  </span>
                </li>
              ))}
            </ul>
          )}
          <form action={ajouterPhotos} className="carte px-3.5 py-3 flex flex-col gap-2">
            <label data-cible className="flex flex-col gap-1 cursor-pointer">
              <span className="etiquette">
                {photos.length === 0 ? "Ajouter une ou plusieurs photos" : "En ajouter d’autres"}
              </span>
              <input
                type="file"
                name="photos"
                multiple
                accept="image/*"
                capture="environment"
                className="text-[13px] file:mr-3 file:h-[38px] file:px-3 file:rounded-[10px] file:border file:border-line file:bg-surface-muted file:text-[13px]"
              />
            </label>
            <button className="h-[44px] rounded-[12px] bg-surface-muted border border-line text-[14px]">
              Enregistrer les photos
            </button>
            <p className="text-[11px] text-ink-faint text-pretty leading-snug">
              La photo mise en avant est celle que le technicien voit quand il choisit son
              matériel. C’est souvent elle qui lui évite de se tromper d’article.
            </p>
          </form>
        </section>

        {/* Les réglages */}
        {peutValider(profil.role) && (
          <section className="flex flex-col gap-2">
            <h2 className="etiquette">Réglages</h2>
            <form action={reglages} className="carte px-3.5 py-3 flex flex-col gap-2.5">
              <label className="flex flex-col gap-1">
                <span className="etiquette">Désignation</span>
                <input
                  name="designation"
                  defaultValue={p.designation}
                  className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
                />
              </label>
              <div className="flex gap-2">
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Prix unitaire</span>
                  <input
                    name="prix"
                    type="number"
                    step="0.01"
                    min={0}
                    inputMode="decimal"
                    defaultValue={p.prix_unitaire ?? ""}
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
                  />
                </label>
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Seuil d’alerte</span>
                  <input
                    name="seuil"
                    type="number"
                    step="0.01"
                    min={0}
                    inputMode="decimal"
                    defaultValue={p.seuil_alerte}
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
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
                  defaultValue={p.quantite_reappro ?? ""}
                  className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
                />
              </label>
              <button className="h-[46px] rounded-[12px] bg-plum text-white font-display font-semibold text-[14.5px]">
                Enregistrer
              </button>
            </form>
          </section>
        )}

        {/* L'historique */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Derniers mouvements</h2>
          {mouvements.length === 0 ? (
            <p className="text-[13px] text-ink-faint">Aucun mouvement enregistré.</p>
          ) : (
            <ul className="carte divide-y divide-line">
              {mouvements.map((m) => {
                const entree = Number(m.quantite) > 0;
                return (
                  <li key={m.id} className="px-3.5 py-2.5 flex items-center gap-3">
                    <span
                      aria-hidden
                      className={`w-8 h-8 shrink-0 rounded-full grid place-items-center ${
                        m.type === "regularisation"
                          ? "bg-surface-muted"
                          : entree
                            ? "bg-green-soft"
                            : "bg-red-soft"
                      }`}
                    >
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
                           stroke={
                             m.type === "regularisation"
                               ? "#4F4B6B"
                               : entree
                                 ? "#357051"
                                 : "#9E3538"
                           }
                           strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                        {m.type === "regularisation" ? (
                          <><path d="M4 12h16" /><path d="M12 4v16" /></>
                        ) : entree ? (
                          <><path d="M12 19V5" /><path d="M5 12l7-7 7 7" /></>
                        ) : (
                          <><path d="M12 5v14" /><path d="M5 12l7 7 7-7" /></>
                        )}
                      </svg>
                    </span>
                    <span className="grow min-w-0">
                      <span className="block text-[13.5px] leading-snug text-pretty">
                        {LIBELLE_MOUVEMENT[m.type]}
                        {m.motif && ` · ${m.motif.replace("_", " ")}`}
                        {m.emplacement && ` · ${m.emplacement}`}
                        {m.qui && ` · ${m.qui}`}
                      </span>
                      <span className="block text-[11px] text-ink-faint">
                        {new Date(m.date_mouvement).toLocaleDateString("fr-FR")}
                        {m.anomalie && ` · ${m.anomalie}`}
                        {m.commentaire && ` · ${m.commentaire}`}
                      </span>
                    </span>
                    <span
                      className={`shrink-0 font-display font-semibold text-[15px] tabular-nums ${
                        m.type === "regularisation"
                          ? "text-ink-soft"
                          : entree
                            ? "text-green"
                            : "text-red"
                      }`}
                    >
                      {entree ? "+" : "−"}
                      {Math.abs(Number(m.quantite))}
                    </span>
                  </li>
                );
              })}
            </ul>
          )}
        </section>

        <Link
          href={"/stock" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Tout le stock
        </Link>
      </div>
    </main>
  );
}
