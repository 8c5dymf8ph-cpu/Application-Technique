import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { peutValider } from "@/lib/domaine";
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

  /**
   * Se déraviser.
   *
   * Tant que la tournée n'est pas rendue, une anomalie cochée peut être
   * décochée : on est encore dans les étages, on a pu se tromper de chambre.
   * La déclaration disparaît entièrement — l'avis, et le matériel qu'elle
   * portait, qui n'a donc pas été utilisé. Le laisser sorti fausserait le
   * stock. Les photos restent attachées au lieu : ce sont des faits.
   */
  async function deselectionner(donnees: FormData) {
    "use server";
    const anomalie = String(donnees.get("anomalie"));
    const [i] = await sql<{ id: string }[]>`
      select i.id from interventions i
      join tournees t on t.id = i.tournee_id
      where i.anomalie_id = ${anomalie} and i.tournee_id = ${tournee.id}
        and t.cloturee_le is null`;
    if (!i) return;
    await sql`delete from mouvements_stock where intervention_id = ${i.id}`;
    await sql`delete from interventions where id = ${i.id}`;
    await sql`
      update anomalies set statut = 'a_faire', maj_le = now()
      where id = ${anomalie} and statut in ('en_cours', 'attente_validation')`;
    revalidatePath(`/technique/${encodeURIComponent(nom)}`);
  }

  async function cloturer() {
    "use server";
    await sql`update tournees set cloturee_le = now() where id = ${tournee.id}`;
    // Le lot est rendu : le récapitulatif de ce que le technicien déclare part
    // maintenant, pas à une heure fixe. Un mail par anomalie en aurait fait dix.
    await deposerRecap(tournee.id, false);
    // L'accueil, pas /technique : un intervenant n'y a pas accès et serait
    // renvoyé sur cette même tournée, qu'il vient de rendre.
    redirect("/");
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={nom}
        sous_titre={`${tournee.reference.split("-").slice(-2, -1)} · ${faites.length} sur ${uniques.length}`}
        // Un intervenant n'a pas accès à /technique : l'y renvoyer le
        // ramènerait aussitôt sur cette même page. Pour lui, le filet est
        // l'accueil ; pour l'encadrement, la liste des intervenants.
        retour={peutValider(profil.role) ? "/technique/intervenants" : "/"}
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
                  <h2 className="font-display font-semibold text-[19px]">{chambre}</h2>
                  <span className="text-[13px] text-ink-faint">{dedans[0].etage}</span>
                </div>
                <ul className="carte divide-y divide-line">
                  {dedans.map((l) => (
                    <li key={l.anomalie_id}>
                      <div className="px-3.5 py-3.5 flex items-start gap-3">
                        {/* La case coche ET décoche : tant que la tournée n'est
                            pas rendue, on peut revenir sur ce qu'on a déclaré. */}
                        {l.traitee ? (
                          <form action={deselectionner} className="w-[30px] h-[30px] mt-0.5 shrink-0">
                            <input type="hidden" name="anomalie" value={l.anomalie_id} />
                            <button
                              aria-label="Annuler ma déclaration"
                              className="w-[30px] h-[30px] rounded-lg bg-green grid place-items-center active:opacity-70"
                            >
                              <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                   stroke="#fff" strokeWidth="2.6" strokeLinecap="round"
                                   strokeLinejoin="round">
                                <path d="M5 12.5l4.5 4.5L19 7.5" />
                              </svg>
                            </button>
                          </form>
                        ) : (
                          <Link
                            href={`/technique/anomalie/${l.anomalie_id}?par=${encodeURIComponent(nom)}`}
                            aria-label="Traiter cette anomalie"
                            className="w-[30px] h-[30px] mt-0.5 shrink-0 rounded-lg border-[2px] border-[#C9C5D8]"
                          />
                        )}
                        <Link
                          href={`/technique/anomalie/${l.anomalie_id}?par=${encodeURIComponent(nom)}`}
                          className="flex flex-col gap-1.5 grow min-w-0 active:opacity-70"
                        >
                          <span className="flex items-start gap-2">
                            <span
                              className={`grow min-w-0 text-[16.5px] leading-snug text-pretty ${
                                l.traitee ? "text-ink-faint line-through" : ""
                              }`}
                            >
                              {l.description}
                            </span>
                            <span className="mt-[2px]">
                              <Indices
                                photos={l.photos}
                                commentaires={l.commentaires}
                                eteint={l.traitee}
                              />
                            </span>
                          </span>
                          {l.traitee && (
                            <span className="text-[13px] text-ink-faint">
                              {l.materiel ?? "Aucun matériel"}
                            </span>
                          )}
                        </Link>
                      </div>
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
            <button className="w-full h-[58px] rounded-[15px] bg-plum text-white font-display font-semibold text-[18px]">
              Fin d’intervention — {faites.length} anomalie{faites.length > 1 ? "s" : ""}
            </button>
          </form>
        </div>
      )}
    </main>
  );
}
