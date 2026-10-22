"use client";

import { useFormStatus } from "react-dom";

/**
 * La case d'une anomalie déclarée : verte, cochée — et qui se décoche.
 *
 * Cocher et décocher doivent SE VOIR. La case se remplit de vert et la coche
 * se trace quand on revient d'un « C'est fait » (`anime`) ; elle se vide et
 * la coche s'efface DÈS l'appui pour décocher, sans attendre la réponse du
 * serveur — sinon on réappuie en croyant que rien ne s'est passé.
 */
export function CaseDeclaree({
  anomalieId,
  action,
  anime,
}: {
  anomalieId: string;
  action: (donnees: FormData) => void | Promise<void>;
  anime: boolean;
}) {
  return (
    <form action={action} className="shrink-0 mt-[1px]">
      <input type="hidden" name="anomalie" value={anomalieId} />
      <Case anime={anime} />
    </form>
  );
}

function Case({ anime }: { anime: boolean }) {
  const { pending } = useFormStatus();
  const etat = pending ? "case-se-vide" : anime ? "case-se-remplit" : "case-remplie";
  return (
    <button
      aria-label="Annuler ma déclaration"
      disabled={pending}
      className={`w-[26px] h-[26px] min-h-0 rounded-[7px] border-2 grid place-items-center ${etat}`}
    >
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#fff"
           strokeWidth="2.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
        <path d="M5 12.5l4.5 4.5L19 7.5" pathLength={1} className="coche" />
      </svg>
    </button>
  );
}
