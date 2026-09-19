"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import type { Route } from "next";

/**
 * Où en était l'historique de l'onglet quand on est entré dans l'application.
 *
 * `history.length` ne dit pas ce qui nous appartient : un onglet ouvert sur
 * une page blanche, puis sur un lien partagé, en compte déjà deux. Revenir en
 * arrière sortirait alors de l'application. On retient donc le point de
 * départ, et on ne revient que sur ce qu'on a soi-même empilé.
 */
const DEPART = "retour:depart";

function depart(): number {
  try {
    const garde = sessionStorage.getItem(DEPART);
    if (garde !== null) return Number(garde);
    sessionStorage.setItem(DEPART, String(window.history.length));
    return window.history.length;
  } catch {
    // Navigation privée, stockage refusé : on s'en tient au filet.
    return Number.POSITIVE_INFINITY;
  }
}

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
 */
export function Retour({ vers, classe }: { vers: Route; classe: string }) {
  const routeur = useRouter();

  // Le point de départ se note au premier écran affiché, pas au premier clic :
  // sinon il vaudrait déjà la profondeur atteinte.
  useEffect(() => {
    depart();
  }, []);

  function revenir() {
    // `document.referrer` ne bouge pas quand Next navigue côté client : il
    // garde la valeur du dernier chargement complet, souvent vide. S'en servir
    // comme preuve d'une navigation interne renverrait toujours au filet.
    // On ne s'en sert donc que pour écarter le cas inverse : arriver d'un
    // autre site, où revenir en arrière ferait sortir de l'application.
    const ref = document.referrer;
    const vientDAilleurs = ref !== "" && !ref.startsWith(window.location.origin);
    if (!vientDAilleurs && window.history.length > depart()) routeur.back();
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
