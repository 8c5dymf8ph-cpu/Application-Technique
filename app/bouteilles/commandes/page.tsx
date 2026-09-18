import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, suitLesDossiers } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";
import { Filtres } from "@/app/composants/suivi";

export const dynamic = "force-dynamic";

type Commande = {
  id: string;
  reference: number;
  fournisseur: string;
  date_commande: string;
  date_livraison: string | null;
  statut: string;
  montant_ht: number | null;
  montant_ttc: number | null;
  montant_tva: number | null;
  facture_fichier: string | null;
  nb_articles: number;
  articles: string | null;
};

const LIBELLE: Record<string, string> = {
  brouillon: "Brouillon",
  envoyee: "Envoyée",
  recue: "Reçue",
  annulee: "Annulée",
};

const TON: Record<string, string> = {
  brouillon: "bg-surface-muted text-ink-faint",
  envoyee: "bg-amber-soft text-amber",
  recue: "bg-green-soft text-green",
  annulee: "bg-red-soft text-red",
};

export default async function Commandes({
  searchParams,
}: {
  searchParams: Promise<{ filtre?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  // Le suivi des dossiers, les commandes et les rapports sont le travail de
  // l'administration ; la gouvernante déclare, remplace et compte.
  if (!suitLesDossiers(profil.role)) redirect("/bouteilles");
  const { filtre = "encours" } = await searchParams;

  const [c] = await sql<{ encours: number; recues: number; tous: number; ht_annee: number }[]>`
    select
      count(*) filter (where statut in ('brouillon','envoyee'))::int as encours,
      count(*) filter (where statut = 'recue')::int                  as recues,
      count(*)::int                                                  as tous,
      coalesce(sum(montant_ht) filter (
        where date_commande >= date_trunc('year', current_date)), 0)  as ht_annee
    from v_commandes`;

  const commandes = await sql<Commande[]>`
    select id, reference, fournisseur, date_commande, date_livraison, statut::text,
           montant_ht, montant_ttc, montant_tva, facture_fichier,
           nb_articles::int, articles
    from v_commandes
    where (${filtre} = 'tous'
        or (${filtre} = 'encours' and statut in ('brouillon','envoyee'))
        or (${filtre} = 'recue'   and statut = 'recue'))
    order by date_commande desc, reference desc
    limit 50`;

  const fournisseurs = await sql<{ id: string; nom: string }[]>`
    select id, nom from fournisseurs where actif order by nom`;

  async function creer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");
    const [creee] = await sql<{ id: string }[]>`
      insert into commandes (fournisseur_id, saisie_par)
      values (${String(donnees.get("fournisseur"))}, ${profil_.id})
      returning id`;
    redirect(`/bouteilles/commande/${creee.id}` as Route);
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Commandes"
        sous_titre={`${euros(c.ht_annee)} HT commandés cette année`}
        retour="/bouteilles"
      />

      <div className="px-5 py-4 flex flex-col gap-3.5">
        <Filtres
          actif={filtre}
          lien={(f) => `/bouteilles/commandes?filtre=${f}` as Route}
          choix={[
            { valeur: "encours", libelle: "En cours", nombre: c.encours },
            { valeur: "recue", libelle: "Reçues", nombre: c.recues },
            { valeur: "tous", libelle: "Toutes", nombre: c.tous },
          ]}
        />

        {commandes.length === 0 ? (
          <Vide>Aucune commande dans cette catégorie.</Vide>
        ) : (
          <ul className="flex flex-col gap-2">
            {commandes.map((cd) => (
              <li key={cd.id}>
                <Link
                  href={`/bouteilles/commande/${cd.id}` as Route}
                  className="carte px-4 py-3.5 flex flex-col gap-2 active:bg-surface-muted"
                >
                  <div className="flex items-start gap-3">
                    <div className="grow min-w-0">
                      <p className="text-[10.5px] text-ink-faint tabular-nums">
                        Commande n° {cd.reference} ·{" "}
                        {new Date(cd.date_commande).toLocaleDateString("fr-FR")}
                      </p>
                      <p className="font-display font-semibold text-[15.5px]">{cd.fournisseur}</p>
                    </div>
                    <span
                      className={`shrink-0 px-2 py-0.5 rounded-md text-[11px] ${TON[cd.statut]}`}
                    >
                      {LIBELLE[cd.statut]}
                    </span>
                  </div>

                  <p className="text-[12.5px] text-ink-soft leading-snug text-pretty">
                    {cd.articles ?? "Aucun article"}
                  </p>

                  <div className="flex items-baseline gap-3 flex-wrap">
                    <span className="font-display font-semibold text-[16px] tabular-nums">
                      {euros(cd.montant_ttc)}
                      <span className="text-[11px] text-ink-faint font-sans font-normal"> TTC</span>
                    </span>
                    <span className="text-[12px] text-ink-faint tabular-nums">
                      {euros(cd.montant_ht)} HT
                      {cd.montant_tva !== null && ` · TVA ${euros(cd.montant_tva)}`}
                    </span>
                    {cd.facture_fichier && (
                      <span className="ml-auto text-[11.5px] text-green">facture jointe</span>
                    )}
                  </div>
                </Link>
              </li>
            ))}
          </ul>
        )}

        <form action={creer} className="carte px-4 py-4 flex flex-col gap-2.5">
          <h2 className="etiquette">Nouvelle commande</h2>
          <select
            name="fournisseur"
            required
            className="carte px-3 h-[48px] text-[16px] bg-surface-muted"
          >
            {fournisseurs.map((f) => (
              <option key={f.id} value={f.id}>
                {f.nom}
              </option>
            ))}
          </select>
          <button className="h-[50px] rounded-[14px] bg-plum text-white font-display font-semibold text-[15.5px]">
            Créer la commande
          </button>
        </form>
      </div>
    </main>
  );
}
