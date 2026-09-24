"use client";

import { useRef } from "react";
import type { Message } from "./fil";
import { Fil } from "./fil";
import { Vignettes } from "./photos";

/** Ce qu'une anomalie porte, en plus de ses mots. */
export type Contexte = {
  description: string;
  emplacement: string;
  etage?: string | null;
  statut?: { libelle: string; fond: string; texte: string } | null;
  depuis?: string | null;
  constate_par?: string | null;
  /** Les photos, par moment : au constat et après intervention. */
  constat?: string[];
  apres?: string[];
  /** Qui est venu, quand, avec quoi, et ce que la gouvernante en a dit. */
  passages?: string[];
};

/**
 * La bulle de commentaires, cliquable.
 *
 * Elle affichait un nombre et rien d'autre : on voyait qu'il y avait eu des
 * mots, sans pouvoir les lire. Les ouvrir dans un écran à part ferait perdre
 * la place où l'on était — pour trois lignes, une fenêtre suffit.
 *
 * `<dialog>` est natif : pas de bibliothèque, et la touche Échap referme.
 */
export function ApercuFil({
  messages,
  eteint = false,
  libelle,
  fiche,
  contexte,
}: {
  messages: Message[];
  eteint?: boolean;
  /**
   * Le mot sur le bouton, à la place du compteur.
   *
   * « Le fil » se lit là où la bulle n'aurait pas de sens — au bout d'une
   * ligne de récapitulatif, par exemple. Et le bouton reste là même sans
   * commentaire : remplacer « Le fil » par un lien « La fiche » déplaçait la
   * cible d'une ligne à l'autre selon qu'il y avait eu des mots ou non, et on
   * ne savait plus où appuyer.
   */
  libelle?: string;
  /** Vers quoi renvoyer pour CORRIGER : la fenêtre montre, elle ne modifie pas. */
  fiche?: string;
  /**
   * Tout ce que la fiche montrait.
   *
   * « Le fil doit tout inclure, et en pop-up. Dès qu'on peut éviter des pages
   * inutiles, on essaye. » Lire ce qui s'est passé sur une anomalie ne vaut
   * pas un écran de plus : on y va, on lit trois lignes, on revient — et le
   * retour ne ramène pas toujours là où on avait appuyé. La fenêtre porte
   * donc l'anomalie entière ; la FICHE reste pour ce qui s'écrit, corriger et
   * ajouter au fil.
   */
  contexte?: Contexte;
}) {
  const fenetre = useRef<HTMLDialogElement>(null);
  // Sans libellé, la bulle chiffrée ne s'affiche que s'il y a des mots.
  if (messages.length === 0 && !libelle) return null;

  return (
    <>
      <button
        type="button"
        onClick={() => fenetre.current?.showModal()}
        aria-label={
          messages.length === 0
            ? "Le fil — rien n’a encore été écrit"
            : `Lire ${messages.length} commentaire${messages.length > 1 ? "s" : ""}`
        }
        className={`h-[34px] pl-2 pr-2.5 rounded-lg flex items-center gap-1.5 text-[14px] font-medium tabular-nums shrink-0 ${
          eteint ? "text-ink-faint bg-surface-muted" : "text-plum bg-plum-soft"
        }`}
      >
        <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor"
             strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
          <path d="M20 12.5c0 3.9-3.6 7-8 7a9.3 9.3 0 01-2.7-.4L4.5 20.5l1.2-3.4A6.7 6.7 0 014 12.5c0-3.9 3.6-7 8-7s8 3.1 8 7z" />
        </svg>
        {libelle ?? messages.length}
      </button>

      <dialog
        ref={fenetre}
        className="m-auto w-[min(92vw,26rem)] rounded-card bg-surface p-0 backdrop:bg-ink/40"
        onClick={(e) => {
          // Un appui à côté referme : c'est le geste attendu d'une fenêtre.
          if (e.target === fenetre.current) fenetre.current?.close();
        }}
      >
        <div className="flex flex-col gap-3 p-4 max-h-[75vh] overflow-y-auto">
          <div className="flex items-center justify-between">
            <span className="etiquette">
              {contexte ? "L’anomalie" : "Ce qui a été dit"}
            </span>
            <button
              type="button"
              onClick={() => fenetre.current?.close()}
              aria-label="Fermer"
              className="w-10 h-10 -mr-2 grid place-items-center text-ink-faint"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                   strokeWidth="2" strokeLinecap="round">
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
            </button>
          </div>
          {/* Ce qu'est l'anomalie, avant ce qui s'est dit dessus. Une
              anomalie ne se montre jamais séparée de son lieu (règle 16bis). */}
          {contexte && (
            <div className="flex flex-col gap-2.5">
              <div className="flex items-baseline gap-2.5">
                <span className="shrink-0 px-2 py-0.5 rounded-md bg-plum-soft text-plum text-[12.5px] font-medium">
                  {contexte.emplacement}
                </span>
                {contexte.etage && (
                  <span className="text-[11.5px] text-ink-faint">{contexte.etage}</span>
                )}
              </div>
              <p className="font-display font-semibold text-[16.5px] leading-snug text-pretty">
                {contexte.description}
              </p>
              <p className="flex flex-wrap items-center gap-2 text-[11.5px]">
                {contexte.statut && (
                  <span
                    className={`px-2 py-0.5 rounded-md ${contexte.statut.fond} ${contexte.statut.texte}`}
                  >
                    {contexte.statut.libelle}
                  </span>
                )}
                <span className="text-ink-faint">
                  {contexte.constate_par ? `${contexte.constate_par}, ` : ""}
                  {contexte.depuis}
                </span>
              </p>

              {(contexte.constat?.length ?? 0) > 0 && (
                <Vignettes chemins={contexte.constat!} titre="Au constat" ton="text-blue" />
              )}
              {(contexte.apres?.length ?? 0) > 0 && (
                <Vignettes
                  chemins={contexte.apres!}
                  titre="Après intervention"
                  ton="text-green"
                />
              )}

              {(contexte.passages?.length ?? 0) > 0 && (
                <div className="flex flex-col gap-1 border-t border-line pt-2.5">
                  {contexte.passages!.map((t, i) => (
                    <p
                      key={i}
                      className="text-[12px] text-ink-soft text-pretty border-l-2 border-line pl-2.5"
                    >
                      {t}
                    </p>
                  ))}
                </div>
              )}

              <span className="etiquette border-t border-line pt-2.5">
                Ce qui a été dit
              </span>
            </div>
          )}

          {messages.length > 0 ? (
            <Fil messages={messages} />
          ) : (
            <p className="text-[13.5px] text-ink-faint text-pretty py-2">
              Rien n’a encore été écrit ici.
            </p>
          )}
          {fiche && (
            <a
              href={fiche}
              className="text-[12.5px] text-plum underline underline-offset-4 self-start"
            >
              {contexte ? "Ajouter un mot, une photo, corriger" : "Ouvrir la fiche"}
            </a>
          )}
        </div>
      </dialog>
    </>
  );
}
