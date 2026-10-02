"use client";

import { useEffect } from "react";
import { usePathname, useRouter } from "next/navigation";

/**
 * Revenir sur un écran, c'est le redemander au serveur.
 *
 * Le routeur garde la page qu'on quitte et la ressort telle quelle à la flèche
 * arrière — c'est ce qui rend la position de lecture, et c'est une bonne chose
 * sur un écran de lecture. Mais l'application est faite d'écrans qui CHANGENT
 * quand on les quitte : on rapproche une facture, on valide un lot, on joue
 * les migrations, on déclare une perte. On revient, et l'écran ressort le
 * formulaire rempli, le bouton encore actif, le travail encore à faire.
 * « Le retour en arrière fonctionne comme un contrôle Z partiel. »
 *
 * Ce n'était corrigé qu'écran par écran, avec `RelireAuRetour` posé à la main :
 * dix-sept écrans écrivaient sans l'avoir. Une règle appliquée à un endroit et
 * pas à l'autre ne vaut rien — alors elle est posée UNE fois, dans la mise en
 * page, et vaut pour tout.
 *
 * On note le chemin au premier passage. Si l'on y revient, on redemande la
 * page : `router.refresh()` garde la position de défilement et ne recharge que
 * ce qui a changé. Sur le wifi de l'hôtel, c'est un aller-retour, et ce qui
 * s'affiche est vrai.
 *
 * **Un technicien qui rouvre l'application le lendemain n'y « revient » pas,
 * au sens de React : rien ne se démonte.** Un téléphone ne ferme pas une
 * page quittée, il la gèle — le `bfcache` du navigateur. On l'a rouverte un
 * autre jour et on y a retrouvé le passage de la veille, « rendu à 23:42 »,
 * proposé à la reprise comme s'il datait d'aujourd'hui : rien n'avait tourné
 * depuis la veille, pas même cet effet, puisque la page gelée ne se remonte
 * pas. Le navigateur prévient de ce dégel précis — `pageshow` avec
 * `persisted` à vrai.
 *
 * Ça ne suffisait pas. « J'ai toujours la même erreur » — un téléphone
 * verrouillé puis rouvert, un passage à une autre application puis un
 * retour : ni bfcache ni navigation, le système suspend l'onglet sans le
 * décharger, et aucun `pageshow` ne prévient de ce réveil-là. C'est la
 * gouvernante qui validait un lot et retrouvait, en y revenant,
 * l'anomalie qu'elle venait de trancher — le formulaire d'une minute plus
 * tôt, figé. Le seul signal qui couvre CE cas est la visibilité de la page
 * (`visibilitychange`) : on redemande la page chaque fois qu'elle redevient
 * visible, pas seulement au dégel d'un bfcache. Un aller-retour de plus sur
 * le wifi de l'hôtel ne coûte rien ; une décision qu'on croit prise et qui
 * ne l'était pas, si.
 */
export function RelireEnRevenant() {
  const chemin = usePathname();
  const routeur = useRouter();

  useEffect(() => {
    if (!chemin) return;
    const marque = `vu:${chemin}`;
    try {
      if (sessionStorage.getItem(marque)) {
        routeur.refresh();
      } else {
        sessionStorage.setItem(marque, "1");
      }
    } catch {
      // Navigation privée, stockage refusé : on ne rafraîchit pas, et la page
      // reste utilisable. Rien ne dépend de cette marque.
    }
  }, [chemin, routeur]);

  useEffect(() => {
    const auReveil = (e: PageTransitionEvent) => {
      if (e.persisted) routeur.refresh();
    };
    window.addEventListener("pageshow", auReveil);
    return () => window.removeEventListener("pageshow", auReveil);
  }, [routeur]);

  useEffect(() => {
    const auRetourVisible = () => {
      if (document.visibilityState === "visible") routeur.refresh();
    };
    document.addEventListener("visibilitychange", auRetourVisible);
    return () => document.removeEventListener("visibilitychange", auRetourVisible);
  }, [routeur]);

  return null;
}
