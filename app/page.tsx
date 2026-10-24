import Link from "next/link";
import type { Route, Viewport } from "next";
import { redirect } from "next/navigation";
import { sql } from "@/lib/db";
import { colonneExiste } from "@/lib/schema";
import { profilActif, type Profil } from "@/lib/profil";
import { saTournee } from "@/lib/acces";
import { chargeParIntervenant, intervenants } from "@/lib/tournee";
import { aujourdhuiLong, peutValider } from "@/lib/domaine";
import { Compteur, Tuile } from "./composants/ui";
import { IconePate } from "./composants/icones-pate";
import { CompteurChoixIntervenant } from "./composants/choix-intervenant";

export const dynamic = "force-dynamic";

// L'accueil commence sur le fond clair, pas sur un en-tête prune : la barre
// d'état prend la même couleur, sinon un bandeau prune flotte au-dessus.
export const viewport: Viewport = { themeColor: "#F4F2F7" };

type Chiffres = {
  a_faire: number;
  en_cours: number;
  attente: number;
  a_valider_lots: number;
  dossiers_bouteille: number;
  sous_seuil: number;
  sans_facture: number;
  a_controler: number;
};

/**
 * Les lieux d'essai.
 *
 * On doit pouvoir déclarer, intervenir et valider pour de faux sans que les
 * compteurs de l'accueil s'en ressentent. Une liste vide n'exclut personne :
 * `= any('{}')` est faux, donc la condition laisse tout passer — ce qui est
 * exactement ce qu'il faut tant que la migration 0008 n'est pas appliquée.
 */
async function lieuxDEssai(): Promise<string[]> {
  if (!(await colonneExiste("emplacements", "essai"))) return [];
  const lignes = await sql<{ id: string }[]>`select id from emplacements where essai`;
  return lignes.map((l) => l.id);
}

async function chiffres(essai: string[]): Promise<Chiffres> {
  const [c] = await sql<Chiffres[]>`
    select
      (select count(*) from anomalies
        where statut = 'a_faire' and not (emplacement_id = any(${essai})))::int  as a_faire,
      (select count(*) from anomalies
        where statut = 'en_cours' and not (emplacement_id = any(${essai})))::int as en_cours,
      (select count(*) from anomalies
        where statut = 'attente_validation'
          and not (emplacement_id = any(${essai})))::int                         as attente,
      (select count(*) from v_tournees where nb_en_attente > 0)::int            as a_valider_lots,
      (select count(*) from v_incidents_bouteille
        where dossier_ouvert and not (emplacement_id = any(${essai})))::int    as dossiers_bouteille,
      (select count(*) from v_stock_produits where sous_seuil)::int             as sous_seuil,
      (select count(*) from v_interventions_sans_facture)::int                  as sans_facture,
      (select count(*) from v_controle_donnees)::int                            as a_controler`;
  return c;
}

export default async function Accueil() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  // Un intervenant vient faire des anomalies : son accueil, c'est sa tournée.
  // Le coût d'un passage, les factures, la valeur du stock ne le regardent pas.
  if (!peutValider(profil.role)) return <AccueilIntervenant profil={profil} />;

  const c = await chiffres(await lieuxDEssai());
  // « À faire » et « En cours » ne sont l'écran de personne : c'est le
  // travail d'UN intervenant, sur sa tournée. La fenêtre demande lequel
  // avant d'y mener, plutôt qu'une liste hotel-wide qui ne ressemble à
  // aucun écran existant.
  const charge = await chargeParIntervenant();
  const nomsIntervenants = (await intervenants()).map((i) => ({
    cle: i.utilisateur_id ?? i.prestataire_id ?? i.nom,
    nom: i.nom,
    specialites: i.specialites,
    charge: charge.get(i.nom) ?? 0,
    compte: i.compte,
  }));

  const gouvernante = peutValider(profil.role);
  const admin = profil.role === "admin" || profil.role === "operations";

  return (
    <main className="fond-studio min-h-dvh px-5 pb-8 pt-8 flex flex-col gap-7 max-w-md mx-auto">
      <div className="flex flex-col gap-[2px]">
        <div className="flex items-center gap-3">
          <p className="text-[14px] text-ink-faint grow min-w-0 truncate">
            Bonjour {profil.nom}
          </p>
        {/* Changer de profil se fait ICI, en haut, pas au bout d'une page.
            L'application est partagée : on la prend des mains de quelqu'un
            d'autre, et la première chose qu'on vérifie est le nom affiché. Le
            lien vivait tout en bas, après les tuiles — il fallait faire
            défiler pour corriger ce qu'on lisait en haut. */}
        <Link
          href={"/profil" as Route}
          aria-label={`Profil : ${profil.nom}. Changer de profil`}
          className="galet-pate shrink-0 flex items-center gap-2 h-11 pl-1.5 pr-3 rounded-full"
        >
          <span className="bille-pate w-8 h-8 rounded-full grid place-items-center font-display font-semibold text-[12.5px] text-white">
            {profil.nom.slice(0, 2).toUpperCase()}
          </span>
          <span className="text-[12.5px] text-ink-soft">Changer</span>
        </Link>
        </div>
        <h1 className="titre-pate font-display font-bold text-[32px] leading-tight tracking-tight">
          Hôtel Parisianer
        </h1>
        <p className="text-[13px] text-ink-faint mt-1">{aujourdhuiLong()}</p>
      </div>

      <div className="grid grid-cols-3 gap-3.5">
        <CompteurChoixIntervenant
          valeur={c.a_faire}
          libelle="À faire"
          ton="text-amber"
          intervenants={nomsIntervenants}
        />
        <CompteurChoixIntervenant
          valeur={c.en_cours}
          libelle="En cours"
          ton="text-blue"
          intervenants={nomsIntervenants}
        />
        <Compteur valeur={c.attente} libelle="À valider" ton="text-plum" href="/gouvernante/valider" />
      </div>

      <nav className="flex flex-col gap-3.5">
        {gouvernante && (
          <Tuile
            href="/gouvernante"
            titre="Gouvernante"
            detail="Déclarer, valider, suivre"
            badge={c.a_valider_lots}
            ton="bg-plum-soft"
            icone={
              <IconePate nom="gouvernante" />
            }
          />
        )}
        <Tuile
          href="/technique"
          titre="Technique"
          detail="Ma tournée du jour"
          badge={c.a_faire}
          ton="bg-green-soft"
          icone={
            <IconePate nom="technique" />
          }
        />
        <Tuile
          href="/bouteilles"
          titre="Bouteilles"
          detail="Parc Purezza et dossiers"
          badge={c.dossiers_bouteille}
          ton="bg-blue-soft"
          icone={
            <IconePate nom="bouteilles" />
          }
        />
        <Tuile
          href="/stock"
          titre="Stock"
          detail="Produits, seuils, inventaire"
          badge={c.sous_seuil}
          ton="bg-amber-soft"
          icone={
            <IconePate nom="stock" />
          }
        />
        {admin && (
          <Tuile
            href="/administration"
            titre="Administration"
            detail="Factures, référentiels, envois"
            badge={c.sans_facture + c.a_controler}
            ton="bg-surface-muted"
            icone={
              <IconePate nom="administration" />
            }
          />
        )}
      </nav>

    </main>
  );
}

/** L'accueil d'un intervenant : son nom, ce qui l'attend, et rien d'autre. */
async function AccueilIntervenant({ profil }: { profil: Profil }) {
  const [c] = await sql<{ a_traiter: number }[]>`
    select count(*)::int as a_traiter
      from fn_anomalies_pour_intervenant(${profil.nom})`;

  return (
    <main className="fond-studio min-h-dvh px-5 pb-8 pt-8 flex flex-col gap-7 max-w-md mx-auto">
      <div className="flex flex-col gap-[2px]">
        <div className="flex items-center gap-3">
          <p className="text-[15px] text-ink-faint grow min-w-0 truncate">
            Bonjour {profil.nom}
          </p>
        {/* Changer de profil se fait ICI, en haut, pas au bout d'une page.
            L'application est partagée : on la prend des mains de quelqu'un
            d'autre, et la première chose qu'on vérifie est le nom affiché. Le
            lien vivait tout en bas, après les tuiles — il fallait faire
            défiler pour corriger ce qu'on lisait en haut. */}
        <Link
          href={"/profil" as Route}
          aria-label={`Profil : ${profil.nom}. Changer de profil`}
          className="galet-pate shrink-0 flex items-center gap-2 h-11 pl-1.5 pr-3 rounded-full"
        >
          <span className="bille-pate w-8 h-8 rounded-full grid place-items-center font-display font-semibold text-[12.5px] text-white">
            {profil.nom.slice(0, 2).toUpperCase()}
          </span>
          <span className="text-[12.5px] text-ink-soft">Changer</span>
        </Link>
        </div>
        <h1 className="titre-pate font-display font-bold text-[32px] leading-tight tracking-tight">
          Hôtel Parisianer
        </h1>
        <p className="text-[14px] text-ink-faint mt-1">{aujourdhuiLong()}</p>
      </div>

      <nav className="flex flex-col gap-3.5">
        <Tuile
          href={saTournee(profil)}
          titre="Ma tournée"
          detail="Traiter mes anomalies, dire le matériel utilisé"
          badge={c.a_traiter}
          ton="bg-green-soft"
          icone={
            <IconePate nom="technique" />
          }
        />
      </nav>

    </main>
  );
}
