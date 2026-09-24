import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { exigerEncadrement } from "@/lib/acces";
import { peutValider, jourISO, aujourdhuiISO, euros } from "@/lib/domaine";
import { enregistrerFichier } from "@/lib/stockage";
import { tableExiste } from "@/lib/schema";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { Confirmation, Entete, Vide } from "@/app/composants/ui";
import { ChampPhotos } from "@/app/composants/photos";
import { VoirDocument } from "@/app/composants/fenetre";
import { ChoixLieux, type LieuChoix } from "@/app/composants/choix-lieux";

export const dynamic = "force-dynamic";

type Suivi = {
  id: string;
  titre: string;
  nature: string;
  nature_code: string;
  parent_id: string | null;
  permanent: boolean;
  declencheur: string | null;
  ouvert_le: string | Date;
  clos_le: string | Date | null;
  commentaire: string | null;
  nb_episodes: number;
  nb_a_controler: number;
  nb_non_regles: number;
  montant: number;
  periodicite_jours: number | null;
  derniere_verification_nature: string | Date | null;
};

type Acte = {
  id: string;
  date_acte: string | Date;
  type_libelle: string;
  type_code: string;
  est_verification: boolean;
  est_traitement: boolean;
  qui: string | null;
  commentaire: string | null;
  montant_ht: number | null;
  gratuit: boolean;
  hors_contrat: boolean;
  positifs: string[];
  negatifs: string[];
  autres: string[];
};

type EtatLieu = {
  emplacement: string;
  regle: boolean;
  a_controler: boolean;
  dernier_traitement: string | Date | null;
  derniere_negative: string | Date | null;
  nb_verifications: number;
  nb_traitements: number;
};

type Piece = {
  id: string;
  chemin: string;
  nom: string | null;
  nature_piece: string;
  ajoute_le: string | Date;
  acte_id: string | null;
};

const TON: Record<string, { fond: string; texte: string }> = {
  positif: { fond: "bg-red", texte: "text-white" },
  negatif: { fond: "bg-green-soft", texte: "text-green" },
  autre: { fond: "bg-plum-soft", texte: "text-plum" },
};

export default async function Dossier({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ fait?: string; acte?: string; episode?: string }>;
}) {
  const profil = await exigerEncadrement();
  const { id } = await params;
  const { fait, acte: ouvrirActe, episode: ouvrirEpisode } = await searchParams;

  if (!(await tableExiste("suivis"))) notFound();

  const [suivi] = await sql<Suivi[]>`
    select id, titre, nature, nature_code, parent_id, permanent, declencheur,
           ouvert_le, clos_le, commentaire, nb_episodes::int, nb_a_controler::int,
           nb_non_regles::int, montant, periodicite_jours, derniere_verification_nature
      from v_suivis where id = ${id}`;
  if (!suivi) notFound();

  const episodes = suivi.permanent
    ? await sql<
        { id: string; titre: string; ouvert_le: string | Date; clos_le: string | Date | null;
          nb_actes: number; nb_a_controler: number; nb_non_regles: number }[]
      >`
        select id, titre, ouvert_le, clos_le, nb_actes::int, nb_a_controler::int,
               nb_non_regles::int
          from v_suivis where parent_id = ${id} order by ouvert_le desc`
    : [];

  // La chronologie : un acte = une ligne, avec sa portée et ses résultats.
  const actes = await sql<Acte[]>`
    select a.id, a.date_acte, t.libelle as type_libelle, t.code as type_code,
           t.est_verification, t.est_traitement,
           coalesce(u.nom, p.nom) as qui,
           a.commentaire, a.montant_ht, a.gratuit, a.hors_contrat,
           coalesce((select array_agg(e.code order by e.code) from acte_lieux al
                      join emplacements e on e.id = al.emplacement_id
                     where al.acte_id = a.id and al.resultat = 'positif'), '{}') as positifs,
           coalesce((select array_agg(e.code order by e.code) from acte_lieux al
                      join emplacements e on e.id = al.emplacement_id
                     where al.acte_id = a.id and al.resultat = 'negatif'), '{}') as negatifs,
           coalesce((select array_agg(e.code order by e.code) from acte_lieux al
                      join emplacements e on e.id = al.emplacement_id
                     where al.acte_id = a.id
                       and (al.resultat is null or al.resultat = 'non_concluant')), '{}') as autres
      from actes a
      join types_acte t on t.id = a.type_acte_id
      left join utilisateurs u on u.id = a.utilisateur_id
      left join prestataires p on p.id = a.prestataire_id
     where a.suivi_id = ${id}
     order by a.date_acte, a.cree_le`;

  const etats = suivi.permanent
    ? []
    : await sql<EtatLieu[]>`
        select emplacement, regle, a_controler, dernier_traitement, derniere_negative,
               nb_verifications::int, nb_traitements::int
          from v_suivi_lieux where suivi_id = ${id} order by emplacement`;

  const pieces = await sql<Piece[]>`
    select id, chemin, nom, nature_piece, ajoute_le, acte_id
      from pieces_suivi where suivi_id = ${id} order by ajoute_le desc`;

  const types = await sql<
    { id: string; libelle: string; code: string; est_verification: boolean;
      porte_sur_lieux: boolean }[]
  >`
    select id, libelle, code, est_verification, porte_sur_lieux
      from types_acte where nature_code = ${suivi.nature_code} order by ordre`;

  const lieux = await sql<LieuChoix[]>`
    select e.id, e.code, et.nom as etage
      from emplacements e join etages et on et.id = e.etage_id
     where e.actif order by et.ordre, e.ordre, e.code`;

  /**
   * Les lieux pré-cochés.
   *
   * Un épisode qui vient de s'ouvrir n'a pas encore de portée : on cochait
   * alors zéro lieu, et « Tout cocher » prenait les soixante-douze lieux de
   * l'hôtel, toit et chaufferie compris. Le PÉRIMÈTRE d'une campagne vit sur
   * le dossier permanent — c'est lui qui dit ce qu'on balaie, Lobby inclus.
   * On retombe donc dessus tant que l'épisode n'a pas le sien.
   */
  const portee = await sql<{ emplacement_id: string }[]>`
    select emplacement_id from suivi_lieux where suivi_id = ${id}
    union
    select sl.emplacement_id from suivi_lieux sl
     where sl.suivi_id = ${suivi.parent_id}::uuid
       and not exists (select 1 from suivi_lieux x where x.suivi_id = ${id})`;

  const gens = await sql<{ id: string; nom: string; genre: string }[]>`
    select id, nom, 'u' as genre from utilisateurs where actif
    union all
    select id, nom, 'p' as genre from prestataires where actif
    order by nom`;

  /**
   * Poser un acte.
   *
   * Aucun ordre n'est imposé : chimique puis froid, l'inverse, ou les deux —
   * ce sont trois actes, et seule leur date compte. L'écran enregistre ce qui
   * a eu lieu, il ne dicte jamais la suite.
   */
  async function ajouterActe(donnees: FormData) {
    "use server";
    const p = await profilActif();
    if (!p || !peutValider(p.role)) redirect(`/suivis/${id}` as Route);

    const type = String(donnees.get("type") ?? "");
    const jour = String(donnees.get("date_acte") ?? "");
    if (!type || !/^\d{4}-\d{2}-\d{2}$/.test(jour)) return;

    const qui = String(donnees.get("qui") ?? "");
    const [genre, quiId] = qui.includes(":") ? qui.split(":") : ["", ""];
    const montantBrut = String(donnees.get("montant_ht") ?? "").replace(",", ".").trim();
    const montant = montantBrut && !Number.isNaN(Number(montantBrut)) ? Number(montantBrut) : null;

    const [cree] = await sql<{ id: string }[]>`
      insert into actes (suivi_id, type_acte_id, date_acte, utilisateur_id, prestataire_id,
                         commentaire, montant_ht, gratuit, hors_contrat, saisie_par)
      values (${id}, ${type}::uuid, ${jour}::date,
              ${genre === "u" ? quiId : null}::uuid,
              ${genre === "p" ? quiId : null}::uuid,
              ${String(donnees.get("commentaire") ?? "").trim() || null},
              ${montant}, ${donnees.get("gratuit") === "on"},
              ${donnees.get("hors_contrat") === "on"}, ${p.id})
      returning id`;

    // Les lieux et leur résultat. Un lieu touché qui n'était pas encore dans
    // la portée du suivi y entre, daté : on s'élargit en cours de route.
    const choisis: { lieu: string; valeur: string }[] = [];
    for (const [cle, valeur] of donnees.entries()) {
      if (!cle.startsWith("lieu_")) continue;
      choisis.push({ lieu: cle.slice(5), valeur: String(valeur) });
    }
    for (const { lieu, valeur } of choisis) {
      await sql`
        insert into acte_lieux (acte_id, emplacement_id, resultat)
        values (${cree.id}, ${lieu}::uuid,
                ${valeur === "positif" ? "positif" : valeur === "negatif" ? "negatif" : null}
                  ::resultat_verification)
        on conflict do nothing`;
      await sql`
        insert into suivi_lieux (suivi_id, emplacement_id, entre_le, motif)
        values (${id}, ${lieu}::uuid, ${jour}::date, 'ajouté par un acte')
        on conflict do nothing`;
    }

    // La pièce jointe : une facture, un rapport, un devis.
    let refusee = false;
    for (const fichier of donnees.getAll("piece")) {
      if (!(fichier instanceof File) || fichier.size === 0) continue;
      const chemin = await enregistrerFichier(fichier);
      if (!chemin) {
        refusee = true;
        continue;
      }
      await sql`
        insert into pieces_suivi (suivi_id, acte_id, chemin, nom, nature_piece, ajoute_par)
        values (${id}, ${cree.id}, ${chemin}, ${fichier.name},
                ${String(donnees.get("nature_piece") ?? "facture")}, ${p.id})`;
    }

    revalidatePath(`/suivis/${id}`);
    redirect(`/suivis/${id}?fait=${refusee ? "acte-sans-piece" : "acte"}` as Route);
  }

  /** Ouvrir un épisode dans ce dossier permanent. */
  async function ouvrirUnEpisode(donnees: FormData) {
    "use server";
    const p = await profilActif();
    if (!p || !peutValider(p.role)) redirect(`/suivis/${id}` as Route);
    const titre = String(donnees.get("titre") ?? "").trim();
    if (titre.length < 3) return;
    const jour = String(donnees.get("ouvert_le") ?? "");
    const [cree] = await sql<{ id: string }[]>`
      insert into suivis (nature_code, parent_id, titre, declencheur, ouvert_le, cree_par)
      values (${suivi.nature_code}, ${id}, ${titre},
              ${String(donnees.get("declencheur") ?? "autre")}::declencheur_suivi,
              ${/^\d{4}-\d{2}-\d{2}$/.test(jour) ? jour : null}::date, ${p.id})
      returning id`;
    revalidatePath("/suivis");
    redirect(`/suivis/${cree.id}?fait=episode` as Route);
  }

  /** Clore ou rouvrir un épisode. Le dossier permanent, lui, ne se clôt pas. */
  async function basculerCloture() {
    "use server";
    const p = await profilActif();
    if (!p || !peutValider(p.role) || suivi.permanent) redirect(`/suivis/${id}` as Route);
    await sql`
      update suivis set clos_le = case when clos_le is null then current_date else null end
       where id = ${id}`;
    revalidatePath(`/suivis/${id}`);
    redirect(`/suivis/${id}?fait=etat` as Route);
  }

  const derniere = suivi.derniere_verification_nature
    ? new Date(jourISO(suivi.derniere_verification_nature))
    : null;
  const joursDepuis = derniere
    ? Math.round((Date.now() - derniere.getTime()) / 86_400_000)
    : null;
  const enRetard =
    joursDepuis !== null &&
    suivi.periodicite_jours !== null &&
    joursDepuis > suivi.periodicite_jours;

  const piecesDe = (a: string) => pieces.filter((p) => p.acte_id === a);
  const typeChoisi = types.find((t) => t.id === ouvrirActe) ?? types[0];

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={suivi.titre}
        sous_titre={suivi.permanent ? "Dossier permanent" : suivi.nature}
        retour={suivi.parent_id ? `/suivis/${suivi.parent_id}` : "/suivis"}
      />

      <div className="px-5 py-4 flex flex-col gap-4">
        {fait && <Confirmation quoi={fait} />}

        {/* L'état, en un mot */}
        {!suivi.permanent && (
          <div
            className={`rounded-card px-4 py-3.5 flex flex-col gap-1 ${
              suivi.nb_a_controler > 0
                ? "bg-amber-soft"
                : suivi.nb_non_regles > 0
                  ? "bg-red-soft"
                  : "bg-green-soft"
            }`}
          >
            <p
              className={`font-display font-semibold text-[16px] ${
                suivi.nb_a_controler > 0
                  ? "text-amber"
                  : suivi.nb_non_regles > 0
                    ? "text-red"
                    : "text-green"
              }`}
            >
              {suivi.nb_a_controler > 0
                ? `${suivi.nb_a_controler} lieu${suivi.nb_a_controler > 1 ? "x" : ""} à contrôler`
                : suivi.nb_non_regles > 0
                  ? `${suivi.nb_non_regles} lieu${suivi.nb_non_regles > 1 ? "x" : ""} non réglé${suivi.nb_non_regles > 1 ? "s" : ""}`
                  : "Réglé"}
            </p>
            <p
              className={`text-[12.5px] text-pretty leading-snug ${
                suivi.nb_a_controler > 0
                  ? "text-amber"
                  : suivi.nb_non_regles > 0
                    ? "text-red"
                    : "text-green"
              }`}
            >
              {suivi.nb_a_controler > 0
                ? "Traité, et aucune vérification concluante depuis. Il faut rappeler la société."
                : suivi.nb_non_regles > 0
                  ? "Une vérification est revenue positive, ou le lieu n’a jamais été vérifié."
                  : "Une vérification négative est postérieure à tous les traitements."}
            </p>
            {suivi.montant > 0 && (
              <p className="text-[12px] text-ink-soft">
                {euros(suivi.montant)} annoncés sur les pièces jointes.
              </p>
            )}
          </div>
        )}

        {suivi.permanent && enRetard && (
          <p className="rounded-card bg-amber-soft px-4 py-3 text-[12.5px] text-amber text-pretty leading-snug">
            Dernière vérification il y a <b>{joursDepuis} jours</b>, pour un rythme attendu de{" "}
            {suivi.periodicite_jours}. <b>La campagne est en retard.</b>
          </p>
        )}

        {suivi.commentaire && (
          <p className="text-[13px] text-ink-soft text-pretty leading-snug">{suivi.commentaire}</p>
        )}

        {/* ---------------------------------------------- les épisodes */}
        {suivi.permanent && (
          <section className="flex flex-col gap-2">
            <h2 className="etiquette">Les épisodes · {episodes.length}</h2>
            {episodes.map((e) => (
              <Link
                key={e.id}
                href={`/suivis/${e.id}` as Route}
                className="carte px-4 py-3.5 flex items-start gap-3 active:bg-surface-muted"
              >
                <span className="grow min-w-0">
                  <span className="block font-display font-semibold text-[15px] leading-snug">
                    {e.titre}
                  </span>
                  <span className="block text-[11.5px] text-ink-faint">
                    {e.nb_actes} acte{e.nb_actes > 1 ? "s" : ""} ·{" "}
                    {e.clos_le
                      ? `clos le ${new Date(e.clos_le).toLocaleDateString("fr-FR")}`
                      : "ouvert"}
                  </span>
                </span>
                <span
                  className={`shrink-0 px-2 py-0.5 rounded-md text-[11px] ${
                    e.nb_a_controler > 0
                      ? "bg-amber-soft text-amber"
                      : e.nb_non_regles > 0
                        ? "bg-red-soft text-red"
                        : "bg-green-soft text-green"
                  }`}
                >
                  {e.nb_a_controler > 0
                    ? "à contrôler"
                    : e.nb_non_regles > 0
                      ? "en cours"
                      : "réglé"}
                </span>
              </Link>
            ))}

            <details className="carte overflow-hidden group/ep" open={Boolean(ouvrirEpisode)}>
              <summary
                data-cible
                className="px-4 flex items-center gap-3 cursor-pointer list-none select-none text-[14.5px]"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8E8AA3"
                     strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                     className="shrink-0 transition-transform group-open/ep:rotate-90">
                  <path d="M9 5l7 7-7 7" />
                </svg>
                Ouvrir un épisode
              </summary>
              <form action={ouvrirUnEpisode} className="px-4 pb-4 pt-1 flex flex-col gap-2.5">
                <label className="flex flex-col gap-1">
                  <span className="etiquette">Ce qui se passe</span>
                  <input
                    name="titre"
                    required
                    minLength={3}
                    placeholder="Automne 2026 — chambre 34"
                    className="h-[48px] rounded-[12px] border border-line px-3 bg-surface text-[16px]"
                  />
                </label>
                <div className="grid grid-cols-2 gap-2">
                  <label className="flex flex-col gap-1">
                    <span className="etiquette">Déclenché par</span>
                    <select
                      name="declencheur"
                      defaultValue="prevention"
                      className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[14.5px]"
                    >
                      <option value="client">Un client</option>
                      <option value="prevention">Une vérification de prévention</option>
                      <option value="personnel">Le personnel</option>
                      <option value="autre">Autre</option>
                    </select>
                  </label>
                  <label className="flex flex-col gap-1">
                    <span className="etiquette">Ouvert le</span>
                    <input
                      name="ouvert_le"
                      type="date"
                      defaultValue={aujourdhuiISO()}
                      className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[15px]"
                    />
                  </label>
                </div>
                <BoutonEnvoi
                  pendant="Ouverture…"
                  className="h-[48px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15px]"
                >
                  Ouvrir l’épisode
                </BoutonEnvoi>
              </form>
            </details>
          </section>
        )}

        {/* ---------------------------------------------- la chronologie */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">La chronologie · {actes.length}</h2>
          {actes.length === 0 ? (
            <Vide>Aucun acte encore. Le premier se pose ci-dessous.</Vide>
          ) : (
            <ol className="relative flex flex-col gap-3 pl-6">
              <span
                aria-hidden
                className="absolute left-[5px] top-2 bottom-2 w-[2px] bg-line"
              />
              {actes.map((a) => {
                const ton =
                  a.positifs.length > 0
                    ? "bg-red"
                    : a.negatifs.length > 0
                      ? "bg-green"
                      : a.est_traitement
                        ? "bg-plum"
                        : "bg-ink-faint";
                return (
                  <li key={a.id} className="relative">
                    <span
                      aria-hidden
                      className={`absolute -left-6 top-[7px] w-[11px] h-[11px] rounded-full ${ton} ring-2 ring-surface`}
                    />
                    <p className="etiquette">
                      {new Date(a.date_acte).toLocaleDateString("fr-FR", {
                        weekday: "short",
                        day: "numeric",
                        month: "long",
                        year: "numeric",
                      })}
                    </p>
                    <p className="text-[15.5px] leading-snug text-pretty">
                      {a.type_libelle}
                      {a.qui && <span className="text-ink-soft"> — {a.qui}</span>}
                    </p>
                    <p className="flex flex-wrap items-center gap-1.5 mt-1">
                      {a.positifs.length > 0 && (
                        <span className={`px-2 py-0.5 rounded-md text-[11px] ${TON.positif.fond} ${TON.positif.texte}`}>
                          trouvé : {a.positifs.join(", ")}
                        </span>
                      )}
                      {a.negatifs.length > 0 && (
                        <span className={`px-2 py-0.5 rounded-md text-[11px] ${TON.negatif.fond} ${TON.negatif.texte}`}>
                          {a.negatifs.length} vérifié{a.negatifs.length > 1 ? "s" : ""}, rien
                        </span>
                      )}
                      {a.autres.length > 0 && (
                        <span className={`px-2 py-0.5 rounded-md text-[11px] ${TON.autre.fond} ${TON.autre.texte}`}>
                          {a.autres.length > 6 ? `${a.autres.length} lieux` : a.autres.join(", ")}
                          {a.est_verification ? " — résultat non écrit" : ""}
                        </span>
                      )}
                      {a.gratuit && (
                        <span className="px-2 py-0.5 rounded-md text-[11px] bg-blue-soft text-blue">
                          offert
                        </span>
                      )}
                      {a.hors_contrat && (
                        <span className="px-2 py-0.5 rounded-md text-[11px] bg-amber-soft text-amber">
                          hors contrat
                        </span>
                      )}
                      {a.montant_ht != null && !a.gratuit && (
                        <span className="px-2 py-0.5 rounded-md text-[11px] bg-surface-muted text-ink-soft tabular-nums">
                          {euros(Number(a.montant_ht))}
                        </span>
                      )}
                    </p>
                    {a.negatifs.length > 0 && (
                      <details className="mt-1">
                        <summary className="text-[12px] text-plum cursor-pointer">
                          Voir les lieux vérifiés
                        </summary>
                        <p className="flex flex-wrap gap-1 mt-1.5">
                          {a.negatifs.map((c) => (
                            <span
                              key={c}
                              className="px-1.5 py-0.5 rounded-md bg-green-soft text-green text-[11px]"
                            >
                              {c}
                            </span>
                          ))}
                        </p>
                      </details>
                    )}
                    {a.commentaire && (
                      <p className="text-[13px] text-ink-soft text-pretty leading-snug mt-1">
                        {a.commentaire}
                      </p>
                    )}
                    {piecesDe(a.id).map((p) => (
                      <VoirDocument
                        key={p.id}
                        chemin={p.chemin}
                        titre={p.nom ?? p.nature_piece}
                        className="mt-1 text-[12.5px] text-plum underline underline-offset-4 self-start block"
                      >
                        {p.nature_piece} — {p.nom ?? "voir la pièce"}
                      </VoirDocument>
                    ))}
                  </li>
                );
              })}
            </ol>
          )}
        </section>

        {/* ---------------------------------------------- poser un acte */}
        <details className="carte overflow-hidden group/acte" open={Boolean(ouvrirActe)}>
          <summary
            data-cible
            className="px-4 flex items-center gap-3 cursor-pointer list-none select-none"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8E8AA3"
                 strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                 className="shrink-0 transition-transform group-open/acte:rotate-90">
              <path d="M9 5l7 7-7 7" />
            </svg>
            <span className="grow text-[15px] font-display font-semibold">Ajouter un acte</span>
          </summary>

          {/* Le TYPE se choisit d'abord, parce qu'il décide si l'acte porte un
              résultat. Un lien, pas un menu : l'écran se redemande et le
              formulaire se règle en conséquence. */}
          <div className="px-4 pb-4 pt-1 flex flex-col gap-3">
            <div className="flex flex-col gap-1.5">
              <span className="etiquette">Quoi</span>
              <div className="flex flex-wrap gap-1.5">
                {types.map((t) => (
                  <Link
                    key={t.id}
                    href={`/suivis/${id}?acte=${t.id}` as Route}
                    replace
                    scroll={false}
                    className={`h-[38px] px-3 rounded-pill border text-[13px] flex items-center ${
                      t.id === typeChoisi?.id
                        ? "bg-plum border-plum text-white"
                        : "bg-surface border-line text-ink-soft"
                    }`}
                  >
                    {t.libelle}
                  </Link>
                ))}
              </div>
            </div>

            <form action={ajouterActe} className="flex flex-col gap-3 place-pour-le-calendrier">
              <input type="hidden" name="type" value={typeChoisi?.id ?? ""} />

              <div className="grid grid-cols-2 gap-2">
                <label className="flex flex-col gap-1">
                  <span className="etiquette">Quel jour</span>
                  <input
                    name="date_acte"
                    type="date"
                    required
                    defaultValue={aujourdhuiISO()}
                    className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[15px]"
                  />
                </label>
                <label className="flex flex-col gap-1">
                  <span className="etiquette">Par qui</span>
                  <select
                    name="qui"
                    defaultValue=""
                    className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[14.5px]"
                  >
                    <option value="">—</option>
                    {gens.map((g) => (
                      <option key={`${g.genre}:${g.id}`} value={`${g.genre}:${g.id}`}>
                        {g.nom}
                      </option>
                    ))}
                  </select>
                </label>
              </div>

              {typeChoisi?.porte_sur_lieux && (
                <ChoixLieux
                  lieux={lieux}
                  defaut={portee.map((p) => p.emplacement_id)}
                  verification={typeChoisi.est_verification}
                />
              )}

              <label className="flex flex-col gap-1">
                <span className="etiquette">Ce qu’il faut retenir</span>
                <textarea
                  name="commentaire"
                  rows={3}
                  placeholder="Un geste commercial, ce qui a été fait, ce que la société a dit…"
                  className="rounded-[12px] border border-line px-3 py-2.5 bg-surface text-[15px] leading-snug resize-none placeholder:text-ink-faint"
                />
              </label>

              <div className="grid grid-cols-2 gap-2">
                <label className="flex flex-col gap-1">
                  <span className="etiquette">Montant HT</span>
                  <input
                    name="montant_ht"
                    type="text"
                    inputMode="decimal"
                    placeholder="—"
                    className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[15px] tabular-nums"
                  />
                </label>
                <label className="flex flex-col gap-1">
                  <span className="etiquette">La pièce</span>
                  <select
                    name="nature_piece"
                    defaultValue="facture"
                    className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[14.5px]"
                  >
                    <option value="facture">Facture</option>
                    <option value="devis">Devis</option>
                    <option value="rapport">Rapport</option>
                    <option value="photo">Photo</option>
                    <option value="autre">Autre</option>
                  </select>
                </label>
              </div>

              <div className="flex flex-wrap gap-3">
                <label className="flex items-center gap-2 text-[13.5px] cursor-pointer">
                  <input type="checkbox" name="gratuit" className="w-4 h-4 accent-[#453A6E]" />
                  Offert
                </label>
                <label className="flex items-center gap-2 text-[13.5px] cursor-pointer">
                  <input type="checkbox" name="hors_contrat" className="w-4 h-4 accent-[#453A6E]" />
                  Facturé hors contrat
                </label>
              </div>

              <ChampPhotos
                nom="piece"
                libelle="Joindre la facture, le devis, le rapport (facultatif)"
                documents
              />

              <BoutonEnvoi
                pendant="Enregistrement…"
                className="h-[52px] rounded-[14px] bg-plum text-white font-display font-semibold text-[16px]"
              >
                Enregistrer l’acte
              </BoutonEnvoi>
            </form>
          </div>
        </details>

        {/* ---------------------------------------------- l'état par lieu */}
        {!suivi.permanent && etats.length > 0 && (
          <section className="flex flex-col gap-2">
            <h2 className="etiquette">Où on en est, lieu par lieu</h2>
            <ul className="carte divide-y divide-line">
              {etats.map((e) => (
                <li key={e.emplacement} className="px-3.5 py-2.5 flex items-center gap-3">
                  <span className="shrink-0 px-2 py-0.5 rounded-md bg-plum-soft text-plum text-[12.5px] font-medium">
                    {e.emplacement}
                  </span>
                  <span className="grow min-w-0 text-[11.5px] text-ink-faint">
                    {e.nb_verifications} vérification{e.nb_verifications > 1 ? "s" : ""} ·{" "}
                    {e.nb_traitements} traitement{e.nb_traitements > 1 ? "s" : ""}
                    {e.dernier_traitement &&
                      ` · dernier le ${new Date(e.dernier_traitement).toLocaleDateString("fr-FR")}`}
                  </span>
                  <span
                    className={`shrink-0 px-2 py-0.5 rounded-md text-[11px] ${
                      e.regle
                        ? "bg-green-soft text-green"
                        : e.a_controler
                          ? "bg-amber-soft text-amber"
                          : "bg-red-soft text-red"
                    }`}
                  >
                    {e.regle ? "réglé" : e.a_controler ? "à contrôler" : "en cours"}
                  </span>
                </li>
              ))}
            </ul>
          </section>
        )}

        {/* ---------------------------------------------- clore */}
        {!suivi.permanent && (
          <form action={basculerCloture} className="pt-1">
            <BoutonEnvoi
              pendant="…"
              className="w-full h-[46px] rounded-[12px] bg-surface border border-line text-[14px] text-ink-soft"
            >
              {suivi.clos_le ? "Rouvrir cet épisode" : "Clore cet épisode"}
            </BoutonEnvoi>
          </form>
        )}
      </div>
    </main>
  );
}
