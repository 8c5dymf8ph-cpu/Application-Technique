"use client";

import { useEffect, useRef, useState } from "react";
import { BoutonEnvoi } from "./bouton-envoi";

/**
 * Le bouton de déclaration, qui dit COMBIEN de lieux partent.
 *
 * On coche quatre chambres de plus et le bouton continuait d'annoncer
 * « Déclarer en 12 » : rien ne disait que les cases avaient été prises en
 * compte, et on rouvrait le dépliant pour vérifier. Il compte donc les cases
 * cochées de son propre formulaire — c'est la seule chose qu'un serveur ne
 * peut pas savoir.
 */
export function BoutonDeclarer({ lieu }: { lieu: string }) {
  const ancre = useRef<HTMLDivElement>(null);
  const [aussi, setAussi] = useState(0);

  useEffect(() => {
    const formulaire = ancre.current?.closest("form");
    if (!formulaire) return;
    const compter = () =>
      setAussi(
        formulaire.querySelectorAll<HTMLInputElement>('input[name="aussi"]:checked').length,
      );
    compter();
    formulaire.addEventListener("change", compter);
    return () => formulaire.removeEventListener("change", compter);
  }, []);

  return (
    <div ref={ancre} className="grow">
      <BoutonEnvoi
        pendant="Déclaration…"
        className="w-full h-[54px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]"
      >
        {aussi === 0 ? `Déclarer en ${lieu}` : `Déclarer dans ${aussi + 1} lieux`}
      </BoutonEnvoi>
    </div>
  );
}
