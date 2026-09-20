"use client";

import { useEffect, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import type { Route } from "next";

/**
 * Une recherche qui suit la frappe.
 *
 * Il fallait taper, puis viser « Chercher ». Sur un téléphone tenu d'une main,
 * dans un couloir, c'est un appui de trop — et rien ne bouge tant qu'on ne l'a
 * pas fait, ce qui laisse croire que l'écran ne répond pas.
 *
 * La liste est calculée par le serveur : on ne recharge donc pas à chaque
 * lettre, mais après une courte pause. Le champ, lui, reste réactif : ce que
 * l'on tape s'affiche tout de suite, c'est la liste qui suit.
 */
export function RechercheVive({
  valeur,
  base,
  placeholder,
}: {
  valeur: string;
  /**
   * Le chemin de l'écran. On ne peut pas recevoir une fonction d'un composant
   * serveur — seulement des données —, alors l'adresse se compose ici.
   */
  base: string;
  placeholder: string;
}) {
  const routeur = useRouter();
  const [texte, setTexte] = useState(valeur);
  const premier = useRef(true);

  useEffect(() => {
    // Au premier rendu, la valeur vient de l'adresse : ne pas la réécrire.
    if (premier.current) {
      premier.current = false;
      return;
    }
    const minuteur = setTimeout(() => {
      // `replace` et non `push` : chercher n'est pas naviguer, et le retour ne
      // doit pas repasser par chaque lettre tapée.
      const suite = texte.trim() ? `?q=${encodeURIComponent(texte.trim())}` : "";
      routeur.replace(`${base}${suite}` as Route, { scroll: false });
    }, 250);
    return () => clearTimeout(minuteur);
  }, [texte, base, routeur]);

  return (
    <div className="relative">
      <input
        id="recherche"
        name="q"
        value={texte}
        onChange={(e) => setTexte(e.target.value)}
        autoComplete="off"
        placeholder={placeholder}
        className="carte w-full px-4 pr-11 h-[52px] text-[16px] placeholder:text-ink-faint"
      />
      {texte !== "" && (
        <button
          type="button"
          aria-label="Effacer"
          onClick={() => setTexte("")}
          className="absolute right-1.5 top-1.5 w-11 h-11 grid place-items-center text-ink-faint"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="2" strokeLinecap="round">
            <path d="M6 6l12 12M18 6L6 18" />
          </svg>
        </button>
      )}
    </div>
  );
}
