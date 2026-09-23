import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, jourISO } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";
import { Cadre, Chiffre, Repartition, SERIES, Tableau } from "@/app/composants/graphiques";

export const dynamic = "force-dynamic";

/**
 * Le récapitulatif d'une période.
 *
 * Le tableau de bord dit où en est le parc aujourd'hui ; celui-ci dit ce qui
 * s'est PASSÉ entre deux dates. Ce sont deux questions différentes : l'une se
 * regarde le matin, l'autre se sort en fin de mois, pour la direction ou pour
 * rapprocher une facture Purezza.
 *
 * Trois choses, dans cet ordre : ce qui est entré et sorti, ce qui a été livré,
 * puis chaque dossier par date — avec son commentaire, parce que c'est là que
 * se trouve ce que les chiffres ne disent pas.
 */

type Bilan = {
  type: string;
  bouteille: string;
  couleur: string | null;
  quantite: number;
};

type Livraison = {
  date_mouvement: string | Date;
  bouteille: string;
  couleur: string | null;
  quantite: number;
  commande: number | null;
  commentaire: string | null;
};

type Dossier = {
  id: string;
  reference: number;
  emplacement: string;
  bouteille: string | null;
  quantite: number;
  nature: string;
  statut: string;
  responsable: string | null;
  client_nom: string | null;
  constate_par: string | null;
  transmis_a: string | null;
  constate_le: string | Date;
  resolu_le: string | Date | null;
  montant: number | null;
  commentaire: string | null;
};

const NATURE: Record<string, string> = {
  emport: "Emportée par le client",
  casse: "Cassée",
};

/** Les mêmes mots et les mêmes tons que la liste des dossiers : un état n'a
    pas deux noms selon l'écran où on le lit. */
const STATUT: Record<string, { l: string; fond: string; texte: string }> = {
  signale: { l: "Signalé", fond: "bg-amber-soft", texte: "text-amber" },
  transmis: { l: "Transmis", fond: "bg-amber-soft", texte: "text-amber" },
  client_contacte: { l: "Client contacté", fond: "bg-blue-soft", texte: "text-blue" },
  restitue: { l: "Restituée", fond: "bg-green-soft", texte: "text-green" },
  facture: { l: "Facturé", fond: "bg-green-soft", texte: "text-green" },
  non_facture: { l: "Perte sèche", fond: "bg-red-soft", texte: "text-red" },
  clos: { l: "Clos", fond: "bg-surface-muted", texte: "text-ink-faint" },
};

/** Le premier jour du mois en cours, et aujourd'hui : la période la plus demandée. */
function moisCourant(): { debut: string; fin: string } {
  const d = new Date();
  return {
    debut: jourISO(new Date(d.getFullYear(), d.getMonth(), 1)),
    fin: jourISO(d),
  };
}

function valide(v: string | undefined, repli: string): string {
  return v && /^\d{4}-\d{2}-\d{2}$/.test(v) ? v : repli;
}

function enFrancais(d: string | Date): string {
  return new Date(d).toLocaleDateString("fr-FR", {
    weekday: "long",
    day: "numeric",
    month: "long",
    year: "numeric",
  });
}

export default async function Recapitulatif({
  searchParams,
}: {
  searchParams: Promise<{ debut?: string; fin?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  const defaut = moisCourant();
  const p = await searchParams;
  const debut = valide(p.debut, defaut.debut);
  // Une période à l'envers ne rend rien et ne dit pas pourquoi : on la remet
  // à l'endroit plutôt que d'afficher une page vide.
  const finBrute = valide(p.fin, defaut.fin);
  const fin = finBrute < debut ? debut : finBrute;

  /**
   * Ce qui est entré et sorti, par type de mouvement et par bouteille.
   *
   * Les récupérations en font partie : une bouteille restituée revient dans la
   * réserve, et c'est exactement ce qu'on veut lire en fin de mois — combien
   * sont parties, combien sont revenues.
   *
   * La dotation n'est PAS un mouvement de parc : c'est un déplacement de la
   * réserve vers la chambre (règle 2bis). Elle est comptée à part.
   */
  const bilan = await sql<Bilan[]>`
    select m.type::text, bt.libelle as bouteille, bt.couleur,
           sum(m.quantite)::int as quantite
      from mouvements_bouteilles m
      join bouteille_types bt on bt.id = m.bouteille_type_id
     where m.date_mouvement >= ${debut}::date
       and m.date_mouvement < (${fin}::date + 1)
     group by 1, 2, 3
     order by 2, 1`;

  const livraisons = await sql<Livraison[]>`
    select m.date_mouvement, bt.libelle as bouteille, bt.couleur,
           m.quantite, c.reference as commande, m.commentaire
      from mouvements_bouteilles m
      join bouteille_types bt on bt.id = m.bouteille_type_id
      left join commandes c on c.id = m.commande_id
     where m.type = 'entree'
       and m.date_mouvement >= ${debut}::date
       and m.date_mouvement < (${fin}::date + 1)
     order by m.date_mouvement desc`;

  const dossiers = await sql<Dossier[]>`
    select id, reference, emplacement, bouteille, quantite, nature::text,
           statut::text, responsable::text, client_nom, constate_par, transmis_a,
           constate_le, resolu_le, montant, commentaire
      from v_dossiers_bouteille
     where constate_le >= ${debut}::date
       and constate_le < (${fin}::date + 1)
     order by constate_le desc, reference desc`;

  const somme = (t: string) =>
    bilan.filter((b) => b.type === t).reduce((n, b) => n + b.quantite, 0);

  const sorties = somme("emport") + somme("casse");
  const recuperees = somme("retour");
  const perdues = somme("perte");
  const livrees = somme("entree");
  const enJeu = dossiers.reduce((n, d) => n + Number(d.montant ?? 0), 0);
  const facture = dossiers
    .filter((d) => d.statut === "facture")
    .reduce((n, d) => n + Number(d.montant ?? 0), 0);
  // La perte sèche, c'est ce que l'hôtel a décidé de ne pas facturer : ça ne
  // rentrera pas, et c'est le chiffre qu'on cherche en fin de mois.
  const perteSeche = dossiers
    .filter((d) => d.statut === "non_facture")
    .reduce((n, d) => n + Number(d.montant ?? 0), 0);

  // Le solde du parc détenu sur la période : ce qui est entré moins ce qui en
  // est sorti pour de bon. Une bouteille chez un client n'est pas perdue, mais
  // elle n'est plus détenue — c'est la règle 2bis, et c'est ce que dit ce solde.
  const solde = livrees + recuperees - sorties;

  const lien = (d: string, f: string) =>
    `/bouteilles/recapitulatif?debut=${d}&fin=${f}` as Route;

  const aujourdhui = new Date();
  const raccourcis = [
    { l: "Ce mois-ci", ...moisCourant() },
    {
      l: "Mois dernier",
      debut: jourISO(new Date(aujourdhui.getFullYear(), aujourdhui.getMonth() - 1, 1)),
      fin: jourISO(new Date(aujourdhui.getFullYear(), aujourdhui.getMonth(), 0)),
    },
    {
      l: "12 mois",
      debut: jourISO(
        new Date(aujourdhui.getFullYear(), aujourdhui.getMonth() - 11, 1),
      ),
      fin: jourISO(aujourdhui),
    },
  ];

  const parJour = [...new Set(dossiers.map((d) => jourISO(d.constate_le)))];

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Récapitulatif"
        sous_titre={`Du ${new Date(debut).toLocaleDateString("fr-FR")} au ${new Date(
          fin,
        ).toLocaleDateString("fr-FR")}`}
        retour="/bouteilles"
      />

      <div className="px-5 py-5 place-pour-le-calendrier flex flex-col gap-4">
        {/* La période. Elle se règle, et trois raccourcis couvrent ce qu'on
            demande neuf fois sur dix. */}
        <form method="get" className="carte px-4 py-3.5 flex flex-col gap-3">
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
          <div className="flex items-center gap-2">
            <button className="h-[40px] px-4 rounded-[11px] bg-plum text-white font-display font-semibold text-[14px] active:opacity-80">
              Afficher
            </button>
            {raccourcis.map((r) => (
              <Link
                key={r.l}
                href={lien(r.debut, r.fin)}
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
        </form>

        {/* Les chiffres de la période. « Récupérées » compte autant que
            « sorties » : c'est ce qui revient qui dit si le dispositif marche. */}
        <div className="grid grid-cols-4 gap-2">
          <Chiffre valeur={sorties} libelle="Sorties" ton={SERIES.en_cours} />
          <Chiffre
            valeur={recuperees}
            libelle="Récupérées"
            ton={SERIES.restituee}
          />
          <Chiffre valeur={perdues} libelle="Perdues" ton={SERIES.perdue} />
          <Chiffre valeur={livrees} libelle="Livrées" ton={SERIES.facturee} />
        </div>

        <Cadre
          titre="Entrées et sorties"
          detail={
            "Ce qui est entré moins ce qui est sorti du parc détenu. " +
            "La re-dotation n’y figure pas : elle déplace une bouteille de la " +
            "réserve vers la chambre, elle n’en fait pas sortir une seconde."
          }
        >
          {bilan.length === 0 ? (
            <p className="text-[13px] text-ink-faint">
              Aucun mouvement sur cette période.
            </p>
          ) : (
            <div className="flex flex-col gap-3">
              <div className="flex items-baseline justify-between gap-3 border-b border-line pb-2.5">
                <span className="text-[13.5px] text-ink-soft">
                  Solde du parc détenu
                </span>
                <span
                  className="font-display font-semibold text-[22px] tabular-nums"
                  style={{
                    color:
                      solde < 0
                        ? SERIES.perdue
                        : solde > 0
                          ? SERIES.restituee
                          : undefined,
                  }}
                >
                  {solde > 0 ? "+" : ""}
                  {solde}
                </span>
              </div>
              <Tableau
                entetes={["Bouteille", "Mouvement", "Quantité"]}
                lignes={bilan.map((b) => [
                  b.bouteille,
                  {
                    entree: "Livrée",
                    emport: "Emportée",
                    casse: "Cassée",
                    retour: "Récupérée",
                    perte: "Perdue",
                    dotation: "Re-dotation",
                    regularisation: "Régularisation",
                  }[b.type] ?? b.type,
                  b.quantite,
                ])}
              />
              <Repartition
                parts={[
                  { libelle: "Sorties", valeur: sorties, couleur: SERIES.en_cours },
                  {
                    libelle: "Récupérées",
                    valeur: recuperees,
                    couleur: SERIES.restituee,
                  },
                  { libelle: "Perdues", valeur: perdues, couleur: SERIES.perdue },
                  { libelle: "Livrées", valeur: livrees, couleur: SERIES.facturee },
                ]}
              />
            </div>
          )}
        </Cadre>

        <Cadre
          titre="Livraisons"
          detail="Ce que Purezza a livré sur la période, dans l’ordre des dates."
        >
          {livraisons.length === 0 ? (
            <p className="text-[13px] text-ink-faint">
              Aucune livraison sur cette période.
            </p>
          ) : (
            <ul className="flex flex-col divide-y divide-line">
              {livraisons.map((l, i) => (
                <li key={i} className="py-2.5 flex items-center gap-2.5">
                  <span
                    aria-hidden
                    className="w-2.5 h-2.5 rounded-full shrink-0"
                    style={{ background: l.couleur ?? "#8E8AA3" }}
                  />
                  <span className="grow min-w-0 flex flex-col gap-0.5">
                    <span className="text-[14px]">{l.bouteille}</span>
                    <span className="text-[11.5px] text-ink-faint">
                      {new Date(l.date_mouvement).toLocaleDateString("fr-FR")}
                      {l.commande ? ` · commande n° ${l.commande}` : ""}
                      {l.commentaire ? ` · ${l.commentaire}` : ""}
                    </span>
                  </span>
                  <span className="shrink-0 font-display font-semibold text-[17px] tabular-nums">
                    +{l.quantite}
                  </span>
                </li>
              ))}
            </ul>
          )}
        </Cadre>

        {/* Ce que les chiffres ne disent pas : chaque dossier, par date, avec
            son commentaire. C'est la partie qu'on lit vraiment. */}
        <section className="flex flex-col gap-2.5">
          <div className="flex items-baseline justify-between gap-3">
            <h2 className="etiquette">Les dossiers</h2>
            <span className="text-[11.5px] text-ink-faint tabular-nums">
              {dossiers.length} · {euros(enJeu)} en jeu
              {facture > 0 ? ` · ${euros(facture)} facturés` : ""}
              {perteSeche > 0 ? ` · ${euros(perteSeche)} de perte sèche` : ""}
            </span>
          </div>

          {dossiers.length === 0 ? (
            <Vide>Aucun dossier ouvert sur cette période.</Vide>
          ) : (
            parJour.map((jour) => (
              <div key={jour} className="flex flex-col gap-2">
                {/* La date en en-tête dès qu'il y en a plusieurs (règle 16bis). */}
                <p className="text-[12px] text-ink-faint pt-1">{enFrancais(jour)}</p>
                {dossiers
                  .filter((d) => jourISO(d.constate_le) === jour)
                  .map((d) => {
                    const s = STATUT[d.statut] ?? {
                      l: d.statut,
                      fond: "bg-surface-muted",
                      texte: "text-ink-soft",
                    };
                    return (
                      <Link
                        key={d.id}
                        href={`/bouteilles/dossier/${d.id}` as Route}
                        className="carte px-4 py-3.5 flex flex-col gap-2 active:bg-surface-muted"
                      >
                        <div className="flex items-baseline gap-2.5">
                          {/* Une anomalie ne se montre jamais séparée de son
                              lieu, et un dossier non plus (règle 16bis). */}
                          <span className="shrink-0 px-2 py-0.5 rounded-md bg-plum-soft text-plum text-[12.5px] font-medium">
                            {d.emplacement}
                          </span>
                          <span className="grow min-w-0 text-[14px] truncate">
                            {d.bouteille ?? "sans type"}
                          </span>
                          <span className="shrink-0 text-[11px] text-ink-faint tabular-nums">
                            n° {d.reference}
                          </span>
                        </div>
                        <div className="flex flex-wrap items-center gap-1.5">
                          <span
                            className={`px-2 py-0.5 rounded-md text-[11.5px] ${s.fond} ${s.texte}`}
                          >
                            {s.l}
                          </span>
                          <span className="text-[12px] text-ink-faint">
                            {NATURE[d.nature] ?? d.nature}
                          </span>
                          {Number(d.montant ?? 0) > 0 && (
                            <span className="text-[12px] tabular-nums text-ink-soft">
                              · {euros(d.montant)}
                            </span>
                          )}
                        </div>
                        {/* Qui a constaté, à qui on l'a dit : c'est ce qu'elle
                            doit toujours pouvoir retrouver. */}
                        <p className="text-[12px] text-ink-faint text-pretty">
                          Constaté par {d.constate_par ?? "personne de noté"}
                          {d.transmis_a ? `, transmis à ${d.transmis_a}` : ""}
                          {d.client_nom ? ` · client ${d.client_nom}` : ""}
                          {d.resolu_le
                            ? ` · clos le ${new Date(d.resolu_le).toLocaleDateString("fr-FR")}`
                            : ""}
                        </p>
                        {d.commentaire && (
                          <p className="text-[13px] text-ink-soft text-pretty border-l-2 border-line pl-2.5">
                            {d.commentaire}
                          </p>
                        )}
                      </Link>
                    );
                  })}
              </div>
            ))
          )}
        </section>
      </div>
    </main>
  );
}
