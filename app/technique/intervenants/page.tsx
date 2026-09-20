import { redirect } from "next/navigation";
import Link from "next/link";
import { sql } from "@/lib/db";
import { exigerEncadrement } from "@/lib/acces";
import { intervenants } from "@/lib/tournee";
import { Entete } from "@/app/composants/ui";

export const dynamic = "force-dynamic";

export default async function ChoixIntervenant() {
  const profil = await exigerEncadrement();

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
      <Entete titre="Technique" sous_titre="Qui intervient ?" retour="/technique" />
      <div className="px-5 py-5 flex flex-col gap-2">
        {/* Une seule liste, dépliée. Le pli séparait « l'équipe » des
            « intervenants extérieurs » et refermait les dix derniers : on
            croyait qu'il n'y avait que cinq noms. Et la distinction était
            fausse — Farid et Rachid ne sont pas plus de la maison que les
            autres, ils interviennent, comme tout le monde ici. */}
        <p className="text-[13.5px] text-ink-faint text-pretty">
          {liste.length} intervenants. Appuyez sur un nom pour ouvrir sa tournée.
        </p>

        {liste.map((i) => {
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
                <span className="font-display font-semibold text-[16.5px] truncate">
                  {i.nom}
                </span>
                <span className="text-[12.5px] text-ink-faint">
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
      </div>
    </main>
  );
}
