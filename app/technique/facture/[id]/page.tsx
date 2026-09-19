import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, jourISO, peutValider } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { ChampPhotos } from "@/app/composants/photos";
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
  emplacements: string;
  apercu: string;
  cout_materiel: number;
  ecart_jours: number;
  interventions: string[];
  deja_rapprochee: boolean;
};

type Rattachee = {
  intervention_id: string;
  date_intervention: string | Date;
  emplacement: string;
  description: string;
  cout_materiel: number | null;
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
           a.description, c.cout_materiel
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
          select date_intervention, intervenant, nb_anomalies, emplacements, apercu,
                 cout_materiel, ecart_jours, interventions, deja_rapprochee
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

  const couvert = rattachees.reduce((n, r) => n + Number(r.cout_materiel ?? 0), 0);

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={f.emetteur ?? "Facture"}
        sous_titre={`${f.reference ?? "sans numéro"} · ${new Date(f.date_reference).toLocaleDateString("fr-FR")}`}
        retour="/technique/factures"
      />

      <div className="px-5 py-4 flex flex-col gap-5">
        {/* La pièce, consultable */}
        {f.fichier_url ? (
          <a
            href={`/photo/${f.fichier_url}`}
            target="_blank"
            rel="noreferrer"
            className="carte px-4 py-3.5 flex items-center gap-3 active:bg-surface-muted"
          >
            <span className="w-10 h-10 shrink-0 rounded-[11px] bg-green-soft grid place-items-center">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#357051"
                   strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
                <path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z" />
                <path d="M14 3v5h5" />
              </svg>
            </span>
            <span className="grow min-w-0">
              <span className="block text-[14.5px]">Ouvrir la facture</span>
              <span className="block text-[11.5px] text-ink-faint">
                {euros(f.montant_ht)} HT · {euros(f.montant_ttc)} TTC
              </span>
            </span>
          </a>
        ) : (
          <p className="text-[13px] text-ink-faint text-pretty">
            Aucune pièce jointe. Ajoutez-la ci-dessous : elle sera consultable depuis chaque
            intervention qu’elle couvre.
          </p>
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
                          <span className="grow min-w-0 text-[13.5px] leading-snug text-pretty">
                            {r.description}
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
                          {j.nb_anomalies} anomalie{j.nb_anomalies > 1 ? "s" : ""} ·{" "}
                          {j.ecart_jours} jour{j.ecart_jours > 1 ? "s" : ""} avant la facture
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

                    {j.deja_rapprochee ? (
                      <span className="text-[11.5px] text-green">Déjà rattachée</span>
                    ) : (
                      <form action={rapprocher}>
                        <input
                          type="hidden"
                          name="interventions"
                          value={j.interventions.join(",")}
                        />
                        <button className="w-full h-[42px] rounded-[11px] bg-plum-soft text-plum text-[13.5px] font-medium">
                          Rattacher cette journée
                        </button>
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
