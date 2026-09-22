import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { viderLaFileEnFond } from "@/lib/envoi";
import { euros, jours } from "@/lib/domaine";
import { Confirmation, Entete } from "@/app/composants/ui";
import { peutValider } from "@/lib/domaine";
import { MarquerValide } from "@/app/composants/quitter-si-revenu";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { Frise } from "@/app/composants/suivi";
import { ChampCommentaire } from "@/app/composants/fil";
import { deposerAlerteBouteille } from "@/lib/alerte-bouteille";
import type { LigneBouteille } from "@/lib/courriel";

export const dynamic = "force-dynamic";

type Dossier = {
  id: string;
  reference: number;
  emplacement: string;
  nature: string;
  responsable: string;
  client_nom: string | null;
  constate_par: string | null;
  transmis_a: string | null;
  constate_le: string;
  transmis_le: string | null;
  client_contacte_le: string | null;
  resolu_le: string | null;
  notifie_le: string | null;
  statut: string;
  montant: number;
  quantite: number;
  lignes: LigneBouteille[];
  facturable_client: boolean;
  dossier_ouvert: boolean;
  etape_constate: boolean;
  etape_transmis: boolean;
  etape_client_contacte: boolean;
  etape_resolue: boolean;
  jours_ouvert: number;
  commentaire: string | null;
};

const LIBELLE: Record<string, string> = {
  signale: "Signalé",
  transmis: "Transmis",
  client_contacte: "Client contacté",
  restitue: "Restituée",
  facture: "Facturé",
  non_facture: "Perte sèche",
  clos: "Clos",
};

export default async function DetailDossier({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ fait?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { id } = await params;
  const { fait } = await searchParams;

  const [d] = await sql<Dossier[]>`
    select id, reference, emplacement, nature::text, responsable::text, client_nom,
           constate_par, transmis_a, constate_le, transmis_le, client_contacte_le,
           resolu_le, notifie_le, statut::text, montant, quantite, lignes,
           facturable_client, dossier_ouvert, etape_constate, etape_transmis,
           etape_client_contacte, etape_resolue, jours_ouvert, commentaire
    from v_dossiers_bouteille where id = ${id}`;
  if (!d) notFound();

  /**
   * Ce qu'il reste à faire, en une phrase.
   *
   * La frise dessine où l'on en est, mais elle ne dit pas quoi faire : on
   * voyait quatre pastilles et cinq boutons de cinq couleurs, sans savoir
   * lequel était le pas suivant. Un dossier n'a qu'un pas naturel à la fois ;
   * les autres issues restent possibles, plus bas et plus discrètes.
   */
  const prochaine = !d.dossier_ouvert
    ? `Dossier clos — ${LIBELLE[d.statut].toLowerCase()}.`
    : d.statut === "signale" && d.nature === "emport" && d.facturable_client
      ? "À transmettre à la réception, qui préviendra le client."
      : d.statut === "signale"
        ? "Reste à décider de son sort."
        : d.statut === "transmis"
          ? "La réception a le message. Dites-nous quand le client a été contacté."
          : "Le client est au courant. Reste à savoir si la bouteille revient.";

  // On reconnaît une bouteille à sa couleur en chambre, pas à son nom. La vue
  // du dossier ne porte pas la couleur ; on la prend au référentiel plutôt que
  // de faire une migration pour deux lignes.
  const couleurs = new Map(
    (
      await sql<{ code: string; couleur: string | null }[]>`
        select code, couleur from bouteille_types`
    ).map((b) => [b.code, b.couleur]),
  );

  // À qui l'alerte est destinée. Jamais au client : c'est la réception qui lui
  // écrit, avec le texte préparé ci-dessous.
  const [alerte] = await sql<{ destinataires: string[]; actif: boolean }[]>`
    select destinataires, actif from alertes_destinataires
    where evenement = 'incident_bouteille'`;

  async function avancer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");
    const etape = String(donnees.get("etape"));

    if (etape === "transmis") {
      await sql`
        update incidents_bouteille
           set statut = 'transmis', transmis_le = now(), transmis_a = ${profil_.id},
               notifie_le = coalesce(notifie_le, now())
         where id = ${id} and statut = 'signale'`;
      await deposerAlerteBouteille(id);
    } else if (etape === "contacte") {
      await sql`
        update incidents_bouteille
           set statut = 'client_contacte', client_contacte_le = now(),
               transmis_le = coalesce(transmis_le, now())
         where id = ${id} and statut in ('signale', 'transmis')`;
    } else if (["restitue", "facture", "non_facture"].includes(etape)) {
      await sql`
        update incidents_bouteille
           set statut = ${etape}::statut_incident_bouteille,
               resolu_le = now(), resolu_par = ${profil_.id}
         where id = ${id} and statut in ('signale', 'transmis', 'client_contacte')`;
    }
    revalidatePath(`/bouteilles/dossier/${id}`);
  }

  /**
   * Ce qui se règle sans rien déplacer : le montant, un mot de plus.
   *
   * Tout ce qui touche au parc — la date, la chambre, les types — est sur
   * l'écran de correction : corriger l'un d'eux déplace des bouteilles.
   */
  async function modifier(donnees: FormData) {
    "use server";
    const note = String(donnees.get("commentaire") ?? "").trim() || null;
    const mt = donnees.get("montant") ? Number(donnees.get("montant")) : null;
    await sql`
      update incidents_bouteille
         set commentaire = coalesce(${note}, commentaire),
             montant = ${mt}
       where id = ${id}`;
    revalidatePath(`/bouteilles/dossier/${id}`);
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      {/* Le numéro d'abord. C'est lui qu'on cite au téléphone, lui qu'on
          cherche dans la liste, lui qui figure dans le message à la réception
          — la chambre, elle, se répète sur dix dossiers. */}
      <Entete
        titre={`Dossier n° ${d.reference}`}
        sous_titre={`Chambre ${d.emplacement} · ${LIBELLE[d.statut]}`}
        retour="/bouteilles/dossiers"
      />

      <div className="px-5 py-4 flex flex-col gap-5">
        {/* Ce que l'alerte est devenue : partie, en attente, ou pas envoyée
            faute de destinataire. Le silence faisait croire à un envoi. */}
        <Confirmation quoi={fait} />
        {/* On arrive ici en sortant du formulaire : il ne doit plus se rouvrir
            par la flèche arrière, rempli comme avant l'envoi. */}
        {fait && <MarquerValide cle="bouteille" />}
        {/* Où en est le dossier, avant tout le reste : c'est la question
            qu'on se pose en l'ouvrant. La frise le dessine, et la phrase en
            dessous le dit en mots — une frise seule se lit vite mais ne
            s'explique pas. */}
        <section className="carte px-4 py-4 flex flex-col gap-3.5">
          <Frise
            etapes={[
              { libelle: "Constaté", faite: d.etape_constate },
              { libelle: "Transmis", faite: d.etape_transmis },
              { libelle: "Contacté", faite: d.etape_client_contacte },
              { libelle: "Réglé", faite: d.etape_resolue },
            ]}
          />
          <p className="text-[13px] text-ink-soft text-pretty leading-snug text-center">
            {prochaine}
          </p>
        </section>

        {/* Ce que le dossier dit : quelles bouteilles, combien, et chez qui. */}
        <section className="carte px-4 py-4 flex flex-col gap-3.5">
          <ul className="flex flex-col gap-2">
            {d.lignes.map((l) => (
              <li key={l.code} className="flex items-center gap-3">
                {/* La bouteille à sa couleur : bleue pour la filtrée, rouge
                    pour la gazeuse. On la reconnaît à ça en chambre. */}
                <span
                  aria-hidden
                  className="w-[20px] h-[30px] shrink-0 rounded-[6px] border-2"
                  style={{
                    borderColor: couleurs.get(l.code) ?? "#8C86A8",
                    background: (couleurs.get(l.code) ?? "#8C86A8") + "22",
                  }}
                />
                <span className="grow min-w-0 flex flex-col">
                  <span className="text-[15px] leading-snug">{l.libelle}</span>
                  <span className="text-[11.5px] text-ink-faint tabular-nums">
                    {l.quantite} × {euros(l.prix)}
                  </span>
                </span>
              </li>
            ))}
          </ul>

          <div className="flex items-baseline justify-between border-t border-line pt-3">
            <span className="text-[13px] text-ink-soft">
              {d.facturable_client ? "À retenir au client" : "À la charge de l’hôtel"}
            </span>
            <span className="font-display font-semibold text-[21px] tabular-nums">
              {euros(d.montant)}
            </span>
          </div>

          <dl className="grid grid-cols-[auto_1fr] gap-x-3 gap-y-1.5 text-[12.5px]">
            <dt className="text-ink-faint">Chambre</dt>
            <dd>{d.emplacement}</dd>

            <dt className="text-ink-faint">Client</dt>
            <dd>
              {d.client_nom ?? (
                <span className="text-ink-faint">pas de nom noté</span>
              )}
            </dd>

            <dt className="text-ink-faint">Nature</dt>
            <dd>
              {d.nature === "casse" ? "Bouteille cassée" : "Bouteille emportée"} ·{" "}
              {jours(d.jours_ouvert)}
            </dd>

            {/* « — » à la place d'un prénom ne se lit pas : on dit en toutes
                lettres que personne n'a été noté, parce que c'est une chose à
                corriger, pas un blanc typographique. */}
            <dt className="text-ink-faint">Constaté par</dt>
            <dd>
              {d.constate_par ?? <span className="text-ink-faint">personne de noté</span>} ·{" "}
              {new Date(d.constate_le).toLocaleDateString("fr-FR")}
            </dd>

            {d.transmis_le && (
              <>
                <dt className="text-ink-faint">Transmis à</dt>
                <dd>
                  {d.transmis_a ?? <span className="text-ink-faint">personne de noté</span>} ·{" "}
                  {new Date(d.transmis_le).toLocaleDateString("fr-FR")}
                </dd>
              </>
            )}
            {d.client_contacte_le && (
              <>
                <dt className="text-ink-faint">Client contacté</dt>
                <dd>{new Date(d.client_contacte_le).toLocaleDateString("fr-FR")}</dd>
              </>
            )}
            {d.resolu_le && (
              <>
                <dt className="text-ink-faint">Réglé</dt>
                <dd>
                  {LIBELLE[d.statut]} · {new Date(d.resolu_le).toLocaleDateString("fr-FR")}
                </dd>
              </>
            )}
          </dl>

          {d.commentaire && (
            <p className="rounded-card bg-surface-muted px-3.5 py-2.5 text-[13px] leading-snug text-pretty">
              {d.commentaire}
            </p>
          )}
        </section>

        {/* Le mail ne s'affiche pas : il est standardisé, il n'y a rien à y
            relire. C'est une action — « transmettre » — et le texte se
            construit tout seul au moment de l'envoi. */}
        {/* Ce qui reste à décider */}
        {d.dossier_ouvert && (
          <section className="flex flex-col gap-2">
            <h2 className="etiquette">Faire avancer le dossier</h2>
            {d.notifie_le && (
              <p className="text-[11.5px] text-green text-pretty leading-snug">
                La réception a reçu le message le{" "}
                {new Date(d.notifie_le).toLocaleDateString("fr-FR")}.
              </p>
            )}

            {/* UN pas à la fois, en grand. Cinq boutons de cinq couleurs côte
                à côte ne disaient pas lequel était le suivant — et « Facturé »,
                plein et vert, ressemblait au geste principal alors qu'il clôt
                le dossier. */}
            <form action={avancer} className="flex flex-col gap-2">
              {d.statut === "signale" && (
                <>
                  {d.facturable_client && d.nature === "emport" && (
                    <p className="text-[11.5px] text-ink-faint text-pretty leading-snug">
                      Le message part à{" "}
                      {alerte?.actif && alerte.destinataires.length > 0
                        ? alerte.destinataires.join(", ")
                        : "la réception"}
                      , rédigé et prêt à être transféré au client. Le texte est le même pour
                      tous les dossiers : il n’y a rien à relire ni à corriger.
                    </p>
                  )}
                  <BoutonEnvoi
                    name="etape"
                    value="transmis"
                    pendant="Envoi…"
                    className="h-[52px] px-3 rounded-[13px] bg-plum text-white font-display font-semibold text-[15px]"
                  >
                    Transmettre à la réception
                  </BoutonEnvoi>
                </>
              )}

              {d.statut === "transmis" && d.nature === "emport" && (
                <BoutonEnvoi
                  name="etape"
                  value="contacte"
                  pendant="…"
                  className="h-[52px] px-3 rounded-[13px] bg-blue text-white font-display font-semibold text-[15px]"
                >
                  Le client a été contacté
                </BoutonEnvoi>
              )}

              {/* Les issues closent le dossier : groupées, plus petites, et
                  dites comme telles. Elles restent toutes les trois — la
                  gouvernante n'a pas deux choix, elle en a trois. */}
              <div className="flex flex-col gap-2 border-t border-line pt-3 mt-1">
                <span className="etiquette">Clore le dossier</span>
                <div className="flex flex-wrap gap-2">
                  {d.nature === "emport" && (
                    <BoutonEnvoi
                      name="etape"
                      value="restitue"
                      pendant="…"
                      className="grow h-[44px] px-3 rounded-[12px] bg-green-soft text-green text-[13.5px] font-medium"
                    >
                      Restituée
                    </BoutonEnvoi>
                  )}
                  {d.facturable_client && (
                    <BoutonEnvoi
                      name="etape"
                      value="facture"
                      pendant="…"
                      className="grow h-[44px] px-3 rounded-[12px] bg-surface border border-line text-ink-soft text-[13.5px] font-medium"
                    >
                      Facturée au client
                    </BoutonEnvoi>
                  )}
                  <BoutonEnvoi
                    name="etape"
                    value="non_facture"
                    pendant="…"
                    className="grow h-[44px] px-3 rounded-[12px] bg-red-soft text-red text-[13.5px] font-medium"
                  >
                    Perte sèche
                  </BoutonEnvoi>
                </div>
              </div>
            </form>
          </section>
        )}

        {/* Ce qui se corrige à tout moment */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Corriger</h2>
          <form action={modifier} className="carte px-3.5 py-3 flex flex-col gap-2.5">
            <label className="flex flex-col gap-1">
              <span className="etiquette">Montant retenu</span>
              <input
                name="montant"
                type="number"
                step="0.01"
                min={0}
                inputMode="decimal"
                defaultValue={d.montant ?? ""}
                className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px] tabular-nums"
              />
              <span className="text-[11px] text-ink-faint text-pretty">
                Vide, c’est le barème qui s’applique. Un geste commercial se saisit ici.
              </span>
            </label>
            <ChampCommentaire libelle="Ajouter au commentaire" lignes={2} />
            <button className="h-[46px] rounded-[12px] bg-surface-muted border border-line text-[14.5px]">
              Enregistrer
            </button>
          </form>

          {/* Ce qui touche au PARC — la date, la chambre, les types — a son
              écran : corriger l'un d'eux déplace des bouteilles, ce n'est pas
              un champ qu'on modifie au passage. */}
          {peutValider(profil.role) && (
            <Link
              href={`/bouteilles/dossier/${id}/corriger` as Route}
              className="carte px-4 py-3.5 flex items-center gap-3 active:bg-surface-muted"
            >
              <span
                aria-hidden
                className="w-8 h-8 shrink-0 rounded-full bg-plum-soft grid place-items-center"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#453A6E"
                     strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M4 20h4L19 9a2.1 2.1 0 00-3-3L5 17z" />
                </svg>
              </span>
              <span className="grow flex flex-col">
                <span className="text-[15px]">Corriger la déclaration</span>
                <span className="text-[11.5px] text-ink-faint text-pretty leading-snug">
                  La date, la chambre, les bouteilles, les prénoms — ou supprimer le dossier
                </span>
              </span>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8C86A8"
                   strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
                <path d="M9 5l7 7-7 7" />
              </svg>
            </Link>
          )}
        </section>

        <Link
          href={"/bouteilles/dossiers" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Tous les dossiers
        </Link>
      </div>
    </main>
  );
}
