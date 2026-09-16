import { notFound, redirect } from "next/navigation";
import Link from "next/link";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { jours, LIBELLE_STATUT, TON_STATUT, type StatutAnomalie } from "@/lib/domaine";
import { Entete, Vide } from "../../../composants/ui";

export const dynamic = "force-dynamic";

type Existante = {
  anomalie_id: string;
  description: string;
  statut: StatutAnomalie;
  ouverte: boolean;
  jours_depuis: number;
  constate_par: string | null;
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
  searchParams: Promise<{ q?: string; choix?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  const { code } = await params;
  const { q = "", choix } = await searchParams;
  const lieu = decodeURIComponent(code);

  const [emplacement] = await sql<{ id: string; code: string; etage: string }[]>`
    select e.id, e.code, et.nom as etage
    from emplacements e join etages et on et.id = e.etage_id
    where e.code = ${lieu} and e.actif`;
  if (!emplacement) notFound();

  // Les totaux sont comptés à part : la liste affichée est tronquée, et un
  // compteur qui refléterait la troncature mentirait.
  const [total] = await sql<{ ouvertes: number; closes: number }[]>`
    select count(*) filter (where ouverte)::int     as ouvertes,
           count(*) filter (where not ouverte)::int as closes
    from v_anomalies_du_lieu
    where emplacement_id = ${emplacement.id} and statut <> 'annulee'`;

  const existantes = await sql<Existante[]>`
    select anomalie_id, description, statut, ouverte, jours_depuis, constate_par
    from v_anomalies_du_lieu
    where emplacement_id = ${emplacement.id} and statut <> 'annulee'
    order by ouverte desc, declare_le desc
    limit 20`;

  // Le catalogue vu depuis ce lieu : chaque libellé sait s'il y est déjà ouvert.
  const resultats = q.trim()
    ? await sql<Entree[]>`
        select id, libelle, occurrences, deja_ouverte, ouverte_depuis,
               nb_fois_ici, derniere_fois
        from fn_catalogue_pour_lieu(${emplacement.id}, ${q}) limit 15`
    : [];

  const choisie = choix ? resultats.find((r) => r.id === choix) : undefined;

  async function enregistrer(donnees: FormData) {
    "use server";
    const catalogue_id = String(donnees.get("catalogue_id"));
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");

    const [emp] = await sql<{ id: string }[]>`
      select id from emplacements where code = ${lieu}`;

    // La base refuse un problème déjà ouvert ici ; on le dit plutôt que de
    // laisser remonter une erreur technique.
    try {
      await sql`
        insert into anomalies (emplacement_id, catalogue_id, type_id, description,
                               constate_par, saisie_par)
        select ${emp.id}, c.id, c.type_id, c.libelle, ${profil_.id}, ${profil_.id}
        from catalogue_anomalies c where c.id = ${catalogue_id}`;
    } catch {
      redirect(`/gouvernante/declarer/${encodeURIComponent(lieu)}?deja=1`);
    }
    redirect(`/gouvernante/declarer/${encodeURIComponent(lieu)}?fait=1`);
  }

  const ouvertes = existantes.filter((e) => e.ouverte);
  const passees = existantes.filter((e) => !e.ouverte);
  const reste = total.ouvertes - ouvertes.length;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={emplacement.code}
        sous_titre={emplacement.etage}
        retour="/gouvernante/declarer"
      />

      <div className="px-5 py-5 flex flex-col gap-6">
        {/* Ce qui est déjà signalé ici, avant toute saisie */}
        <section className="flex flex-col gap-2.5">
          <h2 className="etiquette">
            Déjà signalé ici {total.ouvertes > 0 && `· ${total.ouvertes} en cours`}
          </h2>

          {existantes.length === 0 ? (
            <Vide>Rien n’a encore été signalé dans ce lieu.</Vide>
          ) : (
            <ul className="flex flex-col gap-2">
              {ouvertes.map((e) => (
                <li key={e.anomalie_id} className="carte px-4 py-3 flex flex-col gap-1.5">
                  <p className="text-[14.5px] leading-snug text-pretty">{e.description}</p>
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
                </li>
              ))}
              {reste > 0 && (
                <li className="text-[13px] text-ink-faint px-1">
                  et {reste} autre{reste > 1 ? "s" : ""} en cours
                </li>
              )}
              {passees.length > 0 && (
                <li className="pt-1">
                  <details>
                    <summary className="text-[13px] text-ink-faint cursor-pointer py-2">
                      {total.closes} déjà traitée{total.closes > 1 ? "s" : ""} — voir
                      l’historique
                    </summary>
                    <ul className="flex flex-col gap-1.5 pt-2">
                      {passees.map((e) => (
                        <li
                          key={e.anomalie_id}
                          className="px-4 py-2.5 rounded-card bg-surface-muted flex flex-col gap-0.5"
                        >
                          <p className="text-[13.5px] text-ink-soft leading-snug text-pretty">
                            {e.description}
                          </p>
                          <p className="text-[11.5px] text-ink-faint">
                            {LIBELLE_STATUT[e.statut]} · {jours(e.jours_depuis)}
                          </p>
                        </li>
                      ))}
                    </ul>
                  </details>
                </li>
              )}
            </ul>
          )}
        </section>

        {/* Chercher dans le catalogue */}
        <section className="flex flex-col gap-2.5">
          <h2 className="etiquette">Que faut-il faire&nbsp;?</h2>
          <form method="get" className="flex gap-2">
            <input
              id="recherche"
              name="q"
              defaultValue={q}
              autoComplete="off"
              placeholder="Chercher : fuite, spot, liseuse…"
              className="carte grow px-4 h-[52px] text-[16px] placeholder:text-ink-faint"
            />
            <button className="px-4 rounded-card bg-plum text-white text-[15px]">
              Chercher
            </button>
          </form>

          {q.trim() && resultats.length === 0 && (
            <Vide>
              Aucun libellé ne correspond. Un ajout au catalogue se fait depuis un ordinateur,
              par l’administrateur.
            </Vide>
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
                    href={`?q=${encodeURIComponent(q)}&choix=${r.id}`}
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
          <section className="flex flex-col gap-3 border-t border-line pt-5">
            <p className="font-display font-semibold text-[17px] leading-snug text-pretty">
              {choisie.libelle}
            </p>
            {choisie.nb_fois_ici > 0 && (
              <div className="rounded-card bg-blue-soft px-4 py-3 flex flex-col gap-1">
                <p className="text-[13.5px] text-blue leading-snug text-pretty">
                  C’est la <strong>{rang(choisie.nb_fois_ici)}</strong> en {emplacement.code}.
                  {choisie.derniere_fois &&
                    ` La dernière remonte au ${new Date(choisie.derniere_fois).toLocaleDateString("fr-FR")}.`}
                </p>
              </div>
            )}
            <form action={enregistrer} className="flex gap-2">
              <input type="hidden" name="catalogue_id" value={choisie.id} />
              <Link
                href={`?q=${encodeURIComponent(q)}`}
                className="carte px-5 grid place-items-center text-[15px] text-ink-soft"
              >
                Annuler
              </Link>
              <button className="grow h-[54px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]">
                Déclarer en {emplacement.code}
              </button>
            </form>
          </section>
        )}
      </div>
    </main>
  );
}
