import { redirect } from "next/navigation";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { suitLesDossiers } from "@/lib/domaine";
import { EXPORTS } from "@/lib/export";
import { tableExiste } from "@/lib/schema";
import { Entete } from "@/app/composants/ui";

export const dynamic = "force-dynamic";

/**
 * Sortir ses données.
 *
 * L'ancienne application était un tableau : on l'ouvrait, on triait, on
 * bricolait une somme. Celle-ci range mieux — mais des données qu'on ne peut
 * pas sortir ne sont pas vraiment à soi. Un appui, un fichier, ouvert d'un
 * double-clic dans Excel ou Numbers.
 */
export default async function Exporter() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!suitLesDossiers(profil.role)) redirect("/");

  // Le volume, pour que le fichier ne soit pas une surprise. Une seule requête :
  // ce sont des comptages, pas les données elles-mêmes.
  const [n] = await sql<
    {
      anomalies: number;
      interventions: number;
      passages: number;
      mouvements: number;
      produits: number;
      bouteilles: number;
      factures: number;
      commentaires: number;
      equipe: number;
      referentiels: number;
      catalogue: number;
      bouteilles_park: number;
      mouvements_bouteilles: number;
      commandes: number;
      fournisseurs: number;
    }[]
  >`
    select (select count(*) from anomalies)::int             as anomalies,
           (select count(*) from interventions)::int         as interventions,
           (select count(*) from tournees)::int              as passages,
           (select count(*) from mouvements_stock)::int      as mouvements,
           (select count(*) from produits)::int              as produits,
           (select count(*) from incidents_bouteille)::int   as bouteilles,
           (select count(*) from factures)::int              as factures,
           (select count(*) from v_fil_commentaires)::int    as commentaires,
           ((select count(*) from utilisateurs) +
            (select count(*) from prestataires))::int        as equipe,
           (select count(*) from emplacements)::int          as referentiels,
           (select count(*) from catalogue_anomalies)::int   as catalogue,
           (select count(*) from dotations)::int             as bouteilles_park,
           (select count(*) from mouvements_bouteilles)::int as mouvements_bouteilles,
           (select count(*) from commandes)::int             as commandes,
           (select count(*) from fournisseurs)::int          as fournisseurs`;

  // Deux tableaux neufs (migrations 0021 et 0023) : la table peut ne pas encore
  // exister sur une base qui n'a pas encore joué la migration.
  const [avecSuivis, avecSupprimees] = await Promise.all([
    tableExiste("suivis"),
    tableExiste("anomalies_supprimees"),
  ]);
  const [supplement] = await sql<{ suivis: number; anomalies_supprimees: number }[]>`
    select ${avecSuivis ? sql`(select count(*) from actes)` : sql`0`}::int as suivis,
           ${avecSupprimees ? sql`(select count(*) from anomalies_supprimees)` : sql`0`}::int
             as anomalies_supprimees`;

  const compte = { ...n, ...supplement } as unknown as Record<string, number>;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Exporter"
        sous_titre="Vos données, dans un tableur"
        retour="/administration"
      />

      <div className="px-5 py-4 flex flex-col gap-4">
        <p className="rounded-card bg-green-soft px-4 py-3 text-[13px] text-green text-pretty leading-snug">
          <strong>Rien n’est préparé à l’avance.</strong> Chaque fichier est construit à
          l’instant où vous appuyez : il contient la dernière déclaration, la dernière
          validation, le dernier mouvement de stock. Le nombre de lignes affiché ci-dessous est
          celui de maintenant.
        </p>

        <p className="text-[13px] text-ink-soft text-pretty leading-snug">
          Chaque fichier est un tableau prêt à l’emploi : une ligne par fait, les codes
          remplacés par les noms, les colonnes en français. Il s’ouvre d’un double-clic dans
          Excel, Numbers ou Google Sheets — accents, dates et montants compris.
        </p>

        <a
          href="/api/export/classeur"
          download
          className="carte px-4 py-3.5 flex items-center gap-3 border-plum bg-plum-soft"
        >
          <span className="grow min-w-0">
            <span className="block text-[15.5px] font-display font-semibold text-plum">
              Tout, dans un seul fichier
            </span>
            <span className="block text-[12px] text-ink-faint text-pretty leading-snug mt-0.5">
              Un classeur Excel (.xlsx), un onglet par tableau ci-dessous. C’est celui à garder
              de côté : en cas de besoin, on reprend depuis lui, sans l’application.
            </span>
          </span>
          <span className="shrink-0 w-10 h-10 rounded-full bg-plum text-white grid place-items-center">
            <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                 strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
              <path d="M12 4v11m0 0l-4-4m4 4l4-4M5 19h14" />
            </svg>
          </span>
        </a>

        <p className="text-[13px] text-ink-soft text-pretty leading-snug">
          Ou table par table, en CSV — pour une donnée précise, à recharger ailleurs :
        </p>

        <ul className="flex flex-col gap-2">
          {EXPORTS.map((e) => (
            <li key={e.cle}>
              <a
                href={`/api/export/${e.cle}`}
                download
                className="carte px-4 py-3.5 flex items-center gap-3"
              >
                <span className="grow min-w-0">
                  <span className="block text-[15.5px] font-display font-semibold">
                    {e.titre}
                  </span>
                  <span className="block text-[12px] text-ink-faint text-pretty leading-snug mt-0.5">
                    {e.aide}
                  </span>
                  <span className="block text-[11.5px] text-ink-faint tabular-nums mt-1">
                    {compte[e.cle] ?? 0} ligne{(compte[e.cle] ?? 0) > 1 ? "s" : ""}
                  </span>
                </span>
                <span className="shrink-0 w-10 h-10 rounded-full bg-plum-soft text-plum grid place-items-center">
                  <svg width="19" height="19" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                       strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
                    <path d="M12 4v11m0 0l-4-4m4 4l4-4M5 19h14" />
                  </svg>
                </span>
              </a>
            </li>
          ))}
        </ul>

        <p className="text-[12px] text-ink-faint text-pretty leading-snug">
          Le nom du fichier porte la date du jour : gardez-en un par mois et vous avez votre
          propre sauvegarde, indépendante de l’application. Le fichier contient des noms de
          clients — il se range comme un document de l’hôtel.
        </p>
      </div>
    </main>
  );
}
