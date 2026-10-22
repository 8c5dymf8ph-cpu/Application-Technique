import type { Metadata, Viewport } from "next";
import { Playfair_Display, Source_Serif_4 } from "next/font/google";
import "./globals.css";
import { Parcours } from "./composants/parcours";
import { RelireEnRevenant } from "./composants/relire-en-revenant";
import { HauteurReelle } from "./composants/hauteur-reelle";

const display = Playfair_Display({
  subsets: ["latin"],
  weight: ["500", "600", "700"],
  variable: "--font-display",
});
// Le texte courant est dessiné pour sa taille : Source Serif porte un axe
// optique, qui ouvre les petites lettres et affine les grandes. Sans lui, la
// même lettre sert à 11 px comme à 17 px, et les mentions s'empâtent.
const body = Source_Serif_4({
  subsets: ["latin"],
  axes: ["opsz"],
  variable: "--font-body",
});

export const metadata: Metadata = {
  title: "Application Technique — Parisianer",
  description: "Interventions, stock et bouteilles de l'Hôtel Parisianer",
  manifest: "/manifest.webmanifest",
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#453A6E",
  // L'application s'installe sur l'écran d'accueil : elle doit passer sous
  // l'encoche sans que son contenu s'y cache.
  viewportFit: "cover",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="fr" className={`${display.variable} ${body.variable}`}>
      <body>
        {/* Compte nos écrans, pour que le retour sache s'il y a quelque chose
            derrière. Il doit voir tous les changements d'écran, y compris ceux
            qui n'ont pas de bouton retour : sa place est ici. */}
        <Parcours />
        {/* La vraie hauteur d'écran, mesurée plutôt que devinée par `dvh` —
            voir composants/hauteur-reelle.tsx pour pourquoi. */}
        <HauteurReelle />
        {/* Revenir sur un écran, c'est le redemander au serveur. Posé ICI et
            pas écran par écran : dix-sept écrans écrivaient sans la
            protection, et on retrouvait le formulaire qu'on venait
            d'envoyer — « un contrôle Z partiel ». */}
        <RelireEnRevenant />
        {children}
      </body>
    </html>
  );
}
