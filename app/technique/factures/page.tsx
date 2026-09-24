import { redirect } from "next/navigation";
import type { Route } from "next";

/**
 * Les factures ne sont plus un écran à part.
 *
 * « Je ne veux pas de pont, je veux réellement que les deux écrans soient un
 * seul et même écran. » Un passage et une facture sont deux lectures d'une
 * même chose : ce que l'hôtel a fait faire, et ce qu'il paye. Elles vivent
 * donc sur le même écran, en deux onglets.
 *
 * Cette adresse reste pour les liens déjà partagés et l'application lancée
 * depuis l'écran d'accueil ; elle mène à l'onglet des factures.
 */
export default function Factures() {
  redirect("/technique/historique?vue=factures" as Route);
}
