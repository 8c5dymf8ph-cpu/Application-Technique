/**
 * Les graphiques du tableau de bord.
 *
 * Tout est en SVG écrit à la main : aucune dépendance, rien à charger, et la
 * page reste lisible sur un téléphone. Les marques sont fines, la grille
 * discrète, et chaque valeur reste accessible autrement que par la couleur —
 * une étiquette, un titre au survol, et le tableau replié sous le graphique.
 *
 * Les quatre couleurs de série ont été vérifiées : écart suffisant entre voisines
 * y compris pour un daltonien, contraste suffisant sur le fond.
 */
export const SERIES = {
  restituee: "#1F7A4D",
  facturee: "#2E62B0",
  en_cours: "#C07A10",
  perdue: "#C0283A",
} as const;

const ENCRE = "#1B1930";
const ENCRE_PALE = "#8E8AA3";
const GRILLE = "#E7E4EF";
const ACCENT = "#453A6E";

export function Cadre({
  titre,
  detail,
  children,
}: {
  titre: string;
  detail?: string;
  children: React.ReactNode;
}) {
  return (
    <section className="carte px-4 py-4 flex flex-col gap-3">
      <div>
        <h2 className="font-display font-semibold text-[15px]">{titre}</h2>
        {detail && <p className="text-[11.5px] text-ink-faint text-pretty">{detail}</p>}
      </div>
      {children}
    </section>
  );
}

/** Une tuile de tête : le chiffre, ce qu'il est, et son évolution. */
export function Chiffre({
  valeur,
  libelle,
  evolution,
  sens = "hausse_mauvaise",
  ton = ACCENT,
}: {
  valeur: string | number;
  libelle: string;
  evolution?: string;
  sens?: "hausse_mauvaise" | "hausse_bonne" | "neutre";
  ton?: string;
}) {
  const mauvais = evolution?.startsWith("+");
  const couleur =
    sens === "neutre"
      ? ENCRE_PALE
      : (sens === "hausse_mauvaise") === !!mauvais
        ? SERIES.perdue
        : SERIES.restituee;
  return (
    <div className="carte px-3 py-3 flex flex-col gap-1 overflow-hidden relative">
      <span aria-hidden className="absolute top-0 left-0 right-0 h-[3px]" style={{ background: ton }} />
      <span className="font-display font-semibold text-[22px] leading-none tabular-nums mt-1">
        {valeur}
      </span>
      <span className="etiquette text-[8.5px] leading-tight">{libelle}</span>
      {evolution && (
        <span className="text-[10.5px] tabular-nums" style={{ color: couleur }}>
          {evolution}
        </span>
      )}
    </div>
  );
}

/**
 * Colonnes dans le temps : une seule série, donc une seule couleur. Le mois en
 * cours est mis en avant, les autres sont le contexte.
 */
export function Colonnes({
  points,
  unite = "",
}: {
  points: { libelle: string; valeur: number; courant?: boolean }[];
  unite?: string;
}) {
  const max = Math.max(1, ...points.map((p) => p.valeur));
  const H = 96;
  const largeur = 100 / points.length;
  return (
    <div className="flex flex-col gap-1.5">
      <div className="relative" style={{ height: H }}>
        {/* Grille : deux repères suffisent, en filet plein et discret. */}
        {[0, 0.5, 1].map((f) => (
          <span
            key={f}
            aria-hidden
            className="absolute left-0 right-0 border-t"
            style={{ borderColor: GRILLE, top: H - f * H }}
          />
        ))}
        <div className="absolute inset-0 flex items-end">
          {points.map((p) => (
            <div key={p.libelle} className="flex flex-col items-center justify-end h-full"
                 style={{ width: `${largeur}%` }}>
              {p.valeur > 0 && (
                <span
                  className="text-[9.5px] tabular-nums mb-0.5"
                  style={{ color: p.courant ? ENCRE : ENCRE_PALE }}
                >
                  {p.valeur}
                </span>
              )}
              <span
                title={`${p.libelle} : ${p.valeur}${unite}`}
                className="rounded-t-[4px]"
                style={{
                  width: "min(22px, 70%)",
                  height: Math.max(p.valeur > 0 ? 3 : 1, (p.valeur / max) * (H - 18)),
                  background: p.courant ? ACCENT : "#C9C4DB",
                }}
              />
            </div>
          ))}
        </div>
      </div>
      <div className="flex">
        {points.map((p) => (
          <span
            key={p.libelle}
            className="text-[9px] text-center"
            style={{ width: `${largeur}%`, color: p.courant ? ENCRE : ENCRE_PALE }}
          >
            {p.libelle}
          </span>
        ))}
      </div>
    </div>
  );
}

/** Barres horizontales classées : une seule série, la valeur au bout. */
export function Barres({
  lignes,
  format,
  nomsLongs = false,
}: {
  lignes: { libelle: string; valeur: number; detail?: string }[];
  format: (n: number) => string;
  /**
   * Le nom au-dessus de la barre plutôt qu'à côté.
   *
   * Une chambre tient en deux caractères, pas « Détection Canine » ni
   * « Télérupteurs (Mécaniques) Paris Elec ». Dans 62 px ils devenaient
   * « Détectio… », « Télérupt… », « Télérupt… » — trois lignes qu'on ne
   * distingue plus l'une de l'autre, donc un graphique qui n'apprend rien.
   */
  nomsLongs?: boolean;
}) {
  const max = Math.max(1, ...lignes.map((l) => l.valeur));
  if (nomsLongs) {
    return (
      <ul className="flex flex-col gap-2.5">
        {lignes.map((l) => (
          <li key={l.libelle} className="flex flex-col gap-1">
            <span className="flex items-baseline gap-2">
              <span className="grow text-[12.5px] leading-snug text-pretty">
                {l.libelle}
              </span>
              <span className="shrink-0 text-[12.5px] tabular-nums font-display font-semibold">
                {format(l.valeur)}
              </span>
            </span>
            <span className="h-[8px] rounded-[3px]" style={{ background: "#F1EFF6" }}>
              <span
                className="block h-full rounded-r-[4px]"
                style={{ width: `${Math.max(3, (l.valeur / max) * 100)}%`, background: ACCENT }}
              />
            </span>
          </li>
        ))}
      </ul>
    );
  }
  return (
    <ul className="flex flex-col gap-2">
      {lignes.map((l) => (
        <li key={l.libelle} className="flex items-center gap-2.5">
          <span className="w-[62px] shrink-0 text-[12px] truncate">{l.libelle}</span>
          <span className="grow h-[10px] rounded-[3px]" style={{ background: "#F1EFF6" }}>
            <span
              title={`${l.libelle} : ${format(l.valeur)}`}
              className="block h-full rounded-r-[4px]"
              style={{ width: `${Math.max(3, (l.valeur / max) * 100)}%`, background: ACCENT }}
            />
          </span>
          <span className="w-[56px] shrink-0 text-right text-[12px] tabular-nums">
            {format(l.valeur)}
          </span>
        </li>
      ))}
    </ul>
  );
}

/**
 * Part-à-tout : une barre empilée horizontale plutôt qu'un camembert — sur un
 * téléphone, deux parts proches ne se comparent pas sur un disque. Chaque part
 * est séparée par un filet de fond, et la légende porte le nom ET la valeur :
 * la couleur n'est jamais la seule information.
 */
export function Repartition({
  parts,
}: {
  parts: { libelle: string; valeur: number; couleur: string }[];
}) {
  const total = parts.reduce((s, p) => s + p.valeur, 0);
  if (total === 0) {
    return <p className="text-[13px] text-ink-faint">Aucun dossier sur la période.</p>;
  }
  const visibles = parts.filter((p) => p.valeur > 0);
  return (
    <div className="flex flex-col gap-2.5">
      <div className="flex h-[26px] rounded-[6px] overflow-hidden gap-[2px]">
        {visibles.map((p) => (
          <span
            key={p.libelle}
            title={`${p.libelle} : ${p.valeur} sur ${total}`}
            style={{ background: p.couleur, flexGrow: p.valeur }}
          />
        ))}
      </div>
      <ul className="flex flex-col gap-1">
        {parts.map((p) => (
          <li key={p.libelle} className="flex items-center gap-2 text-[12px]">
            <span
              aria-hidden
              className="w-2.5 h-2.5 rounded-[3px] shrink-0"
              style={{ background: p.couleur }}
            />
            <span className="grow text-ink-soft">{p.libelle}</span>
            <span className="tabular-nums">{p.valeur}</span>
            <span className="w-[42px] text-right tabular-nums text-ink-faint">
              {total > 0 ? Math.round((p.valeur / total) * 100) : 0}&nbsp;%
            </span>
          </li>
        ))}
      </ul>
    </div>
  );
}

/** Une jauge : une quantité face à son seuil, sur la même piste. */
export function Jauge({
  libelle,
  valeur,
  seuil,
  maximum,
  couleur,
}: {
  libelle: string;
  valeur: number;
  seuil: number;
  maximum: number;
  couleur: string;
}) {
  const plein = Math.min(100, (valeur / Math.max(1, maximum)) * 100);
  const marque = Math.min(100, (seuil / Math.max(1, maximum)) * 100);
  const sous = valeur <= seuil;
  return (
    <div className="flex flex-col gap-1">
      <div className="flex items-baseline gap-2">
        <span className="text-[12.5px] grow">{libelle}</span>
        <span
          className="text-[13px] tabular-nums font-display font-semibold"
          style={{ color: sous ? SERIES.perdue : ENCRE }}
        >
          {valeur}
        </span>
        <span className="text-[10.5px] text-ink-faint tabular-nums">seuil {seuil}</span>
      </div>
      <div className="relative h-[10px] rounded-[3px]" style={{ background: "#F1EFF6" }}>
        <span
          className="block h-full rounded-r-[4px]"
          style={{ width: `${Math.max(2, plein)}%`, background: sous ? SERIES.perdue : couleur }}
        />
        <span
          aria-hidden
          title={`Seuil : ${seuil}`}
          className="absolute top-[-3px] bottom-[-3px] w-[2px]"
          style={{ left: `${marque}%`, background: ENCRE_PALE }}
        />
      </div>
    </div>
  );
}

/** Le tableau des mêmes chiffres, replié : rien n'est accessible seulement en image. */
export function Tableau({
  entetes,
  lignes,
}: {
  entetes: string[];
  lignes: (string | number)[][];
}) {
  return (
    <details className="mt-1">
      <summary className="text-[11.5px] text-plum underline underline-offset-4 cursor-pointer list-none">
        Voir les chiffres
      </summary>
      <div className="mt-2 overflow-x-auto">
        <table className="w-full text-[11.5px] tabular-nums">
          <thead>
            <tr className="text-ink-faint text-left">
              {entetes.map((e) => (
                <th key={e} className="font-normal py-1 pr-3 whitespace-nowrap">
                  {e}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {lignes.map((l, i) => (
              <tr key={i} className="border-t border-line">
                {l.map((c, j) => (
                  <td key={j} className="py-1 pr-3 whitespace-nowrap">
                    {c}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </details>
  );
}
