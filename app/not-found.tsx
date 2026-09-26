import { Entete, Vide } from "@/app/composants/ui";
import { RevenirSiSupprime } from "@/app/composants/quitter-si-revenu";

/**
 * Une adresse qui ne mène nulle part.
 *
 * Le cas le plus courant : on vient de confirmer une suppression — dossier
 * bouteille, anomalie, facture — et on revient en arrière sur la fiche
 * disparue. `RevenirSiSupprime` rattrape ce cas précis en silence, sans
 * jamais laisser voir cet écran. Ce qui reste ici, c'est le lien partagé
 * depuis longtemps ou l'adresse mal tapée — un vrai dépliant vide, pas la
 * page blanche de Next.
 */
export default function IntrouvableGlobal() {
  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <RevenirSiSupprime />
      <Entete titre="Page introuvable" />
      <div className="px-5 py-4">
        <Vide>
          Cette adresse ne correspond à rien — la page a peut-être été supprimée, ou le lien
          est ancien. La maison, en haut à droite, ramène toujours à l’accueil.
        </Vide>
      </div>
    </main>
  );
}
