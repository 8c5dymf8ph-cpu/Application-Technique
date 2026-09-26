"use client";

import { useRef } from "react";
import Link from "next/link";
import type { Route } from "next";

/**
 * Un choix, derrière une icône plutôt qu'une rangée de boutons.
 *
 * « Par date / A → Z » et « En cours / Urgents / Réglés / Perte sèche / Tous »
 * prenaient chacun une ligne entière, toujours affichée, alors qu'on ne
 * change ce choix qu'une fois de temps en temps. Une icône suffit : elle
 * porte le choix ACTUEL en clair à côté d'elle — jamais un pictogramme seul,
 * qui ne dit rien tant qu'on n'a pas appuyé — et ouvre la liste complète
 * dans une fenêtre, comme `CreerLibelle`.
 *
 * Chaque choix porte son adresse déjà construite (`href`), jamais une
 * fonction : `MenuFiltre` est un composant client, et une fonction ordinaire
 * de l'écran serveur qui l'appelle ne peut pas lui être passée telle quelle
 * (règle 7duodecies).
 */
export function MenuFiltre({
  icone,
  titre,
  actif,
  choix,
}: {
  icone: "tri" | "filtre";
  titre: string;
  actif: string;
  choix: { valeur: string; libelle: string; nombre?: number; href: string }[];
}) {
  const fenetre = useRef<HTMLDialogElement>(null);
  const courant = choix.find((c) => c.valeur === actif);

  return (
    <>
      <button
        type="button"
        onClick={() => fenetre.current?.showModal()}
        aria-label={`${titre} : ${courant?.libelle ?? actif}. Changer`}
        className="h-[38px] pl-3 pr-3.5 rounded-pill border border-line bg-surface text-[13px] text-ink-soft flex items-center gap-2"
      >
        {icone === "tri" ? (
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
            <path d="M3 7h11M3 12h7M3 17h4" />
            <path d="M17 4v16M17 20l4-4M17 20l-4-4" />
          </svg>
        ) : (
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
            <path d="M4 5h16l-6 8v6l-4 2v-8z" />
          </svg>
        )}
        {courant?.libelle ?? actif}
      </button>

      <dialog
        ref={fenetre}
        className="m-auto w-[min(94vw,380px)] rounded-card bg-surface p-0 backdrop:bg-black/45"
        onClick={(e) => {
          if (e.target === fenetre.current) fenetre.current?.close();
        }}
      >
        <div className="flex flex-col gap-1 p-4">
          <div className="flex items-center gap-3 pb-1">
            <p className="grow font-display font-semibold text-[16px]">{titre}</p>
            <button
              type="button"
              onClick={() => fenetre.current?.close()}
              aria-label="Fermer"
              className="shrink-0 w-[34px] h-[34px] rounded-lg bg-surface-muted grid place-items-center text-ink-soft"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                   strokeWidth="2" strokeLinecap="round" aria-hidden>
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
            </button>
          </div>
          {choix.map((c) => (
            <Link
              key={c.valeur}
              href={c.href as Route}
              onClick={() => fenetre.current?.close()}
              className={`h-[48px] px-3 rounded-[12px] flex items-center gap-3 ${
                c.valeur === actif ? "bg-plum-soft text-plum" : "text-ink"
              }`}
            >
              <span
                className={`shrink-0 w-5 h-5 rounded-full border-2 grid place-items-center ${
                  c.valeur === actif ? "border-plum" : "border-line"
                }`}
              >
                {c.valeur === actif && <span className="w-2.5 h-2.5 rounded-full bg-plum" />}
              </span>
              <span className="grow min-w-0 text-[14.5px]">{c.libelle}</span>
              {c.nombre !== undefined && (
                <span className="text-[12.5px] text-ink-faint tabular-nums">{c.nombre}</span>
              )}
            </Link>
          ))}
        </div>
      </dialog>
    </>
  );
}
