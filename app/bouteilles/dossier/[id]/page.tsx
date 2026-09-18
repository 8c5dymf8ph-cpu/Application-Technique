import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, jours, suitLesDossiers } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { Frise } from "@/app/composants/suivi";
import { ChampCommentaire } from "@/app/composants/fil";
import {
  corpsAlerteBouteille,
  objetAlerteBouteille,
  type LigneBouteille,
} from "@/lib/courriel";

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
}: {
  params: Promise<{ id: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  // Le suivi des dossiers, les commandes et les rapports sont le travail de
  // l'administration ; la gouvernante déclare, remplace et compte.
  if (!suitLesDossiers(profil.role)) redirect("/bouteilles");
  const { id } = await params;

  const [d] = await sql<Dossier[]>`
    select id, reference, emplacement, nature::text, responsable::text, client_nom,
           constate_par, transmis_a, constate_le, transmis_le, client_contacte_le,
           resolu_le, notifie_le, statut::text, montant, quantite, lignes,
           facturable_client, dossier_ouvert, etape_constate, etape_transmis,
           etape_client_contacte, etape_resolue, jours_ouvert, commentaire
    from v_dossiers_bouteille where id = ${id}`;
  if (!d) notFound();

  // À qui l'alerte est destinée. Jamais au client : c'est la réception qui lui
  // écrit, avec le texte préparé ci-dessous.
  const [alerte] = await sql<{ destinataires: string[]; actif: boolean }[]>`
    select destinataires, actif from alertes_destinataires
    where evenement = 'incident_bouteille'`;

  const objet = objetAlerteBouteille(d);
  const corps = corpsAlerteBouteille(d);

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

  async function modifier(donnees: FormData) {
    "use server";
    const nom = String(donnees.get("client") ?? "").trim() || null;
    const note = String(donnees.get("commentaire") ?? "").trim() || null;
    const mt = donnees.get("montant") ? Number(donnees.get("montant")) : null;
    await sql`
      update incidents_bouteille
         set client_nom = ${nom},
             commentaire = coalesce(${note}, commentaire),
             montant = ${mt}
       where id = ${id}`;
    revalidatePath(`/bouteilles/dossier/${id}`);
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={`Chambre ${d.emplacement}`}
        sous_titre={`Dossier n° ${d.reference} · ${LIBELLE[d.statut]}`}
        retour="/bouteilles/dossiers"
      />

      <div className="px-5 py-4 flex flex-col gap-5">
        <section className="carte px-4 py-4 flex flex-col gap-3">
          <div className="flex items-start gap-3">
            <div className="grow min-w-0">
              <p className="font-display font-semibold text-[16px]">
                {d.client_nom ?? <span className="text-ink-faint italic">Client non nommé</span>}
              </p>
              <p className="text-[12px] text-ink-faint">
                {d.nature === "casse" ? "Bouteille cassée" : "Bouteille emportée"} ·{" "}
                {jours(d.jours_ouvert)}
              </p>
            </div>
            <span className="font-display font-semibold text-[19px] tabular-nums shrink-0">
              {euros(d.montant)}
            </span>
          </div>

          <ul className="flex flex-col gap-1">
            {d.lignes.map((l) => (
              <li key={l.code} className="flex items-baseline gap-2 text-[13.5px]">
                <span className="grow">{l.libelle}</span>
                <span className="tabular-nums text-ink-faint">
                  {l.quantite} × {euros(l.prix)}
                </span>
              </li>
            ))}
          </ul>

          <Frise
            etapes={[
              { libelle: "Constaté", faite: d.etape_constate },
              { libelle: "Transmis", faite: d.etape_transmis },
              { libelle: "Contacté", faite: d.etape_client_contacte },
              { libelle: "Réglé", faite: d.etape_resolue },
            ]}
          />

          <dl className="grid grid-cols-[auto_1fr] gap-x-3 gap-y-1 text-[12px]">
            <dt className="text-ink-faint">Constaté par</dt>
            <dd>
              {d.constate_par ?? "—"} · {new Date(d.constate_le).toLocaleDateString("fr-FR")}
            </dd>
            {d.transmis_le && (
              <>
                <dt className="text-ink-faint">Transmis à</dt>
                <dd>
                  {d.transmis_a ?? "—"} ·{" "}
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

        {/* Le mail, prêt à partir — vers la réception, jamais vers le client.
            Un dossier déjà réglé le garde replié : c'est une trace, plus une action. */}
        {d.facturable_client && d.nature === "emport" && (
          <section className="flex flex-col gap-2">
            <h2 className="etiquette">
              {d.dossier_ouvert ? "Mail pour la réception" : "Le mail qui avait été préparé"}
            </h2>
            <p className="text-[12px] text-ink-soft text-pretty leading-snug">
              Ce texte part à la réception, qui l’envoie au client. L’application n’écrit jamais
              directement à un client.
              {alerte?.actif && alerte.destinataires.length > 0
                ? ` Destinataires enregistrés : ${alerte.destinataires.join(", ")}.`
                : " Aucun destinataire n’est encore enregistré : à renseigner dans le paramétrage."}
            </p>
            <details open={d.dossier_ouvert} className="carte px-4 py-3 flex flex-col gap-2">
              <summary className="text-[12.5px] text-plum underline underline-offset-4 cursor-pointer list-none mb-2">
                {d.dossier_ouvert ? "Masquer le texte" : "Relire le texte"}
              </summary>
              <p className="text-[11px] uppercase tracking-[0.08em] text-ink-faint">Objet</p>
              <p className="text-[13px] leading-snug text-pretty font-medium">{objet}</p>
              <p className="text-[11px] uppercase tracking-[0.08em] text-ink-faint mt-1">
                Message
              </p>
              <pre className="text-[12.5px] leading-[1.5] whitespace-pre-wrap font-sans text-ink">
                {corps}
              </pre>
            </details>
            {d.dossier_ouvert && (
            <a
              href={`mailto:${(alerte?.destinataires ?? []).join(",")}?subject=${encodeURIComponent(
                objet,
              )}&body=${encodeURIComponent(corps)}`}
              className="h-[48px] rounded-[13px] bg-plum-soft text-plum font-display font-semibold text-[14.5px] grid place-items-center"
            >
              Ouvrir dans le logiciel de messagerie
            </a>
            )}
          </section>
        )}

        {/* Ce qui reste à décider */}
        {d.dossier_ouvert && (
          <section className="flex flex-col gap-2">
            <h2 className="etiquette">Faire avancer le dossier</h2>
            <form action={avancer} className="flex flex-wrap gap-2">
              {d.statut === "signale" && (
                <button
                  name="etape"
                  value="transmis"
                  className="grow h-[46px] px-3 rounded-[12px] bg-plum-soft text-plum text-[13.5px] font-medium"
                >
                  Transmis à la réception
                </button>
              )}
              {d.statut !== "client_contacte" && d.nature === "emport" && (
                <button
                  name="etape"
                  value="contacte"
                  className="grow h-[46px] px-3 rounded-[12px] bg-blue-soft text-blue text-[13.5px] font-medium"
                >
                  Client contacté
                </button>
              )}
              {d.nature === "emport" && (
                <button
                  name="etape"
                  value="restitue"
                  className="grow h-[46px] px-3 rounded-[12px] bg-green-soft text-green text-[13.5px] font-medium"
                >
                  Restituée
                </button>
              )}
              {d.facturable_client && (
                <button
                  name="etape"
                  value="facture"
                  className="grow h-[46px] px-3 rounded-[12px] bg-green text-white text-[13.5px] font-medium"
                >
                  Facturé
                </button>
              )}
              <button
                name="etape"
                value="non_facture"
                className="grow h-[46px] px-3 rounded-[12px] bg-red-soft text-red text-[13.5px] font-medium"
              >
                Perte sèche
              </button>
            </form>
          </section>
        )}

        {/* Ce qui se corrige à tout moment */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Corriger</h2>
          <form action={modifier} className="carte px-3.5 py-3 flex flex-col gap-2.5">
            <label className="flex flex-col gap-1">
              <span className="etiquette">Nom du client</span>
              <input
                name="client"
                autoComplete="off"
                defaultValue={d.client_nom ?? ""}
                className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
              />
            </label>
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
