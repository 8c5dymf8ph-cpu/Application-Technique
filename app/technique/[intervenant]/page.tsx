import { notFound, redirect } from "next/navigation";
import Link from "next/link";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { intervenants, tourneeEnCours } from "@/lib/tournee";
import { deposerRecap } from "@/lib/recap";
import { Entete, Indices, Vide } from "@/app/composants/ui";

export const dynamic = "force-dynamic";

type Ligne = {
  anomalie_id: string;
  emplacement: string;
  etage: string;
  description: string;
  statut: string;
  traitee: boolean;
  materiel: string | null;
  photos: number;
  commentaires: number;
};

export default async function Tournee({
  params,
}: {
  params: Promise<{ intervenant: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  const nom = decodeURIComponent((await params).intervenant);
  const intervenant = (await intervenants()).find((i) => i.nom === nom);
  if (!intervenant) notFound();

  const tournee = await tourneeEnCours(intervenant);

  // Ce qu'il a à traiter — filtré par sa spécialité — plus ce qu'il a déjà
  // coché dans cette tournée, pour qu'il voie son avancement.
  const lignes = await sql<Ligne[]>`
    with accompagnement as (
      select a.id,
             (select count(*) from photos_anomalie ph
               where ph.anomalie_id = a.id and ph.moment = 'constat')::int as photos,
             (select count(*) from v_fil_commentaires f
               where f.anomalie_id = a.id)::int as commentaires
        from anomalies a
    )
    select a.id as anomalie_id, e.code as emplacement, et.nom as etage,
           a.description, a.statut::text,
           (i.id is not null) as traitee,
           (select string_agg(p.designation || ' × ' || abs(m.quantite), ', ')
              from mouvements_stock m join produits p on p.id = m.produit_id
             where m.intervention_id = i.id and m.type = 'sortie') as materiel,
           ac.photos, ac.commentaires
    from fn_anomalies_pour_intervenant(${nom}) a
    join emplacements e on e.id = a.emplacement_id
    join etages et      on et.id = e.etage_id
    join accompagnement ac on ac.id = a.id
    left join interventions i on i.anomalie_id = a.id and i.tournee_id = ${tournee.id}
    union all
    select a.id, e.code, et.nom, a.description, a.statut::text, true,
           (select string_agg(p.designation || ' × ' || abs(m.quantite), ', ')
              from mouvements_stock m join produits p on p.id = m.produit_id
             where m.intervention_id = i.id and m.type = 'sortie'),
           ac.photos, ac.commentaires
    from interventions i
    join anomalies a    on a.id = i.anomalie_id
    join emplacements e on e.id = a.emplacement_id
    join etages et      on et.id = e.etage_id
    join accompagnement ac on ac.id = a.id
    where i.tournee_id = ${tournee.id}
      and a.statut not in ('a_faire','en_cours')
    order by 2, 1`;

  const uniques = [...new Map(lignes.map((l) => [l.anomalie_id, l])).values()];
  const faites = uniques.filter((l) => l.traitee);
  const chambres = [...new Set(uniques.map((l) => l.emplacement))];

  async function cloturer() {
    "use server";
    await sql`update tournees set cloturee_le = now() where id = ${tournee.id}`;
    // Le lot est rendu : le récapitulatif de ce que le technicien déclare part
    // maintenant, pas à une heure fixe. Un mail par anomalie en aurait fait dix.
    await deposerRecap(tournee.id, false);
    redirect("/technique");
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={nom}
        sous_titre={`${tournee.reference.split("-").slice(-2, -1)} · ${faites.length} sur ${uniques.length}`}
        retour="/technique"
      />

      <div className="px-5 py-4 flex flex-col gap-4 grow">
        {uniques.length === 0 ? (
          <Vide>Rien à traiter pour {nom} aujourd’hui.</Vide>
        ) : (
          chambres.map((chambre) => {
            const dedans = uniques.filter((l) => l.emplacement === chambre);
            return (
              <section key={chambre} className="flex flex-col gap-2">
                <div className="flex items-center gap-2.5">
                  <span className="w-[3px] h-4 rounded-sm bg-amber" />
                  <h2 className="font-display font-semibold text-[16px]">{chambre}</h2>
                  <span className="text-[11.5px] text-ink-faint">{dedans[0].etage}</span>
                </div>
                <ul className="carte divide-y divide-line">
                  {dedans.map((l) => (
                    <li key={l.anomalie_id}>
                      <Link
                        href={`/technique/anomalie/${l.anomalie_id}?par=${encodeURIComponent(nom)}`}
                        className="px-3.5 py-3 flex items-start gap-3 active:bg-surface-muted"
                      >
                        <span
                          className={`w-[22px] h-[22px] mt-0.5 shrink-0 rounded-md grid place-items-center ${
                            l.traitee ? "bg-green" : "border-[1.7px] border-[#C9C5D8]"
                          }`}
                        >
                          {l.traitee && (
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                 stroke="#fff" strokeWidth="2.6" strokeLinecap="round"
                                 strokeLinejoin="round">
                              <path d="M5 12.5l4.5 4.5L19 7.5" />
                            </svg>
                          )}
                        </span>
                        <span className="flex flex-col gap-1 grow min-w-0">
                          <span className="flex items-start gap-2">
                            <span
                              className={`grow min-w-0 text-[14px] leading-snug text-pretty ${
                                l.traitee ? "text-ink-faint line-through" : ""
                              }`}
                            >
                              {l.description}
                            </span>
                            <span className="mt-[1px]">
                              <Indices
                                photos={l.photos}
                                commentaires={l.commentaires}
                                eteint={l.traitee}
                              />
                            </span>
                          </span>
                          {l.traitee && (
                            <span className="self-start px-2 py-0.5 rounded-md bg-plum-soft text-plum text-[11.5px]">
                              {l.materiel ?? "Aucun matériel"}
                            </span>
                          )}
                        </span>
                      </Link>
                    </li>
                  ))}
                </ul>
              </section>
            );
          })
        )}
      </div>

      {faites.length > 0 && (
        <div className="px-5 pb-6 pt-2 sticky bottom-0 bg-ground">
          <form action={cloturer}>
            <button className="w-full h-[54px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]">
              Fin d’intervention — {faites.length} anomalie{faites.length > 1 ? "s" : ""}
            </button>
          </form>
        </div>
      )}
    </main>
  );
}
