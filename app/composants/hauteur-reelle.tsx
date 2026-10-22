"use client";

import { useEffect } from "react";

/**
 * La vraie hauteur de l'écran, mesurée — pas devinée par une unité CSS.
 *
 * `100dvh` promet de suivre la barre de Safari quand elle se cache ou
 * reparaît, mais sur un vrai iPhone elle se RECALCULE à l'instant précis où
 * le défilement s'arrête — exactement le moment où la barre reprend sa
 * place. Pendant qu'on défile, la barre est cachée et `dvh` vaut la grande
 * valeur : tout semble juste. Dès que le doigt se lève, la barre revient,
 * `dvh` retombe à la petite valeur, et tout ce qui comptait sur elle
 * (hauteur minimale de la page, colonne d'onglets) se redessine d'un coup —
 * le vide sous le bouton réapparaît, ou le bouton recouvre la liste.
 *
 * Deux tentatives l'ont montré : `h-dvh` sur la coque entière, puis
 * `fixed inset-0`, portent toutes les deux ce même défaut parce qu'elles
 * demandent au NAVIGATEUR de recalculer une taille d'écran pendant qu'elle
 * change. La mesure, elle, ne recalcule que quand on lui dit de le faire —
 * au chargement, et sur `resize` (Safari ne déclenche PAS cet événement
 * pendant un simple défilement, seulement quand sa barre finit de bouger).
 * `visualViewport` est l'API faite pour ça : elle existe précisément parce
 * que `window.innerHeight` a les mêmes trous que `dvh` sur ce point.
 *
 * Posé une fois, dans la mise en page : la variable `--h-reelle` est
 * disponible partout, mais seul l'écran qui en a besoin la réclame
 * (`min-h-[var(--h-reelle)]`, `h-[var(--h-reelle)]`) — les autres gardent
 * `min-h-dvh`, qui ne leur a jamais posé ce problème.
 */
export function HauteurReelle() {
  useEffect(() => {
    const mesurer = () => {
      const h = window.visualViewport?.height ?? window.innerHeight;
      document.documentElement.style.setProperty("--h-reelle", `${h}px`);
    };
    mesurer();
    window.visualViewport?.addEventListener("resize", mesurer);
    window.addEventListener("resize", mesurer);
    window.addEventListener("orientationchange", mesurer);
    return () => {
      window.visualViewport?.removeEventListener("resize", mesurer);
      window.removeEventListener("resize", mesurer);
      window.removeEventListener("orientationchange", mesurer);
    };
  }, []);

  return null;
}
