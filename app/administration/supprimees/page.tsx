import { redirect } from "next/navigation";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { peutValider } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { tableExiste } from "@/lib/schema";

export const dynamic = "force-dynamic";

type Supprimee = {
  id: string;
  emplacement: string | null;
  description: string | null;
  statut: string | null;
  declare_le: string | Date | null;
  constate_par: string | null;
  nb_photos: number;
  nb_commentaires: number;
  nb_interventions: number;
  supprimee_le: string | Date;
  par: string | null;
};

/**
 * Ce qui a été supprimé.
 *
 * « J'ai supprimé une ancienne anomalie sans faire exprès, mais je ne sais
 * plus laquelle. » Sans journal, la question n'a aucune réponse : la ligne
 * est partie, et la base ne sait même plus qu'elle a existé. La 0021 pose
 * le déclencheur ; ici on lit ce qu'il a retenu.
 */
export default async function CeQuiAEteSupprime() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!peutValider(profil.role)) redirect("/");

  // `tableExiste` : le code part en ligne avant la migration, et nommer une
  // table absente casse l'écran entier, pas seulement la requête.
  const journalPret = await tableExiste("anomalies_supprimees");
  const supprimees = journalPret
    ? await sql<Supprimee[]>`
        select s.id, s.emplacement, s.description, s.statut, s.declare_le,
               s.constate_par, s.nb_photos, s.nb_commentaires,
               s.nb_interventions, s.supprimee_le,
               (select u.nom from utilisateurs u where u.id = s.supprimee_par) as par
          from anomalies_supprimees s
         order by s.supprimee_le desc limit 30`
    : [];

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Ce qui a été supprimé"
        sous_titre={journalPret ? `${supprimees.length} au journal` : "journal pas encore posé"}
        retour="/administration"
      />

      <div className="px-5 py-5 flex flex-col gap-5">
        {!journalPret && (
          <p className="rounded-card bg-amber-soft px-4 py-3 text-[13px] text-amber text-pretty leading-snug">
            Le journal des suppressions n’existe pas encore dans la base : jouez les
            migrations depuis « État de l’application ».
          </p>
        )}
        {/* Ce qui a été supprimé. Une suppression ne se défait pas — photos,
            fil et interventions sont partis avec — mais on doit au moins
            pouvoir dire CE QUI a disparu, et le redéclarer. */}
        {journalPret && (
          <>
            {supprimees.length === 0 ? (
              <p className="text-[13px] text-ink-faint text-pretty">
                Rien n’a été supprimé depuis que le journal existe. Ce qui a
                disparu avant lui n’y figure pas : le déclencheur ne voit que
                ce qui passe après son installation.
              </p>
            ) : (
              <ul className="flex flex-col gap-2">
                {supprimees.map((d) => (
                  <li key={d.id} className="carte px-4 py-3 flex flex-col gap-1.5">
                    <div className="flex items-baseline gap-2.5">
                      <span className="shrink-0 px-2 py-0.5 rounded-md bg-plum-soft text-plum text-[12.5px] font-medium">
                        {d.emplacement ?? "lieu inconnu"}
                      </span>
                      <span className="grow min-w-0 text-[14px] leading-snug text-pretty">
                        {d.description ?? "sans description"}
                      </span>
                    </div>
                    <p className="text-[11.5px] text-ink-faint text-pretty">
                      Supprimée le{" "}
                      {new Date(d.supprimee_le).toLocaleDateString("fr-FR", {
                        day: "numeric",
                        month: "long",
                        year: "numeric",
                      })}
                      {d.par ? ` par ${d.par}` : ""}
                      {d.declare_le
                        ? ` · déclarée le ${new Date(d.declare_le).toLocaleDateString("fr-FR")}`
                        : ""}
                      {d.constate_par ? ` par ${d.constate_par}` : ""}
                    </p>
                    {(d.nb_photos > 0 ||
                      d.nb_commentaires > 0 ||
                      d.nb_interventions > 0) && (
                      <p className="text-[11.5px] text-amber">
                        Avec elle :{" "}
                        {[
                          d.nb_interventions > 0 &&
                            `${d.nb_interventions} intervention${d.nb_interventions > 1 ? "s" : ""}`,
                          d.nb_photos > 0 &&
                            `${d.nb_photos} photo${d.nb_photos > 1 ? "s" : ""}`,
                          d.nb_commentaires > 0 &&
                            `${d.nb_commentaires} commentaire${d.nb_commentaires > 1 ? "s" : ""}`,
                        ]
                          .filter(Boolean)
                          .join(", ")}
                        .
                      </p>
                    )}
                  </li>
                ))}
              </ul>
            )}
          </>
        )}

        {/* Ce que le journal ne voit pas. Il ne retient que ce qui passe
            APRÈS son installation : une anomalie supprimée avant lui n'y
            figure pas, et l'écran doit le dire plutôt que de laisser croire
            à une liste complète. Le tableau de l'hôtel, lui, la porte
            toujours. */}
        <p className="text-[12px] text-ink-faint text-pretty leading-snug pt-2 border-t border-line">
          Une anomalie supprimée AVANT que ce journal existe n’y figure pas. Si elle
          venait de l’ancienne application, l’export « TEST Tech 3 » la porte encore :
          les deux fichiers de <code>donnees/recuperation/</code> disent ce qui manque
          à la base, puis le remettent — l’anomalie, son commentaire, son passage et le
          matériel sorti. Les photos et les mots écrits ici, eux, sont perdus.
        </p>
      </div>
    </main>
  );
}
