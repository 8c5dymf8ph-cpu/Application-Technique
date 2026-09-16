import type { MetadataRoute } from "next";

// C'est ce fichier qui permet d'ajouter l'application à l'écran d'accueil
// du téléphone et de l'ouvrir en plein écran, sans passer par un magasin.
export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Application Technique — Parisianer",
    short_name: "Parisianer",
    description: "Interventions, stock et bouteilles de l'Hôtel Parisianer",
    start_url: "/",
    display: "standalone",
    background_color: "#F4F2F7",
    theme_color: "#453A6E",
    lang: "fr",
  };
}
