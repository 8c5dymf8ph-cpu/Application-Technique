"use client";

import { useRef, useState } from "react";
import { useFormStatus } from "react-dom";

/**
 * Le champ de photos — réduit les images AVANT de les envoyer.
 *
 * Vercel refuse toute requête de plus de 4,5 Mo : une photo de téléphone en
 * fait trois à huit, et l'envoi est coupé par la plateforme sans que rien ne
 * s'affiche. L'écran paraît figé alors qu'il attend une réponse qui ne viendra
 * pas. Les images sont donc redessinées ici, côté navigateur, avant de partir.
 *
 * Effet de bord heureux : le dépôt Supabase est limité à 1 Go sur l'offre
 * gratuite. Une photo de 300 Ko au lieu de 6 Mo, c'est vingt fois plus de
 * photos avant d'y penser.
 */

/** Un côté de 1600 px suffit largement pour reconnaître une fuite ou une prise. */
const COTE_MAX = 1600;
const QUALITE = 0.82;
/** La limite de Vercel est à 4,5 Mo ; on garde de la marge pour le reste du formulaire. */
const LIMITE = 3.5 * 1024 * 1024;

async function decoder(fichier: File): Promise<ImageBitmap | null> {
  try {
    // « from-image » applique l'orientation EXIF : sans elle, une photo prise
    // à la verticale arrive couchée.
    return await createImageBitmap(fichier, { imageOrientation: "from-image" });
  } catch {
    return null;
  }
}

async function reduire(fichier: File): Promise<File> {
  if (!fichier.type.startsWith("image/")) return fichier;

  const image = await decoder(fichier);
  // Format que le navigateur ne sait pas décoder (un HEIC ailleurs que sur
  // iPhone) : on laisse passer l'original plutôt que de perdre la photo.
  if (!image) return fichier;

  const echelle = Math.min(1, COTE_MAX / Math.max(image.width, image.height));
  if (echelle === 1 && fichier.size <= LIMITE) {
    image.close();
    return fichier;
  }

  const largeur = Math.max(1, Math.round(image.width * echelle));
  const hauteur = Math.max(1, Math.round(image.height * echelle));
  const toile = document.createElement("canvas");
  toile.width = largeur;
  toile.height = hauteur;
  const pinceau = toile.getContext("2d");
  if (!pinceau) {
    image.close();
    return fichier;
  }
  pinceau.drawImage(image, 0, 0, largeur, hauteur);
  image.close();

  const blob = await new Promise<Blob | null>((donner) =>
    toile.toBlob(donner, "image/jpeg", QUALITE),
  );
  if (!blob || blob.size >= fichier.size) return fichier;

  const nom = fichier.name.replace(/\.[^.]+$/, "") + ".jpg";
  return new File([blob], nom, { type: "image/jpeg", lastModified: Date.now() });
}

function Etat({ nombre }: { nombre: number }) {
  const { pending } = useFormStatus();
  if (pending && nombre > 0) return <>Envoi en cours…</>;
  if (nombre === 0) return null;
  return <>{nombre === 1 ? "1 fichier prêt" : `${nombre} fichiers prêts`}</>;
}

/** Un fichier prêt à partir, et son aperçu. */
type Prete = { fichier: File; apercu: string };

export function ChampPhotos({
  nom = "photos",
  libelle = "Ajouter une ou plusieurs photos",
  multiple = true,
  documents = false,
}: {
  nom?: string;
  libelle?: string;
  /** Un seul fichier quand l'écran n'en attend qu'un — la photo d'un produit. */
  multiple?: boolean;
  /** Une facture arrive en PDF aussi souvent qu'en photo. */
  documents?: boolean;
}) {
  const champ = useRef<HTMLInputElement>(null);
  const [pretes, setPretes] = useState<Prete[]>([]);
  const [prepare, setPrepare] = useState(false);

  /**
   * Le champ natif REMPLACE sa sélection à chaque ouverture.
   *
   * Sur un téléphone, prendre une photo puis rouvrir pour en prendre une
   * seconde effaçait la première, sans un mot. On croyait ne pas pouvoir en
   * ajouter. On garde donc la liste nous-mêmes, et on réécrit le champ à
   * partir d'elle : chaque photo s'ajoute aux précédentes.
   */
  function poser(liste: Prete[]) {
    const sac = new DataTransfer();
    for (const p of liste) sac.items.add(p.fichier);
    if (champ.current) champ.current.files = sac.files;
    setPretes(liste);
  }

  function retirer(rang: number) {
    const gardees = pretes.filter((_, i) => i !== rang);
    const partie = pretes[rang];
    if (partie && !partie.apercu.startsWith("pdf:")) URL.revokeObjectURL(partie.apercu);
    poser(gardees);
  }

  async function choisies(evenement: React.ChangeEvent<HTMLInputElement>) {
    const choix = Array.from(evenement.currentTarget.files ?? []);
    if (choix.length === 0) return;
    setPrepare(true);
    try {
      const reduites = await Promise.all(choix.map(reduire));
      const neuves = reduites.map((f) => ({
        fichier: f,
        apercu: f.type === "application/pdf" ? `pdf:${f.name}` : URL.createObjectURL(f),
      }));
      // Un écran qui n'attend qu'un fichier remplace ; les autres ajoutent.
      poser(multiple ? [...pretes, ...neuves] : neuves);
    } catch {
      const neuves = choix.map((f) => ({ fichier: f, apercu: URL.createObjectURL(f) }));
      poser(multiple ? [...pretes, ...neuves] : neuves);
    } finally {
      setPrepare(false);
    }
  }

  const images = pretes.filter((p) => !p.apercu.startsWith("pdf:"));

  return (
    <div className="flex flex-col gap-2">
      <label
        data-cible
        className="carte px-4 py-3.5 flex items-center gap-3 cursor-pointer active:bg-surface-muted"
      >
        <span className="w-10 h-10 shrink-0 rounded-[11px] bg-plum-soft grid place-items-center">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#453A6E"
               strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
            <path d="M4 8a2 2 0 0 1 2-2h2l1.2-1.6A1 1 0 0 1 10 4h4a1 1 0 0 1 .8.4L16 6h2a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z" />
            <circle cx="12" cy="12.5" r="3.2" />
          </svg>
        </span>
        <span className="flex flex-col grow min-w-0">
          <span className="text-[14.5px] text-ink-soft">
            {pretes.length > 0 && multiple ? "Ajouter une autre photo" : libelle}
          </span>
          <span className="text-[11.5px] text-ink-faint">
            {prepare ? "Préparation…" : <Etat nombre={pretes.length} />}
          </span>
        </span>
        {/* Pas de `capture` : le téléphone propose alors l'appareil photo ET la
            photothèque, au choix. Forcer l'appareil interdisait de reprendre une
            photo déjà prise, ou une image reçue. */}
        <input
          ref={champ}
          type="file"
          name={nom}
          multiple={multiple}
          accept={documents ? "image/*,application/pdf" : "image/*"}
          className="sr-only"
          onChange={choisies}
        />
      </label>

      {images.length > 0 && (
        <div className="flex flex-wrap gap-1.5">
          {images.map((p) => {
            const rang = pretes.indexOf(p);
            return (
              <span key={p.apercu} className="relative">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={p.apercu}
                  alt=""
                  className="w-[64px] h-[64px] object-cover rounded-[9px] border border-line"
                />
                {/* Une photo ratée se retire : sinon il faut tout recommencer. */}
                <button
                  type="button"
                  onClick={() => retirer(rang)}
                  aria-label="Retirer cette photo"
                  className="absolute -top-1.5 -right-1.5 w-[22px] h-[22px] rounded-full bg-ink text-white grid place-items-center"
                >
                  <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                       strokeWidth="3" strokeLinecap="round">
                    <path d="M6 6l12 12M18 6L6 18" />
                  </svg>
                </button>
              </span>
            );
          })}
        </div>
      )}

      {pretes.some((p) => p.apercu.startsWith("pdf:")) && (
        <ul className="flex flex-col gap-1">
          {pretes
            .filter((p) => p.apercu.startsWith("pdf:"))
            .map((p) => (
              <li key={p.apercu} className="text-[12.5px] text-ink-faint flex items-center gap-2">
                <span className="grow min-w-0 truncate">{p.apercu.slice(4)}</span>
                <button
                  type="button"
                  onClick={() => retirer(pretes.indexOf(p))}
                  className="text-plum underline underline-offset-4 shrink-0"
                >
                  retirer
                </button>
              </li>
            ))}
        </ul>
      )}
    </div>
  );
}
