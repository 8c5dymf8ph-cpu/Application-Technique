import type { Config } from "tailwindcss";

// Les couleurs et les polices viennent des maquettes : un seul jeu de valeurs
// pour toute l'application, référencé par son rôle et jamais en dur.
export default {
  content: ["./app/**/*.{ts,tsx}", "./lib/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        ground: "#F4F2F7",
        surface: { DEFAULT: "#FFFFFF", muted: "#FAF9FC" },
        ink: { DEFAULT: "#1B1930", soft: "#4F4B6B", faint: "#8E8AA3" },
        line: "#E7E4EF",
        plum: { DEFAULT: "#453A6E", soft: "#EDE9F5", ink: "#35305A" },
        amber: { DEFAULT: "#A8641F", soft: "#F6EEE3" },
        blue: { DEFAULT: "#3A6499", soft: "#E6EDF6" },
        green: { DEFAULT: "#357051", soft: "#E3EFE8" },
        red: { DEFAULT: "#9E3538", soft: "#F7E6E7" },
      },
      fontFamily: {
        display: ["var(--font-display)", "Georgia", "serif"],
        sans: ["var(--font-body)", "Georgia", "serif"],
      },
      borderRadius: { card: "14px", pill: "12px", tile: "18px" },
    },
  },
} satisfies Config;
