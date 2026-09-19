import { notFound, redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { intervenants, tourneeEnCours } from "@/lib/tournee";
import { Entete } from "@/app/composants/ui";
import { ChampPhotos, Vignettes } from "@/app/composants/photos";
import { ChampCommentaire, Fil, type Message } from "@/app/composants/fil";
import { enregistrerPhoto } from "@/lib/stockage";

export const dynamic = "force-dynamic";

/** La photo du produit, ou un repère tant qu'elle n'a pas été chargée. */
function VignetteProduit({ photo, taille = 44 }: { photo: string | null; taille?: number }) {
  if (photo) {
    // eslint-disable-next-line @next/next/no-img-element
    return (
      <img
        src={`/photo/${photo}`}
        alt=""
        style={{ width: taille, height: taille }}
        className="shrink-0 rounded-[11px] object-cover border border-line bg-surface-muted"
      />
    );
  }
  return (
    <span
      style={{ width: taille, height: taille }}
      className="shrink-0 rounded-[11px] bg-plum-soft grid place-items-center"
    >
      <svg width={taille * 0.45} height={taille * 0.45} viewBox="0 0 24 24" fill="none"
           stroke="#8B86A8" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
        <rect x="3" y="5" width="18" height="14" rx="2" />
        <circle cx="9" cy="10.5" r="1.8" />
        <path d="M3 16l4.5-4 4 3.5L15.5 11l5.5 5" />
      </svg>
    </span>
  );
}

type Anomalie = {
  id: string;
  description: string;
  catalogue_id: string | null;
  emplacement: string;
  etage: string;
  intervenant: string | null;
};

type Produit = { id: string; designation: string; code: string; stock: number; photo: string | null };

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

  const [anomalie] = await sql<Anomalie[]>`
    select a.id, a.description, a.catalogue_id, e.code as emplacement,
           et.nom as etage, null as intervenant
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

  // Le matériel déjà coché, transmis d'un écran à l'autre : rien n'est écrit
  // en base tant que le technicien n'a pas confirmé.
  const choisis = pris.split(",").filter(Boolean);

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
    select p.id, p.designation, p.code, p.stock, p.photo_principale as photo
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
        select id, designation, code, stock, photo_principale as photo
        from v_stock_produits where id = any(${choisis}) order by designation`
    : [];

  async function enregistrer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");

    const nom = String(donnees.get("intervenant"));
    const articles = String(donnees.get("pris") || "").split(",").filter(Boolean);

    const intervenant = (await intervenants()).find((i) => i.nom === nom);
    if (!intervenant) redirect(`/technique/anomalie/${id}`);
    const tournee = await tourneeEnCours(intervenant);

    const [intervention] = await sql<{ id: string }[]>`
      insert into interventions (anomalie_id, tournee_id, technicien_id, prestataire_id, saisie_par)
      values (${id}, ${tournee.id}, ${intervenant.utilisateur_id},
              ${intervenant.prestataire_id}, ${profil_.id})
      returning id`;

    // L'écran grise les articles épuisés, mais un lien recopié ou une réserve
    // vidée entre-temps passerait à travers : on revérifie ici.
    // Une sortie de stock par article, rattachée à cette anomalie : c'est ce
    // qui donnera son coût matériel, sans que le technicien voie un prix.
    for (const article of articles) {
      await sql`
        insert into mouvements_stock (produit_id, type, quantite, utilisateur_id,
                                      prestataire_id, emplacement_id, intervention_id, commentaire)
        select ${article}, 'sortie', -1, ${intervenant.utilisateur_id},
               ${intervenant.prestataire_id}, a.emplacement_id, ${intervention.id},
               'Intervention — ' || a.description
        from anomalies a
        where a.id = ${id}
          and exists (select 1 from v_stock_produits s
                       where s.id = ${article} and s.stock > 0)`;
    }

    for (const fichier of donnees.getAll("photos")) {
      if (!(fichier instanceof File)) continue;
      const chemin = await enregistrerPhoto(fichier);
      if (!chemin) continue;
      await sql`
        insert into photos_anomalie (anomalie_id, intervention_id, chemin, moment, prise_par)
        values (${id}, ${intervention.id}, ${chemin}, 'apres', ${profil_.id})`;
    }

    // Le mot du technicien reste attaché à sa décision : la gouvernante le
    // lira en validant, et le sien s'ajoutera dessous sans l'effacer.
    const mot = String(donnees.get("commentaire") ?? "").trim() || null;
    await sql`
      insert into validations (intervention_id, acteur, decision, utilisateur_id,
                               saisie_par, commentaire)
      values (${intervention.id}, 'technicien', 'fait',
              ${intervenant.utilisateur_id}, ${profil_.id}, ${mot})`;

    redirect(`/technique/${encodeURIComponent(nom)}`);
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

        <Vignettes chemins={constat} titre="Photographié au constat" ton="text-blue" />

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
              {retenus.map((p) => (
                <li key={p.id} className="carte px-3.5 py-3 flex items-center gap-3">
                  <VignetteProduit photo={p.photo} />
                  <span className="flex flex-col grow min-w-0">
                    <span className="text-[14.5px] leading-snug text-pretty">{p.designation}</span>
                    <span className="text-[11.5px] text-ink-faint">
                      {p.code} · reste {p.stock} en réserve
                    </span>
                  </span>
                  <Link
                    href={lien({ pris: choisis.filter((c) => c !== p.id).join(",") })}
                    aria-label="Retirer"
                    className="w-11 h-11 shrink-0 rounded-[11px] bg-surface-muted grid place-items-center"
                  >
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#4F4B6B"
                         strokeWidth="2.2" strokeLinecap="round">
                      <path d="M6 12h12" />
                    </svg>
                  </Link>
                </li>
              ))}
            </ul>
          )}

          <p className="text-[13.5px] text-ink-faint text-pretty">
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
                const dedans = (
                  <>
                    <VignetteProduit photo={p.photo} taille={40} />
                    <span className="flex flex-col grow min-w-0">
                      <span className="text-[15.5px] leading-snug text-pretty">
                        {p.designation}
                      </span>
                      <span className={`text-[13px] ${epuise ? "text-red" : "text-ink-faint"}`}>
                        {epuise ? "épuisé — rien en réserve" : `reste ${p.stock} en réserve`}
                      </span>
                    </span>
                  </>
                );
                return (
                  <li key={p.id}>
                    {epuise ? (
                      <div className="px-3 py-2.5 rounded-card bg-surface-muted border border-line flex items-center gap-3 opacity-55">
                        {dedans}
                      </div>
                    ) : (
                      <Link
                        href={lien({ pris: [...choisis, p.id].join(",") })}
                        className="px-3 py-2.5 rounded-card bg-surface-muted border border-line flex items-center gap-3 active:bg-plum-soft"
                      >
                        {dedans}
                        <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#453A6E"
                             strokeWidth="2.2" strokeLinecap="round" className="shrink-0">
                          <path d="M6 12h12" /><path d="M12 6v12" />
                        </svg>
                      </Link>
                    )}
                  </li>
                );
              })}
          </ul>
        </section>
      </div>

      <div className="px-5 pb-6 pt-2 sticky bottom-0 bg-ground">
        <form action={enregistrer} className="flex flex-col gap-3">
          <input type="hidden" name="intervenant" value={par ?? profil.nom} />
          <input type="hidden" name="pris" value={pris} />
          <ChampCommentaire libelle="Un mot sur ce que vous avez fait" lignes={2} />
          <ChampPhotos libelle="Photographier le travail fait (facultatif)" />
          <button className="w-full h-[54px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]">
            {choisis.length === 0
              ? "C’est fait, sans matériel"
              : `C’est fait — ${choisis.length} article${choisis.length > 1 ? "s" : ""}`}
          </button>
        </form>
      </div>
    </main>
  );
}
