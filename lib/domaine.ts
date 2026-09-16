/** Les valeurs du domaine, telles qu'elles sont définies en base. */

export type StatutAnomalie =
  | "a_faire"
  | "en_cours"
  | "attente_validation"
  | "validee"
  | "a_acheter"
  | "annulee";

export const LIBELLE_STATUT: Record<StatutAnomalie, string> = {
  a_faire: "À faire",
  en_cours: "En cours",
  attente_validation: "En attente de validation",
  validee: "Validée",
  a_acheter: "Achat à faire",
  annulee: "Annulée",
};

/** Chaque statut a sa couleur, la même partout dans l'application. */
export const TON_STATUT: Record<StatutAnomalie, { fond: string; texte: string }> = {
  a_faire: { fond: "bg-amber-soft", texte: "text-amber" },
  en_cours: { fond: "bg-blue-soft", texte: "text-blue" },
  attente_validation: { fond: "bg-plum-soft", texte: "text-plum" },
  validee: { fond: "bg-green-soft", texte: "text-green" },
  a_acheter: { fond: "bg-red-soft", texte: "text-red" },
  annulee: { fond: "bg-surface-muted", texte: "text-ink-faint" },
};

export type RoleUtilisateur = "technicien" | "gouvernante" | "admin" | "lecture";

export const LIBELLE_ROLE: Record<RoleUtilisateur, string> = {
  technicien: "Technicien",
  gouvernante: "Gouvernante",
  admin: "Administrateur",
  lecture: "Lecture seule",
};

export function jours(n: number): string {
  if (n <= 0) return "aujourd'hui";
  if (n === 1) return "hier";
  if (n < 31) return `il y a ${n} jours`;
  if (n < 365) return `il y a ${Math.round(n / 30)} mois`;
  const annees = Math.round(n / 365);
  return annees === 1 ? "il y a un an" : `il y a ${annees} ans`;
}

export function euros(n: number | null): string {
  if (n === null || n === undefined) return "—";
  return n.toLocaleString("fr-FR", { style: "currency", currency: "EUR" });
}
