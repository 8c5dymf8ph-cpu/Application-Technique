import { notFound, redirect } from "next/navigation";
import Link from "next/link";
import { RechercheVive } from "@/app/composants/recherche-vive";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { QuitterSiRevenu } from "@/app/composants/quitter-si-revenu";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import {
  jours,
  LIBELLE_STATUT,
  suitLesDossiers,
  TON_STATUT,
  type StatutAnomalie,
} from "@/lib/domaine";
import { Entete, Indices, Vide } from "../../../composants/ui";
import { ChampPhotos } from "../../../composants/photos";
import { ChampCommentaire } from "../../../composants/fil";
import { enregistrerPhoto } from "@/lib/stockage";

export const dynamic = "force-dynamic";

type Existante = {
  anomalie_id: string;
  description: string;
  statut: StatutAnomalie;
  ouverte: boolean;
  jours_depuis: number;
  constate_par: string | null;
  nb_photos: number;
  nb_commentaires: number;
};

type Entree = {
  id: string;
  libelle: string;
  occurrences: number;
  deja_ouverte: boolean;
  ouverte_depuis: number | null;
  nb_fois_ici: number;
  derniere_fois: string | null;
};

/** « 3e fois ici » se lit mieux que « déjà survenu 2 fois ». */
function rang(n: number): string {
  const suivant = n + 1;
  return suivant === 2 ? "2e fois ici" : `${suivant}e fois ici`;
}

export default async function Declarer({
  params,
  searchParams,
}: {
  params: Promise<{ code: string }>;
  searchParams: Promise<{
    q?: string;
    choix?: string;
    jour?: string;
    presse?: string;
  }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  const { code } = await params;
  const { q = "", choix, jour, presse } = await searchParams;
  /**
   * La date du constat.
   *
   * Depuis un passage saisi, l'anomalie a été constatée CE jour-là. Sans elle,
   * elle arrive datée d'aujourd'hui et se retrouve après l'intervention qui
   * l'a résolue : un historique où le problème naît après sa réparation.
   */
  const jourDuConstat = jour && /^\d{4}-\d{2}-\d{2}$/.test(jour) ? jour : undefined;

  /** La priorité choisie en créant le libellé, s'il vient d'être créé. */
  const presseChoisie = ["basse", "normale", "haute", "urgente"].includes(presse ?? "")
    ? presse!
    : null;
  const lieu = decodeURIComponent(code);

  const [emplacement] = await sql<{ id: string; code: string; etage: string }[]>`
    select e.id, e.code, et.nom as etage
    from emplacements e join etages et on et.id = e.etage_id
    where e.code = ${lieu} and e.actif`;
  if (!emplacement) notFound();

  /**
   * L'adresse de cet écran, avec ses paramètres.
   *
   * Les liens pointaient vers « ?q=…&choix=… », sans chemin. Next ne résout
   * pas cette forme de façon fiable dans l'App Router : le clic ne faisait
   * rien du tout, sur n'importe quelle chambre.
   */
  const lien = (p: { q?: string; choix?: string }) => {
    const params = new URLSearchParams();
    if (p.q) params.set("q", p.q);
    if (p.choix) params.set("choix", p.choix);
    const suite = params.toString();
    return `/gouvernante/declarer/${encodeURIComponent(lieu)}${suite ? "?" + suite : ""}` as Route;
  };

  // Les totaux sont comptés à part : la liste affichée est tronquée, et un
  // compteur qui refléterait la troncature mentirait.
  // En déclarant, elle n'a besoin que de ce qui est encore à traiter. Le reste
  // est de l'historique : consultable d'un geste, mais pas dans le chemin.
  const [total] = await sql<{ en_cours: number; passees: number }[]>`
    select count(*) filter (where statut in ('a_faire','en_cours','a_acheter'))::int as en_cours,
           count(*) filter (where statut in ('validee','attente_validation'))::int   as passees
    from v_anomalies_du_lieu where emplacement_id = ${emplacement.id}`;

  const enCours = await sql<Existante[]>`
    select anomalie_id, description, statut, ouverte, jours_depuis, constate_par,
           nb_photos, nb_commentaires
    from v_anomalies_du_lieu
    where emplacement_id = ${emplacement.id}
      and statut in ('a_faire','en_cours','a_acheter')
    order by declare_le desc`;

  // Le catalogue vu depuis ce lieu : chaque libellé sait s'il y est déjà ouvert.
  const resultats = q.trim()
    ? await sql<Entree[]>`
        select id, libelle, occurrences, deja_ouverte, ouverte_depuis,
               nb_fois_ici, derniere_fois
        from fn_catalogue_pour_lieu(${emplacement.id}, ${q}) limit 15`
    : [];

  const choisie = choix ? resultats.find((r) => r.id === choix) : undefined;

  /**
   * Créer le libellé qui manque.
   *
   * Le catalogue est fermé, et c'est ce qui donne son sens au comptage des
   * récurrences (règle 8). Mais un catalogue qu'on ne peut pas enrichir depuis
   * le terrain finit par mentir : on déclare « autre chose » à la place, ou on
   * ne déclare pas.
   *
   * Le libellé créé REJOINT donc le catalogue — on n'ouvre pas une anomalie
   * hors catalogue, on ajoute le mot qui manquait. La fois suivante, le même
   * problème portera le même nom, et le comptage tombe juste.
   *
   * Réservé à Sarah P et Miguel (`suitLesDossiers`), et la règle est dans la
   * RLS (`fn_peut_enrichir_le_catalogue`), pas ici.
   */
  const enrichit = suitLesDossiers(profil.role);
  const types = enrichit
    ? await sql<{ id: string; nom: string }[]>`
        select id, nom from types_intervention order by nom`
    : [];

  /** Ajouter un libellé au catalogue, puis revenir dessus pour le déclarer. */
  async function creerLeLibelle(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !suitLesDossiers(profil_.role)) {
      redirect(`/gouvernante/declarer/${encodeURIComponent(lieu)}`);
    }
    const libelle = String(donnees.get("libelle") ?? "").trim();
    if (libelle.length < 3) {
      redirect(`/gouvernante/declarer/${encodeURIComponent(lieu)}?q=${encodeURIComponent(libelle)}`);
    }
    const choixType = String(donnees.get("type") ?? "");
    const type = choixType && choixType !== "aucun" ? choixType : null;
    const priorite = String(donnees.get("priorite") ?? "normale");

    // `on conflict` : le libellé est unique. Si quelqu'un vient de l'ajouter,
    // on récupère le sien plutôt que de refuser — c'est le même problème.
    const [entree] = await sql<{ id: string }[]>`
      insert into catalogue_anomalies (libelle, type_id, cree_par)
      values (${libelle}, ${type}::uuid, ${profil_.id})
      on conflict (libelle) do update set actif = true
      returning id`;

    // On revient sur l'écran avec le libellé cherché ET choisi : le
    // formulaire de déclaration s'ouvre dessus, sans rien à retaper.
    redirect(
      `/gouvernante/declarer/${encodeURIComponent(lieu)}?q=${encodeURIComponent(
        libelle,
      )}&choix=${entree.id}&presse=${priorite}${
        jourDuConstat ? `&jour=${jourDuConstat}` : ""
      }`,
    );
  }

  async function enregistrer(donnees: FormData) {
    "use server";
    const catalogue_id = String(donnees.get("catalogue_id"));
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");

    const [emp] = await sql<{ id: string }[]>`
      select id from emplacements where code = ${lieu}`;

    // La base refuse un problème déjà ouvert ici ; on le dit plutôt que de
    // laisser remonter une erreur technique.
    let anomalie_id: string;
    try {
      const [creee] = await sql<{ id: string }[]>`
        insert into anomalies (emplacement_id, catalogue_id, type_id, description,
                               constate_par, saisie_par, declare_le, priorite)
        select ${emp.id}, c.id, c.type_id, c.libelle, ${profil_.id}, ${profil_.id},
               coalesce(${jourDuConstat ?? null}::date, current_date),
               coalesce(${presseChoisie}::priorite_anomalie, 'normale')
        from catalogue_anomalies c where c.id = ${catalogue_id}
        returning id`;
      anomalie_id = creee.id;
    } catch {
      redirect(`/gouvernante/declarer/${encodeURIComponent(lieu)}?deja=1`);
    }

    // Le commentaire libre de la gouvernante : c'est ici qu'elle écrit ce que
    // le libellé du catalogue ne dit pas.
    const texte = String(donnees.get("commentaire") ?? "").trim();
    if (texte) {
      await sql`
        insert into commentaires (anomalie_id, texte, auteur_id, saisie_par)
        values (${anomalie_id}, ${texte}, ${profil_.id}, ${profil_.id})`;
    }

    // Les photos du constat. Une déclaration sans photo reste valable : c'est
    // un plus, pas une condition.
    let refusee = false;
    for (const fichier of donnees.getAll("photos")) {
      if (!(fichier instanceof File)) continue;
      const chemin = await enregistrerPhoto(fichier);
      // Une photo refusée par le dépôt disparaissait en silence : on la
      // signale, la déclaration reste enregistrée.
      if (!chemin) {
        refusee = true;
        continue;
      }
      await sql`
        insert into photos_anomalie (anomalie_id, chemin, moment, prise_par)
        values (${anomalie_id}, ${chemin}, 'constat', ${profil_.id})`;
    }

    // Retour à la liste des lieux, pas dans la chambre : on vient de finir, et
    // rester devant le même écran laisse douter que ce soit enregistré.
    redirect(
      `/gouvernante/declarer?fait=${refusee ? "declare-sans-photo" : "declare"}&ou=${encodeURIComponent(lieu)}${
        jourDuConstat ? `&jour=${jourDuConstat}` : ""
      }`,
    );
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      {/* Déjà déclaré : la flèche arrière ne rouvre pas le formulaire rempli —
          on le renverrait en croyant qu'il n'était pas parti. */}
      <QuitterSiRevenu cle="anomalie" vers="/gouvernante/declarer" />
      <Entete
        titre={emplacement.code}
        sous_titre={emplacement.etage}
        retour="/gouvernante/declarer"
      />

      <div className="px-5 py-5 flex flex-col gap-6">
        {/* Ce qui reste à traiter ici — rien d'autre */}
        <section className="flex flex-col gap-2.5">
          <div className="flex items-baseline justify-between gap-3">
            <h2 className="etiquette">
              {total.en_cours === 0
                ? "Rien en cours ici"
                : `${total.en_cours} en cours ici`}
            </h2>
            {total.passees > 0 && (
              <Link
                href={`/gouvernante/historique/${encodeURIComponent(emplacement.code)}`}
                className="text-[12.5px] text-plum underline underline-offset-4"
              >
                Historique ({total.passees})
              </Link>
            )}
          </div>

          {enCours.length > 0 && (
            <ul className="flex flex-col gap-2">
              {enCours.map((e) => (
                <li key={e.anomalie_id}>
                  <Link
                    href={`/anomalie/${e.anomalie_id}`}
                    className="carte px-4 py-3 flex flex-col gap-1.5 active:bg-surface-muted"
                  >
                  <div className="flex items-start gap-2">
                    <p className="grow min-w-0 text-[14.5px] leading-snug text-pretty">
                      {e.description}
                    </p>
                    <span className="mt-[1px]">
                      <Indices photos={e.nb_photos} commentaires={e.nb_commentaires} />
                    </span>
                  </div>
                  <p className="flex flex-wrap items-center gap-2 text-[11.5px]">
                    <span
                      className={`px-2 py-0.5 rounded-md ${TON_STATUT[e.statut].fond} ${TON_STATUT[e.statut].texte}`}
                    >
                      {LIBELLE_STATUT[e.statut]}
                    </span>
                    <span className="text-ink-faint">
                      {e.constate_par ? `${e.constate_par}, ` : ""}
                      {jours(e.jours_depuis)}
                    </span>
                  </p>
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </section>

        {/* Chercher dans le catalogue — masqué une fois le choix fait : la
            liste faisait défiler l'enregistrement hors de l'écran, et on ne
            savait pas qu'il fallait encore valider. */}
        <section className={`flex flex-col gap-2.5 ${choisie ? "hidden" : ""}`}>
          <h2 className="etiquette">Que faut-il faire&nbsp;?</h2>
          <RechercheVive
            valeur={q}
            base={`/gouvernante/declarer/${encodeURIComponent(lieu)}`}
            placeholder="Chercher : fuite, spot, liseuse…"
          />

          {q.trim() && resultats.length === 0 && !enrichit && (
            <Vide>
              Aucun libellé ne correspond. Un ajout au catalogue se fait depuis un ordinateur,
              par l’administrateur.
            </Vide>
          )}

          {/* Le libellé qui manque se crée, ici, par Sarah P ou Miguel — et il
              rejoint le catalogue. Une impasse qui renvoie « demandez à
              l'administrateur » quand on EST l'administrateur n'a pas de sens. */}
          {enrichit && q.trim().length >= 3 && (
            <form
              action={creerLeLibelle}
              className="carte px-4 py-3.5 flex flex-col gap-2.5"
            >
              <p className="text-[13px] text-ink-soft text-pretty">
                {resultats.length === 0
                  ? "Aucun libellé ne correspond."
                  : "Rien de tout ça ?"}{" "}
                Ajoutez-le au catalogue : la fois suivante, le même problème
                portera le même mot — c’est ce qui permet de compter les
                récurrences.
              </p>
              {/* Le libellé se corrige avant d'entrer au catalogue : ce
                  qu'on a tapé pour chercher n'est pas toujours ce qu'on veut
                  y laisser pour toujours. */}
              <label className="flex flex-col gap-1">
                <span className="etiquette">Le libellé, tel qu’il restera</span>
                <input
                  name="libelle"
                  defaultValue={q.trim()}
                  autoComplete="off"
                  required
                  minLength={3}
                  className="h-[48px] rounded-[12px] border border-line px-3 bg-surface text-[16px]"
                />
              </label>
              {/* Le métier ne se devine pas : un même mot peut être un travail
                  électrique ou de plomberie, et rien ne dit lequel. Aucun
                  choix par défaut — on demande. */}
              <label className="flex flex-col gap-1">
                <span className="etiquette">De quel métier</span>
                <select
                  name="type"
                  defaultValue=""
                  required
                  className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[15px]"
                >
                  <option value="" disabled>
                    Choisir le métier
                  </option>
                  {types.map((t) => (
                    <option key={t.id} value={t.id}>
                      {t.nom}
                    </option>
                  ))}
                  <option value="aucun">Aucun en particulier</option>
                </select>
              </label>
              <label className="flex flex-col gap-1">
                <span className="etiquette">Ça presse ?</span>
                <select
                  name="priorite"
                  defaultValue="normale"
                  className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[15px]"
                >
                  <option value="basse">Quand ce sera possible</option>
                  <option value="normale">Normale</option>
                  <option value="haute">Prioritaire</option>
                  <option value="urgente">Urgent</option>
                </select>
              </label>
              <BoutonEnvoi
                pendant="Ajout…"
                className="h-[48px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15px]"
              >
                Ajouter au catalogue et déclarer
              </BoutonEnvoi>
            </form>
          )}

          <ul className="flex flex-col gap-2">
            {resultats.map((r) =>
              r.deja_ouverte ? (
                // Déjà ouvert ici : pas proposable, et on dit pourquoi.
                <li
                  key={r.id}
                  className="px-4 py-3.5 rounded-card bg-surface-muted border border-line flex flex-col gap-1"
                >
                  <span className="text-[15px] leading-snug text-ink-faint text-pretty">
                    {r.libelle}
                  </span>
                  <span className="text-[11.5px] text-amber">
                    Déjà en cours ici{" "}
                    {r.ouverte_depuis !== null && `— signalé ${jours(r.ouverte_depuis)}`}
                  </span>
                </li>
              ) : (
                <li key={r.id}>
                  <Link
                    href={lien({ q, choix: r.id })}
                    className="carte w-full px-4 py-3.5 flex items-center gap-3 text-left active:bg-surface-muted"
                  >
                    <span className="flex flex-col gap-0.5 grow min-w-0">
                      <span className="text-[15px] leading-snug text-pretty">{r.libelle}</span>
                      <span className="text-[11.5px] text-ink-faint">
                        {r.nb_fois_ici > 0 ? (
                          <span className="text-blue">{rang(r.nb_fois_ici)}</span>
                        ) : (
                          `vu ${r.occurrences} fois dans l’hôtel`
                        )}
                      </span>
                    </span>
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#8E8AA3"
                         strokeWidth="1.8" strokeLinecap="round" className="shrink-0">
                      <path d="M9 5l7 7-7 7" />
                    </svg>
                  </Link>
                </li>
              ),
            )}
          </ul>
        </section>

        {/* Confirmer */}
        {choisie && (
          <section className="flex flex-col gap-3 order-first">
            <p className="etiquette">Ce que vous déclarez</p>
            <p className="font-display font-semibold text-[19px] leading-snug text-pretty">
              {choisie.libelle}
            </p>
            <Link
              href={lien({ q })}
              className="self-start text-[13.5px] text-plum underline underline-offset-4"
            >
              Choisir autre chose
            </Link>
            {choisie.nb_fois_ici > 0 && (
              <div className="rounded-card bg-blue-soft px-4 py-3 flex flex-col gap-1">
                <p className="text-[13.5px] text-blue leading-snug text-pretty">
                  C’est la <strong>{rang(choisie.nb_fois_ici)}</strong> en {emplacement.code}.
                  {choisie.derniere_fois &&
                    ` La dernière remonte au ${new Date(choisie.derniere_fois).toLocaleDateString("fr-FR")}.`}
                </p>
              </div>
            )}
            <form action={enregistrer} className="flex flex-col gap-3">
              <input type="hidden" name="catalogue_id" value={choisie.id} />
              <ChampCommentaire />
              <ChampPhotos libelle="Ajouter une ou plusieurs photos (facultatif)" />
              <div className="flex gap-2">
              <Link
                href={lien({ q })}
                className="carte px-5 grid place-items-center text-[15px] text-ink-soft"
              >
                Annuler
              </Link>
              <BoutonEnvoi
                pendant="Déclaration…"
                className="grow h-[54px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]"
              >
                Déclarer en {emplacement.code}
              </BoutonEnvoi>
              </div>
            </form>
          </section>
        )}
      </div>
    </main>
  );
}
