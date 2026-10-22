"use client";

import { useRef } from "react";
import { CarteIntervenant } from "./carte-intervenant";

export type NomIntervenant = {
  cle: string;
  nom: string;
  specialites: string[];
  charge: number;
  /** A un profil pour ouvrir l'application à son nom : on le choisit le plus souvent. */
  compte: boolean;
};

/**
 * Un compteur de l'accueil qui ouvre une fenêtre pour choisir qui — au lieu
 * d'une liste hotel-wide qui n'est l'écran de personne. « À faire » et
 * « En cours » mènent au travail d'UN intervenant, sur SA tournée
 * (`/technique/<nom>`) : il faut d'abord savoir lequel.
 *
 * Les intervenants s'y présentent comme dans « Intervenir » — même carte,
 * mêmes chiffres, ceux qui ont un profil d'abord, les autres repliés — et la
 * fenêtre est CENTRÉE à l'écran : elle prend toute la hauteur et pose son
 * encadré au milieu, au lieu de compter sur la marge automatique d'un
 * `<dialog>`, que Safari ne centre pas toujours.
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
  const fermer = () => fenetre.current?.close();
  const avecProfil = intervenants.filter((i) => i.compte);
  const sansProfil = intervenants.filter((i) => !i.compte);
  const carte = (i: NomIntervenant) => (
    <CarteIntervenant
      key={i.cle}
      nom={i.nom}
      specialites={i.specialites}
      charge={i.charge}
      onClick={fermer}
    />
  );

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
        className="backdrop:bg-black/60 bg-transparent p-0 m-0 w-full h-full max-w-none max-h-none"
      >
        <div
          className="min-h-full flex items-center justify-center p-4"
          onClick={(e) => {
            if (e.target === e.currentTarget) fermer();
          }}
        >
          <div className="w-full max-w-md flex flex-col gap-3">
            <div className="rounded-card bg-ground px-4 py-4 flex flex-col gap-2.5">
              <p className="font-display font-semibold text-[17px]">Qui intervient ?</p>
              <p className="text-[13.5px] text-ink-faint text-pretty">
                {valeur} anomalie{valeur > 1 ? "s" : ""} {libelle.toLowerCase()}. Choisissez qui
                intervient : les anomalies cochées ensuite seront complétées à son nom.
              </p>
              <div className="max-h-[56dvh] overflow-y-auto overscroll-contain flex flex-col gap-2 -mx-1 px-1 py-0.5">
                {avecProfil.map(carte)}
                {sansProfil.length > 0 && (
                  <details className="group/autres flex flex-col gap-2" open={avecProfil.length === 0}>
                    <summary className="list-none h-11 flex items-center gap-2 text-[14px] text-ink-soft cursor-pointer">
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                           strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" aria-hidden
                           className="transition-transform group-open/autres:rotate-90">
                        <path d="M9 6l6 6-6 6" />
                      </svg>
                      <span className="grow">Les autres intervenants</span>
                      <span className="text-[12.5px] text-ink-faint tabular-nums">{sansProfil.length}</span>
                    </summary>
                    <div className="flex flex-col gap-2 pt-1">{sansProfil.map(carte)}</div>
                  </details>
                )}
              </div>
            </div>
            <button
              type="button"
              onClick={fermer}
              className="w-full h-[52px] rounded-[15px] border-[1.5px] border-line bg-surface text-ink-faint font-display font-semibold text-[16px] active:opacity-70"
            >
              Annuler
            </button>
          </div>
        </div>
      </dialog>
    </>
  );
}
