import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { peutValider } from "@/lib/domaine";
import { Entete, Tuile } from "@/app/composants/ui";
import { envoyerCourrielsEnAttente } from "@/lib/envoi";
import { depot } from "@/lib/stockage";

export const dynamic = "force-dynamic";

type Attente = { categorie: string; nombre: number; plus_ancien: string; en_erreur: number };
type Envoye = {
  id: string;
  categorie: string;
  sujet: string;
  destinataires: string[];
  envoye_le: string;
  succes: boolean;
  erreur: string | null;
};
type Alerte = { evenement: string; destinataires: string[]; actif: boolean };

const LIBELLE: Record<string, string> = {
  alerte_bouteille: "Bouteille manquante — réception",
  recap_technicien: "Lot rendu — ce que l’intervenant déclare",
  recap_intervention: "Récapitulatif complet — les deux avis",
  devis: "Demande de devis",
};

const EVENEMENT: Record<string, { titre: string; aide: string }> = {
  incident_bouteille: {
    titre: "Bouteille manquante",
    aide: "La réception, qui écrit au client. Jamais le client lui-même.",
  },
  seuil_stock: {
    titre: "Produit sous le seuil",
    aide: "Qui doit savoir qu’il faut recommander.",
  },
};

export default async function Administration({
  searchParams,
}: {
  searchParams: Promise<{ envoi?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!peutValider(profil.role)) redirect("/");
  const { envoi } = await searchParams;

  const attente = await sql<Attente[]>`
    select categorie, count(*)::int as nombre, min(cree_le) as plus_ancien,
           count(*) filter (where erreur is not null)::int as en_erreur
    from emails_envoyes where envoye_le is null
    group by categorie order by 2 desc`;

  const derniers = await sql<Envoye[]>`
    select id, categorie, sujet, destinataires, envoye_le, succes, erreur
    from emails_envoyes where envoye_le is not null
    order by envoye_le desc limit 8`;

  const alertes = await sql<Alerte[]>`
    select evenement, destinataires, actif from alertes_destinataires order by evenement`;

  const [controle] = await sql<{ n: number }[]>`
    select count(*)::int as n from v_controle_donnees`;

  const configure = Boolean(process.env.RESEND_API_KEY);
  const ouVontLesFichiers = depot();
  const total = attente.reduce((n, a) => n + a.nombre, 0);

  async function envoyerMaintenant() {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    const r = await envoyerCourrielsEnAttente();
    redirect(
      `/administration?envoi=${encodeURIComponent(
        r.ignores > 0
          ? "sans-cle"
          : `${r.envoyes} envoyé${r.envoyes > 1 ? "s" : ""}${r.echoues > 0 ? `, ${r.echoues} en échec` : ""}`,
      )}` as Route,
    );
  }

  async function enregistrerAlerte(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    const adresses = String(donnees.get("destinataires") ?? "")
      .split(/[,;\s]+/)
      .map((a) => a.trim())
      .filter((a) => a.includes("@"));
    // La contrainte l'exige : une alerte sans destinataire ne peut pas être
    // active. On désactive plutôt que d'échouer.
    await sql`
      update alertes_destinataires
         set destinataires = ${adresses},
             actif = ${adresses.length > 0 && donnees.get("actif") === "on"}
       where evenement = ${String(donnees.get("evenement"))}`;
    revalidatePath("/administration");
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Administration" sous_titre={profil.nom} retour="/" />

      <div className="px-5 py-5 flex flex-col gap-5">
        {envoi && (
          <p
            className={`rounded-card px-4 py-3 text-[13px] text-pretty ${
              envoi === "sans-cle" ? "bg-amber-soft text-amber" : "bg-green-soft text-green"
            }`}
          >
            {envoi === "sans-cle"
              ? "Aucune clé d’envoi n’est configurée : rien n’est parti, et la file est intacte."
              : `Passage terminé : ${envoi}.`}
          </p>
        )}

        {/* Les envois */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Courriels</h2>

          {!configure && (
            <p className="rounded-card bg-amber-soft px-4 py-3 text-[12.5px] text-amber text-pretty leading-snug">
              L’envoi n’est pas branché : la clé <code>RESEND_API_KEY</code> n’est pas
              renseignée. Les messages s’accumulent dans la file sans se perdre — ils partiront
              tous au premier passage une fois la clé posée dans Vercel.
            </p>
          )}

          {total === 0 ? (
            <p className="text-[13px] text-ink-faint text-pretty">
              Rien en attente. Les messages se rédigent tout seuls quand l’événement a lieu.
            </p>
          ) : (
            <ul className="carte divide-y divide-line">
              {attente.map((a) => (
                <li key={a.categorie} className="px-3.5 py-2.5 flex items-center gap-3">
                  <span className="grow min-w-0">
                    <span className="block text-[13.5px] leading-snug text-pretty">
                      {LIBELLE[a.categorie] ?? a.categorie}
                    </span>
                    <span className="block text-[11.5px] text-ink-faint">
                      le plus ancien du{" "}
                      {new Date(a.plus_ancien).toLocaleDateString("fr-FR")}
                      {a.en_erreur > 0 && ` · ${a.en_erreur} en échec`}
                    </span>
                  </span>
                  <span
                    className={`shrink-0 min-w-[30px] h-[30px] px-2 rounded-lg grid place-items-center text-[14px] tabular-nums ${
                      a.en_erreur > 0 ? "bg-red-soft text-red" : "bg-amber-soft text-amber"
                    }`}
                  >
                    {a.nombre}
                  </span>
                </li>
              ))}
            </ul>
          )}

          <form action={envoyerMaintenant}>
            <button
              disabled={total === 0}
              className="w-full h-[48px] rounded-[13px] bg-plum text-white font-display font-semibold text-[14.5px] disabled:opacity-40"
            >
              Envoyer maintenant
            </button>
          </form>
          <p className="text-[11px] text-ink-faint text-pretty leading-snug">
            La file se vide d’elle-même toutes les quinze minutes. Ce bouton sert à ne pas
            attendre. Un échec ne perd rien : le message repart au passage suivant.
          </p>

          {derniers.length > 0 && (
            <details className="carte px-3.5 py-3">
              <summary className="text-[12.5px] text-plum underline underline-offset-4 cursor-pointer list-none">
                Les derniers partis
              </summary>
              <ul className="mt-2 flex flex-col gap-2">
                {derniers.map((d) => (
                  <li key={d.id} className="flex flex-col gap-0.5">
                    <span className="flex items-baseline gap-2">
                      <span
                        aria-hidden
                        className={`w-2 h-2 rounded-full shrink-0 ${
                          d.succes ? "bg-green" : "bg-red"
                        }`}
                      />
                      <span className="grow min-w-0 text-[12.5px] leading-snug text-pretty">
                        {d.sujet}
                      </span>
                    </span>
                    <span className="text-[11px] text-ink-faint pl-4">
                      {new Date(d.envoye_le).toLocaleString("fr-FR")} ·{" "}
                      {d.destinataires.join(", ")}
                    </span>
                    {d.erreur && (
                      <span className="text-[11px] text-red pl-4 text-pretty">{d.erreur}</span>
                    )}
                  </li>
                ))}
              </ul>
            </details>
          )}
        </section>

        {/* Où vont les photos et les factures */}
        {ouVontLesFichiers === "disque" && (
          <p className="rounded-card bg-red-soft px-4 py-3 text-[12.5px] text-red text-pretty leading-snug">
            Les photos et les factures sont écrites sur le disque du serveur. En ligne, ce
            disque repart à zéro à chaque déploiement : elles seraient perdues. Renseignez{" "}
            <code>SUPABASE_URL</code> et <code>SUPABASE_SERVICE_ROLE_KEY</code> avant de mettre
            en service.
          </p>
        )}

        {/* Qui reçoit quoi */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Destinataires des alertes</h2>
          {alertes.map((a) => {
            const e = EVENEMENT[a.evenement] ?? { titre: a.evenement, aide: "" };
            return (
              <form
                key={a.evenement}
                action={enregistrerAlerte}
                className="carte px-3.5 py-3 flex flex-col gap-2"
              >
                <input type="hidden" name="evenement" value={a.evenement} />
                <span className="flex items-center gap-2">
                  <span className="grow min-w-0">
                    <span className="block text-[14.5px]">{e.titre}</span>
                    <span className="block text-[11.5px] text-ink-faint text-pretty">
                      {e.aide}
                    </span>
                  </span>
                  <label className="shrink-0 flex items-center gap-1.5 text-[12px] cursor-pointer">
                    <input
                      type="checkbox"
                      name="actif"
                      defaultChecked={a.actif}
                      className="w-4 h-4 accent-[#453A6E]"
                    />
                    actif
                  </label>
                </span>
                <input
                  name="destinataires"
                  autoComplete="off"
                  defaultValue={a.destinataires.join(", ")}
                  placeholder="adresse@hotel.com, autre@hotel.com"
                  className="w-full h-[46px] px-3 rounded-[11px] border border-line bg-surface text-[15px] placeholder:text-ink-faint"
                />
                <button className="h-[42px] rounded-[11px] bg-surface-muted border border-line text-[13.5px]">
                  Enregistrer
                </button>
              </form>
            );
          })}
        </section>

        {/* Le reste du paramétrage */}
        <div className="flex flex-col gap-3">
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
            href="/administration/controle"
            titre="Contrôle des données"
            detail="Ce que la reprise a laissé de douteux"
            badge={controle.n}
            ton="bg-amber-soft"
          />
        </div>

        <Link
          href={"/" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Retour à l’accueil
        </Link>
      </div>
    </main>
  );
}
