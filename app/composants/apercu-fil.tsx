"use client";

import { useRef } from "react";
import type { Message } from "./fil";
import { Fil } from "./fil";

/**
 * La bulle de commentaires, cliquable.
 *
 * Elle affichait un nombre et rien d'autre : on voyait qu'il y avait eu des
 * mots, sans pouvoir les lire. Les ouvrir dans un écran à part ferait perdre
 * la place où l'on était — pour trois lignes, une fenêtre suffit.
 *
 * `<dialog>` est natif : pas de bibliothèque, et la touche Échap referme.
 */
export function ApercuFil({
  messages,
  eteint = false,
}: {
  messages: Message[];
  eteint?: boolean;
}) {
  const fenetre = useRef<HTMLDialogElement>(null);
  if (messages.length === 0) return null;

  return (
    <>
      <button
        type="button"
        onClick={() => fenetre.current?.showModal()}
        aria-label={`Lire ${messages.length} commentaire${messages.length > 1 ? "s" : ""}`}
        className={`h-[34px] pl-2 pr-2.5 rounded-lg flex items-center gap-1.5 text-[14px] font-medium tabular-nums shrink-0 ${
          eteint ? "text-ink-faint bg-surface-muted" : "text-plum bg-plum-soft"
        }`}
      >
        <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor"
             strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
          <path d="M20 12.5c0 3.9-3.6 7-8 7a9.3 9.3 0 01-2.7-.4L4.5 20.5l1.2-3.4A6.7 6.7 0 014 12.5c0-3.9 3.6-7 8-7s8 3.1 8 7z" />
        </svg>
        {messages.length}
      </button>

      <dialog
        ref={fenetre}
        className="m-auto w-[min(92vw,26rem)] rounded-card bg-surface p-0 backdrop:bg-ink/40"
        onClick={(e) => {
          // Un appui à côté referme : c'est le geste attendu d'une fenêtre.
          if (e.target === fenetre.current) fenetre.current?.close();
        }}
      >
        <div className="flex flex-col gap-3 p-4 max-h-[75vh] overflow-y-auto">
          <div className="flex items-center justify-between">
            <span className="etiquette">Ce qui a été dit</span>
            <button
              type="button"
              onClick={() => fenetre.current?.close()}
              aria-label="Fermer"
              className="w-10 h-10 -mr-2 grid place-items-center text-ink-faint"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                   strokeWidth="2" strokeLinecap="round">
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
            </button>
          </div>
          <Fil messages={messages} />
        </div>
      </dialog>
    </>
  );
}
