import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { euros, peutValider } from "@/lib/domaine";
import { Entete, Vide } from "@/app/composants/ui";
import { RechercheVive } from "@/app/composants/recherche-vive";

export const dynamic = "force-dynamic";

type Produit = {
  id: string;
  code: string;
  designation: string;
  categorie: string | null;
  prix_unitaire: number | null;
  actif: boolean;
};

type Fournisseur = {
  produit_id: string;
  nom: string;
  contact: string | null;
  email: string | null;
  telephone: string | null;
  reference_fournisseur: string | null;
  prix_indicatif: number | null;
  prefere: boolean;
};

/**
 * Le résumé du catalogue matériel — un produit, sa référence, son prix de
 * référence HT, et ce qu'on sait de qui le fournit.
 *
 * `/stock` sert à travailler le stock du jour ; `/administration/export`
 * sort un tableur. Entre les deux, rien ne répondait à « quel est le prix et
 * le contact de tel article », sans ouvrir sa fiche une par une ni télécharger
 * un fichier pour une seule ligne. Un produit peut avoir plusieurs
 * fournisseurs (règle 15) : ils sont tous là, le préféré en tête.
 *
 * Un produit sans prix n'est pas compté pour zéro (règle 6) : on le dit. Un
 * produit sans fournisseur enregistré aussi — « si ça a été ajouté », pas
 * autrement. Les retirés restent dans la liste, en bas (règle 14ter).
 */
export default async function ResumeProduits({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (!peutValider(profil.role)) redirect("/");

  const { q = "" } = await searchParams;
  const terme = q.trim().toLowerCase();

  const produits = await sql<Produit[]>`
    select p.id, p.code, p.designation, p.categorie, p.prix_unitaire, p.actif
      from produits p
     where ${terme} = ''
        or lower(p.designation) like ${"%" + terme + "%"}
        or lower(p.code) like ${"%" + terme + "%"}
        or lower(coalesce(p.categorie, '')) like ${"%" + terme + "%"}
        or exists (
             select 1 from article_fournisseurs af
             join fournisseurs f on f.id = af.fournisseur_id
            where af.produit_id = p.id and lower(f.nom) like ${"%" + terme + "%"})
     -- Même clé de tri que /stock : sans casse ni accent, pour que l'ordre
     -- ne dépende pas de la collation de l'installation, et les retirés en
     -- bas plutôt que mélangés.
     order by p.actif desc, lower(translate(
       p.designation,
       'ÀÁÂÃÄÅàáâãäåÇçÈÉÊËèéêëÌÍÎÏìíîïÑñÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÝýÿ',
       'AAAAAAaaaaaaCcEEEEeeeeIIIIiiiiNnOOOOOOooooooUUUUuuuuYyy'))`;

  const fournisseurs = produits.length
    ? await sql<Fournisseur[]>`
        select af.produit_id, f.nom, f.contact, f.email, f.telephone,
               af.reference_fournisseur, af.prix_indicatif, af.prefere
          from article_fournisseurs af
          join fournisseurs f on f.id = af.fournisseur_id
         where af.produit_id = any(${produits.map((p) => p.id)})
         order by af.prefere desc, f.nom`
    : [];
  const pour = (id: string) => fournisseurs.filter((f) => f.produit_id === id);

  const sansPrix = produits.filter((p) => p.prix_unitaire === null).length;

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Produits"
        sous_titre={`${produits.length} produit${produits.length > 1 ? "s" : ""} enregistré${
          produits.length > 1 ? "s" : ""
        }`}
        retour="/administration"
      />

      <div className="px-5 py-4 flex flex-col gap-3.5">
        <p className="text-[13px] text-ink-soft text-pretty leading-snug">
          Nom, référence, prix de référence HT et fournisseurs — ce qui est connu de chaque
          article du catalogue matériel. Le détail complet, les mouvements et les photos restent
          sur la fiche du produit, dans Stock.
        </p>

        {sansPrix > 0 && (
          <p className="text-[11.5px] text-amber text-pretty leading-snug">
            {sansPrix} produit{sansPrix > 1 ? "s" : ""} sans prix renseigné.
          </p>
        )}

        <RechercheVive
          valeur={q}
          base="/administration/produits"
          placeholder="Chercher un produit, une référence, un fournisseur…"
        />

        {produits.length === 0 ? (
          <Vide>Rien qui corresponde à « {q.trim()} ».</Vide>
        ) : (
          <ul className="flex flex-col gap-2">
            {produits.map((p) => {
              const fs = pour(p.id);
              return (
                <li
                  key={p.id}
                  className={`carte px-4 py-3.5 flex flex-col gap-2 ${
                    p.actif ? "" : "opacity-60"
                  }`}
                >
                  <div className="flex items-start gap-3">
                    <span className="grow min-w-0 flex flex-col gap-0.5">
                      <span className="flex items-baseline gap-2">
                        <Link
                          href={`/stock/produit/${p.id}` as Route}
                          className="font-display font-semibold text-[15px] text-pretty underline-offset-4 active:underline"
                        >
                          {p.designation}
                        </Link>
                        {!p.actif && (
                          <span className="shrink-0 text-[10.5px] uppercase tracking-[0.06em] text-ink-faint">
                            retiré
                          </span>
                        )}
                      </span>
                      <span className="text-[11.5px] text-ink-faint">
                        {p.code}
                        {p.categorie && ` · ${p.categorie}`}
                      </span>
                    </span>
                    <span className="shrink-0 text-right">
                      {p.prix_unitaire === null ? (
                        <span className="text-[12.5px] text-amber">non renseigné</span>
                      ) : (
                        <span className="font-display font-semibold text-[15px] tabular-nums">
                          {euros(p.prix_unitaire)}
                        </span>
                      )}
                      <span className="block text-[10px] text-ink-faint">HT</span>
                    </span>
                  </div>

                  {fs.length === 0 ? (
                    <p className="text-[12px] text-ink-faint">Aucun fournisseur enregistré.</p>
                  ) : (
                    <ul className="flex flex-col gap-1.5">
                      {fs.map((f, i) => (
                        <li
                          key={i}
                          className="rounded-[10px] bg-surface-muted px-2.5 py-2 flex flex-col gap-0.5"
                        >
                          <span className="flex items-baseline gap-1.5 text-[12.5px]">
                            <span className="font-medium">{f.nom}</span>
                            {f.prefere && (
                              <span className="text-[10px] uppercase tracking-[0.04em] text-plum">
                                préféré
                              </span>
                            )}
                            {f.reference_fournisseur && (
                              <span className="text-ink-faint">· réf. {f.reference_fournisseur}</span>
                            )}
                            {f.prix_indicatif !== null && (
                              <span className="text-ink-faint">· {euros(f.prix_indicatif)}</span>
                            )}
                          </span>
                          {(f.contact || f.email || f.telephone) && (
                            <span className="text-[11.5px] text-ink-faint text-pretty">
                              {[f.contact, f.email, f.telephone].filter(Boolean).join(" · ")}
                            </span>
                          )}
                        </li>
                      ))}
                    </ul>
                  )}
                </li>
              );
            })}
          </ul>
        )}
      </div>
    </main>
  );
}
