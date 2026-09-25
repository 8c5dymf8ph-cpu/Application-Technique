"use client";

import { useEffect } from "react";

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
 *
 * Le rechargement est FRANC (`window.location`), pas une navigation du
 * routeur : un dépliant resté ouvert (`<details>`, pas piloté par l'adresse)
 * garde son état dans le cache du navigateur telle qu'avant l'envoi, y
 * compris quand la cible est la MÊME adresse que l'écran de saisie — un
 * remplacement côté routeur vers une adresse inchangée ne fait alors rien.
 * Un vrai rechargement, lui, repart toujours d'une page neuve.
 */
export function QuitterSiRevenu({ cle, vers }: { cle: string; vers: string }) {
  useEffect(() => {
    try {
      if (sessionStorage.getItem(`valide:${cle}`)) {
        sessionStorage.removeItem(`valide:${cle}`);
        window.location.replace(vers);
      }
    } catch {
      // Stockage refusé : on laisse le formulaire s'ouvrir. Rien de vital n'en
      // dépend, et le double-envoi est déjà empêché côté écriture.
    }
  }, [cle, vers]);

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
