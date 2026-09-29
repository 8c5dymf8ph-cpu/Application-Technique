import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, peutValider } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { ChampPhotos } from "@/app/composants/photos";
import { enregistrerFichier } from "@/lib/stockage";

export const dynamic = "force-dynamic";

type Type = {
  id: string;
  code: string;
  libelle: string;
  couleur: string | null;
  photo: string | null;
  prix_vente: number;
  prix_achat: number;
  seuil_alerte: number;
  quantite_reappro: number | null;
  en_reserve: number;
};

type Regularisation = {
  id: string;
  bouteille_type_id: string;
  quantite: number;
  de_lieu: string;
  date_mouvement: string | Date;
  commentaire: string | null;
  utilisateur: string | null;
};

export default async function ReglagesBouteilles() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!peutValider(profil.role)) redirect("/bouteilles");

  const types = await sql<Type[]>`
    select bt.id, bt.code, bt.libelle, bt.couleur, bt.photo,
           bt.prix_vente, bt.prix_achat, bt.seuil_alerte, bt.quantite_reappro,
           s.en_reserve::int
    from bouteille_types bt
    join v_stock_bouteilles s on s.bouteille_type_id = bt.id
    order by bt.libelle`;

  // Les cinq dernières, par type — assez pour retrouver une régularisation
  // qu'on vient de saisir, sans remonter tout l'historique.
  const regularisations = await sql<Regularisation[]>`
    select m.id, m.bouteille_type_id, m.quantite, m.de_lieu::text,
           m.date_mouvement, m.commentaire, u.nom as utilisateur
      from mouvements_bouteilles m
      left join utilisateurs u on u.id = m.utilisateur_id
     where m.type = 'regularisation'
     order by m.date_mouvement desc
     limit 40`;

  async function ajusterBouteille(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/bouteilles");

    const type = String(donnees.get("type"));
    const ecart = Number(donnees.get("ecart") ?? 0);
    if (!ecart) return;
    const mot = String(donnees.get("commentaire") ?? "").trim() || null;

    // Aucune chambre connue : on ne peut pas dire quelle chambre a perdu la
    // bouteille (règle 2 — un dossier porte une chambre), donc ça ne passe
    // pas par un dossier. C'est exactement ce à quoi sert la régularisation
    // (règle 4) : un écart tracé, jamais une écriture directe du stock.
    if (ecart < 0) {
      await sql`
        insert into mouvements_bouteilles
          (type, bouteille_type_id, quantite, de_lieu, vers_lieu, utilisateur_id, commentaire)
        values ('regularisation', ${type}, ${Math.abs(ecart)}, 'reserve', 'hors_parc',
                ${profil_.id}, ${mot})`;
    } else {
      await sql`
        insert into mouvements_bouteilles
          (type, bouteille_type_id, quantite, de_lieu, vers_lieu, utilisateur_id, commentaire)
        values ('regularisation', ${type}, ${ecart}, 'hors_parc', 'reserve',
                ${profil_.id}, ${mot})`;
    }
    revalidatePath("/administration/bouteilles");
  }

  // Supprime la ligne : pas de mouvement inverse, rien ne garde la trace que
  // cette régularisation a existé. Réservé à peutValider, et limité au type
  // regularisation — jamais un mouvement réel (entrée, emport…).
  async function supprimerRegularisation(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/bouteilles");
    await sql`
      delete from mouvements_bouteilles
       where id = ${String(donnees.get("mouvement"))} and type = 'regularisation'`;
    revalidatePath("/administration/bouteilles");
  }

  async function enregistrer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/bouteilles");

    const id = String(donnees.get("type"));
    const fichier = donnees.get("photo");
    let chemin: string | null = null;
    if (fichier instanceof File && fichier.size > 0) {
      chemin = await enregistrerFichier(fichier);
    }

    await sql`
      update bouteille_types
         set libelle          = ${String(donnees.get("libelle") ?? "").trim()},
             prix_vente       = ${Number(donnees.get("prix_vente") ?? 0)},
             prix_achat       = ${Number(donnees.get("prix_achat") ?? 0)},
             seuil_alerte     = ${Number(donnees.get("seuil") ?? 0)},
             quantite_reappro = ${
               donnees.get("reappro") ? Number(donnees.get("reappro")) : null
             },
             photo            = coalesce(${chemin}, photo)
       where id = ${id}`;
    revalidatePath("/administration/bouteilles");
  }

  async function retirerPhoto(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/bouteilles");
    await sql`update bouteille_types set photo = null where id = ${String(donnees.get("type"))}`;
    revalidatePath("/administration/bouteilles");
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Les bouteilles" sous_titre="Photos, prix, seuils" retour="/administration" />

      <div className="px-5 py-4 flex flex-col gap-5">
        <p className="text-[13px] text-ink-soft text-pretty leading-snug">
          La photo remplace le dessin sur l’écran de déclaration. Sans photo, la bouteille reste
          dessinée à sa couleur — l’écran fonctionne dans les deux cas.
        </p>

        {types.map((t) => (
          <div
            key={t.id}
            className="carte px-4 py-4 flex flex-col gap-3 border-2"
            style={{ borderColor: t.couleur ?? "#E7E4EF" }}
          >
          <form action={enregistrer} className="flex flex-col gap-3">
            <input type="hidden" name="type" value={t.id} />

            <div className="flex items-start gap-3">
              {t.photo ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={`/photo/${t.photo}`}
                  alt={t.libelle}
                  className="w-[104px] h-[132px] object-contain rounded-[11px] border border-line bg-surface-muted shrink-0"
                />
              ) : (
                <span className="w-[104px] h-[132px] rounded-[11px] border border-dashed border-line bg-surface-muted grid place-items-center text-[10.5px] text-ink-faint text-center px-1 shrink-0">
                  Pas de photo
                </span>
              )}
              <div className="grow min-w-0 flex flex-col gap-2">
                <label className="flex flex-col gap-1">
                  <span className="etiquette">Nom</span>
                  <input
                    name="libelle"
                    defaultValue={t.libelle}
                    className="w-full h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
                  />
                </label>
                <span className="text-[11.5px] text-ink-faint">
                  {t.en_reserve} en réserve · code {t.code}
                </span>
              </div>
            </div>

            <ChampPhotos nom="photo" libelle={t.photo ? "Remplacer la photo" : "Ajouter une photo"} multiple={false} />

            <div className="flex gap-2">
              <label className="flex-1 min-w-0 flex flex-col gap-1">
                <span className="etiquette">Prix client</span>
                <input
                  name="prix_vente"
                  type="number"
                  step="0.01"
                  min={0}
                  inputMode="decimal"
                  defaultValue={t.prix_vente}
                  className="w-full h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
                />
              </label>
              <label className="flex-1 min-w-0 flex flex-col gap-1">
                <span className="etiquette">Prix d’achat</span>
                <input
                  name="prix_achat"
                  type="number"
                  step="0.01"
                  min={0}
                  inputMode="decimal"
                  defaultValue={t.prix_achat}
                  className="w-full h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
                />
              </label>
            </div>

            <div className="flex gap-2">
              <label className="flex-1 min-w-0 flex flex-col gap-1">
                <span className="etiquette">Seuil d’alerte</span>
                <input
                  name="seuil"
                  type="number"
                  min={0}
                  inputMode="numeric"
                  defaultValue={t.seuil_alerte}
                  className="w-full h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
                />
              </label>
              <label className="flex-1 min-w-0 flex flex-col gap-1">
                <span className="etiquette">À recommander</span>
                <input
                  name="reappro"
                  type="number"
                  min={1}
                  inputMode="numeric"
                  defaultValue={t.quantite_reappro ?? ""}
                  className="w-full h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
                />
              </label>
            </div>

            <p className="text-[11.5px] text-ink-faint text-pretty">
              Sous {t.seuil_alerte} en réserve, l’alerte part à la réception. Une bouteille
              emportée est facturée {euros(t.prix_vente)} ; cassée par le personnel, elle est
              valorisée {euros(t.prix_achat)}.
            </p>

            <div className="flex gap-2">
              <button className="grow h-[46px] rounded-[12px] bg-plum text-white font-display font-semibold text-[14.5px]">
                Enregistrer
              </button>
              {t.photo && (
                <button
                  formAction={retirerPhoto}
                  className="h-[46px] px-3 rounded-[12px] bg-surface border border-line text-[13px] text-ink-faint"
                >
                  Retirer la photo
                </button>
              )}
            </div>
          </form>

          {/* Un écart sans chambre connue (une bouteille que Victoria
              recherche encore) ne passe pas par un dossier — un dossier porte
              une chambre. C'est exactement le cas de la régularisation :
              un écart tracé, jamais une écriture directe du stock. */}
          <div className="border-t border-line pt-3 flex flex-col gap-2.5">
            <span className="etiquette">Régulariser le parc</span>
            <form action={ajusterBouteille} className="flex flex-col gap-2">
              <input type="hidden" name="type" value={t.id} />
              <div className="flex gap-2">
                <input
                  name="ecart"
                  type="number"
                  step="1"
                  inputMode="numeric"
                  placeholder="−1 s’il en manque une"
                  className="flex-1 min-w-0 h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[15px] tabular-nums placeholder:text-ink-faint"
                />
                <button className="shrink-0 h-[44px] px-4 rounded-[11px] bg-surface-muted border border-line text-[13.5px] font-medium">
                  Enregistrer
                </button>
              </div>
              <input
                name="commentaire"
                autoComplete="off"
                required
                placeholder="Pourquoi — sans dossier, c’est la seule trace"
                className="w-full h-[42px] px-3 rounded-[11px] border border-line bg-surface text-[14px] placeholder:text-ink-faint"
              />
            </form>

            {regularisations.filter((r) => r.bouteille_type_id === t.id).length > 0 && (
              <ul className="flex flex-col divide-y divide-line">
                {regularisations
                  .filter((r) => r.bouteille_type_id === t.id)
                  .map((r) => (
                    <li key={r.id} className="py-2 flex items-center gap-2.5">
                      <span
                        className={`shrink-0 font-display font-semibold text-[14px] tabular-nums ${
                          r.de_lieu === "reserve" ? "text-red" : "text-green"
                        }`}
                      >
                        {r.de_lieu === "reserve" ? "−" : "+"}
                        {r.quantite}
                      </span>
                      <span className="grow min-w-0 flex flex-col">
                        <span className="text-[12.5px] text-ink-soft text-pretty leading-snug">
                          {r.commentaire ?? "Sans motif noté"}
                        </span>
                        <span className="text-[11px] text-ink-faint">
                          {new Date(r.date_mouvement).toLocaleDateString("fr-FR")}
                          {r.utilisateur ? ` · ${r.utilisateur}` : ""}
                        </span>
                      </span>
                      <form action={supprimerRegularisation}>
                        <input type="hidden" name="mouvement" value={r.id} />
                        <button
                          aria-label="Supprimer"
                          className="shrink-0 w-9 h-9 rounded-[10px] bg-surface-muted grid place-items-center"
                        >
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#4F4B6B"
                               strokeWidth="2.2" strokeLinecap="round">
                            <path d="M6 12h12" />
                          </svg>
                        </button>
                      </form>
                    </li>
                  ))}
              </ul>
            )}
          </div>
          </div>
        ))}

        <Link
          href={"/bouteilles" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Retour aux bouteilles
        </Link>
      </div>
    </main>
  );
}
