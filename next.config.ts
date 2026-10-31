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
  // Les protections de navigateur, posées sur toutes les réponses — écrans,
  // photos, factures PDF :
  // - personne d'autre ne peut afficher l'application dans un cadre (on la
  //   ferait passer pour un autre site) ; elle, si — la facture PDF s'ouvre
  //   dans un cadre de la même origine (`VoirDocument`) ;
  // - le navigateur ne devine pas le type d'un fichier : une « photo » ne
  //   s'exécute jamais comme une page ;
  // - un site ouvert depuis l'application ne reçoit pas l'adresse d'où l'on
  //   vient ;
  // - l'appareil photo reste permis (les photos du constat), le micro et la
  //   position non ;
  // - toujours en HTTPS, et jamais dans un moteur de recherche.
  async headers() {
    return [
      {
        source: "/:path*",
        headers: [
          { key: "X-Frame-Options", value: "SAMEORIGIN" },
          { key: "Content-Security-Policy", value: "frame-ancestors 'self'" },
          { key: "X-Content-Type-Options", value: "nosniff" },
          { key: "Referrer-Policy", value: "same-origin" },
          { key: "Permissions-Policy", value: "camera=(self), microphone=(), geolocation=()" },
          { key: "Strict-Transport-Security", value: "max-age=63072000; includeSubDomains" },
          { key: "X-Robots-Tag", value: "noindex, nofollow" },
        ],
      },
    ];
  },
  experimental: {
    typedRoutes: true,
    // Vercel coupe toute requête de plus de 4,5 Mo (413) : annoncer plus ne
    // sert qu'à voir l'envoi échouer en ligne après avoir marché en local.
    // Les photos sont réduites dans le navigateur avant de partir.
    serverActions: { bodySizeLimit: "4mb" },
  },
};

export default config;
