import type { ReactNode } from "react";

/**
 * Une section qui se déplie — et qui le dit.
 *
 * Les listes longues se replient : sur un téléphone tenu d'une main, faire
 * défiler trois écrans avant d'atteindre le cinquième étage est un défaut.
 * Mais `list-none` retirait le triangle du navigateur sans rien mettre à la
 * place : il ne restait qu'un titre, qui ne ressemblait pas à un bouton. On ne
 * savait pas qu'il y avait quelque chose dessous, et on ne trouvait pas les
 * intervenants.
 *
 * Un chevron, donc, qui pivote en s'ouvrant, et un titre assez grand pour
 * qu'on le vise au pouce. Le compte à droite dit ce qu'on trouvera dedans
 * avant d'ouvrir — « 4 prénoms » se lit plus vite qu'on n'ouvre.
 */
export function Depliant({
  titre,
  aide,
  indice,
  ouvert = false,
  enCarte = true,
  children,
}: {
  titre: string;
  /** Une phrase sous le titre, visible replié : elle dit à quoi sert la section. */
  aide?: string;
  /** Ce qu'on trouvera dedans : un nombre, un état. À droite, discret. */
  indice?: ReactNode;
  ouvert?: boolean;
  /** Une section de page se pose sur le fond ; une section dans une carte, non. */
  enCarte?: boolean;
  children: ReactNode;
}) {
  return (
    <details open={ouvert} className={`group/section ${enCarte ? "carte px-4 py-3.5" : ""}`}>
      <summary
        data-cible
        className="list-none cursor-pointer flex items-center gap-3 min-h-[34px]"
      >
        <span
          aria-hidden
          className="w-7 h-7 shrink-0 rounded-full bg-plum-soft grid place-items-center transition-transform group-open/section:rotate-90"
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#453A6E"
               strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
            <path d="M9 5l7 7-7 7" />
          </svg>
        </span>
        <span className="grow min-w-0 flex flex-col">
          <span className="font-display font-semibold text-[17px] leading-snug text-pretty">
            {titre}
          </span>
          {aide && (
            <span className="text-[12px] text-ink-faint text-pretty leading-snug">{aide}</span>
          )}
        </span>
        {indice !== undefined && (
          <span className="shrink-0 text-[12.5px] text-ink-faint tabular-nums text-right">
            {indice}
          </span>
        )}
      </summary>
      <div className="flex flex-col gap-2.5 pt-3">{children}</div>
    </details>
  );
}

/**
 * Le même geste, en plus petit : une ligne d'une liste qui s'ouvre.
 *
 * Le titre est alors le nom de la ligne, pas celui d'une section — on ne le
 * grossit pas, mais le chevron reste : c'est lui qui dit que ça s'ouvre.
 */
export function LigneDepliante({
  titre,
  detail,
  marque,
  ouvert = false,
  children,
}: {
  titre: ReactNode;
  detail?: ReactNode;
  /** Un état, à droite du titre : « profil », « retiré ». */
  marque?: ReactNode;
  ouvert?: boolean;
  children: ReactNode;
}) {
  return (
    <details open={ouvert} className="group/ligne carte px-3.5 py-2.5">
      <summary data-cible className="list-none cursor-pointer flex items-center gap-2.5">
        <span
          aria-hidden
          className="w-6 h-6 shrink-0 grid place-items-center text-ink-faint transition-transform group-open/ligne:rotate-90"
        >
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round">
            <path d="M9 5l7 7-7 7" />
          </svg>
        </span>
        <span className="grow min-w-0">
          <span className="block text-[15.5px] leading-snug text-pretty">{titre}</span>
          {detail && <span className="block text-[12px] text-ink-faint">{detail}</span>}
        </span>
        {marque}
      </summary>
      <div className="flex flex-col gap-2.5 pt-2.5">{children}</div>
    </details>
  );
}
