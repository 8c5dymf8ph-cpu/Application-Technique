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
 *
 * Même habillage que la confirmation de « Fin d'intervention » — l'autre
 * fenêtre qui s'ouvre par-dessus tout dans l'app — plutôt que le cadre à
 * en-tête et pied séparés d'AvisReprise : un seul encadré, la liste dedans,
 * les boutons dessous, à l'air libre.
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
        className="backdrop:bg-black/60 bg-transparent p-0 m-auto w-full max-w-md"
      >
        <div className="w-full max-w-md flex flex-col gap-3 p-5">
          <div className="rounded-card bg-surface px-4 py-3.5 flex flex-col gap-2">
            <p className="font-display font-semibold text-[16px]">Qui intervient ?</p>
            <p className="text-[13.5px] text-ink-faint text-pretty">
              {valeur} anomalie{valeur > 1 ? "s" : ""} {libelle.toLowerCase()}. Choisis un nom
              pour ouvrir sa tournée.
            </p>
            <ul className="max-h-[34dvh] overflow-y-auto flex flex-col gap-1.5 -mx-1 px-1">
              {intervenants.map((i) => (
                <li key={i.cle}>
                  <Link
                    href={`/technique/${encodeURIComponent(i.nom)}` as Route}
                    className="flex items-center gap-2.5 py-1.5 active:opacity-70"
                  >
                    <span className="shrink-0 w-8 h-8 rounded-full bg-plum-soft grid place-items-center font-display font-semibold text-[12.5px] text-plum">
                      {i.nom.slice(0, 2).toUpperCase()}
                    </span>
                    <span className="grow min-w-0 text-[14.5px]">{i.nom}</span>
                  </Link>
                </li>
              ))}
            </ul>
          </div>
          <button
            type="button"
            onClick={() => fenetre.current?.close()}
            className="w-full h-[52px] rounded-[15px] border-[1.5px] border-line bg-surface text-ink-faint font-display font-semibold text-[16px] active:opacity-70"
          >
            Annuler
          </button>
        </div>
      </dialog>
    </>
  );
}
