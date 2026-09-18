"use client";

import { useState } from "react";

export type LigneComptage = {
  cle: string;
  emplacement_id: string | null;
  bouteille_type_id: string;
  bouteille: string;
  theorique: number;
};

/**
 * Le comptage d'une chambre.
 *
 * Compter trente-sept chambres à deux bouteilles, c'est soixante-quatorze
 * champs. Presque tous valent la dotation : un appui sur « conforme » remplit
 * la ligne, et l'on ne saisit que ce qui diffère. Une chambre non touchée
 * reste NON COMPTÉE — c'est une information, pas un zéro.
 */
export function Comptage({
  lieux,
}: {
  lieux: { code: string; etage: string; lignes: LigneComptage[] }[];
}) {
  const [valeurs, setValeurs] = useState<Record<string, string>>({});
  const etages = [...new Set(lieux.map((l) => l.etage))];

  const comptees = lieux.filter((l) =>
    l.lignes.every((g) => (valeurs[g.cle] ?? "") !== ""),
  ).length;

  const conforme = (l: (typeof lieux)[number]) =>
    setValeurs((v) => ({
      ...v,
      ...Object.fromEntries(l.lignes.map((g) => [g.cle, String(g.theorique)])),
    }));

  const ecart = (l: (typeof lieux)[number]) =>
    l.lignes.some((g) => valeurs[g.cle] !== undefined && valeurs[g.cle] !== "" &&
                          Number(valeurs[g.cle]) !== g.theorique);

  return (
    <div className="flex flex-col gap-2">
      <p className="text-[12px] text-ink-soft text-pretty">
        {comptees} chambre{comptees > 1 ? "s" : ""} comptée{comptees > 1 ? "s" : ""} sur{" "}
        {lieux.length}. Une chambre non touchée n’est pas comptée pour zéro : elle est
        simplement absente de l’inventaire.
      </p>

      {etages.map((etage) => {
        const dedans = lieux.filter((l) => l.etage === etage);
        const faites = dedans.filter((l) =>
          l.lignes.every((g) => (valeurs[g.cle] ?? "") !== ""),
        ).length;
        return (
          <details key={etage} className="carte overflow-hidden group">
            <summary
              data-cible
              className="px-4 flex items-center gap-3 cursor-pointer list-none select-none"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8E8AA3"
                   strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                   className="shrink-0 transition-transform group-open:rotate-90">
                <path d="M9 5l7 7-7 7" />
              </svg>
              <span className="font-display font-semibold text-[16.5px] grow">{etage}</span>
              <span className="text-[12px] text-ink-faint tabular-nums">
                {faites} / {dedans.length}
              </span>
            </summary>

            <div className="px-3 pb-3 pt-1 flex flex-col gap-1.5">
              <button
                type="button"
                onClick={() => dedans.forEach(conforme)}
                className="self-start text-[12px] text-plum underline underline-offset-4 min-h-0 py-1"
              >
                Tout conforme à cet étage
              </button>

              {dedans.map((l) => (
                <div
                  key={l.code}
                  className={`rounded-[11px] border px-2.5 py-2 flex items-center gap-2 ${
                    ecart(l) ? "border-amber/50 bg-amber-soft" : "border-line bg-surface-muted"
                  }`}
                >
                  <span className="w-[42px] shrink-0 text-[14px] font-medium">{l.code}</span>
                  {l.lignes.map((g) => (
                    <label key={g.cle} className="flex-1 min-w-0 flex items-center gap-1.5">
                      <span className="text-[10.5px] text-ink-faint truncate">
                        {g.bouteille.replace(/^Eau\s+/i, "")}
                      </span>
                      <input
                        name={g.cle}
                        type="number"
                        min={0}
                        max={99}
                        inputMode="numeric"
                        value={valeurs[g.cle] ?? ""}
                        placeholder={String(g.theorique)}
                        onChange={(e) =>
                          setValeurs((v) => ({ ...v, [g.cle]: e.target.value }))
                        }
                        aria-label={`${l.code} — ${g.bouteille}`}
                        className="w-[52px] h-[40px] px-1 rounded-[9px] border border-line bg-surface text-[15px] tabular-nums text-center placeholder:text-ink-faint/60"
                      />
                    </label>
                  ))}
                  <button
                    type="button"
                    onClick={() => conforme(l)}
                    aria-label={`Chambre ${l.code} conforme`}
                    className="w-9 h-9 shrink-0 rounded-[9px] bg-surface border border-line grid place-items-center"
                  >
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#357051"
                         strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M5 12.5l4.5 4.5L19 7.5" />
                    </svg>
                  </button>
                </div>
              ))}
            </div>
          </details>
        );
      })}
    </div>
  );
}
