"use client";

import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { Vignettes } from "./galerie-photos";
import { EditeurMateriel, type ProduitDisponible } from "./editeur-materiel";

/**
 * Ouvrir une anomalie SANS aller-retour au serveur.
 *
 * Déplier une ligne passait par l'adresse (`?ouvre=…`) : chaque appui
 * redemandait la page entière, et le serveur refaisait onze requêtes à la
 * base, l'une après l'autre, avant de rendre la ligne ouverte. « Une latence
 * d'une seconde avant que le menu apparaisse. »
 *
 * Tout ce qu'il faut pour déclarer arrive maintenant AVEC la liste : le
 * catalogue une fois, les photos de chaque ligne, et ce qui a déjà servi pour
 * chaque problème. Ouvrir ne fait plus que montrer — instantané, même sans
 * réseau. L'adresse suit toujours (`?ouvre=`, par `history.replaceState`,
 * sans recharger) : un rechargement rouvre la même ligne.
 */

export type ProduitCatalogue = ProduitDisponible & {
  /** Sorties des dix-huit derniers mois, tous problèmes confondus. */
  courant: number;
};

/** Combien de fois un produit a servi pour un problème — par anomalie. */
export type DejaServi = {
  cle: string;
  produit_id: string;
  anomalie_id: string;
  fois: number;
};

export type DetailLigne = {
  anomalieId: string;
  /** `catalogue_id`, ou à défaut `d:` + la description : le « même problème ». */
  cle: string;
  description: string;
  essai: boolean;
  constat: string[];
  apres: string[];
  verifie: string[];
};

type Contexte = {
  ouvert: string | null;
  basculer: (id: string) => void;
  catalogue: ProduitCatalogue[];
  dejaServi: DejaServi[];
  action: (donnees: FormData) => void;
};

const Ctx = createContext<Contexte | null>(null);

function useOuverture(): Contexte {
  const c = useContext(Ctx);
  if (!c) throw new Error("OuvertureAnomalies manquant");
  return c;
}

export function OuvertureAnomalies({
  initial,
  catalogue,
  dejaServi,
  action,
  children,
}: {
  initial: string | null;
  catalogue: ProduitCatalogue[];
  dejaServi: DejaServi[];
  action: (donnees: FormData) => void;
  children: ReactNode;
}) {
  const [ouvert, setOuvert] = useState<string | null>(initial);

  // Après « C'est fait », le serveur renvoie la liste sans `ouvre` : la
  // ligne déclarée ne doit pas rester ouverte d'un rendu à l'autre.
  useEffect(() => setOuvert(initial), [initial]);

  const basculer = (id: string) => {
    const suivant = ouvert === id ? null : id;
    setOuvert(suivant);
    const url = new URL(window.location.href);
    if (suivant) url.searchParams.set("ouvre", suivant);
    else url.searchParams.delete("ouvre");
    window.history.replaceState(window.history.state, "", url);
  };

  return (
    <Ctx.Provider value={{ ouvert, basculer, catalogue, dejaServi, action }}>
      {children}
    </Ctx.Provider>
  );
}

/** La case : ouvre et referme, sans attendre personne. */
export function CaseOuvrir({ id }: { id: string }) {
  const { ouvert, basculer } = useOuverture();
  const actif = ouvert === id;
  return (
    <button
      type="button"
      onClick={() => basculer(id)}
      aria-expanded={actif}
      aria-label={actif ? "Replier cette anomalie" : "Traiter cette anomalie"}
      className={`w-[26px] h-[26px] min-h-0 mt-[1px] shrink-0 rounded-[7px] border-[2px] ${
        actif ? "border-plum bg-plum-soft" : "border-[#C9C5D8]"
      }`}
    />
  );
}

/** Le libellé : même geste que la case, sur toute la largeur du texte. */
export function TexteOuvrir({ id, children }: { id: string; children: ReactNode }) {
  const { basculer } = useOuverture();
  return (
    <button
      type="button"
      onClick={() => basculer(id)}
      className="grow min-w-0 flex flex-col gap-1 text-left active:opacity-70"
    >
      {children}
    </button>
  );
}

const MOTS_VIDES = new Set([
  "faut", "pour", "avec", "dans", "sous", "vers", "chez", "mais", "donc", "cette",
  "leur", "leurs", "tout", "tous", "toute", "toutes", "elle", "elles", "être",
  "avoir", "fait", "faire",
]);

/**
 * Le même ordre que celui que posait la requête : ce qui a déjà servi pour CE
 * problème, puis ce qui recoupe ses mots, puis ce qui est en réserve, puis ce
 * qui sort souvent, puis l'alphabet.
 */
function ordonner(catalogue: ProduitCatalogue[], dejaServi: DejaServi[], ligne: DetailLigne) {
  const deja = new Map<string, number>();
  for (const d of dejaServi) {
    if (d.cle !== ligne.cle || d.anomalie_id === ligne.anomalieId) continue;
    deja.set(d.produit_id, (deja.get(d.produit_id) ?? 0) + d.fois);
  }
  const mots = [
    ...new Set(
      ligne.description
        .toLowerCase()
        .split(/[^a-zàâäéèêëïîôöùûüç0-9]+/)
        .filter((m) => m.length >= 4 && !MOTS_VIDES.has(m)),
    ),
  ];
  const recoupe = (p: ProduitCatalogue) => {
    const d = p.designation.toLowerCase();
    return mots.some((m) => d.includes(m));
  };
  return [...catalogue].sort((a, b) => {
    const da = deja.get(a.id) ?? 0;
    const db = deja.get(b.id) ?? 0;
    return (
      Number(db > 0) - Number(da > 0) ||
      db - da ||
      Number(recoupe(b)) - Number(recoupe(a)) ||
      Number(b.stock > 0) - Number(a.stock > 0) ||
      b.courant - a.courant ||
      a.designation.localeCompare(b.designation, "fr")
    );
  });
}

/** Ce qui s'affiche sous la ligne ouverte — rien tant qu'elle est fermée. */
export function PanneauAnomalie({ ligne }: { ligne: DetailLigne }) {
  const { ouvert, catalogue, dejaServi, action } = useOuverture();
  if (ouvert !== ligne.anomalieId) return null;
  return (
    <div className="pb-4 flex flex-col gap-4 animate-[apparait_.18s_ease-out]">
      {ligne.essai && (
        <p className="text-[11.5px] text-ink-faint">Chambre d’essai · matériel non déduit du stock</p>
      )}
      <Vignettes chemins={ligne.constat} titre="Photographié au constat" ton="text-blue" taille={88} />
      <Vignettes chemins={ligne.apres} titre="Après le dernier passage" ton="text-green" taille={88} />
      <Vignettes chemins={ligne.verifie} titre="Vérifié par la gouvernante" ton="text-plum" taille={88} />
      <EditeurMateriel
        anomalieId={ligne.anomalieId}
        produits={ordonner(catalogue, dejaServi, ligne)}
        action={action}
      />
    </div>
  );
}
