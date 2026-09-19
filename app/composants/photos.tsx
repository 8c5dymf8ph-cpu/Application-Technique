// Le champ de saisie est un composant client : il réduit les images avant
// l'envoi. Il est réexporté ici pour que les écrans n'aient qu'un import.
export { ChampPhotos } from "./champ-photos";

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
