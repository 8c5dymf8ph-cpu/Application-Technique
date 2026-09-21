"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { VignetteProduit } from "./produit";

/**
 * Les photos d'un article, qui s'ouvrent en grand.
 *
 * Au moment de choisir son matériel, le technicien reconnaît la pièce à sa
 * photo — pas à « Mousseur de robinet M24 ». En 40 px il ne reconnaît rien. Un
 * appui sur la vignette les ouvre par-dessus l'écran, sans quitter la liste ni
 * perdre ce qui est déjà sélectionné.
 *
 * **Toutes** les photos, pas seulement celle mise en avant. On en ajoutait
 * quatre sur la fiche du produit, et le technicien n'en voyait qu'une : les
 * trois autres n'existaient nulle part pour lui, alors que ce sont justement
 * elles qui montrent l'article sous un autre angle — le filetage, le dos, la
 * référence imprimée. La pastille sur la vignette dit combien il y en a, sinon
 * rien n'indique qu'il y a autre chose à regarder.
 *
 * Sans photo, la vignette reste le repère dessiné et n'ouvre rien : il n'y a
 * rien à agrandir, et un appui qui ne fait rien vaut mieux qu'une fenêtre vide.
 */
export function PhotoProduit({
  photos,
  designation,
  taille = 44,
}: {
  photos: string[];
  designation: string;
  taille?: number;
}) {
  const fenetre = useRef<HTMLDialogElement>(null);
  const [rang, setRang] = useState(0);
  const depart = useRef(0);

  const deplacer = useCallback(
    (pas: number) => setRang((r) => (r + pas + photos.length) % photos.length),
    [photos.length],
  );

  // Les flèches du clavier sur un ordinateur, le glissement du doigt sur un
  // téléphone : les deux gestes attendus quand une image est en plein écran.
  useEffect(() => {
    const touche = (e: KeyboardEvent) => {
      if (!fenetre.current?.open) return;
      if (e.key === "ArrowRight") deplacer(1);
      if (e.key === "ArrowLeft") deplacer(-1);
    };
    window.addEventListener("keydown", touche);
    return () => window.removeEventListener("keydown", touche);
  }, [deplacer]);

  if (photos.length === 0) return <VignetteProduit photo={null} taille={taille} />;

  return (
    <>
      <button
        type="button"
        onClick={() => {
          setRang(0);
          fenetre.current?.showModal();
        }}
        aria-label={
          photos.length > 1
            ? `Voir les ${photos.length} photos de ${designation}`
            : `Voir ${designation} en grand`
        }
        className="shrink-0 relative rounded-[11px] overflow-hidden border border-line bg-surface-muted"
        style={{ width: taille, height: taille }}
      >
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={`/photo/${photos[0]}`} alt="" className="w-full h-full object-cover" />
        {photos.length > 1 && (
          <span className="absolute bottom-1 right-1 min-w-[20px] h-[20px] px-1 rounded-full bg-ink/75 text-white text-[11px] grid place-items-center tabular-nums">
            {photos.length}
          </span>
        )}
      </button>

      <dialog
        ref={fenetre}
        className="m-auto w-[min(94vw,32rem)] rounded-card bg-ink p-0 backdrop:bg-ink/80"
        onClick={(e) => {
          if (e.target === fenetre.current) fenetre.current?.close();
        }}
        onTouchStart={(e) => {
          depart.current = e.touches[0]?.clientX ?? 0;
        }}
        onTouchEnd={(e) => {
          const fin = e.changedTouches[0]?.clientX ?? 0;
          const ecart = fin - depart.current;
          if (Math.abs(ecart) > 48) deplacer(ecart < 0 ? 1 : -1);
        }}
      >
        <div className="flex flex-col">
          <div className="flex items-center gap-2 px-3 py-2 text-white/85">
            <span className="grow min-w-0 text-[13px] text-pretty leading-snug">
              {designation}
              {photos.length > 1 && (
                <span className="text-white/60 tabular-nums">
                  {" "}
                  · {rang + 1}/{photos.length}
                </span>
              )}
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

          <div className="relative bg-black">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={`/photo/${photos[rang]}`}
              alt={designation}
              className="w-full max-h-[74dvh] object-contain select-none"
            />
            {photos.length > 1 && (
              <>
                <button
                  type="button"
                  onClick={() => deplacer(-1)}
                  aria-label="Photo précédente"
                  className="absolute left-0 inset-y-0 w-16 grid place-items-center text-white/90"
                >
                  <span className="w-10 h-10 rounded-full bg-ink/50 grid place-items-center">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                         strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M15 5l-7 7 7 7" />
                    </svg>
                  </span>
                </button>
                <button
                  type="button"
                  onClick={() => deplacer(1)}
                  aria-label="Photo suivante"
                  className="absolute right-0 inset-y-0 w-16 grid place-items-center text-white/90"
                >
                  <span className="w-10 h-10 rounded-full bg-ink/50 grid place-items-center">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                         strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M9 5l7 7-7 7" />
                    </svg>
                  </span>
                </button>
              </>
            )}
          </div>
        </div>
      </dialog>
    </>
  );
}
