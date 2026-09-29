"use client";

import { useRef, useState } from "react";
import Link from "next/link";
import type { Route } from "next";

/** Insensible à la casse et aux accents : « Electricite » trouve « Électricité ». */
function normalise(texte: string) {
  return texte
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

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
 * Un rayon ou un métier, en texte libre, peut en compter des dizaines : au-delà
 * d'une poignée d'options, une liste sans recherche n'est plus un filtre,
 * c'est un rouleau à faire défiler pour trouver le bon mot. La fenêtre porte
 * donc une recherche dès que la liste dépasse huit choix, et le corps défile
 * dans une hauteur bornée pendant que la recherche et le titre restent fixes.
 *
 * Chaque choix porte son adresse déjà construite (`href`), jamais une
 * fonction : `MenuFiltre` est un composant client, et une fonction ordinaire
 * de l'écran serveur qui l'appelle ne peut pas lui être passée telle quelle
 * (règle 7duodecies).
 *
 * `replace`, pas `push` : changer de tri ou de rayon n'est pas naviguer vers
 * un autre écran, et sans lui, revenir en arrière rejouait chaque choix
 * essayé avant de sortir enfin de la liste.
 */
export function MenuFiltre({
  icone,
  titre,
  actif,
  choix,
}: {
  icone: "tri" | "filtre" | "lieu" | "metier";
  titre: string;
  actif: string;
  choix: { valeur: string; libelle: string; nombre?: number; href: string }[];
}) {
  const fenetre = useRef<HTMLDialogElement>(null);
  const [recherche, setRecherche] = useState("");
  const courant = choix.find((c) => c.valeur === actif);

  const cherchable = choix.length > 8;
  const mot = normalise(recherche.trim());
  const visibles = mot ? choix.filter((c) => normalise(c.libelle).includes(mot)) : choix;

  return (
    <>
      <button
        type="button"
        onClick={() => {
          setRecherche("");
          fenetre.current?.showModal();
        }}
        aria-label={`${titre} : ${courant?.libelle ?? actif}. Changer`}
        className="h-[38px] pl-3 pr-3.5 rounded-pill border border-line bg-surface text-[13px] text-ink-soft flex items-center gap-2"
      >
        {icone === "tri" && (
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
            <path d="M3 7h11M3 12h7M3 17h4" />
            <path d="M17 4v16M17 20l4-4M17 20l-4-4" />
          </svg>
        )}
        {icone === "filtre" && (
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
            <path d="M4 5h16l-6 8v6l-4 2v-8z" />
          </svg>
        )}
        {icone === "lieu" && (
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
            <path d="M12 21s7-6.1 7-11a7 7 0 0 0-14 0c0 4.9 7 11 7 11z" />
            <circle cx="12" cy="10" r="2.5" />
          </svg>
        )}
        {icone === "metier" && (
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
            <path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94z" />
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
          {cherchable && (
            <input
              value={recherche}
              onChange={(e) => setRecherche(e.target.value)}
              autoComplete="off"
              placeholder="Chercher…"
              className="h-[42px] mb-1 rounded-[11px] border border-line px-3 bg-surface text-[14.5px] placeholder:text-ink-faint"
            />
          )}

          <div className="flex flex-col gap-1 max-h-[52vh] overflow-y-auto">
            {visibles.length === 0 ? (
              <p className="px-3 py-6 text-center text-[13px] text-ink-faint">
                Rien ne correspond à « {recherche} ».
              </p>
            ) : (
              visibles.map((c) => (
                <Link
                  key={c.valeur}
                  href={c.href as Route}
                  replace
                  scroll={false}
                  onClick={() => fenetre.current?.close()}
                  className={`h-[48px] px-3 rounded-[12px] flex items-center gap-3 shrink-0 ${
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
              ))
            )}
          </div>
        </div>
      </dialog>
    </>
  );
}
