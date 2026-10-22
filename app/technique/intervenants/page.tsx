import { redirect } from "next/navigation";
import type { Route } from "next";
import { exigerEncadrement } from "@/lib/acces";
import { chargeParIntervenant, intervenants } from "@/lib/tournee";
import { CarteIntervenant } from "@/app/composants/carte-intervenant";
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
  const charge = await chargeParIntervenant();

  // Ceux qui ont un profil sont ceux qu'on choisit le plus souvent — c'est
  // leur propre nom qu'ils viennent compléter. Les autres restent à un
  // appui, dans un dépliant ouvert par défaut : ils n'ont pas disparu, ils
  // ne sont simplement plus ce qu'on cherche en premier.
  const avecProfil = liste.filter((i) => i.compte);
  const sansProfil = liste.filter((i) => !i.compte);

  const ligne = (i: (typeof liste)[number]) => (
    <CarteIntervenant
      key={i.utilisateur_id ?? i.prestataire_id ?? i.nom}
      nom={i.nom}
      specialites={i.specialites}
      charge={charge.get(i.nom) ?? 0}
    />
  );

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Technique" sous_titre="Qui intervient ?" retour="/technique" />
      <div className="px-5 py-5 place-pour-le-calendrier flex flex-col gap-2">
        {/* « Ouvrir sa tournée » ne disait pas à quoi ça sert : choisir un
            prénom ici, c'est compléter les anomalies DE CE PASSAGE sous son
            nom — c'est de ça qu'on se sert pour savoir qui a fait quoi. */}
        <p className="text-[13.5px] text-ink-faint text-pretty">
          Choisissez qui intervient : les anomalies cochées ensuite seront complétées à son nom.
        </p>

        {avecProfil.map(ligne)}

        {sansProfil.length > 0 && (
          <Depliant
            titre="Les autres intervenants"
            aide="Sans profil pour ouvrir l’application à leur nom — mais ils interviennent pareil."
            indice={`${sansProfil.length}`}
            enCarte={false}
          >
            <div className="flex flex-col gap-2">{sansProfil.map(ligne)}</div>
          </Depliant>
        )}

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
