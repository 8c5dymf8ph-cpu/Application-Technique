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

export type RoleUtilisateur =
  | "technicien"
  | "gouvernante"
  | "operations"
  | "admin"
  | "lecture"
  | "menage"
  | "reception";

export const LIBELLE_ROLE: Record<RoleUtilisateur, string> = {
  technicien: "Technicien",
  gouvernante: "Gouvernante",
  operations: "Chargée des opérations",
  admin: "Administrateur",
  lecture: "Lecture seule",
  menage: "Femme de chambre",
  reception: "Réception",
};

/**
 * Le suivi des dossiers, les commandes et les rapports sont le travail de
 * l'administration. La gouvernante déclare, remplace et compte : ce sont ses
 * écrans, et ils ne doivent pas se noyer dans les autres.
 */
export function suitLesDossiers(role?: RoleUtilisateur): boolean {
  return role === "operations" || role === "admin";
}

/** Déclarer une anomalie, et la valider au nom d'un intervenant. */
export function peutValider(role?: RoleUtilisateur): boolean {
  return role === "gouvernante" || role === "operations" || role === "admin";
}

/**
 * Supprimer une anomalie efface une trace : trois personnes, pas plus.
 *
 * Victoria, Sarah P et Miguel. C'est la gouvernante qui déclare, donc c'est
 * elle qui se trompe de chambre ou déclare deux fois le même robinet :
 * l'obliger à attendre quelqu'un d'autre pour défaire son propre geste n'avait
 * pas de sens. Le technicien, lui, traite — il ne décide pas de ce qui existe.
 */
export function peutSupprimer(role?: RoleUtilisateur): boolean {
  return role === "gouvernante" || role === "operations" || role === "admin";
}

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

/**
 * Une date au format d'un champ `<input type="date">`.
 *
 * Le pilote PostgreSQL rend les colonnes `date` sous forme d'objet Date, pas de
 * chaîne : découper la chaîne à la main échoue en production alors que tout
 * passe au typage. Cette fonction accepte les deux.
 */
export function jourISO(v: string | Date | null | undefined): string {
  if (!v) return "";
  const d = v instanceof Date ? v : new Date(v);
  if (Number.isNaN(d.getTime())) return "";
  // En heure locale : une date de facture ne doit pas reculer d'un jour.
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(
    d.getDate(),
  ).padStart(2, "0")}`;
}

/** La date du jour, pour la valeur par défaut d'un champ date. */
export function aujourdhuiISO(): string {
  return jourISO(new Date());
}
