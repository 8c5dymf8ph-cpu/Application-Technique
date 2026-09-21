import { notFound, redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { intervenants, tourneeEnCours } from "@/lib/tournee";
import { Entete } from "@/app/composants/ui";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { ChampPhotos, Vignettes } from "@/app/composants/photos";
import { PhotoProduit } from "@/app/composants/photo-produit";
import { ChampCommentaire, Fil, type Message } from "@/app/composants/fil";
import { enregistrerPhoto } from "@/lib/stockage";
import { colonneExiste } from "@/lib/schema";
import { alerterSiSousSeuil } from "@/lib/seuil";

export const dynamic = "force-dynamic";

type Anomalie = {
  id: string;
  description: string;
  catalogue_id: string | null;
  emplacement: string;
  etage: string;
  essai: boolean;
  intervenant: string | null;
};

type Produit = {
  id: string;
  designation: string;
  code: string;
  stock: number;
  /** TOUTES ses photos, la mise en avant d'abord — pas seulement celle-là. */
  photos: string[];
};

export default async function TraiterAnomalie({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ par?: string; q?: string; pris?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  const { id } = await params;
  const { par, q = "", pris = "" } = await searchParams;

  // `essai` n'existe qu'après la migration 0008 : d'ici là, aucun lieu n'en est
  // un. Une condition booléenne dans le SQL casserait l'écran entier.
  const marque = await colonneExiste("emplacements", "essai");
  const [anomalie] = await sql<Anomalie[]>`
    select a.id, a.description, a.catalogue_id, e.code as emplacement,
           et.nom as etage, ${marque ? sql`e.essai` : sql`false`} as essai,
           null as intervenant
    from anomalies a
    join emplacements e on e.id = a.emplacement_id
    join etages et      on et.id = e.etage_id
    where a.id = ${id}`;
  if (!anomalie) notFound();

  // Ce que la gouvernante a écrit et photographié en signalant : le technicien
  // voit à quoi il vient.
  const messages = await sql<Message[]>`
    select commentaire_id, source, auteur, texte, date_commentaire, decision::text
    from v_fil_commentaires where anomalie_id = ${id} order by date_commentaire`;

  const constat = (
    await sql<{ chemin: string }[]>`
      select chemin from photos_anomalie
      where anomalie_id = ${id} and moment = 'constat' order by prise_le`
  ).map((p) => p.chemin);

  /**
   * Ce qu'il a coché, avec les quantités.
   *
   * Transmis d'un écran à l'autre dans l'adresse — rien n'est écrit en base
   * tant qu'il n'a pas confirmé. Chaque entrée s'écrit « identifiant~quantité »,
   * la quantité valant 1 quand elle n'est pas précisée.
   */
  const lu = pris
    .split(",")
    .filter(Boolean)
    .map((e) => {
      const [ident, q] = e.split("~");
      return { id: ident, qte: Math.max(1, Math.min(99, Number(q) || 1)) };
    });
  const choisis = lu.map((e) => e.id);
  const quantite = new Map(lu.map((e) => [e.id, e.qte]));
  const ecrire = (liste: { id: string; qte: number }[]) =>
    liste.map((e) => (e.qte > 1 ? `${e.id}~${e.qte}` : e.id)).join(",");

  /**
   * Ce qu'on lui propose.
   *
   * Un technicien debout dans une chambre ne tape pas le nom d'un joint : il
   * reconnaît une photo. La liste s'affiche donc d'emblée, et c'est **ce qui a
   * déjà servi pour ce problème-là** qui vient en tête — le catalogue donne le
   * libellé normalisé, les interventions passées donnent le matériel. À défaut,
   * ce qui sort le plus souvent dans l'hôtel. La recherche ne sert qu'à
   * raccourcir une liste, jamais à la faire apparaître.
   */
  const produits = await sql<Produit[]>`
    with deja_servi as (
      select m.produit_id, count(*) as fois
        from mouvements_stock m
        join interventions i on i.id = m.intervention_id
        join anomalies a     on a.id = i.anomalie_id
       where m.type = 'sortie'
         and a.id <> ${id}
         and (
           -- Le même libellé de catalogue : c'est le même problème.
           (${anomalie.catalogue_id}::uuid is not null
             and a.catalogue_id = ${anomalie.catalogue_id}::uuid)
           -- Sinon, la même description mot pour mot.
           or (${anomalie.catalogue_id}::uuid is null
             and a.description = ${anomalie.description})
         )
       group by m.produit_id
    ),
    courant as (
      select m.produit_id, count(*) as fois
        from mouvements_stock m
       where m.type = 'sortie' and m.date_mouvement > now() - interval '18 months'
       group by m.produit_id
    )
    select p.id, p.designation, p.code, p.stock,
           coalesce((select array_agg(x.chemin order by x.principale desc, x.ordre,
                                      x.ajoutee_le)
                       from photos_produit x where x.produit_id = p.id),
                    '{}') as photos
      from v_stock_produits p
      left join deja_servi d on d.produit_id = p.id
      left join courant   c on c.produit_id = p.id
     where p.actif
       and (${q} = '' or p.designation ilike ${"%" + q + "%"} or p.code ilike ${"%" + q + "%"})
     order by (d.produit_id is not null) desc, d.fois desc nulls last,
              p.stock > 0 desc, c.fois desc nulls last, p.designation
     limit 24`;

  const retenus = choisis.length
    ? await sql<Produit[]>`
        select p.id, p.designation, p.code, p.stock,
               coalesce((select array_agg(x.chemin order by x.principale desc, x.ordre,
                                          x.ajoutee_le)
                           from photos_produit x where x.produit_id = p.id),
                        '{}') as photos
        from v_stock_produits p where p.id = any(${choisis}) order by p.designation`
    : [];

  async function enregistrer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");

    const nom = String(donnees.get("intervenant"));
    const articles = String(donnees.get("pris") || "")
      .split(",")
      .filter(Boolean)
      .map((e) => {
        const [ident, q] = e.split("~");
        return { id: ident, qte: Math.max(1, Math.min(99, Number(q) || 1)) };
      });

    const intervenant = (await intervenants()).find((i) => i.nom === nom);
    if (!intervenant) redirect(`/technique/anomalie/${id}`);
    const tournee = await tourneeEnCours(intervenant);

    /**
     * Une anomalie ne se déclare qu'une fois par passage.
     *
     * Rien ne change à l'écran le temps que l'action réponde : on réappuie.
     * Trois appuis ont créé trois déclarations pour la même anomalie, et la
     * gouvernante a eu trois fois la même chose à vérifier. Le bouton se
     * désactive maintenant, mais un second envoi peut encore venir d'un écran
     * resté ouvert : l'insertion ne passe donc que s'il n'y en a pas déjà une
     * dans cette tournée.
     */
    const [intervention] = await sql<{ id: string }[]>`
      insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, saisie_par)
      select ${id}, ${tournee.id}, ${intervenant.utilisateur_id},
             ${intervenant.prestataire_id}, ${profil_.id}
       where not exists (
         select 1 from interventions
          where anomalie_id = ${id} and tournee_id = ${tournee.id})
      returning id`;
    // Déjà déclarée pendant ce passage : on ne double ni la sortie de stock,
    // ni les photos, ni l'avis.
    if (!intervention) {
      redirect(`/technique/${encodeURIComponent(nom)}?fait=${id}#a-${id}` as Route);
    }

    // L'écran grise les articles épuisés, mais un lien recopié ou une réserve
    // vidée entre-temps passerait à travers : on revérifie ici.
    // Une sortie de stock par article, rattachée à cette anomalie : c'est ce
    // qui donnera son coût matériel, sans que le technicien voie un prix.
    for (const article of articles) {
      // On ne sort jamais plus que ce qu'il reste : `least` borne la quantité
      // demandée par la réserve réelle, au moment de l'écriture.
      await sql`
        insert into mouvements_stock (produit_id, type, quantite, utilisateur_id,
                                      prestataire_id, emplacement_id, intervention_id, commentaire)
        select ${article.id}, 'sortie', -least(${article.qte}::numeric, s.stock),
               ${intervenant.utilisateur_id},
               ${intervenant.prestataire_id}, a.emplacement_id, ${intervention.id},
               'Intervention — ' || a.description
        from anomalies a, v_stock_produits s
        where a.id = ${id} and s.id = ${article.id} and s.stock > 0`;
    }

    for (const fichier of donnees.getAll("photos")) {
      if (!(fichier instanceof File)) continue;
      const chemin = await enregistrerPhoto(fichier);
      if (!chemin) continue;
      await sql`
        insert into photos_anomalie (anomalie_id, intervention_id, chemin, moment, prise_par)
        values (${id}, ${intervention.id}, ${chemin}, 'apres', ${profil_.id})`;
    }

    // La sortie peut faire passer un article sous son seuil : c'est le moment
    // de le dire, pas au prochain inventaire.
    if (articles.length > 0) await alerterSiSousSeuil(articles.map((a) => a.id));

    // Le mot du technicien reste attaché à sa décision : la gouvernante le
    // lira en validant, et le sien s'ajoutera dessous sans l'effacer.
    const mot = String(donnees.get("commentaire") ?? "").trim() || null;
    await sql`
      insert into validations (intervention_id, acteur, decision, utilisateur_id,
                               saisie_par, commentaire)
      values (${intervention.id}, 'technicien', 'fait',
              ${intervenant.utilisateur_id}, ${profil_.id}, ${mot})`;

    // On revient sur la liste À L'ENDROIT de ce qu'on vient de déclarer :
    // l'ancre amène l'écran sur la ligne, et elle s'affiche cochée et mise en
    // avant. Revenir en haut d'une liste de douze ne disait pas ce qui avait
    // changé.
    redirect(`/technique/${encodeURIComponent(nom)}?fait=${id}#a-${id}` as Route);
  }

  // L'adresse est construite à la volée : le typage des routes ne couvre pas
  // les paramètres assemblés.
  const lien = (extra: Record<string, string>) => {
    const p = new URLSearchParams({ ...(par ? { par } : {}), q, pris, ...extra });
    return `/technique/anomalie/${id}?${p}` as Route;
  };

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={anomalie.emplacement}
        sous_titre={anomalie.etage}
        retour={par ? `/technique/${encodeURIComponent(par)}` : "/technique"}
      />

      <div className="px-5 py-5 flex flex-col gap-6 grow">
        <p className="font-display font-semibold text-[19px] leading-snug text-pretty">
          {anomalie.description}
        </p>

        {/* Une répétition se dit. Cocher du matériel ici ne sortira rien de la
            réserve — personne n'ira chercher la pièce sur l'étagère — mais
            rien à l'écran ne le laissait deviner, et le stock baissait pour de
            bon. Tout le reste fonctionne comme dans une vraie chambre. */}
        {anomalie.essai && (
          <p className="rounded-xl border border-dashed border-ink-faint/50 bg-surface-muted px-3.5 py-3 text-[14px] leading-snug text-ink-faint text-pretty">
            <span className="font-semibold text-ink">Chambre d’essai.</span> Tout
            se passe comme d’habitude, mais le matériel coché ne sera pas déduit
            du stock et ce passage ne comptera pas dans les chiffres de l’hôtel.
          </p>
        )}

        {/* Le technicien regarde le constat avant de monter : c'est le sujet de
            l'écran, pas une note de bas de page. */}
        <Vignettes
          chemins={constat}
          titre="Photographié au constat"
          ton="text-blue"
          taille={104}
        />

        {messages.length > 0 && (
          <section className="flex flex-col gap-2">
            <h2 className="etiquette">Ce qui a été dit</h2>
            <Fil messages={messages} />
          </section>
        )}

        <section className="flex flex-col gap-2.5">
          <h2 className="etiquette">Matériel utilisé</h2>

          {retenus.length > 0 && (
            <ul className="flex flex-col gap-2">
              {/* Deux lignes, pas une : à 92 px la photo, le nom et les
                  boutons de quantité côte à côte écrasaient le nom sur un mot
                  par ligne. Le nom en haut, les gestes en dessous. */}
              {retenus.map((p) => (
                <li key={p.id} className="carte px-3.5 py-3 flex flex-col gap-2.5">
                  <div className="flex items-center gap-3.5">
                    <PhotoProduit photos={p.photos} designation={p.designation} taille={92} />
                    <span className="flex flex-col grow min-w-0">
                      <span className="text-[17px] font-display font-semibold leading-snug text-pretty">
                        {p.designation}
                      </span>
                      <span className="text-[13.5px] text-ink-faint text-pretty">
                        {p.code} · reste {p.stock} en réserve
                      </span>
                    </span>
                  </div>

                  <div className="flex items-center gap-2">
                  {/* Combien il en a pris. On ne propose jamais plus que la
                      réserve : sortir ce qu'on n'a pas fausserait le stock. */}
                  <span className="flex items-center gap-1 grow">
                    <Link
                      href={lien({
                        pris: ecrire(
                          lu.map((e) =>
                            e.id === p.id ? { ...e, qte: Math.max(1, e.qte - 1) } : e,
                          ),
                        ),
                      })}
                      aria-label="Un de moins"
                      className={`w-10 h-10 rounded-[10px] bg-surface-muted grid place-items-center text-[19px] ${
                        (quantite.get(p.id) ?? 1) <= 1 ? "opacity-35 pointer-events-none" : ""
                      }`}
                    >
                      −
                    </Link>
                    <span className="w-7 text-center font-display font-semibold text-[17px] tabular-nums">
                      {quantite.get(p.id) ?? 1}
                    </span>
                    <Link
                      href={lien({
                        pris: ecrire(
                          lu.map((e) =>
                            e.id === p.id
                              ? { ...e, qte: Math.min(p.stock, e.qte + 1) }
                              : e,
                          ),
                        ),
                      })}
                      aria-label="Un de plus"
                      className={`w-10 h-10 rounded-[10px] bg-surface-muted grid place-items-center text-[19px] ${
                        (quantite.get(p.id) ?? 1) >= p.stock ? "opacity-35 pointer-events-none" : ""
                      }`}
                    >
                      +
                    </Link>
                  </span>
                  <Link
                    href={lien({ pris: ecrire(lu.filter((e) => e.id !== p.id)) })}
                    aria-label="Retirer cet article"
                    className="h-11 shrink-0 px-3.5 rounded-[11px] bg-surface-muted flex items-center gap-2 text-[13.5px] text-ink-soft"
                  >
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#4F4B6B"
                         strokeWidth="2.2" strokeLinecap="round">
                      <path d="M6 12h12" />
                    </svg>
                    Retirer
                  </Link>
                  </div>
                </li>
              ))}
            </ul>
          )}

          {/* Dès qu'un article est retenu, le catalogue se replie : il restait
              ouvert sous la sélection, et repoussait l'enregistrement hors de
              l'écran. On l'ouvre d'un appui pour en ajouter un autre. */}
          <details open={choisis.length === 0} className="flex flex-col gap-2">
            <summary className="list-none carte px-4 py-3 text-[15px] text-plum flex items-center gap-2.5 cursor-pointer">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                   strokeWidth="2.2" strokeLinecap="round" className="shrink-0">
                <path d="M6 12h12" /><path d="M12 6v12" />
              </svg>
              {choisis.length === 0 ? "Choisir le matériel utilisé" : "Ajouter un autre article"}
            </summary>

            <p className="text-[13.5px] text-ink-faint text-pretty pt-2">
              Ce qui a déjà servi pour ce problème vient en premier. Appuyez sur un article
              pour l’ajouter.
            </p>

          {/* La recherche raccourcit la liste ; elle ne sert pas à la faire
              apparaître. Un technicien debout ne tape pas « joint torique ». */}
          <details className="group/chercher">
            <summary className="list-none carte px-4 py-3 text-[15px] text-ink-soft flex items-center gap-2.5 cursor-pointer">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#4F4B6B"
                   strokeWidth="1.9" strokeLinecap="round">
                <circle cx="11" cy="11" r="6.5" /><path d="M16 16l4 4" />
              </svg>
              {q ? `Recherche : « ${q} »` : "Chercher un article"}
            </summary>
            <form method="get" className="flex gap-2 pt-2">
              {par && <input type="hidden" name="par" value={par} />}
              <input type="hidden" name="pris" value={pris} />
              <input
                id="produit"
                name="q"
                defaultValue={q}
                autoComplete="off"
                placeholder="Nom ou code…"
                className="carte grow px-4 h-[48px] text-[16px] placeholder:text-ink-faint"
              />
              <button className="px-4 rounded-card bg-surface border border-line text-[15px]">
                Chercher
              </button>
            </form>
          </details>

          <ul className="flex flex-col gap-1.5">
            {produits
              .filter((p) => !choisis.includes(p.id))
              .map((p) => {
                // Un article qu'on n'a plus ne se prend pas dans la réserve.
                // Il reste visible — sinon on le cherche sans comprendre — mais
                // il ne s'ajoute pas, et il dit pourquoi.
                const epuise = p.stock <= 0;
                const nom_ = (
                  <span className="flex flex-col grow min-w-0">
                    <span className="text-[17px] font-display font-semibold leading-snug text-pretty">
                      {p.designation}
                    </span>
                    <span className={`text-[14px] ${epuise ? "text-red" : "text-ink-faint"}`}>
                      {epuise ? "épuisé — rien en réserve" : `reste ${p.stock} en réserve`}
                    </span>
                  </span>
                );
                return (
                  <li
                    key={p.id}
                    className={`px-3 py-3 rounded-card bg-surface-muted border border-line flex items-center gap-3.5 ${
                      epuise ? "opacity-55" : ""
                    }`}
                  >
                    {/* La photo est À CÔTÉ du lien, pas dedans : arrêter la
                        propagation d'un clic ne suffisait pas — on l'ouvrait
                        en grand ET l'article s'ajoutait. Hors du lien, il n'y
                        a plus rien à arrêter. */}
                    <PhotoProduit photos={p.photos} designation={p.designation} taille={92} />
                    {epuise ? (
                      nom_
                    ) : (
                      <Link
                        href={lien({ pris: ecrire([...lu, { id: p.id, qte: 1 }]) })}
                        className="grow min-w-0 flex items-center gap-3.5 active:opacity-70"
                      >
                        {nom_}
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#453A6E"
                             strokeWidth="2.2" strokeLinecap="round" className="shrink-0">
                          <path d="M6 12h12" /><path d="M12 6v12" />
                        </svg>
                      </Link>
                    )}
                  </li>
                );
              })}
            </ul>
          </details>
        </section>
      </div>

      <div className="px-5 pb-6 pt-2 sticky bottom-0 bg-ground">
        <form action={enregistrer} className="flex flex-col gap-3">
          <input type="hidden" name="intervenant" value={par ?? profil.nom} />
          <input type="hidden" name="pris" value={pris} />
          <ChampCommentaire libelle="Un mot sur ce que vous avez fait" lignes={2} />
          <ChampPhotos libelle="Photographier le travail fait (facultatif)" />
          <BoutonEnvoi
                pendant="Enregistrement…"
                className="w-full h-[54px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]"
              >
            {choisis.length === 0
              ? "C’est fait, sans matériel"
              : `C’est fait — ${choisis.length} article${choisis.length > 1 ? "s" : ""}`}
          </BoutonEnvoi>
        </form>
      </div>
    </main>
  );
}
