import { redirect } from "next/navigation";
import type { Route } from "next";
import { profilActif, type Profil } from "./profil";
import { peutValider } from "./domaine";

/**
 * Qui voit quoi.
 *
 * Un technicien vient faire des anomalies : il n'a pas à voir ce qu'a coûté le
 * passage d'un confrère, ni les factures, ni la valeur du stock. Il n'a pas non
 * plus à désigner qui intervient — c'est une décision d'encadrement.
 *
 * Trois personnes encadrent : Victoria, Miguel et Sarah P. C'est exactement ce
 * que `peutValider` recouvre, et on ne recrée pas une seconde liste.
 */

/**
 * Sa tournée, la seule page qu'un intervenant ait besoin d'ouvrir.
 *
 * Une adresse fixe, sans son nom dedans : un nom qui ne correspondait pas
 * exactement à la liste des intervenants donnait un 404 muet.
 */
export function saTournee(_profil?: Profil): Route {
  return "/technique/ma-tournee" as Route;
}

/** Un écran réservé à l'encadrement : l'intervenant est renvoyé chez lui. */
export async function exigerEncadrement(): Promise<Profil> {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!peutValider(profil.role)) redirect(saTournee(profil));
  return profil;
}
