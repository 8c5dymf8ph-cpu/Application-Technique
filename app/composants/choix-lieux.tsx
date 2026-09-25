"use client";

import { useState } from "react";

export type LieuChoix = { id: string; code: string; etage: string };

/**
 * Choisir les lieux d'un acte, et dire ce qu'on y a trouvé.
 *
 * Un balayage couvre trente-huit chambres et n'en trouve qu'une : saisir
 * trente-huit lignes serait absurde, et ne saisir que la positive perdrait
 * l'information que les trente-sept autres ONT ÉTÉ vérifiées — « j'ai besoin
 * de savoir quelles chambres ont été contrôlées même si elles n'ont rien
 * relevé, c'est pour le suivi ».
 *
 * Un appui = vérifié, rien trouvé. Un deuxième = trouvé. Un troisième =
 * retiré. Trois états sur une pastille, et « Tout cocher » pour la campagne
 * qui part de l'hôtel entier.
 */
export function ChoixLieux({
  lieux,
  defaut = [],
  etats,
  verification,
}: {
  lieux: LieuChoix[];
  /** Les lieux pré-cochés — la portée du suivi. */
  defaut?: string[];
  /**
   * Ce qu'un acte porte DÉJÀ, quand on le corrige : chaque lieu avec son
   * résultat. Sans cela, rouvrir un acte pour changer sa date en aurait
   * effacé les trente-huit chambres — une correction ne doit jamais coûter
   * plus que ce qu'elle corrige.
   */
  etats?: Record<string, "negatif" | "positif" | "concerne">;
  /** Un acte de vérification porte un résultat ; un traitement, non. */
  verification: boolean;
}) {
  const [etat, setEtat] = useState<Record<string, "negatif" | "positif" | "concerne">>(
    etats ?? Object.fromEntries(defaut.map((id) => [id, verification ? "negatif" : "concerne"])),
  );

  const suivant = (id: string) => {
    setEtat((e) => {
      const n = { ...e };
      if (!verification) {
        if (n[id]) delete n[id];
        else n[id] = "concerne";
        return n;
      }
      if (!n[id]) n[id] = "negatif";
      else if (n[id] === "negatif") n[id] = "positif";
      else delete n[id];
      return n;
    });
  };

  const tout = (valeur: "negatif" | "concerne" | null) =>
    setEtat(valeur ? Object.fromEntries(lieux.map((l) => [l.id, valeur])) : {});

  const etages = [...new Set(lieux.map((l) => l.etage))];
  const retenus = Object.keys(etat).length;
  const positifs = Object.values(etat).filter((v) => v === "positif").length;

  return (
    <div className="flex flex-col gap-2.5">
      <div className="flex items-baseline gap-2">
        <span className="etiquette grow">Où</span>
        <span className="text-[11.5px] text-ink-faint tabular-nums">
          {retenus} retenu{retenus > 1 ? "s" : ""}
          {verification && positifs > 0 ? ` · ${positifs} trouvé${positifs > 1 ? "s" : ""}` : ""}
        </span>
      </div>

      <div className="flex gap-1.5">
        <button
          type="button"
          onClick={() => tout(verification ? "negatif" : "concerne")}
          className="h-[34px] px-3 rounded-pill border border-line bg-surface text-[12.5px] text-ink-soft"
        >
          Tout cocher
        </button>
        <button
          type="button"
          onClick={() => tout(null)}
          className="h-[34px] px-3 rounded-pill border border-line bg-surface text-[12.5px] text-ink-soft"
        >
          Tout retirer
        </button>
      </div>

      {verification && (
        <p className="text-[11.5px] text-ink-faint text-pretty leading-snug">
          Un appui : <b className="text-green">vérifié, rien trouvé</b>. Un deuxième :{" "}
          <b className="text-red">trouvé</b>. Un troisième : retiré.
        </p>
      )}

      <div className="flex flex-col gap-2.5 max-h-[46vh] overflow-y-auto pr-1">
        {etages.map((etage) => (
          <div key={etage} className="flex flex-col gap-1.5">
            <span className="etiquette">{etage}</span>
            <div className="flex flex-wrap gap-1.5">
              {lieux
                .filter((l) => l.etage === etage)
                .map((l) => {
                  const v = etat[l.id];
                  return (
                    <button
                      key={l.id}
                      type="button"
                      onClick={() => suivant(l.id)}
                      aria-pressed={Boolean(v)}
                      className={`h-[40px] min-w-[50px] px-3 rounded-pill border text-[14px] ${
                        v === "positif"
                          ? "bg-red border-red text-white font-semibold"
                          : v === "negatif"
                            ? "bg-green-soft border-green/40 text-green"
                            : v === "concerne"
                              ? "bg-plum-soft border-plum text-plum"
                              : "bg-surface border-line text-ink-faint"
                      }`}
                    >
                      {l.code}
                    </button>
                  );
                })}
            </div>
          </div>
        ))}
      </div>

      {Object.entries(etat).map(([id, v]) => (
        <input key={id} type="hidden" name={`lieu_${id}`} value={v} />
      ))}
    </div>
  );
}
