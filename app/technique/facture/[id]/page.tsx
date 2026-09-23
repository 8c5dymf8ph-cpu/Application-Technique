import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, jourISO, peutValider, suitLesDossiers } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { ChampPhotos } from "@/app/composants/photos";
import { estUnPdf, VoirDocument } from "@/app/composants/fenetre";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { enregistrerFichier } from "@/lib/stockage";

export const dynamic = "force-dynamic";

type Facture = {
  id: string;
  type: string;
  reference: string | null;
  emetteur: string | null;
  prestataire_id: string | null;
  date_reference: string | Date;
  periode_debut: string | Date | null;
  periode_fin: string | Date | null;
  montant_ht: number | null;
  montant_ttc: number | null;
  statut: string;
  fichier_url: string | null;
  commentaire: string | null;
};

type Journee = {
  date_intervention: string;
  intervenant: string;
  nb_anomalies: number;
  /** Combien de ses lignes sont DÉJÀ sur cette facture. */
  nb_rattachees: number;
  emplacements: string;
  apercu: string;
  cout_materiel: number;
  ecart_jours: number;
  interventions: string[];
  /** Celles qui ne le sont pas : c'est ce que le bouton rattache. */
  restantes: string[];
  deja_rapprochee: boolean;
};

type Rattachee = {
  intervention_id: string;
  date_intervention: string | Date;
  emplacement: string;
  description: string;
  cout_materiel: number | null;
  /** Sa part de CETTE facture — répartie à parts égales à défaut de montant affecté. */
  cout_prestataire: number | null;
  cout_total: number | null;
  cout_incomplet: boolean | null;
};

export default async function DetailFacture({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ jours?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { id } = await params;
  const { jours = "30" } = await searchParams;
  const fenetre = Math.min(180, Math.max(7, Number(jours) || 30));

  const [f] = await sql<Facture[]>`
    select f.id, f.type::text, f.reference, coalesce(p.nom, fo.nom) as emetteur,
           f.prestataire_id, f.date_reference, f.periode_debut, f.periode_fin,
           f.montant_ht, f.montant_ttc, f.statut::text, f.fichier_url, f.commentaire
    from factures f
    left join prestataires p  on p.id = f.prestataire_id
    left join fournisseurs fo on fo.id = f.fournisseur_id
    where f.id = ${id}`;
  if (!f) notFound();

  const rattachees = await sql<Rattachee[]>`
    select i.id as intervention_id, i.date_intervention, e.code as emplacement,
           a.description, c.cout_materiel, c.cout_prestataire, c.cout_total,
           c.cout_incomplet
    from facture_interventions fi
    join interventions i  on i.id = fi.intervention_id
    join anomalies a      on a.id = i.anomalie_id
    join emplacements e   on e.id = a.emplacement_id
    left join v_interventions_cout c on c.intervention_id = i.id
    where fi.facture_id = ${id}
    order by i.date_intervention desc, a.reference`;

  // Des JOURNÉES, pas des tournées : l'InterventionID changeait à chaque
  // anomalie validée, la journée d'un intervenant est ce qui identifie un
  // passage.
  const journees =
    f.type === "prestation"
      ? await sql<Journee[]>`
          select date_intervention, intervenant, nb_anomalies, nb_rattachees,
                 emplacements, apercu, cout_materiel, ecart_jours, interventions,
                 restantes, deja_rapprochee
          from fn_journees_rapprochables(${id}, ${fenetre})`
      : [];

  async function rapprocher(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect(`/technique/facture/${id}` as Route);
    const interventions = String(donnees.get("interventions") ?? "").split(",").filter(Boolean);
    if (interventions.length === 0) return;
    await sql`
      insert into facture_interventions (facture_id, intervention_id)
      select ${id}, unnest(${interventions}::uuid[])
      on conflict do nothing`;
    await sql`
      update factures set statut = 'rapprochee'
       where id = ${id} and statut = 'a_rapprocher'`;
    revalidatePath(`/technique/facture/${id}`);
  }

  async function detacher(donnees: FormData) {
    "use server";
    await sql`
      delete from facture_interventions
       where facture_id = ${id} and intervention_id = ${String(donnees.get("intervention"))}`;
    revalidatePath(`/technique/facture/${id}`);
  }

  async function enregistrer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect(`/technique/facture/${id}` as Route);

    const fichier = donnees.get("fichier");
    let chemin: string | null = null;
    if (fichier instanceof File && fichier.size > 0) chemin = await enregistrerFichier(fichier);

    await sql`
      update factures
         set reference      = ${String(donnees.get("reference") ?? "").trim() || null},
             date_reference = coalesce(${String(donnees.get("date") ?? "") || null}::date,
                                       date_reference),
             periode_debut  = ${String(donnees.get("debut") ?? "") || null}::date,
             periode_fin    = ${String(donnees.get("fin") ?? "") || null}::date,
             montant_ht     = ${donnees.get("ht") ? Number(donnees.get("ht")) : null},
             montant_ttc    = ${donnees.get("ttc") ? Number(donnees.get("ttc")) : null},
             commentaire    = ${String(donnees.get("commentaire") ?? "").trim() || null},
             fichier_url    = coalesce(${chemin}, fichier_url)
       where id = ${id}`;
    revalidatePath(`/technique/facture/${id}`);
  }

  async function changerStatut(donnees: FormData) {
    "use server";
    await sql`
      update factures set statut = ${String(donnees.get("vers"))}::statut_facture
       where id = ${id}`;
    revalidatePath(`/technique/facture/${id}`);
  }

  /**
   * Supprimer une facture saisie pour rien.
   *
   * On en crée une pour essayer, on se trompe d'intervenant, on la saisit deux
   * fois — et il n'y avait aucun moyen de la retirer : elle restait dans la
   * liste « à rapprocher » pour toujours. Réservé à `suitLesDossiers`, comme
   * les autres corrections de données.
   *
   * Ce que ça emporte : le rattachement aux interventions, qui reprennent
   * alors leur coût matériel seul, et la facture elle-même. Ce que ça
   * n'emporte PAS : les interventions, ni le matériel sorti, ni le fichier
   * déposé — il reste dans le dépôt, il ne coûte rien et personne ne le
   * cherchera. L'écran le dit avant de proposer le geste.
   */
  async function supprimerLaFacture() {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !suitLesDossiers(profil_.role)) {
      redirect(`/technique/facture/${id}` as Route);
    }
    await sql`delete from factures where id = ${id}`;
    redirect("/technique/factures?fait=facture-supprimee" as Route);
  }

  /**
   * Ce que ces interventions ont coûté.
   *
   * Règle 16quater : le coût d'un passage, c'est le matériel PLUS ce que
   * l'intervenant facture. Les deux étaient affichés côte à côte sans jamais
   * être additionnés — or c'est la somme qu'on cherche quand la facture
   * arrive, et une facture couvre souvent plusieurs interventions.
   *
   * `v_cout_prestataire` répartit déjà le montant de la facture entre les
   * interventions qu'elle couvre, à parts égales faute de montant affecté.
   */
  const couvert = rattachees.reduce((n, r) => n + Number(r.cout_materiel ?? 0), 0);
  const facture = rattachees.reduce((n, r) => n + Number(r.cout_prestataire ?? 0), 0);
  const total = rattachees.reduce((n, r) => n + Number(r.cout_total ?? 0), 0);
  const incomplet = rattachees.some((r) => r.cout_incomplet);

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={f.emetteur ?? "Facture"}
        sous_titre={`${f.reference ?? "sans numéro"} · ${new Date(f.date_reference).toLocaleDateString("fr-FR")}`}
        retour="/technique/factures"
      />

      {/* L'écran change en le quittant — on rattache, on détache, on saisit un
          montant. Sans cela, la flèche arrière ressort la page telle qu'elle
          était et on croit que rien n'a été enregistré. */}

      <div className="px-5 py-4 place-pour-le-calendrier flex flex-col gap-5">
        {/* La pièce, consultable SUR l'écran. Elle s'ouvrait dans un onglet :
            on quittait l'application, et revenir demandait trois gestes. */}
        {f.fichier_url ? (
          <VoirDocument
            chemin={f.fichier_url}
            titre={`Facture ${f.reference ?? "sans numéro"} — ${f.emetteur ?? ""}`}
            className="carte px-4 py-3.5 flex items-center gap-3 text-left w-full active:bg-surface-muted active:scale-[.99] transition-transform"
          >
            <span className="w-10 h-10 shrink-0 rounded-[11px] bg-green-soft grid place-items-center">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#357051"
                   strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
                <path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z" />
                <path d="M14 3v5h5" />
              </svg>
            </span>
            <span className="grow min-w-0">
              <span className="block text-[14.5px]">
                {estUnPdf(f.fichier_url) ? "Ouvrir la facture (PDF)" : "Voir la facture"}
              </span>
              <span className="block text-[11.5px] text-ink-faint">
                {euros(f.montant_ht)} HT · {euros(f.montant_ttc)} TTC
                {estUnPdf(f.fichier_url) ? " · s’ouvre dans le lecteur PDF" : ""}
              </span>
            </span>
          </VoirDocument>
        ) : (
          <p className="text-[13px] text-ink-faint text-pretty">
            Aucune pièce jointe. Ajoutez-la ci-dessous : elle sera consultable depuis chaque
            intervention qu’elle couvre.
          </p>
        )}

        {/* Ce que ça a coûté. Le coût d'un passage, c'est le matériel PLUS ce
            que l'intervenant facture (règle 16quater) : les deux étaient
            affichés côte à côte sans jamais être additionnés, alors que c'est
            la somme qu'on cherche quand la facture arrive. */}
        {rattachees.length > 0 && (
          <section className="carte px-4 py-4 flex flex-col gap-3">
            <h2 className="etiquette">
              Ce qu’{rattachees.length > 1 ? "elles ont" : "elle a"} coûté
            </h2>
            <div className="flex flex-col gap-2">
              <div className="flex items-baseline justify-between gap-3">
                <span className="text-[13.5px] text-ink-soft">
                  Facturé par l’intervenant
                </span>
                <span className="text-[15px] tabular-nums">{euros(facture)}</span>
              </div>
              <div className="flex items-baseline justify-between gap-3">
                <span className="text-[13.5px] text-ink-soft">Matériel sorti</span>
                <span className="text-[15px] tabular-nums">{euros(couvert)}</span>
              </div>
              <div className="flex items-baseline justify-between gap-3 border-t border-line pt-2.5">
                <span className="font-display font-semibold text-[15.5px]">
                  {rattachees.length} intervention{rattachees.length > 1 ? "s" : ""}
                </span>
                <span className="font-display font-semibold text-[21px] tabular-nums">
                  {euros(total)}
                </span>
              </div>
            </div>
            {/* Pas de montant par anomalie, ni ici ni ailleurs. Serafino
                facture son MOIS — 396 € pour tout juin, pas pour chaque
                robinet. Diviser ce chiffre par le nombre d'anomalies produit
                un montant que personne n'a jamais convenu, et le montrer le
                fait passer pour un prix. La facture couvre le passage : c'est
                à ce niveau qu'elle se lit. */}
            {/* Un produit sans prix n'est pas compté pour zéro (règle 6). */}
            {incomplet && (
              <p className="text-[12.5px] text-amber text-pretty">
                Du matériel sans prix connu a été utilisé : ce total est un
                minimum.
              </p>
            )}
            {facture === 0 && (
              <p className="text-[12.5px] text-ink-faint text-pretty">
                Le montant de la facture n’est pas encore saisi : seul le
                matériel est compté. Renseignez-le plus bas, il se répartira
                entre ces interventions.
              </p>
            )}
          </section>
        )}

        {/* Ce que la facture couvre déjà */}
        <section className="flex flex-col gap-2">
          <div className="flex items-baseline justify-between gap-3">
            <h2 className="etiquette">Ce qu’elle couvre</h2>
            {rattachees.length > 0 && (
              <span className="text-[11.5px] text-ink-faint tabular-nums">
                {rattachees.length} intervention{rattachees.length > 1 ? "s" : ""} ·{" "}
                {euros(couvert)} de matériel
              </span>
            )}
          </div>
          {rattachees.length === 0 ? (
            <p className="text-[13px] text-ink-faint text-pretty">
              Rien encore. Choisissez les journées ci-dessous.
            </p>
          ) : (
            <ul className="flex flex-col gap-2">
              {[...new Set(rattachees.map((r) => jourISO(r.date_intervention)))].map((jour) => {
                const dedans = rattachees.filter((r) => jourISO(r.date_intervention) === jour);
                return (
                  <li key={jour} className="carte overflow-hidden">
                    <p className="px-3.5 py-2 bg-surface-muted border-b border-line text-[12px] text-ink-soft">
                      {new Date(jour).toLocaleDateString("fr-FR", {
                        weekday: "long",
                        day: "numeric",
                        month: "long",
                        year: "numeric",
                      })}
                    </p>
                    <ul className="divide-y divide-line">
                      {dedans.map((r) => (
                        <li
                          key={r.intervention_id}
                          className="px-3.5 py-2.5 flex items-center gap-2.5"
                        >
                          <span className="shrink-0 px-1.5 py-0.5 rounded-md bg-plum-soft text-plum text-[10.5px]">
                            {r.emplacement}
                          </span>
                          <span className="grow min-w-0 flex flex-col gap-0.5">
                            <span className="text-[13.5px] leading-snug text-pretty">
                              {r.description}
                            </span>
                            {/* Ce que CETTE intervention a coûté : son
                                matériel et sa part de la facture. Sans le
                                détail, on ne sait pas laquelle pèse. */}
                            {/* Le matériel est un vrai prix : il se lit. La
                                part de facture, elle, n'est qu'une clé de
                                répartition — la répéter sur chaque ligne
                                faisait passer une division pour un tarif. */}
                            {Number(r.cout_materiel ?? 0) > 0 && (
                              <span className="text-[11.5px] text-ink-faint tabular-nums">
                                {euros(r.cout_materiel)} de matériel
                              </span>
                            )}
                          </span>
                          {peutValider(profil.role) && (
                            <form action={detacher}>
                              <input
                                type="hidden"
                                name="intervention"
                                value={r.intervention_id}
                              />
                              <button
                                aria-label="Retirer"
                                className="w-9 h-9 shrink-0 rounded-[10px] bg-surface-muted grid place-items-center min-h-0"
                              >
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                     stroke="#4F4B6B" strokeWidth="2.2" strokeLinecap="round">
                                  <path d="M6 12h12" />
                                </svg>
                              </button>
                            </form>
                          )}
                        </li>
                      ))}
                    </ul>
                  </li>
                );
              })}
            </ul>
          )}
        </section>

        {/* Les journées candidates */}
        {f.type === "prestation" && peutValider(profil.role) && (
          <section className="flex flex-col gap-2">
            <div className="flex items-baseline justify-between gap-3">
              <h2 className="etiquette">Journées de {f.emetteur}</h2>
              <span className="flex gap-1.5">
                {[30, 60, 120, 180].map((n) => (
                  <Link
                    key={n}
                    href={`/technique/facture/${id}?jours=${n}` as Route}
                    className={`px-2 py-0.5 rounded-md text-[11px] ${
                      fenetre === n ? "bg-plum text-white" : "bg-surface-muted text-ink-soft"
                    }`}
                  >
                    {n} j
                  </Link>
                ))}
              </span>
            </div>
            <p className="text-[11.5px] text-ink-faint text-pretty leading-snug -mt-1">
              Une journée, pas une tournée : c’est le couple « qui est venu / quel jour » qui
              identifie un passage. Une facture peut en couvrir plusieurs.
            </p>

            {journees.length === 0 ? (
              <p className="text-[13px] text-ink-faint text-pretty">
                Aucune journée de cet intervenant dans les {fenetre} jours précédant la facture.
                Élargissez la fenêtre, ou vérifiez la date.
              </p>
            ) : (
              <ul className="flex flex-col gap-2">
                {journees.map((j) => (
                  <li
                    key={`${j.date_intervention}-${j.intervenant}`}
                    className={`carte px-4 py-3 flex flex-col gap-2 ${
                      j.deja_rapprochee ? "opacity-60" : ""
                    }${
                      j.nb_rattachees > 0 && !j.deja_rapprochee
                        ? " ring-1 ring-plum/30"
                        : ""
                    }`}
                  >
                    <div className="flex items-baseline gap-3">
                      <span className="grow min-w-0">
                        <span className="block text-[14.5px]">
                          {new Date(j.date_intervention).toLocaleDateString("fr-FR", {
                            weekday: "long",
                            day: "numeric",
                            month: "long",
                          })}
                        </span>
                        <span className="block text-[11.5px] text-ink-faint">
                          {j.nb_anomalies} anomalie{j.nb_anomalies > 1 ? "s" : ""}
                          {j.nb_rattachees > 0 && !j.deja_rapprochee
                            ? ` · ${j.nb_rattachees} déjà sur la facture`
                            : ""}{" "}
                          · {j.ecart_jours} jour{j.ecart_jours > 1 ? "s" : ""} avant la
                          facture
                        </span>
                      </span>
                      {Number(j.cout_materiel) > 0 && (
                        <span className="text-[13px] tabular-nums shrink-0">
                          {euros(j.cout_materiel)}
                        </span>
                      )}
                    </div>

                    <ul className="flex flex-col gap-0.5">
                      {j.apercu.split("\n").map((ligne) => {
                        const [lieu, ...reste] = ligne.split(" — ");
                        return (
                          <li key={ligne} className="flex items-baseline gap-2 text-[12px]">
                            <span className="shrink-0 px-1.5 py-0.5 rounded-md bg-plum-soft text-plum text-[10.5px]">
                              {lieu}
                            </span>
                            <span className="grow min-w-0 text-ink-soft leading-snug text-pretty">
                              {reste.join(" — ")}
                            </span>
                          </li>
                        );
                      })}
                    </ul>

                    {/* Une journée à moitié rattachée reste actionnable.
                        `bool_or` marquait la journée entière dès qu'UNE ligne
                        y était : retirer une ligne la faisait disparaître,
                        sans aucun chemin pour la ramener. */}
                    {j.deja_rapprochee ? (
                      <span className="text-[11.5px] text-green">
                        Déjà rattachée — {j.nb_anomalies} ligne
                        {j.nb_anomalies > 1 ? "s" : ""}
                      </span>
                    ) : (
                      <form action={rapprocher}>
                        <input
                          type="hidden"
                          name="interventions"
                          value={j.restantes.join(",")}
                        />
                        <BoutonEnvoi
                          pendant="Rattachement…"
                          className="w-full h-[42px] rounded-[11px] bg-plum-soft text-plum text-[13.5px] font-medium active:opacity-70 active:scale-[.99] transition"
                        >
                          {j.nb_rattachees === 0
                            ? "Rattacher cette journée"
                            : j.restantes.length === 1
                              ? "Rattacher la ligne qui manque"
                              : `Rattacher les ${j.restantes.length} lignes qui manquent`}
                        </BoutonEnvoi>
                      </form>
                    )}
                  </li>
                ))}
              </ul>
            )}
          </section>
        )}

        {/* Les montants et la pièce */}
        {peutValider(profil.role) && (
          <section className="flex flex-col gap-2">
            <h2 className="etiquette">La facture</h2>
            <form action={enregistrer} className="carte px-3.5 py-3 flex flex-col gap-2.5">
              <div className="flex gap-2">
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">N° de facture</span>
                  <input
                    name="reference"
                    autoComplete="off"
                    defaultValue={f.reference ?? ""}
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
                  />
                </label>
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Date</span>
                  <input
                    name="date"
                    type="date"
                    defaultValue={jourISO(f.date_reference)}
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
                  />
                </label>
              </div>
              <div className="flex gap-2">
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Montant HT</span>
                  <input
                    name="ht"
                    type="number"
                    step="0.01"
                    min={0}
                    inputMode="decimal"
                    defaultValue={f.montant_ht ?? ""}
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
                  />
                </label>
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Montant TTC</span>
                  <input
                    name="ttc"
                    type="number"
                    step="0.01"
                    min={0}
                    inputMode="decimal"
                    defaultValue={f.montant_ttc ?? ""}
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
                  />
                </label>
              </div>
              <div className="flex gap-2">
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Période du</span>
                  <input
                    name="debut"
                    type="date"
                    defaultValue={jourISO(f.periode_debut)}
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
                  />
                </label>
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">au</span>
                  <input
                    name="fin"
                    type="date"
                    defaultValue={jourISO(f.periode_fin)}
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
                  />
                </label>
              </div>
              <p className="text-[11px] text-ink-faint text-pretty leading-snug">
                Quand la facture porte une période, c’est elle qui sert à proposer les journées,
                plutôt que la fenêtre autour de la date.
              </p>
              <ChampPhotos nom="fichier" libelle={f.fichier_url ? "Remplacer la pièce" : "La pièce (PDF ou photo)"} multiple={false} documents />
              <input
                name="commentaire"
                autoComplete="off"
                defaultValue={f.commentaire ?? ""}
                placeholder="Note (facultatif)"
                className="w-full h-[44px] px-3 rounded-[11px] border border-line bg-surface text-[15px] placeholder:text-ink-faint"
              />
              <button className="h-[46px] rounded-[12px] bg-plum text-white font-display font-semibold text-[14.5px]">
                Enregistrer
              </button>
            </form>

            <form action={changerStatut} className="flex gap-2">
              {f.statut !== "reglee" && (
                <button
                  name="vers"
                  value="reglee"
                  className="flex-1 h-[44px] rounded-[12px] bg-green-soft text-green text-[13.5px] font-medium"
                >
                  Réglée
                </button>
              )}
              {f.statut !== "litige" && (
                <button
                  name="vers"
                  value="litige"
                  className="flex-1 h-[44px] rounded-[12px] bg-red-soft text-red text-[13.5px] font-medium"
                >
                  En litige
                </button>
              )}
            </form>
          </section>
        )}

        {/* Supprimer, en deux temps et en disant ce que ça emporte. Un bouton
            nu qui efface une facture n'a pas sa place à côté de « Réglée ». */}
        {suitLesDossiers(profil.role) && (
          <details className="carte px-4 py-3">
            <summary className="text-[13px] text-ink-faint cursor-pointer list-none flex items-center gap-2">
              <span className="text-[16px] leading-none">⌄</span>
              Supprimer cette facture
            </summary>
            <div className="pt-3 flex flex-col gap-2.5">
              <p className="text-[12.5px] text-ink-soft text-pretty">
                {rattachees.length > 0
                  ? `Les ${rattachees.length} intervention${
                      rattachees.length > 1 ? "s" : ""
                    } qu’elle couvre ne perdent rien : elles reprennent leur coût
                       matériel seul. `
                  : ""}
                Le fichier déposé reste dans le dépôt. La facture, elle,
                disparaît pour de bon.
              </p>
              <form action={supprimerLaFacture}>
                <BoutonEnvoi
                  pendant="Suppression…"
                  className="w-full h-[44px] rounded-[12px] bg-red-soft text-red text-[13.5px] font-medium active:opacity-70 active:scale-[.99] transition"
                >
                  Oui, supprimer la facture
                </BoutonEnvoi>
              </form>
            </div>
          </details>
        )}

        <Link
          href={"/technique/factures" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Toutes les factures
        </Link>
      </div>
    </main>
  );
}
