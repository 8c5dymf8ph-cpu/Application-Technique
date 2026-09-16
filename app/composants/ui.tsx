import Link from "next/link";
import type { Route } from "next";

/** Une adresse construite à partir d'un segment dynamique. */
type Adresse = Route | (string & {});

export function Entete({
  titre,
  sous_titre,
  retour,
}: {
  titre: string;
  sous_titre?: string;
  retour?: Adresse;
}) {
  return (
    <header className="bg-plum px-5 pb-[18px] pt-5 flex items-center gap-3">
      {retour && (
        <Link
          href={retour as Route}
          aria-label="Retour"
          className="w-11 h-11 shrink-0 rounded-[13px] bg-white/15 grid place-items-center"
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff"
               strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <path d="M15 5l-7 7 7 7" />
          </svg>
        </Link>
      )}
      <div className="min-w-0">
        <h1 className="font-display font-bold text-[21px] text-white leading-tight">{titre}</h1>
        {sous_titre && <p className="text-[11.5px] text-white/70 truncate">{sous_titre}</p>}
      </div>
    </header>
  );
}

export function Compteur({
  valeur,
  libelle,
  ton = "text-ink",
}: {
  valeur: number | string;
  libelle: string;
  ton?: string;
}) {
  return (
    <div className="carte px-2 py-5 flex flex-col items-center gap-1">
      <span className={`font-display font-semibold text-[30px] leading-none tabular-nums ${ton}`}>
        {valeur}
      </span>
      <span className="etiquette">{libelle}</span>
    </div>
  );
}

export function Tuile({
  href,
  titre,
  detail,
  badge,
  ton = "bg-plum-soft",
}: {
  href: Adresse;
  titre: string;
  detail: string;
  badge?: string | number;
  ton?: string;
}) {
  return (
    <Link
      href={href as Route}
      className={`${ton} rounded-tile px-5 py-[22px] flex items-center gap-4 min-h-[96px]`}
    >
      <div className="flex flex-col gap-[3px] grow min-w-0">
        <span className="font-display font-bold text-[22px] text-ink">{titre}</span>
        <span className="text-[13px] text-ink-soft">{detail}</span>
      </div>
      {badge !== undefined && badge !== 0 && (
        <span className="shrink-0 min-w-[34px] h-[34px] px-2 rounded-[10px] bg-white grid place-items-center font-display font-semibold text-[16px] text-ink tabular-nums">
          {badge}
        </span>
      )}
    </Link>
  );
}

export function Vide({ children }: { children: React.ReactNode }) {
  return (
    <p className="text-[14px] text-ink-faint text-center py-8 px-4 text-pretty">{children}</p>
  );
}
