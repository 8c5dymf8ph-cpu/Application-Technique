import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, peutValider } from "@/lib/domaine";
import { Entete, Indices, Vide } from "@/app/composants/ui";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { RelireAuRetour } from "@/app/composants/relire-au-retour";
import { Vignettes } from "@/app/composants/photos";
import { ApercuFil } from "@/app/composants/apercu-fil";
import type { Message } from "@/app/composants/fil";
import { deposerRecapSiComplet } from "@/lib/recap";

export const dynamic = "force-dynamic";

type Lot = {
  id: string;
  reference: string;
  date_tournee: string;
  intervenant: string | null;
  cloturee_le: string | null;
  nb_interventions: number;
  nb_en_attente: number;
  cout_total: number;
  cout_incomplet: boolean;
  prete_pour_recap: boolean;
  reprise: boolean;
  mail_recap_envoye_le: string | null;
};

type Ligne = {
  intervention_id: string;
  anomalie_id: string;
  emplacement: string;
  etage: string;
  description: string;
  intervenant: string | null;
  constate_par: string | null;
  decision_technicien: string | null;
  commentaire_technicien: string | null;
  declare_fait_le: string | null;
  decision_gouvernante: string | null;
  commentaire_gouvernante: string | null;
  gouvernante: string | null;
  decide_gouvernante_le: string | null;
  cout_materiel: number | null;
  articles_sans_prix: number | null;
  cout_total: number | null;
  cout_incomplet: boolean | null;
  materiel: string | null;
  nb_commentaires: number;
};

/** Les trois issues de la gouvernante — jamais deux. */
const ISSUES = [
  { valeur: "validee", libelle: "Validé", classe: "bg-green text-white" },
  { valeur: "en_cours", libelle: "En cours", classe: "bg-blue-soft text-blue" },
  { valeur: "a_refaire", libelle: "À refaire", classe: "bg-red-soft text-red" },
] as const;

const DEJA: Record<string, { libelle: string; fond: string; texte: string }> = {
  validee: { libelle: "Validé", fond: "bg-green-soft", texte: "text-green" },
  en_cours: { libelle: "Remis en cours", fond: "bg-blue-soft", texte: "text-blue" },
  a_refaire: { libelle: "À refaire", fond: "bg-red-soft", texte: "text-red" },
};

function quand(d: string | null): string {
  if (!d) return "";
  return new Date(d).toLocaleDateString("fr-FR", { day: "numeric", month: "long" });
}

export default async function ValiderLot({
  params,
}: {
  params: Promise<{ tournee: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!peutValider(profil.role)) redirect("/");

  const { tournee } = await params;

  const [lot] = await sql<Lot[]>`
    select id, reference, date_tournee, intervenant, cloturee_le,
           nb_interventions::int, nb_en_attente::int, cout_total, cout_incomplet,
           prete_pour_recap, reprise, mail_recap_envoye_le
    from v_tournees where id = ${tournee}`;
  if (!lot) notFound();

  // Les deux avis côte à côte : celui du technicien est déjà là, le sien vient
  // s'ajouter dessous. Aucun des deux n'efface l'autre.
  const lignes = await sql<Ligne[]>`
    select r.intervention_id, r.anomalie_id, r.emplacement, r.etage, r.description,
           r.intervenant, r.constate_par,
           r.decision_technicien::text, r.commentaire_technicien, r.declare_fait_le,
           r.decision_gouvernante::text, r.commentaire_gouvernante, r.gouvernante,
           r.decide_gouvernante_le,
           r.cout_materiel, r.articles_sans_prix::int, r.cout_total, r.cout_incomplet,
           (select string_agg(p.designation || ' × ' || abs(m.quantite), ', ')
              from mouvements_stock m join produits p on p.id = m.produit_id
             where m.intervention_id = r.intervention_id and m.type = 'sortie') as materiel,
           (select count(*) from v_fil_commentaires f
             where f.anomalie_id = r.anomalie_id)::int as nb_commentaires
    from v_recap_interventions r
    where r.tournee = ${lot.reference}
    order by (r.decision_gouvernante is not null), r.emplacement`;

  /**
   * Un lot entièrement décidé n'est plus un écran de saisie.
   *
   * Après le dernier avis, on repart sur l'accueil — mais la flèche de retour
   * ramenait ici, et le navigateur ressortait la page telle qu'elle était : les
   * trois boutons, l'anomalie à décider de nouveau. On croyait que rien n'avait
   * été enregistré. Il n'y a plus rien à faire sur ce lot : on renvoie vers la
   * liste, où il n'apparaît plus.
   */
  if (lot.nb_en_attente === 0 && lignes.every((l) => l.decision_gouvernante)) {
    redirect("/gouvernante/valider" as Route);
  }

  const photos = lignes.length
    ? await sql<{ anomalie_id: string; moment: string; chemin: string }[]>`
        select ph.anomalie_id, ph.moment::text, ph.chemin
        from photos_anomalie ph
        where ph.anomalie_id = any(${lignes.map((l) => l.anomalie_id)})
        order by ph.prise_le`
    : [];

  const serie = (anomalie: string, moment: string) =>
    photos.filter((p) => p.anomalie_id === anomalie && p.moment === moment).map((p) => p.chemin);

  // Le fil de chaque anomalie du lot, en une requête : la bulle n'affichait
  // qu'un nombre, on voyait qu'il y avait eu des mots sans pouvoir les lire.
  const fils = lignes.length
    ? await sql<(Message & { anomalie_id: string })[]>`
        select anomalie_id, commentaire_id, source, auteur, texte,
               date_commentaire, decision::text
        from v_fil_commentaires
        where anomalie_id = any(${lignes.map((l) => l.anomalie_id)})
        order by date_commentaire`
    : [];
  const fil = (anomalie: string) => fils.filter((f) => f.anomalie_id === anomalie);

  async function decider(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");
    if (!peutValider(profil_.role)) redirect("/");

    const intervention = String(donnees.get("intervention"));
    const decision = String(donnees.get("decision"));
    if (!["validee", "en_cours", "a_refaire"].includes(decision)) return;

    // Le mot de la gouvernante reste attaché à sa décision : il s'ajoute au
    // fil sous celui du technicien, il ne le remplace pas.
    const mot = String(donnees.get("commentaire") ?? "").trim() || null;
    // Un lot non rendu ne se valide pas : le technicien est peut-être encore
    // dans les étages, il peut revenir sur ce qu'il a coché. La liste ne le
    // propose pas, mais un écran resté ouvert depuis avant la clôture, ou une
    // adresse conservée, passerait à travers.
    await sql`
      insert into validations (intervention_id, acteur, decision, utilisateur_id,
                               saisie_par, commentaire)
      select ${intervention}, 'gouvernante', ${decision}::decision_validation,
             ${profil_.id}, ${profil_.id}, ${mot}
        from interventions i
        join tournees t on t.id = i.tournee_id
       where i.id = ${intervention} and t.cloturee_le is not null
         -- Un double appui ne fait pas deux avis : le commentaire
         -- apparaissait alors en double dans le fil du technicien. Deux
         -- décisions différentes, ou deux mots différents, restent deux
         -- lignes — c'est de l'histoire, et rien ne l'écrase.
         and not exists (
           select 1 from validations v
            where v.intervention_id = ${intervention}
              and v.acteur = 'gouvernante'
              and v.decision = ${decision}::decision_validation
              and coalesce(v.commentaire, '') = coalesce(${mot}, ''))`;

    // Dès que plus rien n'attend son avis, le récapitulatif complet est rédigé
    // et déposé — avec ce qu'elle n'a pas validé, dit en clair.
    await deposerRecapSiComplet(tournee);

    // Plus rien à trancher dans ce lot : on revient au menu, plutôt que de
    // laisser devant une liste où il n'y a plus rien à faire. Un lot
    // partiellement traité reste ouvert : elle s'y remet quand elle veut.
    const [reste] = await sql<{ n: number }[]>`
      select nb_en_attente::int as n from v_tournees where id = ${tournee}`;
    if (reste && reste.n === 0) redirect("/gouvernante?fait=lot");

    revalidatePath(`/gouvernante/valider/${tournee}`);
  }

  const restantes = lignes.filter((l) => l.decision_gouvernante === null).length;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      {/* Revenir ici après avoir tout décidé reproposait de décider. */}
      <RelireAuRetour cle={`valider:${tournee}`} />
      <Entete
        titre={lot.intervenant ?? "Lot"}
        sous_titre={`${new Date(lot.date_tournee).toLocaleDateString("fr-FR")} · ${
          restantes === 0 ? "tout est décidé" : `${restantes} en attente de votre avis`
        }`}
        retour="/gouvernante/valider"
      />

      <div className="px-5 py-5 flex flex-col gap-4 grow">
        {lignes.length === 0 && <Vide>Ce lot ne contient aucune anomalie traitée.</Vide>}

        {lignes.map((l) => {
          const decidee = l.decision_gouvernante ? DEJA[l.decision_gouvernante] : null;
          const constat = serie(l.anomalie_id, "constat");
          const apres = serie(l.anomalie_id, "apres");
          return (
            <section
              key={l.intervention_id}
              className={`carte px-4 py-4 flex flex-col gap-3 ${decidee ? "opacity-80" : ""}`}
            >
              <div className="flex items-start gap-2">
                <div className="grow min-w-0 flex flex-col gap-0.5">
                  <span className="flex items-center gap-2">
                    <span className="font-display font-semibold text-[16px]">
                      {l.emplacement}
                    </span>
                    <span className="text-[11.5px] text-ink-faint">{l.etage}</span>
                  </span>
                  <p className="text-[14.5px] leading-snug text-pretty">{l.description}</p>
                </div>
                <span className="mt-[2px] flex items-center gap-1.5 shrink-0">
                  <Indices photos={constat.length + apres.length} />
                  {/* La bulle s'ouvre : les mots se lisent sans quitter l'écran. */}
                  <ApercuFil messages={fil(l.anomalie_id)} />
                </span>
              </div>

              {/* Ce que le technicien a dit — conservé quoi qu'elle décide */}
              <div className="rounded-card bg-blue-soft px-3.5 py-3 flex flex-col gap-1.5">
                <p className="text-[11px] uppercase tracking-[0.08em] text-blue">
                  {l.intervenant ?? "Technicien"}
                  {l.decision_technicien === "non_fait"
                    ? " · n’a pas pu faire"
                    : " · a déclaré fait"}
                  {l.declare_fait_le && ` · ${quand(l.declare_fait_le)}`}
                </p>
                <p className="text-[13px] text-ink">
                  {l.materiel ?? "Aucun matériel utilisé"}
                  {l.materiel && (
                    <span className="text-ink-faint"> · {euros(l.cout_materiel)}</span>
                  )}
                </p>
                {/* Un produit sans prix n'est pas compté pour zéro : on le dit. */}
                {(l.articles_sans_prix ?? 0) > 0 && (
                  <p className="text-[11.5px] text-red">
                    {l.articles_sans_prix} article{(l.articles_sans_prix ?? 0) > 1 ? "s" : ""} sans
                    prix — le coût affiché est incomplet
                  </p>
                )}
                {l.commentaire_technicien && (
                  <p className="text-[14px] leading-snug text-ink text-pretty whitespace-pre-line">
                    {l.commentaire_technicien}
                  </p>
                )}
              </div>

              <Vignettes chemins={constat} titre="Au constat" ton="text-ink-faint" />
              <Vignettes chemins={apres} titre="Après intervention" ton="text-green" />

              {decidee ? (
                <div className={`rounded-card ${decidee.fond} px-3.5 py-3 flex flex-col gap-1.5`}>
                  <p className={`text-[11px] uppercase tracking-[0.08em] ${decidee.texte}`}>
                    {l.gouvernante ?? "Gouvernante"} · {decidee.libelle}
                    {l.decide_gouvernante_le && ` · ${quand(l.decide_gouvernante_le)}`}
                  </p>
                  {l.commentaire_gouvernante && (
                    <p className="text-[14px] leading-snug text-ink text-pretty whitespace-pre-line">
                      {l.commentaire_gouvernante}
                    </p>
                  )}
                  <Link
                    href={`/anomalie/${l.anomalie_id}` as Route}
                    className="self-start text-[12.5px] text-plum underline underline-offset-4"
                  >
                    Le fil complet
                  </Link>
                </div>
              ) : (
                <form action={decider} className="flex flex-col gap-2.5">
                  <input type="hidden" name="intervention" value={l.intervention_id} />
                  <details className="group">
                    <summary className="text-[12.5px] text-plum underline underline-offset-4 cursor-pointer list-none">
                      Ajouter un mot
                    </summary>
                    <textarea
                      name="commentaire"
                      rows={2}
                      placeholder="Ce qu’il faut savoir…"
                      className="mt-2 w-full rounded-card border border-line bg-surface px-3.5 py-2.5 text-[15px] leading-snug resize-none placeholder:text-ink-faint"
                    />
                  </details>
                  <div className="grid grid-cols-3 gap-2">
                    {ISSUES.map((i) => (
                      <BoutonEnvoi
                        key={i.valeur}
                        name="decision"
                        value={i.valeur}
                        pendant="…"
                        className={`${i.classe} h-[48px] rounded-[13px] font-display font-semibold text-[14.5px]`}
                      >
                        {i.libelle}
                      </BoutonEnvoi>
                    ))}
                  </div>
                </form>
              )}
            </section>
          );
        })}
      </div>

      {lignes.length > 0 && (
        <div className="px-5 pb-6 pt-3 sticky bottom-0 bg-ground border-t border-line flex items-center justify-between gap-3">
          <span className="text-[12.5px] text-ink-soft text-pretty">
            {restantes > 0
              ? `${restantes} anomalie${restantes > 1 ? "s" : ""} sans votre avis — rien ne part tant qu’il en reste.`
              : lot.reprise
                ? "Lot repris de l’ancienne application : aucun envoi."
                : lot.mail_recap_envoye_le
                  ? "Récapitulatif déjà envoyé."
                  : "Récapitulatif prêt : il partira au prochain envoi."}
          </span>
          <span className="shrink-0 text-right">
            <span className="block text-[14px] font-display font-semibold tabular-nums">
              {euros(lot.cout_total)}
            </span>
            {lot.cout_incomplet && (
              <span className="block text-[10.5px] text-red">coût incomplet</span>
            )}
          </span>
        </div>
      )}
    </main>
  );
}
