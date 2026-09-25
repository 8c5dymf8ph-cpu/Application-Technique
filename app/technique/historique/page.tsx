import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { exigerEncadrement } from "@/lib/acces";
import { euros, jourISO } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";
import { Filtres, Recherche, Stat, Surligne } from "@/app/composants/suivi";

export const dynamic = "force-dynamic";

type Lot = {
  id: string;
  reference: string;
  intervenant: string | null;
  date_tournee: string;
  cloturee_le: string | null;
  nb_interventions: number;
  nb_en_attente: number;
  nb_validees: number;
  nb_a_refaire: number;
  cout_total: number;
  cout_incomplet: boolean;
  reprise: boolean;
  mail_recap_envoye_le: string | null;
  emplacements: string | null;
  /** La facture qui couvre ce passage, et combien de journées elle couvre. */
  facture: string | null;
  facture_id: string | null;
  nb_journees_couvertes: number;
};

/** Une anomalie du passage, telle qu'on la lit dans le mois déplié. */
type Detail = {
  tournee: string;
  sharepoint_id: number | null;
  emplacement: string;
  description: string;
  decision_gouvernante: string | null;
  decision_technicien: string | null;
  materiel: string | null;
};

type Facture = {
  id: string;
  type: string;
  reference: string | null;
  emetteur: string | null;
  date_reference: string | Date;
  montant_ht: number | null;
  statut: string;
  fichier_url: string | null;
  nb_interventions: number;
  /** Les journées que la pièce couvre, dans l'ordre. C'est la lecture qui manquait. */
  journees: (string | Date)[];
  /** Le passage par lequel on entre dans la facture : elle s'y règle en entier. */
  premier_passage: string | null;
};

type Attente = { prestataire_id: string; prestataire: string; nb: number; plus_ancienne: number };

const STATUT: Record<string, { l: string; fond: string; texte: string }> = {
  a_rapprocher: { l: "À rapprocher", fond: "bg-amber-soft", texte: "text-amber" },
  rapprochee: { l: "Rapprochée", fond: "bg-blue-soft", texte: "text-blue" },
  reglee: { l: "Réglée", fond: "bg-green-soft", texte: "text-green" },
  litige: { l: "Litige", fond: "bg-red-soft", texte: "text-red" },
};

const JOUR = { day: "numeric", month: "long" } as const;
const JOUR_LONG = { weekday: "long", day: "numeric", month: "long", year: "numeric" } as const;

/**
 * Les passages et les factures, sur UN écran.
 *
 * C'était deux : l'historique d'un côté, les factures de l'autre, la même
 * pièce des deux côtés et un aller-retour entre les deux pour rattacher une
 * journée. Or ce sont deux LECTURES d'une seule chose — ce que l'hôtel a fait
 * faire et ce qu'il paye — et elles se répondent : on part d'un passage pour
 * saisir la facture, on part d'une facture pour voir ce qu'elle couvre.
 *
 * Deux onglets, donc, et un seul chemin depuis Technique. Les deux mènent au
 * même endroit : le passage, où la facture se règle entièrement (règle
 * 16duodecies).
 */
export default async function PassagesEtFactures({
  searchParams,
}: {
  searchParams: Promise<{
    q?: string;
    qui?: string;
    vue?: string;
    filtre?: string;
    mois?: string;
  }>;
}) {
  await exigerEncadrement();
  const {
    q = "",
    qui = "tous",
    vue = "passages",
    filtre = "a_rapprocher",
    mois: moisOuverts,
  } = await searchParams;
  const terme = q.trim().toLowerCase();
  const factures_ = vue === "factures";

  const [c] = await sql<
    {
      lots: number;
      anomalies: number;
      cout_annee: number;
      incomplets: number;
      a_rapprocher: number;
      toutes: number;
      ht_annee: number;
      sans_facture: number;
    }[]
  >`
    select
      (select count(*) filter (where nb_interventions > 0) from v_tournees)::int as lots,
      (select coalesce(sum(nb_interventions), 0) from v_tournees)::int           as anomalies,
      (select coalesce(sum(cout_total), 0) from v_tournees
        where date_tournee >= date_trunc('year', current_date))                  as cout_annee,
      (select count(*) filter (where cout_incomplet) from v_tournees)::int       as incomplets,
      (select count(*) from factures where statut = 'a_rapprocher')::int         as a_rapprocher,
      (select count(*) from factures)::int                                       as toutes,
      (select coalesce(sum(montant_ht), 0) from factures
        where date_reference >= date_trunc('year', current_date))                as ht_annee,
      (select count(*) from v_interventions_sans_facture)::int                   as sans_facture`;

  const gens = factures_
    ? []
    : await sql<{ intervenant: string; nombre: number }[]>`
        select intervenant, count(*)::int as nombre
        from v_tournees
        where nb_interventions > 0 and intervenant is not null
        group by 1 order by 2 desc, 1 limit 12`;

  // Une tournée se retrouve par l'intervenant, la chambre, ou un mot de
  // l'anomalie : on cherche rarement par référence.
  const lots = factures_
    ? []
    : await sql<Lot[]>`
        select t.id, t.reference, t.intervenant, t.date_tournee, t.cloturee_le,
               t.nb_interventions::int, t.nb_en_attente::int, t.nb_validees::int,
               t.nb_a_refaire::int, t.cout_total,
               coalesce(t.cout_incomplet, false) as cout_incomplet,
               t.reprise, t.mail_recap_envoye_le,
               (select string_agg(distinct r.emplacement, ', ' order by r.emplacement)
                  from v_recap_interventions r where r.tournee = t.reference) as emplacements,
               fa.reference as facture, fa.id as facture_id,
               coalesce(fa.nb_journees, 0)::int as nb_journees_couvertes
        from v_tournees t
        left join lateral (
          select f.id, f.reference,
                 (select count(distinct i2.date_intervention)
                    from facture_interventions fi2
                    join interventions i2 on i2.id = fi2.intervention_id
                   where fi2.facture_id = f.id) as nb_journees
            from v_recap_interventions r
            join facture_interventions fi on fi.intervention_id = r.intervention_id
            join factures f               on f.id = fi.facture_id
           where r.tournee = t.reference
           limit 1) fa on true
        where t.nb_interventions > 0
          and (${qui} = 'tous' or t.intervenant = ${qui})
          and (${terme} = '' or exists (
                select 1 from v_recap_interventions r
                where r.tournee = t.reference
                  and (lower(r.description) like ${"%" + terme + "%"}
                    or lower(r.emplacement) like ${"%" + terme + "%"}
                    or lower(coalesce(r.intervenant, '')) like ${"%" + terme + "%"}
                    -- On identifie une anomalie par son NUMÉRO d'origine, celui
                    -- de l'ancienne application : « l'anomalie 378 ». Chercher
                    -- « 378 » ne rendait rien, et on concluait qu'elle avait
                    -- disparu.
                    or exists (select 1 from anomalies a
                                where a.id = r.anomalie_id
                                  and a.sharepoint_id::text = ${terme}))))
        order by t.date_tournee desc, t.cloturee_le desc nulls last
        -- Plus de coupe à 50 : sur la base de l'hôtel, 46 passages sur 96 —
        -- 304 anomalies — n'existaient tout simplement pas à l'écran, et rien
        -- ne le disait. Les mois se replient, ils ne se tronquent pas.
        limit 400`;

  // Une facture se lit par ce qu'elle COUVRE : sans les journées, la carte ne
  // disait qu'un nombre d'interventions, et on ouvrait pour savoir lesquelles.
  const factures = factures_
    ? await sql<Facture[]>`
        select f.id, f.type::text, f.reference,
               coalesce(p.nom, fo.nom) as emetteur,
               f.date_reference, f.montant_ht, f.statut::text, f.fichier_url,
               coalesce(j.nb_interventions, 0)::int as nb_interventions,
               coalesce(j.journees, '{}'::date[])   as journees,
               j.premier_passage
        from factures f
        left join prestataires p  on p.id = f.prestataire_id
        left join fournisseurs fo on fo.id = f.fournisseur_id
        left join lateral (
          select count(*)::int as nb_interventions,
                 array_agg(distinct i.date_intervention order by i.date_intervention)
                   as journees,
                 (array_agg(t.id order by t.date_tournee))[1] as premier_passage
            from facture_interventions fi
            join interventions i on i.id = fi.intervention_id
            left join tournees t on t.id = i.tournee_id
           where fi.facture_id = f.id) j on true
        where (${filtre} = 'toutes' or f.statut::text = ${filtre})
          and (${terme} = ''
            or lower(coalesce(p.nom, fo.nom, '')) like ${"%" + terme + "%"}
            or lower(coalesce(f.reference, '')) like ${"%" + terme + "%"})
        order by f.date_reference desc, f.cree_le desc
        limit 40`
    : [];

  // Ce qu'un prestataire a fait et qu'aucune facture ne couvre : c'est le
  // filet, et c'est par là qu'on commence quand une facture arrive. Chaque
  // ligne mène à ses passages — c'est de là qu'on saisit la pièce.
  const attente = factures_
    ? await sql<Attente[]>`
        select prestataire_id, prestataire, count(*)::int as nb,
               max(jours_ecoules)::int as plus_ancienne
        from v_interventions_sans_facture
        group by prestataire_id, prestataire
        order by max(jours_ecoules) desc`
    : [];

  /**
   * Les passages, groupés par mois.
   *
   * Quatre-vingt-seize cartes à la file ne disent rien : on fait défiler sans
   * savoir où l'on est dans le temps, et on renonce. Un mois par section, avec
   * ce qu'il pèse, et l'on ouvre celui qu'on cherche. Les deux plus récents
   * sont ouverts — c'est là qu'on regarde neuf fois sur dix.
   */
  const cleDuMois = (d: string | Date) => jourISO(d).slice(0, 7);

  const mois = lots.reduce<
    { cle: string; libelle: string; lots: Lot[]; anomalies: number; cout: number }[]
  >((acc, l) => {
    const d = new Date(jourISO(l.date_tournee));
    const cle = cleDuMois(l.date_tournee);
    let groupe = acc.find((g) => g.cle === cle);
    if (!groupe) {
      groupe = {
        cle,
        libelle: d.toLocaleDateString("fr-FR", { month: "long", year: "numeric" }),
        lots: [],
        anomalies: 0,
        cout: 0,
      };
      acc.push(groupe);
    }
    groupe.lots.push(l);
    groupe.anomalies += l.nb_interventions;
    groupe.cout += Number(l.cout_total ?? 0);
    return acc;
  }, []);

  /**
   * Quels mois sont dépliés — et c'est l'ADRESSE qui le dit.
   *
   * Sans ça, ouvrir un passage puis revenir refermait tout : `RelireEnRevenant`
   * redemande la page au serveur, et l'état d'un `<details>` n'y survit pas.
   * On remontait le mois qu'on venait de quitter à chaque aller-retour.
   * Dans l'adresse, l'ouverture est une donnée comme une autre : elle survit au
   * retour, et le lien se partage tel qu'on le regarde.
   *
   * Par défaut les deux mois les plus récents — c'est là qu'on regarde neuf
   * fois sur dix. `?mois=` (vide) les referme tous.
   */
  const ouverts = new Set(
    moisOuverts !== undefined
      ? moisOuverts.split(",").filter(Boolean)
      : // Chercher, c'est déjà dire ce qu'on veut lire : les mois qui
        // répondent s'ouvrent tous, sinon on retrouve la bonne section fermée
        // et on croit que le mot n'a rien donné. Sans recherche, les deux plus
        // récents — c'est là qu'on regarde neuf fois sur dix.
        terme
        ? mois.map((g) => g.cle)
        : mois.slice(0, 2).map((g) => g.cle),
  );

  /**
   * Le détail des mois ouverts — TOUTES les anomalies, pas un aperçu.
   *
   * « Si je clique pour avoir le détail, c'est que je veux tous les détails
   * des anomalies regroupées ensemble, et non devoir cliquer sur la deuxième
   * intervention du mois pour avoir le détail à nouveau. » Le mois déplié
   * porte donc tout ; on ne charge que ce qui est ouvert.
   */
  const referencesOuvertes = lots
    .filter((l) => ouverts.has(cleDuMois(l.date_tournee)))
    .map((l) => l.reference);

  const details = referencesOuvertes.length
    ? await sql<Detail[]>`
        select r.tournee, a.sharepoint_id, r.emplacement, r.description,
               r.decision_gouvernante::text, r.decision_technicien::text,
               (select string_agg(p.designation || ' × ' || abs(m.quantite), ', ')
                  from mouvements_stock m join produits p on p.id = m.produit_id
                 where m.intervention_id = r.intervention_id and m.type = 'sortie')
                 as materiel
          from v_recap_interventions r
          join anomalies a on a.id = r.anomalie_id
         where r.tournee = any(${referencesOuvertes})
         order by r.emplacement, r.description`
    : [];
  const detailDe = (reference: string) => details.filter((d) => d.tournee === reference);

  const ici = (p: Record<string, string>) =>
    `/technique/historique?${new URLSearchParams({
      ...(vue !== "passages" ? { vue } : {}),
      ...(qui !== "tous" ? { qui } : {}),
      ...(q ? { q } : {}),
      ...(moisOuverts !== undefined ? { mois: moisOuverts } : {}),
      ...p,
    })}` as Route;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Passages & factures"
        sous_titre={
          factures_
            ? `${c.toutes} facture${c.toutes > 1 ? "s" : ""} · ${euros(c.ht_annee)} HT cette année`
            : `${c.lots} passages · ${c.anomalies} anomalies`
        }
        retour="/technique"
      />

      <div className="px-5 py-4 flex flex-col gap-3.5">
        {/* Les deux lectures d'une même chose. On ne quitte pas l'écran pour
            passer de l'une à l'autre : elles se répondent. */}
        <div className="flex gap-1.5 p-1 rounded-pill bg-surface-muted">
          {[
            { v: "passages", l: "Par passage", n: c.lots },
            { v: "factures", l: "Par facture", n: c.toutes },
          ].map((o) => (
            <Link
              key={o.v}
              href={ici({ vue: o.v })}
              aria-current={o.v === vue ? "true" : undefined}
              className={`flex-1 h-[38px] rounded-pill flex items-center justify-center gap-1.5 text-[13.5px] ${
                o.v === vue
                  ? "bg-surface border border-line font-display font-semibold shadow-[0_1px_2px_rgba(0,0,0,0.05)]"
                  : "text-ink-soft"
              }`}
            >
              {o.l}
              <span className="text-ink-faint text-[12px] tabular-nums">{o.n}</span>
            </Link>
          ))}
        </div>

        <div className="flex gap-2">
          {factures_ ? (
            <>
              <Stat
                valeur={c.a_rapprocher}
                libelle="À rapprocher"
                ton={c.a_rapprocher > 0 ? "alerte" : undefined}
              />
              <Stat valeur={c.sans_facture} libelle="Sans facture" />
              <Stat valeur={euros(c.ht_annee)} libelle="HT cette année" />
            </>
          ) : (
            <>
              <Stat valeur={c.lots} libelle="Passages" />
              <Stat valeur={c.anomalies} libelle="Anomalies" />
              <Stat valeur={euros(c.cout_annee)} libelle="Coût cette année" />
            </>
          )}
        </div>

        {!factures_ && c.incomplets > 0 && (
          <p className="text-[11.5px] text-amber text-pretty leading-snug">
            {c.incomplets} passage{c.incomplets > 1 ? "s" : ""} au coût incomplet : au moins un
            article utilisé n’a pas de prix renseigné.
          </p>
        )}

        <Recherche
          valeur={q}
          placeholder={factures_ ? "Un intervenant, un numéro…" : "Une chambre, un mot, un nom…"}
          // Les mois ouverts ne suivent pas la recherche : une question neuve
          // rouvre ce qui répond, sinon le mot tombe dans une section restée
          // fermée par la question d'avant.
          caches={factures_ ? { vue, filtre } : { qui }}
        />

        {factures_ ? (
          <>
            {/* Ce qu'on attend. Une facture arrive, on cherche À QUOI elle
                correspond : chaque ligne mène aux passages de l'intervenant,
                d'où la pièce se saisit. */}
            {attente.length > 0 && (
              <section className="flex flex-col gap-2">
                <h2 className="etiquette">Passages sans facture</h2>
                <ul className="flex flex-col gap-1.5">
                  {attente.map((a) => (
                    <li key={a.prestataire_id}>
                      <Link
                        href={ici({ vue: "passages", qui: a.prestataire })}
                        className="carte px-3.5 py-2.5 flex items-center gap-3 active:bg-surface-muted"
                      >
                        <span className="grow min-w-0">
                          <span className="block text-[14px]">{a.prestataire}</span>
                          <span className="block text-[11.5px] text-ink-faint">
                            {a.nb} anomalie{a.nb > 1 ? "s" : ""} · la plus ancienne remonte à{" "}
                            {a.plus_ancienne} jours
                          </span>
                        </span>
                        <span
                          className={`shrink-0 px-2 py-0.5 rounded-md text-[11px] ${
                            a.plus_ancienne > 45
                              ? "bg-red-soft text-red"
                              : "bg-surface-muted text-ink-soft"
                          }`}
                        >
                          {a.plus_ancienne > 45 ? "à relancer" : "en attente"}
                        </span>
                      </Link>
                    </li>
                  ))}
                </ul>
              </section>
            )}

            <Filtres
              actif={filtre}
              lien={(f) => ici({ filtre: f })}
              choix={[
                { valeur: "a_rapprocher", libelle: "À rapprocher", nombre: c.a_rapprocher },
                { valeur: "rapprochee", libelle: "Rapprochées" },
                { valeur: "reglee", libelle: "Réglées" },
                { valeur: "toutes", libelle: "Toutes", nombre: c.toutes },
              ]}
            />

            {factures.length === 0 ? (
              <Vide>
                {terme
                  ? `Aucune facture ne correspond à « ${q} ».`
                  : "Aucune facture dans cette catégorie."}
              </Vide>
            ) : (
              <ul className="flex flex-col gap-2">
                {factures.map((f) => {
                  const s = STATUT[f.statut] ?? STATUT.a_rapprocher;
                  // Une facture de prestation se règle SUR le passage : c'est
                  // là que sont le montant, la pièce et ce qu'elle couvre.
                  const vers = f.premier_passage
                    ? (`/technique/tournee/${f.premier_passage}` as Route)
                    : (`/technique/facture/${f.id}` as Route);
                  return (
                    <li key={f.id}>
                      <Link
                        href={vers}
                        className="carte px-4 py-3.5 flex flex-col gap-1.5 active:bg-surface-muted"
                      >
                        <span className="flex items-start gap-3">
                          <span className="grow min-w-0">
                            <span className="block font-display font-semibold text-[15px]">
                              {f.emetteur ? (
                                <Surligne texte={f.emetteur} mot={terme} />
                              ) : (
                                "—"
                              )}
                            </span>
                            <span className="block text-[11.5px] text-ink-faint">
                              {f.reference ? (
                                <Surligne texte={f.reference} mot={terme} />
                              ) : (
                                "sans numéro"
                              )}{" "}
                              ·{" "}
                              {new Date(f.date_reference).toLocaleDateString("fr-FR")}
                              {f.type === "achat" && " · achat"}
                            </span>
                          </span>
                          <span
                            className={`shrink-0 px-2 py-0.5 rounded-md text-[11px] ${s.fond} ${s.texte}`}
                          >
                            {s.l}
                          </span>
                        </span>

                        <span className="flex items-baseline gap-3 flex-wrap">
                          <span className="font-display font-semibold text-[15px] tabular-nums">
                            {euros(f.montant_ht)}
                            <span className="text-[10.5px] text-ink-faint font-sans font-normal">
                              {" "}
                              HT
                            </span>
                          </span>
                          {f.fichier_url && (
                            <span className="ml-auto text-[11px] text-green">pièce jointe</span>
                          )}
                        </span>

                        {/* Ce qu'elle couvre, en clair. « 3 interventions » ne
                            disait pas lesquelles : on ouvrait pour savoir. */}
                        {f.journees.length > 0 ? (
                          <span className="flex flex-wrap gap-1">
                            {f.journees.slice(0, 6).map((j) => (
                              <span
                                key={jourISO(j)}
                                className="px-1.5 py-0.5 rounded-md bg-surface-muted text-[11px] text-ink-soft"
                              >
                                {new Date(j).toLocaleDateString("fr-FR", JOUR)}
                              </span>
                            ))}
                            {f.journees.length > 6 && (
                              <span className="px-1.5 py-0.5 text-[11px] text-ink-faint">
                                +{f.journees.length - 6}
                              </span>
                            )}
                            <span className="px-1.5 py-0.5 text-[11px] text-ink-faint">
                              · {f.nb_interventions} anomalie
                              {f.nb_interventions > 1 ? "s" : ""}
                            </span>
                          </span>
                        ) : (
                          <span className="text-[11.5px] text-amber">
                            {f.type === "achat"
                              ? "facture d’achat — sans passage"
                              : "ne couvre encore aucune journée"}
                          </span>
                        )}
                      </Link>
                    </li>
                  );
                })}
              </ul>
            )}
          </>
        ) : (
          <>
            <Filtres
              actif={qui}
              lien={(v) => ici({ qui: v })}
              choix={[
                { valeur: "tous", libelle: "Tous", nombre: c.lots },
                ...gens.map((g) => ({
                  valeur: g.intervenant,
                  libelle: g.intervenant,
                  nombre: g.nombre,
                })),
              ]}
            />

            {lots.length === 0 ? (
              <Vide>
                {terme ? `Aucun passage ne correspond à « ${q} ».` : "Aucun passage enregistré."}
              </Vide>
            ) : (
              <div className="flex flex-col gap-3">
                {mois.map((g) => {
                  const ouvert = ouverts.has(g.cle);
                  // Basculer ce mois : `replace`, pas `push` — déplier n'est
                  // pas naviguer, et la flèche arrière doit sortir de l'écran,
                  // pas refermer les mois un par un (règle 14septies).
                  const bascule = [...ouverts];
                  const apres = ouvert
                    ? bascule.filter((c) => c !== g.cle)
                    : [...bascule, g.cle];
                  return (
                  <section key={g.cle} className="flex flex-col gap-2">
                    <Link
                      href={ici({ mois: apres.join(",") })}
                      replace
                      scroll={false}
                      data-cible
                      className="carte px-4 py-2.5 flex items-center gap-3 select-none"
                    >
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
                           stroke="#8E8AA3" strokeWidth="2" strokeLinecap="round"
                           strokeLinejoin="round"
                           className={`shrink-0 transition-transform ${ouvert ? "rotate-90" : ""}`}>
                        <path d="M9 5l7 7-7 7" />
                      </svg>
                      <span className="grow font-display font-semibold text-[15px] first-letter:uppercase">
                        {g.libelle}
                      </span>
                      <span className="shrink-0 text-[11.5px] text-ink-faint tabular-nums">
                        {g.lots.length} passage{g.lots.length > 1 ? "s" : ""} · {g.anomalies}{" "}
                        anomalie{g.anomalies > 1 ? "s" : ""}
                        {g.cout > 0 ? ` · ${euros(g.cout)}` : ""}
                      </span>
                    </Link>
                    {ouvert && (
                    <ul className="flex flex-col gap-2">
{g.lots.map((l) => (
                  <li key={l.id} className="carte px-4 py-3.5 flex flex-col gap-1.5">
                    <div>
                      <span className="flex items-baseline gap-3">
                        <span className="grow min-w-0">
                          <span className="block font-display font-semibold text-[15.5px]">
                            {l.intervenant ? (
                              <Surligne texte={l.intervenant} mot={terme} />
                            ) : (
                              "Intervenant inconnu"
                            )}
                          </span>
                          <span className="block text-[11.5px] text-ink-faint">
                            {new Date(l.date_tournee).toLocaleDateString("fr-FR", JOUR_LONG)}
                          </span>
                        </span>
                        <span className="shrink-0 text-right">
                          <span className="block font-display font-semibold text-[15px] tabular-nums">
                            {euros(l.cout_total)}
                          </span>
                          {l.cout_incomplet && (
                            <span className="block text-[10px] text-red">incomplet</span>
                          )}
                        </span>
                      </span>


                    </div>

                    {/* TOUTES les anomalies du passage, pas trois. Déplier un
                        mois, c'est vouloir le lire en entier — pas rouvrir
                        chaque passage l'un après l'autre. */}
                    <ul className="flex flex-col divide-y divide-line border-y border-line">
                      {detailDe(l.reference).map((d, i) => (
                        <li key={`${d.emplacement}-${i}`} className="py-2 flex items-start gap-2.5">
                          <span className="shrink-0 mt-[1px] flex flex-col items-center gap-0.5">
                            <span className="px-1.5 py-0.5 rounded-md bg-plum-soft text-plum text-[11.5px] font-medium tabular-nums">
                              <Surligne texte={d.emplacement} mot={terme} />
                            </span>
                            {/* On identifie une anomalie par son NUMÉRO
                                d'origine : « l'anomalie 378 ». On le cherchait,
                                et il n'était écrit nulle part. */}
                            {d.sharepoint_id != null && (
                              <span className="text-[9.5px] text-ink-faint tabular-nums">
                                n° <Surligne texte={String(d.sharepoint_id)} mot={terme} />
                              </span>
                            )}
                          </span>
                          <span className="grow min-w-0">
                            <span className="block text-[13.5px] leading-snug text-pretty">
                              <Surligne texte={d.description} mot={terme} />
                            </span>
                            {d.materiel && (
                              <span className="block text-[11.5px] text-ink-faint">
                                <Surligne texte={d.materiel} mot={terme} />
                              </span>
                            )}
                          </span>
                          <span
                            className={`shrink-0 mt-[1px] px-1.5 py-0.5 rounded-md text-[10.5px] ${
                              d.decision_gouvernante === "validee"
                                ? "bg-green-soft text-green"
                                : d.decision_gouvernante === "a_refaire"
                                  ? "bg-red-soft text-red"
                                  : d.decision_gouvernante
                                    ? "bg-blue-soft text-blue"
                                    : d.decision_technicien === "fait"
                                      ? "bg-amber-soft text-amber"
                                      : "bg-surface-muted text-ink-faint"
                            }`}
                          >
                            {d.decision_gouvernante === "validee"
                              ? "validée"
                              : d.decision_gouvernante === "a_refaire"
                                ? "à refaire"
                                : d.decision_gouvernante
                                  ? "en cours"
                                  : d.decision_technicien === "fait"
                                    ? "sans avis"
                                    : "—"}
                          </span>
                        </li>
                      ))}
                    </ul>

                    <Link
                      href={`/technique/tournee/${l.id}` as Route}
                      className="flex flex-wrap items-center gap-2 text-[11px] active:opacity-70"
                    >
                      <span className="text-plum underline underline-offset-4">
                        Ouvrir le passage
                      </span>
                        {/* La facture, d'un coup d'œil : ce qui est couvert et
                            ce qui attend encore sa pièce ne se distinguaient
                            pas. */}
                        {l.facture_id ? (
                          <span className="flex items-center gap-1 px-1.5 py-0.5 rounded-md bg-green-soft text-green">
                            <svg width="11" height="11" viewBox="0 0 24 24" fill="none"
                                 stroke="currentColor" strokeWidth="2" strokeLinecap="round"
                                 strokeLinejoin="round" aria-hidden>
                              <path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z" />
                              <path d="M14 3v5h5" />
                            </svg>
                            {l.facture ?? "facturé"}
                            {l.nb_journees_couvertes > 1
                              ? ` · ${l.nb_journees_couvertes} journées`
                              : ""}
                          </span>
                        ) : (
                          l.cout_total > 0 && (
                            <span className="px-1.5 py-0.5 rounded-md bg-amber-soft text-amber">
                              sans facture
                            </span>
                          )
                        )}
                        {l.nb_validees > 0 && (
                          <span className="text-green">
                            {l.nb_validees} validée{l.nb_validees > 1 ? "s" : ""}
                          </span>
                        )}
                        {l.nb_a_refaire > 0 && (
                          <span className="text-red">{l.nb_a_refaire} à refaire</span>
                        )}
                        {l.nb_en_attente > 0 && (
                          <span className="text-amber">{l.nb_en_attente} sans avis</span>
                        )}
                        {l.reprise ? (
                          <span className="text-ink-faint">repris de l’ancienne application</span>
                        ) : l.mail_recap_envoye_le ? (
                          <span className="text-ink-faint">récapitulatif envoyé</span>
                        ) : null}
                    </Link>
                  </li>
                      ))}
                    </ul>
                    )}
                  </section>
                  );
                })}
              </div>
            )}
          </>
        )}
      </div>
    </main>
  );
}
