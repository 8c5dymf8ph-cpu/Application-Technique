/**
 * Les pictogrammes de l'accueil, en pâte.
 *
 * Ce sont les mêmes dessins qu'avant — la coche dans son cercle, la clé, la
 * goutte, le carton, les curseurs — et rien d'autre ne change que la matière :
 * un trait épais et arrondi comme un boudin, la couleur du menu qui fonce vers
 * le bas, un reflet clair sur le bord haut-gauche, une ombre douce sur le bord
 * bas-droit et une petite ombre portée qui les pose sur leur palet. Essayé
 * d'abord avec des objets redessinés (planchette, bouteilles, engrenage) :
 * « il ne fallait pas forcément changer, juste les améliorer ».
 *
 * Tout est dans le SVG — aucune image à charger, net à toutes les tailles.
 * Les identifiants de dégradé et de filtre portent le nom de l'icône : une
 * icône ne paraît qu'une fois par écran.
 */

export type NomIcone = "gouvernante" | "technique" | "bouteilles" | "stock" | "administration";

type Teinte = { clair: string; fonce: string; doux: string };

const TEINTES: Record<NomIcone, Teinte> = {
  gouvernante: { clair: "#8577C2", fonce: "#453A6E", doux: "#EDE9F5" },
  technique: { clair: "#62B087", fonce: "#2E6448", doux: "#E3EFE8" },
  bouteilles: { clair: "#6E9AD3", fonce: "#33598A", doux: "#E6EDF6" },
  stock: { clair: "#E3A458", fonce: "#94561A", doux: "#F6EEE3" },
  administration: { clair: "#8C87AE", fonce: "#46425F", doux: "#F1EFF6" },
};

const CLE =
  "M14.7 6.3a1 1 0 000 1.4l1.6 1.6a1 1 0 001.4 0l3.77-3.77a6 6 0 01-7.94 7.94l-6.91 6.91a2.12 2.12 0 01-3-3l6.91-6.91a6 6 0 017.94-7.94z";

export function IconePate({ nom, taille = 38 }: { nom: NomIcone; taille?: number }) {
  const t = TEINTES[nom];
  const degrade = `pate-${nom}-d`;
  const filtre = `pate-${nom}-f`;
  const couleur = `url(#${degrade})`;
  // Un trait : un boudin de pâte. Une forme fermée : remplie de la couleur
  // douce du menu, ce qui lui donne du volume sans changer le dessin.
  const trait = {
    stroke: couleur,
    strokeWidth: 3.1,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };

  return (
    <svg
      width={taille}
      height={taille}
      viewBox="0 0 24 24"
      fill="none"
      aria-hidden
      style={{ overflow: "visible" }}
    >
      <defs>
        <linearGradient id={degrade} x1="0" y1="3" x2="0" y2="21" gradientUnits="userSpaceOnUse">
          <stop offset="0" stopColor={t.clair} />
          <stop offset="1" stopColor={t.fonce} />
        </linearGradient>
        <filter
          id={filtre}
          x="-40%"
          y="-40%"
          width="180%"
          height="190%"
          colorInterpolationFilters="sRGB"
        >
          {/* L'ombre intérieure, sur le bord bas-droit. */}
          <feOffset in="SourceAlpha" dx="-.55" dy="-.75" result="o1" />
          <feGaussianBlur in="o1" stdDeviation=".45" result="b1" />
          <feComposite in="SourceAlpha" in2="b1" operator="arithmetic" k2="1" k3="-1" result="e1" />
          <feFlood floodColor={t.fonce} floodOpacity=".55" />
          <feComposite in2="e1" operator="in" result="ombre" />
          {/* Le reflet, sur le bord haut-gauche. */}
          <feOffset in="SourceAlpha" dx=".5" dy=".7" result="o2" />
          <feGaussianBlur in="o2" stdDeviation=".4" result="b2" />
          <feComposite in="SourceAlpha" in2="b2" operator="arithmetic" k2="1" k3="-1" result="e2" />
          <feFlood floodColor="#fff" floodOpacity=".8" />
          <feComposite in2="e2" operator="in" result="reflet" />
          {/* L'ombre portée, de la couleur de l'objet. */}
          <feGaussianBlur in="SourceAlpha" stdDeviation=".55" result="db" />
          <feOffset in="db" dx=".2" dy=".9" result="do" />
          <feFlood floodColor={t.fonce} floodOpacity=".28" />
          <feComposite in2="do" operator="in" result="portee" />
          <feMerge>
            <feMergeNode in="portee" />
            <feMergeNode in="SourceGraphic" />
            <feMergeNode in="ombre" />
            <feMergeNode in="reflet" />
          </feMerge>
        </filter>
      </defs>
      <g filter={`url(#${filtre})`}>
        {nom === "gouvernante" && (
          <>
            <circle cx="12" cy="12" r="8.4" fill={t.doux} {...trait} />
            <path d="M8.4 12.3l2.3 2.3 4.7-5.1" {...trait} />
          </>
        )}
        {nom === "technique" && (
          // La clé, pleine : la même silhouette, comme un objet modelé.
          <path d={CLE} fill={couleur} {...trait} strokeWidth={2.2} />
        )}
        {nom === "bouteilles" && (
          <path d="M12 3s6 6.5 6 11a6 6 0 01-12 0c0-4.5 6-11 6-11z" fill={t.doux} {...trait} />
        )}
        {nom === "stock" && (
          // Le carton : ses trois faces prennent chacune leur teinte.
          <>
            <path d="M3.5 8.5V16L12 20.5V13z" fill="#EDC48F" />
            <path d="M20.5 8.5V16L12 20.5V13z" fill="#DDA868" />
            <path d="M3.5 8.5L12 4l8.5 4.5L12 13z" fill="#FAE6CB" {...trait} />
            <path d="M3.5 8.5V16L12 20.5 20.5 16V8.5" {...trait} />
            <path d="M12 13v7.5" {...trait} />
          </>
        )}
        {nom === "administration" && (
          <>
            <path d="M4 7h9M17 7h3M4 17h3M11 17h9" {...trait} />
            <circle cx="15" cy="7" r="2.5" fill="#F6F4FA" {...trait} strokeWidth={2.6} />
            <circle cx="8" cy="17" r="2.5" fill="#F6F4FA" {...trait} strokeWidth={2.6} />
          </>
        )}
      </g>
    </svg>
  );
}
