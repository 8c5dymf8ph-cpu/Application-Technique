import Link from "next/link";
import type { Route } from "next";

type Adresse = Route | (string & {});

/**
 * La frise d'un dossier : constaté, transmis, client contacté, résolu.
 *
 * Elle dit d'un coup d'œil où en est le dossier, sans lire le statut. Une étape
 * franchie est pleine, l'étape en cours est cerclée, les suivantes sont en
 * pointillé — ce qui reste à faire se voit autant que ce qui est fait.
 */
export function Frise({ etapes }: { etapes: { libelle: string; faite: boolean }[] }) {
  const courante = etapes.findIndex((e) => !e.faite);
  return (
    <ol className="flex items-start">
      {etapes.map((e, i) => {
        const etat = e.faite ? "faite" : i === courante ? "courante" : "future";
        return (
          <li key={e.libelle} className="flex-1 flex flex-col items-center relative">
            {i < etapes.length - 1 && (
              <span
                aria-hidden
                className={`absolute top-[8px] left-1/2 w-full h-[1.5px] ${
                  etapes[i + 1].faite ? "bg-plum" : "bg-line"
                }`}
              />
            )}
            <span
              className={`relative z-10 w-[17px] h-[17px] rounded-full grid place-items-center ${
                etat === "faite"
                  ? "bg-plum"
                  : etat === "courante"
                    ? "bg-surface border-[1.7px] border-amber"
                    : "bg-surface border border-dashed border-line"
              }`}
            >
              {etat === "faite" && (
                <svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="#fff"
                     strokeWidth="3.4" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
                  <path d="M5 12.5l4.5 4.5L19 7.5" />
                </svg>
              )}
            </span>
            <span
              className={`mt-1 text-[9.5px] text-center leading-tight ${
                etat === "future" ? "text-ink-faint" : "text-ink-soft"
              }`}
            >
              {e.libelle}
            </span>
          </li>
        );
      })}
    </ol>
  );
}

/** Les filtres d'une liste : des pastilles, une seule active, tout tient sur une ligne. */
export function Filtres({
  choix,
  actif,
  lien,
}: {
  choix: { valeur: string; libelle: string; nombre?: number }[];
  actif: string;
  lien: (valeur: string) => Adresse;
}) {
  return (
    <div className="flex gap-1.5 overflow-x-auto -mx-5 px-5 pb-0.5 [scrollbar-width:none]">
      {choix.map((c) => (
        <Link
          key={c.valeur}
          href={lien(c.valeur) as Route}
          aria-current={c.valeur === actif ? "true" : undefined}
          className={`shrink-0 h-[34px] px-3.5 rounded-pill border text-[12.5px] flex items-center gap-1.5 ${
            c.valeur === actif
              ? "bg-plum border-plum text-white"
              : "bg-surface border-line text-ink-soft"
          }`}
        >
          {c.libelle}
          {c.nombre !== undefined && (
            <span className={c.valeur === actif ? "text-white/70" : "text-ink-faint"}>
              {c.nombre}
            </span>
          )}
        </Link>
      ))}
    </div>
  );
}

/** Un chiffre et son libellé, en tête de liste. */
export function Stat({
  valeur,
  libelle,
  ton,
}: {
  valeur: number | string;
  libelle: string;
  ton?: "alerte";
}) {
  return (
    <div
      className={`flex-1 rounded-card border px-2 py-2.5 text-center ${
        ton === "alerte" ? "bg-red-soft border-red/20" : "bg-surface border-line"
      }`}
    >
      <div
        className={`font-display font-semibold text-[21px] leading-none tabular-nums ${
          ton === "alerte" ? "text-red" : "text-ink"
        }`}
      >
        {valeur}
      </div>
      <div className="etiquette mt-1 text-[8.5px]">{libelle}</div>
    </div>
  );
}

/**
 * Le mot cherché, marqué dans le texte.
 *
 * Filtrer ne suffit pas : sur un mois déplié qui porte quarante-sept lignes,
 * la liste dit « il y a quelque chose ici » sans dire OÙ. On relit tout pour
 * retrouver le mot qu'on vient de taper — et sur « 22 », qui est autant une
 * chambre qu'un numéro d'anomalie, on ne sait même pas ce qui a répondu.
 * Le mot se surligne donc là où il se trouve, comme dans un navigateur.
 *
 * Sans mot, le texte passe tel quel : aucun coût quand on ne cherche rien.
 */
export function Surligne({ texte, mot }: { texte: string; mot?: string }) {
  const cherche = (mot ?? "").trim().toLowerCase();
  if (!cherche || !texte) return <>{texte}</>;

  const bas = texte.toLowerCase();
  const morceaux: { t: string; marque: boolean }[] = [];
  let curseur = 0;
  for (let i = bas.indexOf(cherche); i !== -1; i = bas.indexOf(cherche, curseur)) {
    if (i > curseur) morceaux.push({ t: texte.slice(curseur, i), marque: false });
    morceaux.push({ t: texte.slice(i, i + cherche.length), marque: true });
    curseur = i + cherche.length;
  }
  if (morceaux.length === 0) return <>{texte}</>;
  if (curseur < texte.length) morceaux.push({ t: texte.slice(curseur), marque: false });

  return (
    <>
      {morceaux.map((m, i) =>
        m.marque ? (
          <mark
            key={i}
            className="rounded-[3px] bg-amber-soft px-[1px] text-amber font-medium"
          >
            {m.t}
          </mark>
        ) : (
          <span key={i}>{m.t}</span>
        ),
      )}
    </>
  );
}

/** La barre de recherche d'une liste, en GET : l'adresse reste partageable. */
export function Recherche({
  valeur,
  placeholder,
  caches,
}: {
  valeur: string;
  placeholder: string;
  caches?: Record<string, string>;
}) {
  return (
    <form method="get" className="flex gap-2">
      {Object.entries(caches ?? {}).map(([n, v]) => (
        <input key={n} type="hidden" name={n} value={v} />
      ))}
      <input
        name="q"
        defaultValue={valeur}
        autoComplete="off"
        placeholder={placeholder}
        className="carte grow px-4 h-[46px] text-[16px] placeholder:text-ink-faint"
      />
      <button className="px-4 rounded-card bg-surface border border-line text-[14.5px]">
        Chercher
      </button>
    </form>
  );
}
