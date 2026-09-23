import { sql } from "@/lib/db";
import { exigerEncadrement } from "@/lib/acces";
import { euros, eurosCourt } from "@/lib/domaine";
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

/**
 * Le tableau de bord technique.
 *
 * Il répond à quatre questions, dans cet ordre : combien de travail, où,
 * combien ça coûte, et **où en est le matériel**. C'est la dernière qui
 * manquait le plus — le stock se lisait article par article dans une liste,
 * sans jamais dire ce qui part, ni ce qui va manquer.
 *
 * Mêmes marques que le tableau de bord des bouteilles : tout est en SVG écrit
 * à la main, rien à charger, et chaque valeur reste lisible autrement que par
 * la couleur — un tableau replié sous chaque graphique.
 *
 * Il n'est pas pour l'intervenant : ni coût, ni facture, ni valeur du stock
 * (règle 10ter). `exigerEncadrement` le pose.
 */

type Mois = {
  mois: string;
  declarees: number;
  traitees: number;
  cout_materiel: number | null;
  cout_prestataire: number | null;
};

type Ligne = { libelle: string; valeur: number; detail?: string };

type Produit = {
  designation: string;
  stock: number;
  seuil_alerte: number;
  valeur_stock: number | null;
  sorties_12m: number;
  prix_inconnu: boolean;
  actif: boolean;
};

const MOIS_COURT = ["jan", "fév", "mar", "avr", "mai", "juin",
                    "juil", "août", "sep", "oct", "nov", "déc"];

function evolution(courant: number, precedent: number): string | undefined {
  const delta = courant - precedent;
  if (delta === 0) return undefined;
  return `${delta > 0 ? "+" : "−"}${Math.abs(delta).toLocaleString("fr-FR")} vs mois dernier`;
}

export default async function TableauTechnique() {
  await exigerEncadrement();

  // Douze mois pleins, trous compris : un mois sans anomalie est une
  // information, pas une absence de colonne.
  const mois = await sql<Mois[]>`
    with m as (
      select generate_series(
        date_trunc('month', current_date) - interval '11 months',
        date_trunc('month', current_date),
        interval '1 month')::date as mois
    )
    select m.mois::text,
           (select count(*) from anomalies a
             join emplacements e on e.id = a.emplacement_id
            where date_trunc('month', a.declare_le)::date = m.mois
              and not coalesce(e.essai, false))::int as declarees,
           (select count(*) from v_recap_interventions r
            where date_trunc('month', r.date_intervention)::date = m.mois)::int
             as traitees,
           (select sum(r.cout_materiel) from v_recap_interventions r
            where date_trunc('month', r.date_intervention)::date = m.mois)
             as cout_materiel,
           (select sum(r.cout_prestataire) from v_recap_interventions r
            where date_trunc('month', r.date_intervention)::date = m.mois)
             as cout_prestataire
      from m order by m.mois`;

  const [c] = await sql<
    {
      ouvertes: number;
      en_attente: number;
      cout_annee: number;
      incomplets: number;
      valeur_stock: number;
      sous_seuil: number;
      a_compter: number;
    }[]
  >`
    select
      (select count(*) from anomalies a
        join emplacements e on e.id = a.emplacement_id
       where a.statut in ('a_faire','en_cours','a_acheter')
         and not coalesce(e.essai, false))::int                       as ouvertes,
      (select coalesce(sum(nb_en_attente), 0) from v_tournees)::int    as en_attente,
      (select coalesce(sum(cout_total), 0) from v_recap_interventions
        where date_intervention >= date_trunc('year', current_date))   as cout_annee,
      (select count(*) from v_recap_interventions
        where cout_incomplet)::int                                     as incomplets,
      (select coalesce(sum(valeur_stock), 0) from v_stock_produits)    as valeur_stock,
      (select count(*) from v_stock_produits
        where sous_seuil and actif and stock >= 0)::int                as sous_seuil,
      (select count(*) from v_stock_produits where stock < 0)::int     as a_compter`;

  const etages = await sql<Ligne[]>`
    select et.nom as libelle, count(*)::int as valeur
      from anomalies a
      join emplacements e on e.id = a.emplacement_id
      join etages et      on et.id = e.etage_id
     where a.declare_le >= current_date - interval '12 months'
       and not coalesce(e.essai, false)
     group by et.nom, et.ordre
     order by et.ordre`;

  const lieux = await sql<Ligne[]>`
    select e.code as libelle, count(*)::int as valeur
      from anomalies a
      join emplacements e on e.id = a.emplacement_id
     where a.declare_le >= current_date - interval '12 months'
       and not coalesce(e.essai, false)
     group by e.code
     order by 2 desc, 1 limit 8`;

  const gens = await sql<Ligne[]>`
    select coalesce(intervenant, prestataire, 'sans nom') as libelle,
           count(*)::int as valeur
      from v_recap_interventions
     where date_intervention >= current_date - interval '12 months'
     group by 1 order by 2 desc, 1 limit 8`;

  // Le matériel. Ce qui SORT, pas ce qui est en rayon : une liste alphabétique
  // dit où trouver, elle ne dit pas ce qu'on consomme.
  const consommes = await sql<Ligne[]>`
    select p.designation as libelle, abs(sum(m.quantite))::int as valeur,
           to_char(abs(coalesce(sum(m.quantite * coalesce(m.prix_unitaire,
                                                          p.prix_unitaire)), 0)),
                   'FM999G999D00') as detail
      from v_mouvements_reels m
      join produits p on p.id = m.produit_id
     where m.type = 'sortie'
       and m.date_mouvement >= current_date - interval '12 months'
     group by p.designation
     order by 2 desc limit 8`;

  const produits = await sql<Produit[]>`
    select s.designation, s.stock, s.seuil_alerte, s.valeur_stock, s.prix_inconnu,
           s.actif,
           coalesce((select abs(sum(m.quantite)) from v_mouvements_reels m
                      where m.produit_id = s.id and m.type = 'sortie'
                        and m.date_mouvement >= current_date - interval '12 months'), 0)::int
             as sorties_12m
      from v_stock_produits s
     where s.actif and (s.sous_seuil or s.stock < 0)
     order by s.stock, s.designation
     limit 10`;

  const dernier = mois[mois.length - 1];
  const avant = mois[mois.length - 2];
  const maxStock = Math.max(
    1,
    ...produits.map((p) => Math.max(Number(p.stock), Number(p.seuil_alerte))),
  );

  const coutMois = (m: Mois) =>
    Number(m.cout_materiel ?? 0) + Number(m.cout_prestataire ?? 0);

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Tableau de bord"
        sous_titre="Technique — douze derniers mois"
        retour="/technique"
      />

      <div className="px-5 py-5 flex flex-col gap-4">
        <div className="grid grid-cols-4 gap-2">
          <Chiffre
            valeur={c.ouvertes}
            libelle="Ouvertes"
            evolution={evolution(dernier.declarees, avant.declarees)}
            ton={SERIES.en_cours}
          />
          <Chiffre
            valeur={c.en_attente}
            libelle="À valider"
            ton={SERIES.facturee}
            sens="neutre"
          />
          <Chiffre
            valeur={eurosCourt(c.cout_annee)}
            libelle="Coût de l’année"
            ton={SERIES.perdue}
            sens="neutre"
          />
          <Chiffre
            valeur={eurosCourt(c.valeur_stock)}
            libelle="Valeur du stock"
            ton={SERIES.restituee}
            sens="neutre"
          />
        </div>

        <Cadre
          titre="Ce qui arrive, ce qui est traité"
          detail="Déclarées et traitées, mois par mois. Les chambres d’essai 06 et 07 en sont écartées."
        >
          <Colonnes
            points={mois.map((m, i) => ({
              libelle: MOIS_COURT[new Date(m.mois).getMonth()],
              valeur: m.declarees,
              courant: i === mois.length - 1,
            }))}
          />
          <Tableau
            entetes={["Mois", "Déclarées", "Traitées"]}
            lignes={mois.map((m) => [
              `${MOIS_COURT[new Date(m.mois).getMonth()]} ${new Date(m.mois).getFullYear()}`,
              m.declarees,
              m.traitees,
            ])}
          />
        </Cadre>

        <Cadre
          titre="Ce que ça coûte"
          detail="Le matériel sorti PLUS ce que les intervenants facturent : c’est ça, le coût d’un passage."
        >
          <Colonnes
            points={mois.map((m, i) => ({
              libelle: MOIS_COURT[new Date(m.mois).getMonth()],
              valeur: Math.round(coutMois(m)),
              courant: i === mois.length - 1,
            }))}
            unite=" €"
          />
          <div className="flex flex-col gap-1.5 pt-1">
            <div className="flex items-baseline justify-between gap-3">
              <span className="text-[13px] text-ink-soft">Matériel, ce mois-ci</span>
              <span className="text-[14px] tabular-nums">
                {euros(dernier.cout_materiel ?? 0)}
              </span>
            </div>
            <div className="flex items-baseline justify-between gap-3">
              <span className="text-[13px] text-ink-soft">Facturé, ce mois-ci</span>
              <span className="text-[14px] tabular-nums">
                {euros(dernier.cout_prestataire ?? 0)}
              </span>
            </div>
          </div>
          {/* Un produit sans prix n'est pas compté pour zéro (règle 6). */}
          {c.incomplets > 0 && (
            <p className="text-[12.5px] text-amber text-pretty">
              {c.incomplets} intervention{c.incomplets > 1 ? "s ont" : " a"} utilisé
              du matériel sans prix connu : ces totaux sont des minimums.
            </p>
          )}
          <Tableau
            entetes={["Mois", "Matériel", "Facturé", "Total"]}
            lignes={mois.map((m) => [
              `${MOIS_COURT[new Date(m.mois).getMonth()]} ${new Date(m.mois).getFullYear()}`,
              euros(m.cout_materiel ?? 0),
              euros(m.cout_prestataire ?? 0),
              euros(coutMois(m)),
            ])}
          />
        </Cadre>

        <Cadre
          titre="Où ça tombe"
          detail="Par étage sur douze mois. C’est l’ordre du bâtiment, pas celui des chiffres."
        >
          <Repartition
            parts={etages.map((e, i) => ({
              libelle: e.libelle,
              valeur: e.valeur,
              couleur: [
                SERIES.facturee,
                SERIES.restituee,
                SERIES.en_cours,
                SERIES.perdue,
                "#6B5BA8",
                "#1F7A7A",
                "#A0548C",
              ][i % 7],
            }))}
          />
        </Cadre>

        <Cadre
          titre="Les lieux qui reviennent"
          detail="Huit premiers sur douze mois. Un lieu qui revient est un problème de fond, pas une série de pannes."
        >
          <Barres lignes={lieux} format={(n) => String(n)} />
        </Cadre>

        <Cadre titre="Qui intervient" detail="Interventions sur douze mois.">
          <Barres lignes={gens} format={(n) => String(n)} nomsLongs />
        </Cadre>

        {/* Le matériel. Le stock se lisait article par article, sans jamais
            dire ce qui part ni ce qui va manquer. */}
        <Cadre
          titre="Ce qui part de la réserve"
          detail="Les huit articles les plus sortis sur douze mois, et ce qu’ils ont coûté. Les essais en 06 et 07 n’y sont pas."
        >
          {consommes.length === 0 ? (
            <p className="text-[13px] text-ink-faint">
              Aucune sortie de matériel sur douze mois.
            </p>
          ) : (
            <>
              <Barres lignes={consommes} format={(n) => String(n)} nomsLongs />
              <Tableau
                entetes={["Article", "Sorties", "Valeur"]}
                lignes={consommes.map((l) => [
                  l.libelle,
                  l.valeur,
                  `${l.detail ?? "0,00"} €`,
                ])}
              />
            </>
          )}
        </Cadre>

        <Cadre
          titre="Ce qui va manquer"
          detail="Sous le seuil, ou déjà sous zéro. Le trait sur la piste est le seuil."
        >
          {produits.length === 0 ? (
            <p className="text-[13px] text-ink-faint">
              Rien sous le seuil : la réserve tient.
            </p>
          ) : (
            <div className="flex flex-col gap-2.5">
              {produits.map((p) => (
                <Jauge
                  key={p.designation}
                  libelle={p.designation}
                  valeur={Number(p.stock)}
                  seuil={Number(p.seuil_alerte)}
                  maximum={maxStock}
                  couleur={SERIES.facturee}
                />
              ))}
              {/* Un stock négatif n'est pas un stock vide : c'est un stock
                  faux, et le seul chemin est un inventaire (règle 4bis). */}
              {c.a_compter > 0 && (
                <p className="text-[12.5px] text-amber text-pretty">
                  {c.a_compter} article{c.a_compter > 1 ? "s sont" : " est"} sous
                  zéro : les sorties dépassent les entrées connues. Ça ne se
                  corrige pas par une écriture, ça se compte — un inventaire
                  depuis l’écran Stock.
                </p>
              )}
              <p className="text-[12.5px] text-ink-faint text-pretty">
                {c.sous_seuil} article{c.sous_seuil > 1 ? "s" : ""} sous le seuil
                en tout.
              </p>
            </div>
          )}
        </Cadre>
      </div>
    </main>
  );
}
