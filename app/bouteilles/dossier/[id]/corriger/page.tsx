import { notFound, redirect } from "next/navigation";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif, type Profil } from "@/lib/profil";
import { peutValider } from "@/lib/domaine";
import { jourISO } from "@/lib/domaine";
import { Confirmation, Entete } from "@/app/composants/ui";
import { Depliant } from "@/app/composants/depliant";
import { ChoixPrenom } from "@/app/composants/prenom";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { RelireAuRetour } from "@/app/composants/relire-au-retour";

export const dynamic = "force-dynamic";

/**
 * Corriger un dossier bouteille.
 *
 * Un dossier ne se corrigeait pas : déclaré, c'était dit pour toujours. Deux
 * besoins réels se heurtaient à ça.
 *
 * On reprend l'historique — des dossiers d'il y a des semaines, saisis
 * aujourd'hui. Sans date à corriger, ils arrivaient tous datés du jour, au
 * milieu des dossiers en cours, et le suivi ne voulait plus rien dire.
 *
 * Et on se trompe : de chambre, de type de bouteille, de prénom. La chambre
 * surtout — c'est le même défaut que pour les anomalies, où « lavabo bouché »
 * s'est retrouvé sur le palier du 4ème.
 *
 * Ce qui ne se corrige PAS ici : la nature du dossier. Passer d'un emport à une
 * casse ne déplace pas une bouteille, cela change son sort. Un dossier de la
 * mauvaise nature se supprime et se redéclare — c'est dit en clair plus bas.
 *
 * Les mouvements suivent : c'est la migration 0014 qui s'en charge, en base,
 * pas cet écran. Le parc est la somme des mouvements ; corriger l'en-tête sans
 * les déplacer le rendrait faux.
 */

type Dossier = {
  id: string;
  reference: number;
  emplacement_id: string;
  emplacement: string;
  nature: string;
  statut: string;
  client_nom: string | null;
  constate_par_id: string | null;
  transmis_a_id: string | null;
  constate_le: string;
  redoter: boolean;
  commentaire: string | null;
};

type Chambre = { id: string; code: string; etage: string };
type Ligne = { bouteille_type_id: string; quantite: number };
type Type = { id: string; code: string; libelle: string; couleur: string | null };

export default async function CorrigerDossier({
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

  // Corriger une donnée n'est pas un geste de terrain : les trois qui décident
  // de ce qui existe — Victoria, Sarah P, Miguel.
  if (!peutValider(profil.role)) redirect(`/bouteilles/dossier/${id}` as Route);

  const [d] = await sql<Dossier[]>`
    select i.id, i.reference, i.emplacement_id, e.code as emplacement,
           i.nature::text, i.statut::text, i.client_nom,
           i.constate_par as constate_par_id, i.transmis_a as transmis_a_id,
           i.constate_le, i.redoter, i.commentaire
      from incidents_bouteille i
      join emplacements e on e.id = i.emplacement_id
     where i.id = ${id}`;
  if (!d) notFound();

  const lignes = await sql<Ligne[]>`
    select bouteille_type_id, quantite from incident_lignes_bouteille
     where incident_id = ${id}`;

  const chambres = await sql<Chambre[]>`
    select e.id, e.code, et.nom as etage
      from emplacements e join etages et on et.id = e.etage_id
     where e.actif and e.dote_bouteilles
     order by et.ordre, e.ordre, e.code`;

  const types = await sql<Type[]>`
    select id, code, libelle, couleur from bouteille_types order by libelle`;

  const constatent = await sql<Profil[]>`
    select id, nom, role from utilisateurs
     where actif and role in ('menage', 'gouvernante') order by nom`;
  const transmettent = await sql<Profil[]>`
    select id, nom, role from utilisateurs
     where actif and role in ('reception', 'admin') order by nom`;

  const dossier = `/bouteilles/dossier/${id}` as Route;
  const ici = `/bouteilles/dossier/${id}/corriger` as Route;
  const parType = new Map(lignes.map((l) => [l.bouteille_type_id, l.quantite]));

  async function enregistrer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect(dossier);

    const emplacement = String(donnees.get("lieu") ?? "");
    const jour = String(donnees.get("jour") ?? "").trim();
    const client = String(donnees.get("client") ?? "").trim() || null;
    const vu_par = String(donnees.get("vu_par") ?? "") || null;
    const remonte_a = String(donnees.get("remonte_a") ?? "") || null;
    const mot = String(donnees.get("commentaire") ?? "").trim() || null;
    const redoter = donnees.get("redoter") === "oui";

    if (!emplacement) redirect(ici);

    // La date se saisit au jour ; on garde l'heure d'origine, qui n'a jamais
    // eu d'importance mais qui range deux dossiers du même jour dans l'ordre
    // où ils ont été déclarés.
    const [ancien] = await sql<{ constate_le: string }[]>`
      select constate_le from incidents_bouteille where id = ${id}`;
    const heure = new Date(ancien.constate_le);
    const quand = jour
      ? new Date(
          `${jour}T${String(heure.getHours()).padStart(2, "0")}:${String(
            heure.getMinutes(),
          ).padStart(2, "0")}:00`,
        ).toISOString()
      : ancien.constate_le;

    await sql`
      update incidents_bouteille
         set emplacement_id = ${emplacement},
             constate_le    = ${quand},
             client_nom     = ${client},
             constate_par   = ${vu_par},
             transmis_a     = ${remonte_a},
             transmis_le    = case when ${remonte_a}::uuid is null then null
                                   else coalesce(transmis_le, ${quand}) end,
             redoter        = ${redoter},
             commentaire    = ${mot}
       where id = ${id}`;

    // Les types concernés : une chambre peut perdre la filtrée ET la gazeuse.
    // Une ligne retirée emporte ses mouvements — c'est le déclencheur de la
    // migration 0014 qui s'en charge, jamais cet écran.
    // Une chambre est dotée d'UNE bouteille de chaque type : il n'y a pas de
    // quantité à corriger, seulement les types concernés.
    const voulus = new Map<string, number>();
    for (const t of donnees.getAll("type")) voulus.set(String(t), 1);
    if (voulus.size === 0) redirect(`${ici}?fait=sans-type` as Route);

    const [...ids] = voulus.keys();
    await sql`
      delete from incident_lignes_bouteille
       where incident_id = ${id} and bouteille_type_id <> all(${ids})`;
    for (const [type, q] of voulus) {
      await sql`
        insert into incident_lignes_bouteille (incident_id, bouteille_type_id, quantite)
        values (${id}, ${type}, ${q})
        on conflict (incident_id, bouteille_type_id)
        do update set quantite = excluded.quantite`;
    }

    redirect(`${dossier}?fait=modifie` as Route);
  }

  async function supprimer() {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect(dossier);
    // Les mouvements partent avec le dossier (`on delete cascade`) : un dossier
    // déclaré par erreur n'a jamais déplacé la moindre bouteille, le parc
    // redevient ce qu'il était.
    await sql`delete from incidents_bouteille where id = ${id}`;
    redirect("/bouteilles/dossiers?fait=dossier-supprime" as Route);
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={`Dossier n° ${d.reference}`}
        sous_titre={`Chambre ${d.emplacement} · corriger`}
        retour={dossier}
      />

      <div className="px-5 py-5 flex flex-col gap-5">
        {/* On corrige, on revient en arrière — le routeur ressortait le
            formulaire tel qu'il l'avait mis de côté, avec les anciennes
            valeurs, comme si la correction n'avait pas eu lieu. Corriger deux
            fois n'est pas grave (c'est une mise à jour, pas un doublon), mais
            lire de vieilles valeurs, si. */}
        <RelireAuRetour cle={`corriger-dossier:${id}`} />
        <Confirmation quoi={fait} />

        <form action={enregistrer} className="flex flex-col gap-5">
          {/* La date d'abord : c'est elle qu'on vient corriger en reprenant
              l'historique. */}
          <label className="flex flex-col gap-1">
            <span className="etiquette">Constaté le</span>
            <input
              name="jour"
              type="date"
              defaultValue={jourISO(d.constate_le)}
              max={jourISO(new Date().toISOString())}
              className="w-full h-[48px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
            />
            <span className="text-[11.5px] text-ink-faint text-pretty leading-snug">
              Les mouvements de bouteilles suivent cette date. Un dossier d’il y a trois
              semaines se range à sa place, pas au milieu des dossiers du jour.
            </span>
          </label>

          <label className="flex flex-col gap-1">
            <span className="etiquette">Chambre</span>
            <select
              name="lieu"
              defaultValue={d.emplacement_id}
              className="w-full h-[48px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
            >
              {chambres.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.code} — {c.etage}
                </option>
              ))}
            </select>
            <span className="text-[11.5px] text-ink-faint text-pretty leading-snug">
              La bouteille repart de cette chambre, et c’est elle qui est re-dotée. Se
              tromper de porte fausse son historique pour toujours.
            </span>
          </label>

          <fieldset className="flex flex-col gap-2">
            <legend className="etiquette mb-2">Bouteilles concernées</legend>
            <div className="flex flex-col gap-2">
              {types.map((t) => {
                const prise = parType.has(t.id);
                return (
                  <label
                    key={t.id}
                    className="carte px-3.5 py-3 flex items-center gap-3 cursor-pointer has-[:checked]:border-plum has-[:checked]:bg-plum-soft"
                  >
                    <input
                      type="checkbox"
                      name="type"
                      value={t.id}
                      defaultChecked={prise}
                      className="w-[22px] h-[22px] shrink-0 accent-plum"
                    />
                    {/* On reconnaît une bouteille à sa couleur en chambre, pas
                        à son nom. */}
                    <span
                      aria-hidden
                      className="w-[30px] h-[46px] shrink-0 rounded-[7px] border-2"
                      style={{
                        borderColor: t.couleur ?? "#8C86A8",
                        background: (t.couleur ?? "#8C86A8") + "33",
                      }}
                    />
                    <span className="grow text-[15px]">{t.libelle}</span>
                  </label>
                );
              })}
            </div>
          </fieldset>

          <label className="flex flex-col gap-1">
            <span className="etiquette">Nom du client</span>
            <input
              name="client"
              autoComplete="off"
              defaultValue={d.client_nom ?? ""}
              className="w-full h-[48px] px-3 rounded-[11px] border border-line bg-surface text-[16px]"
            />
          </label>

          <ChoixPrenom
            nom="vu_par"
            libelle="Qui l’a constaté"
            personnes={constatent}
            defaut={d.constate_par_id ?? undefined}
            facultatif
          />

          <ChoixPrenom
            nom="remonte_a"
            libelle="À qui c’est remonté"
            personnes={transmettent}
            defaut={d.transmis_a_id ?? undefined}
            facultatif
          />

          <label className="carte px-3.5 py-3 flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              name="redoter"
              value="oui"
              defaultChecked={d.redoter}
              className="w-[22px] h-[22px] shrink-0 accent-plum"
            />
            <span className="flex flex-col grow">
              <span className="text-[15px]">La chambre a été re-dotée</span>
              <span className="text-[11.5px] text-ink-faint text-pretty leading-snug">
                Une bouteille de la réserve a remplacé celle qui manque. Décocher retire ce
                déplacement : la chambre reste en manque.
              </span>
            </span>
          </label>

          <label className="flex flex-col gap-1">
            <span className="etiquette">Commentaire</span>
            <textarea
              name="commentaire"
              rows={3}
              defaultValue={d.commentaire ?? ""}
              className="w-full px-3 py-2.5 rounded-[11px] border border-line bg-surface text-[16px] leading-snug"
            />
          </label>

          <BoutonEnvoi
            pendant="Enregistrement…"
            className="h-[52px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15.5px]"
          >
            Enregistrer les corrections
          </BoutonEnvoi>
        </form>

        {/* Supprimer est un geste à part : il ne se trouve pas sous le doigt
            qui enregistre. */}
        <Depliant
          titre="Supprimer ce dossier"
          aide="Pour un dossier qui n’aurait jamais dû exister"
        >
          <p className="text-[13px] text-ink-soft text-pretty leading-snug">
            Le dossier n° {d.reference} disparaît, avec les mouvements de bouteilles qu’il a
            produits : l’emport, la re-dotation, et le retour s’il y en a eu un. Le parc
            redevient exactement ce qu’il était — c’est juste, puisqu’une bouteille déclarée
            par erreur n’a jamais bougé.
          </p>
          <p className="text-[13px] text-ink-soft text-pretty leading-snug">
            C’est aussi le geste à faire pour changer la <strong>nature</strong> d’un dossier :
            un emport n’est pas une casse, et l’un ne se transforme pas en l’autre. On
            supprime, et on redéclare.
          </p>
          <form action={supprimer}>
            <BoutonEnvoi
              pendant="Suppression…"
              className="w-full h-[48px] rounded-[12px] bg-red-soft text-red font-medium text-[14.5px]"
            >
              Supprimer le dossier n° {d.reference}
            </BoutonEnvoi>
          </form>
        </Depliant>
      </div>
    </main>
  );
}
