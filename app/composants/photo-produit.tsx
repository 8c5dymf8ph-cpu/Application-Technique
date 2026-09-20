"use client";

import { useRef } from "react";
import { VignetteProduit } from "./produit";

/**
 * La photo d'un article, qui s'ouvre en grand.
 *
 * Au moment de choisir son matériel, le technicien reconnaît la pièce à sa
 * photo — pas à « Mousseur de robinet M24 ». En 40 px il ne reconnaît rien.
 * Un appui sur la vignette l'ouvre en grand, par-dessus l'écran, sans quitter
 * la liste ni perdre ce qui est déjà sélectionné.
 *
 * Sans photo, la vignette reste le repère dessiné et n'ouvre rien : il n'y a
 * rien à agrandir, et un appui qui ne fait rien vaut mieux qu'une fenêtre vide.
 */
export function PhotoProduit({
  photo,
  designation,
  taille = 44,
}: {
  photo: string | null;
  designation: string;
  taille?: number;
}) {
  const fenetre = useRef<HTMLDialogElement>(null);

  if (!photo) return <VignetteProduit photo={null} taille={taille} />;

  return (
    <>
      <button
        type="button"
        onClick={(e) => {
          // La vignette est dans un lien qui ajoute l'article : sans cela,
          // regarder la photo l'ajouterait au passage.
          e.preventDefault();
          e.stopPropagation();
          fenetre.current?.showModal();
        }}
        aria-label={`Voir ${designation} en grand`}
        className="shrink-0 rounded-[11px] overflow-hidden border border-line bg-surface-muted"
        style={{ width: taille, height: taille }}
      >
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={`/photo/${photo}`} alt="" className="w-full h-full object-cover" />
      </button>

      <dialog
        ref={fenetre}
        className="m-auto w-[min(94vw,32rem)] rounded-card bg-ink p-0 backdrop:bg-ink/80"
        onClick={(e) => {
          if (e.target === fenetre.current) fenetre.current?.close();
        }}
      >
        <div className="flex flex-col">
          <div className="flex items-center gap-2 px-3 py-2 text-white/85">
            <span className="grow min-w-0 text-[13px] text-pretty leading-snug">
              {designation}
            </span>
            <button
              type="button"
              onClick={() => fenetre.current?.close()}
              aria-label="Fermer"
              className="w-10 h-10 -mr-2 shrink-0 grid place-items-center"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                   strokeWidth="2" strokeLinecap="round">
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
            </button>
          </div>
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={`/photo/${photo}`}
            alt={designation}
            className="w-full max-h-[74dvh] object-contain bg-black"
          />
        </div>
      </dialog>
    </>
  );
}
