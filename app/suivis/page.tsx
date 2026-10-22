import Link from "next/link";
import type { Route } from "next";
import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { sql } from "@/lib/db";
import { exigerEncadrement } from "@/lib/acces";
import { tableExiste } from "@/lib/schema";
import { depuis, jourISO, suitLesDossiers } from "@/lib/domaine";
import { codeDepuis, ETAPES_PROPOSEES, ressembleAUneVisite } from "@/lib/suivis";
import { Entete, Vide } from "@/app/composants/ui";
import { Stat } from "@/app/composants/suivi";
import { Depliant } from "@/app/composants/depliant";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";

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
/**
 * Créer un dossier de suivi à soi — un contrat de désenfumage, la
 * vérification des extincteurs.
 *
 * Une seule nature existait, posée par la migration : les punaises. « Je
 * souhaite que ce soit moi-même qui le fasse » : le nom, le rythme des visites
 * du contrat, et la liste des étapes (le « quoi »), qui se corrige ensuite
 * dans « Les étapes » du dossier. Le dossier créé est permanent — c'est lui
 * qui porte la chronologie du contrat.
 */
async function creerDossier(donnees: FormData) {
  "use server";
  const p = await exigerEncadrement();
  if (!suitLesDossiers(p.role)) redirect("/suivis" as Route);

  const nom = String(donnees.get("nom") ?? "").trim();
  if (nom.length < 3) return;
  const mois = Number(String(donnees.get("mois") ?? "").replace(",", "."));
  const periodicite = mois > 0 ? Math.round((mois * 365) / 12) : null;
  const etapes = [
    ...new Set(
      String(donnees.get("etapes") ?? "")
        .split(/\r?\n/)
        .map((l) => l.trim())
        .filter((l) => l.length > 0),
    ),
  ];
  if (etapes.length === 0) return;

  const id = await sql.begin(async (tx) => {
    // Un code unique, même si deux dossiers portent un nom proche.
    const base = codeDepuis(nom);
    const pris = await tx<{ code: string }[]>`
      select code from natures_suivi where code = ${base} or code like ${base + "-%"}`;
    let code = base;
    for (let n = 2; pris.some((x) => x.code === code); n++) code = `${base}-${n}`;

    await tx`
      insert into natures_suivi (code, libelle, periodicite_jours, ordre)
      values (${code}, ${nom}, ${periodicite},
              (select coalesce(max(ordre), 0) + 1 from natures_suivi))`;

    const vus = new Set<string>();
    for (const [i, libelle] of etapes.entries()) {
      let codeEtape = codeDepuis(libelle);
      while (vus.has(codeEtape)) codeEtape += "-bis";
      vus.add(codeEtape);
      await tx`
        insert into types_acte (nature_code, code, libelle, est_verification,
                                est_traitement, porte_sur_lieux, ordre)
        values (${code}, ${codeEtape}, ${libelle}, ${ressembleAUneVisite(libelle)},
                false, false, ${i + 1})`;
    }

    const [cree] = await tx<{ id: string }[]>`
      insert into suivis (nature_code, titre, declencheur, cree_par)
      values (${code}, ${nom}, 'reglementaire', ${p.id})
      returning id`;
    return cree.id;
  });

  revalidatePath("/suivis");
  redirect(`/suivis/${id}?fait=dossier-cree` as Route);
}

export default async function Suivis() {
  const profil = await exigerEncadrement();

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
                  {/* Un contrat de désenfumage ne surveille pas de chambres :
                      « 0 lieux surveillés » n'apprenait rien. */}
                  {p.nb_actes} acte{p.nb_actes > 1 ? "s" : ""}
                  {p.nb_episodes > 0 &&
                    ` · ${p.nb_episodes} épisode${p.nb_episodes > 1 ? "s" : ""}`}
                  {p.nb_lieux > 0 && ` · ${p.nb_lieux} lieux surveillés`}
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

        {/* Créer un dossier à soi : un contrat, une vérification réglementaire —
            n'importe quelle histoire qui ne tient pas dans une anomalie. */}
        {suitLesDossiers(profil.role) && (
          <Depliant
            titre="Nouveau dossier de suivi"
            aide="Un contrat, une vérification réglementaire : son nom, son rythme, ses étapes."
          >
            <form action={creerDossier} className="flex flex-col gap-3">
              <label className="flex flex-col gap-1">
                <span className="etiquette">Nom du dossier</span>
                <input
                  name="nom"
                  required
                  minLength={3}
                  autoComplete="off"
                  placeholder="Désenfumage, Extincteurs…"
                  className="h-[48px] rounded-[12px] border border-line px-3 bg-surface text-[16px] placeholder:text-ink-faint"
                />
              </label>
              <label className="flex flex-col gap-1">
                <span className="etiquette">Une visite tous les… (facultatif)</span>
                <span className="flex items-center gap-2">
                  <input
                    name="mois"
                    type="number"
                    min={1}
                    step={1}
                    inputMode="numeric"
                    placeholder="12"
                    className="w-[96px] h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[16px] tabular-nums placeholder:text-ink-faint"
                  />
                  <span className="text-[14px] text-ink-soft">mois</span>
                </span>
                <span className="text-[11.5px] text-ink-faint text-pretty">
                  Le dossier dira quand la visite est en retard.
                </span>
              </label>
              <label className="flex flex-col gap-1">
                <span className="etiquette">Les étapes — une par ligne</span>
                <textarea
                  name="etapes"
                  rows={6}
                  required
                  defaultValue={ETAPES_PROPOSEES.join("\n")}
                  className="rounded-[12px] border border-line px-3 py-2.5 bg-surface text-[15px] leading-snug"
                />
                <span className="text-[11.5px] text-ink-faint text-pretty">
                  C’est la liste « Quoi » des actes. Elle se corrige ensuite dans « Les étapes »
                  du dossier.
                </span>
              </label>
              <BoutonEnvoi
                pendant="Création…"
                className="h-[50px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15.5px]"
              >
                Créer le dossier
              </BoutonEnvoi>
            </form>
          </Depliant>
        )}

        <section className="flex flex-col gap-2">
          <h2 className="titre text-[15.5px]">Les épisodes</h2>
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
