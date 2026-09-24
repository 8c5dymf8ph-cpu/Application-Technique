import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { profilActif } from "@/lib/profil";
import { peutValider } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { Depliant } from "@/app/composants/depliant";
import { envoyerCourrielsEnAttente } from "@/lib/envoi";
import { colonneExiste } from "@/lib/schema";

export const dynamic = "force-dynamic";

type Attente = {
  categorie: string;
  nombre: number;
  plus_ancien: string;
  en_erreur: number;
  derniere_erreur: string | null;
  dernier_essai: string | null;
  a_qui: string[] | null;
};
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
    aide:
      "Qui doit savoir qu’il faut recommander. Le message part quand un article " +
      "passe sous son seuil, un seul par fournisseur même si plusieurs tombent " +
      "en même temps.",
  },
  recap_technicien: {
    titre: "Lot rendu par l’intervenant",
    aide:
      "Envoyé à la fin d’un passage : ce que l’intervenant déclare avoir fait. " +
      "L’adresse notée sur SON profil, dans L’équipe, s’ajoute à celles-ci — " +
      "elle ne les remplace pas : vous restez en copie.",
  },
  recap_intervention: {
    titre: "Récapitulatif complet",
    aide:
      "Envoyé à la dernière validation : les deux avis, et ce qui n’a pas été validé. " +
      "Celui-ci ne concerne que l’hôtel : l’intervenant ne le reçoit pas.",
  },
};

/**
 * Les courriels et leurs destinataires, sur le même écran.
 *
 * Régler à qui part une alerte et regarder si elle est partie sont le même
 * geste, à deux minutes d'intervalle : une file en échec se corrige en
 * changeant une adresse, puis en réadressant (règle 7decies). Les séparer
 * obligeait à faire l'aller-retour.
 */
export default async function AlertesEtCourriels({
  searchParams,
}: {
  searchParams: Promise<{ envoi?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!peutValider(profil.role)) redirect("/");
  const { envoi } = await searchParams;

  // La dernière erreur, en clair. « 3 en échec » sans le motif n'aide
  // personne : c'est Resend qui dit pourquoi il refuse, et c'est ce texte-là
  // qui donne le geste à faire (vérifier un domaine, corriger une adresse).
  const dateEssai = await colonneExiste("emails_envoyes", "dernier_essai_le");
  const attente = dateEssai
    ? await sql<Attente[]>`
        select categorie, count(*)::int as nombre, min(cree_le) as plus_ancien,
               count(*) filter (where erreur is not null)::int as en_erreur,
               (array_agg(erreur order by cree_le desc)
                  filter (where erreur is not null))[1] as derniere_erreur,
               max(dernier_essai_le) as dernier_essai,
               (select array_agg(distinct a) from emails_envoyes e2,
                       unnest(e2.destinataires) a
                 where e2.envoye_le is null and e2.categorie = e.categorie) as a_qui
        from emails_envoyes e where envoye_le is null
        group by categorie order by 2 desc`
    : await sql<Attente[]>`
        select categorie, count(*)::int as nombre, min(cree_le) as plus_ancien,
               count(*) filter (where erreur is not null)::int as en_erreur,
               (array_agg(erreur order by cree_le desc)
                  filter (where erreur is not null))[1] as derniere_erreur,
               null::timestamptz as dernier_essai,
               (select array_agg(distinct a) from emails_envoyes e2,
                       unnest(e2.destinataires) a
                 where e2.envoye_le is null and e2.categorie = e.categorie) as a_qui
        from emails_envoyes e where envoye_le is null
        group by categorie order by 2 desc`;

  const derniers = await sql<Envoye[]>`
    select id, categorie, sujet, destinataires, envoye_le, succes, erreur
    from emails_envoyes where envoye_le is not null
    order by envoye_le desc limit 8`;

  const alertes = await sql<Alerte[]>`
    select evenement, destinataires, actif from alertes_destinataires order by evenement`;

  const configure = Boolean(process.env.RESEND_API_KEY);
  const total = attente.reduce((n, a) => n + a.nombre, 0);

  async function envoyerMaintenant() {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    const r = await envoyerCourrielsEnAttente();
    redirect(
      `/administration/envois?envoi=${encodeURIComponent(
        r.ignores > 0
          ? "sans-cle"
          : `${r.envoyes} envoyé${r.envoyes > 1 ? "s" : ""}${r.echoues > 0 ? `, ${r.echoues} en échec` : ""}`,
      )}` as Route,
    );
  }

  /**
   * Quel réglage commande quelle catégorie de message.
   *
   * Les deux noms diffèrent : `alertes_destinataires` range par ÉVÉNEMENT,
   * `emails_envoyes` par CATÉGORIE de message. Le lien n'était écrit nulle
   * part, et sans lui on ne peut pas réadresser une file.
   */
  const REGLAGE: Record<string, string> = {
    alerte_bouteille: "incident_bouteille",
    recap_technicien: "recap_technicien",
    recap_intervention: "recap_intervention",
    seuil_stock: "seuil_stock",
  };

  /**
   * Réadresser une file aux destinataires réglés aujourd'hui.
   *
   * Un message porte les destinataires qu'il avait AU MOMENT du dépôt : c'est
   * juste, un message est un fait, pas une intention. Mais quand on corrige
   * une adresse après coup, les messages déjà déposés gardent l'ancienne et
   * échouent indéfiniment — on croit que la correction n'a servi à rien.
   *
   * Pour le « lot rendu », l'adresse de l'intervenant a été ajoutée au dépôt
   * et ne figure dans aucun réglage : on la garde.
   */
  async function readresser(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    const categorie = String(donnees.get("categorie"));
    const evenement = REGLAGE[categorie];
    if (!evenement) return;

    const [regle] = await sql<{ destinataires: string[] }[]>`
      select destinataires from alertes_destinataires
      where evenement = ${evenement} and actif`;
    if (!regle || regle.destinataires.length === 0) {
      redirect("/administration/envois?envoi=sans-destinataire" as Route);
    }

    await sql`
      update emails_envoyes e
         set destinataires = (
               select array_agg(distinct a)
                 from unnest(
                   ${regle.destinataires}::text[]
                   || case when ${categorie} = 'recap_technicien'
                           -- L'adresse propre à l'intervenant, posée au dépôt :
                           -- elle n'est dans aucun réglage, on ne la perd pas.
                           then coalesce((
                             select array_agg(x) from unnest(e.destinataires) x
                              where x in (
                                select email from utilisateurs where email is not null
                                union all
                                select email from prestataires where email is not null)
                           ), '{}'::text[])
                           else '{}'::text[] end
                 ) as a),
             erreur = null
       where e.envoye_le is null and e.categorie = ${categorie}`;
    revalidatePath("/administration/envois");
    redirect("/administration/envois?envoi=readresse" as Route);
  }

  /**
   * Abandonner ce qui ne partira jamais.
   *
   * Une file qui garde éternellement des messages en échec finit par ne plus
   * rien vouloir dire. Abandonner les EFFACE : on ne marque jamais `envoye_le`
   * sur un message qui n'est pas parti, ce serait prétendre l'avoir envoyé.
   */
  async function abandonner(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    await sql`
      delete from emails_envoyes
       where envoye_le is null and categorie = ${String(donnees.get("categorie"))}`;
    revalidatePath("/administration/envois");
    redirect("/administration/envois?envoi=abandonne" as Route);
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
    revalidatePath("/administration/envois");
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Alertes & courriels"
        sous_titre={total === 0 ? "rien en attente" : `${total} en attente`}
        retour="/administration"
      />

      <div className="px-5 py-5 flex flex-col gap-5">
        {envoi && (
          <p
            className={`rounded-card px-4 py-3 text-[13px] text-pretty ${
              envoi === "sans-cle" || envoi === "sans-destinataire"
                ? "bg-amber-soft text-amber"
                : "bg-green-soft text-green"
            }`}
          >
            {envoi === "sans-cle"
              ? "Aucune clé d’envoi n’est configurée : rien n’est parti, et la file est intacte."
              : envoi === "readresse"
                ? "Les messages en attente sont réadressés aux destinataires réglés aujourd’hui. Appuyez sur « Envoyer maintenant » pour les faire partir."
                : envoi === "abandonne"
                  ? "Les messages en attente de cette catégorie ont été effacés. Rien n’a été envoyé, et rien ne le prétend."
                  : envoi === "sans-destinataire"
                    ? "Aucune adresse n’est réglée pour cette alerte : il n’y a personne à qui réadresser. Réglez-la plus bas, puis réessayez."
                    : `Passage terminé : ${envoi}.`}
          </p>
        )}
        {/* Les envois */}
        <Depliant
          titre="Courriels"
          enCarte={false}
          ouvert
          indice={
            attente.length === 0
              ? "rien en attente"
              : `${attente.reduce((n, a) => n + a.nombre, 0)} en attente`
          }
        >

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
                <li key={a.categorie} className="px-3.5 py-2.5 flex flex-col gap-1.5">
                  <div className="flex items-center gap-3">
                  <span className="grow min-w-0">
                    <span className="block text-[13.5px] leading-snug text-pretty">
                      {LIBELLE[a.categorie] ?? a.categorie}
                    </span>
                    <span className="block text-[11.5px] text-ink-faint">
                      le plus ancien du{" "}
                      {new Date(a.plus_ancien).toLocaleDateString("fr-FR")}
                      {a.en_erreur > 0 && ` · ${a.en_erreur} en échec`}
                    </span>
                    {/* À QUI ces messages sont adressés. Un message porte les
                        destinataires qu'il avait au dépôt : sans les voir, on
                        corrige le réglage et on ne comprend pas que rien ne
                        change. */}
                    {a.a_qui && a.a_qui.length > 0 && (
                      <span className="block text-[11.5px] text-ink-faint break-words">
                        à {a.a_qui.join(", ")}
                      </span>
                    )}
                    {a.derniere_erreur && (
                      <span className="mt-1 block rounded-[9px] bg-red-soft px-2.5 py-1.5 text-[11.5px] text-red text-pretty leading-snug break-words">
                        {a.dernier_essai && (
                          <span className="block opacity-80 mb-0.5">
                            Refus du dernier essai,{" "}
                            {new Date(a.dernier_essai).toLocaleString("fr-FR", {
                              day: "numeric",
                              month: "long",
                              hour: "2-digit",
                              minute: "2-digit",
                            })}{" "}
                            — il ne change pas tant qu’on ne réessaie pas.
                          </span>
                        )}
                        {a.derniere_erreur}
                        {/* Le refus le plus courant, et le seul geste qui le
                            lève : sans domaine vérifié, Resend n'accepte que
                            votre propre adresse. */}
                        {/(verify a domain|testing emails|domain is not verified)/i.test(
                          a.derniere_erreur,
                        ) && (
                          <span className="mt-1.5 block">
                            Tant qu’aucun domaine n’est vérifié, Resend n’accepte que votre
                            propre adresse. Vérifiez le domaine de l’hôtel dans Resend →
                            Domains, puis renseignez <strong>MAIL_EXPEDITEUR</strong> dans
                            Vercel avec une adresse de ce domaine. Les messages en attente
                            repartiront d’eux-mêmes.
                          </span>
                        )}
                      </span>
                    )}
                  </span>
                  <span
                    className={`shrink-0 min-w-[30px] h-[30px] px-2 rounded-lg grid place-items-center text-[14px] tabular-nums ${
                      a.en_erreur > 0 ? "bg-red-soft text-red" : "bg-amber-soft text-amber"
                    }`}
                  >
                    {a.nombre}
                  </span>
                  </div>

                  {/* Deux issues quand une file s'obstine : la réadresser aux
                      destinataires réglés aujourd'hui, ou l'abandonner. Sans
                      elles, un message mal adressé échoue indéfiniment et
                      l'écran ne veut plus rien dire. */}
                  {a.en_erreur > 0 && REGLAGE[a.categorie] && (
                    <div className="flex gap-2 pt-1">
                      <form action={readresser} className="grow">
                        <input type="hidden" name="categorie" value={a.categorie} />
                        <BoutonEnvoi
                          pendant="…"
                          className="w-full h-[38px] rounded-[10px] bg-plum text-white text-[12.5px]"
                        >
                          Réadresser aux destinataires actuels
                        </BoutonEnvoi>
                      </form>
                      <form action={abandonner} className="shrink-0">
                        <input type="hidden" name="categorie" value={a.categorie} />
                        <BoutonEnvoi
                          pendant="…"
                          className="h-[38px] px-3 rounded-[10px] bg-surface-muted border border-line text-ink-soft text-[12.5px]"
                        >
                          Abandonner
                        </BoutonEnvoi>
                      </form>
                    </div>
                  )}
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
        </Depliant>
        {/* Qui reçoit quoi */}
        <Depliant
          titre="Destinataires des alertes"
          aide="Qui reçoit quoi, et à quelle adresse"
          enCarte={false}
          indice={`${alertes.filter((a) => a.destinataires.length > 0).length}/${alertes.length} réglés`}
        >
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
        </Depliant>
      </div>
    </main>
  );
}
