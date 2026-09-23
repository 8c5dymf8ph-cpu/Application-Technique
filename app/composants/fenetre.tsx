"use client";

import { useRef } from "react";

/**
 * Un document, ouvert de la façon qui convient à son format.
 *
 * Une IMAGE s'ouvre sur l'écran : un `<dialog>` natif suffit, on ne quitte
 * pas l'application et Échap referme.
 *
 * Un PDF, non. Essayé, et raté : dans un cadre de la taille d'un téléphone il
 * arrive trop zoomé, on ne voit que la première page, et sur un ordinateur ce
 * n'est pas mieux. Le lecteur PDF du téléphone fait tout cela correctement —
 * pages, pincement, rotation, recherche — et il n'y a aucune raison de le
 * refaire moins bien dans une fenêtre de 94 % de large. Une facture se lit,
 * elle ne se survole pas : sortir un instant de l'application pour la lire
 * vraiment est le bon compromis.
 *
 * L'écran le dit avant l'appui, pour qu'on ne soit pas surpris de changer
 * d'onglet.
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

  // Un PDF part au lecteur du téléphone : il fait mieux que nous.
  if (pdf) {
    return (
      <a
        href={adresse}
        target="_blank"
        rel="noreferrer"
        aria-label={ariaLabel ?? `Ouvrir ${titre}`}
        className={className}
      >
        {children}
      </a>
    );
  }

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
            <a
              href={adresse}
              target="_blank"
              rel="noreferrer"
              className="shrink-0 text-[12px] text-plum underline underline-offset-4"
            >
              Plein écran
            </a>
            <button
              type="button"
              onClick={() => fenetre.current?.close()}
              aria-label="Fermer"
              className="shrink-0 w-9 h-9 rounded-[10px] bg-surface-muted grid place-items-center"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                   strokeWidth="2.2" strokeLinecap="round" aria-hidden>
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
            </button>
          </div>
          <div className="grow min-h-0 overflow-auto bg-surface-muted">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={adresse} alt={titre} className="w-full h-auto" />
          </div>
        </div>
      </dialog>
    </>
  );
}

/** Vrai quand le fichier est un PDF : l'écran peut le dire avant l'appui. */
export function estUnPdf(chemin: string | null | undefined): boolean {
  return !!chemin && /\.pdf($|\?)/i.test(chemin);
}
