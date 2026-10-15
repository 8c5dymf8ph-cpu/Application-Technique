"use client";

import { useRef } from "react";
import Link from "next/link";
import type { Route } from "next";

export type NomIntervenant = { cle: string; nom: string };

/**
 * Un compteur de l'accueil qui ouvre une fenêtre pour choisir qui — au lieu
 * d'une liste hotel-wide qui n'est l'écran de personne. « À faire » et
 * « En cours » mènent au travail d'UN intervenant, sur SA tournée
 * (`/technique/<nom>`) : il faut d'abord savoir lequel, et c'est tout ce
 * que cette fenêtre demande.
 */
export function CompteurChoixIntervenant({
  valeur,
  libelle,
  ton,
  intervenants,
}: {
  valeur: number;
  libelle: string;
  ton: string;
  intervenants: NomIntervenant[];
}) {
  const fenetre = useRef<HTMLDialogElement>(null);

  return (
    <>
      <button
        type="button"
        onClick={() => fenetre.current?.showModal()}
        className="rounded-[18px] bg-surface px-2 py-5 flex flex-col items-center gap-1 shadow-[0_2px_4px_rgba(27,25,48,0.04),0_10px_22px_-10px_rgba(27,25,48,0.18)] active:bg-surface-muted"
      >
        <span className={`font-display font-semibold text-[30px] leading-none tabular-nums ${ton}`}>
          {valeur}
        </span>
        <span className="etiquette">{libelle}</span>
      </button>

      <dialog
        ref={fenetre}
        onClick={(e) => {
          if (e.target === fenetre.current) fenetre.current?.close();
        }}
        className="backdrop:bg-black/60 bg-transparent p-0 m-auto max-w-[92vw] w-[92vw] max-h-[85dvh]"
      >
        <div className="bg-surface rounded-card overflow-hidden flex flex-col max-h-[85dvh] w-full max-w-md mx-auto">
          <div className="px-4 pt-4 pb-3 border-b border-line">
            <p className="font-display font-semibold text-[15.5px]">Qui intervient ?</p>
            <p className="text-[12px] text-ink-faint mt-0.5">
              { libelle } — {valeur}. Choisis un nom pour ouvrir sa tournée.
            </p>
          </div>
          <ul className="px-3 py-2.5 flex flex-col gap-1.5 overflow-y-auto">
            {intervenants.map((i) => (
              <li key={i.cle}>
                <Link
                  href={`/technique/${encodeURIComponent(i.nom)}` as Route}
                  className="carte px-4 py-3 flex items-center text-[14.5px] active:bg-surface-muted"
                >
                  {i.nom}
                </Link>
              </li>
            ))}
          </ul>
          <div className="px-4 py-3.5 border-t border-line">
            <button
              type="button"
              onClick={() => fenetre.current?.close()}
              className="w-full h-[46px] rounded-[13px] bg-surface-muted border border-line text-[14.5px] active:opacity-80"
            >
              Annuler
            </button>
          </div>
        </div>
      </dialog>
    </>
  );
}
