import type { NextConfig } from "next";

const config: NextConfig = {
  // L'application est servie sur téléphone et sur ordinateur ; rien de statique
  // n'est pré-rendu puisque tout dépend des données et du profil actif.
  experimental: {
    typedRoutes: true,
    // Vercel coupe toute requête de plus de 4,5 Mo (413) : annoncer plus ne
    // sert qu'à voir l'envoi échouer en ligne après avoir marché en local.
    // Les photos sont réduites dans le navigateur avant de partir.
    serverActions: { bodySizeLimit: "4mb" },
  },
};

export default config;
