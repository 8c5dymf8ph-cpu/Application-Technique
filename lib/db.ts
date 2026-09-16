import postgres from "postgres";

/**
 * Accès à la base. Une seule connexion partagée, réutilisée entre les rendus —
 * Next recharge les modules en développement, d'où le passage par globalThis.
 *
 * La même chaîne de connexion sert en local et sur Supabase : c'est du
 * PostgreSQL des deux côtés.
 */
const global_ = globalThis as unknown as { sql?: postgres.Sql };

export const sql =
  global_.sql ??
  postgres(process.env.DATABASE_URL ?? "postgres://postgres@localhost:55432/reel", {
    // Les vues de calcul renvoient des numeric ; on les veut en nombres et non
    // en chaînes, sinon chaque addition côté interface serait une concaténation.
    types: {
      numeric: {
        to: 1700,
        from: [1700],
        serialize: (x: number) => String(x),
        parse: (x: string) => Number(x),
      },
    },
  });

if (process.env.NODE_ENV !== "production") global_.sql = sql;
