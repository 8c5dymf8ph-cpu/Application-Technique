"use client";

import { useFormStatus } from "react-dom";

/**
 * Le bouton qui n'accepte qu'un appui.
 *
 * Sur un téléphone, rien ne dit que l'enregistrement est parti : l'écran reste
 * le même une seconde ou deux. On réappuie. Trois appuis sur « C'est fait » ont
 * créé trois déclarations pour la même anomalie, et la gouvernante en a eu
 * trois à vérifier.
 *
 * `useFormStatus` connaît l'état du formulaire qui entoure le bouton : tant que
 * l'action tourne, il se désactive et le dit. Le geste ne peut plus partir deux
 * fois, et on voit qu'il est parti une fois.
 */
export function BoutonEnvoi({
  children,
  pendant = "Enregistrement…",
  className = "",
  ...reste
}: React.ButtonHTMLAttributes<HTMLButtonElement> & {
  /** Ce qui s'affiche le temps que l'action réponde. */
  pendant?: string;
}) {
  const { pending } = useFormStatus();
  return (
    <button
      {...reste}
      disabled={pending || reste.disabled}
      aria-busy={pending}
      className={`${className} ${pending ? "opacity-60 pointer-events-none" : ""}`}
    >
      {pending ? (
        <span className="inline-flex items-center gap-2">
          <span
            className="w-[15px] h-[15px] rounded-full border-2 border-current border-t-transparent animate-spin"
            aria-hidden
          />
          {pendant}
        </span>
      ) : (
        children
      )}
    </button>
  );
}
