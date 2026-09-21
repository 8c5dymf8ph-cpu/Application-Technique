"use client";

import { useRouter } from "next/navigation";
import type { Route } from "next";
import { profondeur } from "./parcours";

/**
 * Le retour.
 *
 * Chaque écran désignait un parent écrit en dur. On consultait le fil d'une
 * ancienne intervention depuis l'historique d'une chambre, et le retour
 * renvoyait à l'historique complet de cette chambre — pas à l'endroit d'où
 * l'on venait. D'autres écrans ramenaient à l'accueil alors que trois pages
 * s'étaient ouvertes avant.
 *
 * On revient donc **d'où l'on vient**, comme la flèche du navigateur. Le
 * parent ne sert plus que de filet : ouverture directe, lien partagé,
 * application lancée depuis l'écran d'accueil du téléphone — là, il n'y a rien
 * derrière, et repartir en arrière ferait sortir de l'application.
 *
 * Savoir s'il y a quelque chose derrière est le travail de `Parcours`, qui
 * compte nos écrans. Les deux indices employés avant — `history.length` et
 * `document.referrer` — n'y répondaient pas : voir le commentaire là-bas.
 */
export function Retour({ vers, classe }: { vers: Route; classe: string }) {
  const routeur = useRouter();

  function revenir() {
    if (profondeur() > 0) routeur.back();
    else routeur.push(vers);
  }

  return (
    <button type="button" onClick={revenir} aria-label="Retour" className={classe}>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff"
           strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
        <path d="M15 5l-7 7 7 7" />
      </svg>
    </button>
  );
}
