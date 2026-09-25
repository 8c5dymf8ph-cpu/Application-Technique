"use client";

import { useState } from "react";

export type TypeConsequence = {
  id: string;
  code: string;
  libelle: string;
  porte_sur_lieux: boolean;
  porte_montant: boolean;
};

export type LieuSimple = { id: string; code: string };

export type ConsequencePosee = {
  type_id: string;
  lieux: string[];
  montant: string;
};

/**
 * Ce qu'on a décidé parce que l'acte a eu lieu.
 *
 * « Geste commercial, remise en vente, chambre bloquée sont plus la
 * conséquence que des événements. » Elles ne méritent donc pas une ligne de
 * chronologie à elles — « Chambre bloquée » seule ne dit pas pourquoi — mais
 * elles pendent au fait qui les a causées, et se lisent avec lui : « le 04/11,
 * constat client, et la 34 a été bloquée ».
 *
 * Replié tant qu'on n'en pose aucune : la plupart des actes n'en portent pas,
 * et un formulaire qui montre tout ce qu'il SAIT faire fait perdre de vue ce
 * qu'on est venu faire.
 */
export function ChoixConsequences({
  types,
  lieux,
  posees = [],
}: {
  types: TypeConsequence[];
  /** Les lieux du dossier : on ne bloque pas une chambre qu'il ne couvre pas. */
  lieux: LieuSimple[];
  /** Ce que l'acte porte déjà, quand on le corrige. */
  posees?: ConsequencePosee[];
}) {
  const [actives, setActives] = useState<Record<string, { lieux: string[]; montant: string }>>(
    Object.fromEntries(posees.map((c) => [c.type_id, { lieux: c.lieux, montant: c.montant }])),
  );

  const basculer = (id: string) =>
    setActives((a) => {
      const n = { ...a };
      if (n[id]) delete n[id];
      else n[id] = { lieux: [], montant: "" };
      return n;
    });

  const basculerLieu = (id: string, lieu: string) =>
    setActives((a) => {
      const courant = a[id];
      if (!courant) return a;
      const dedans = courant.lieux.includes(lieu);
      return {
        ...a,
        [id]: {
          ...courant,
          lieux: dedans ? courant.lieux.filter((l) => l !== lieu) : [...courant.lieux, lieu],
        },
      };
    });

  if (types.length === 0) return null;
  const combien = Object.keys(actives).length;

  return (
    <details className="rounded-[12px] border border-line bg-surface" open={combien > 0}>
      <summary className="list-none cursor-pointer px-3 h-[46px] flex items-center gap-2 text-[14px]">
        <svg
          width="15"
          height="15"
          viewBox="0 0 24 24"
          fill="none"
          stroke="#8E8AA3"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          aria-hidden
        >
          <path d="M9 5l7 7-7 7" />
        </svg>
        <span className="grow">Ce qu’on a décidé</span>
        <span className="text-[12px] text-ink-faint">
          {combien > 0 ? `${combien} conséquence${combien > 1 ? "s" : ""}` : "aucune"}
        </span>
      </summary>

      <div className="px-3 pb-3 pt-1 flex flex-col gap-2.5">
        <p className="text-[11.5px] text-ink-faint text-pretty leading-snug">
          Une conséquence n’est pas un événement : elle porte la date de ce qui l’a causée, et se
          lit avec lui.
        </p>

        <div className="flex flex-wrap gap-1.5">
          {types.map((t) => (
            <button
              key={t.id}
              type="button"
              onClick={() => basculer(t.id)}
              aria-pressed={Boolean(actives[t.id])}
              className={`h-[38px] px-3 rounded-pill border text-[13px] ${
                actives[t.id]
                  ? "bg-amber-soft border-amber text-amber font-medium"
                  : "bg-surface border-line text-ink-soft"
              }`}
            >
              {t.libelle}
            </button>
          ))}
        </div>

        {types
          .filter((t) => actives[t.id])
          .map((t) => (
            <div key={t.id} className="rounded-[11px] bg-surface-muted px-3 py-2.5 flex flex-col gap-2">
              <span className="etiquette">{t.libelle}</span>

              {t.porte_sur_lieux && (
                <div className="flex flex-wrap gap-1.5">
                  {lieux.map((l) => {
                    const pris = actives[t.id].lieux.includes(l.id);
                    return (
                      <button
                        key={l.id}
                        type="button"
                        onClick={() => basculerLieu(t.id, l.id)}
                        aria-pressed={pris}
                        className={`h-[36px] min-w-[46px] px-2.5 rounded-pill border text-[13px] ${
                          pris
                            ? "bg-amber border-amber text-white font-semibold"
                            : "bg-surface border-line text-ink-faint"
                        }`}
                      >
                        {l.code}
                      </button>
                    );
                  })}
                  {lieux.length === 0 && (
                    <span className="text-[11.5px] text-ink-faint">
                      Ce dossier ne couvre encore aucun lieu.
                    </span>
                  )}
                </div>
              )}

              {t.porte_montant && (
                <label className="flex flex-col gap-1">
                  <span className="etiquette">Montant</span>
                  <input
                    value={actives[t.id].montant}
                    onChange={(e) =>
                      setActives((a) => ({ ...a, [t.id]: { ...a[t.id], montant: e.target.value } }))
                    }
                    inputMode="decimal"
                    placeholder="—"
                    className="h-[44px] rounded-[11px] border border-line px-3 bg-surface text-[15px] tabular-nums"
                  />
                </label>
              )}
            </div>
          ))}
      </div>

      {Object.entries(actives).map(([id, v]) => (
        <span key={id}>
          <input type="hidden" name={`cons_${id}`} value="1" />
          <input type="hidden" name={`cons_montant_${id}`} value={v.montant} />
          {v.lieux.map((l) => (
            <input key={l} type="hidden" name={`cons_lieu_${id}`} value={l} />
          ))}
        </span>
      ))}
    </details>
  );
}
