"use client";

import { useEffect, useRef } from "react";

export type Compteur = { label: string; valeur: number; couleur: "green" | "amber" | "red" };

const COULEUR: Record<Compteur["couleur"], string> = {
  green: "bg-green-soft text-green",
  amber: "bg-amber-soft text-amber",
  red: "bg-red-soft text-red",
};

/**
 * Ce qui a bougé sur ce passage pendant qu'on avait le dos tourné.
 *
 * Un texte posé dans le fil de la page se lisait ou pas selon qu'on
 * faisait défiler — et sur un geste qui change ce que le technicien
 * doit comprendre avant de continuer (certaines anomalies reviennent
 * décochées, d'autres ont disparu pour de bon), ça ne suffit pas. La
 * fenêtre s'ouvre d'elle-même à l'arrivée sur l'écran et se ferme sur
 * « Compris » — jamais toute seule, jamais sur un appui à côté : c'est
 * un message à accuser réception, pas une photo qu'on referme en
 * touchant n'importe où.
 */
export function AvisReprise({
  compteurs,
  messages,
}: {
  compteurs: Compteur[];
  messages: string[];
}) {
  const fenetre = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    fenetre.current?.showModal();
  }, []);

  return (
    <dialog
      ref={fenetre}
      className="backdrop:bg-black/60 bg-transparent p-0 m-auto max-w-[92vw] w-[92vw] max-h-[85dvh]"
    >
      <div className="bg-surface rounded-card overflow-hidden flex flex-col max-h-[85dvh] w-full max-w-md mx-auto">
        <div className="px-4 pt-4 pb-3 border-b border-line flex flex-col gap-3">
          <p className="font-display font-semibold text-[15.5px]">
            Depuis ton dernier passage ici
          </p>
          {compteurs.length > 0 && (
            <div className="flex gap-2">
              {compteurs.map((c) => (
                <span
                  key={c.label}
                  className={`flex-1 rounded-[11px] px-2 py-2 text-center ${COULEUR[c.couleur]}`}
                >
                  <span className="block font-display font-semibold text-[18px] leading-none">
                    {c.valeur}
                  </span>
                  <span className="block text-[10px] font-medium tracking-wide mt-1">
                    {c.label}
                  </span>
                </span>
              ))}
            </div>
          )}
        </div>
        <div className="px-4 py-3.5 flex flex-col gap-3 overflow-y-auto">
          {messages.map((m) => (
            <p key={m} className="text-[13px] text-ink-soft leading-snug text-pretty">
              {m}
            </p>
          ))}
        </div>
        <div className="px-4 py-3.5 border-t border-line">
          <button
            type="button"
            onClick={() => fenetre.current?.close()}
            className="w-full h-[46px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15px] active:opacity-80"
          >
            Compris
          </button>
        </div>
      </div>
    </dialog>
  );
}
