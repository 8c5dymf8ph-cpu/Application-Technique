import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { colonneExiste } from "@/lib/schema";
import { peutValider } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";

export const dynamic = "force-dynamic";

type Ligne = {
  id: string;
  emplacement: string;
  etage: string;
  description: string;
  priorite: string;
};

/**
 * Les anomalies « À faire » ou « En cours », hotel-wide.
 *
 * Les compteurs de l'accueil (`c.a_faire`, `c.en_cours`) ne menaient nulle
 * part : un chiffre qu'on ne peut pas ouvrir n'est qu'une affiche.
 * `/gouvernante/declarer` ne convenait pas — c'est un écran pour DÉCLARER
 * une anomalie dans un lieu choisi, pas pour LIRE celles qui existent déjà.
 * Celui-ci répond à une seule question : qu'est-ce qui attend, dans cet
 * état précis, dans tout l'hôtel — et dans l'ordre du bâtiment (règle
 * 14octies), pas celui de la base.
 */
const STATUTS: Record<string, { titre: string; sous: string }> = {
  a_faire: { titre: "À faire", sous: "Pas encore commencées" },
  en_cours: { titre: "En cours", sous: "Déjà entamées" },
};

const PRESSE: Record<string, { ton: string; titre: string }> = {
  urgente: { ton: "text-red", titre: "Urgent" },
  haute: { ton: "text-amber", titre: "Prioritaire" },
};

function Chevrons({ priorite }: { priorite: string }) {
  const p = PRESSE[priorite];
  if (!p) return null;
  return (
    <span className={`shrink-0 ${p.ton}`} title={p.titre} aria-label={p.titre}>
      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
           strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
        <path d="M6 13l6-5 6 5" />
        <path d="M6 18l6-5 6 5" />
      </svg>
    </span>
  );
}

export default async function Anomalies({
  searchParams,
}: {
  searchParams: Promise<{ statut?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  // Même accès que les compteurs qui y mènent, sur l'accueil : encadrement
  // seulement — un technicien a sa tournée, pas une vue sur tout l'hôtel.
  if (!peutValider(profil.role)) redirect("/");

  const { statut: brut } = await searchParams;
  const statut = brut && brut in STATUTS ? brut : "a_faire";
  const { titre, sous } = STATUTS[statut];

  // Même filtre essai que l'accueil : un essai ne doit pas apparaître comme
  // une vraie anomalie qui attend.
  const marque = await colonneExiste("emplacements", "essai");
  const lignes = await sql<Ligne[]>`
    select a.id, e.code as emplacement, et.nom as etage, a.description, a.priorite::text
      from anomalies a
      join emplacements e on e.id = a.emplacement_id
      join etages et      on et.id = e.etage_id
     where a.statut = ${statut}::statut_anomalie
       ${marque ? sql`and not coalesce(e.essai, false)` : sql``}
     order by et.ordre, e.ordre,
       case a.priorite when 'urgente' then 0 when 'haute' then 1 else 2 end`;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre={titre} sous_titre={sous} retour="/" />

      <div className="px-5 py-4 flex flex-col gap-2.5">
        <div className="flex gap-2">
          {Object.entries(STATUTS).map(([v, s]) => (
            <Link
              key={v}
              href={`/anomalies?statut=${v}` as Route}
              replace
              className={`flex-1 h-[40px] rounded-[11px] grid place-items-center text-[13px] ${
                v === statut ? "bg-plum-soft text-plum font-medium" : "bg-surface-muted text-ink-soft"
              }`}
            >
              {s.titre}
            </Link>
          ))}
        </div>

        {lignes.length === 0 ? (
          <Vide>Rien {statut === "a_faire" ? "à faire" : "en cours"} pour l’instant.</Vide>
        ) : (
          <ul className="flex flex-col gap-1.5">
            {lignes.map((l) => (
              <Link
                key={l.id}
                href={`/anomalie/${l.id}` as Route}
                className="carte px-4 py-3 flex items-center gap-2.5 active:bg-surface-muted"
              >
                <span className="shrink-0 px-2 py-0.5 rounded-md bg-plum-soft text-plum text-[12.5px] font-medium">
                  {l.emplacement}
                </span>
                <span className="grow min-w-0 text-[14px] text-pretty leading-snug">
                  {l.description}
                </span>
                <Chevrons priorite={l.priorite} />
              </Link>
            ))}
          </ul>
        )}
      </div>
    </main>
  );
}
