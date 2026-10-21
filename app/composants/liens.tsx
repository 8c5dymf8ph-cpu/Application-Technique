"use client";

import { useLinkStatus } from "next/link";

/**
 * L'anneau de `BoutonEnvoi`, pour un lien.
 *
 * Changer d'étage, ouvrir une anomalie, chercher : rien de tout ça n'envoie
 * de formulaire, donc `BoutonEnvoi` ne les couvre pas — mais chacun part
 * quand même en aller-retour au serveur, et rien ne le disait. Entre l'appui
 * et la réponse, l'écran restait figé, parfois une seconde entière sur un
 * téléphone, et on réappuyait en croyant que rien ne s'était passé.
 *
 * Doit être un DESCENDANT du `<Link>` qu'il annonce : `useLinkStatus` ne
 * fonctionne pas autrement. Le délai avant d'apparaître (`.indicateur-attente`,
 * globals.css) évite qu'il clignote sur une navigation déjà rapide — il ne se
 * montre que si l'attente est réelle.
 */
export function IndicateurLien({ className = "" }: { className?: string }) {
  const { pending } = useLinkStatus();
  return (
    <span
      aria-hidden
      className={`indicateur-attente ${pending ? "en-attente" : ""} ${className}`}
    >
      <span className="block w-full h-full rounded-full border-2 border-current border-t-transparent animate-spin" />
    </span>
  );
}
