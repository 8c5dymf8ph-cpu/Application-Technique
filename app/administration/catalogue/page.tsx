import { redirect } from "next/navigation";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { suitLesDossiers } from "@/lib/domaine";
import { regleContient } from "@/lib/schema";
import { Entete, Vide, Confirmation } from "@/app/composants/ui";
import { RechercheVive } from "@/app/composants/recherche-vive";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";

export const dynamic = "force-dynamic";

type Entree = {
  id: string;
  libelle: string;
  metier: string | null;
  nb: number;
  actif: boolean;
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

  const resultats = q.trim()
    ? await sql<Entree[]>`
        select c.id, c.libelle, ti.nom as metier,
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

    const [{ deplacees }] = await sql<{ deplacees: number }[]>`
      select fn_fusionner_catalogue(${survivant}::uuid, ${autres}::uuid[]) as deplacees`;

    redirect(
      `/administration/catalogue?q=${encodeURIComponent(recherche)}&fait=fusionne&n=${deplacees}&vers=${encodeURIComponent(cible!.libelle)}` as Route,
    );
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

        {!prete && (
          <p className="rounded-card bg-amber-soft px-4 py-3 text-[13px] text-amber text-pretty leading-snug">
            La fusion n’est pas encore disponible : la migration 0030 n’a pas été jouée.
            Voir « État de l’application ».
          </p>
        )}

        <p className="text-[13px] text-ink-faint text-pretty leading-snug">
          Cherchez un mot — « télérupteur », « liseuse » — pour voir tous les libellés qui s’en
          approchent. Cochez ceux qui disent la même chose, choisissez lequel garder, et
          fusionnez : les anomalies qui portaient les autres rejoignent celui-ci, avec sa
          rédaction.
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
                    <span className="text-[14.5px] leading-snug text-pretty">{r.libelle}</span>
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
      </div>
    </main>
  );
}
