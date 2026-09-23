"use client";

import { useEffect } from "react";
import { usePathname, useRouter } from "next/navigation";

/**
 * Revenir sur un écran, c'est le redemander au serveur.
 *
 * Le routeur garde la page qu'on quitte et la ressort telle quelle à la flèche
 * arrière — c'est ce qui rend la position de lecture, et c'est une bonne chose
 * sur un écran de lecture. Mais l'application est faite d'écrans qui CHANGENT
 * quand on les quitte : on rapproche une facture, on valide un lot, on joue
 * les migrations, on déclare une perte. On revient, et l'écran ressort le
 * formulaire rempli, le bouton encore actif, le travail encore à faire.
 * « Le retour en arrière fonctionne comme un contrôle Z partiel. »
 *
 * Ce n'était corrigé qu'écran par écran, avec `RelireAuRetour` posé à la main :
 * dix-sept écrans écrivaient sans l'avoir. Une règle appliquée à un endroit et
 * pas à l'autre ne vaut rien — alors elle est posée UNE fois, dans la mise en
 * page, et vaut pour tout.
 *
 * On note le chemin au premier passage. Si l'on y revient, on redemande la
 * page : `router.refresh()` garde la position de défilement et ne recharge que
 * ce qui a changé. Sur le wifi de l'hôtel, c'est un aller-retour, et ce qui
 * s'affiche est vrai.
 */
export function RelireEnRevenant() {
  const chemin = usePathname();
  const routeur = useRouter();

  useEffect(() => {
    if (!chemin) return;
    const marque = `vu:${chemin}`;
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
  }, [chemin, routeur]);

  return null;
}
