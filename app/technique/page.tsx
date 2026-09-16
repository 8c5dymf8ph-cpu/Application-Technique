import { redirect } from "next/navigation";
import Link from "next/link";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { intervenants } from "@/lib/tournee";
import { Entete } from "../composants/ui";

export const dynamic = "force-dynamic";

export default async function ChoixIntervenant() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  const liste = await intervenants();

  // Pour chacun, ce qu'il verrait dans sa section : tout s'il est polyvalent,
  // son seul métier s'il a une spécialité.
  const charges = await sql<{ nom: string; a_traiter: number; en_cours: number }[]>`
    select i.nom,
           count(a.*) filter (where a.statut = 'a_faire')::int  as a_traiter,
           count(a.*) filter (where a.statut = 'en_cours')::int as en_cours
    from v_intervenants i
    left join lateral fn_anomalies_pour_intervenant(i.nom) a on true
    where i.actif group by i.nom`;
  const charge = new Map(charges.map((c) => [c.nom, c]));

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Technique" sous_titre="Qui intervient ?" retour="/" />
      <div className="px-5 py-5 flex flex-col gap-5">
        {(["interne", "externe"] as const).map((origine) => {
          const dedans = liste.filter((i) => i.origine === origine);
          if (dedans.length === 0) return null;
          return (
            <section key={origine} className="flex flex-col gap-2">
              <h2 className="etiquette">
                {origine === "interne" ? "L’équipe" : "Intervenants extérieurs"}
              </h2>
              {dedans.map((i) => {
                const c = charge.get(i.nom);
                const cle = i.utilisateur_id ?? i.prestataire_id ?? "";
                return (
                  <Link
                    key={cle}
                    href={`/technique/${encodeURIComponent(i.nom)}`}
                    className="carte px-4 py-3.5 flex items-center gap-3.5 active:bg-surface-muted"
                  >
                    <span className="w-10 h-10 shrink-0 rounded-full bg-plum-soft grid place-items-center font-display font-semibold text-[14px] text-plum">
                      {i.nom.slice(0, 2).toUpperCase()}
                    </span>
                    <span className="flex flex-col grow min-w-0 gap-0.5">
                      <span className="font-display font-semibold text-[16px] truncate">
                        {i.nom}
                      </span>
                      <span className="text-[11.5px] text-ink-faint">
                        {i.specialites.length > 0
                          ? `${i.specialites.join(", ").toLowerCase()} uniquement`
                          : "toutes les anomalies"}
                      </span>
                    </span>
                    {c && c.a_traiter + c.en_cours > 0 && (
                      <span className="shrink-0 min-w-[30px] h-[30px] px-2 rounded-lg bg-amber-soft text-amber text-[14px] grid place-items-center tabular-nums">
                        {c.a_traiter + c.en_cours}
                      </span>
                    )}
                  </Link>
                );
              })}
            </section>
          );
        })}
      </div>
    </main>
  );
}
