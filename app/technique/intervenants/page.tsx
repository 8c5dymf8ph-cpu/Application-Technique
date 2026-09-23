import { redirect } from "next/navigation";
import type { Route } from "next";
import Link from "next/link";
import { sql } from "@/lib/db";
import { exigerEncadrement } from "@/lib/acces";
import { intervenants } from "@/lib/tournee";
import { aujourdhuiISO, suitLesDossiers } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { Depliant } from "@/app/composants/depliant";

export const dynamic = "force-dynamic";

export default async function ChoixIntervenant() {
  const profil = await exigerEncadrement();

  const liste = await intervenants();
  const reprend = suitLesDossiers(profil.role);

  /**
   * Ouvrir le passage d'un autre jour.
   *
   * Miguel et Sarah P rentrent d'anciennes interventions : ils choisissent qui
   * et quand, et retombent sur l'écran d'intervention habituel — mêmes étages,
   * même liste, même « C'est fait ». Rien de nouveau à apprendre ; c'est la
   * date qui change, et elle se voit en haut.
   *
   * Un passage existe dès qu'un intervenant est venu un jour donné : ouvrir la
   * journée SUFFIT à la créer, et deux ouvertures du même jour rendent le même
   * passage (index `passage_unique_par_intervenant_et_jour`).
   */
  async function ouvrirUnJour(donnees: FormData) {
    "use server";
    const p = await exigerEncadrement();
    if (!suitLesDossiers(p.role)) redirect("/technique/intervenants" as Route);
    const qui = String(donnees.get("qui") ?? "").trim();
    const jour = String(donnees.get("jour") ?? "").trim();
    if (!qui || !/^\d{4}-\d{2}-\d{2}$/.test(jour)) {
      redirect("/technique/intervenants" as Route);
    }
    redirect(
      `/technique/${encodeURIComponent(qui)}?jour=${jour}` as Route,
    );
  }

  // Pour chacun, ce qu'il verrait dans sa section : tout s'il est polyvalent,
  // son seul métier s'il a une spécialité.
  const charges = await sql<{ nom: string; a_traiter: number; en_cours: number }[]>`
    select i.nom,
           count(a.*) filter (where a.statut = 'a_faire')::int  as a_traiter,
           count(a.*) filter (where a.statut = 'en_cours')::int as en_cours
    from v_intervenants i
    left join lateral fn_anomalies_pour_intervenant(i.nom) a on true
    where i.actif group by i.nom`;
  const charge = new Map(charges.map((c) => [c.nom, c]));

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Technique" sous_titre="Qui intervient ?" retour="/technique" />
      <div className="px-5 py-5 flex flex-col gap-2">
        {/* Une seule liste, dépliée. Le pli séparait « l'équipe » des
            « intervenants extérieurs » et refermait les dix derniers : on
            croyait qu'il n'y avait que cinq noms. Et la distinction était
            fausse — Farid et Rachid ne sont pas plus de la maison que les
            autres, ils interviennent, comme tout le monde ici. */}
        <p className="text-[13.5px] text-ink-faint text-pretty">
          {liste.length} intervenants. Appuyez sur un nom pour ouvrir sa tournée.
        </p>

        {liste.map((i) => {
          const c = charge.get(i.nom);
          const cle = i.utilisateur_id ?? i.prestataire_id ?? "";
          return (
            <Link
              key={cle}
              href={`/technique/${encodeURIComponent(i.nom)}`}
              className="carte px-4 py-3.5 flex items-center gap-3.5 active:bg-surface-muted"
            >
              <span className="w-10 h-10 shrink-0 rounded-full bg-plum-soft grid place-items-center font-display font-semibold text-[14px] text-plum">
                {i.nom.slice(0, 2).toUpperCase()}
              </span>
              <span className="flex flex-col grow min-w-0 gap-0.5">
                <span className="font-display font-semibold text-[16.5px] truncate">
                  {i.nom}
                </span>
                <span className="text-[12.5px] text-ink-faint">
                  {i.specialites.length > 0
                    ? `${i.specialites.join(", ").toLowerCase()} uniquement`
                    : "toutes les anomalies"}
                </span>
              </span>
              {c && c.a_traiter + c.en_cours > 0 && (
                <span className="shrink-0 min-w-[30px] h-[30px] px-2 rounded-lg bg-amber-soft text-amber text-[14px] grid place-items-center tabular-nums">
                  {c.a_traiter + c.en_cours}
                </span>
              )}
            </Link>
          );
        })}

        {/* Saisir un passage d'un autre jour. Replié : c'est un geste de
            reprise, pas le geste du jour — mais il doit se voir comme un
            dépliant, sinon on ne le trouve pas. */}
        {reprend && (
          <Depliant
            titre="Saisir un passage passé"
            aide="Une intervention d’il y a trois semaines se saisit à SA date : c’est la date qui permet à la facture de se rapprocher."
            enCarte
          >
            <form action={ouvrirUnJour} className="flex flex-col gap-3 pt-1">
              <label className="flex flex-col gap-1.5">
                <span className="etiquette">Qui est venu</span>
                <select
                  name="qui"
                  required
                  defaultValue=""
                  className="h-[46px] rounded-[12px] border border-line px-3 bg-white text-[15px]"
                >
                  <option value="" disabled>
                    Choisir un intervenant
                  </option>
                  {liste.map((i) => (
                    <option key={i.nom} value={i.nom}>
                      {i.nom}
                    </option>
                  ))}
                </select>
              </label>
              <label className="flex flex-col gap-1.5">
                <span className="etiquette">Quel jour</span>
                <input
                  type="date"
                  name="jour"
                  required
                  max={aujourdhuiISO()}
                  defaultValue={aujourdhuiISO()}
                  className="h-[46px] rounded-[12px] border border-line px-3 bg-white text-[15px]"
                />
              </label>
              <BoutonEnvoi
                pendant="Ouverture…"
                className="h-[50px] rounded-[14px] bg-plum text-white font-display font-semibold text-[16px]"
              >
                Ouvrir ce passage
              </BoutonEnvoi>
            </form>
          </Depliant>
        )}
      </div>
    </main>
  );
}
