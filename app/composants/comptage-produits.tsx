"use client";

import { useState } from "react";

export type LigneProduit = {
  id: string;
  designation: string;
  code: string;
  categorie: string;
  unite: string;
  theorique: number;
  photo: string | null;
};

/**
 * Le comptage du matériel.
 *
 * Trente-six produits, rangés par métier. Le théorique est en filigrane dans le
 * champ, jamais pré-rempli : un chiffre déjà posé se valide sans être vérifié,
 * et l'inventaire ne vaut plus rien. Un produit non touché reste NON COMPTÉ —
 * il sera simplement absent de l'inventaire, sans écart inventé.
 */
export function ComptageProduits({ lignes }: { lignes: LigneProduit[] }) {
  const [valeurs, setValeurs] = useState<Record<string, string>>({});
  const categories = [...new Set(lignes.map((l) => l.categorie))];

  const comptes = lignes.filter((l) => (valeurs[l.id] ?? "") !== "").length;
  const ecarts = lignes.filter(
    (l) => (valeurs[l.id] ?? "") !== "" && Number(valeurs[l.id]) !== l.theorique,
  ).length;

  const conforme = (dedans: LigneProduit[]) =>
    setValeurs((v) => ({
      ...v,
      ...Object.fromEntries(dedans.map((l) => [l.id, String(l.theorique)])),
    }));

  return (
    <div className="flex flex-col gap-2">
      <p className="text-[12px] text-ink-soft text-pretty leading-snug">
        {comptes} produit{comptes > 1 ? "s" : ""} compté{comptes > 1 ? "s" : ""} sur{" "}
        {lignes.length}
        {ecarts > 0 && ` · ${ecarts} écart${ecarts > 1 ? "s" : ""}`}. Un produit non touché n’est
        pas compté pour zéro : il reste absent de l’inventaire.
      </p>

      {categories.map((categorie) => {
        const dedans = lignes.filter((l) => l.categorie === categorie);
        const faits = dedans.filter((l) => (valeurs[l.id] ?? "") !== "").length;
        return (
          <details key={categorie} className="carte overflow-hidden group">
            <summary
              data-cible
              className="px-4 flex items-center gap-3 cursor-pointer list-none select-none"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8E8AA3"
                   strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                   className="shrink-0 transition-transform group-open:rotate-90">
                <path d="M9 5l7 7-7 7" />
              </svg>
              <span className="font-display font-semibold text-[16px] grow">{categorie}</span>
              <span className="text-[12px] text-ink-faint tabular-nums">
                {faits} / {dedans.length}
              </span>
            </summary>

            <div className="px-3 pb-3 pt-1 flex flex-col gap-1.5">
              <button
                type="button"
                onClick={() => conforme(dedans)}
                className="self-start text-[12px] text-plum underline underline-offset-4 min-h-0 py-1"
              >
                Tout conforme dans « {categorie} »
              </button>

              {dedans.map((l) => {
                const saisi = valeurs[l.id] ?? "";
                const ecart = saisi !== "" && Number(saisi) !== l.theorique;
                return (
                  <label
                    key={l.id}
                    className={`rounded-[11px] border px-2.5 py-2 flex items-center gap-2.5 ${
                      ecart ? "border-amber/50 bg-amber-soft" : "border-line bg-surface-muted"
                    }`}
                  >
                    {l.photo ? (
                      // eslint-disable-next-line @next/next/no-img-element
                      <img
                        src={`/photo/${l.photo}`}
                        alt=""
                        className="w-[38px] h-[38px] shrink-0 rounded-[9px] object-cover border border-line"
                      />
                    ) : (
                      <span className="w-[38px] h-[38px] shrink-0 rounded-[9px] bg-plum-soft" />
                    )}
                    <span className="grow min-w-0">
                      <span className="block text-[13.5px] leading-snug">{l.designation}</span>
                      <span className="block text-[11px] text-ink-faint tabular-nums">
                        théorique {l.theorique}
                        {l.unite !== "unité" && ` ${l.unite}`}
                      </span>
                    </span>
                    <input
                      name={`p-${l.id}`}
                      type="number"
                      step="0.01"
                      min={0}
                      inputMode="decimal"
                      value={saisi}
                      placeholder={String(l.theorique)}
                      onChange={(e) => setValeurs((v) => ({ ...v, [l.id]: e.target.value }))}
                      aria-label={`Compté — ${l.designation}`}
                      className="w-[68px] h-[42px] px-1 shrink-0 rounded-[9px] border border-line bg-surface text-[16px] tabular-nums text-center placeholder:text-ink-faint/60"
                    />
                  </label>
                );
              })}
            </div>
          </details>
        );
      })}
    </div>
  );
}
