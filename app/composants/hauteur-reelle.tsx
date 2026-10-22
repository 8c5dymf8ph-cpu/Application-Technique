"use client";

import { useEffect, useRef } from "react";

/**
 * La vraie hauteur de l'écran, mesurée — pas devinée par une unité CSS, et
 * FIGÉE une fois posée.
 *
 * Premier essai : mettre à jour `--h-reelle` sur chaque `resize` de
 * `visualViewport`. Faux calcul — c'est exactement ce que fait `dvh`, pour
 * la même raison. La barre de Safari qui se cache en défilant vers le bas
 * et qui REVIENT en défilant vers le haut déclenche elle aussi ce
 * `resize`, en continu pendant son animation : « ce n'est pas figé, donc
 * l'espace réapparaît » dès qu'on remonte un peu dans la liste.
 *
 * Et prendre la DERNIÈRE valeur mesurée a un second défaut, pire que le
 * premier : si elle est mesurée pendant que la barre est cachée (la
 * grande valeur), tout ce qui s'appuie dessus — la colonne d'étages —
 * devient plus haut que l'écran RÉELLEMENT visible une fois la barre
 * revenue. Un élément `sticky` plus haut que le viewport ne peut pas
 * montrer sa fin tant qu'il est collé : ses derniers onglets (sous-sol)
 * restent hors champ jusqu'à ce que le défilement atteigne le bas de la
 * liste et le décolle.
 *
 * La bonne mesure est donc double : on observe un court instant après le
 * montage (le temps que la barre de Safari se stabilise), on retient la
 * PLUS PETITE valeur vue pendant cette fenêtre — jamais trop haut, au pire
 * un peu de place en plus quand la barre est cachée — puis on FIGE
 * `--h-reelle` et on arrête d'écouter la hauteur. On ne la reprend que sur
 * un vrai changement, signalé par la LARGEUR qui bouge — une rotation, un
 * iPad qui change de disposition — jamais un simple défilement, qui ne
 * change que la hauteur.
 */
export function HauteurReelle() {
  const largeurConnue = useRef<number | null>(null);

  useEffect(() => {
    let min = Infinity;
    let minuteur: ReturnType<typeof setTimeout> | null = null;

    const figer = () => {
      document.documentElement.style.setProperty("--h-reelle", `${min}px`);
      largeurConnue.current = window.innerWidth;
    };

    const observer = () => {
      const h = window.visualViewport?.height ?? window.innerHeight;
      if (h < min) min = h;
      if (minuteur) clearTimeout(minuteur);
      // 600 ms sans nouvelle mesure plus petite : la barre a fini de bouger.
      minuteur = setTimeout(figer, 600);
    };

    const auResize = () => {
      // Une rotation ou un changement de disposition change la LARGEUR ;
      // la barre de Safari, elle, ne touche qu'à la hauteur. Ignorer l'un
      // pour ne réagir qu'à l'autre évite de reprendre la mesure à chaque
      // simple défilement.
      if (largeurConnue.current !== null && window.innerWidth === largeurConnue.current) {
        return;
      }
      min = Infinity;
      observer();
    };

    observer();
    window.visualViewport?.addEventListener("resize", auResize);
    window.addEventListener("resize", auResize);
    window.addEventListener("orientationchange", auResize);
    return () => {
      if (minuteur) clearTimeout(minuteur);
      window.visualViewport?.removeEventListener("resize", auResize);
      window.removeEventListener("resize", auResize);
      window.removeEventListener("orientationchange", auResize);
    };
  }, []);

  return null;
}
