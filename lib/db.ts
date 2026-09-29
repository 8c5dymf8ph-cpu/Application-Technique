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
    // L'hôtel est à Paris ; sans ça, `current_date` et `now()` côté SQL
    // (la date de création d'une commande, par exemple) suivent l'UTC du
    // serveur Postgres — et reculent d'un jour entre minuit et 1h ou 2h du
    // matin heure française. Même raison que FUSEAU_HOTEL dans lib/domaine.ts,
    // côté base plutôt que côté JS.
    connection: { TimeZone: "Europe/Paris" },
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
