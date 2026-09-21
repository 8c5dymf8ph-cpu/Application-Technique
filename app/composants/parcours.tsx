"use client";

import { useEffect, useRef } from "react";
import { usePathname } from "next/navigation";

/**
 * Combien de NOS écrans sont derrière celui qu'on regarde.
 *
 * Le retour avait besoin de répondre à une seule question : « y a-t-il un de
 * nos écrans derrière ? » Il y répondait avec deux indices qui ne valent rien.
 *
 * `history.length` ne dit pas ce qui nous appartient : un onglet ouvert sur
 * une page de démarrage, puis sur un lien, en compte déjà deux.
 *
 * `document.referrer` est pire : il ne change JAMAIS pendant une navigation
 * Next — il garde la valeur du dernier chargement complet. Arriver une fois
 * par un lien reçu dans un message suffisait à le fixer sur l'origine du
 * message pour toute la session : chaque retour, ensuite, poussait le parent
 * écrit en dur au lieu de revenir. Depuis le fil d'une anomalie, on se
 * retrouvait sur l'historique d'un lieu, puis sur son écran de déclaration —
 * deux écrans de suite qui n'étaient pas ceux qu'on venait de quitter.
 *
 * On compte donc nous-mêmes. Trois gestes, trois signatures :
 *
 * - **avancer** (`push`) : `history.length` grandit ;
 * - **remplacer** (`replace`, le choix d'un étage) : elle ne bouge pas ;
 * - **revenir** (`back`) : elle ne bouge pas non plus, mais `popstate` a eu
 *   lieu juste avant.
 *
 * Le compteur vit dans `sessionStorage` : il survit à un rechargement et
 * s'efface en fermant l'onglet, ce qui est exactement sa durée de vie utile.
 */
const PROFONDEUR = "parcours:profondeur";
const LONGUEUR = "parcours:longueur";

function lire(cle: string): number | null {
  try {
    const v = sessionStorage.getItem(cle);
    return v === null ? null : Number(v);
  } catch {
    // Navigation privée, stockage refusé.
    return null;
  }
}

function ecrire(cle: string, valeur: number): void {
  try {
    sessionStorage.setItem(cle, String(valeur));
  } catch {
    /* Rien à faire : le retour s'en tiendra au parent. */
  }
}

/**
 * Y a-t-il un de nos écrans derrière ?
 *
 * Quand le stockage est refusé, on répond non : pousser le parent est un
 * moindre mal — on reste dans l'application, alors qu'un `back()` à tort en
 * sortirait.
 */
export function profondeur(): number {
  return lire(PROFONDEUR) ?? 0;
}

/**
 * Le compteur, posé une fois pour toute l'application.
 *
 * Il doit voir CHAQUE changement d'écran, y compris ceux des écrans qui n'ont
 * pas de bouton retour : sa place est donc dans la mise en page, pas dans
 * l'en-tête.
 */
export function Parcours() {
  const chemin = usePathname();
  const revenu = useRef(false);
  const dernier = useRef<string | null>(null);

  useEffect(() => {
    const retour = () => {
      revenu.current = true;
    };
    window.addEventListener("popstate", retour);
    return () => window.removeEventListener("popstate", retour);
  }, []);

  useEffect(() => {
    // Le premier écran de la session est la racine : rien derrière lui.
    if (lire(PROFONDEUR) === null) {
      ecrire(PROFONDEUR, 0);
      ecrire(LONGUEUR, window.history.length);
      dernier.current = chemin;
      return;
    }

    // Un rechargement rejoue cet effet sur le même écran : rien n'a bougé.
    if (dernier.current === null && lire(LONGUEUR) === window.history.length) {
      dernier.current = chemin;
      return;
    }
    if (dernier.current === chemin) return;
    dernier.current = chemin;

    const avant = lire(PROFONDEUR) ?? 0;
    const longueur = lire(LONGUEUR) ?? window.history.length;

    if (revenu.current) {
      revenu.current = false;
      ecrire(PROFONDEUR, Math.max(0, avant - 1));
    } else if (window.history.length > longueur) {
      // Le navigateur plafonne l'historique (50 entrées) : au-delà, un pas en
      // avant ne se voit plus. Le retour redeviendra prudent, jamais faux.
      ecrire(PROFONDEUR, avant + 1);
    }
    // Sinon : un remplacement. On reste au même endroit du parcours.
    ecrire(LONGUEUR, window.history.length);
  }, [chemin]);

  return null;
}
