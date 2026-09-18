"use client";

import { useState } from "react";

/**
 * Le total à facturer, qui suit la saisie.
 *
 * C'est le seul endroit de l'application qui a besoin de compter dans le
 * navigateur : il ne décide de rien, il montre ce que la déclaration coûtera.
 * Le montant réellement retenu reste calculé en base.
 */
export function TotalBouteilles({
  types,
  libelle,
}: {
  types: { id: string; libelle: string; prix: number }[];
  libelle: string;
}) {
  const [quantites, setQuantites] = useState<Record<string, number>>({});
  const total = types.reduce((s, t) => s + (quantites[t.id] ?? 0) * t.prix, 0);

  return (
    <>
      <div className="flex gap-2">
        {types.map((t) => (
          <label
            key={t.id}
            className={`flex-1 min-w-0 carte px-3 py-3 flex flex-col gap-2 cursor-pointer ${
              (quantites[t.id] ?? 0) > 0 ? "border-plum bg-plum-soft" : ""
            }`}
          >
            <span className="text-[14px] leading-tight">{t.libelle}</span>
            <span className="text-[12.5px] text-ink-faint tabular-nums">
              {t.prix.toLocaleString("fr-FR", { style: "currency", currency: "EUR" })}
            </span>
            <input
              name={`qte-${t.id}`}
              type="number"
              min={0}
              max={20}
              inputMode="numeric"
              value={quantites[t.id] ?? 0}
              onChange={(e) =>
                setQuantites((q) => ({ ...q, [t.id]: Math.max(0, Number(e.target.value) || 0) }))
              }
              aria-label={`Nombre de ${t.libelle}`}
              className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[17px] tabular-nums text-center"
            />
          </label>
        ))}
      </div>
      <div className="rounded-card bg-plum px-4 py-3 flex items-baseline gap-3">
        <span className="text-[13px] text-white/75 grow leading-snug text-pretty">{libelle}</span>
        <span className="font-display font-semibold text-[20px] text-white tabular-nums">
          {total.toLocaleString("fr-FR", { style: "currency", currency: "EUR" })}
        </span>
      </div>
    </>
  );
}
