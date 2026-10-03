"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

/**
 * Un écran qui se regarde sans jamais le quitter ne se met jamais à jour.
 *
 * `RelireEnRevenant` (posé dans la mise en page) redemande la page quand on
 * y REVIENT — un autre écran, un onglet qu'on retrouve, un téléphone qu'on
 * déverrouille. Mais « Derniers passages » se laisse ouvert EXPRÈS, à
 * côté d'un autre écran où l'on agit (un autre onglet, une autre fenêtre) :
 * aucun des deux signaux de `RelireEnRevenant` ne se déclenche tant qu'on
 * ne quitte jamais CETTE page-là. Un passage rendu ailleurs n'apparaît donc
 * qu'au prochain vrai aller-retour.
 *
 * Un aller-retour de plus sur le wifi de l'hôtel ne coûte rien ; un écran
 * de suivi qui ment pendant qu'on le regarde, si. Posé sur un seul écran —
 * celui qu'on laisse ouvert pour surveiller — pas sur toute l'application.
 */
export function RafraichitPeriodiquement({ secondes = 30 }: { secondes?: number }) {
  const routeur = useRouter();

  useEffect(() => {
    const id = setInterval(() => routeur.refresh(), secondes * 1000);
    return () => clearInterval(id);
  }, [routeur, secondes]);

  return null;
}
