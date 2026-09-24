import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { capacites } from "@/lib/capacites";
import { appliquerLesMigrations, migrationsEnAttente } from "@/lib/migrations";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { profilActif } from "@/lib/profil";
import { peutValider } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { Depliant } from "@/app/composants/depliant";
import { depot, verifierDepot } from "@/lib/stockage";

export const dynamic = "force-dynamic";

/**
 * L'état de l'application : ce que la base sait faire, et où vont les fichiers.
 *
 * Les deux répondent à la même question — « pourquoi ce bouton ne fait-il
 * rien ? » — et elles vivaient au milieu des réglages, où l'on ne va pas les
 * chercher. Elles ont leur écran ; l'administration redevient un menu.
 */
export default async function EtatDeLApplication({
  searchParams,
}: {
  searchParams: Promise<{ essai?: string; maj?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!peutValider(profil.role)) redirect("/");
  const { essai, maj } = await searchParams;

  const etat = await capacites();
  const enAttente = etat.filter((c) => !c.prete);
  const fichiersEnAttente = await migrationsEnAttente();
  const ouVontLesFichiers = depot();

  /**
   * Le test du dépôt, à la demande.
   *
   * Il écrit un fichier, le relit et l'efface : c'est la seule réponse sûre à
   * « pourquoi ma photo ne s'affiche pas ». On ne le lance pas à chaque
   * ouverture de l'écran — un aller-retour vers Supabase à chaque affichage
   * serait payé pour rien.
   */
  const verdict = essai === "1" ? await verifierDepot() : null;

  /**
   * Jouer les migrations manquantes, depuis l'écran.
   *
   * L'application a déjà la chaîne de connexion. Lui demander d'aller sur
   * GitHub, de trouver l'onglet Actions et de lire un journal pour savoir si
   * une colonne existe, c'est trois allers-retours pendant lesquels des
   * boutons restent grisés sans explication.
   *
   * Réservé à l'administrateur : c'est une écriture de schéma, pas un réglage.
   */
  async function mettreLaBaseAJour() {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || profil_.role !== "admin") redirect("/administration/base" as Route);
    const faites = await appliquerLesMigrations();
    const bilan =
      faites.length === 0
        ? "rien-a-faire"
        : faites.some((f) => f.etat === "échec")
          ? `echec:${faites.find((f) => f.etat === "échec")!.fichier}:${
              faites.find((f) => f.etat === "échec")!.erreur?.slice(0, 180) ?? ""
            }`
          : `ok:${faites.filter((f) => f.etat === "appliquée").length}`;
    redirect(`/administration/base?maj=${encodeURIComponent(bilan)}` as Route);
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="État de l’application" sous_titre={profil.nom} retour="/administration" />

      <div className="px-5 py-5 flex flex-col gap-5">
        {/* Ce que la base sait faire. Sur son propre écran, la section est ce
            qu'on vient voir : elle s'ouvre. Repliée, elle demandait un appui
            de plus pour rien. */}
        <Depliant
          titre="État de la base"
          enCarte={false}
          ouvert
          indice={
            <span
              className={
                fichiersEnAttente.length === 0 && enAttente.length === 0
                  ? "text-green"
                  : "text-amber"
              }
            >
              {fichiersEnAttente.length > 0
                ? `${fichiersEnAttente.length} fichier${fichiersEnAttente.length > 1 ? "s" : ""} à jouer`
                : enAttente.length === 0
                  ? "à jour"
                  : `${enAttente.length} mise${enAttente.length > 1 ? "s" : ""} à jour en attente`}
            </span>
          }
        >

          {/* Le verdict de la dernière tentative. */}
          {maj && (
            <p
              className={`rounded-card px-4 py-3 text-[13px] text-pretty leading-snug ${
                maj.startsWith("echec:")
                  ? "bg-red-soft text-red"
                  : "bg-green-soft text-green"
              }`}
              role="status"
            >
              {maj === "rien-a-faire" ? (
                "La base était déjà à jour : aucun fichier à jouer."
              ) : maj.startsWith("ok:") ? (
                <>
                  <strong>{maj.slice(3)} mise(s) à jour appliquée(s).</strong> Les lignes
                  ci-dessous disent ce que la base sait faire maintenant.
                </>
              ) : (
                <>
                  <strong>Échec sur {maj.split(":")[1]}.</strong> Rien n’a été laissé à
                  moitié : ce fichier a été annulé en entier, et les suivants n’ont pas été
                  tentés. {maj.split(":").slice(2).join(":")}
                </>
              )}
            </p>
          )}

          {/* Mettre à jour depuis ici : l'application a déjà la connexion, et
              passer par GitHub laissait des boutons grisés sans explication.
              Le bloc suit les FICHIERS en attente, pas la liste des capacités :
              un fichier peut ne rien changer à ce qu'on sait faire et devoir
              être joué quand même. */}
          {(fichiersEnAttente.length > 0 || enAttente.length > 0) && (
            <div className="rounded-card bg-amber-soft px-4 py-3.5 flex flex-col gap-2.5">
              <p className="text-[13px] text-amber text-pretty leading-snug">
                {fichiersEnAttente.length > 0 ? (
                  <>
                    <strong>
                      {fichiersEnAttente.length} fichier
                      {fichiersEnAttente.length > 1 ? "s" : ""} à jouer.
                    </strong>{" "}
                    Rien n’est effacé, chaque fichier passe entièrement ou pas du tout, et ce
                    qui est déjà appliqué n’est pas rejoué.
                  </>
                ) : (
                  <>
                    Les fichiers de mise à jour ne sont pas dans ce déploiement. Passez par
                    GitHub : onglet <strong>Actions</strong> →{" "}
                    <strong>Mettre à jour la base</strong> → <em>Run workflow</em>.
                  </>
                )}
              </p>
              {fichiersEnAttente.length > 0 && profil.role === "admin" && (
                <form action={mettreLaBaseAJour}>
                  <BoutonEnvoi
                    pendant="Mise à jour…"
                    className="h-[46px] w-full rounded-[12px] bg-amber text-white font-display font-semibold text-[14.5px]"
                  >
                    Mettre la base à jour
                  </BoutonEnvoi>
                </form>
              )}
              {fichiersEnAttente.length > 0 && profil.role !== "admin" && (
                <p className="text-[12px] text-amber">
                  Miguel peut la lancer depuis cet écran.
                </p>
              )}
            </div>
          )}

          <ul className="carte divide-y divide-line">
            {etat.map((c) => (
              <li key={c.titre} className="px-3.5 py-2.5 flex items-start gap-3">
                <span
                  aria-hidden
                  className={`mt-0.5 w-[18px] h-[18px] shrink-0 rounded-full grid place-items-center text-[11px] ${
                    c.prete ? "bg-green-soft text-green" : "bg-amber-soft text-amber"
                  }`}
                >
                  {c.prete ? "✓" : "!"}
                </span>
                <span className="grow min-w-0">
                  <span className="block text-[14px] leading-snug">{c.titre}</span>
                  {!c.prete && (
                    <span className="block text-[11.5px] text-ink-faint text-pretty leading-snug mt-0.5">
                      {c.sans}
                    </span>
                  )}
                </span>
              </li>
            ))}
          </ul>
        </Depliant>
        {/* Où vont les photos et les factures */}
        {!verdict && (
          <Link
            href={"/administration/base?essai=1" as Route}
            className="carte px-4 py-3 text-[14.5px] text-center active:bg-surface-muted"
          >
            Vérifier le dépôt des fichiers
          </Link>
        )}

        {verdict && (
          <div
            className={`rounded-card px-4 py-3 flex flex-col gap-1 text-[12.5px] text-pretty leading-snug ${
              verdict.identique && verdict.depot === "supabase"
                ? "bg-green-soft text-green"
                : "bg-red-soft text-red"
            }`}
          >
            <span className="font-display font-semibold text-[13.5px]">
              Dépôt des fichiers — {verdict.depot === "supabase" ? `Supabase, seau « ${verdict.seau} »` : "disque du serveur"}
            </span>
            <span>
              écrit&nbsp;: {verdict.ecrit ? "oui" : "non"} · relu&nbsp;:{" "}
              {verdict.relu ? "oui" : "non"} · identique&nbsp;:{" "}
              {verdict.identique ? "oui" : "non"}
            </span>
            <span>{verdict.detail}</span>
          </div>
        )}

        {ouVontLesFichiers === "disque" && (
          <p className="rounded-card bg-red-soft px-4 py-3 text-[12.5px] text-red text-pretty leading-snug">
            Les photos et les factures sont écrites sur le disque du serveur. En ligne, ce
            disque repart à zéro à chaque déploiement : elles seraient perdues. Renseignez{" "}
            <code>SUPABASE_URL</code> et <code>SUPABASE_SECRET_KEY</code> avant de mettre
            en service.
          </p>
        )}

      </div>
    </main>
  );
}
