"use client";

import { useRef, useState } from "react";
import { aujourdhuiISO } from "@/lib/domaine";
import { BoutonEnvoi } from "./bouton-envoi";
import { VoirDocument } from "./fenetre";

/**
 * Corriger le prix et la facture d'une entrée déjà enregistrée.
 *
 * Le prix ne se saisissait qu'au moment de la livraison : une entrée
 * ancienne (reprise) n'en portait aucun, et une entrée du jour sans facture
 * sous la main restait sans prix pour toujours. Il n'y avait donc pas de
 * vrai historique de prix, seulement ce qu'on avait pensé à saisir tout de
 * suite. Un crayon sur chaque entrée ouvre le MÊME genre de formulaire,
 * pré-rempli avec ce qui existe déjà.
 *
 * Une facture déjà jointe se REGARDE depuis ce même écran — pas seulement
 * depuis l'icône du document dans la liste, repliée dès qu'on ouvre le
 * crayon — et se retire d'ici si elle a été jointe par erreur.
 */
export function CorrigerAchat({
  action,
  retirerAction,
  supprimerAction,
  mouvementId,
  date,
  dateISO,
  prixActuel,
  fournisseurs,
  fournisseurActuelId,
  referenceActuelle,
  commentaireActuel,
  factureFichier,
}: {
  action: (donnees: FormData) => void | Promise<void>;
  retirerAction: (donnees: FormData) => void | Promise<void>;
  /** Supprimer la livraison entière — saisie deux fois, ou pour le mauvais produit. */
  supprimerAction: (donnees: FormData) => void | Promise<void>;
  mouvementId: string;
  date: string;
  /** La même date, au format YYYY-MM-DD — pour le champ, qui n'affiche pas le français. */
  dateISO: string;
  prixActuel: number | null;
  fournisseurs: { id: string; nom: string }[];
  fournisseurActuelId: string | null;
  referenceActuelle: string | null;
  commentaireActuel: string | null;
  /** Le fichier déjà joint, s'il y en a un — pour le regarder ou le retirer. */
  factureFichier: string | null;
}) {
  const fenetre = useRef<HTMLDialogElement>(null);
  const [confirmerRetrait, setConfirmerRetrait] = useState(false);
  const [confirmerSuppression, setConfirmerSuppression] = useState(false);
  const dejaJointe = !!factureFichier;

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

          <label className="flex flex-col gap-1">
            <span className="etiquette">Date de livraison</span>
            <input
              name="date"
              type="date"
              max={aujourdhuiISO()}
              defaultValue={dateISO}
              className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[16px]"
            />
          </label>

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
              className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[16px] tabular-nums"
            />
          </label>

          <label className="flex flex-col gap-1">
            <span className="etiquette">Commentaire (facultatif)</span>
            <input
              name="commentaire"
              defaultValue={commentaireActuel ?? ""}
              autoComplete="off"
              placeholder="D’où vient-elle ?"
              className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[15px] placeholder:text-ink-faint"
            />
          </label>

          {/* La facture déjà jointe se regarde ici, sans quitter le crayon. */}
          {dejaJointe && (
            <VoirDocument
              chemin={factureFichier!}
              titre={`Facture · Entrée du ${date}`}
              ariaLabel="Voir la facture déjà jointe"
              className="flex items-center gap-2 h-[42px] px-3 rounded-[11px] bg-plum-soft text-plum text-[13.5px] font-medium self-start"
            >
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                   strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
                <path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z" />
                <path d="M14 3v5h5" />
              </svg>
              Voir la facture déjà jointe
            </VoirDocument>
          )}

          {fournisseurs.length === 0 ? (
            <p className="rounded-card bg-amber-soft px-3.5 py-2.5 text-[12.5px] text-amber text-pretty leading-snug">
              Aucun fournisseur n’est encore enregistré dans l’application : la facture ne peut
              pas se joindre tant qu’il n’y en a pas un. Ajoutez-en un depuis la section
              « Fournisseurs » plus bas — le champ ci-dessous les proposera tous, pas seulement
              celui déjà rattaché à ce produit.
            </p>
          ) : (
            <>
              <div className="grid grid-cols-2 gap-2">
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
                <label className="flex flex-col gap-1">
                  <span className="etiquette">N° de facture (facultatif)</span>
                  <input
                    name="reference"
                    defaultValue={referenceActuelle ?? ""}
                    autoComplete="off"
                    className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[15px]"
                  />
                </label>
              </div>

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
            </>
          )}

          <BoutonEnvoi
            pendant="Enregistrement…"
            className="h-[48px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15px]"
          >
            Enregistrer
          </BoutonEnvoi>
        </form>

        {/* Retirer une facture jointe par erreur — en deux temps, comme
            toute suppression dans l'application. Le prix, lui, ne bouge
            pas : ce sont deux informations distinctes. */}
        {dejaJointe && (
          <div className="px-5 pb-5 -mt-1">
            {!confirmerRetrait ? (
              <button
                type="button"
                onClick={() => setConfirmerRetrait(true)}
                className="text-[12.5px] text-red underline underline-offset-4"
              >
                Retirer cette facture
              </button>
            ) : (
              <form
                action={retirerAction}
                className="rounded-card bg-red-soft px-3.5 py-3 flex flex-col gap-2.5"
              >
                <input type="hidden" name="mouvement_id" value={mouvementId} />
                <p className="text-[12.5px] text-red text-pretty leading-snug">
                  Le fichier et le fournisseur rattachés à cette entrée seront retirés. Le prix
                  reste enregistré.
                </p>
                <div className="flex gap-2">
                  <button
                    type="button"
                    onClick={() => setConfirmerRetrait(false)}
                    className="flex-1 h-[38px] rounded-[10px] bg-surface border border-line text-[12.5px] text-ink-soft"
                  >
                    Annuler
                  </button>
                  <BoutonEnvoi
                    pendant="Retrait…"
                    className="flex-1 h-[38px] rounded-[10px] bg-red text-white text-[12.5px] font-medium"
                  >
                    Oui, retirer
                  </BoutonEnvoi>
                </div>
              </form>
            )}
          </div>
        )}

        {/* Supprimer la livraison entière — saisie deux fois, ou pour le
            mauvais produit. En deux temps, comme toute suppression. */}
        <div className="px-5 pb-5 -mt-1 border-t border-line pt-3.5">
          {!confirmerSuppression ? (
            <button
              type="button"
              onClick={() => setConfirmerSuppression(true)}
              className="text-[12.5px] text-red underline underline-offset-4"
            >
              Supprimer cette livraison
            </button>
          ) : (
            <form
              action={supprimerAction}
              className="rounded-card bg-red-soft px-3.5 py-3 flex flex-col gap-2.5"
            >
              <input type="hidden" name="mouvement_id" value={mouvementId} />
              <p className="text-[12.5px] text-red text-pretty leading-snug">
                Cette entrée du {date} disparaît, avec sa facture si elle n’en couvre pas
                d’autre. Le stock recalculé baisse d’autant : à n’utiliser que pour une saisie en
                trop, jamais pour corriger une quantité — le crayon fait ça.
              </p>
              <div className="flex gap-2">
                <button
                  type="button"
                  onClick={() => setConfirmerSuppression(false)}
                  className="flex-1 h-[38px] rounded-[10px] bg-surface border border-line text-[12.5px] text-ink-soft"
                >
                  Annuler
                </button>
                <BoutonEnvoi
                  pendant="Suppression…"
                  className="flex-1 h-[38px] rounded-[10px] bg-red text-white text-[12.5px] font-medium"
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
