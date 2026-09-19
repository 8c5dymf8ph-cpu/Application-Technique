import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, peutValider } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { deposerRecap } from "@/lib/recap";

export const dynamic = "force-dynamic";

type Lot = {
  id: string;
  reference: string;
  intervenant: string | null;
  date_tournee: string;
  cloturee_le: string | null;
  nb_interventions: number;
  nb_en_attente: number;
  cout_total: number;
  cout_incomplet: boolean;
  reprise: boolean;
  mail_technicien_envoye_le: string | null;
  mail_recap_envoye_le: string | null;
  prete_pour_recap: boolean;
};

type Ligne = {
  intervention_id: string;
  anomalie_id: string;
  emplacement: string;
  description: string;
  decision_technicien: string | null;
  commentaire_technicien: string | null;
  decision_gouvernante: string | null;
  commentaire_gouvernante: string | null;
  gouvernante: string | null;
  non_validee_par_gouvernante: boolean;
  materiel: string | null;
  cout_materiel: number | null;
  cout_prestataire: number | null;
  cout_total: number | null;
  articles_sans_prix: number | null;
  facture: string | null;
  facture_fichier: string | null;
};

const DECISION: Record<string, { l: string; fond: string; texte: string }> = {
  validee: { l: "Validée", fond: "bg-green-soft", texte: "text-green" },
  en_cours: { l: "Remise en cours", fond: "bg-blue-soft", texte: "text-blue" },
  a_refaire: { l: "À refaire", fond: "bg-red-soft", texte: "text-red" },
};

export default async function DetailTournee({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { id } = await params;

  const [lot] = await sql<Lot[]>`
    select id, reference, intervenant, date_tournee, cloturee_le,
           nb_interventions::int, nb_en_attente::int, cout_total,
           coalesce(cout_incomplet, false) as cout_incomplet, reprise,
           mail_technicien_envoye_le, mail_recap_envoye_le, prete_pour_recap
    from v_tournees where id = ${id}`;
  if (!lot) notFound();

  const lignes = await sql<Ligne[]>`
    select r.intervention_id, r.anomalie_id, r.emplacement, r.description,
           r.decision_technicien::text, r.commentaire_technicien,
           r.decision_gouvernante::text, r.commentaire_gouvernante, r.gouvernante,
           coalesce(r.non_validee_par_gouvernante, false) as non_validee_par_gouvernante,
           (select string_agg(p.designation || ' × ' || abs(m.quantite), ', ')
              from mouvements_stock m join produits p on p.id = m.produit_id
             where m.intervention_id = r.intervention_id and m.type = 'sortie') as materiel,
           r.cout_materiel, r.cout_prestataire, r.cout_total, r.articles_sans_prix,
           f.reference    as facture,
           f.fichier_url  as facture_fichier
    from v_recap_interventions r
    left join facture_interventions fi on fi.intervention_id = r.intervention_id
    left join factures f               on f.id = fi.facture_id
    where r.tournee = ${lot.reference}
    order by r.emplacement`;

  async function renvoyer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect(`/technique/tournee/${id}` as Route);
    // Renvoyer est une décision : le message est reconstruit avec l'état
    // d'aujourd'hui, pas avec celui du jour où il était parti.
    await deposerRecap(id, donnees.get("quoi") === "complet", true);
    revalidatePath(`/technique/tournee/${id}`);
  }

  const materielTotal = lignes.reduce((n, l) => n + Number(l.cout_materiel ?? 0), 0);
  const prestataireTotal = lignes.reduce((n, l) => n + Number(l.cout_prestataire ?? 0), 0);
  const refusees = lignes.filter((l) => l.non_validee_par_gouvernante);

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={lot.intervenant ?? "Passage"}
        sous_titre={new Date(lot.date_tournee).toLocaleDateString("fr-FR", {
          weekday: "long",
          day: "numeric",
          month: "long",
          year: "numeric",
        })}
        retour="/technique/historique"
      />

      <div className="px-5 py-4 flex flex-col gap-5">
        {/* Le coût, décomposé : c'est la question qu'on pose à un passage. */}
        <section className="carte px-4 py-4 flex flex-col gap-3">
          <div className="flex items-baseline gap-3">
            <span className="grow">
              <span className="block etiquette">Coût du passage</span>
              <span className="block font-display font-semibold text-[26px] tabular-nums">
                {euros(lot.cout_total)}
              </span>
            </span>
            <span className="text-[12px] text-ink-faint text-right">
              {lot.nb_interventions} anomalie{lot.nb_interventions > 1 ? "s" : ""}
            </span>
          </div>

          <div className="grid grid-cols-2 gap-2">
            <div className="rounded-[11px] bg-surface-muted px-3 py-2">
              <div className="font-display font-semibold text-[16px] tabular-nums">
                {euros(materielTotal)}
              </div>
              <div className="etiquette text-[8.5px]">Matériel sorti</div>
            </div>
            <div className="rounded-[11px] bg-surface-muted px-3 py-2">
              <div className="font-display font-semibold text-[16px] tabular-nums">
                {prestataireTotal > 0 ? euros(prestataireTotal) : "—"}
              </div>
              <div className="etiquette text-[8.5px]">Prestation facturée</div>
            </div>
          </div>

          {lot.cout_incomplet && (
            <p className="rounded-card bg-red-soft px-3.5 py-2.5 text-[12.5px] text-red text-pretty">
              Au moins un article utilisé n’a pas de prix renseigné : le total est un minimum,
              pas le coût réel.
            </p>
          )}
          {prestataireTotal === 0 && lot.intervenant && (
            <p className="text-[11.5px] text-ink-faint text-pretty leading-snug">
              Aucune facture de prestation rattachée à ce passage. Elle arrive souvent une à deux
              semaines après.
            </p>
          )}
        </section>

        {/* Ce qui n'a pas été validé, dit en premier */}
        {refusees.length > 0 && (
          <div className="rounded-card bg-red-soft px-4 py-3 flex flex-col gap-1">
            <p className="text-[12.5px] text-red text-pretty leading-snug">
              {refusees.length} anomalie{refusees.length > 1 ? "s" : ""} déclarée
              {refusees.length > 1 ? "s" : ""} faite{refusees.length > 1 ? "s" : ""} mais non
              validée{refusees.length > 1 ? "s" : ""} par la gouvernante.
            </p>
          </div>
        )}

        {/* Les lignes, avec les deux avis */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Ce qui a été fait</h2>
          <ul className="flex flex-col gap-2">
            {lignes.map((l) => {
              const d = l.decision_gouvernante ? DECISION[l.decision_gouvernante] : null;
              return (
                <li key={l.intervention_id} className="carte px-4 py-3 flex flex-col gap-2">
                  <div className="flex items-start gap-2">
                    <span className="px-2 py-0.5 rounded-md bg-plum-soft text-plum text-[11.5px] shrink-0">
                      {l.emplacement}
                    </span>
                    <p className="grow min-w-0 text-[14px] leading-snug text-pretty">
                      {l.description}
                    </p>
                    {Number(l.cout_total ?? 0) > 0 && (
                      <span className="shrink-0 text-[13px] tabular-nums">
                        {euros(l.cout_total)}
                      </span>
                    )}
                  </div>

                  <p className="text-[12px] text-ink-soft">
                    {l.materiel ?? "Aucun matériel"}
                    {Number(l.articles_sans_prix ?? 0) > 0 && (
                      <span className="text-red">
                        {" "}
                        · {l.articles_sans_prix} sans prix
                      </span>
                    )}
                  </p>

                  {l.commentaire_technicien && (
                    <p className="rounded-card bg-blue-soft px-3 py-2 text-[12.5px] text-ink leading-snug text-pretty">
                      {l.commentaire_technicien}
                    </p>
                  )}

                  <div className="flex items-center gap-2 flex-wrap">
                    {d ? (
                      <span className={`px-2 py-0.5 rounded-md text-[11px] ${d.fond} ${d.texte}`}>
                        {d.l}
                        {l.gouvernante && ` · ${l.gouvernante}`}
                      </span>
                    ) : (
                      <span className="px-2 py-0.5 rounded-md bg-amber-soft text-amber text-[11px]">
                        Sans avis de la gouvernante
                      </span>
                    )}
                    {l.facture && (
                      <span className="text-[11px] text-ink-faint">Facture {l.facture}</span>
                    )}
                    {l.facture_fichier && (
                      <a
                        href={`/photo/${l.facture_fichier}`}
                        target="_blank"
                        rel="noreferrer"
                        className="text-[11px] text-plum underline underline-offset-2"
                      >
                        voir
                      </a>
                    )}
                    <Link
                      href={`/anomalie/${l.anomalie_id}` as Route}
                      className="ml-auto text-[11.5px] text-plum underline underline-offset-4"
                    >
                      Le fil
                    </Link>
                  </div>

                  {l.commentaire_gouvernante && (
                    <p className="rounded-card bg-amber-soft px-3 py-2 text-[12.5px] text-ink leading-snug text-pretty">
                      {l.commentaire_gouvernante}
                    </p>
                  )}
                </li>
              );
            })}
          </ul>
        </section>

        {/* Renvoyer un récapitulatif */}
        {peutValider(profil.role) && !lot.reprise && (
          <section className="flex flex-col gap-2">
            <h2 className="etiquette">Récapitulatif</h2>
            <p className="text-[11.5px] text-ink-faint text-pretty leading-snug">
              {lot.mail_recap_envoye_le
                ? `Envoyé le ${new Date(lot.mail_recap_envoye_le).toLocaleDateString("fr-FR")}.`
                : lot.prete_pour_recap
                  ? "Prêt, pas encore envoyé."
                  : `${lot.nb_en_attente} ligne${lot.nb_en_attente > 1 ? "s" : ""} attend${lot.nb_en_attente > 1 ? "ent" : ""} encore l’avis de la gouvernante.`}{" "}
              Un renvoi reconstruit le message avec l’état d’aujourd’hui.
            </p>
            <form action={renvoyer} className="flex gap-2">
              <button
                name="quoi"
                value="technicien"
                className="flex-1 h-[46px] rounded-[12px] bg-surface border border-line text-[13.5px]"
              >
                Ce que l’intervenant a rendu
              </button>
              <button
                name="quoi"
                value="complet"
                className="flex-1 h-[46px] rounded-[12px] bg-plum text-white text-[13.5px] font-medium"
              >
                Le récapitulatif complet
              </button>
            </form>
          </section>
        )}

        <Link
          href={"/technique/historique" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Tout l’historique
        </Link>
      </div>
    </main>
  );
}
