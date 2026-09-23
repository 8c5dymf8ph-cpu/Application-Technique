"use client";

import { useRef } from "react";

/**
 * Un document qui s'ouvre SUR l'écran, pas à côté.
 *
 * La facture s'ouvrait dans un onglet : on quittait l'application, et pour
 * revenir il fallait refermer l'onglet — sur un téléphone, c'est trois gestes
 * et on perd la place où l'on était. Un `<dialog>` natif suffit : rien à
 * charger, la touche Échap referme, et l'écran de dessous reste là où on l'a
 * laissé. C'est déjà ce que font `Vignettes` pour les photos et `ApercuFil`
 * pour les commentaires — un document n'a pas de raison d'être l'exception.
 *
 * Un PDF s'affiche dans un cadre, une image telle quelle : c'est l'extension
 * qui décide, parce que c'est tout ce qu'on connaît du fichier.
 */
export function VoirDocument({
  chemin,
  titre,
  children,
  className = "",
  ariaLabel,
}: {
  chemin: string;
  titre: string;
  children: React.ReactNode;
  className?: string;
  ariaLabel?: string;
}) {
  const fenetre = useRef<HTMLDialogElement>(null);
  const adresse = `/photo/${chemin}`;
  const pdf = /\.pdf($|\?)/i.test(chemin);

  return (
    <>
      <button
        type="button"
        onClick={() => fenetre.current?.showModal()}
        aria-label={ariaLabel ?? `Voir ${titre}`}
        className={className}
      >
        {children}
      </button>

      <dialog
        ref={fenetre}
        onClick={(e) => {
          // Un appui à côté referme : c'est le geste qu'on fait d'instinct.
          if (e.target === fenetre.current) fenetre.current?.close();
        }}
        className="backdrop:bg-black/60 bg-transparent p-0 m-auto max-w-[94vw] w-[94vw] max-h-[92dvh]"
      >
        <div className="bg-surface rounded-card overflow-hidden flex flex-col max-h-[92dvh]">
          <div className="px-4 py-3 flex items-center gap-3 border-b border-line">
            <span className="grow min-w-0 font-display font-semibold text-[15px] truncate">
              {titre}
            </span>
            {/* Ouvrir en grand reste possible — mais ce n'est plus le seul
                chemin, et ça ne se déclenche plus tout seul. */}
            <a
              href={adresse}
              target="_blank"
              rel="noreferrer"
              className="shrink-0 text-[12px] text-plum underline underline-offset-4 active:opacity-60"
            >
              Plein écran
            </a>
            <button
              type="button"
              onClick={() => fenetre.current?.close()}
              aria-label="Fermer"
              className="shrink-0 w-9 h-9 rounded-[10px] bg-surface-muted grid place-items-center active:opacity-70 transition-opacity"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                   strokeWidth="2.2" strokeLinecap="round" aria-hidden>
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
            </button>
          </div>
          <div className="grow min-h-0 overflow-auto bg-surface-muted">
            {pdf ? (
              <iframe
                src={adresse}
                title={titre}
                className="w-full h-[78dvh] border-0 bg-white"
              />
            ) : (
              /* eslint-disable-next-line @next/next/no-img-element */
              <img src={adresse} alt={titre} className="w-full h-auto" />
            )}
          </div>
        </div>
      </dialog>
    </>
  );
}
