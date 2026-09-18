/** La photo d'un produit, ou un repère tant qu'elle n'a pas été ajoutée. */
export function VignetteProduit({
  photo,
  taille = 44,
}: {
  photo: string | null;
  taille?: number;
}) {
  if (photo) {
    // eslint-disable-next-line @next/next/no-img-element
    return (
      <img
        src={`/photo/${photo}`}
        alt=""
        style={{ width: taille, height: taille }}
        className="shrink-0 rounded-[11px] object-cover border border-line bg-surface-muted"
      />
    );
  }
  return (
    <span
      style={{ width: taille, height: taille }}
      className="shrink-0 rounded-[11px] bg-plum-soft grid place-items-center"
      aria-hidden
    >
      <svg width={taille * 0.45} height={taille * 0.45} viewBox="0 0 24 24" fill="none"
           stroke="#8B86A8" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <rect x="3" y="5" width="18" height="14" rx="2" />
        <circle cx="9" cy="10.5" r="1.8" />
        <path d="M3 16l4.5-4 4 3.5L15.5 11l5.5 5" />
      </svg>
    </span>
  );
}

/**
 * Où en est le stock face à son seuil.
 *
 * Trois états, trois couleurs, la même partout : à zéro c'est rouge, sous le
 * seuil c'est ambre, au-dessus c'est vert. La barre se lit de loin, le chiffre
 * confirme. Le seuil est marqué sur la piste : on voit d'un coup combien il
 * reste avant de recommander.
 */
export function JaugeStock({
  stock,
  seuil,
  unite,
  hauteur = 8,
  avecChiffre = true,
}: {
  stock: number;
  seuil: number;
  unite?: string;
  hauteur?: number;
  /** Faux quand le chiffre est déjà affiché ailleurs sur la ligne. */
  avecChiffre?: boolean;
}) {
  const rupture = stock <= 0;
  const sous = stock <= seuil;
  // La piste va jusqu'au double du seuil, ou jusqu'au stock s'il le dépasse :
  // un produit largement fourni ne doit pas écraser la lecture du seuil.
  const plafond = Math.max(seuil * 2, stock, 1);
  const part = Math.max(rupture ? 0 : 3, (stock / plafond) * 100);
  const repere = (seuil / plafond) * 100;
  const ton = rupture ? "#9E3538" : sous ? "#A8641F" : "#357051";

  return (
    <span className="flex items-center gap-2.5">
      <span
        className="grow min-w-0 relative rounded-[3px] bg-[#EFEDF4]"
        style={{ height: hauteur }}
      >
        <span
          className="block h-full rounded-[3px]"
          style={{ width: `${Math.min(100, part)}%`, background: ton }}
        />
        {seuil > 0 && (
          <span
            aria-hidden
            title={`Seuil : ${seuil}`}
            className="absolute top-[-2px] bottom-[-2px] w-[2px] bg-ink-faint"
            style={{ left: `${Math.min(100, repere)}%` }}
          />
        )}
      </span>
      {avecChiffre && (
        <span className="shrink-0 flex items-baseline gap-1">
          <span
            className="font-display font-semibold text-[15px] tabular-nums"
            style={{ color: ton }}
          >
            {stock}
          </span>
          {unite && unite !== "unité" && (
            <span className="text-[10.5px] text-ink-faint">{unite}</span>
          )}
        </span>
      )}
    </span>
  );
}

/** L'état en un mot, pour les endroits où la barre ne tient pas. */
export function EtatStock({ stock, seuil }: { stock: number; seuil: number }) {
  const rupture = stock <= 0;
  const sous = stock <= seuil;
  return (
    <span
      className={`px-2 py-0.5 rounded-md text-[11.5px] ${
        rupture
          ? "bg-red-soft text-red"
          : sous
            ? "bg-amber-soft text-amber"
            : "bg-green-soft text-green"
      }`}
    >
      {rupture ? "Épuisé" : sous ? "Seuil bas" : "En stock"}
    </span>
  );
}
