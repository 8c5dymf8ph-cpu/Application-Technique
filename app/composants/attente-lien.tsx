"use client";

import { useLinkStatus } from "next/link";

/**
 * Le lien a été touché, l'écran suivant arrive.
 *
 * Choisir une chambre ou passer de « Perte » à « Casse » demande un aller-retour
 * au serveur : entre l'appui et la réponse, rien ne bougeait, et on ne savait
 * pas si l'appui avait porté — « je sais que c'est pris en compte mais il n'y
 * a aucun repère visuel ». Posé DANS un lien `relative`, il le couvre d'un
 * voile qui pulse jusqu'à l'arrivée de l'écran. Le même principe que les
 * onglets d'étage (`onglet-etage.tsx`), aux coins du lien qui le porte.
 */
export function AttenteLien() {
  const { pending } = useLinkStatus();
  if (!pending) return null;
  return (
    <span
      aria-hidden
      className="absolute inset-0 rounded-[inherit] ring-2 ring-inset ring-plum/70 bg-plum/15 animate-pulse pointer-events-none"
    />
  );
}
