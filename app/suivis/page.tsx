import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { exigerEncadrement } from "@/lib/acces";
import { tableExiste } from "@/lib/schema";
import { depuis, jourISO } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";
import { Stat } from "@/app/composants/suivi";

export const dynamic = "force-dynamic";

type Suivi = {
  id: string;
  titre: string;
  nature: string;
  permanent: boolean;
  ouvert_le: string | Date;
  clos_le: string | Date | null;
  nb_episodes: number;
  nb_actes: number;
  nb_lieux: number;
  nb_non_regles: number;
  nb_a_controler: number;
  dernier_acte: string | Date | null;
  periodicite_jours: number | null;
  derniere_verification_nature: string | Date | null;
};

/**
 * Les suivis : les histoires qui ne tiennent pas dans une anomalie.
 *
 * Une anomalie est un problème dans un lieu, qu'on répare et qu'on clôt. Une
 * histoire de punaises traverse des chambres et des semaines, enchaîne des
 * actes dont l'ordre varie, et ne se termine pas par une réparation mais par
 * une vérification qui revient négative.
 */
export default async function Suivis() {
  await exigerEncadrement();

  // Le code part en ligne avant la migration : sans la 0023, l'écran le dit
  // au lieu de casser.
  if (!(await tableExiste("suivis"))) {
    return (
      <main className="min-h-dvh flex flex-col max-w-md mx-auto">
        <Entete titre="Suivis" retour="/technique" />
        <div className="px-5 py-5">
          <p className="rounded-card bg-amber-soft px-4 py-3.5 text-[13.5px] text-amber text-pretty leading-snug">
            Les suivis n’existent pas encore dans la base. Ouvrez{" "}
            <b>Administration → État de l’application</b> et jouez les migrations.
          </p>
        </div>
      </main>
    );
  }

  const suivis = await sql<Suivi[]>`
    select id, titre, nature, permanent, ouvert_le, clos_le, nb_episodes::int,
           nb_actes::int, nb_lieux::int, nb_non_regles::int, nb_a_controler::int,
           dernier_acte, periodicite_jours, derniere_verification_nature
    from v_suivis order by permanent desc, ouvert_le desc`;

  const permanents = suivis.filter((s) => s.permanent);
  const episodes = suivis.filter((s) => !s.permanent);
  const aControler = episodes.reduce((n, s) => n + s.nb_a_controler, 0);

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Suivis"
        sous_titre={`${permanents.length} dossier${permanents.length > 1 ? "s" : ""} · ${episodes.length} épisode${episodes.length > 1 ? "s" : ""}`}
        retour="/technique"
      />

      <div className="px-5 py-4 flex flex-col gap-4">
        <div className="flex gap-2">
          <Stat valeur={episodes.length} libelle="Épisodes" />
          <Stat
            valeur={aControler}
            libelle="À contrôler"
            ton={aControler > 0 ? "alerte" : undefined}
          />
          <Stat
            valeur={episodes.filter((s) => s.clos_le).length}
            libelle="Réglés"
          />
        </div>

        {permanents.map((p) => {
          // Le rythme : c'est ce qu'un dossier permanent doit dire tout seul.
          const derniere = p.derniere_verification_nature
            ? new Date(jourISO(p.derniere_verification_nature))
            : null;
          const jours = derniere
            ? Math.round((Date.now() - derniere.getTime()) / 86_400_000)
            : null;
          const enRetard =
            jours !== null && p.periodicite_jours !== null && jours > p.periodicite_jours;
          return (
            <section key={p.id} className="flex flex-col gap-2">
              <Link
                href={`/suivis/${p.id}` as Route}
                className="rounded-tile bg-plum text-white px-5 py-[20px] flex flex-col gap-1"
              >
                <span className="etiquette text-white/60">Dossier permanent</span>
                <span className="font-display font-bold text-[21px]">{p.titre}</span>
                <span className="text-[12.5px] text-white/75">
                  {p.nb_episodes} épisode{p.nb_episodes > 1 ? "s" : ""} · {p.nb_lieux} lieux
                  surveillés
                </span>
              </Link>
              {enRetard && (
                <p className="rounded-card bg-amber-soft px-4 py-3 text-[12.5px] text-amber text-pretty leading-snug">
                  Dernière vérification il y a <b>{jours} jours</b>, pour un rythme attendu de{" "}
                  {p.periodicite_jours}. La campagne est en retard.
                </p>
              )}
            </section>
          );
        })}

        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Les épisodes</h2>
          {episodes.length === 0 ? (
            <Vide>Aucun épisode ouvert.</Vide>
          ) : (
            <ul className="flex flex-col gap-2">
              {episodes.map((s) => (
                <li key={s.id}>
                  <Link
                    href={`/suivis/${s.id}` as Route}
                    className="carte px-4 py-3.5 flex flex-col gap-1.5 active:bg-surface-muted"
                  >
                    <span className="flex items-start gap-3">
                      <span className="grow min-w-0 font-display font-semibold text-[15.5px] leading-snug">
                        {s.titre}
                      </span>
                      <span
                        className={`shrink-0 px-2 py-0.5 rounded-md text-[11px] ${
                          s.nb_a_controler > 0
                            ? "bg-amber-soft text-amber"
                            : s.nb_non_regles > 0
                              ? "bg-red-soft text-red"
                              : "bg-green-soft text-green"
                        }`}
                      >
                        {s.nb_a_controler > 0
                          ? "à contrôler"
                          : s.nb_non_regles > 0
                            ? "en cours"
                            : "réglé"}
                      </span>
                    </span>
                    <span className="text-[11.5px] text-ink-faint">
                      {s.nb_actes} acte{s.nb_actes > 1 ? "s" : ""} · {s.nb_lieux} lieu
                      {s.nb_lieux > 1 ? "x" : ""} ·{" "}
                      {s.clos_le
                        ? `clos le ${new Date(s.clos_le).toLocaleDateString("fr-FR")}`
                        : s.dernier_acte
                          ? `dernier acte ${depuis(
                              Math.round(
                                (Date.now() - new Date(jourISO(s.dernier_acte)).getTime()) /
                                  86_400_000,
                              ),
                              s.dernier_acte,
                            )}`
                          : "aucun acte"}
                    </span>
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </section>
      </div>
    </main>
  );
}
