"use client";

import { useRef } from "react";
import { BoutonEnvoi } from "./bouton-envoi";

/**
 * Corriger le prix et la facture d'une entrée déjà enregistrée.
 *
 * Le prix ne se saisissait qu'au moment de la livraison : une entrée
 * ancienne (reprise) n'en portait aucun, et une entrée du jour sans facture
 * sous la main restait sans prix pour toujours. Il n'y avait donc pas de
 * vrai historique de prix, seulement ce qu'on avait pensé à saisir tout de
 * suite. Un crayon sur chaque entrée ouvre le MÊME genre de formulaire,
 * pré-rempli avec ce qui existe déjà.
 */
export function CorrigerAchat({
  action,
  mouvementId,
  date,
  prixActuel,
  fournisseurs,
  fournisseurActuelId,
  referenceActuelle,
  dejaJointe,
}: {
  action: (donnees: FormData) => void | Promise<void>;
  mouvementId: string;
  date: string;
  prixActuel: number | null;
  fournisseurs: { id: string; nom: string }[];
  fournisseurActuelId: string | null;
  referenceActuelle: string | null;
  dejaJointe: boolean;
}) {
  const fenetre = useRef<HTMLDialogElement>(null);

  return (
    <>
      <button
        type="button"
        onClick={() => fenetre.current?.showModal()}
        aria-label="Corriger le prix ou la facture de cette entrée"
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
        <form action={action} className="flex flex-col gap-3 p-5">
          <input type="hidden" name="mouvement_id" value={mouvementId} />
          <div className="flex items-start gap-3">
            <p className="grow font-display font-semibold text-[16.5px] leading-snug">
              Entrée du {date}
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

          <div className="grid grid-cols-2 gap-2">
            <label className="flex flex-col gap-1">
              <span className="etiquette">Prix payé (unité)</span>
              <input
                name="prix"
                type="number"
                step="0.01"
                min={0}
                inputMode="decimal"
                defaultValue={prixActuel ?? undefined}
                placeholder="—"
                className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[15px] tabular-nums"
              />
            </label>
            <label className="flex flex-col gap-1">
              <span className="etiquette">Fournisseur</span>
              <select
                name="fournisseur"
                defaultValue={fournisseurActuelId ?? ""}
                className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[14px]"
              >
                <option value="">Aucun</option>
                {fournisseurs.map((f) => (
                  <option key={f.id} value={f.id}>
                    {f.nom}
                  </option>
                ))}
              </select>
            </label>
          </div>

          <label className="flex flex-col gap-1">
            <span className="etiquette">N° de facture (facultatif)</span>
            <input
              name="reference"
              defaultValue={referenceActuelle ?? ""}
              autoComplete="off"
              className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[15px]"
            />
          </label>

          <label className="flex flex-col gap-1">
            <span className="etiquette">
              {dejaJointe ? "Remplacer la facture (facultatif)" : "Facture (PDF ou photo)"}
            </span>
            <input
              name="facture"
              type="file"
              accept="application/pdf,image/*"
              className="text-[13.5px] file:mr-3 file:h-[38px] file:px-3 file:rounded-[10px] file:border-0 file:bg-surface-muted file:text-[13px]"
            />
          </label>
          <p className="text-[11.5px] text-ink-faint text-pretty leading-snug -mt-1.5">
            Jointe seulement si un fournisseur ET un fichier sont donnés tous les deux
            {dejaJointe && " — sans nouveau fichier, la facture déjà jointe est gardée"}.
          </p>

          <BoutonEnvoi
            pendant="Enregistrement…"
            className="h-[48px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15px]"
          >
            Enregistrer
          </BoutonEnvoi>
        </form>
      </dialog>
    </>
  );
}
