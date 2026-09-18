import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, suitLesDossiers } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { enregistrerFichier } from "@/lib/stockage";

export const dynamic = "force-dynamic";

type Commande = {
  id: string;
  reference: number;
  fournisseur: string;
  fournisseur_id: string;
  date_commande: string;
  date_livraison: string | null;
  recue_le: string | null;
  statut: string;
  montant_ht: number | null;
  montant_ttc: number | null;
  montant_tva: number | null;
  total_lignes_ht: number | null;
  facture_id: string | null;
  facture_fichier: string | null;
  facture_reference: string | null;
  commentaire: string | null;
  saisie_par: string | null;
};

type Ligne = {
  id: string;
  libelle: string;
  nature: string;
  quantite: number;
  prix_unitaire_ht: number | null;
  quantite_recue: number | null;
};

type Article = { id: string; libelle: string; nature: string };

export default async function DetailCommande({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  // Le suivi des dossiers, les commandes et les rapports sont le travail de
  // l'administration ; la gouvernante déclare, remplace et compte.
  if (!suitLesDossiers(profil.role)) redirect("/bouteilles");
  const { id } = await params;

  const [commande] = await sql<Commande[]>`
    select id, reference, fournisseur, fournisseur_id, date_commande, date_livraison,
           recue_le, statut::text, montant_ht, montant_ttc, montant_tva,
           total_lignes_ht, facture_id, facture_fichier, facture_reference,
           commentaire, saisie_par
    from v_commandes where id = ${id}`;
  if (!commande) notFound();

  const lignes = await sql<Ligne[]>`
    select cl.id,
           coalesce(p.designation, bt.libelle)                        as libelle,
           case when cl.produit_id is null then 'bouteille' else 'produit' end as nature,
           cl.quantite, cl.prix_unitaire_ht, cl.quantite_recue
    from commande_lignes cl
    left join produits p         on p.id = cl.produit_id
    left join bouteille_types bt on bt.id = cl.bouteille_type_id
    where cl.commande_id = ${id}
    order by coalesce(p.designation, bt.libelle)`;

  // Ce qu'on peut commander : les bouteilles d'abord, puis le matériel du même
  // fournisseur — c'est ainsi qu'une commande se remplit dans la vraie vie.
  const articles = await sql<Article[]>`
    select bt.id, bt.libelle, 'bouteille' as nature from bouteille_types bt
    union all
    select p.id, p.designation, 'produit' from produits p
    where p.actif and exists (
      select 1 from article_fournisseurs af
      where af.produit_id = p.id and af.fournisseur_id = ${commande.fournisseur_id})
    order by 3, 2`;

  const modifiable = commande.statut === "brouillon" || commande.statut === "envoyee";

  async function ajouterLigne(donnees: FormData) {
    "use server";
    const article = String(donnees.get("article"));
    const [nature, article_id] = article.split(":");
    const quantite = Math.max(1, Number(donnees.get("quantite") ?? 1));
    const prix = donnees.get("prix") ? Number(donnees.get("prix")) : null;
    await sql`
      insert into commande_lignes (commande_id, produit_id, bouteille_type_id,
                                   quantite, prix_unitaire_ht)
      values (${id},
              ${nature === "produit" ? article_id : null},
              ${nature === "bouteille" ? article_id : null},
              ${quantite}, ${prix})`;
    revalidatePath(`/bouteilles/commande/${id}`);
  }

  async function retirerLigne(donnees: FormData) {
    "use server";
    await sql`delete from commande_lignes where id = ${String(donnees.get("ligne"))}`;
    revalidatePath(`/bouteilles/commande/${id}`);
  }

  async function enregistrerMontants(donnees: FormData) {
    "use server";
    const ht = donnees.get("ht") ? Number(donnees.get("ht")) : null;
    const ttc = donnees.get("ttc") ? Number(donnees.get("ttc")) : null;
    const livraison = String(donnees.get("livraison") ?? "") || null;
    const mot = String(donnees.get("commentaire") ?? "").trim() || null;
    await sql`
      update commandes
         set montant_ht = ${ht}, montant_ttc = ${ttc},
             date_livraison = ${livraison}, commentaire = ${mot}
       where id = ${id}`;
    revalidatePath(`/bouteilles/commande/${id}`);
  }

  async function joindreFacture(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");

    const fichier = donnees.get("facture");
    if (!(fichier instanceof File) || fichier.size === 0) return;
    const chemin = await enregistrerFichier(fichier);
    if (!chemin) return;

    const reference = String(donnees.get("reference") ?? "").trim() || null;
    const [c] = await sql<
      { fournisseur_id: string; date_commande: string; montant_ht: number | null;
        montant_ttc: number | null; facture_id: string | null }[]
    >`select fournisseur_id, date_commande, montant_ht, montant_ttc, facture_id
        from commandes where id = ${id}`;

    // La facture est une vraie facture d'achat : elle existe indépendamment de
    // la commande, et c'est elle qui portera le règlement.
    if (c.facture_id) {
      await sql`
        update factures set fichier_url = ${chemin}, reference = ${reference}
         where id = ${c.facture_id}`;
    } else {
      const [creee] = await sql<{ id: string }[]>`
        insert into factures (type, fournisseur_id, reference, date_reference,
                              montant_ht, montant_ttc, fichier_url, statut, saisie_par)
        values ('achat', ${c.fournisseur_id}, ${reference}, ${c.date_commande},
                ${c.montant_ht}, ${c.montant_ttc}, ${chemin}, 'rapprochee', ${profil_.id})
        returning id`;
      await sql`update commandes set facture_id = ${creee.id} where id = ${id}`;
    }
    revalidatePath(`/bouteilles/commande/${id}`);
  }

  async function changerStatut(donnees: FormData) {
    "use server";
    const vers = String(donnees.get("vers"));
    if (vers === "recue") {
      // La réception écrit les entrées de stock (trigger). Les quantités reçues
      // saisies ligne à ligne l'emportent sur les quantités commandées.
      for (const [cle, valeur] of donnees.entries()) {
        if (!cle.startsWith("recu-")) continue;
        const ligne = cle.slice(5);
        const q = String(valeur).trim();
        await sql`
          update commande_lignes set quantite_recue = ${q === "" ? null : Number(q)}
           where id = ${ligne} and commande_id = ${id}`;
      }
      await sql`
        update commandes set statut = 'recue', recue_le = now(),
                             date_livraison = coalesce(date_livraison, current_date)
         where id = ${id} and statut <> 'recue'`;
    } else {
      await sql`
        update commandes set statut = ${vers}::statut_commande
         where id = ${id} and statut <> 'recue'`;
    }
    revalidatePath(`/bouteilles/commande/${id}`);
  }

  const ecart =
    commande.total_lignes_ht !== null &&
    commande.montant_ht !== null &&
    Math.abs(Number(commande.total_lignes_ht) - Number(commande.montant_ht)) >= 0.01;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={`Commande n° ${commande.reference}`}
        sous_titre={`${commande.fournisseur} · ${new Date(commande.date_commande).toLocaleDateString("fr-FR")}`}
        retour="/bouteilles/commandes"
      />

      <div className="px-5 py-4 flex flex-col gap-5">
        {/* Les articles */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Articles</h2>
          {lignes.length === 0 ? (
            <p className="text-[13.5px] text-ink-faint">Aucun article pour l’instant.</p>
          ) : (
            <ul className="carte divide-y divide-line">
              {lignes.map((l) => (
                <li key={l.id} className="px-3.5 py-2.5 flex items-center gap-3">
                  <span className="grow min-w-0">
                    <span className="block text-[14px] leading-snug text-pretty">{l.libelle}</span>
                    <span className="block text-[11.5px] text-ink-faint tabular-nums">
                      {l.quantite} ×{" "}
                      {l.prix_unitaire_ht !== null
                        ? `${euros(l.prix_unitaire_ht)} HT`
                        : "prix non renseigné"}
                      {l.quantite_recue !== null &&
                        l.quantite_recue !== l.quantite &&
                        ` · ${l.quantite_recue} reçus`}
                    </span>
                  </span>
                  {modifiable && (
                    <form action={retirerLigne}>
                      <input type="hidden" name="ligne" value={l.id} />
                      <button
                        aria-label="Retirer"
                        className="w-10 h-10 rounded-[11px] bg-surface-muted grid place-items-center"
                      >
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#4F4B6B"
                             strokeWidth="2.2" strokeLinecap="round">
                          <path d="M6 12h12" />
                        </svg>
                      </button>
                    </form>
                  )}
                </li>
              ))}
            </ul>
          )}

          {modifiable && (
            <form action={ajouterLigne} className="carte px-3.5 py-3 flex flex-col gap-2">
              <select
                name="article"
                required
                className="h-[46px] px-3 rounded-[11px] border border-line bg-surface-muted text-[15px]"
              >
                {articles.map((a) => (
                  <option key={`${a.nature}:${a.id}`} value={`${a.nature}:${a.id}`}>
                    {a.nature === "bouteille" ? "🫙 " : "🔧 "}
                    {a.libelle}
                  </option>
                ))}
              </select>
              <div className="flex gap-2">
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Quantité</span>
                  <input
                    name="quantite"
                    type="number"
                    min={1}
                    defaultValue={1}
                    inputMode="numeric"
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
                  />
                </label>
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Prix unitaire HT</span>
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
              <button className="h-[46px] rounded-[12px] bg-surface-muted border border-line text-[14.5px]">
                Ajouter l’article
              </button>
            </form>
          )}
        </section>

        {/* Les montants */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Montants</h2>
          <form action={enregistrerMontants} className="carte px-3.5 py-3 flex flex-col gap-2.5">
            <div className="flex gap-2">
              <label className="flex-1 min-w-0 flex flex-col gap-1">
                <span className="etiquette">Total HT</span>
                <input
                  name="ht"
                  type="number"
                  step="0.01"
                  min={0}
                  inputMode="decimal"
                  defaultValue={commande.montant_ht ?? ""}
                  className="w-full h-[48px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
                />
              </label>
              <label className="flex-1 min-w-0 flex flex-col gap-1">
                <span className="etiquette">Total TTC</span>
                <input
                  name="ttc"
                  type="number"
                  step="0.01"
                  min={0}
                  inputMode="decimal"
                  defaultValue={commande.montant_ttc ?? ""}
                  className="w-full h-[48px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
                />
              </label>
            </div>
            {commande.montant_tva !== null && (
              <p className="text-[12px] text-ink-faint tabular-nums">
                TVA : {euros(commande.montant_tva)}
              </p>
            )}
            {ecart && (
              <p className="text-[12px] text-amber text-pretty">
                Les lignes totalisent {euros(commande.total_lignes_ht)} HT, le montant saisi dit{" "}
                {euros(commande.montant_ht)}. C’est peut-être un port, une remise — ou une erreur.
              </p>
            )}
            <label className="flex flex-col gap-1">
              <span className="etiquette">Date de livraison</span>
              <input
                name="livraison"
                type="date"
                defaultValue={commande.date_livraison ?? ""}
                className="w-full h-[48px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
              />
            </label>
            <label className="flex flex-col gap-1">
              <span className="etiquette">Note</span>
              <textarea
                name="commentaire"
                rows={2}
                defaultValue={commande.commentaire ?? ""}
                className="px-3 py-2.5 rounded-[11px] border border-line bg-surface text-[15px] leading-snug resize-none"
              />
            </label>
            <button className="h-[46px] rounded-[12px] bg-surface-muted border border-line text-[14.5px]">
              Enregistrer
            </button>
          </form>
        </section>

        {/* La facture */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Facture du fournisseur</h2>
          {commande.facture_fichier ? (
            <a
              href={`/photo/${commande.facture_fichier}`}
              target="_blank"
              rel="noreferrer"
              className="carte px-4 py-3.5 flex items-center gap-3 active:bg-surface-muted"
            >
              <span className="w-10 h-10 shrink-0 rounded-[11px] bg-green-soft grid place-items-center">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#357051"
                     strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z" />
                  <path d="M14 3v5h5" />
                </svg>
              </span>
              <span className="grow min-w-0">
                <span className="block text-[14.5px]">
                  {commande.facture_reference ?? "Facture jointe"}
                </span>
                <span className="block text-[11.5px] text-ink-faint">Ouvrir le document</span>
              </span>
            </a>
          ) : (
            <p className="text-[13px] text-ink-faint text-pretty">
              Aucune facture jointe. Elle arrive souvent après la livraison.
            </p>
          )}
          <form action={joindreFacture} className="carte px-3.5 py-3 flex flex-col gap-2">
            <label className="flex flex-col gap-1">
              <span className="etiquette">N° de facture</span>
              <input
                name="reference"
                autoComplete="off"
                defaultValue={commande.facture_reference ?? ""}
                className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
              />
            </label>
            <label data-cible className="flex flex-col gap-1 cursor-pointer">
              <span className="etiquette">Le document (PDF ou photo)</span>
              <input
                type="file"
                name="facture"
                accept="application/pdf,image/*"
                className="text-[13px] file:mr-3 file:h-[38px] file:px-3 file:rounded-[10px] file:border file:border-line file:bg-surface-muted file:text-[13px]"
              />
            </label>
            <button className="h-[46px] rounded-[12px] bg-surface-muted border border-line text-[14.5px]">
              {commande.facture_fichier ? "Remplacer la facture" : "Joindre la facture"}
            </button>
          </form>
        </section>

        {/* Le cycle de vie */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">
            {commande.statut === "recue" ? "Reçue" : "Où en est la commande"}
          </h2>
          {commande.statut === "recue" ? (
            <p className="rounded-card bg-green-soft px-4 py-3 text-[13px] text-green text-pretty">
              Reçue le {new Date(commande.recue_le!).toLocaleDateString("fr-FR")}. Les entrées de
              stock ont été écrites : elles sont visibles dans l’historique des mouvements, et
              rien ne se « recalcule ».
            </p>
          ) : (
            <form action={changerStatut} className="flex flex-col gap-2.5">
              {lignes.length > 0 && (
                <div className="carte px-3.5 py-3 flex flex-col gap-2">
                  <p className="text-[12px] text-ink-soft text-pretty">
                    Ce qui est réellement arrivé, si différent du commandé :
                  </p>
                  {lignes.map((l) => (
                    <label key={l.id} className="flex items-center gap-3">
                      <span className="grow min-w-0 text-[13.5px] truncate">{l.libelle}</span>
                      <input
                        name={`recu-${l.id}`}
                        type="number"
                        min={0}
                        inputMode="numeric"
                        placeholder={String(l.quantite)}
                        defaultValue={l.quantite_recue ?? ""}
                        className="w-[74px] h-[42px] px-2 rounded-[10px] border border-line bg-surface text-[15px] tabular-nums text-center placeholder:text-ink-faint"
                      />
                    </label>
                  ))}
                </div>
              )}
              <div className="flex gap-2">
                {commande.statut === "brouillon" && (
                  <button
                    name="vers"
                    value="envoyee"
                    className="flex-1 h-[50px] rounded-[13px] bg-amber-soft text-amber font-display font-semibold text-[14.5px]"
                  >
                    Envoyée
                  </button>
                )}
                <button
                  name="vers"
                  value="recue"
                  disabled={lignes.length === 0}
                  className="flex-1 h-[50px] rounded-[13px] bg-plum text-white font-display font-semibold text-[14.5px] disabled:opacity-40"
                >
                  Reçue — entrer en stock
                </button>
              </div>
              <button
                name="vers"
                value="annulee"
                className="h-[44px] rounded-[12px] bg-surface border border-line text-[13px] text-ink-faint"
              >
                Annuler la commande
              </button>
            </form>
          )}
        </section>

        <Link
          href={"/bouteilles/commandes" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Toutes les commandes
        </Link>
      </div>
    </main>
  );
}
