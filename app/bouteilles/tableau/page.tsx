import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import {
  Barres,
  Cadre,
  Chiffre,
  Colonnes,
  Jauge,
  Repartition,
  SERIES,
  Tableau,
} from "@/app/composants/graphiques";

export const dynamic = "force-dynamic";

type Mois = {
  mois: string;
  nb_dossiers: number;
  nb_bouteilles: number;
  montant_en_jeu: number | null;
  montant_facture: number | null;
  perte_seche: number | null;
};

type Lieu = { emplacement: string; nb_dossiers: number; montant: number | null };

type Parc = {
  libelle: string;
  couleur: string | null;
  en_reserve: number;
  en_chambre: number;
  chez_clients: number;
  parc_detenu: number;
  seuil_alerte: number;
};

const MOIS_COURT = ["jan", "fév", "mar", "avr", "mai", "juin",
                    "juil", "août", "sep", "oct", "nov", "déc"];

function evolution(courant: number, precedent: number, suffixe = ""): string | undefined {
  const delta = courant - precedent;
  if (delta === 0) return undefined;
  return `${delta > 0 ? "+" : "−"}${Math.abs(delta).toLocaleString("fr-FR")}${suffixe} vs mois dernier`;
}

export default async function TableauDeBord() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  // Douze mois pleins, trous compris : un mois sans dossier est une information,
  // pas une absence de colonne.
  const mois = await sql<Mois[]>`
    select m.mois::text,
           coalesce(b.nb_dossiers, 0)::int   as nb_dossiers,
           coalesce(b.nb_bouteilles, 0)::int as nb_bouteilles,
           b.montant_en_jeu, b.montant_facture, b.perte_seche
    from generate_series(
           date_trunc('month', current_date) - interval '11 months',
           date_trunc('month', current_date),
           interval '1 month') as m (mois)
    left join v_bouteilles_par_mois b on b.mois = m.mois::date
    order by m.mois`;

  const lieux = await sql<Lieu[]>`
    select emplacement, nb_dossiers::int, montant
    from v_bouteilles_par_emplacement_couts
    where dernier_dossier >= current_date - interval '12 months'
    order by montant desc nulls last, nb_dossiers desc
    limit 6`;

  const parc = await sql<Parc[]>`
    select libelle, couleur, en_reserve::int, en_chambre::int, chez_clients::int,
           parc_detenu::int, seuil_alerte::int
    from v_stock_bouteilles order by libelle`;

  const [sort] = await sql<
    { restituee: number; facturee: number; en_cours: number; perdue: number;
      recupere: number; perte: number; en_jeu: number }[]
  >`
    select
      count(*) filter (where statut = 'restitue')::int    as restituee,
      count(*) filter (where statut = 'facture')::int     as facturee,
      count(*) filter (where famille = 'ouvert')::int     as en_cours,
      count(*) filter (where statut = 'non_facture')::int as perdue,
      coalesce(sum(montant) filter (where statut = 'facture'), 0)     as recupere,
      coalesce(sum(montant) filter (where statut = 'non_facture'), 0) as perte,
      coalesce(sum(montant) filter (where famille = 'ouvert'), 0)     as en_jeu
    from v_dossiers_bouteille
    where constate_le >= current_date - interval '12 months'`;

  const ceMois = mois[mois.length - 1];
  const moisAvant = mois[mois.length - 2];

  const colonnes = mois.map((m, i) => ({
    libelle: MOIS_COURT[new Date(m.mois).getMonth()],
    valeur: m.nb_dossiers,
    courant: i === mois.length - 1,
  }));

  const maxParc = Math.max(
    ...parc.map((p) => Math.max(p.en_reserve, p.seuil_alerte * 2, 1)),
  );

  return (
    <main className="min-h-dvh flex flex-col max-w-md md:max-w-2xl mx-auto">
      <Entete titre="Tableau de bord" sous_titre="Bouteilles · 12 derniers mois" retour="/bouteilles" />

      <div className="px-5 py-4 flex flex-col gap-4">
        {/* Les quatre chiffres de tête */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
          <Chiffre
            valeur={ceMois.nb_dossiers}
            libelle="Dossiers ce mois"
            evolution={evolution(ceMois.nb_dossiers, moisAvant.nb_dossiers)}
            ton={SERIES.perdue}
          />
          <Chiffre
            valeur={euros(sort.en_jeu)}
            libelle="En jeu, non réglé"
            sens="neutre"
            ton={SERIES.en_cours}
          />
          <Chiffre
            valeur={euros(sort.recupere)}
            libelle="Récupéré, facturé"
            sens="neutre"
            ton={SERIES.restituee}
          />
          <Chiffre
            valeur={euros(sort.perte)}
            libelle="Perte sèche"
            sens="neutre"
            ton={SERIES.perdue}
          />
        </div>

        <Cadre
          titre="Dossiers par mois"
          detail="Un dossier compte dans le mois où la bouteille a été constatée manquante."
        >
          <Colonnes points={colonnes} />
          <Tableau
            entetes={["Mois", "Dossiers", "Bouteilles", "En jeu", "Facturé", "Perte sèche"]}
            lignes={mois.map((m) => [
              new Date(m.mois).toLocaleDateString("fr-FR", { month: "long", year: "numeric" }),
              m.nb_dossiers,
              m.nb_bouteilles,
              euros(m.montant_en_jeu),
              euros(m.montant_facture),
              euros(m.perte_seche),
            ])}
          />
        </Cadre>

        <Cadre
          titre="Ce que deviennent les dossiers"
          detail="Sur douze mois. Un dossier en cours n’est ni perdu ni récupéré : il attend."
        >
          <Repartition
            parts={[
              { libelle: "Restituée", valeur: sort.restituee, couleur: SERIES.restituee },
              { libelle: "Facturée au client", valeur: sort.facturee, couleur: SERIES.facturee },
              { libelle: "En cours", valeur: sort.en_cours, couleur: SERIES.en_cours },
              { libelle: "Perte sèche", valeur: sort.perdue, couleur: SERIES.perdue },
            ]}
          />
        </Cadre>

        {lieux.length > 0 && (
          <Cadre
            titre="Où partent les bouteilles"
            detail="Les emplacements qui coûtent le plus sur douze mois."
          >
            <Barres
              lignes={lieux.map((l) => ({
                libelle: l.emplacement,
                valeur: Number(l.montant ?? 0),
              }))}
              format={(n) => euros(n)}
            />
            <Tableau
              entetes={["Emplacement", "Dossiers", "Montant"]}
              lignes={lieux.map((l) => [l.emplacement, l.nb_dossiers, euros(l.montant)])}
            />
          </Cadre>
        )}

        <Cadre
          titre="La réserve"
          detail="Ce qui reste pour re-doter une chambre. Le repère gris marque le seuil d’alerte."
        >
          <div className="flex flex-col gap-3">
            {parc.map((p) => (
              <Jauge
                key={p.libelle}
                libelle={p.libelle}
                valeur={p.en_reserve}
                seuil={p.seuil_alerte}
                maximum={maxParc}
                couleur={p.couleur ?? "#453A6E"}
              />
            ))}
          </div>
          <Tableau
            entetes={["Type", "Réserve", "En chambre", "Chez clients", "Parc détenu"]}
            lignes={parc.map((p) => [
              p.libelle,
              p.en_reserve,
              p.en_chambre,
              p.chez_clients,
              p.parc_detenu,
            ])}
          />
          <p className="text-[11.5px] text-ink-faint text-pretty leading-snug">
            Le parc détenu est la réserve plus les chambres. Une bouteille chez un client n’y est
            pas comptée : elle n’est plus à l’hôtel, même si elle peut revenir.
          </p>
        </Cadre>

        <Link
          href={"/bouteilles/dossiers" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Voir les dossiers
        </Link>
      </div>
    </main>
  );
}
