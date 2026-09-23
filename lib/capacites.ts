import {
  colonneExiste,
  inventaireDeRepriseRetire,
  regleContient,
  vueContient,
  vueExiste,
} from "./schema";

/**
 * Ce que la base sait déjà faire.
 *
 * Le code part en ligne dès qu'il est poussé ; une migration s'applique à la
 * main, plus tard. Entre les deux, un écran affiche un bouton qui ne peut rien
 * enregistrer — et rien ne dit pourquoi. « Donner un profil ne fonctionne
 * pas » : le bouton était grisé parce que la colonne n'existait pas encore.
 *
 * Plutôt que de le deviner écran par écran, on le demande une fois et on
 * l'affiche en clair dans `/administration`, avec le geste qui débloque.
 */
export type Capacite = {
  titre: string;
  /** Ce qui ne marche pas tant que la base n'a pas été mise à jour. */
  sans: string;
  prete: boolean;
};

type Attendue = Omit<Capacite, "prete"> & { verifier: () => Promise<boolean> };

const ATTENDUES: Attendue[] = [
  {
    titre: "Profils des intervenants",
    sans: "Le bouton « Donner un profil » de l’écran Équipe reste grisé, et les adresses de récapitulatif ne s’enregistrent pas.",
    verifier: () => colonneExiste("utilisateurs", "peut_se_connecter"),
  },
  {
    titre: "Suppression d’une anomalie",
    sans: "Victoria ne peut pas supprimer une anomalie déclarée par erreur ; Sarah P et Miguel le peuvent déjà.",
    verifier: () => regleContient("fn_peut_supprimer", "gouvernante"),
  },
  {
    titre: "Date du dernier essai d’envoi",
    sans: "L’erreur d’un courriel s’affiche sans dire de quand elle date : un refus d’il y a deux jours passe pour un refus de maintenant.",
    verifier: () => colonneExiste("emails_envoyes", "dernier_essai_le"),
  },
  {
    titre: "Qui émet des factures",
    sans: "Une facture de Farid ou de Rachid ne peut pas être rattachée à leur nom.",
    verifier: () => colonneExiste("factures", "technicien_id"),
  },
  {
    titre: "Chambres d’essai 06 et 07",
    sans: "Les essais faits en 06 et 07 comptent dans les chiffres de l’hôtel.",
    verifier: () => colonneExiste("emplacements", "essai"),
  },
  {
    titre: "Un essai ne touche pas le stock",
    sans: "Du matériel coché pour une anomalie en 06 ou 07 est déduit de la réserve pour de bon, et compte dans le coût du passage.",
    verifier: () => vueExiste("v_mouvements_reels"),
  },
  {
    titre: "Corriger un dossier bouteille",
    sans: "La date, la chambre et les types d’un dossier ne se corrigent pas : un dossier d’il y a trois semaines arrive daté d’aujourd’hui, et une erreur de chambre reste pour toujours.",
    verifier: () => regleContient("fn_corriger_dossier_bouteille", "dotation"),
  },
  {
    titre: "Un passage suit sa date",
    sans: "Corriger la date d’une intervention la laisse accrochée au passage du mauvais jour : la facture ne se rapproche plus.",
    verifier: () => regleContient("fn_regrouper_les_passages", "INT-REPRISE-"),
  },
  {
    titre: "Ce qui attend vraiment la gouvernante",
    sans: "L’écran « À valider » annonce des centaines d’anomalies à valider — de l’historique clos dans l’ancienne application, que personne n’a jamais eu à vérifier.",
    verifier: () => vueContient("v_tournees", "attente_validation"),
  },
  {
    titre: "Le stock réel, sans les ajustements de l’ancienne application",
    sans: "Le stock porte encore vingt-deux régularisations qui visaient le chiffre affiché par l’ancienne application — un chiffre faux, puisqu’elle ignorait 249 mouvements sur 261.",
    verifier: () => inventaireDeRepriseRetire(),
  },
  {
    titre: "Un passage par intervenant et par jour",
    sans: "Revenir l’après-midi ouvre un second passage : l’historique montre trois journées pour une, et le récapitulatif part autant de fois.",
    verifier: () =>
      regleContient("fn_fusionner_les_passages_du_jour", "v_fusionnes"),
  },
  {
    titre: "Fournisseurs de bouteilles",
    sans: "Culligan apparaît dans la liste des fournisseurs d’un joint de robinet.",
    verifier: () => colonneExiste("fournisseurs", "pour_bouteilles"),
  },
];

export async function capacites(): Promise<Capacite[]> {
  return Promise.all(
    ATTENDUES.map(async ({ verifier, ...c }) => ({ ...c, prete: await verifier() })),
  );
}
