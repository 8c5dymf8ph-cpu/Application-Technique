"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

/**
 * Relire la page quand on y revient par la flèche arrière.
 *
 * Après avoir validé le dernier avis d'un lot, on repart sur l'accueil. La
 * flèche arrière ramenait sur l'écran de validation — mais le routeur ressort
 * la page telle qu'il l'avait mise de côté : les trois boutons, l'anomalie à
 * décider de nouveau. On croyait que rien n'avait été enregistré.
 *
 * Ce n'est pas un défaut du routeur : garder la page évite de tout recharger
 * et rend la position de lecture. Seulement, un écran de décision n'est pas un
 * écran de lecture — ce qu'il montre doit être vrai maintenant.
 *
 * On marque donc le premier passage. Si le composant se remonte alors que la
 * marque est déjà là, c'est qu'on revient : on redemande la page au serveur,
 * qui dira ce qu'il en est — et renverra ailleurs s'il n'y a plus rien à
 * décider.
 */
export function RelireAuRetour({ cle }: { cle: string }) {
  const routeur = useRouter();

  useEffect(() => {
    const marque = `vu:${cle}`;
    try {
      if (sessionStorage.getItem(marque)) {
        routeur.refresh();
      } else {
        sessionStorage.setItem(marque, "1");
      }
    } catch {
      // Navigation privée, stockage refusé : on ne rafraîchit pas, et la page
      // reste utilisable. Rien ne dépend de cette marque.
    }
  }, [cle, routeur]);

  return null;
}
