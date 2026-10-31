import type { MetadataRoute } from "next";

// Une application d'hôtel n'a rien à faire dans un moteur de recherche : si son
// adresse traîne quelque part, elle ne doit pas en sortir pour autant.
export default function robots(): MetadataRoute.Robots {
  return { rules: { userAgent: "*", disallow: "/" } };
}
