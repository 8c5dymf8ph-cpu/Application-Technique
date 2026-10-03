"use client";

import { useEffect, useRef } from "react";

const TONS: Record<string, string> = {
  green: "bg-green-soft text-green",
  blue: "bg-blue-soft text-blue",
  amber: "bg-amber-soft text-amber",
  red: "bg-red-soft text-red",
};

/**
 * La confirmation qu'on ne peut pas manquer.
 *
 * `Confirmation` (ui.tsx) est un bandeau dans le fil de la page : sur un
 * geste qu'on enchaîne vite — déclarer, valider — rien ne dit qu'il faut s'y
 * arrêter, et on continue sans l'avoir lu. « Impossible de le louper » :
 * un `<dialog>` natif, au milieu de l'écran, qu'il faut fermer pour
 * continuer. Même famille que `VoirDocument` (fenetre.tsx).
 *
 * `cle` force la réouverture : posée en clé React par l'appelant, elle
 * change à chaque nouvelle confirmation (un nouvel identifiant dans
 * l'adresse) et remonte le composant — sans elle, rouvrir la même anomalie
 * une seconde fois ne redéclencherait rien.
 */
export function ConfirmationCentree({
  texte,
  ton = "green",
  cle,
}: {
  texte: string;
  ton?: "green" | "blue" | "amber" | "red";
  cle: string;
}) {
  const fenetre = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    fenetre.current?.showModal();
  }, [cle]);

  return (
    <dialog
      ref={fenetre}
      onClick={(e) => {
        if (e.target === fenetre.current) fenetre.current?.close();
      }}
      className="backdrop:bg-black/60 bg-transparent p-0 m-auto max-w-[88vw] w-[340px]"
    >
      <div
        className={`rounded-card p-5 flex flex-col gap-4 items-center text-center ${TONS[ton]}`}
      >
        <p className="text-[16px] font-display font-semibold leading-snug text-pretty">
          {texte}
        </p>
        <button
          type="button"
          onClick={() => fenetre.current?.close()}
          className="h-[44px] px-7 rounded-[12px] bg-white/70 font-semibold text-[14px] active:opacity-70"
        >
          OK
        </button>
      </div>
    </dialog>
  );
}
