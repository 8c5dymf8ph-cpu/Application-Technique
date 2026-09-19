import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { peutValider } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";

export const dynamic = "force-dynamic";

type Ligne = {
  anomalie_donnee: string;
  anomalie_id: string | null;
  reference: number | null;
  emplacement: string | null;
  description: string | null;
  detail: string;
};

const FAMILLE: Record<string, { titre: string; aide: string; ton: string }> = {
  date_future: {
    titre: "Dates dans le futur",
    aide: "L’ancienne application acceptait n’importe quelle date. Corrigez-les au fil de l’eau.",
    ton: "text-amber",
  },
  localisation_incertaine: {
    titre: "Localisation incertaine",
    aide: "Rangées dans « Général » faute de mieux : le lieu d’origine est dans le commentaire de reprise.",
    ton: "text-amber",
  },
  stock_negatif: {
    titre: "Stock négatif",
    aide: "Plus de sorties que d’entrées : il manque des entrées anciennes. Un inventaire les remettra d’aplomb.",
    ton: "text-red",
  },
};

export default async function Controle() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!peutValider(profil.role)) redirect("/");

  const lignes = await sql<Ligne[]>`
    select anomalie_donnee, anomalie_id, reference, emplacement, description, detail
    from v_controle_donnees
    order by anomalie_donnee, emplacement nulls last, reference`;

  const familles = [...new Set(lignes.map((l) => l.anomalie_donnee))];

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Contrôle des données"
        sous_titre={`${lignes.length} point${lignes.length > 1 ? "s" : ""} à regarder`}
        retour="/administration"
      />

      <div className="px-5 py-4 flex flex-col gap-5">
        <p className="text-[13px] text-ink-soft text-pretty leading-snug">
          Rien ici n’est une erreur de l’application : ce sont les traces de ce que la reprise a
          trouvé de douteux. Elles restent visibles tant qu’elles ne sont pas corrigées, plutôt
          que d’être effacées en silence.
        </p>

        {lignes.length === 0 ? (
          <Vide>Rien à signaler. Les données reprises sont cohérentes.</Vide>
        ) : (
          familles.map((f) => {
            const dedans = lignes.filter((l) => l.anomalie_donnee === f);
            const meta = FAMILLE[f] ?? { titre: f, aide: "", ton: "text-ink-soft" };
            return (
              <section key={f} className="flex flex-col gap-2">
                <div className="flex items-baseline justify-between gap-3">
                  <h2 className={`etiquette ${meta.ton}`}>{meta.titre}</h2>
                  <span className="text-[12px] text-ink-faint tabular-nums">{dedans.length}</span>
                </div>
                {meta.aide && (
                  <p className="text-[11.5px] text-ink-faint text-pretty leading-snug -mt-1">
                    {meta.aide}
                  </p>
                )}
                <ul className="carte divide-y divide-line">
                  {dedans.map((l, i) => {
                    const contenu = (
                      <>
                        <span className="grow min-w-0">
                          <span className="flex items-center gap-2">
                            {l.emplacement && (
                              <span className="shrink-0 px-1.5 py-0.5 rounded-md bg-plum-soft text-plum text-[10.5px]">
                                {l.emplacement}
                              </span>
                            )}
                            <span className="text-[13.5px] leading-snug text-pretty truncate">
                              {l.description ?? "—"}
                            </span>
                          </span>
                          <span className="block text-[11.5px] text-ink-faint text-pretty mt-0.5">
                            {l.detail}
                          </span>
                        </span>
                      </>
                    );
                    return (
                      <li key={`${f}-${l.anomalie_id ?? i}`}>
                        {l.anomalie_id ? (
                          <Link
                            href={`/anomalie/${l.anomalie_id}` as Route}
                            className="px-3.5 py-2.5 flex items-center gap-3 active:bg-surface-muted"
                          >
                            {contenu}
                          </Link>
                        ) : (
                          <span className="px-3.5 py-2.5 flex items-center gap-3">{contenu}</span>
                        )}
                      </li>
                    );
                  })}
                </ul>
              </section>
            );
          })
        )}

        <Link
          href={"/administration" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Retour au paramétrage
        </Link>
      </div>
    </main>
  );
}
