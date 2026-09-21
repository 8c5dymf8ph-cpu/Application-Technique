import type { NextConfig } from "next";

const config: NextConfig = {
  // Les fichiers de migration doivent partir AVEC le déploiement : c'est
  // l'application qui les joue maintenant, depuis /administration. Sans cette
  // ligne, Vercel ne garde que ce que le code importe — un dossier lu à
  // l'exécution n'en fait pas partie, et le bouton ne trouverait rien.
  outputFileTracingIncludes: {
    "/administration": ["./supabase/migrations/**/*.sql"],
  },
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
