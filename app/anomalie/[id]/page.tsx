import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { colonneExiste } from "@/lib/schema";
import { profilActif } from "@/lib/profil";
import {
  jourISO,
  jours,
  LIBELLE_STATUT,
  peutSupprimer,
  suitLesDossiers,
  TON_STATUT,
  type StatutAnomalie,
} from "@/lib/domaine";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { Confirmation, Entete } from "@/app/composants/ui";
import { ChampPhotos, Vignettes } from "@/app/composants/photos";
import { ChampCommentaire, Fil, type Message } from "@/app/composants/fil";
import { enregistrerPhoto } from "@/lib/stockage";

export const dynamic = "force-dynamic";

type Anomalie = {
  id: string;
  reference: number;
  description: string;
  statut: StatutAnomalie;
  emplacement: string;
  etage: string;
  constate_par: string | null;
  jours_depuis: number;
  declare_le: string | Date;
  priorite: string;
  type_id: string | null;
  type_intervention: string | null;
  catalogue_libelle: string | null;
};

type MaterielLigne = {
  id: string;
  produit: string;
  quantite: number;
  date_mouvement: string;
  qui: string | null;
};

export default async function DetailAnomalie({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ fait?: string; supprimer?: string; retirer?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { id } = await params;
  const { fait, supprimer: confirmeSuppression, retirer: aRetirer } = await searchParams;

  const [anomalie] = await sql<Anomalie[]>`
    select anomalie_id as id, reference, description, statut, emplacement, declare_le,
           (select x.priorite::text from anomalies x where x.id = v.anomalie_id) as priorite,
           (select et.nom from etages et join emplacements e on e.etage_id = et.id
             where e.id = v.emplacement_id) as etage,
           constate_par, jours_depuis,
           (select x.type_id from anomalies x where x.id = v.anomalie_id) as type_id,
           type_intervention,
           (select c.libelle from catalogue_anomalies c where c.id = v.catalogue_id)
             as catalogue_libelle
    from v_anomalies_du_lieu v where anomalie_id = ${id}`;
  if (!anomalie) notFound();

  const messages = await sql<Message[]>`
    select commentaire_id, source, auteur, texte, date_commentaire, decision::text
    from v_fil_commentaires where anomalie_id = ${id}
    order by date_commentaire`;

  const photos = await sql<{ chemin: string; moment: string }[]>`
    select chemin, moment::text from photos_anomalie
    where anomalie_id = ${id} order by prise_le`;

  // Ce que la suppression emporterait. On le dit avant, pas après : « 2 photos
  // et 1 intervention » n'est pas la même décision que « rien ».
  const [emporte] = await sql<{
    interventions: number;
    photos: number;
    sorties: number;
    pieces: number;
  }[]>`
    select (select count(*) from interventions where anomalie_id = ${id})::int
             as interventions,
           (select count(*) from photos_anomalie where anomalie_id = ${id})::int
             as photos,
           (select count(*) from mouvements_stock m
              join interventions i on i.id = m.intervention_id
             where i.anomalie_id = ${id})::int as sorties,
           (select coalesce(sum(abs(m.quantite)), 0) from mouvements_stock m
              join interventions i on i.id = m.intervention_id
             where i.anomalie_id = ${id})::numeric as pieces`;

  /**
   * Le matériel revient-il en réserve ?
   *
   * La 0022 fait suivre le mouvement : ce qu'on supprime n'a pas eu lieu, et
   * laisser la sortie en place retirerait de la réserve une pièce que
   * personne n'a prise. Mais le code part en ligne avant la migration : tant
   * qu'elle n'est pas jouée, le mouvement reste détaché et l'écran doit dire
   * CELA. Une phrase fausse sur un geste irréversible est pire que pas de
   * phrase du tout.
   */
  const rendLeMateriel = await colonneExiste("anomalies_supprimees", "nb_mouvements");

  const supprimable = peutSupprimer(profil.role);
  // Corriger une anomalie, c'est corriger une donnée, pas faire un geste de
  // terrain : Sarah P et Miguel. La gouvernante déclare et supprime ce qui
  // n'aurait pas dû exister ; elle ne réécrit pas l'historique.
  const modifiable = suitLesDossiers(profil.role);

  // Le matériel sorti pour cette anomalie — toutes ses interventions
  // confondues — pour qu'une sortie enregistrée par erreur (une quantité
  // comptée à zéro que la reprise a quand même écrite, un mauvais produit)
  // puisse se retirer sans passer par une correction en base.
  const materiel = modifiable
    ? await sql<MaterielLigne[]>`
        select m.id, pr.designation as produit, m.quantite, m.date_mouvement,
               coalesce(u.nom, p.nom) as qui
          from mouvements_stock m
          join interventions i on i.id = m.intervention_id
          join produits pr     on pr.id = m.produit_id
          left join utilisateurs u  on u.id = m.utilisateur_id
          left join prestataires p  on p.id = m.prestataire_id
         where i.anomalie_id = ${id} and m.type = 'sortie'
         order by m.date_mouvement desc`
    : [];

  const PRIORITES = ["basse", "normale", "haute", "urgente"] as const;

  // Les lieux, pour corriger celui d'une anomalie reprise de travers. Les
  // paliers et les locaux en font partie : ce sont des lieux comme les autres.
  const lieux = modifiable
    ? await sql<{ id: string; code: string; etage: string }[]>`
        select e.id, e.code, et.nom as etage
          from emplacements e join etages et on et.id = e.etage_id
         order by et.ordre, e.code`
    : [];

  // Le métier décide si un intervenant SPÉCIALISÉ voit l'anomalie
  // (fn_anomalies_pour_intervenant lit anomalies.type_id) — une ligne reprise
  // sans type, ou avec le mauvais, est invisible pour tous les spécialistes
  // sans qu'aucun écran ne le montre jusqu'ici.
  const types = modifiable
    ? await sql<{ id: string; nom: string }[]>`
        select id, nom from types_intervention where actif order by nom`
    : [];

  /**
   * Corriger une anomalie.
   *
   * La description reprise de l'ancienne application porte des coquilles, une
   * date de déclaration fausse décale le comptage des récurrences, et **le
   * lieu lui-même peut être faux** : l'ancienne application avait un champ
   * libre, et « lavabo bouché » s'est retrouvé sur le palier du 4ème au lieu
   * d'une chambre. Si on ne peut pas le corriger, l'historique de la chambre
   * est faux pour toujours — et le comptage des récurrences avec lui.
   *
   * L'état, lui, ne se corrige jamais ici : il se décide en déclarant, en
   * intervenant ou en validant.
   */
  async function modifier(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!suitLesDossiers(profil_?.role)) redirect(`/anomalie/${id}` as Route);

    const description = String(donnees.get("description") ?? "").trim();
    const priorite = String(donnees.get("priorite") ?? "normale");
    const jour = String(donnees.get("jour") ?? "").trim();
    const lieu = String(donnees.get("lieu") ?? "").trim();
    // Vide = aucun type : visible seulement aux intervenants polyvalents.
    // Un choix délibéré se fait en touchant le select — pas une case qu'on
    // laisse par défaut, mais on ne force pas non plus une valeur qu'on ne
    // connaît pas.
    const typeId = String(donnees.get("type_id") ?? "").trim() || null;
    if (!description || !PRIORITES.includes(priorite as (typeof PRIORITES)[number])) return;

    // Une date vide ou mal formée ne doit pas effacer la date de déclaration :
    // `coalesce` garde celle qui est en place. L'heure d'origine est conservée
    // — elle sert à ranger deux déclarations du même jour.
    const dateValide = /^\d{4}-\d{2}-\d{2}$/.test(jour) ? jour : null;
    try {
      await sql`
        update anomalies
           set description    = ${description},
               priorite       = ${priorite}::priorite_anomalie,
               emplacement_id = coalesce(${lieu || null}::uuid, emplacement_id),
               declare_le     = coalesce(${dateValide}::date, declare_le::date)
                                  + declare_le::time,
               type_id        = ${typeId}::uuid,
               maj_le         = now()
         where id = ${id}`;
    } catch (e) {
      // Le même problème ne peut pas être ouvert deux fois au même endroit :
      // l'index le refuse, et c'est la base qui a raison. On le dit plutôt que
      // d'avaler l'échec — mais seulement pour CE refus-là : une autre erreur
      // doit remonter telle quelle, pas se déguiser en doublon.
      const doublon =
        typeof e === "object" && e !== null && (e as { code?: string }).code === "23505";
      if (!doublon) throw e;
      redirect(`/anomalie/${id}?fait=deja-ouverte` as Route);
    }
    revalidatePath(`/anomalie/${id}`);
    redirect(`/anomalie/${id}?fait=modifie` as Route);
  }

  /**
   * Retirer une ligne de matériel enregistrée par erreur.
   *
   * Décocher une déclaration supprime son matériel tant que la tournée est
   * ouverte (règle 10bis) ; passé ce moment, rien ne permettait de défaire
   * une sortie mal comptée sans une correction écrite à la main en base — ce
   * qui vient d'arriver sur une batterie NI-Cd sortie pour zéro pièce
   * réellement constatée. La pièce revient en réserve : le stock est une
   * somme (règle 1), retirer le mouvement suffit à la remonter.
   */
  async function retirerMateriel(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!suitLesDossiers(profil_?.role)) redirect(`/anomalie/${id}` as Route);
    const mouvementId = String(donnees.get("mouvement_id") ?? "");
    if (!mouvementId) return;
    await sql`
      delete from mouvements_stock m
       using interventions i
       where m.id = ${mouvementId}
         and m.intervention_id = i.id
         and i.anomalie_id = ${id}
         and m.type = 'sortie'`;
    revalidatePath(`/anomalie/${id}`);
    redirect(`/anomalie/${id}?fait=materiel-retire` as Route);
  }

  /**
   * Supprimer une anomalie.
   *
   * Trois personnes seulement — Victoria, Sarah P, Miguel. Depuis la 0022, le
   * matériel sorti REVIENT en réserve : ce qu'on supprime n'a pas eu lieu, et
   * une sortie laissée en place retirerait de l'étagère une pièce que
   * personne n'a prise. L'écran le dit avant, chiffre en main.
   */
  async function supprimer() {
    "use server";
    const profil_ = await profilActif();
    if (!peutSupprimer(profil_?.role)) redirect(`/anomalie/${id}` as Route);
    const [ou] = await sql<{ code: string }[]>`
      select e.code from anomalies a
      join emplacements e on e.id = a.emplacement_id where a.id = ${id}`;
    await sql`delete from anomalies where id = ${id}`;
    revalidatePath("/gouvernante/declarer");
    redirect(
      ou
        ? (`/gouvernante/historique/${encodeURIComponent(ou.code)}?fait=supprime` as Route)
        : ("/gouvernante/declarer?fait=supprime" as Route),
    );
  }

  async function commenter(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");

    const texte = String(donnees.get("commentaire") ?? "").trim();
    if (texte) {
      await sql`
        insert into commentaires (anomalie_id, texte, auteur_id, saisie_par)
        values (${id}, ${texte}, ${profil_.id}, ${profil_.id})`;
    }

    for (const fichier of donnees.getAll("photos")) {
      // Un champ resté vide rend quand même un File, de taille nulle. Sans ce
      // test, déclarer SANS photo partait au dépôt, échouait, et l'écran
      // annonçait « la photo n'a pas pu être enregistrée » alors qu'il n'y en
      // avait aucune — un échec inventé sur le geste le plus courant.
      if (!(fichier instanceof File) || fichier.size === 0) continue;
      const chemin = await enregistrerPhoto(fichier);
      if (!chemin) continue;
      await sql`
        insert into photos_anomalie (anomalie_id, chemin, moment, prise_par)
        values (${id}, ${chemin}, 'constat', ${profil_.id})`;
    }

    revalidatePath(`/anomalie/${id}`);
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      {/* On arrive ici depuis l'historique du lieu : sans retour, le seul
          moyen de repartir était le bouton du navigateur. */}
      <Entete
        titre={anomalie.emplacement}
        sous_titre={anomalie.etage}
        retour={`/gouvernante/historique/${encodeURIComponent(anomalie.emplacement)}`}
      />

      <div className="px-5 py-5 flex flex-col gap-6">
        <Confirmation quoi={fait} />
        <div className="flex flex-col gap-2">
          <h1 className="font-display font-semibold text-[19px] leading-snug text-pretty">
            {anomalie.description}
          </h1>
          <p className="flex flex-wrap items-center gap-2 text-[11.5px]">
            <span
              className={`px-2 py-0.5 rounded-md ${TON_STATUT[anomalie.statut].fond} ${TON_STATUT[anomalie.statut].texte}`}
            >
              {LIBELLE_STATUT[anomalie.statut]}
            </span>
            {/* Le métier décide qui la voit (les spécialistes ne voient que
                le leur, règle 15) — jusqu'ici invisible sans ouvrir
                « Corriger cette anomalie ». Une anomalie sans métier n'est
                pas un cas neutre : elle disparaît pour tout intervenant
                spécialisé, le dire en amber plutôt qu'en gris. */}
            <span
              className={
                anomalie.type_intervention
                  ? "px-2 py-0.5 rounded-md bg-surface-muted text-ink-soft"
                  : "px-2 py-0.5 rounded-md bg-amber-soft text-amber"
              }
            >
              {anomalie.type_intervention ?? "Aucun métier"}
            </span>
            <span className="text-ink-faint">
              {anomalie.constate_par ? `${anomalie.constate_par}, ` : ""}
              {jours(anomalie.jours_depuis)}
            </span>
          </p>
        </div>

        <Vignettes
          chemins={photos.filter((p) => p.moment === "constat").map((p) => p.chemin)}
          titre="Au constat"
          ton="text-blue"
        />
        <Vignettes
          chemins={photos.filter((p) => p.moment === "apres").map((p) => p.chemin)}
          titre="Après intervention"
          ton="text-green"
        />

        <section className="flex flex-col gap-2.5">
          <h2 className="etiquette">Le fil · {messages.length}</h2>
          <Fil messages={messages} />
        </section>

        <form action={commenter} className="flex flex-col gap-3 border-t border-line pt-5">
          <ChampCommentaire libelle="Ajouter un commentaire" />
          <ChampPhotos libelle="Ajouter une photo" />
          <button className="h-[50px] rounded-[14px] bg-plum text-white font-display font-semibold text-[15px]">
            Ajouter au fil
          </button>
        </form>

        {modifiable && (
          <details className="border-t border-line pt-5">
            <summary className="list-none cursor-pointer text-[13px] text-plum underline underline-offset-4">
              Corriger cette anomalie
            </summary>
            <form action={modifier} className="mt-3 carte px-3.5 py-3 flex flex-col gap-2.5">
              <label className="flex flex-col gap-1">
                <span className="etiquette">Description</span>
                <textarea
                  name="description"
                  rows={2}
                  defaultValue={anomalie.description}
                  className="w-full rounded-[11px] border border-line bg-surface px-3 py-2.5 text-[15px] leading-snug resize-none"
                />
              </label>
              <div className="flex gap-2">
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Priorité</span>
                  <select
                    name="priorite"
                    defaultValue={anomalie.priorite}
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[15px]"
                  >
                    {PRIORITES.map((p) => (
                      <option key={p} value={p}>
                        {p}
                      </option>
                    ))}
                  </select>
                </label>
                <label className="flex-1 min-w-0 flex flex-col gap-1">
                  <span className="etiquette">Déclarée le</span>
                  <input
                    type="date"
                    name="jour"
                    defaultValue={jourISO(anomalie.declare_le)}
                    className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[15px]"
                  />
                </label>
              </div>
              <label className="flex flex-col gap-1">
                <span className="etiquette">Lieu</span>
                <select
                  name="lieu"
                  defaultValue={lieux.find((x) => x.code === anomalie.emplacement)?.id ?? ""}
                  className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[15px]"
                >
                  {lieux.map((x) => (
                    <option key={x.id} value={x.id}>
                      {x.code} — {x.etage}
                    </option>
                  ))}
                </select>
              </label>
              <label className="flex flex-col gap-1">
                <span className="etiquette">Métier</span>
                <select
                  name="type_id"
                  defaultValue={anomalie.type_id ?? ""}
                  className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[15px]"
                >
                  <option value="">— Aucun (visible aux polyvalents seulement) —</option>
                  {types.map((t) => (
                    <option key={t.id} value={t.id}>
                      {t.nom}
                    </option>
                  ))}
                </select>
                <span className="text-[11px] text-ink-faint text-pretty">
                  {anomalie.catalogue_libelle
                    ? `Catalogue : « ${anomalie.catalogue_libelle} ». `
                    : "Hors catalogue. "}
                  C’est CE champ qui décide si un intervenant spécialisé voit l’anomalie — pas le
                  catalogue seul, qui ne sert qu’aux anomalies créées depuis l’application.
                </span>
              </label>
              <p className="text-[11.5px] text-ink-faint text-pretty leading-snug">
                Corriger le lieu déplace l’anomalie dans l’historique de la chambre et dans le
                comptage des récurrences — à faire quand la reprise s’est trompée de porte, pas
                pour autre chose. L’état ne se corrige pas ici : il se décide en déclarant, en
                intervenant ou en validant.
              </p>
              <BoutonEnvoi
                pendant="…"
                className="h-[44px] rounded-[12px] bg-plum text-white font-display font-semibold text-[14px]"
              >
                Enregistrer
              </BoutonEnvoi>
            </form>
          </details>
        )}

        {/* Une ligne se retire, pas la sortie entière : c'est le geste qui
            corrige un matériel mal compté sans toucher au reste — l'avis du
            technicien, les photos, la clôture. Confirmé comme une
            suppression, en plus léger : la pièce revient en réserve, ce
            n'est pas une trace qui disparaît. */}
        {modifiable && materiel.length > 0 && (
          <section className="flex flex-col gap-2 border-t border-line pt-5">
            <h2 className="etiquette">Matériel utilisé</h2>
            <ul className="carte divide-y divide-line">
              {materiel.map((m) => (
                <li key={m.id} className="px-3.5 py-2.5 flex items-center gap-3">
                  <span className="grow min-w-0">
                    <span className="block text-[13.5px]">
                      {m.produit} · {Math.abs(Number(m.quantite))}
                    </span>
                    <span className="block text-[11px] text-ink-faint">
                      {new Date(m.date_mouvement).toLocaleDateString("fr-FR")}
                      {m.qui && ` · ${m.qui}`}
                    </span>
                  </span>
                  {aRetirer === m.id ? (
                    <span className="shrink-0 flex items-center gap-1.5">
                      <Link
                        href={`/anomalie/${id}` as Route}
                        replace
                        className="h-[34px] px-2.5 rounded-lg bg-surface-muted text-[12.5px] text-ink-soft grid place-items-center"
                      >
                        Annuler
                      </Link>
                      <form action={retirerMateriel}>
                        <input type="hidden" name="mouvement_id" value={m.id} />
                        <BoutonEnvoi
                          pendant="…"
                          className="h-[34px] px-2.5 rounded-lg bg-red text-white text-[12.5px] font-medium"
                        >
                          Oui, retirer
                        </BoutonEnvoi>
                      </form>
                    </span>
                  ) : (
                    <Link
                      href={`/anomalie/${id}?retirer=${m.id}` as Route}
                      replace
                      className="shrink-0 text-[12px] text-ink-faint underline underline-offset-4"
                    >
                      Retirer
                    </Link>
                  )}
                </li>
              ))}
            </ul>
            <p className="text-[11.5px] text-ink-faint text-pretty leading-snug">
              La pièce revient en réserve — à réserver à une sortie qui n’a pas réellement eu
              lieu (une quantité comptée à zéro, un mauvais produit). Ce qui a été réellement
              posé se laisse : le retirer fausserait le stock.
            </p>
          </section>
        )}

        {/* Supprimer se confirme, en deux temps, comme « Fin d'intervention ».
            Un dépliant n'est pas une confirmation : on l'ouvre pour voir ce
            qu'il y a dedans, et le bouton rouge est déjà sous le pouce. Une
            anomalie d'il y a six mois a disparu comme ça. */}
        {supprimable && (
          <div className="border-t border-line pt-5">
            {!confirmeSuppression ? (
              <Link
                href={`/anomalie/${id}?supprimer=1` as Route}
                replace
                className="text-[13px] text-ink-faint underline underline-offset-4"
              >
                Supprimer cette anomalie
              </Link>
            ) : (
            <div className="mt-3 rounded-card bg-red-soft px-4 py-3.5 flex flex-col gap-3">
              <p className="font-display font-semibold text-[15.5px] text-red">
                Supprimer « {anomalie.description} » ?
              </p>
              <p className="text-[13px] text-red text-pretty leading-snug">
                La ligne disparaît pour de bon, avec son fil
                {messages.length > 0 && ` (${messages.length} message${messages.length > 1 ? "s" : ""})`}
                {emporte.photos > 0 &&
                  `, ${emporte.photos} photo${emporte.photos > 1 ? "s" : ""}`}
                {emporte.interventions > 0 &&
                  ` et ${emporte.interventions} intervention${emporte.interventions > 1 ? "s" : ""}`}
                . À réserver à ce qui n’aurait jamais dû être déclaré — une erreur de chambre,
                un doublon. Un problème résolu se clôt, il ne se supprime pas.
              </p>
              {emporte.sorties > 0 && (
                <p className="text-[12px] text-red/80 text-pretty leading-snug">
                  {rendLeMateriel ? (
                    <>
                      {emporte.sorties} sortie{emporte.sorties > 1 ? "s" : ""} de stock
                      {" "}repart{emporte.sorties > 1 ? "ent" : ""} avec elle :{" "}
                      {Number(emporte.pieces)} pièce
                      {Number(emporte.pieces) > 1 ? "s reviennent" : " revient"} en réserve.
                      Si le matériel a réellement été posé, ne supprimez pas — clôturez.
                    </>
                  ) : (
                    <>
                      Le matériel sorti pour cette anomalie n’est pas remis en réserve : il a
                      bien quitté le stock.
                    </>
                  )}
                </p>
              )}
              <div className="flex gap-2.5">
                <Link
                  href={`/anomalie/${id}` as Route}
                  replace
                  className="flex-1 h-[46px] rounded-[12px] bg-surface border border-line text-ink-soft font-display font-semibold text-[14.5px] grid place-items-center"
                >
                  Annuler
                </Link>
                <form action={supprimer} className="flex-1">
                  <BoutonEnvoi
                    pendant="Suppression…"
                    className="h-[46px] w-full rounded-[12px] bg-red text-white font-display font-semibold text-[14.5px]"
                  >
                    Oui, supprimer
                  </BoutonEnvoi>
                </form>
              </div>
            </div>
            )}
          </div>
        )}
      </div>
    </main>
  );
}
