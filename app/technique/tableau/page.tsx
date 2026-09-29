import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { exigerEncadrement } from "@/lib/acces";
import { euros, eurosCourt, jourISO } from "@/lib/domaine";
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
import { FormulaireEnPlace } from "@/app/composants/formulaire-en-place";

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

type VariationPrix = {
  designation: string;
  premier_prix: number;
  dernier_prix: number;
  nb_achats: number;
};

function valideDate(v: string | undefined, repli: string): string {
  return v && /^\d{4}-\d{2}-\d{2}$/.test(v) ? v : repli;
}

const MOIS_COURT = ["jan", "fév", "mar", "avr", "mai", "juin",
                    "juil", "août", "sep", "oct", "nov", "déc"];

function evolution(courant: number, precedent: number): string | undefined {
  const delta = courant - precedent;
  if (delta === 0) return undefined;
  return `${delta > 0 ? "+" : "−"}${Math.abs(delta).toLocaleString("fr-FR")} vs mois dernier`;
}

export default async function TableauTechnique({
  searchParams,
}: {
  searchParams: Promise<{ debut?: string; fin?: string }>;
}) {
  await exigerEncadrement();

  // Ce qui part de la réserve et la variation de prix se regardent sur une
  // période choisie — comparer un prix demande souvent une fenêtre plus
  // fine ou plus large que douze mois. Le reste du tableau (déclarées,
  // traitées, où ça tombe, qui intervient) garde son cadre fixe de douze
  // mois glissants : ce sont des tendances mensuelles, une période libre n'y
  // aurait pas de sens.
  const aujourdhui = jourISO(new Date());
  const defautDebut = jourISO(
    new Date(new Date().getFullYear(), new Date().getMonth() - 11, new Date().getDate()),
  );
  const p = await searchParams;
  const debut = valideDate(p.debut, defautDebut);
  const finBrute = valideDate(p.fin, aujourdhui);
  const fin = finBrute < debut ? debut : finBrute;

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
       and m.date_mouvement >= ${debut}::date
       and m.date_mouvement < (${fin}::date + 1)
     group by p.designation
     order by 2 desc limit 8`;

  /**
   * La variation du prix payé, sur la période choisie : le premier et le
   * dernier prix d'achat de chaque article qui en a eu au moins deux, comme
   * `v_achats_produit` le fait déjà pour un seul produit sur sa fiche — ici
   * regroupé pour voir d'un coup lesquels ont bougé.
   */
  const variationsPrix = await sql<VariationPrix[]>`
    with achats as (
      select m.produit_id, m.prix_unitaire,
             row_number() over (partition by m.produit_id
                                 order by m.date_mouvement, m.id)       as rang_asc,
             row_number() over (partition by m.produit_id
                                 order by m.date_mouvement desc, m.id desc) as rang_desc
        from mouvements_stock m
       where m.type = 'entree' and m.prix_unitaire is not null
         and m.date_mouvement >= ${debut}::date
         and m.date_mouvement < (${fin}::date + 1)
    )
    select p.designation,
           min(a.prix_unitaire) filter (where a.rang_asc = 1)  as premier_prix,
           min(a.prix_unitaire) filter (where a.rang_desc = 1) as dernier_prix,
           count(*)::int as nb_achats
      from achats a
      join produits p on p.id = a.produit_id
     group by p.id, p.designation
    having count(*) >= 2`;

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

  // Seuls les articles qui ont réellement bougé, les plus francs d'abord —
  // un prix qui n'a pas varié n'a rien à montrer ici.
  const variations = variationsPrix
    .map((v) => {
      const premier = Number(v.premier_prix);
      const dernier = Number(v.dernier_prix);
      return {
        designation: v.designation,
        premier,
        dernier,
        delta: dernier - premier,
        pct: premier !== 0 ? ((dernier - premier) / premier) * 100 : 0,
      };
    })
    .filter((v) => Math.abs(v.delta) >= 0.01)
    .sort((a, b) => Math.abs(b.pct) - Math.abs(a.pct))
    .slice(0, 8);

  const lienPeriode = (d: string, f: string) =>
    `/technique/tableau?debut=${d}&fin=${f}` as Route;
  const raccourcisPeriode = [
    {
      l: "30 jours",
      debut: jourISO(new Date(new Date().setDate(new Date().getDate() - 30))),
      fin: aujourdhui,
    },
    {
      l: "3 mois",
      debut: jourISO(new Date(new Date().getFullYear(), new Date().getMonth() - 3, new Date().getDate())),
      fin: aujourdhui,
    },
    { l: "12 mois", debut: defautDebut, fin: aujourdhui },
    {
      l: "Cette année",
      debut: jourISO(new Date(new Date().getFullYear(), 0, 1)),
      fin: aujourdhui,
    },
  ];

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
            dire ce qui part ni ce qui va manquer. Ce qui part et sa
            variation de prix se regardent sur une période choisie — quatre
            raccourcis couvrent l'essentiel, et les dates se règlent. */}
        <FormulaireEnPlace className="carte px-4 py-3.5 flex flex-col gap-3">
          <div className="flex gap-2.5">
            <label className="flex-1 flex flex-col gap-1">
              <span className="etiquette">Du</span>
              <input
                type="date"
                name="debut"
                defaultValue={debut}
                className="h-[42px] rounded-[11px] border border-line px-2.5 bg-white text-[14px]"
              />
            </label>
            <label className="flex-1 flex flex-col gap-1">
              <span className="etiquette">Au</span>
              <input
                type="date"
                name="fin"
                defaultValue={fin}
                className="h-[42px] rounded-[11px] border border-line px-2.5 bg-white text-[14px]"
              />
            </label>
          </div>
          <div className="flex items-center gap-2 flex-wrap">
            <button className="h-[40px] px-4 rounded-[11px] bg-plum text-white font-display font-semibold text-[14px] active:opacity-80">
              Afficher
            </button>
            {raccourcisPeriode.map((r) => (
              <Link
                key={r.l}
                href={lienPeriode(r.debut, r.fin)}
                replace
                scroll={false}
                className={`h-[40px] px-2.5 rounded-[11px] grid place-items-center text-[12.5px] ${
                  debut === r.debut && fin === r.fin
                    ? "bg-plum-soft text-plum font-medium"
                    : "bg-surface-muted text-ink-soft"
                }`}
              >
                {r.l}
              </Link>
            ))}
          </div>
        </FormulaireEnPlace>

        <Cadre
          titre="Ce qui part de la réserve"
          detail={`Les huit articles les plus sortis du ${new Date(debut).toLocaleDateString("fr-FR")} au ${new Date(fin).toLocaleDateString("fr-FR")}, et ce qu’ils ont coûté. Les essais en 06 et 07 n’y sont pas.`}
        >
          {consommes.length === 0 ? (
            <p className="text-[13px] text-ink-faint">
              Aucune sortie de matériel sur cette période.
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
          titre="Variation du prix (HT)"
          detail="Premier et dernier prix payé sur la période, pour les articles achetés au moins deux fois. Le prix payé se lit dans les mouvements, ce n’est jamais un tarif négocié."
        >
          {variations.length === 0 ? (
            <p className="text-[13px] text-ink-faint">
              Aucun article acheté deux fois sur cette période : rien à comparer.
            </p>
          ) : (
            <ul className="flex flex-col gap-1.5">
              {variations.map((v) => (
                <li key={v.designation} className="flex items-baseline gap-2 text-[13px]">
                  <span className="grow min-w-0 truncate">{v.designation}</span>
                  <span className="text-ink-faint tabular-nums text-[12px] shrink-0">
                    {euros(v.premier)} → {euros(v.dernier)}
                  </span>
                  <span
                    className={`shrink-0 px-2 py-0.5 rounded-md text-[12.5px] tabular-nums ${
                      v.delta > 0 ? "bg-red-soft text-red" : "bg-green-soft text-green"
                    }`}
                  >
                    {v.delta > 0 ? "+" : "−"}
                    {Math.abs(v.pct).toFixed(1)} %
                  </span>
                </li>
              ))}
            </ul>
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
