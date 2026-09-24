import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { exigerEncadrement } from "@/lib/acces";
import { euros, peutValider } from "@/lib/domaine";
import { Confirmation, Entete, Vide } from "@/app/composants/ui";
import { Filtres, Stat } from "@/app/composants/suivi";

export const dynamic = "force-dynamic";

type Facture = {
  id: string;
  type: string;
  reference: string | null;
  emetteur: string | null;
  date_reference: string;
  periode_debut: string | null;
  periode_fin: string | null;
  montant_ht: number | null;
  montant_ttc: number | null;
  statut: string;
  fichier_url: string | null;
  nb_interventions: number;
};

type Attente = {
  prestataire_id: string;
  prestataire: string;
  nb: number;
  plus_ancienne: number;
};

const STATUT: Record<string, { l: string; fond: string; texte: string }> = {
  a_rapprocher: { l: "À rapprocher", fond: "bg-amber-soft", texte: "text-amber" },
  rapprochee: { l: "Rapprochée", fond: "bg-blue-soft", texte: "text-blue" },
  reglee: { l: "Réglée", fond: "bg-green-soft", texte: "text-green" },
  litige: { l: "Litige", fond: "bg-red-soft", texte: "text-red" },
};

export default async function Factures({
  searchParams,
}: {
  searchParams: Promise<{ filtre?: string; fait?: string }>;
}) {
  const profil = await exigerEncadrement();
  const { filtre = "a_rapprocher", fait } = await searchParams;

  const [c] = await sql<
    { a_rapprocher: number; toutes: number; ht_annee: number; en_attente: number }[]
  >`
    select
      (select count(*) from factures where statut = 'a_rapprocher')::int as a_rapprocher,
      (select count(*) from factures)::int                               as toutes,
      (select coalesce(sum(montant_ht), 0) from factures
        where date_reference >= date_trunc('year', current_date))        as ht_annee,
      (select count(*) from v_interventions_sans_facture)::int           as en_attente`;

  const factures = await sql<Facture[]>`
    select f.id, f.type::text, f.reference,
           coalesce(p.nom, fo.nom) as emetteur,
           f.date_reference, f.periode_debut, f.periode_fin,
           f.montant_ht, f.montant_ttc, f.statut::text, f.fichier_url,
           (select count(*) from facture_interventions fi where fi.facture_id = f.id)::int
             as nb_interventions
    from factures f
    left join prestataires p  on p.id = f.prestataire_id
    left join fournisseurs fo on fo.id = f.fournisseur_id
    where (${filtre} = 'toutes' or f.statut::text = ${filtre})
    order by f.date_reference desc, f.cree_le desc
    limit 40`;

  // Ce qu'un prestataire a fait et qu'aucune facture ne couvre : c'est le
  // filet, et c'est par là qu'on commence quand une facture arrive.
  const attente = await sql<Attente[]>`
    select prestataire_id, prestataire, count(*)::int as nb,
           max(jours_ecoules)::int as plus_ancienne
    from v_interventions_sans_facture
    group by prestataire_id, prestataire
    order by max(jours_ecoules) desc`;




  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre="Factures"
        sous_titre={`${euros(c.ht_annee)} HT cette année`}
        retour="/technique"
      />

      <div className="px-5 py-4 flex flex-col gap-4">
        {fait && <Confirmation quoi={fait} />}
        <div className="flex gap-2">
          <Stat
            valeur={c.a_rapprocher}
            libelle="À rapprocher"
            ton={c.a_rapprocher > 0 ? "alerte" : undefined}
          />
          <Stat valeur={c.en_attente} libelle="Sans facture" />
          <Stat valeur={euros(c.ht_annee)} libelle="HT cette année" />
        </div>

        {/* Ce qu'on attend, par prestataire */}
        {attente.length > 0 && (
          <section className="flex flex-col gap-2">
            <h2 className="etiquette">Passages sans facture</h2>
            <ul className="carte divide-y divide-line">
              {attente.map((a) => (
                <li key={a.prestataire_id} className="px-3.5 py-2.5 flex items-center gap-3">
                  <span className="grow min-w-0">
                    <span className="block text-[14px]">{a.prestataire}</span>
                    <span className="block text-[11.5px] text-ink-faint">
                      {a.nb} anomalie{a.nb > 1 ? "s" : ""} · la plus ancienne remonte à{" "}
                      {a.plus_ancienne} jours
                    </span>
                  </span>
                  <span
                    className={`shrink-0 px-2 py-0.5 rounded-md text-[11px] ${
                      a.plus_ancienne > 45 ? "bg-red-soft text-red" : "bg-surface-muted text-ink-soft"
                    }`}
                  >
                    {a.plus_ancienne > 45 ? "à relancer" : "en attente"}
                  </span>
                </li>
              ))}
            </ul>
          </section>
        )}

        <Filtres
          actif={filtre}
          lien={(f) => `/technique/factures?filtre=${f}` as Route}
          choix={[
            { valeur: "a_rapprocher", libelle: "À rapprocher", nombre: c.a_rapprocher },
            { valeur: "rapprochee", libelle: "Rapprochées" },
            { valeur: "reglee", libelle: "Réglées" },
            { valeur: "toutes", libelle: "Toutes", nombre: c.toutes },
          ]}
        />

        {factures.length === 0 ? (
          <Vide>Aucune facture dans cette catégorie.</Vide>
        ) : (
          <ul className="flex flex-col gap-2">
            {factures.map((f) => {
              const s = STATUT[f.statut] ?? STATUT.a_rapprocher;
              return (
                <li key={f.id}>
                  <Link
                    href={`/technique/facture/${f.id}` as Route}
                    className="carte px-4 py-3.5 flex flex-col gap-1.5 active:bg-surface-muted"
                  >
                    <span className="flex items-start gap-3">
                      <span className="grow min-w-0">
                        <span className="block font-display font-semibold text-[15px]">
                          {f.emetteur ?? "—"}
                        </span>
                        <span className="block text-[11.5px] text-ink-faint">
                          {f.reference ?? "sans numéro"} ·{" "}
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
                      <span className="text-[11.5px] text-ink-faint">
                        {f.nb_interventions === 0
                          ? "aucune intervention rattachée"
                          : `${f.nb_interventions} intervention${f.nb_interventions > 1 ? "s" : ""}`}
                      </span>
                      {f.fichier_url && (
                        <span className="ml-auto text-[11px] text-green">pièce jointe</span>
                      )}
                    </span>
                  </Link>
                </li>
              );
            })}
          </ul>
        )}

        {/* Une facture de prestation naît d'un PASSAGE, jamais ici.
            C'est la règle 16quater — le montant et la pièce se saisissent là
            où on regarde le passage — et c'est ce qui évite d'avoir deux
            écrans pour une seule facture. L'écran des factures les liste et
            renvoie sur le passage ; il n'en crée plus. */}
        {peutValider(profil.role) && (
          <p className="carte px-4 py-3.5 text-[13px] text-ink-soft text-pretty">
            Une facture se saisit depuis le passage qu’elle couvre :{" "}
            <Link
              href={"/technique/historique" as Route}
              className="text-plum underline underline-offset-4"
            >
              ouvrez la journée de l’intervenant
            </Link>{" "}
            et renseignez le montant. De là, elle peut ensuite couvrir d’autres
            journées.
          </p>
        )}
      </div>
    </main>
  );
}
