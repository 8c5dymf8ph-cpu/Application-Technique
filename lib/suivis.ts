/**
 * Un code stable tiré d'un libellé : « Vérification des extincteurs » →
 * `verification-des-extincteurs`. Sert d'identifiant à une nature de dossier
 * et à ses étapes ; le libellé, lui, se corrige à volonté.
 */
export function codeDepuis(libelle: string): string {
  return (
    libelle
      .normalize("NFD")
      .replace(/[̀-ͯ]/g, "")
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "")
      .slice(0, 40) || "etape"
  );
}

/**
 * Une étape dont le nom dit qu'elle est LA visite du contrat compte pour le
 * rythme (« dernière visite il y a 400 jours, pour un rythme de 365 »). Ce
 * n'est qu'un point de départ : la case se décoche dans « Les étapes ».
 */
export function ressembleAUneVisite(libelle: string): boolean {
  return /visite|v[ée]rif|contr[ôo]le/i.test(libelle);
}

/** Les étapes proposées à la création d'un dossier — modifiables avant de créer. */
export const ETAPES_PROPOSEES = [
  "Visite de contrôle",
  "Rapport reçu",
  "Devis",
  "Intervention",
  "Note",
];

/** La nature d'une pièce jointe : ce qu'elle EST, pas seulement une facture. */
export const NATURES_PIECE = [
  { v: "document", l: "Un document" },
  { v: "rapport", l: "Un rapport" },
  { v: "attestation", l: "Une attestation" },
  { v: "contrat", l: "Un contrat" },
  { v: "devis", l: "Un devis" },
  { v: "facture", l: "Une facture" },
  { v: "photo", l: "Une photo" },
] as const;
