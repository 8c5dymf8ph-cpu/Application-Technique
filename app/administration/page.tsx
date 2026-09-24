import { redirect } from "next/navigation";
import { sql } from "@/lib/db";
import { capacites } from "@/lib/capacites";
import { version } from "@/lib/version";
import { migrationsEnAttente } from "@/lib/migrations";
import { profilActif } from "@/lib/profil";
import { peutValider } from "@/lib/domaine";
import { Entete, Tuile } from "@/app/composants/ui";
import { tableExiste } from "@/lib/schema";

export const dynamic = "force-dynamic";

/**
 * L'administration est un MENU, pas un écran.
 *
 * Tout y était posé bout à bout : l'état de la base, la file des courriels,
 * le test du dépôt, le journal des suppressions, les destinataires, puis
 * quatre tuiles tout en bas — « toutes les sous-menus en vrac ». On faisait
 * défiler pour trouver, et on ne savait pas ce qu'il y avait plus loin.
 *
 * Trois groupes, donc, chacun avec ce qu'il contient et un compte quand il y
 * a quelque chose à regarder : ce qu'on règle, ce qu'on regarde dans les
 * données, et l'état de l'application elle-même. Chaque section vit sur son
 * écran — un menu qui contient tout n'est plus un menu.
 */
export default async function Administration() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!peutValider(profil.role)) redirect("/");

  const [c] = await sql<{ courriels: number; controle: number; alertes: number }[]>`
    select
      (select count(*) from emails_envoyes where envoye_le is null)::int as courriels,
      (select count(*) from v_controle_donnees)::int                     as controle,
      (select count(*) from alertes_destinataires
        where actif and cardinality(destinataires) > 0)::int             as alertes`;

  // Le journal n'existe qu'après la 0021 : nommer une table absente casse
  // l'écran entier, pas seulement la requête.
  const journalPret = await tableExiste("anomalies_supprimees");
  const [j] = journalPret
    ? await sql<{ n: number }[]>`select count(*)::int as n from anomalies_supprimees`
    : [{ n: 0 }];

  // Ce que la base ne sait pas encore faire : c'est ce qui grise les boutons
  // ailleurs, et c'est la première chose à voir en arrivant ici.
  const etat = await capacites();
  const enAttente = etat.filter((x) => !x.prete).length;
  const fichiers = (await migrationsEnAttente()).length;
  const v = version();

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Administration" sous_titre={profil.nom} retour="/" />

      <div className="px-5 py-5 flex flex-col gap-6">
        {/* Ce qui ne marche pas encore se dit AVANT le menu : sinon on va
            chercher le défaut dans l'écran qui le subit. */}
        {(enAttente > 0 || fichiers > 0) && (
          <p className="rounded-card bg-amber-soft px-4 py-3 text-[13px] text-amber text-pretty leading-snug">
            {fichiers > 0
              ? `${fichiers} migration${fichiers > 1 ? "s" : ""} à jouer`
              : `${enAttente} capacité${enAttente > 1 ? "s" : ""} en attente`}{" "}
            : certains boutons restent grisés tant que la base n’est pas à jour.
            Voir « État de l’application ».
          </p>
        )}

        <section className="flex flex-col gap-3">
          <h2 className="etiquette">Réglages</h2>
          <Tuile
            href="/administration/equipe"
            titre="L’équipe"
            detail="Qui constate, à qui l’on transmet, qui intervient"
            ton="bg-plum-soft"
          />
          <Tuile
            href="/administration/bouteilles"
            titre="Les bouteilles"
            detail="Photos, prix, seuils"
            ton="bg-blue-soft"
          />
          <Tuile
            href="/administration/envois"
            titre="Alertes & courriels"
            detail="Qui reçoit quoi, et ce qui attend de partir"
            badge={c.courriels}
            ton="bg-amber-soft"
          />
        </section>

        <section className="flex flex-col gap-3">
          <h2 className="etiquette">Les données</h2>
          <Tuile
            href="/administration/controle"
            titre="Contrôle des données"
            detail="Ce que la reprise a laissé de douteux"
            badge={c.controle}
            ton="bg-amber-soft"
          />
          <Tuile
            href="/administration/supprimees"
            titre="Ce qui a été supprimé"
            detail="Les anomalies effacées, avec ce qu’elles emportaient"
            badge={j.n}
            ton="bg-surface"
          />
          <Tuile
            href="/administration/export"
            titre="Exporter"
            detail="Vos données dans un tableur, prêtes à trier"
            ton="bg-green-soft"
          />
        </section>

        <section className="flex flex-col gap-3">
          <h2 className="etiquette">L’application</h2>
          <Tuile
            href="/administration/base"
            titre="État de l’application"
            detail="Ce que la base sait faire, où vont les photos et les factures"
            badge={fichiers + enAttente}
            ton="bg-surface"
          />
        </section>

        {/* Quelle version est en ligne.
            « Les modifications ne sont pas là » et « le code est poussé »
            peuvent être vrais en même temps : entre les deux il y a un
            déploiement, qui peut ne pas avoir eu lieu, avoir échoué, ou être
            servi depuis le cache du téléphone. Le titre du commit se lit en
            français : on compare en une seconde, au lieu de se fier à sa
            mémoire des écrans. */}
        <section className="flex flex-col gap-1 pt-2 border-t border-line">
          <span className="etiquette">Version en ligne</span>
          {v.locale ? (
            <p className="text-[12px] text-ink-faint text-pretty leading-snug">
              Application lancée depuis un poste, pas depuis le déploiement.
            </p>
          ) : v.court ? (
            <p className="text-[12px] text-ink-faint text-pretty leading-snug">
              <span className="tabular-nums">{v.court}</span>
              {v.branche ? ` · ${v.branche}` : ""}
              {v.titre ? (
                <>
                  <br />
                  <span className="text-ink-soft">{v.titre}</span>
                </>
              ) : null}
            </p>
          ) : (
            <p className="text-[12px] text-ink-faint text-pretty leading-snug">
              Inconnue : Vercel n’expose pas les variables système pour ce projet.
              Settings → Environment Variables → « Automatically expose System
              Environment Variables ».
            </p>
          )}
        </section>
      </div>
    </main>
  );
}
