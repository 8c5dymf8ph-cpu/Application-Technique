import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { depuis, suitLesDossiers } from "@/lib/domaine";
import { colonneExiste, regleContient, tableExiste } from "@/lib/schema";
import { Entete, Vide, Confirmation } from "@/app/composants/ui";
import { RechercheVive } from "@/app/composants/recherche-vive";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { LigneDepliante } from "@/app/composants/depliant";

export const dynamic = "force-dynamic";

type Entree = {
  id: string;
  reference: number | null;
  libelle: string;
  metier: string | null;
  nb: number;
  actif: boolean;
};

type Fusion = {
  id: string;
  survivant_libelle: string;
  survivant_reference: number;
  autres_libelles: string[];
  autres_references: number[];
  nb_anomalies: number;
  fusionne_par: string | null;
  fusionne_le: string | Date;
  jours_depuis: number;
  annulee_le: string | Date | null;
  annulee_par: string | null;
  jours_depuis_annulation: number | null;
};

/**
 * Une anomalie déplacée par une fusion, identifiée comme l'hôtel la connaît —
 * par le numéro de SON tableau d'origine (`sharepoint_id`), pas par un numéro
 * interne à l'application. « Reformulée », jamais supprimée : la ligne existe
 * toujours, avec son fil, ses photos, ses interventions ; seuls son libellé
 * et le libellé du catalogue auquel elle est rattachée ont changé.
 */
type AnomalieFusionnee = {
  fusion_id: string;
  anomalie_id: string;
  sharepoint_id: number | null;
  lieu: string | null;
};

/**
 * Fusionner les doublons du catalogue.
 *
 * Le catalogue fermé empêche une TROISIÈME graphie de naître (règle 9bis),
 * mais rien n'empêchait la DEUXIÈME : « télérupteur à changer - spot et
 * leds » et « télérupteur (spots/leds) » sont deux lignes, pas une seule, et
 * la recherche les propose côte à côte. Décider que ce sont le même geste —
 * ou que « serrer le bras » et « changer le flexible » d'une liseuse n'en
 * sont PAS un — est un jugement de métier, pas quelque chose qu'un algorithme
 * de casse et d'accents peut trancher (`generer_catalogue.py` ne lisse que
 * ça). Cet écran donne le geste ; la décision reste à qui a l'expérience du
 * terrain.
 *
 * Deux garanties, demandées en voyant le premier jet :
 *  - « Comment je vérifie ? » — chaque libellé porte un `#référence` court et
 *    stable, à noter avant de fusionner et à retrouver après, dans l'écran ou
 *    dans Supabase — la phrase seule ne distingue pas deux doublons.
 *  - « Assure-toi qu'on puisse revenir en arrière. » — chaque fusion est
 *    journalisée (`fusions_catalogue`), avec la valeur d'AVANT de chaque
 *    anomalie déplacée ; « Annuler » la défait jusqu'au bout.
 */
export default async function Catalogue({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; fait?: string; n?: string; vers?: string }>;
}) {
  const profil = await profilActif();
  if (!profil || !suitLesDossiers(profil.role)) redirect("/administration");

  const { q = "", fait, n, vers } = await searchParams;

  const prete = await regleContient("fn_fusionner_catalogue", "actif = false");
  // Le numéro de vérification et le journal des fusions (migration 0031)
  // peuvent manquer un instant après que la 0030 seule a été jouée : deux
  // requêtes, choisies ici, jamais une colonne absente dans le SQL.
  const verifiable = await colonneExiste("catalogue_anomalies", "reference");
  const journalPret = await tableExiste("fusions_catalogue");

  const resultats = q.trim()
    ? verifiable
      ? await sql<Entree[]>`
          select c.id, c.reference, c.libelle, ti.nom as metier,
                 (select count(*)::int from anomalies a where a.catalogue_id = c.id) as nb,
                 c.actif
            from catalogue_anomalies c
            left join types_intervention ti on ti.id = c.type_id
           where c.libelle ilike ${"%" + q.trim() + "%"}
              or exists (select 1 from unnest(c.mots_cles) m where m ilike ${q.trim() + "%"})
           order by c.actif desc, nb desc, c.libelle
           limit 40`
      : await sql<Entree[]>`
          select c.id, null::int as reference, c.libelle, ti.nom as metier,
                 (select count(*)::int from anomalies a where a.catalogue_id = c.id) as nb,
                 c.actif
            from catalogue_anomalies c
            left join types_intervention ti on ti.id = c.type_id
           where c.libelle ilike ${"%" + q.trim() + "%"}
              or exists (select 1 from unnest(c.mots_cles) m where m ilike ${q.trim() + "%"})
           order by c.actif desc, nb desc, c.libelle
           limit 40`
    : [];
  const actifs = resultats.filter((r) => r.actif);

  const fusions = journalPret
    ? await sql<Fusion[]>`
        select f.id, f.survivant_libelle, f.survivant_reference,
               f.autres_libelles, f.autres_references, f.nb_anomalies,
               u1.nom as fusionne_par, f.fusionne_le,
               (current_date - f.fusionne_le::date)::int as jours_depuis,
               f.annulee_le, u2.nom as annulee_par,
               (current_date - f.annulee_le::date)::int as jours_depuis_annulation
          from fusions_catalogue f
          left join utilisateurs u1 on u1.id = f.fusionne_par
          left join utilisateurs u2 on u2.id = f.annulee_par
         order by f.fusionne_le desc
         limit 15`
    : [];

  const anomaliesFusionnees =
    journalPret && fusions.length > 0
      ? await sql<AnomalieFusionnee[]>`
          select fca.fusion_id, fca.anomalie_id, a.sharepoint_id, e.code as lieu
            from fusions_catalogue_anomalies fca
            join anomalies a on a.id = fca.anomalie_id
            left join emplacements e on e.id = a.emplacement_id
           where fca.fusion_id = any(${fusions.map((f) => f.id)}::uuid[])
           order by a.sharepoint_id nulls last`
      : [];
  const parFusion = (fusionId: string) =>
    anomaliesFusionnees.filter((a) => a.fusion_id === fusionId);

  async function fusionner(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    const recherche = String(donnees.get("q") ?? "");
    if (!suitLesDossiers(profil_?.role)) {
      redirect(`/administration/catalogue?q=${encodeURIComponent(recherche)}` as Route);
    }
    const survivant = String(donnees.get("survivant") ?? "");
    const autres = donnees
      .getAll("autres")
      .map(String)
      .filter((id) => id !== survivant && /^[0-9a-f-]{36}$/.test(id));
    if (!survivant || autres.length === 0) {
      redirect(
        `/administration/catalogue?q=${encodeURIComponent(recherche)}&fait=fusion-incomplete` as Route,
      );
    }

    const [cible] = await sql<{ libelle: string }[]>`
      select libelle from catalogue_anomalies where id = ${survivant}::uuid`;
    if (!cible) {
      redirect(
        `/administration/catalogue?q=${encodeURIComponent(recherche)}&fait=fusion-incomplete` as Route,
      );
    }

    // La 0031 fait rendre l'id de la fusion à la fonction, pas un simple
    // compte — mais le code part en ligne avant la migration : tant qu'elle
    // n'est pas jouée, c'est encore l'ancienne version qui répond.
    const journalPret_ = await tableExiste("fusions_catalogue");
    let deplacees: number;
    if (journalPret_) {
      const [{ fn_fusionner_catalogue: fusionId }] = await sql<
        { fn_fusionner_catalogue: string }[]
      >`select fn_fusionner_catalogue(${survivant}::uuid, ${autres}::uuid[], ${profil_!.id}::uuid)`;
      const [f] = await sql<{ nb_anomalies: number }[]>`
        select nb_anomalies from fusions_catalogue where id = ${fusionId}::uuid`;
      deplacees = f?.nb_anomalies ?? 0;
    } else {
      const [{ fn_fusionner_catalogue: compte }] = await sql<
        { fn_fusionner_catalogue: number }[]
      >`select fn_fusionner_catalogue(${survivant}::uuid, ${autres}::uuid[])`;
      deplacees = compte;
    }

    redirect(
      `/administration/catalogue?q=${encodeURIComponent(recherche)}&fait=fusionne&n=${deplacees}&vers=${encodeURIComponent(cible!.libelle)}` as Route,
    );
  }

  async function annuler(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!suitLesDossiers(profil_?.role)) redirect("/administration/catalogue" as Route);
    const fusionId = String(donnees.get("fusion_id") ?? "");
    if (!/^[0-9a-f-]{36}$/.test(fusionId)) redirect("/administration/catalogue" as Route);

    const [{ fn_annuler_fusion_catalogue: restaurees }] = await sql<
      { fn_annuler_fusion_catalogue: number }[]
    >`select fn_annuler_fusion_catalogue(${fusionId}::uuid, ${profil_!.id}::uuid)`;

    redirect(`/administration/catalogue?fait=fusion-annulee&n=${restaurees}` as Route);
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Le catalogue" sous_titre="Fusionner les doublons" retour="/administration" />

      <div className="px-5 py-5 flex flex-col gap-5">
        {fait === "fusionne" && (
          <Confirmation
            quoi="fusionne"
            qui={`${n} anomalie${n === "1" ? "" : "s"} déplacée${n === "1" ? "" : "s"} vers « ${vers} »`}
          />
        )}
        {fait === "fusion-incomplete" && <Confirmation quoi="fusion-incomplete" />}
        {fait === "fusion-annulee" && (
          <Confirmation
            quoi="fusion-annulee"
            qui={`${n} anomalie${n === "1" ? "" : "s"} restaurée${n === "1" ? "" : "s"}`}
          />
        )}

        {!prete && (
          <p className="rounded-card bg-amber-soft px-4 py-3 text-[13px] text-amber text-pretty leading-snug">
            La fusion n’est pas encore disponible : la migration 0030 n’a pas été jouée.
            Voir « État de l’application ».
          </p>
        )}
        {prete && !journalPret && (
          <p className="rounded-card bg-amber-soft px-4 py-3 text-[13px] text-amber text-pretty leading-snug">
            La fusion fonctionne, mais sans numéro de vérification ni possibilité de revenir en
            arrière : la migration 0031 n’a pas été jouée. Voir « État de l’application ».
          </p>
        )}

        <p className="text-[13px] text-ink-faint text-pretty leading-snug">
          Cherchez un mot — « télérupteur », « liseuse » — pour voir tous les libellés qui s’en
          approchent. Cochez ceux qui disent la même chose, choisissez lequel garder, et
          fusionnez : les anomalies qui portaient les autres rejoignent celui-ci, avec sa
          rédaction. Chaque libellé porte son numéro — notez-le pour vérifier après coup que
          c’est bien celui-là qui a bougé.
        </p>

        <RechercheVive valeur={q} base="/administration/catalogue" placeholder="télérupteur, liseuse…" />

        {q.trim() && resultats.length === 0 && <Vide>Aucun libellé ne correspond.</Vide>}

        {resultats.length > 0 && (
          <form action={fusionner} className="flex flex-col gap-3">
            <input type="hidden" name="q" value={q} />
            <ul className="flex flex-col gap-2">
              {resultats.map((r) => (
                <li
                  key={r.id}
                  className={`carte px-4 py-3 flex items-start gap-3 ${!r.actif ? "opacity-50" : ""}`}
                >
                  {r.actif ? (
                    <input
                      type="checkbox"
                      name="autres"
                      value={r.id}
                      className="mt-1 w-5 h-5 shrink-0 accent-plum"
                      aria-label={`Fusionner « ${r.libelle} »`}
                    />
                  ) : (
                    <span className="mt-1 w-5 h-5 shrink-0" aria-hidden />
                  )}
                  <span className="flex flex-col gap-0.5 grow min-w-0">
                    <span className="text-[14.5px] leading-snug text-pretty">
                      {r.reference !== null && (
                        <span className="text-ink-faint tabular-nums">#{r.reference} · </span>
                      )}
                      {r.libelle}
                    </span>
                    <span className="text-[11.5px] text-ink-faint">
                      {r.metier ?? "sans métier"} · {r.nb} anomalie{r.nb === 1 ? "" : "s"}
                      {!r.actif && " · déjà fusionné ailleurs"}
                    </span>
                  </span>
                  {r.actif && (
                    <label className="shrink-0 flex items-center gap-1.5 text-[12px] text-ink-faint">
                      <input type="radio" name="survivant" value={r.id} className="accent-plum" />
                      garder
                    </label>
                  )}
                </li>
              ))}
            </ul>

            {actifs.length >= 2 && (
              <BoutonEnvoi
                disabled={!prete}
                className="carte px-5 py-3.5 bg-plum text-white font-display font-semibold text-[15px] disabled:opacity-40"
              >
                Fusionner ce qui est coché dans celui marqué « garder »
              </BoutonEnvoi>
            )}
          </form>
        )}

        {journalPret && fusions.length > 0 && (
          <section className="flex flex-col gap-2.5 pt-2 border-t border-line">
            <h2 className="etiquette">Fusions récentes</h2>
            <p className="text-[12px] text-ink-faint text-pretty leading-snug">
              Rien n’est supprimé : les anomalies listées sont reformulées — leur libellé et leur
              rattachement au catalogue changent, le reste (fil, photos, interventions) reste
              intact. Repérez-les par leur numéro d’origine, celui de votre tableau.
            </p>
            <ul className="flex flex-col gap-2">
              {fusions.map((f) => (
                <li key={f.id}>
                  <LigneDepliante
                    titre={
                      <>
                        <span className="tabular-nums text-ink-faint">
                          #{f.survivant_reference}
                        </span>{" "}
                        « {f.survivant_libelle} »
                      </>
                    }
                    detail={`${f.nb_anomalies} anomalie${f.nb_anomalies === 1 ? "" : "s"} déplacée${f.nb_anomalies === 1 ? "" : "s"} · ${f.fusionne_par ?? "quelqu’un"}, ${depuis(f.jours_depuis, f.fusionne_le)}`}
                    marque={
                      f.annulee_le ? (
                        <span className="text-[11px] text-green">Annulée</span>
                      ) : undefined
                    }
                  >
                    <p className="text-[12.5px] text-ink-faint text-pretty leading-snug">
                      Fusionné dans celui-ci :{" "}
                      {f.autres_libelles
                        .map((l, i) => `#${f.autres_references[i]} « ${l} »`)
                        .join(", ")}
                    </p>

                    <ul className="flex flex-col gap-1">
                      {parFusion(f.id).map((a) => (
                        <li key={a.anomalie_id}>
                          <Link
                            href={`/anomalie/${a.anomalie_id}`}
                            className="text-[12.5px] text-plum underline underline-offset-4"
                          >
                            {a.sharepoint_id !== null
                              ? `#${a.sharepoint_id}`
                              : "créée dans l’application"}
                            {a.lieu ? ` — ${a.lieu}` : ""}
                          </Link>
                        </li>
                      ))}
                    </ul>

                    {f.annulee_le ? (
                      <p className="text-[11.5px] text-green">
                        Annulée · {f.annulee_par ?? "quelqu’un"},{" "}
                        {depuis(f.jours_depuis_annulation ?? 0, f.annulee_le)}
                      </p>
                    ) : (
                      <form action={annuler} className="self-start">
                        <input type="hidden" name="fusion_id" value={f.id} />
                        <BoutonEnvoi className="text-[12.5px] text-red underline underline-offset-4">
                          Annuler cette fusion
                        </BoutonEnvoi>
                      </form>
                    )}
                  </LigneDepliante>
                </li>
              ))}
            </ul>
          </section>
        )}
      </div>
    </main>
  );
}
