"use client";

import { useRef, useState } from "react";
import { PhotoProduit } from "./photo-produit";
import { ChampCommentaire } from "./fil";
import { ChampPhotos } from "./photos";
import { BoutonEnvoi } from "./bouton-envoi";

export type ProduitDisponible = {
  id: string;
  designation: string;
  code: string;
  stock: number;
  photos: string[];
};

/**
 * Déclarer le matériel EN PLACE, sans quitter la liste.
 *
 * Avant : cocher une anomalie menait vers un écran à part, où choisir un
 * article rechargeait la page à chaque appui (le choix voyageait dans
 * l'adresse, `pris=id~qte,id~qte`). Ça marchait, mais ce n'était pas rapide —
 * et ce n'est pas ce qu'on cherchait : « ajouter un produit » doit ouvrir un
 * pop-up, pas naviguer.
 *
 * La sélection en cours vit donc en état React, le temps de l'édition — rien
 * n'est écrit avant « C'est fait ». La LISTE des articles proposés, elle,
 * vient du serveur une seule fois, à l'ouverture de la ligne (déjà triée :
 * ce qui a servi pour ce problème, puis ce qui recoupe ses mots) ; chercher
 * dans le pop-up ne fait que filtrer ce qui est déjà là, sans aller-retour —
 * c'est ce qui rend le pop-up instantané.
 */
export function EditeurMateriel({
  anomalieId,
  produits,
  action,
}: {
  anomalieId: string;
  produits: ProduitDisponible[];
  action: (donnees: FormData) => void;
}) {
  const [choisis, setChoisis] = useState<{ id: string; qte: number }[]>([]);
  const [recherche, setRecherche] = useState("");
  const dialogue = useRef<HTMLDialogElement>(null);

  const parId = new Map(produits.map((p) => [p.id, p]));
  const idsChoisis = new Set(choisis.map((c) => c.id));

  const ajouter = (id: string) => {
    setChoisis((c) => (c.some((e) => e.id === id) ? c : [...c, { id, qte: 1 }]));
    setRecherche("");
    dialogue.current?.close();
  };
  const retirer = (id: string) => setChoisis((c) => c.filter((e) => e.id !== id));
  const changerQte = (id: string, delta: number) =>
    setChoisis((c) =>
      c.map((e) => {
        if (e.id !== id) return e;
        const stock = parId.get(id)?.stock ?? 99;
        return { ...e, qte: Math.max(1, Math.min(stock, e.qte + delta)) };
      }),
    );

  // La recherche ne fait QUE filtrer ce qui est déjà en main : la liste
  // entière des produits actifs est déjà là, triée par le serveur. Un
  // technicien qui tape « flex » doit voir « Flexible de douche » même si ce
  // n'est pas parmi les tout premiers proposés.
  const terme = recherche.trim().toLowerCase();
  const proposes = produits.filter(
    (p) =>
      !idsChoisis.has(p.id) &&
      (terme === "" ||
        p.designation.toLowerCase().includes(terme) ||
        p.code.toLowerCase().includes(terme)),
  );

  return (
    <form action={action} className="flex flex-col gap-3">
      <input type="hidden" name="anomalie_id" value={anomalieId} />
      <input type="hidden" name="articles" value={JSON.stringify(choisis)} />

      {choisis.length > 0 && (
        <ul className="flex flex-col gap-2">
          {choisis.map((e) => {
            const p = parId.get(e.id);
            if (!p) return null;
            return (
              <li key={e.id} className="carte px-3.5 py-3 flex flex-col gap-2.5">
                <div className="flex items-center gap-3.5">
                  <PhotoProduit photos={p.photos} designation={p.designation} taille={76} />
                  <span className="flex flex-col grow min-w-0">
                    <span className="text-[15.5px] font-display font-semibold leading-snug text-pretty">
                      {p.designation}
                    </span>
                    <span className="text-[13px] text-ink-faint text-pretty">
                      {p.code} · reste {p.stock} en réserve
                    </span>
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="flex items-center gap-1 grow">
                    <button
                      type="button"
                      onClick={() => changerQte(e.id, -1)}
                      aria-label="Un de moins"
                      disabled={e.qte <= 1}
                      className="w-10 h-10 rounded-[10px] bg-surface-muted grid place-items-center text-[19px] disabled:opacity-35"
                    >
                      −
                    </button>
                    <span className="w-7 text-center font-display font-semibold text-[17px] tabular-nums">
                      {e.qte}
                    </span>
                    <button
                      type="button"
                      onClick={() => changerQte(e.id, 1)}
                      aria-label="Un de plus"
                      disabled={e.qte >= p.stock}
                      className="w-10 h-10 rounded-[10px] bg-surface-muted grid place-items-center text-[19px] disabled:opacity-35"
                    >
                      +
                    </button>
                  </span>
                  <button
                    type="button"
                    onClick={() => retirer(e.id)}
                    className="h-11 shrink-0 px-3.5 rounded-[11px] bg-surface-muted flex items-center gap-2 text-[13.5px] text-ink-soft"
                  >
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#4F4B6B"
                         strokeWidth="2.2" strokeLinecap="round">
                      <path d="M6 12h12" />
                    </svg>
                    Retirer
                  </button>
                </div>
              </li>
            );
          })}
        </ul>
      )}

      <button
        type="button"
        onClick={() => dialogue.current?.showModal()}
        className="carte px-4 py-3 text-[15px] text-plum flex items-center gap-2.5"
      >
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
             strokeWidth="2.2" strokeLinecap="round" className="shrink-0">
          <path d="M6 12h12" /><path d="M12 6v12" />
        </svg>
        {choisis.length === 0 ? "Ajouter un produit" : "Ajouter un autre produit"}
      </button>

      {/* Le pop-up : il s'ouvre et se referme sans jamais recharger la
          page — la liste et la recherche sont déjà en mémoire. */}
      <dialog
        ref={dialogue}
        onClose={() => setRecherche("")}
        onClick={(ev) => {
          if (ev.target === dialogue.current) dialogue.current?.close();
        }}
        className="backdrop:bg-black/60 bg-transparent p-0 m-auto w-full max-w-md max-h-[88dvh]"
      >
        <div className="bg-surface rounded-card overflow-hidden flex flex-col max-h-[88dvh]">
          <div className="px-4 py-3 flex items-center gap-3 border-b border-line shrink-0">
            <span className="grow min-w-0 font-display font-semibold text-[15px]">
              Ajouter un produit
            </span>
            <button
              type="button"
              onClick={() => dialogue.current?.close()}
              aria-label="Fermer"
              className="w-9 h-9 shrink-0 rounded-[10px] bg-surface-muted grid place-items-center"
            >
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#4F4B6B"
                   strokeWidth="2.2" strokeLinecap="round">
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
            </button>
          </div>
          <div className="px-4 pt-3 pb-2 shrink-0">
            <input
              autoFocus
              value={recherche}
              onChange={(e) => setRecherche(e.target.value)}
              placeholder="Nom ou code…"
              autoComplete="off"
              className="carte w-full px-4 h-[46px] text-[16px] placeholder:text-ink-faint"
            />
          </div>
          {/* Fluide, sans bouton « voir plus » : un défilement natif, borné
              à sa propre zone, sur ce qui est déjà en mémoire. `min-h-0` est
              nécessaire : sans lui, un enfant flex avec overflow-y-auto ne
              se borne pas à l'espace restant, il grandit avec son contenu. */}
          <ul className="flex-1 min-h-0 flex flex-col gap-1.5 px-4 pb-4 overflow-y-auto overscroll-contain">
            {proposes.length === 0 && (
              <li className="py-6 text-[13.5px] text-ink-faint text-center">
                Rien qui corresponde à « {recherche} ».
              </li>
            )}
            {proposes.map((p) => {
              const epuise = p.stock <= 0;
              const nom_ = (
                <span className="flex flex-col grow min-w-0">
                  <span className="text-[15.5px] font-display font-semibold leading-snug text-pretty">
                    {p.designation}
                  </span>
                  <span className={`text-[13px] ${epuise ? "text-red" : "text-ink-faint"}`}>
                    {epuise ? "épuisé — rien en réserve" : `reste ${p.stock} en réserve`}
                  </span>
                </span>
              );
              return (
                <li
                  key={p.id}
                  className={`px-3 py-2.5 rounded-card bg-surface-muted border border-line flex items-center gap-3 ${
                    epuise ? "opacity-55" : ""
                  }`}
                >
                  <PhotoProduit photos={p.photos} designation={p.designation} taille={76} />
                  {epuise ? (
                    nom_
                  ) : (
                    <button
                      type="button"
                      onClick={() => ajouter(p.id)}
                      className="grow min-w-0 flex items-center gap-3.5 text-left active:opacity-70"
                    >
                      {nom_}
                      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#453A6E"
                           strokeWidth="2.2" strokeLinecap="round" className="shrink-0">
                        <path d="M6 12h12" /><path d="M12 6v12" />
                      </svg>
                    </button>
                  )}
                </li>
              );
            })}
          </ul>
        </div>
      </dialog>

      <ChampCommentaire libelle="Un mot sur ce que vous avez fait" lignes={2} compact />
      <ChampPhotos nom="photos" libelle="Photographier le travail fait (facultatif)" compact />
      <BoutonEnvoi
        pendant="Enregistrement…"
        className="w-full h-[54px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]"
      >
        {choisis.length === 0
          ? "C’est fait, sans matériel"
          : `C’est fait — ${choisis.length} article${choisis.length > 1 ? "s" : ""}`}
      </BoutonEnvoi>
    </form>
  );
}
