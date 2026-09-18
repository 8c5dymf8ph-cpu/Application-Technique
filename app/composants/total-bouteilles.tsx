"use client";

import { useState } from "react";

export type TypeBouteille = {
  id: string;
  libelle: string;
  detail: string;
  prix: number;
  couleur: string;
  /** La photo ajoutée depuis le paramétrage. À défaut, la bouteille est dessinée. */
  photo: string | null;
};

/** La bouteille, dessinée à sa couleur. Bleue pour la filtrée, rouge pour la gazeuse. */
function Bouteille({ couleur, choisie }: { couleur: string; choisie: boolean }) {
  return (
    <svg
      viewBox="0 0 48 96"
      width="46"
      height="92"
      aria-hidden
      className="shrink-0"
      style={{ opacity: choisie ? 1 : 0.55 }}
    >
      {/* bouchon */}
      <rect x="17" y="3" width="14" height="10" rx="2" fill="#3A3345" />
      <rect x="18.5" y="12" width="11" height="5" fill="#3A3345" />
      {/* col et corps */}
      <path
        d="M19 16h10v9c0 3 9 7 9 15v44a7 7 0 0 1-7 7H17a7 7 0 0 1-7-7V40c0-8 9-12 9-15z"
        fill={couleur}
        fillOpacity="0.16"
        stroke={couleur}
        strokeWidth="1.8"
      />
      {/* étiquette */}
      <rect x="11" y="50" width="26" height="26" rx="2" fill={couleur} fillOpacity="0.9" />
      <rect x="14" y="56" width="20" height="2" rx="1" fill="#fff" fillOpacity="0.9" />
      <rect x="14" y="61" width="14" height="2" rx="1" fill="#fff" fillOpacity="0.7" />
      <rect x="14" y="66" width="17" height="2" rx="1" fill="#fff" fillOpacity="0.5" />
    </svg>
  );
}

/**
 * Le choix des bouteilles, et le total qui suit.
 *
 * Un appui sur la bouteille en met une ; un second l'enlève. Les deux peuvent
 * être choisies ensemble, et le contour prend la couleur de la bouteille —
 * bleu pour la filtrée, rouge pour la gazeuse — parce que c'est ainsi qu'on les
 * reconnaît en chambre, pas à leur nom.
 *
 * C'est le seul endroit de l'application qui compte dans le navigateur : il ne
 * décide de rien, il montre ce que la déclaration coûtera. Le montant retenu
 * reste calculé en base.
 */
export function TotalBouteilles({
  types,
  libelle,
}: {
  types: TypeBouteille[];
  libelle: string;
}) {
  const [quantites, setQuantites] = useState<Record<string, number>>({});
  const total = types.reduce((s, t) => s + (quantites[t.id] ?? 0) * t.prix, 0);
  const poser = (id: string, n: number) =>
    setQuantites((q) => ({ ...q, [id]: Math.max(0, Math.min(20, n)) }));

  return (
    <>
      <div className="flex gap-2.5">
        {types.map((t) => {
          const n = quantites[t.id] ?? 0;
          return (
            <div
              key={t.id}
              className="flex-1 min-w-0 rounded-card border-2 bg-surface px-2.5 pt-3 pb-2.5 flex flex-col items-center gap-1.5 transition-colors"
              style={{
                borderColor: n > 0 ? t.couleur : "#E7E4EF",
                background: n > 0 ? `${t.couleur}0F` : undefined,
              }}
            >
              <button
                type="button"
                onClick={() => poser(t.id, n > 0 ? 0 : 1)}
                aria-pressed={n > 0}
                aria-label={`${t.libelle} — ${n > 0 ? "retirer" : "ajouter"}`}
                className="flex flex-col items-center gap-1.5 w-full"
              >
                {t.photo ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={`/photo/${t.photo}`}
                    alt=""
                    className="h-[92px] w-auto max-w-full object-contain"
                    style={{ opacity: n > 0 ? 1 : 0.55 }}
                  />
                ) : (
                  <Bouteille couleur={t.couleur} choisie={n > 0} />
                )}
                <span className="flex items-center gap-1.5">
                  <span
                    aria-hidden
                    className="w-2.5 h-2.5 rounded-full shrink-0"
                    style={{ background: t.couleur }}
                  />
                  <span
                    className="text-[14px] leading-tight font-medium"
                    style={{ color: n > 0 ? t.couleur : undefined }}
                  >
                    {t.libelle}
                  </span>
                </span>
                <span className="font-display font-semibold text-[16px] tabular-nums">
                  {t.prix.toLocaleString("fr-FR", { style: "currency", currency: "EUR" })}
                </span>
                <span className="text-[11px] text-ink-faint">{t.detail}</span>
              </button>

              {/* Plusieurs bouteilles du même type, c'est rare : la quantité ne
                  s'ouvre qu'une fois la bouteille choisie. */}
              {n > 0 && (
                <span className="flex items-center gap-1 mt-0.5">
                  <button
                    type="button"
                    onClick={() => poser(t.id, n - 1)}
                    aria-label="Une de moins"
                    className="w-9 h-9 rounded-[10px] bg-surface border border-line grid place-items-center text-[17px] leading-none"
                  >
                    −
                  </button>
                  <span className="w-7 text-center font-display font-semibold text-[17px] tabular-nums">
                    {n}
                  </span>
                  <button
                    type="button"
                    onClick={() => poser(t.id, n + 1)}
                    aria-label="Une de plus"
                    className="w-9 h-9 rounded-[10px] bg-surface border border-line grid place-items-center text-[17px] leading-none"
                  >
                    +
                  </button>
                </span>
              )}
              <input type="hidden" name={`qte-${t.id}`} value={n} />
            </div>
          );
        })}
      </div>

      <div className="rounded-card bg-plum px-4 py-3 flex items-baseline gap-3">
        <span className="text-[13px] text-white/75 grow leading-snug text-pretty">{libelle}</span>
        <span className="font-display font-semibold text-[22px] text-white tabular-nums">
          {total.toLocaleString("fr-FR", { style: "currency", currency: "EUR" })}
        </span>
      </div>
    </>
  );
}
