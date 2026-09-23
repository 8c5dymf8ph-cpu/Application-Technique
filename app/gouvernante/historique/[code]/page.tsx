import { notFound } from "next/navigation";
import { sql } from "@/lib/db";
import {
  jours,
  LIBELLE_STATUT,
  peutSupprimer,
  TON_STATUT,
  type StatutAnomalie,
} from "@/lib/domaine";
import { Confirmation, Entete, Vide } from "@/app/composants/ui";
import Link from "next/link";
import type { Route } from "next";
import { Vignettes } from "@/app/composants/photos";
import { profilActif } from "@/lib/profil";
import { revalidatePath } from "next/cache";

export const dynamic = "force-dynamic";

type Ligne = {
  anomalie_id: string;
  description: string;
  statut: StatutAnomalie;
  jours_depuis: number;
  constate_par: string | null;
  declare_le: string;
};

type Frequence = { libelle: string; nb_fois: number; derniere_fois: string };

/**
 * Ce qui a été FAIT, et par qui.
 *
 * L'historique disait ce qui avait été déclaré, et s'arrêtait là : on lisait
 * « mitigeur qui fuit — validée » sans savoir qui était venu, quand, ni avec
 * quoi. C'est pourtant la première question quand le problème revient — est-ce
 * le même qui a réparé ? a-t-il mis la bonne pièce ?
 */
type Passage = {
  anomalie_id: string;
  date_intervention: string | Date;
  intervenant: string | null;
  decision_technicien: string | null;
  gouvernante: string | null;
  decision_gouvernante: string | null;
  materiel: string | null;
  /** La facture qui couvre ce passage, s'il y en a une. */
  facture: string | null;
  facture_id: string | null;
};
type Photo = { anomalie_id: string; chemin: string; moment: "constat" | "apres" };
type Compte = { anomalie_id: string; nb: number };

export default async function HistoriqueDuLieu({
  params,
  searchParams,
}: {
  params: Promise<{ code: string }>;
  searchParams: Promise<{ fait?: string }>;
}) {
  const lieu = decodeURIComponent((await params).code);
  const { fait } = await searchParams;

  const [emplacement] = await sql<{ id: string; code: string; etage: string }[]>`
    select e.id, e.code, et.nom as etage
    from emplacements e join etages et on et.id = e.etage_id where e.code = ${lieu}`;
  if (!emplacement) notFound();

  // Ce qui revient le plus souvent, en tête : c'est l'information qui sert
  // vraiment quand on regarde l'historique d'une chambre.
  const recurrences = await sql<Frequence[]>`
    select libelle, nb_fois, derniere_fois from v_frequence_anomalie_lieu
    where emplacement_id = ${emplacement.id} and nb_fois > 1
    order by nb_fois desc, derniere_fois desc`;

  const lignes = await sql<Ligne[]>`
    select anomalie_id, description, statut, jours_depuis, constate_par, declare_le
    from v_anomalies_du_lieu
    where emplacement_id = ${emplacement.id} and statut <> 'annulee'
    order by declare_le desc`;

  // Qui est venu, quand, avec quoi, et ce que la gouvernante en a dit. Une
  // anomalie reprise plusieurs fois porte plusieurs passages : on les garde
  // tous, dans l'ordre, parce que c'est l'aller-retour qui est parlant.
  const passages = await sql<Passage[]>`
    select r.anomalie_id, r.date_intervention,
           coalesce(r.intervenant, r.prestataire) as intervenant,
           r.decision_technicien::text, r.gouvernante,
           r.decision_gouvernante::text,
           (select string_agg(p.designation || ' × ' || abs(m.quantite), ', ')
              from mouvements_stock m join produits p on p.id = m.produit_id
             where m.intervention_id = r.intervention_id and m.type = 'sortie')
             as materiel,
           f.reference as facture, f.id as facture_id
      from v_recap_interventions r
      join anomalies a on a.id = r.anomalie_id
      left join facture_interventions fi on fi.intervention_id = r.intervention_id
      left join factures f               on f.id = fi.facture_id
     where a.emplacement_id = ${emplacement.id}
     order by r.date_intervention`;
  const parPassage = (id: string) => passages.filter((p) => p.anomalie_id === id);

  // Les photos des deux moments : ce que la gouvernante a constaté, et ce que
  // le technicien a rendu.
  const photos = await sql<Photo[]>`
    select ph.anomalie_id, ph.chemin, ph.moment::text
    from photos_anomalie ph join anomalies a on a.id = ph.anomalie_id
    where a.emplacement_id = ${emplacement.id}
    order by ph.prise_le`;
  const parAnomalie = (id: string, moment: string) =>
    photos.filter((p) => p.anomalie_id === id && p.moment === moment).map((p) => p.chemin);

  const commentaires = await sql<Compte[]>`
    select f.anomalie_id, count(*)::int as nb
    from v_fil_commentaires f join anomalies a on a.id = f.anomalie_id
    where a.emplacement_id = ${emplacement.id} group by f.anomalie_id`;
  const nbCommentaires = new Map(commentaires.map((c) => [c.anomalie_id, c.nb]));

  const profil = await profilActif();
  const supprimable = peutSupprimer(profil?.role);

  async function supprimer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!peutSupprimer(profil_?.role)) return;
    await sql`delete from anomalies where id = ${String(donnees.get("id"))}`;
    revalidatePath(`/gouvernante/historique/${lieu}`);
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={emplacement.code}
        sous_titre={`Historique · ${emplacement.etage}`}
        retour={`/gouvernante/declarer/${encodeURIComponent(lieu)}`}
      />

      <div className="px-5 py-5 flex flex-col gap-6">
        <Confirmation quoi={fait} />
        {recurrences.length > 0 && (
          <section className="flex flex-col gap-2.5">
            <h2 className="etiquette">Ce qui revient</h2>
            <ul className="flex flex-col gap-1.5">
              {recurrences.map((r) => (
                <li
                  key={r.libelle}
                  className="carte px-4 py-3 flex items-center gap-3"
                >
                  <span className="text-[14px] leading-snug grow text-pretty">{r.libelle}</span>
                  <span className="shrink-0 px-2.5 py-1 rounded-lg bg-blue-soft text-blue text-[12.5px] tabular-nums">
                    {r.nb_fois} fois
                  </span>
                </li>
              ))}
            </ul>
          </section>
        )}

        <section className="flex flex-col gap-2.5">
          <h2 className="etiquette">Tout l’historique · {lignes.length}</h2>
          {lignes.length === 0 ? (
            <Vide>Rien n’a jamais été déclaré ici.</Vide>
          ) : (
            <ul className="flex flex-col gap-1.5">
              {lignes.map((l) => (
                <li key={l.anomalie_id} className="carte px-4 py-3 flex flex-col gap-2">
                  <div className="flex items-start gap-3">
                    <Link
                      href={`/anomalie/${l.anomalie_id}`}
                      className="flex flex-col gap-1 grow min-w-0"
                    >
                      <p className="text-[14px] leading-snug text-pretty">{l.description}</p>
                      <p className="flex flex-wrap items-center gap-2 text-[11.5px]">
                        <span
                          className={`px-2 py-0.5 rounded-md ${TON_STATUT[l.statut].fond} ${TON_STATUT[l.statut].texte}`}
                        >
                          {LIBELLE_STATUT[l.statut]}
                        </span>
                        <span className="text-ink-faint">
                          {l.constate_par ? `${l.constate_par}, ` : ""}
                          {jours(l.jours_depuis)}
                        </span>
                        {(nbCommentaires.get(l.anomalie_id) ?? 0) > 0 && (
                          <span className="flex items-center gap-1 text-plum">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none"
                                 stroke="currentColor" strokeWidth="2" strokeLinecap="round"
                                 strokeLinejoin="round">
                              <path d="M20 15a2 2 0 0 1-2 2H8l-4 4V6a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2z" />
                            </svg>
                            {nbCommentaires.get(l.anomalie_id)}
                          </span>
                        )}
                      </p>
                    </Link>
                    {supprimable && (
                      <form action={supprimer} className="shrink-0">
                        <input type="hidden" name="id" value={l.anomalie_id} />
                        <button
                          aria-label="Supprimer cette anomalie"
                          className="w-11 h-11 rounded-[11px] bg-surface-muted grid place-items-center active:bg-red-soft"
                        >
                          <svg width="17" height="17" viewBox="0 0 24 24" fill="none"
                               stroke="#9E3538" strokeWidth="1.8" strokeLinecap="round"
                               strokeLinejoin="round">
                            <path d="M5 7h14" /><path d="M10 11v6" /><path d="M14 11v6" />
                            <path d="M6 7l1 12a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1l1-12" />
                            <path d="M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2" />
                          </svg>
                        </button>
                      </form>
                    )}
                  </div>
                  {/* Qui a réparé, quand, avec quoi, et ce que la gouvernante
                      en a dit. L'historique s'arrêtait à « validée » : on ne
                      savait pas qui était venu ni s'il avait mis la bonne
                      pièce — or c'est la première question quand le problème
                      revient. Les deux avis restent côte à côte (règle 3). */}
                  {parPassage(l.anomalie_id).map((p, i) => (
                    <p
                      key={i}
                      className="text-[12px] text-ink-soft text-pretty border-l-2 border-line pl-2.5"
                    >
                      <span className="text-ink">
                        {p.intervenant ?? "intervenant inconnu"}
                      </span>{" "}
                      le{" "}
                      {new Date(p.date_intervention).toLocaleDateString("fr-FR")}
                      {p.materiel ? ` · ${p.materiel}` : " · aucun matériel"}
                      <br />
                      {/* Rapprochée d'une facture, ou pas : sans ce signe, on
                          ne peut pas distinguer ce qui est déjà couvert de ce
                          qui attend encore sa pièce. */}
                      {p.facture_id && (
                        <>
                          <Link
                            href={`/technique/facture/${p.facture_id}` as Route}
                            className="text-blue underline underline-offset-2"
                          >
                            facture {p.facture ?? "sans numéro"}
                          </Link>
                          {" · "}
                        </>
                      )}
                      {p.decision_gouvernante === "validee" ? (
                        <span className="text-green">
                          validé par {p.gouvernante ?? "la gouvernante"}
                        </span>
                      ) : p.decision_gouvernante === "a_refaire" ? (
                        <span className="text-red">
                          à refaire, selon {p.gouvernante ?? "la gouvernante"}
                        </span>
                      ) : p.decision_gouvernante === "en_cours" ? (
                        <span className="text-blue">
                          remis en cours par {p.gouvernante ?? "la gouvernante"}
                        </span>
                      ) : p.decision_technicien === "fait" ? (
                        <span className="text-ink-faint">
                          déclaré fait — pas encore vérifié
                        </span>
                      ) : (
                        <span className="text-ink-faint">passage sans avis</span>
                      )}
                    </p>
                  ))}
                  <Vignettes chemins={parAnomalie(l.anomalie_id, "constat")}
                             titre="Au constat" ton="text-blue" />
                  <Vignettes chemins={parAnomalie(l.anomalie_id, "apres")}
                             titre="Après intervention" ton="text-green" />
                </li>
              ))}
            </ul>
          )}
        </section>
      </div>
    </main>
  );
}
