import { notFound, redirect } from "next/navigation";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { Confirmation, Entete } from "@/app/composants/ui";
import { ChampPhotos } from "@/app/composants/photos";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { enregistrerFichier, supprimerFichier } from "@/lib/stockage";

export const dynamic = "force-dynamic";

/**
 * Les photos d'un produit, sur leur propre écran.
 *
 * Elles vivaient dans un panneau qui montait du bas de la fiche, ouvert par la
 * vignette. Trois défauts en un :
 *
 * - le panneau défilait dans lui-même, et la liste de ce qui est prêt à partir
 *   comme le bouton d'enregistrement tombaient hors de vue. On choisissait une
 *   photo, rien ne bougeait à l'endroit qu'on regardait, on la rechoisissait —
 *   et on s'est retrouvé avec la même photo quatre fois ;
 * - le bouton d'enregistrement, une fois trouvé, ressemblait à celui des
 *   réglages juste en dessous : on ne savait plus lequel valide quoi ;
 * - après l'ajout, le panneau se refermait et l'écran revenait en haut, sans
 *   qu'on voie ce qui avait été ajouté ; revenir en arrière ramenait à la fiche
 *   d'avant l'ajout, comme si rien ne s'était passé.
 *
 * Un écran règle les trois : un en-tête qui dit où l'on est, un retour qui
 * ramène à la fiche, la confirmation en haut, les photos en grand dessous, et
 * un seul bouton qui ne peut valider que les photos.
 */

type Photo = {
  id: string;
  chemin: string;
  principale: boolean;
  ajoutee_le: string;
  par: string | null;
};

export default async function PhotosProduit({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ fait?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { id } = await params;
  const { fait } = await searchParams;

  const [p] = await sql<{ designation: string; code: string }[]>`
    select designation, code from produits where id = ${id}`;
  if (!p) notFound();

  const photos = await sql<Photo[]>`
    select ph.id, ph.chemin, ph.principale, ph.ajoutee_le, u.nom as par
      from photos_produit ph
      left join utilisateurs u on u.id = ph.ajoutee_par
     where ph.produit_id = ${id}
     order by ph.principale desc, ph.ordre, ph.ajoutee_le`;

  const fiche = `/stock/produit/${id}` as Route;
  const ici = `/stock/produit/${id}/photos` as Route;

  async function ajouter(donnees: FormData) {
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
      // Une photo refusée par le dépôt disparaissait sans un mot : on croyait
      // l'avoir ajoutée et la vignette ne changeait pas.
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
    // On reste sur l'écran : les nouvelles photos apparaissent dans la liste,
    // sous la confirmation. Il n'y a plus rien à aller vérifier ailleurs.
    redirect(`${ici}?fait=${refusees > 0 ? "photo-refusee" : posees > 1 ? "photos" : "photo"}` as Route);
  }

  async function mettreEnAvant(donnees: FormData) {
    "use server";
    const photo = String(donnees.get("photo"));
    await sql`update photos_produit set principale = false where produit_id = ${id}`;
    await sql`update photos_produit set principale = true where id = ${photo}`;
    redirect(`${ici}?fait=en-avant` as Route);
  }

  async function retirer(donnees: FormData) {
    "use server";
    const photo = String(donnees.get("photo"));
    // Le fichier part du dépôt aussi : une photo retirée de l'écran mais gardée
    // en stockage se paierait au gigaoctet.
    const [ligne] = await sql<{ chemin: string }[]>`
      select chemin from photos_produit where id = ${photo}`;
    await sql`delete from photos_produit where id = ${photo}`;
    if (ligne) await supprimerFichier(ligne.chemin);
    // S'il en reste, la première reprend la place.
    await sql`
      update photos_produit set principale = true
       where id = (select id from photos_produit where produit_id = ${id}
                   order by ordre, ajoutee_le limit 1)
         and not exists (select 1 from photos_produit
                          where produit_id = ${id} and principale)`;
    redirect(`${ici}?fait=photo-retiree` as Route);
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Photos" sous_titre={p.designation} retour={fiche} />

      <div className="px-5 py-5 flex flex-col gap-5">
        {/* Ajouter une photo change ce que cet écran doit montrer : en
            revenant dessus, on doit voir la liste à jour, pas celle d'avant
            l'ajout. */}
        <Confirmation quoi={fait} />

        <p className="text-[13px] text-ink-faint text-pretty leading-snug">
          {photos.length === 0
            ? "Aucune photo. C’est elle que le technicien voit quand il choisit son matériel — souvent ce qui lui évite de se tromper d’article."
            : "Le technicien les voit toutes en choisissant son matériel. Celle mise en avant est la première qu’il regarde."}
        </p>

        {/* Ajouter vient en premier : c'est ce pour quoi on ouvre cet écran.
            La liste de ce qui est prêt à partir s'affiche juste sous le champ,
            et le bouton juste dessous — les trois se voient d'un seul regard. */}
        <form action={ajouter} className="flex flex-col gap-2.5">
          <ChampPhotos
            nom="photos"
            libelle={photos.length === 0 ? "Choisir une ou plusieurs photos" : "En ajouter"}
          />
          <BoutonEnvoi
            pendant="Enregistrement…"
            className="h-[50px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15px]"
          >
            Enregistrer les photos
          </BoutonEnvoi>
        </form>

        {photos.length > 0 && (
          <section className="flex flex-col gap-2.5">
            <h2 className="etiquette">
              {photos.length} photo{photos.length > 1 ? "s" : ""} enregistrée
              {photos.length > 1 ? "s" : ""}
            </h2>

            <ul className="flex flex-col gap-2.5">
              {photos.map((ph) => (
                <li key={ph.id} className="carte p-2.5 flex gap-3">
                  <a
                    href={`/photo/${ph.chemin}`}
                    target="_blank"
                    rel="noreferrer"
                    className="shrink-0"
                    aria-label="Voir l’image entière"
                  >
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src={`/photo/${ph.chemin}`}
                      alt=""
                      className={`w-[104px] h-[104px] object-cover rounded-[11px] border-2 ${
                        ph.principale ? "border-plum" : "border-line"
                      }`}
                    />
                  </a>

                  <div className="grow min-w-0 flex flex-col gap-2 justify-center">
                    <span className="flex flex-col">
                      <span
                        className={`text-[13px] ${ph.principale ? "text-plum font-semibold" : "text-ink-faint"}`}
                      >
                        {ph.principale ? "Mise en avant" : "Photo suivante"}
                      </span>
                      <span className="text-[11.5px] text-ink-faint">
                        {new Date(ph.ajoutee_le).toLocaleDateString("fr-FR")}
                        {ph.par ? ` · ${ph.par}` : ""}
                      </span>
                    </span>

                    <span className="flex gap-1.5">
                      {!ph.principale && (
                        <form action={mettreEnAvant} className="grow">
                          <input type="hidden" name="photo" value={ph.id} />
                          <BoutonEnvoi
                            pendant="…"
                            className="w-full h-[38px] rounded-[10px] bg-plum-soft text-plum text-[12.5px]"
                          >
                            Mettre en avant
                          </BoutonEnvoi>
                        </form>
                      )}
                      <form action={retirer} className={ph.principale ? "grow" : ""}>
                        <input type="hidden" name="photo" value={ph.id} />
                        <BoutonEnvoi
                          pendant="…"
                          className="w-full h-[38px] px-3 rounded-[10px] bg-surface border border-line text-ink-faint text-[12.5px]"
                        >
                          Supprimer
                        </BoutonEnvoi>
                      </form>
                    </span>
                  </div>
                </li>
              ))}
            </ul>
          </section>
        )}
      </div>
    </main>
  );
}
