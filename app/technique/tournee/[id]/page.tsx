import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { colonneExiste } from "@/lib/schema";
import { enregistrerFichier } from "@/lib/stockage";
import { profilActif } from "@/lib/profil";
import { exigerEncadrement } from "@/lib/acces";
import { euros, jourISO, peutValider, suitLesDossiers } from "@/lib/domaine";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { Confirmation, Entete } from "@/app/composants/ui";
import { ChampPhotos } from "@/app/composants/photos";
import { VoirDocument } from "@/app/composants/fenetre";
import { ApercuFil } from "@/app/composants/apercu-fil";
import type { Message } from "@/app/composants/fil";
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
  date_intervention: string | Date;
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

type Emetteur = {
  prestataire_id: string | null;
  technicien_id: string | null;
  prestataire: string | null;
  facture: boolean;
};

export default async function DetailTournee({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ fait?: string }>;
}) {
  const profil = await exigerEncadrement();
  const { id } = await params;
  const { fait } = await searchParams;

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
           r.date_intervention,
           f.reference    as facture,
           f.fichier_url  as facture_fichier
    from v_recap_interventions r
    left join facture_interventions fi on fi.intervention_id = r.intervention_id
    left join factures f               on f.id = fi.facture_id
    where r.tournee = ${lot.reference}
    order by r.date_intervention desc, r.emplacement`;

  // Le fil de chaque anomalie du passage : la bulle s'ouvre SUR l'écran.
  // « Le fil » était un lien vers un écran de plus, et on perdait sa place
  // pour lire trois lignes.
  const fils = lignes.length
    ? await sql<(Message & { anomalie_id: string })[]>`
        select anomalie_id, commentaire_id, source, auteur, texte,
               date_commentaire, decision::text
          from v_fil_commentaires
         where anomalie_id = any(${lignes.map((l) => l.anomalie_id)}::uuid[])
         order by date_commentaire`
    : [];
  const fil = (id: string) => fils.filter((m) => m.anomalie_id === id);

  // Les photos des deux moments : la fenêtre du fil les montre, plutôt que de
  // renvoyer sur un écran de plus pour les regarder.
  const photos = lignes.length
    ? await sql<{ anomalie_id: string; chemin: string; moment: string }[]>`
        select anomalie_id, chemin, moment::text
          from photos_anomalie
         where anomalie_id = any(${lignes.map((l) => l.anomalie_id)}::uuid[])
         order by prise_le`
    : [];
  const clichés = (id: string, moment: string) =>
    photos.filter((p) => p.anomalie_id === id && p.moment === moment).map((p) => p.chemin);

  /**
   * Qui est venu, et s'il facture.
   *
   * Une entreprise extérieure facture toujours. Une personne inscrite facture
   * si elle n'est pas de la maison : Farid et Rachid interviennent sans être
   * salariés. Taibi, Victoria et Miguel sont de l'hôtel — leur passage ne
   * coûte que le matériel sorti.
   */
  const dit = await colonneExiste("utilisateurs", "emet_des_factures");
  const [qui] = dit
    ? await sql<Emetteur[]>`
        select t.prestataire_id, t.technicien_id, p.nom as prestataire,
               coalesce(u.emet_des_factures, t.prestataire_id is not null) as facture
          from tournees t
          left join prestataires p on p.id = t.prestataire_id
          left join utilisateurs u on u.id = t.technicien_id
         where t.id = ${id}`
    : await sql<Emetteur[]>`
        select t.prestataire_id, t.technicien_id, p.nom as prestataire,
               (t.prestataire_id is not null) as facture
          from tournees t
          left join prestataires p on p.id = t.prestataire_id
         where t.id = ${id}`;

  const [facture] = await sql<{
    id: string; reference: string | null; montant_ht: number | null;
    date_facture: string | null; fichier_url: string | null;
  }[]>`
    select distinct f.id, f.reference, f.montant_ht, f.date_facture, f.fichier_url
      from factures f
      join facture_interventions fi on fi.facture_id = f.id
      join v_recap_interventions r on r.intervention_id = fi.intervention_id
     where r.tournee = ${lot.reference}
     limit 1`;

  /**
   * Redater un passage.
   *
   * Ce qui identifie un passage, c'est QUI est venu et QUEL JOUR — « FAIT LE »
   * et « PAR » dans l'ancienne application. Une date reprise de travers, et la
   * facture ne se rapproche plus de rien. Il faut donc pouvoir la corriger.
   *
   * Un passage ne s'étale pas sur deux jours : déplacer le passage déplace
   * TOUTES ses interventions avec lui, sinon la tournée dirait un jour et ses
   * lignes un autre. Réservé à Sarah P et Miguel : c'est une correction de
   * données, pas un geste de terrain.
   */
  async function redater(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !suitLesDossiers(profil_.role)) {
      redirect(`/technique/tournee/${id}` as Route);
    }
    const jour = String(donnees.get("jour") ?? "").trim();
    if (!/^\d{4}-\d{2}-\d{2}$/.test(jour)) return;
    await sql`update tournees set date_tournee = ${jour}::date where id = ${id}`;
    await sql`
      update interventions
         set date_intervention = ${jour}::date
       where tournee_id = ${id}`;
    revalidatePath(`/technique/tournee/${id}`);
    revalidatePath("/technique/historique");
    redirect(`/technique/tournee/${id}?fait=modifie` as Route);
  }

  /**
   * Ce que l'intervenant facture.
   *
   * Le détail ne nous intéresse pas : dans la plupart des cas le matériel
   * appartient à l'hôtel, et sa facture porte le déplacement et ce qu'il
   * estime avoir coûté. On saisit donc un montant et on joint la pièce. Le
   * coût du matériel reste compté à part — il s'ajoute, il ne se remplace pas.
   *
   * La facture couvre toutes les interventions du passage : c'est le lot qui
   * est l'unité, pas l'anomalie.
   */
  async function enregistrerCout(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect(`/technique/tournee/${id}` as Route);
    if (!qui?.facture) return;

    const montant = String(donnees.get("montant_ht") ?? "").trim();
    const reference = String(donnees.get("reference") ?? "").trim() || null;
    const quand = String(donnees.get("date_facture") ?? "").trim() || null;

    let chemin: string | null = null;
    const piece = donnees.get("fichier");
    if (piece instanceof File && piece.size > 0) chemin = await enregistrerFichier(piece);

    const [f] = await sql<{ id: string }[]>`
      insert into factures (id, type, prestataire_id, technicien_id, reference,
                            date_reference,
                            date_facture, montant_ht, fichier_url, statut, saisie_par)
      values (coalesce(${facture?.id ?? null}::uuid, gen_random_uuid()),
              'prestation', ${qui.prestataire_id},
              ${qui.prestataire_id ? null : qui.technicien_id}, ${reference},
              ${lot.date_tournee}::date, ${quand}::date,
              ${montant === "" ? null : Number(montant)}, ${chemin},
              'rapprochee', ${profil_.id})
      on conflict (id) do update
        set reference    = coalesce(excluded.reference, factures.reference),
            date_facture = coalesce(excluded.date_facture, factures.date_facture),
            montant_ht   = coalesce(excluded.montant_ht, factures.montant_ht),
            -- Une pièce déjà jointe ne s'efface pas parce qu'on corrige un montant.
            fichier_url  = coalesce(excluded.fichier_url, factures.fichier_url)
      returning id`;

    // Le rapprochement porte sur le passage entier ; montant_affecte reste nul,
    // la répartition se fait à parts égales.
    await sql`
      insert into facture_interventions (facture_id, intervention_id)
      select ${f.id}, r.intervention_id
        from v_recap_interventions r
       where r.tournee = ${lot.reference}
      on conflict do nothing`;

    revalidatePath(`/technique/tournee/${id}`);
  }

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
  // Un lot peut s'étaler : le technicien revient parfois le lendemain finir.
  const jours = [...new Set(lignes.map((l) => jourISO(l.date_intervention)))];

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
        <Confirmation quoi={fait} />

        {/* Corriger la date d'un passage. Une date reprise de travers, et la
            facture ne se rapproche plus de rien. Réservé à Sarah P et Miguel. */}
        {suitLesDossiers(profil.role) && (
          <details className="carte px-4 py-3">
            <summary className="list-none cursor-pointer text-[12.5px] text-plum underline underline-offset-4">
              Corriger la date de ce passage
            </summary>
            <form action={redater} className="mt-3 flex flex-col gap-2">
              <input
                type="date"
                name="jour"
                defaultValue={jourISO(lot.date_tournee)}
                className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
              />
              <p className="text-[11.5px] text-ink-faint text-pretty leading-snug">
                Les {lot.nb_interventions} intervention{lot.nb_interventions > 1 ? "s" : ""} du
                passage suivent la même date : un passage ne s’étale pas sur deux jours. Le coût
                et les avis ne changent pas.
              </p>
              <BoutonEnvoi
                pendant="…"
                className="h-[44px] rounded-[12px] bg-plum text-white font-display font-semibold text-[14px]"
              >
                Enregistrer la date
              </BoutonEnvoi>
            </form>
          </details>
        )}

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
          {prestataireTotal === 0 && lot.intervenant && !qui?.facture && (
            <p className="text-[12.5px] text-ink-faint text-pretty leading-snug">
              {lot.intervenant} fait partie de l’hôtel : ce passage ne coûte que le matériel
              sorti.
            </p>
          )}

          {/* Saisir le montant là où l'on regarde le passage. Le détail ne nous
              intéresse pas : le matériel appartient le plus souvent à l'hôtel,
              et la facture porte le déplacement et ce que l'intervenant estime
              avoir coûté. */}
          {qui?.facture && (
            <details className="group/cout" open={prestataireTotal === 0}>
              <summary className="list-none carte px-4 py-3 text-[15px] flex items-center justify-between cursor-pointer">
                <span>{facture ? "Corriger la facture" : "Renseigner ce qu’il a facturé"}</span>
                <span className="text-[13px] text-ink-faint">
                  {facture?.montant_ht != null ? euros(Number(facture.montant_ht)) : "à saisir"}
                </span>
              </summary>

              <form action={enregistrerCout} className="flex flex-col gap-2.5 pt-2.5">
                <label className="flex flex-col gap-1">
                  <span className="etiquette">Montant HT facturé</span>
                  <input
                    name="montant_ht"
                    type="number"
                    step="0.01"
                    min="0"
                    inputMode="decimal"
                    defaultValue={facture?.montant_ht ?? ""}
                    placeholder="Déplacement et main-d’œuvre"
                    className="w-full h-[50px] px-3 rounded-[11px] border border-line bg-surface text-[17px] tabular-nums"
                  />
                </label>

                <div className="grid grid-cols-2 gap-2">
                  <label className="flex flex-col gap-1">
                    <span className="etiquette">Numéro</span>
                    <input
                      name="reference"
                      defaultValue={facture?.reference ?? ""}
                      className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
                    />
                  </label>
                  <label className="flex flex-col gap-1">
                    <span className="etiquette">Date de facture</span>
                    <input
                      name="date_facture"
                      type="date"
                      defaultValue={jourISO(facture?.date_facture)}
                      className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
                    />
                  </label>
                </div>

                <ChampPhotos
                  nom="fichier"
                  libelle={facture?.fichier_url ? "Remplacer la facture" : "Joindre la facture"}
                  multiple={false}
                  documents
                />

                {facture?.fichier_url && (
                  <VoirDocument
                    chemin={facture.fichier_url}
                    titre={`Facture ${facture.reference ?? ""}`}
                    className="text-[13.5px] text-plum underline underline-offset-4 self-start"
                  >
                    Voir la facture jointe
                  </VoirDocument>
                )}

                <button className="h-[50px] rounded-[13px] bg-plum text-white font-display font-semibold text-[16px]">
                  Enregistrer
                </button>
                <p className="text-[12px] text-ink-faint text-pretty leading-snug">
                  Le matériel sorti reste compté à part : il s’ajoute à ce montant, il ne le
                  remplace pas.
                </p>
              </form>

              {/* Le pont entre les deux écrans. Ici on saisit la facture d'UN
                  passage — c'est le geste courant, et il doit rester à trois
                  appuis. Mais Serafino facture son mois : la même pièce couvre
                  souvent cinq journées. Plutôt que de refaire ici la liste des
                  journées rapprochables, on renvoie là où elle vit déjà, avec
                  la facture qu'on vient de saisir. */}
              {facture && (
                <Link
                  href={`/technique/facture/${facture.id}` as Route}
                  className="mt-2.5 carte px-4 py-3 flex items-center gap-3"
                >
                  <span className="grow min-w-0">
                    <span className="block text-[14px]">
                      Cette facture couvre d’autres journées ?
                    </span>
                    <span className="block text-[11.5px] text-ink-faint text-pretty">
                      Les ajouter, en retirer, voir ce qu’elles ont coûté en tout.
                    </span>
                  </span>
                  <span className="shrink-0 text-ink-faint">›</span>
                </Link>
              )}
            </details>
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
            {lignes.map((l, i) => {
              const d = l.decision_gouvernante ? DECISION[l.decision_gouvernante] : null;
              const jour = jourISO(l.date_intervention);
              const nouveauJour = i === 0 || jourISO(lignes[i - 1].date_intervention) !== jour;
              return (
                <li key={l.intervention_id} className="carte px-4 py-3 flex flex-col gap-2">
                  {nouveauJour && jours.length > 1 && (
                    <p className="text-[11px] uppercase tracking-[0.08em] text-ink-faint -mb-0.5">
                      {new Date(jour).toLocaleDateString("fr-FR", {
                        weekday: "long",
                        day: "numeric",
                        month: "long",
                      })}
                    </p>
                  )}
                  <div className="flex items-start gap-2">
                    <span className="px-2 py-0.5 rounded-md bg-plum-soft text-plum text-[11.5px] shrink-0">
                      {l.emplacement}
                    </span>
                    <p className="grow min-w-0 text-[14px] leading-snug text-pretty">
                      {l.description}
                    </p>
                    {/* Le MATÉRIEL de cette ligne, et rien d'autre. Le
                        `cout_total` y ajoutait la part de facture — une
                        division du montant du passage par le nombre
                        d'anomalies, que personne n'a jamais convenue. Sur une
                        ligne, ça se lit comme un prix. La facture couvre le
                        passage : elle se lit en bas, sur le passage. */}
                    {Number(l.cout_materiel ?? 0) > 0 && (
                      <span className="shrink-0 text-[13px] tabular-nums">
                        {euros(l.cout_materiel)}
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
                    {/* La facture s'ouvre SUR l'écran : un onglet faisait
                        sortir de l'application pour trois lignes. */}
                    {l.facture_fichier && (
                      <VoirDocument
                        chemin={l.facture_fichier}
                        titre={`Facture ${l.facture ?? ""}`}
                        className="text-[11px] text-plum underline underline-offset-2 active:opacity-60 transition-opacity"
                      >
                        voir
                      </VoirDocument>
                    )}
                    {/* « Le fil », toujours au même endroit et toujours en
                        fenêtre. Le remplacer par « La fiche » quand il n'y
                        avait rien déplaçait la cible d'une ligne à l'autre, et
                        renvoyait sur un écran de plus — d'où l'on ne revenait
                        pas là où on avait appuyé. */}
                    <span className="ml-auto">
                      <ApercuFil
                        messages={fil(l.anomalie_id)}
                        libelle="Le fil"
                        fiche={`/anomalie/${l.anomalie_id}`}
                        contexte={{
                          description: l.description,
                          emplacement: l.emplacement,
                          constat: clichés(l.anomalie_id, "constat"),
                          apres: clichés(l.anomalie_id, "apres"),
                          passages: [
                            [
                              lot.intervenant ?? "intervenant inconnu",
                              `le ${new Date(l.date_intervention).toLocaleDateString("fr-FR")}`,
                              l.materiel ?? "aucun matériel",
                            ].join(" · "),
                            l.decision_gouvernante === "validee"
                              ? `validé par ${l.gouvernante ?? "la gouvernante"}`
                              : l.decision_gouvernante === "a_refaire"
                                ? `à refaire, selon ${l.gouvernante ?? "la gouvernante"}`
                                : l.decision_gouvernante === "en_cours"
                                  ? `remis en cours par ${l.gouvernante ?? "la gouvernante"}`
                                  : "déclaré fait — pas encore vérifié",
                          ],
                        }}
                      />
                    </span>
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
