import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, peutValider } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";

export const dynamic = "force-dynamic";

type Lot = {
  id: string;
  reference: string;
  date_tournee: string;
  intervenant: string | null;
  cloturee_le: string | null;
  nb_interventions: number;
  nb_en_attente: number;
  nb_validees: number;
  nb_a_refaire: number;
  nb_en_cours: number;
  cout_total: number;
  cout_incomplet: boolean;
  prete_pour_recap: boolean;
  reprise: boolean;
  mail_recap_envoye_le: string | null;
};

function pluriel(n: number, mot: string): string {
  return `${n} ${mot}${n > 1 ? "s" : ""}`;
}

/** Ce que devient le récapitulatif d'un lot — y compris quand il n'en part pas. */
function recap(l: Lot): string {
  // Les lots repris de l'ancienne application ne déclenchent aucun envoi :
  // le travail a eu lieu, le mail n'a plus de destinataire utile.
  if (l.reprise) return "repris de l’ancienne application";
  if (l.mail_recap_envoye_le) return "récapitulatif envoyé";
  if (l.prete_pour_recap) return "récapitulatif à envoyer";
  return "en cours de revue";
}

function jour(d: string): string {
  return new Date(d).toLocaleDateString("fr-FR", {
    weekday: "long",
    day: "numeric",
    month: "long",
  });
}

/** Le détail d'un lot : ce qui est décidé, ce qui ne l'est pas encore. */
function Compte({ lot }: { lot: Lot }) {
  const parts = [
    lot.nb_validees > 0 && { n: lot.nb_validees, mot: "validée", ton: "text-green" },
    lot.nb_en_cours > 0 && { n: lot.nb_en_cours, mot: "en cours", ton: "text-blue" },
    lot.nb_a_refaire > 0 && { n: lot.nb_a_refaire, mot: "à refaire", ton: "text-red" },
  ].filter(Boolean) as { n: number; mot: string; ton: string }[];
  if (parts.length === 0) return null;
  return (
    <span className="flex flex-wrap gap-2 text-[11.5px]">
      {parts.map((p) => (
        <span key={p.mot} className={p.ton}>
          {p.n} {p.mot}
          {p.n > 1 && p.mot !== "en cours" ? "s" : ""}
        </span>
      ))}
    </span>
  );
}

export default async function AValider() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!peutValider(profil.role)) redirect("/");

  // Un lot est une tournée : le technicien rend son travail d'un coup, elle le
  // reprend à l'unité et peut s'y remettre en plusieurs fois.
  const lots = await sql<Lot[]>`
    select id, reference, date_tournee, intervenant, cloturee_le,
           nb_interventions::int, nb_en_attente::int, nb_validees::int,
           nb_a_refaire::int, nb_en_cours::int, cout_total, cout_incomplet,
           prete_pour_recap, reprise, mail_recap_envoye_le
    from v_tournees
    where nb_interventions > 0
    order by nb_en_attente > 0 desc, date_tournee desc
    limit 40`;

  const attente = lots.filter((l) => l.nb_en_attente > 0);
  const finies = lots.filter((l) => l.nb_en_attente === 0).slice(0, 12);

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="À valider"
        sous_titre={
          attente.length === 0
            ? "Rien en attente"
            : `${pluriel(
                attente.reduce((s, l) => s + l.nb_en_attente, 0),
                "anomalie",
              )} sur ${pluriel(attente.length, "tournée")}`
        }
        retour="/gouvernante"
      />

      <div className="px-5 py-5 flex flex-col gap-6">
        <section className="flex flex-col gap-2.5">
          <h2 className="etiquette">Lots rendus</h2>
          {attente.length === 0 ? (
            <Vide>Tout est passé en revue. Rien n’attend votre avis.</Vide>
          ) : (
            <ul className="flex flex-col gap-2">
              {attente.map((l) => (
                <li key={l.id}>
                  <Link
                    href={`/gouvernante/valider/${l.id}` as Route}
                    className="carte px-4 py-3.5 flex items-center gap-3 active:bg-surface-muted"
                  >
                    <span className="flex flex-col gap-1 grow min-w-0">
                      <span className="font-display font-semibold text-[16px]">
                        {l.intervenant ?? "Intervenant inconnu"}
                      </span>
                      <span className="text-[11.5px] text-ink-faint">
                        {jour(l.date_tournee)}
                        {l.cloturee_le === null && " · lot encore ouvert"}
                      </span>
                      <Compte lot={l} />
                    </span>
                    <span className="shrink-0 min-w-[34px] h-[34px] px-2 rounded-[10px] bg-amber-soft grid place-items-center font-display font-semibold text-[16px] text-amber tabular-nums">
                      {l.nb_en_attente}
                    </span>
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </section>

        {finies.length > 0 && (
          <section className="flex flex-col gap-2.5">
            <h2 className="etiquette">Passés en revue</h2>
            <ul className="flex flex-col gap-2">
              {finies.map((l) => (
                <li key={l.id}>
                  <Link
                    href={`/gouvernante/valider/${l.id}` as Route}
                    className="px-4 py-3 rounded-card bg-surface-muted border border-line flex items-center gap-3"
                  >
                    <span className="flex flex-col gap-0.5 grow min-w-0">
                      <span className="text-[14.5px]">{l.intervenant ?? "—"}</span>
                      <span className="text-[11.5px] text-ink-faint">
                        {jour(l.date_tournee)} · {pluriel(l.nb_interventions, "anomalie")}
                        {" · "}
                        {recap(l)}
                      </span>
                      <Compte lot={l} />
                    </span>
                    <span className="shrink-0 text-right">
                      <span className="block text-[13px] tabular-nums">
                        {euros(l.cout_total)}
                      </span>
                      {l.cout_incomplet && (
                        <span className="block text-[10.5px] text-red">coût incomplet</span>
                      )}
                    </span>
                  </Link>
                </li>
              ))}
            </ul>
          </section>
        )}
      </div>
    </main>
  );
}
