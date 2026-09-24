"use client";

import { useRef } from "react";
import { BoutonEnvoi } from "./bouton-envoi";

/**
 * Ajouter au catalogue le libellé qui manque — dans une fenêtre, et APRÈS la
 * liste.
 *
 * L'encadré tenait six lignes et s'ouvrait AVANT les résultats : on tapait
 * trois lettres et on lisait une explication sur les récurrences au lieu de
 * voir ce que le catalogue proposait. Or on ne crée qu'après avoir cherché et
 * n'avoir rien trouvé — c'est le dernier geste, pas le premier.
 *
 * Un bouton discret, donc, sous la liste, et la fenêtre porte le formulaire.
 * Le métier arrive sur « Technique », qui est le métier général de l'hôtel et
 * non un rangement au hasard : Plomberie, Électrique et Achats sont les
 * spécialités, Technique est le reste. Le commentaire est là aussi, parce que
 * c'est en créant le libellé qu'on a en tête ce que le mot ne dit pas.
 */
export function CreerLibelle({
  action,
  types,
  defaut,
  aucunResultat,
}: {
  action: (donnees: FormData) => void | Promise<void>;
  types: { id: string; nom: string }[];
  /** Ce qui a été tapé dans la recherche : le libellé part de là. */
  defaut: string;
  aucunResultat: boolean;
}) {
  const fenetre = useRef<HTMLDialogElement>(null);
  // Le métier général de l'hôtel, s'il existe. Sinon aucun choix par défaut :
  // mieux vaut demander que ranger au hasard.
  const general = types.find((t) => t.nom.toLowerCase().startsWith("technique"));

  return (
    <>
      <button
        type="button"
        onClick={() => fenetre.current?.showModal()}
        className={`self-start h-[42px] px-3.5 rounded-pill border text-[13.5px] flex items-center gap-2 ${
          aucunResultat
            ? "border-plum bg-plum-soft text-plum"
            : "border-line bg-surface text-ink-soft"
        }`}
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
             strokeWidth="2.2" strokeLinecap="round" aria-hidden>
          <path d="M12 5v14M5 12h14" />
        </svg>
        {aucunResultat ? "Créer ce libellé" : "Rien de tout ça ?"}
      </button>

      <dialog
        ref={fenetre}
        className="m-auto w-[min(94vw,430px)] rounded-card bg-surface p-0 backdrop:bg-black/45"
        onClick={(e) => {
          if (e.target === fenetre.current) fenetre.current?.close();
        }}
      >
        <form action={action} className="flex flex-col gap-3 p-5">
          <div className="flex items-start gap-3">
            <p className="grow font-display font-semibold text-[16.5px] leading-snug">
              Ajouter au catalogue
            </p>
            <button
              type="button"
              onClick={() => fenetre.current?.close()}
              aria-label="Fermer"
              className="shrink-0 w-[34px] h-[34px] rounded-lg bg-surface-muted grid place-items-center text-ink-soft"
            >
              <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                   strokeWidth="2" strokeLinecap="round" aria-hidden>
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
            </button>
          </div>

          <p className="text-[12.5px] text-ink-soft text-pretty leading-snug">
            La fois suivante, le même problème portera le même mot — c’est ce qui permet de
            compter les récurrences.
          </p>

          {/* Le libellé se corrige avant d'entrer au catalogue : ce qu'on a
              tapé pour chercher n'est pas toujours ce qu'on veut y laisser
              pour toujours. */}
          <label className="flex flex-col gap-1">
            <span className="etiquette">Le libellé, tel qu’il restera</span>
            <input
              name="libelle"
              defaultValue={defaut}
              autoComplete="off"
              required
              minLength={3}
              className="h-[48px] rounded-[12px] border border-line px-3 bg-surface text-[16px]"
            />
          </label>

          <div className="grid grid-cols-2 gap-2">
            <label className="flex flex-col gap-1">
              <span className="etiquette">Métier</span>
              <select
                name="type"
                defaultValue={general?.id ?? ""}
                required
                className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[14.5px]"
              >
                <option value="" disabled>
                  Choisir
                </option>
                {types.map((t) => (
                  <option key={t.id} value={t.id}>
                    {t.nom}
                  </option>
                ))}
                <option value="aucun">Aucun en particulier</option>
              </select>
            </label>
            <label className="flex flex-col gap-1">
              <span className="etiquette">Ça presse ?</span>
              <select
                name="priorite"
                defaultValue="normale"
                className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[14.5px]"
              >
                <option value="basse">Quand ce sera possible</option>
                <option value="normale">Normale</option>
                <option value="haute">Prioritaire</option>
                <option value="urgente">Urgent</option>
              </select>
            </label>
          </div>

          {/* Le commentaire se saisit ICI : c'est en créant le libellé qu'on a
              en tête ce que le mot ne dira jamais. Il suit jusqu'à la
              déclaration, sans être retapé. */}
          <label className="flex flex-col gap-1">
            <span className="etiquette">Commentaire (facultatif)</span>
            <textarea
              name="mot"
              rows={3}
              placeholder="Ce qu’il faut savoir…"
              className="rounded-[12px] border border-line px-3 py-2.5 bg-surface text-[15px] leading-snug resize-none placeholder:text-ink-faint"
            />
          </label>

          <BoutonEnvoi
            pendant="Ajout…"
            className="h-[48px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15px]"
          >
            Ajouter et déclarer ici
          </BoutonEnvoi>
        </form>
      </dialog>
    </>
  );
}
