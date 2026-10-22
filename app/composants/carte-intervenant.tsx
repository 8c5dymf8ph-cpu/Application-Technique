import Link from "next/link";
import type { Route } from "next";

/**
 * Un intervenant tel qu'on le choisit : ses initiales, son nom, ce qu'il
 * traite, et ce qui l'attend. Le même dessin dans « Intervenir » et dans la
 * fenêtre de l'accueil — on reconnaît un nom à sa place, pas en relisant.
 */
export function CarteIntervenant({
  nom,
  specialites,
  charge,
  onClick,
}: {
  nom: string;
  specialites: string[];
  charge: number;
  onClick?: () => void;
}) {
  return (
    <Link
      href={`/technique/${encodeURIComponent(nom)}` as Route}
      onClick={onClick}
      className="carte px-4 py-3.5 flex items-center gap-3.5 active:bg-surface-muted"
    >
      <span className="w-10 h-10 shrink-0 rounded-full bg-plum-soft grid place-items-center font-display font-semibold text-[14px] text-plum">
        {nom.slice(0, 2).toUpperCase()}
      </span>
      <span className="flex flex-col grow min-w-0 gap-0.5">
        <span className="font-display font-semibold text-[16.5px] truncate">{nom}</span>
        <span className="text-[12.5px] text-ink-faint">
          {specialites.length > 0
            ? `${specialites.join(", ").toLowerCase()} uniquement`
            : "toutes les anomalies"}
        </span>
      </span>
      {charge > 0 && (
        <span className="shrink-0 min-w-[30px] h-[30px] px-2 rounded-lg bg-amber-soft text-amber text-[14px] grid place-items-center tabular-nums">
          {charge}
        </span>
      )}
    </Link>
  );
}
