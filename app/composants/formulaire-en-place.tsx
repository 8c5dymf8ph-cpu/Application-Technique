"use client";

import { useRouter, usePathname } from "next/navigation";
import type { Route } from "next";

/**
 * Un `<form method="get">` qui reste sur place.
 *
 * Un formulaire GET natif navigue vraiment à chaque envoi — une entrée
 * d'historique par recherche, par période choisie. Comme les pastilles de
 * `Filtres` ou `MenuFiltre` : revenir en arrière ne sortait pas de l'écran,
 * il rejouait chaque essai précédent un par un. Interceptée, la soumission
 * pose la même adresse en `replace` : elle affine ce qu'on regarde, elle ne
 * change pas d'écran.
 *
 * Tous les champs du formulaire (y compris les champs cachés) deviennent des
 * paramètres de l'adresse — le même contrat qu'un `<form method="get">`
 * natif, juste sans la navigation.
 */
export function FormulaireEnPlace({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  const routeur = useRouter();
  const chemin = usePathname();
  return (
    <form
      className={className}
      onSubmit={(e) => {
        e.preventDefault();
        const p = new URLSearchParams();
        for (const [nom, valeur] of new FormData(e.currentTarget).entries()) {
          if (typeof valeur === "string" && valeur) p.set(nom, valeur);
        }
        const suite = p.toString();
        routeur.replace(`${chemin}${suite ? `?${suite}` : ""}` as Route, { scroll: false });
      }}
    >
      {children}
    </form>
  );
}
