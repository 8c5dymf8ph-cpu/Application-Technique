"use client";

import { useRef, useState } from "react";
import { aujourdhuiISO } from "@/lib/domaine";
import { BoutonEnvoi } from "./bouton-envoi";

/**
 * Corriger ou supprimer un ajustement déjà enregistré — même geste que le
 * crayon d'une entrée : une fenêtre pré-remplie, qui se referme une fois
 * enregistrée pour laisser la fiche là où on l'avait.
 */
export function CorrigerAjustement({
  action,
  supprimerAction,
  mouvementId,
  date,
  dateISO,
  ecart,
  motif,
  commentaire,
  motifs,
}: {
  action: (donnees: FormData) => void | Promise<void>;
  supprimerAction: (donnees: FormData) => void | Promise<void>;
  mouvementId: string;
  date: string;
  dateISO: string;
  ecart: number;
  motif: string | null;
  commentaire: string | null;
  motifs: readonly { v: string; l: string }[];
}) {
  const fenetre = useRef<HTMLDialogElement>(null);
  const [confirmer, setConfirmer] = useState(false);

  return (
    <>
      <button
        type="button"
        onClick={() => {
          setConfirmer(false);
          fenetre.current?.showModal();
        }}
        aria-label="Corriger ou supprimer cet ajustement"
        className="shrink-0 w-8 h-8 rounded-full bg-surface-muted grid place-items-center text-ink-faint"
      >
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
             strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
          <path d="M12 20h9" />
          <path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z" />
        </svg>
      </button>

      <dialog
        ref={fenetre}
        className="m-auto w-[min(94vw,420px)] rounded-card bg-surface p-0 backdrop:bg-black/45"
        onClick={(e) => {
          if (e.target === fenetre.current) fenetre.current?.close();
        }}
      >
        <form
          action={async (donnees) => {
            await action(donnees);
            fenetre.current?.close();
          }}
          className="flex flex-col gap-3 p-5"
        >
          <input type="hidden" name="mouvement_id" value={mouvementId} />
          <div className="flex items-start gap-3">
            <p className="grow font-display font-semibold text-[16.5px] leading-snug">
              Ajustement du {date}
            </p>
            <button
              type="button"
              onClick={() => fenetre.current?.close()}
              aria-label="Fermer"
              className="shrink-0 w-[34px] h-[34px] min-h-0 rounded-lg bg-surface-muted grid place-items-center text-ink-soft"
            >
              <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                   strokeWidth="2" strokeLinecap="round" aria-hidden>
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
            </button>
          </div>

          <label className="flex flex-col gap-1">
            <span className="etiquette">Écart — négatif s’il en manque</span>
            <input
              name="ecart"
              type="number"
              step="0.01"
              inputMode="decimal"
              required
              defaultValue={ecart}
              className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[16px] tabular-nums"
            />
          </label>

          <fieldset className="flex flex-col gap-1.5">
            <legend className="etiquette mb-1.5">Pourquoi&nbsp;?</legend>
            <div className="grid grid-cols-2 gap-2">
              {motifs.map((m) => (
                <label
                  key={m.v}
                  className="rounded-[11px] border border-line bg-surface h-[44px] grid place-items-center text-[13px] cursor-pointer has-[:checked]:border-plum has-[:checked]:bg-plum-soft"
                >
                  <input type="radio" name="motif" value={m.v}
                         defaultChecked={m.v === motif} className="sr-only" />
                  {m.l}
                </label>
              ))}
            </div>
          </fieldset>

          <label className="flex flex-col gap-1">
            <span className="etiquette">Date</span>
            <input
              name="date"
              type="date"
              max={aujourdhuiISO()}
              defaultValue={dateISO}
              className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[16px]"
            />
          </label>

          <input
            name="commentaire"
            autoComplete="off"
            defaultValue={commentaire ?? ""}
            placeholder="Ce qu’il faut savoir (facultatif)"
            className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[15px] placeholder:text-ink-faint"
          />

          <BoutonEnvoi
            pendant="Enregistrement…"
            className="h-[50px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15.5px]"
          >
            Enregistrer
          </BoutonEnvoi>
        </form>

        {/* Supprimer, en deux temps : l'ajustement disparaît de l'historique
            et le stock se recalcule sans lui. */}
        <div className="px-5 pb-5 -mt-1">
          {!confirmer ? (
            <button
              type="button"
              onClick={() => setConfirmer(true)}
              className="w-full h-[44px] rounded-[12px] text-[14px] text-red"
            >
              Supprimer cet ajustement
            </button>
          ) : (
            <form action={supprimerAction} className="flex flex-col gap-2 rounded-card bg-red-soft p-3">
              <input type="hidden" name="mouvement_id" value={mouvementId} />
              <p className="text-[13px] text-red text-pretty leading-snug">
                L’ajustement de {ecart > 0 ? "+" : ""}
                {ecart.toLocaleString("fr-FR")} disparaît, et le stock se recalcule sans lui.
              </p>
              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={() => setConfirmer(false)}
                  className="flex-1 h-[44px] rounded-[11px] bg-surface text-[14px] text-ink-soft"
                >
                  Annuler
                </button>
                <BoutonEnvoi
                  pendant="Suppression…"
                  className="flex-1 h-[44px] rounded-[11px] bg-red text-white text-[14px] font-semibold"
                >
                  Oui, supprimer
                </BoutonEnvoi>
              </div>
            </form>
          )}
        </div>
      </dialog>
    </>
  );
}
