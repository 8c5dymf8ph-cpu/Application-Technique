import type { NextConfig } from "next";

const config: NextConfig = {
  // L'application est servie sur téléphone et sur ordinateur ; rien de statique
  // n'est pré-rendu puisque tout dépend des données et du profil actif.
  experimental: { typedRoutes: true },
};

export default config;
