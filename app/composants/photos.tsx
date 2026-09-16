/** Le champ de prise de photo, identique partout où l'on en ajoute. */
export function ChampPhotos({
  nom = "photos",
  libelle = "Ajouter une ou plusieurs photos",
}: {
  nom?: string;
  libelle?: string;
}) {
  return (
    <label
      data-cible
      className="carte px-4 py-3.5 flex items-center gap-3 cursor-pointer active:bg-surface-muted"
    >
      <span className="w-10 h-10 shrink-0 rounded-[11px] bg-plum-soft grid place-items-center">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#453A6E"
             strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
          <path d="M4 8a2 2 0 0 1 2-2h2l1.2-1.6A1 1 0 0 1 10 4h4a1 1 0 0 1 .8.4L16 6h2a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z" />
          <circle cx="12" cy="12.5" r="3.2" />
        </svg>
      </span>
      <span className="text-[14.5px] text-ink-soft grow">{libelle}</span>
      <input
        type="file"
        name={nom}
        multiple
        accept="image/*"
        capture="environment"
        className="sr-only"
      />
    </label>
  );
}

/** Les vignettes d'une série de photos. */
export function Vignettes({
  chemins,
  titre,
  ton = "text-ink-faint",
}: {
  chemins: string[];
  titre: string;
  ton?: string;
}) {
  if (chemins.length === 0) return null;
  return (
    <div className="flex flex-col gap-1.5">
      <span className={`text-[11.5px] ${ton}`}>{titre}</span>
      <div className="flex flex-wrap gap-1.5">
        {chemins.map((c) => (
          <a key={c} href={`/photo/${c}`} target="_blank" rel="noreferrer">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={`/photo/${c}`}
              alt="Photo de l’anomalie"
              className="w-[74px] h-[74px] object-cover rounded-[11px] border border-line bg-surface-muted"
            />
          </a>
        ))}
      </div>
    </div>
  );
}
