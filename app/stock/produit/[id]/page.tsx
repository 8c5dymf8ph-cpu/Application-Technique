import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { colonneExiste } from "@/lib/schema";
import { profilActif } from "@/lib/profil";
import { euros, peutValider } from "@/lib/domaine";
import { Entete , Confirmation } from "@/app/composants/ui";
import { ChampPhotos } from "@/app/composants/photos";
import { EtatStock, JaugeStock, VignetteProduit } from "@/app/composants/produit";
import { enregistrerFichier, supprimerFichier } from "@/lib/stockage";

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
  actif: boolean;
  photo_principale: string | null;
  stock: number;
  valeur_stock: number | null;
  sous_seuil: boolean;
  total_entrees: number;
  total_sorties: number;
  total_ajustements: number;
  dernier_mouvement: string | null;
};

type Fournisseur = {
  lien_id: string;
  fournisseur_id: string;
  nom: string;
  email: string | null;
  contact: string | null;
  telephone: string | null;
  reference_fournisseur: string | null;
  prefere: boolean;
};

type Achat = {
  mouvement_id: string;
  date_mouvement: string;
  quantite: number;
  prix_unitaire: number;
  fournisseur: string | null;
  facture_fichier: string | null;
  facture: string | null;
  prix_precedent: number | null;
};

type Prix = {
  prix_reference: number | null;
  dernier_prix: number | null;
  dernier_achat: string | null;
  dernier_fournisseur: string | null;
  variation_pct: number | null;
  ecart_reference_pct: number | null;
  nb_achats: number;
  prix_min: number | null;
  prix_max: number | null;
  prix_moyen: number | null;
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
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ neuf?: string; fait?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { id } = await params;
  const { neuf, fait } = await searchParams;

  const [p] = await sql<Produit[]>`
    select id, code, designation, categorie, categorie_lieu, unite, prix_unitaire,
           prix_inconnu, seuil_alerte, quantite_reappro, actif, photo_principale,
           stock, valeur_stock, sous_seuil, total_entrees, total_sorties,
           total_ajustements, dernier_mouvement
    from v_stock_produits where id = ${id}`;
  if (!p) notFound();

  const photos = await sql<{ id: string; chemin: string; principale: boolean }[]>`
    select id, chemin, principale from photos_produit
    where produit_id = ${id} order by principale desc, ordre, ajoutee_le`;

  // Culligan ne vend que des bouteilles : il n'a rien à faire dans la liste
  // qu'on propose en ouvrant la fiche d'un joint. Tant que la migration 0005
  // n'est pas appliquée, la colonne n'existe pas — et Postgres refuse la
  // requête entière, il ne se contente pas d'ignorer la condition. Deux
  // requêtes, donc, pas une condition.
  const tri = await colonneExiste("fournisseurs", "pour_bouteilles");

  const fournisseurs = await sql<Fournisseur[]>`
    select af.id as lien_id, f.id as fournisseur_id, f.nom, f.email,
           f.contact, f.telephone, af.reference_fournisseur, af.prefere
    from article_fournisseurs af
    join fournisseurs f on f.id = af.fournisseur_id
    where af.produit_id = ${id}
    order by af.prefere desc, f.nom`;

  const tous = tri
    ? await sql<{ id: string; nom: string; email: string | null }[]>`
        select id, nom, email from fournisseurs
         where actif and not pour_bouteilles order by nom`
    : await sql<{ id: string; nom: string; email: string | null }[]>`
        select id, nom, email from fournisseurs where actif order by nom`;

  const [prix] = await sql<Prix[]>`
    select prix_reference, dernier_prix, dernier_achat, dernier_fournisseur,
           variation_pct, ecart_reference_pct, nb_achats, prix_min, prix_max, prix_moyen
    from v_prix_produit where produit_id = ${id}`;

  const achats = await sql<Achat[]>`
    select mouvement_id, date_mouvement, quantite, prix_unitaire, fournisseur,
           facture_fichier, facture, prix_precedent
    from v_achats_produit where produit_id = ${id}
    order by date_mouvement desc, mouvement_id desc limit 12`;

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
    let posees = 0;
    let refusees = 0;
    for (const fichier of donnees.getAll("photos")) {
      if (!(fichier instanceof File) || fichier.size === 0) continue;
      const chemin = await enregistrerFichier(fichier);
      // Une photo refusée disparaissait sans un mot : on croyait l'avoir
      // ajoutée, et la vignette ne changeait pas.
      if (!chemin) {
        refusees += 1;
        continue;
      }
      await sql`
        insert into photos_produit (produit_id, chemin, principale, ordre, ajoutee_par)
        values (${id}, ${chemin}, ${rang === 0}, ${rang}, ${profil_.id})`;
      rang += 1;
      posees += 1;
    }
    // Renavigue plutôt que revalider : le panneau des photos se referme.
    const mot = refusees > 0 ? "photo-refusee" : posees > 1 ? "photos" : "photo";
    redirect(`/stock/produit/${id}?fait=${mot}` as Route);
  }

  async function mettreEnAvant(donnees: FormData) {
    "use server";
    const photo = String(donnees.get("photo"));
    await sql`update photos_produit set principale = false where produit_id = ${id}`;
    await sql`update photos_produit set principale = true where id = ${photo}`;
    // Renavigue plutôt que revalider : le panneau des photos se referme.
    redirect(`/stock/produit/${id}` as Route);
  }

  async function retirerPhoto(donnees: FormData) {
    "use server";
    const photo = String(donnees.get("photo"));
    // On retire le fichier du dépôt aussi : une photo supprimée de l'écran mais
    // gardée en stockage se paierait au gigaoctet.
    const [ligne] = await sql<{ chemin: string }[]>`
      select chemin from photos_produit where id = ${photo}`;
    await sql`delete from photos_produit where id = ${photo}`;
    if (ligne) await supprimerFichier(ligne.chemin);
    // S'il reste des photos, la première reprend la place.
    await sql`
      update photos_produit set principale = true
       where id = (select id from photos_produit where produit_id = ${id}
                   order by ordre, ajoutee_le limit 1)
         and not exists (select 1 from photos_produit
                          where produit_id = ${id} and principale)`;
    // Renavigue plutôt que revalider : le panneau des photos se referme.
    redirect(`/stock/produit/${id}` as Route);
  }

  async function rattacher(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect(`/stock/produit/${id}` as Route);

    const nom = String(donnees.get("nouveau") ?? "").trim();
    const email = String(donnees.get("email") ?? "").trim() || null;
    let fournisseur = String(donnees.get("fournisseur") ?? "");

    // Un fournisseur qui n'existe pas encore se crée ici : on ne quitte pas la
    // fiche du produit pour aller saisir un référentiel.
    if (nom) {
      const [cree] = await sql<{ id: string }[]>`
        insert into fournisseurs (nom, email, contact, telephone)
        values (${nom}, ${email},
                ${String(donnees.get("contact") ?? "").trim() || null},
                ${String(donnees.get("telephone") ?? "").trim() || null})
        on conflict (nom) do update
          set email     = coalesce(excluded.email, fournisseurs.email),
              contact   = coalesce(excluded.contact, fournisseurs.contact),
              telephone = coalesce(excluded.telephone, fournisseurs.telephone)
        returning id`;
      fournisseur = cree.id;
    } else if (fournisseur) {
      // Ce qu'on a saisi corrige la fiche du fournisseur : c'est ici qu'on se
      // rend compte que le contact a changé.
      await sql`
        update fournisseurs
           set email     = coalesce(${email}, email),
               contact   = coalesce(${String(donnees.get("contact") ?? "").trim() || null}, contact),
               telephone = coalesce(${String(donnees.get("telephone") ?? "").trim() || null}, telephone)
         where id = ${fournisseur}`;
    }
    if (!fournisseur) return;

    await sql`
      insert into article_fournisseurs (produit_id, fournisseur_id, reference_fournisseur, prefere)
      values (${id}, ${fournisseur},
              ${String(donnees.get("reference") ?? "").trim() || null},
              not exists (select 1 from article_fournisseurs where produit_id = ${id}))
      on conflict do nothing`;
    revalidatePath(`/stock/produit/${id}`);
  }

  async function corrigerFournisseur(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect(`/stock/produit/${id}` as Route);
    await sql`
      update fournisseurs
         set email     = ${String(donnees.get("email") ?? "").trim() || null},
             contact   = ${String(donnees.get("contact") ?? "").trim() || null},
             telephone = ${String(donnees.get("telephone") ?? "").trim() || null}
       where id = ${String(donnees.get("fournisseur"))}`;
    await sql`
      update article_fournisseurs
         set reference_fournisseur = ${String(donnees.get("reference") ?? "").trim() || null}
       where id = ${String(donnees.get("lien"))}`;
    revalidatePath(`/stock/produit/${id}`);
  }

  async function detacher(donnees: FormData) {
    "use server";
    await sql`delete from article_fournisseurs where id = ${String(donnees.get("lien"))}`;
    revalidatePath(`/stock/produit/${id}`);
  }

  async function prefererFournisseur(donnees: FormData) {
    "use server";
    await sql`update article_fournisseurs set prefere = false where produit_id = ${id}`;
    await sql`update article_fournisseurs set prefere = true where id = ${String(donnees.get("lien"))}`;
    revalidatePath(`/stock/produit/${id}`);
  }

  async function alignerPrix() {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect(`/stock/produit/${id}` as Route);
    // Le prix de référence ne bouge jamais tout seul : c'est une décision, et
    // elle se prend en connaissant la hausse.
    await sql`
      update produits p set prix_unitaire = v.dernier_prix
      from v_prix_produit v
      where v.produit_id = p.id and p.id = ${id} and v.dernier_prix is not null`;
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

  /**
   * Retirer un produit du catalogue sans rien effacer.
   *
   * Un article qu'on ne rachète plus doit disparaître du choix du technicien —
   * sinon il le sélectionne et le stock part en négatif — mais ses mouvements,
   * son prix et les interventions où il a servi restent : le coût des passages
   * passés ne doit pas bouger. `produits.actif` porte exactement cette
   * différence, et `v_stock_produits` la transmet aux écrans.
   */
  async function basculerActif() {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect(`/stock/produit/${id}` as Route);
    await sql`update produits set actif = not actif where id = ${id}`;
    revalidatePath(`/stock/produit/${id}`);
    revalidatePath("/stock");
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
        <Confirmation quoi={fait} />
        {!p.actif && (
          <p className="rounded-card bg-amber-soft px-4 py-3 text-[13px] text-amber text-pretty leading-snug">
            <strong>Produit retiré du catalogue.</strong> Le technicien ne peut plus le
            choisir. Rien n’est effacé : son stock, ses mouvements et les interventions où il
            a servi restent tels quels.
          </p>
        )}
        {neuf && (
          <p className="rounded-card bg-green-soft px-4 py-3 text-[13px] text-green text-pretty leading-snug">
            Produit créé. Il reste à lui mettre une photo — appuyez sur la vignette —, un
            fournisseur, et à enregistrer ce que vous en avez en stock.
          </p>
        )}

        {/* L'état, d'un coup d'œil */}
        <section className="carte px-4 py-4 flex flex-col gap-3">
          <div className="flex items-center gap-3">
            {/* La photo ouvre sa propre galerie : consulter, ajouter, retirer. */}
            <details className="shrink-0 group/photos open:relative open:z-40">
              <summary
                data-cible
                className="list-none cursor-pointer relative z-20 block group-open/photos:ring-4 group-open/photos:ring-plum/30 rounded-[11px]"
                aria-label={
                  photos.length === 0
                    ? "Ajouter une photo"
                    : `${photos.length} photo${photos.length > 1 ? "s" : ""} — ouvrir`
                }
              >
                <VignetteProduit photo={p.photo_principale} taille={68} />
                <span className="absolute -bottom-1 -right-1 min-w-[22px] h-[22px] px-1 rounded-full bg-plum text-white text-[11px] grid place-items-center tabular-nums">
                  {photos.length > 0 ? photos.length : "+"}
                </span>
              </summary>

              <div className="fixed inset-0 z-10 bg-ink/40 hidden group-open/photos:block" />
              <div className="fixed inset-x-0 bottom-0 z-30 max-w-md mx-auto bg-surface rounded-t-[20px] px-5 pt-4 pb-6 hidden group-open/photos:flex flex-col gap-3 max-h-[80dvh] overflow-y-auto">
                <span className="w-10 h-1 rounded-full bg-line self-center" aria-hidden />
                <h3 className="font-display font-semibold text-[16px]">Photos du produit</h3>

                {photos.length === 0 ? (
                  <p className="text-[13px] text-ink-faint text-pretty">
                    Aucune photo. C’est elle que le technicien voit quand il choisit son
                    matériel — souvent ce qui lui évite de se tromper d’article.
                  </p>
                ) : (
                  <ul className="flex flex-wrap gap-2">
                    {photos.map((ph) => (
                      <li key={ph.id} className="flex flex-col gap-1">
                        <a href={`/photo/${ph.chemin}`} target="_blank" rel="noreferrer">
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img
                            src={`/photo/${ph.chemin}`}
                            alt=""
                            className={`w-[92px] h-[92px] object-cover rounded-[11px] border-2 ${
                              ph.principale ? "border-plum" : "border-line"
                            }`}
                          />
                        </a>
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
                              Supprimer
                            </button>
                          </form>
                        </span>
                      </li>
                    ))}
                  </ul>
                )}

                <form action={ajouterPhotos} className="flex flex-col gap-2">
                  <ChampPhotos nom="photos" libelle={photos.length === 0 ? "Ajouter une ou plusieurs photos" : "En ajouter"} />
                  <button className="h-[46px] rounded-[12px] bg-plum text-white font-display font-semibold text-[14.5px]">
                    Enregistrer
                  </button>
                </form>

                <span className="text-[11.5px] text-ink-faint text-center">
                  Appuyez de nouveau sur la vignette, en haut, pour refermer.
                </span>
              </div>
            </details>

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

        {/* Le prix, et ce qu'il devient */}
        {/* Toujours visible pour qui peut la tenir : sans elle, le premier
            fournisseur ne pourrait jamais être rattaché. */}
        {(peutValider(profil.role) || fournisseurs.length > 0 || (prix?.nb_achats ?? 0) > 0) && (
          <section className="flex flex-col gap-2">
            <h2 className="etiquette">Le prix</h2>

            {prix && prix.nb_achats > 0 && (
              <div className="carte px-4 py-3.5 flex flex-col gap-2.5">
                <div className="flex items-baseline gap-3">
                  <span className="grow min-w-0">
                    <span className="block text-[11.5px] text-ink-faint">
                      Dernier prix payé
                      {prix.dernier_fournisseur && ` · ${prix.dernier_fournisseur}`}
                    </span>
                    <span className="block font-display font-semibold text-[22px] tabular-nums">
                      {euros(prix.dernier_prix)}
                    </span>
                  </span>
                  {prix.variation_pct !== null && Number(prix.variation_pct) !== 0 && (
                    <span
                      className={`px-2.5 py-1 rounded-md text-[13px] tabular-nums ${
                        Number(prix.variation_pct) > 0
                          ? "bg-red-soft text-red"
                          : "bg-green-soft text-green"
                      }`}
                    >
                      {Number(prix.variation_pct) > 0 ? "+" : "−"}
                      {Math.abs(Number(prix.variation_pct))} %
                    </span>
                  )}
                </div>

                <p className="text-[12px] text-ink-soft text-pretty leading-snug">
                  {prix.nb_achats} achat{prix.nb_achats > 1 ? "s" : ""} — de{" "}
                  {euros(prix.prix_min)} à {euros(prix.prix_max)}, {euros(prix.prix_moyen)} en
                  moyenne.
                </p>

                {prix.ecart_reference_pct !== null &&
                  Math.abs(Number(prix.ecart_reference_pct)) >= 1 && (
                    <div className="rounded-card bg-amber-soft px-3.5 py-2.5 flex flex-col gap-2">
                      <p className="text-[12.5px] text-amber text-pretty leading-snug">
                        Le prix de référence est {euros(prix.prix_reference)}, le dernier payé{" "}
                        {euros(prix.dernier_prix)} —{" "}
                        {Number(prix.ecart_reference_pct) > 0 ? "+" : "−"}
                        {Math.abs(Number(prix.ecart_reference_pct))} %. La valeur du stock est
                        calculée sur la référence.
                      </p>
                      {peutValider(profil.role) && (
                        <form action={alignerPrix}>
                          <button className="h-[38px] px-3 rounded-[10px] bg-surface border border-amber/30 text-[12.5px] text-amber">
                            Aligner la référence sur {euros(prix.dernier_prix)}
                          </button>
                        </form>
                      )}
                    </div>
                  )}

                {/* Les achats, du plus récent au plus ancien. Une liste dit mieux
                    qu'une courbe ce qui s'est passé quand il y a trois achats. */}
                <ul className="flex flex-col gap-1 border-t border-line pt-2.5">
                  {achats.map((a) => {
                    const hausse =
                      a.prix_precedent !== null
                        ? Number(a.prix_unitaire) - Number(a.prix_precedent)
                        : null;
                    return (
                      <li key={a.mouvement_id} className="flex items-baseline gap-2 text-[12.5px]">
                        <span className="text-ink-faint tabular-nums w-[68px] shrink-0">
                          {new Date(a.date_mouvement).toLocaleDateString("fr-FR")}
                        </span>
                        <span className="grow min-w-0 truncate text-ink-soft">
                          {a.fournisseur ?? "—"}
                          {a.facture && ` · ${a.facture}`}
                        </span>
                        {hausse !== null && Math.abs(hausse) >= 0.01 && (
                          <span
                            className={`tabular-nums text-[11px] ${
                              hausse > 0 ? "text-red" : "text-green"
                            }`}
                          >
                            {hausse > 0 ? "+" : "−"}
                            {Math.abs(hausse).toFixed(2)}
                          </span>
                        )}
                        <span className="tabular-nums shrink-0">{euros(a.prix_unitaire)}</span>
                        {a.facture_fichier && (
                          <a
                            href={`/photo/${a.facture_fichier}`}
                            target="_blank"
                            rel="noreferrer"
                            aria-label="Voir la facture"
                            className="text-plum underline underline-offset-2 text-[11px] shrink-0"
                          >
                            facture
                          </a>
                        )}
                      </li>
                    );
                  })}
                </ul>
              </div>
            )}

            {/* Chez qui on commande, et à quelle adresse.
                Replié dès qu'un fournisseur est en place : une fois réglé, on
                n'a plus besoin de le voir en ouvrant la fiche. */}
            <details className="carte px-3.5 py-3" open={fournisseurs.length === 0}>
              <summary className="list-none flex items-center justify-between cursor-pointer">
                <span className="etiquette">Fournisseurs</span>
                <span className="text-[12.5px] text-ink-faint">
                  {fournisseurs.length === 0
                    ? "aucun"
                    : fournisseurs.map((f) => f.nom).join(", ")}
                </span>
              </summary>
              <div className="flex flex-col gap-2.5 pt-2.5">
              {fournisseurs.length === 0 ? (
                <p className="text-[12.5px] text-ink-faint text-pretty">
                  Aucun fournisseur rattaché : la demande de devis ne peut pas partir pour ce
                  produit.
                </p>
              ) : (
                <ul className="flex flex-col gap-1.5">
                  {fournisseurs.map((f) => (
                    <li key={f.lien_id} className="flex flex-col gap-1.5">
                    <span className="flex items-center gap-2">
                      <span className="grow min-w-0">
                        <span className="block text-[14px] truncate">
                          {f.nom}
                          {f.prefere && (
                            <span className="ml-1.5 text-[10.5px] text-plum">préféré</span>
                          )}
                        </span>
                        <span className="block text-[11.5px] text-ink-faint truncate">
                          {f.email ?? "pas d’adresse — le devis ne partira pas"}
                          {f.reference_fournisseur && ` · réf. ${f.reference_fournisseur}`}
                        </span>
                        {(f.contact || f.telephone) && (
                          <span className="block text-[11.5px] text-ink-faint truncate">
                            {f.contact}
                            {f.contact && f.telephone && " · "}
                            {f.telephone && (
                              <a href={`tel:${f.telephone}`} className="text-plum">
                                {f.telephone}
                              </a>
                            )}
                          </span>
                        )}
                      </span>
                      {!f.prefere && peutValider(profil.role) && (
                        <form action={prefererFournisseur}>
                          <input type="hidden" name="lien" value={f.lien_id} />
                          <button className="h-[34px] px-2.5 rounded-[9px] bg-plum-soft text-plum text-[11px] min-h-0">
                            Préférer
                          </button>
                        </form>
                      )}
                      {peutValider(profil.role) && (
                        <form action={detacher}>
                          <input type="hidden" name="lien" value={f.lien_id} />
                          <button
                            aria-label={`Retirer ${f.nom}`}
                            className="w-9 h-9 rounded-[9px] bg-surface border border-line grid place-items-center min-h-0"
                          >
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                 stroke="#8E8AA3" strokeWidth="2.2" strokeLinecap="round">
                              <path d="M6 12h12" />
                            </svg>
                          </button>
                        </form>
                      )}
                    </span>

                    {peutValider(profil.role) && (
                      <details className="rounded-[10px] bg-surface-muted px-2.5 py-1.5">
                        <summary className="text-[11.5px] text-plum cursor-pointer list-none underline underline-offset-4">
                          Corriger le contact
                        </summary>
                        <form action={corrigerFournisseur} className="flex flex-col gap-1.5 pt-2">
                          <input type="hidden" name="fournisseur" value={f.fournisseur_id} />
                          <input type="hidden" name="lien" value={f.lien_id} />
                          <input
                            name="contact"
                            autoComplete="off"
                            defaultValue={f.contact ?? ""}
                            placeholder="Nom de la personne"
                            className="w-full h-[40px] px-2.5 rounded-[9px] border border-line bg-surface text-[14px] placeholder:text-ink-faint"
                          />
                          <div className="flex gap-1.5">
                            <input
                              name="telephone"
                              type="tel"
                              autoComplete="off"
                              defaultValue={f.telephone ?? ""}
                              placeholder="Téléphone"
                              className="flex-1 min-w-0 h-[40px] px-2.5 rounded-[9px] border border-line bg-surface text-[14px] placeholder:text-ink-faint"
                            />
                            <input
                              name="reference"
                              autoComplete="off"
                              defaultValue={f.reference_fournisseur ?? ""}
                              placeholder="Réf."
                              className="w-[88px] h-[40px] px-2.5 rounded-[9px] border border-line bg-surface text-[14px] placeholder:text-ink-faint"
                            />
                          </div>
                          <input
                            name="email"
                            type="email"
                            autoComplete="off"
                            defaultValue={f.email ?? ""}
                            placeholder="Adresse mail"
                            className="w-full h-[40px] px-2.5 rounded-[9px] border border-line bg-surface text-[14px] placeholder:text-ink-faint"
                          />
                          <button className="h-[38px] rounded-[9px] bg-surface border border-line text-[12.5px]">
                            Enregistrer
                          </button>
                          <p className="text-[10.5px] text-ink-faint text-pretty leading-snug">
                            Le contact change souvent : il se corrige d’ici, sans quitter le
                            produit.
                          </p>
                        </form>
                      </details>
                    )}
                    </li>
                  ))}
                </ul>
              )}

              {peutValider(profil.role) && (
                <details className="border-t border-line pt-2.5" open={fournisseurs.length === 0}>
                  <summary className="list-none text-[14px] text-plum cursor-pointer py-1">
                    {fournisseurs.length === 0
                      ? "Rattacher un fournisseur"
                      : "Rattacher un autre fournisseur"}
                  </summary>
                <form action={rattacher} className="flex flex-col gap-2 pt-2">
                  <select
                    name="fournisseur"
                    className="w-full h-[44px] px-3 rounded-[11px] border border-line bg-surface-muted text-[15px]"
                  >
                    <option value="">— Un fournisseur connu —</option>
                    {tous
                      .filter((t) => !fournisseurs.some((f) => f.fournisseur_id === t.id))
                      .map((t) => (
                        <option key={t.id} value={t.id}>
                          {t.nom}
                          {t.email ? "" : " (sans adresse)"}
                        </option>
                      ))}
                  </select>
                  <div className="flex gap-2">
                    <input
                      name="nouveau"
                      autoComplete="off"
                      placeholder="…ou un nouveau nom"
                      className="flex-1 min-w-0 h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[15px] placeholder:text-ink-faint"
                    />
                    <input
                      name="reference"
                      autoComplete="off"
                      placeholder="Réf. chez lui"
                      className="w-[110px] h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[15px] placeholder:text-ink-faint"
                    />
                  </div>
                  <input
                    name="email"
                    type="email"
                    autoComplete="off"
                    placeholder="Adresse mail — c’est là que part le devis"
                    className="w-full h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[15px] placeholder:text-ink-faint"
                  />
                  <div className="flex gap-2">
                    <input
                      name="contact"
                      autoComplete="off"
                      placeholder="Nom du contact"
                      className="flex-1 min-w-0 h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[15px] placeholder:text-ink-faint"
                    />
                    <input
                      name="telephone"
                      type="tel"
                      autoComplete="off"
                      placeholder="Téléphone"
                      className="flex-1 min-w-0 h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[15px] placeholder:text-ink-faint"
                    />
                  </div>
                  <button className="h-[44px] rounded-[12px] bg-surface-muted border border-line text-[14px]">
                    Rattacher au produit
                  </button>
                  <p className="text-[11px] text-ink-faint text-pretty leading-snug">
                    Plusieurs fournisseurs sont possibles : la consultation part alors chez
                    chacun, pour comparer. L’adresse saisie ici corrige aussi celle du
                    fournisseur.
                  </p>
                </form>
                </details>
              )}
              </div>
            </details>
          </section>
        )}

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

            {/* On ne supprime pas un produit : on le retire. Le supprimer
                effacerait les mouvements qui portent le coût des passages
                passés. */}
            <form action={basculerActif} className="carte px-3.5 py-3 flex items-center gap-3">
              <span className="grow text-[13px] text-ink-soft text-pretty leading-snug">
                {p.actif
                  ? "Proposé au technicien quand il dit ce qu’il a utilisé."
                  : "Retiré du choix du technicien. Les données sont gardées."}
              </span>
              <button
                className={`h-[40px] px-3.5 rounded-[11px] text-[13px] shrink-0 ${
                  p.actif
                    ? "bg-surface-muted border border-line text-ink-soft"
                    : "bg-plum text-white"
                }`}
              >
                {p.actif ? "Retirer" : "Remettre"}
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
