"use client";

import { useCallback, useEffect, useRef, useState } from "react";

/**
 * Les photos d'une anomalie, consultables sans quitter l'écran.
 *
 * Une vignette de 74 px ne dit pas si la fuite est réparée. Elles ouvraient un
 * onglet du navigateur : on perdait sa place, et il fallait revenir. Une
 * fenêtre native suffit — l'image en grand, les flèches pour passer à la
 * suivante, Échap ou un appui à côté pour refermer.
 *
 * Côté technicien les vignettes sont plus grandes : il regarde le constat pour
 * savoir ce qu'il vient faire, et c'est la première chose qu'il fait.
 */
export function Vignettes({
  chemins,
  titre,
  ton = "text-ink-faint",
  taille = 74,
}: {
  chemins: string[];
  titre: string;
  ton?: string;
  /** Côté du carré, en pixels. 74 par défaut, 104 quand la photo est le sujet. */
  taille?: number;
}) {
  const fenetre = useRef<HTMLDialogElement>(null);
  const [rang, setRang] = useState(0);

  const ouvrir = (i: number) => {
    setRang(i);
    fenetre.current?.showModal();
  };

  const deplacer = useCallback(
    (pas: number) => setRang((r) => (r + pas + chemins.length) % chemins.length),
    [chemins.length],
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

  const depart = useRef(0);

  if (chemins.length === 0) return null;

  return (
    <div className="flex flex-col gap-1.5">
      <span className={`text-[11.5px] ${ton}`}>{titre}</span>
      <div className="flex flex-wrap gap-1.5">
        {chemins.map((c, i) => (
          <button
            key={c}
            type="button"
            onClick={() => ouvrir(i)}
            aria-label={`Agrandir la photo ${i + 1} sur ${chemins.length}`}
            className="rounded-[11px] overflow-hidden border border-line bg-surface-muted shrink-0"
            style={{ width: taille, height: taille }}
          >
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={`/photo/${c}`}
              alt={`${titre} — ${i + 1}`}
              loading="lazy"
              className="w-full h-full object-cover"
            />
          </button>
        ))}
      </div>

      <dialog
        ref={fenetre}
        className="m-auto w-[min(96vw,44rem)] max-h-[92dvh] rounded-card bg-ink p-0 backdrop:bg-ink/80"
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
          <div className="flex items-center justify-between px-3 py-2 text-white/80">
            <span className="text-[12.5px] tabular-nums">
              {titre} · {rang + 1} / {chemins.length}
            </span>
            <button
              type="button"
              onClick={() => fenetre.current?.close()}
              aria-label="Fermer"
              className="w-10 h-10 -mr-2 grid place-items-center"
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
              src={`/photo/${chemins[rang]}`}
              alt={`${titre} — ${rang + 1}`}
              className="w-full max-h-[76dvh] object-contain select-none"
            />
            {chemins.length > 1 && (
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

          {/* Ouvrir l'original reste possible : c'est la seule façon de l'enregistrer. */}
          <a
            href={`/photo/${chemins[rang]}`}
            target="_blank"
            rel="noreferrer"
            className="px-3 py-2.5 text-[12.5px] text-white/70 underline underline-offset-4"
          >
            Ouvrir l’image entière
          </a>
        </div>
      </dialog>
    </div>
  );
}
