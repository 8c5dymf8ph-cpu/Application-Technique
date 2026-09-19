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
  return <>{nombre === 1 ? "1 photo prête" : `${nombre} photos prêtes`}</>;
}

export function ChampPhotos({
  nom = "photos",
  libelle = "Ajouter une ou plusieurs photos",
}: {
  nom?: string;
  libelle?: string;
}) {
  const champ = useRef<HTMLInputElement>(null);
  const [apercus, setApercus] = useState<string[]>([]);
  const [prepare, setPrepare] = useState(false);

  async function choisies(evenement: React.ChangeEvent<HTMLInputElement>) {
    const champs = evenement.currentTarget;
    const choix = Array.from(champs.files ?? []);
    if (choix.length === 0) {
      setApercus([]);
      return;
    }
    setPrepare(true);
    try {
      const reduites = await Promise.all(choix.map(reduire));
      // On remplace le contenu du champ : c'est lui que le formulaire envoie.
      const sac = new DataTransfer();
      for (const f of reduites) sac.items.add(f);
      champs.files = sac.files;
      setApercus((anciens) => {
        anciens.forEach(URL.revokeObjectURL);
        return reduites.map((f) => URL.createObjectURL(f));
      });
    } catch {
      // La réduction a échoué : les originaux partent tels quels.
      setApercus(choix.map((f) => URL.createObjectURL(f)));
    } finally {
      setPrepare(false);
    }
  }

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
          <span className="text-[14.5px] text-ink-soft">{libelle}</span>
          <span className="text-[11.5px] text-ink-faint">
            {prepare ? "Préparation…" : <Etat nombre={apercus.length} />}
          </span>
        </span>
        {/* Pas de `capture` : le téléphone propose alors l'appareil photo ET la
            photothèque, au choix. Forcer l'appareil interdisait de reprendre une
            photo déjà prise, ou une image reçue. */}
        <input
          ref={champ}
          type="file"
          name={nom}
          multiple
          accept="image/*"
          className="sr-only"
          onChange={choisies}
        />
      </label>

      {apercus.length > 0 && (
        <div className="flex flex-wrap gap-1.5">
          {apercus.map((src) => (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              key={src}
              src={src}
              alt=""
              className="w-[56px] h-[56px] object-cover rounded-[9px] border border-line"
            />
          ))}
        </div>
      )}
    </div>
  );
}
