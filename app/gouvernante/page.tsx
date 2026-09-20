import { redirect } from "next/navigation";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { Confirmation, Entete, Tuile } from "../composants/ui";

export const dynamic = "force-dynamic";

export default async function HubGouvernante({
  searchParams,
}: {
  searchParams: Promise<{ fait?: string }>;
}) {
  const { fait } = await searchParams;
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  const [c] = await sql<
    { lots: number; anomalies: number; dossiers: number; recurrentes: number }[]
  >`
    select
      (select count(*) from v_tournees where nb_en_attente > 0)::int          as lots,
      (select sum(nb_en_attente) from v_tournees)::int                        as anomalies,
      (select count(*) from v_incidents_bouteille where dossier_ouvert)::int  as dossiers,
      (select count(*) from v_recurrences_emplacement where recurrent)::int   as recurrentes`;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Gouvernante" sous_titre={profil.nom} retour="/" />
      <div className="px-5 py-5 flex flex-col gap-3.5">
        <Confirmation quoi={fait} />
        <Tuile
          href="/gouvernante/declarer"
          titre="Déclarer"
          detail="Une anomalie dans une chambre"
          ton="bg-plum-soft"
        />
        <Tuile
          href="/gouvernante/valider"
          titre="À valider"
          detail={
            c.lots === 0
              ? "Rien en attente"
              : `${c.anomalies} anomalie${c.anomalies > 1 ? "s" : ""} sur ${c.lots} tournée${c.lots > 1 ? "s" : ""}`
          }
          badge={c.anomalies}
          ton="bg-amber-soft"
        />
        <Tuile
          href="/bouteilles"
          titre="Bouteilles"
          detail="Signaler, suivre les dossiers"
          badge={c.dossiers}
          ton="bg-blue-soft"
        />
        <Tuile
          href="/gouvernante/historique"
          titre="Historique"
          detail="Par chambre, et les récurrentes"
          badge={c.recurrentes}
          ton="bg-green-soft"
        />
      </div>
    </main>
  );
}
