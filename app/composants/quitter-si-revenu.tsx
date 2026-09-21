"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import type { Route } from "next";

/**
 * Ne pas rouvrir un formulaire qu'on vient de valider.
 *
 * On déclare une perte, on arrive sur le dossier, on appuie sur la flèche
 * arrière — et le formulaire revient, rempli comme avant l'envoi. Rien ne dit
 * qu'il est déjà parti : on corrige, on renvoie, et le dossier existe deux
 * fois. Un formulaire validé n'est plus un écran de saisie.
 *
 * L'écran d'arrivée pose une marque (`<MarquerValide>`) ; le formulaire la
 * trouve en se remontant, l'efface et repart d'où l'on vient. Elle est
 * effacée au passage, donc rouvrir l'écran plus tard pour une VRAIE nouvelle
 * déclaration fonctionne normalement — c'est ce qui distingue le retour en
 * arrière d'une nouvelle saisie.
 */
export function QuitterSiRevenu({ cle, vers }: { cle: string; vers: string }) {
  const routeur = useRouter();

  useEffect(() => {
    try {
      if (sessionStorage.getItem(`valide:${cle}`)) {
        sessionStorage.removeItem(`valide:${cle}`);
        routeur.replace(vers as Route);
      }
    } catch {
      // Stockage refusé : on laisse le formulaire s'ouvrir. Rien de vital n'en
      // dépend, et le double-envoi est déjà empêché côté écriture.
    }
  }, [cle, vers, routeur]);

  return null;
}

/**
 * La marque, posée par l'écran d'arrivée.
 *
 * C'est lui qui sait que la saisie a abouti — il n'existe que parce qu'elle a
 * abouti.
 */
export function MarquerValide({ cle }: { cle: string }) {
  useEffect(() => {
    try {
      sessionStorage.setItem(`valide:${cle}`, "1");
    } catch {
      /* Rien à faire : le retour rouvrira le formulaire, comme avant. */
    }
  }, [cle]);

  return null;
}
