import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { peutSupprimer, peutValider } from "@/lib/domaine";
import { intervenants, tourneeEnCours } from "@/lib/tournee";
import { deposerRecap } from "@/lib/recap";
import { Confirmation, Entete, Indices, Vide } from "@/app/composants/ui";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { ApercuFil } from "@/app/composants/apercu-fil";
import { RechercheVive } from "@/app/composants/recherche-vive";
import type { Message } from "@/app/composants/fil";

export const dynamic = "force-dynamic";

type Ligne = {
  anomalie_id: string;
  emplacement: string;
  etage: string;
  ordre: number;
  description: string;
  statut: string;
  priorite: string;
  traitee: boolean;
  materiel: string | null;
  photos: number;
  commentaires: number;
};

/**
 * La priorité, lisible d'un coup d'œil.
 *
 * Deux chevrons pour ce qui presse, rien pour le reste : une liste où tout
 * porte un signe ne dit plus rien. C'est ce qui décide par quoi on commence.
 */
const PRESSE: Record<string, { ton: string; titre: string }> = {
  urgente: { ton: "text-red", titre: "Urgent" },
  haute: { ton: "text-amber", titre: "Prioritaire" },
};

/**
 * Une couleur par étage, dans l'ordre du bâtiment.
 *
 * On ne lit pas « 3ème étage » : on reconnaît sa bande. C'est la même idée que
 * la bouteille bleue et la bouteille rouge — la couleur va plus vite que le
 * mot quand on tient le téléphone d'une main.
 */
const TONS = [
  { fond: "bg-[#F6C9CE]", texte: "text-[#7A2B36]" }, // rose
  { fond: "bg-[#C5DCEC]", texte: "text-[#1F4964]" }, // bleu
  { fond: "bg-[#F4E3B2]", texte: "text-[#6B5312]" }, // jaune
  { fond: "bg-[#D6CCEA]", texte: "text-[#43326E]" }, // violet
  { fond: "bg-[#C8E4D2]", texte: "text-[#1F5236]" }, // vert
  { fond: "bg-[#BFE3E2]", texte: "text-[#14524F]" }, // turquoise
  { fond: "bg-[#F8D3BE]", texte: "text-[#8A3F1E]" }, // corail
  { fond: "bg-[#EFD0E2]", texte: "text-[#6A2B55]" }, // mauve
];

function Chevrons({ priorite }: { priorite: string }) {
  const p = PRESSE[priorite];
  if (!p) return null;
  return (
    <span className={`shrink-0 ${p.ton}`} title={p.titre} aria-label={p.titre}>
      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
           strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
        <path d="M6 13l6-5 6 5" />
        <path d="M6 18l6-5 6 5" />
      </svg>
    </span>
  );
}

export default async function Tournee({
  params,
  searchParams,
}: {
  params: Promise<{ intervenant: string }>;
  searchParams: Promise<{ fait?: string; etage?: string; q?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  const nom = decodeURIComponent((await params).intervenant);
  const intervenant = (await intervenants()).find((i) => i.nom === nom);
  if (!intervenant) notFound();

  // Celle qu'on vient de déclarer : elle se retrouve cochée, mise en avant, et
  // l'ancre du navigateur amène l'écran dessus. Sans cela on revenait en haut
  // d'une liste de douze lignes sans savoir ce qui avait changé.
  const { fait, etage, q = "" } = await searchParams;

  const tournee = await tourneeEnCours(intervenant);

  // Ce qu'il a à traiter — filtré par sa spécialité — plus ce qu'il a déjà
  // coché dans cette tournée, pour qu'il voie son avancement.
  const lignes = await sql<Ligne[]>`
    with accompagnement as (
      select a.id,
             (select count(*) from photos_anomalie ph
               where ph.anomalie_id = a.id and ph.moment = 'constat')::int as photos,
             (select count(*) from v_fil_commentaires f
               where f.anomalie_id = a.id)::int as commentaires
        from anomalies a
    )
    select a.id as anomalie_id, e.code as emplacement, et.nom as etage, et.ordre,
           a.description, a.statut::text, a.priorite::text,
           (i.id is not null) as traitee,
           (select string_agg(p.designation || ' × ' || abs(m.quantite), ', ')
              from mouvements_stock m join produits p on p.id = m.produit_id
             where m.intervention_id = i.id and m.type = 'sortie') as materiel,
           ac.photos, ac.commentaires
    from fn_anomalies_pour_intervenant(${nom}) a
    join emplacements e on e.id = a.emplacement_id
    join etages et      on et.id = e.etage_id
    join accompagnement ac on ac.id = a.id
    left join interventions i on i.anomalie_id = a.id and i.tournee_id = ${tournee.id}
    union all
    select a.id, e.code, et.nom, et.ordre, a.description, a.statut::text, a.priorite::text, true,
           (select string_agg(p.designation || ' × ' || abs(m.quantite), ', ')
              from mouvements_stock m join produits p on p.id = m.produit_id
             where m.intervention_id = i.id and m.type = 'sortie'),
           ac.photos, ac.commentaires
    from interventions i
    join anomalies a    on a.id = i.anomalie_id
    join emplacements e on e.id = a.emplacement_id
    join etages et      on et.id = e.etage_id
    join accompagnement ac on ac.id = a.id
    where i.tournee_id = ${tournee.id}
      and a.statut not in ('a_faire','en_cours')
    order by 2, 1`;

  const uniques = [...new Map(lignes.map((l) => [l.anomalie_id, l])).values()];

  // Le fil de chaque anomalie de la tournée : la bulle s'ouvre sur place.
  const fils = uniques.length
    ? await sql<(Message & { anomalie_id: string })[]>`
        select anomalie_id, commentaire_id, source, auteur, texte,
               date_commentaire, decision::text
        from v_fil_commentaires
        where anomalie_id = any(${uniques.map((l) => l.anomalie_id)})
        order by date_commentaire`
    : [];
  const fil = (anomalie: string) => fils.filter((f) => f.anomalie_id === anomalie);

  /**
   * Les étages, en onglets sur le côté.
   *
   * Cent dix-neuf lignes à faire défiler pour trouver le troisième étage, ce
   * n'est pas une liste : c'est un rouleau. Les étages deviennent des onglets
   * verticaux, dans l'ordre du bâtiment, avec ce qui reste à traiter sur
   * chacun. On monte au troisième, on appuie sur « 3ème étage », on a sa
   * tournée de l'étage.
   */
  const etages = [...new Map(uniques.map((l) => [l.etage, l.ordre])).entries()]
    .sort((a, b) => a[1] - b[1])
    .map(([nom_, ordre]) => ({
      nom: nom_,
      ordre,
      reste: uniques.filter((l) => l.etage === nom_ && !l.traitee).length,
    }));

  // Un étage vidé de ses anomalies disparaîtrait de ses propres onglets et on
  // se retrouverait devant une liste vide sans savoir où l'on est : l'onglet
  // choisi reste, même s'il ne reste rien dessus.
  const choisi = etage && etages.some((e) => e.nom === etage) ? etage : null;

  // La recherche porte sur ce qu'on a sous les yeux : la description et le
  // lieu. On cherche « mitigeur » ou « 27 », pas un numéro de référence.
  const terme = q.trim().toLowerCase();
  const correspond = (l: Ligne) =>
    terme === "" ||
    l.description.toLowerCase().includes(terme) ||
    l.emplacement.toLowerCase().includes(terme);

  const vues = uniques.filter(
    (l) => (choisi === null || l.etage === choisi) && correspond(l),
  );

  const faites = vues.filter((l) => l.traitee);
  const restantes = vues.filter((l) => !l.traitee);
  // La clôture porte sur TOUT le passage, pas sur l'étage regardé.
  const faitesEnTout = uniques.filter((l) => l.traitee);

  /**
   * L'ordre du bâtiment, pas l'ordre de l'alphabet.
   *
   * Trier d'abord par priorité mettait l'urgent du cinquième avant le reste du
   * rez-de-chaussée : on redescendait, on remontait. Et trier les lieux par
   * leur nom renvoyait « 4eme étage » — le palier, qui est un lieu comme un
   * autre — après la chambre 39, donc au milieu du troisième.
   *
   * On suit donc l'étage (`ordre`, celui du bâtiment), puis le lieu dans
   * l'étage, puis la priorité pour départager deux lignes du même endroit. On
   * monte une fois, on fait l'étage, on continue. Ce qui est déjà déclaré
   * passe à la fin, barré : c'est de l'avancement, pas du travail.
   */
  const rang: Record<string, number> = { urgente: 0, haute: 1, normale: 2, basse: 3 };
  const parLieu = (a: Ligne, b: Ligne) =>
    a.ordre - b.ordre ||
    a.emplacement.localeCompare(b.emplacement, "fr", { numeric: true }) ||
    (rang[a.priorite] ?? 2) - (rang[b.priorite] ?? 2);

  const ordonnees = [...restantes.sort(parLieu), ...faites.sort(parLieu)];

  const encadre = peutValider(profil.role);
  const supprimable = peutSupprimer(profil.role);

  const aujourdhui = new Date();
  const jourCourt = aujourdhui.toLocaleDateString("fr-FR", { weekday: "short" });

  /**
   * Se déraviser.
   *
   * Tant que la tournée n'est pas rendue, une anomalie cochée peut être
   * décochée : on est encore dans les étages, on a pu se tromper de chambre.
   * La déclaration disparaît entièrement — l'avis, et le matériel qu'elle
   * portait, qui n'a donc pas été utilisé. Le laisser sorti fausserait le
   * stock. Les photos restent attachées au lieu : ce sont des faits.
   */
  async function deselectionner(donnees: FormData) {
    "use server";
    const anomalie = String(donnees.get("anomalie"));
    const [i] = await sql<{ id: string }[]>`
      select i.id from interventions i
      join tournees t on t.id = i.tournee_id
      where i.anomalie_id = ${anomalie} and i.tournee_id = ${tournee.id}
        and t.cloturee_le is null`;
    if (!i) return;
    await sql`delete from mouvements_stock where intervention_id = ${i.id}`;
    await sql`delete from interventions where id = ${i.id}`;
    await sql`
      update anomalies set statut = 'a_faire', maj_le = now()
      where id = ${anomalie} and statut in ('en_cours', 'attente_validation')`;
    revalidatePath(`/technique/${encodeURIComponent(nom)}`);
  }

  /**
   * Supprimer une anomalie sans quitter la liste.
   *
   * Une chambre déclarée de travers se voit en arrivant devant la porte, pas
   * depuis un écran d'administration : il faut pouvoir l'effacer là où on la
   * lit. Trois personnes seulement — Victoria, Sarah P, Miguel — et jamais un
   * technicien : il traite, il ne décide pas de ce qui existe.
   */
  async function supprimer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!peutSupprimer(profil_?.role)) redirect(`/technique/${encodeURIComponent(nom)}` as Route);
    await sql`delete from anomalies where id = ${String(donnees.get("anomalie"))}`;
    revalidatePath(`/technique/${encodeURIComponent(nom)}`);
    redirect(`/technique/${encodeURIComponent(nom)}?fait=supprime` as Route);
  }

  async function cloturer() {
    "use server";
    await sql`update tournees set cloturee_le = now() where id = ${tournee.id}`;
    // Le lot est rendu : le récapitulatif de ce que le technicien déclare part
    // maintenant, pas à une heure fixe. Un mail par anomalie en aurait fait dix.
    await deposerRecap(tournee.id, false);
    // L'accueil, pas /technique : un intervenant n'y a pas accès et serait
    // renvoyé sur cette même tournée, qu'il vient de rendre.
    redirect("/");
  }

  return (
    /* Une coque, pas une page qui défile : l'en-tête et la colonne d'étages
       restent, seule la liste bouge. C'est la seule façon pour les bandes de
       tenir tout le bord de l'écran, du haut jusqu'en bas. */
    <main className="h-dvh overflow-hidden flex flex-col max-w-md mx-auto">
      <Entete
        titre={nom}
        sous_titre="Ce qu’il y a à traiter"
        // Un intervenant n'a pas accès à /technique : l'y renvoyer le
        // ramènerait aussitôt sur cette même page. Pour lui, le filet est
        // l'accueil ; pour l'encadrement, la liste des intervenants.
        retour={encadre ? "/technique/intervenants" : "/"}
      />

      <div className="flex grow min-h-0">
        {/* Les étages, sur tout le bord, dans l'ordre du bâtiment. */}
        {uniques.length > 0 && (
          <nav
            aria-label="Étages"
            className="shrink-0 flex flex-col gap-[3px] py-1.5"
          >
            <Link
              replace
              href={`/technique/${encodeURIComponent(nom)}${q ? `?q=${encodeURIComponent(q)}` : ""}` as Route}
              className={`w-[36px] flex-1 min-h-[40px] rounded-r-[10px] grid place-items-center text-[14px] font-medium ${
                choisi === null ? "bg-ink text-white" : "bg-surface-muted text-ink-faint"
              }`}
              style={{ writingMode: "vertical-rl", rotate: "180deg" }}
            >
              Tout
            </Link>
            {etages.map((e, i) => {
              const ton = TONS[i % TONS.length];
              const actif = choisi === e.nom;
              const p = new URLSearchParams({ etage: e.nom, ...(q ? { q } : {}) });
              return (
                <Link
                  key={e.nom}
                  replace
                  href={`/technique/${encodeURIComponent(nom)}?${p}` as Route}
                  aria-current={actif ? "page" : undefined}
                  className={`flex-1 min-h-[40px] rounded-r-[10px] grid place-items-center text-[14px] ${ton.fond} ${ton.texte} ${
                    actif ? "w-[42px] font-semibold shadow-sm" : "w-[36px] opacity-75"
                  }`}
                  style={{ writingMode: "vertical-rl", rotate: "180deg" }}
                >
                  {/* Le nom court : « 3ème étage » tient mal à la verticale. */}
                  {e.nom.replace(" étage", "").replace("Rez-de-chaussée", "RDC")}
                  {e.reste > 0 && ` · ${e.reste}`}
                </Link>
              );
            })}
          </nav>
        )}

        {/* Seule la liste défile, et de la place sous la dernière ligne : le
            bouton d'ajout flotte au-dessus et masquait ce qui était en bas. */}
        <div
          className={`grow min-h-0 overflow-y-auto pl-3 pr-5 pt-3 flex flex-col gap-4 ${
            encadre ? "pb-24" : "pb-4"
          }`}
        >
        {fait === "supprime" && <Confirmation quoi="supprime" />}

        {/* Le jour, en gros : on ouvre l'écran pour savoir où on en est
            aujourd'hui, et une tournée ne court jamais d'un jour sur l'autre. */}
        <div className="flex items-end gap-3 border-b-[2.5px] border-ink pb-2.5">
          <span className="grow min-w-0">
            <span className="block text-[12.5px] text-ink-faint">
              {aujourdhui.toLocaleDateString("fr-FR", { month: "long", year: "numeric" })}
            </span>
            <span className="flex items-baseline gap-2">
              <span className="font-display font-semibold text-[30px] leading-none">
                {aujourdhui.getDate()}
                <span className="text-[20px] text-ink-soft">.{jourCourt}</span>
              </span>
            </span>
          </span>
          <span className="shrink-0 text-right">
            <span className="block font-display font-semibold text-[19px] tabular-nums">
              {faitesEnTout.length}
              <span className="text-ink-faint">/{uniques.length}</span>
            </span>
            <span className="block text-[11px] text-ink-faint">traitées</span>
          </span>
        </div>

        {/* Chercher plutôt que faire défiler. On tape « mitigeur » ou « 27 » :
            la description et le lieu, rien d'autre — un numéro de référence ne
            se retient pas. La recherche garde l'étage regardé. */}
        {uniques.length > 0 && (
          <RechercheVive
            valeur={q}
            base={`/technique/${encodeURIComponent(nom)}`}
            garde={choisi ? { etage: choisi } : {}}
            placeholder="Chercher une anomalie, une chambre…"
          />
        )}

        {/* L'avancement, dessiné : un chiffre seul ne se lit pas en marchant. */}
        {uniques.length > 0 && (
          <div className="h-[6px] rounded-full bg-surface-muted overflow-hidden">
            <div
              className="h-full rounded-full bg-green transition-[width]"
              style={{ width: `${Math.round((faitesEnTout.length / uniques.length) * 100)}%` }}
            />
          </div>
        )}

        {uniques.length === 0 ? (
          <Vide>Rien à traiter pour {nom} aujourd’hui.</Vide>
        ) : (
            <ul className="flex flex-col">
              {ordonnees.map((l, i) => {
              const vientDEtreFaite = fait === l.anomalie_id;
              const premiereFaite = l.traitee && (i === 0 || !ordonnees[i - 1].traitee);
              return (
                <li key={l.anomalie_id} id={`a-${l.anomalie_id}`} className="scroll-mt-4 relative">
                  {/* La bascule entre ce qui reste et ce qui est fait se voit :
                      sinon la liste paraît mélangée. */}
                  {premiereFaite && restantes.length > 0 && (
                    <p className="etiquette pt-5 pb-2 text-[12px]">Déjà déclarées</p>
                  )}
                  {/* En regardant « Tout », l'étage change en cours de liste :
                      sans un trait, on ne voit pas qu'on a changé de niveau. */}
                  {choisi === null &&
                    (i === 0 ||
                      ordonnees[i - 1].etage !== l.etage ||
                      (l.traitee && !ordonnees[i - 1].traitee)) && (
                      <p className="etiquette pt-4 pb-1.5 text-[12px] text-plum">
                        {l.etage}
                      </p>
                    )}
                  <div
                    className={`flex items-start gap-3 py-3 border-b border-line ${
                      vientDEtreFaite
                        ? "bg-green-soft -mx-2 px-2 rounded-[10px] border-transparent"
                        : ""
                    }`}
                  >
                    {/* La case coche ET décoche : tant que la tournée n'est pas
                        rendue, on peut revenir sur ce qu'on a déclaré. */}
                    {l.traitee ? (
                      <form action={deselectionner} className="shrink-0 mt-[1px]">
                        <input type="hidden" name="anomalie" value={l.anomalie_id} />
                        <button
                          aria-label="Annuler ma déclaration"
                          className="w-[26px] h-[26px] rounded-[7px] bg-plum grid place-items-center active:opacity-70"
                        >
                          <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                               stroke="#fff" strokeWidth="2.8" strokeLinecap="round"
                               strokeLinejoin="round">
                            <path d="M5 12.5l4.5 4.5L19 7.5" />
                          </svg>
                        </button>
                      </form>
                    ) : (
                      <Link
                        href={`/technique/anomalie/${l.anomalie_id}?par=${encodeURIComponent(nom)}`}
                        aria-label="Traiter cette anomalie"
                        className="w-[26px] h-[26px] mt-[1px] shrink-0 rounded-[7px] border-[2px] border-[#C9C5D8] active:bg-plum-soft"
                      />
                    )}

                    <Link
                      href={`/technique/anomalie/${l.anomalie_id}?par=${encodeURIComponent(nom)}`}
                      className="grow min-w-0 flex flex-col gap-1 active:opacity-70"
                    >
                      <span
                        className={`text-[17.5px] font-display font-semibold leading-snug text-pretty ${
                          l.traitee ? "text-ink-faint line-through" : ""
                        }`}
                      >
                        {l.description}
                      </span>
                      {/* Une anomalie ne se montre jamais séparée de son lieu :
                          sinon on croit qu'il y a un lave-vaisselle en 57. */}
                      <span className="flex flex-wrap items-center gap-1.5">
                        <span
                          className={`px-2 py-0.5 rounded-md text-[13px] font-medium ${
                            l.traitee
                              ? "bg-surface-muted text-ink-faint"
                              : "bg-amber-soft text-amber"
                          }`}
                        >
                          {l.emplacement}
                        </span>
                        <span className="text-[12.5px] text-ink-faint">{l.etage}</span>
                        {l.traitee && (
                          <span className="text-[12.5px] text-ink-faint">
                            · {l.materiel ?? "aucun matériel"}
                          </span>
                        )}
                      </span>
                    </Link>

                    <span
                      className={`shrink-0 mt-[1px] flex items-center gap-1.5 ${
                        supprimable && !l.traitee ? "pr-7" : ""
                      }`}
                    >
                      {!l.traitee && <Chevrons priorite={l.priorite} />}
                      <Indices photos={l.photos} eteint={l.traitee} />
                      <ApercuFil messages={fil(l.anomalie_id)} eteint={l.traitee} />
                    </span>
                  </div>

                  {/* Supprimer là où on la lit : une chambre déclarée de
                      travers se voit devant la porte, pas depuis un écran
                      d'administration. Jamais pour un technicien. */}
                  {supprimable && !l.traitee && (
                    <details className="group/sup">
                      {/* Un « Supprimer » écrit sous chacune des cent dix-neuf
                          lignes noie la liste. Trois points au bout de la
                          ligne, et le mot n'apparaît qu'une fois ouvert. */}
                      <summary
                        aria-label="Supprimer cette anomalie"
                        className="list-none cursor-pointer absolute top-[12px] right-0 w-8 h-8 grid place-items-center text-ink-faint group-open/sup:text-red group-open/sup:bg-red-soft rounded-lg"
                      >
                        {/* Une poubelle : tout le monde sait ce que c'est. */}
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"
                             strokeLinejoin="round" aria-hidden>
                          <path d="M4 7h16" />
                          <path d="M9.5 7V5.2A1.2 1.2 0 0110.7 4h2.6A1.2 1.2 0 0114.5 5.2V7" />
                          <path d="M6.5 7l.8 11.3A1.8 1.8 0 009.1 20h5.8a1.8 1.8 0 001.8-1.7L17.5 7" />
                          <path d="M10.5 11v5M13.5 11v5" />
                        </svg>
                      </summary>
                      <div className="ml-[38px] mb-2.5 rounded-card bg-red-soft px-3.5 py-3 flex flex-col gap-2">
                        <p className="text-[12.5px] text-red text-pretty leading-snug">
                          Efface l’anomalie, son fil et ses photos. À réserver à ce qui n’aurait
                          jamais dû être déclaré — une erreur de chambre, un doublon.
                        </p>
                        <form action={supprimer}>
                          <input type="hidden" name="anomalie" value={l.anomalie_id} />
                          <BoutonEnvoi
                            pendant="…"
                            className="h-[40px] w-full rounded-[11px] bg-red text-white font-display font-semibold text-[13.5px]"
                          >
                            Supprimer définitivement
                          </BoutonEnvoi>
                        </form>
                      </div>
                    </details>
                  )}
                </li>
              );
            })}
              {vues.length === 0 && (
                <li className="py-8 text-[14.5px] text-ink-faint text-center text-pretty">
                  {terme
                    ? `Rien qui corresponde à « ${q.trim()} »${choisi ? ` à cet étage` : ""}.`
                    : "Rien à traiter à cet étage."}
                </li>
              )}
            </ul>
        )}
        </div>
      </div>

      {/* Déclarer ce qu'on voit en passant, sans quitter sa tournée. Un
          technicien n'y a pas droit : le catalogue est fermé et la déclaration
          est un geste d'encadrement. */}
      {encadre && (
        <Link
          href={"/gouvernante/declarer" as Route}
          aria-label="Déclarer une anomalie"
          className={`fixed right-5 z-20 w-[58px] h-[58px] rounded-full bg-plum text-white grid place-items-center shadow-lg active:opacity-80 ${
            faitesEnTout.length > 0 ? "bottom-[92px]" : "bottom-6"
          }`}
        >
          <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="2.4" strokeLinecap="round" aria-hidden>
            <path d="M6 12h12" /><path d="M12 6v12" />
          </svg>
        </Link>
      )}

      {faitesEnTout.length > 0 && (
        <div className="px-5 pb-6 pt-2 sticky bottom-0 bg-ground">
          <form action={cloturer}>
            <BoutonEnvoi
              pendant="Clôture…"
              className="w-full h-[58px] rounded-[15px] bg-plum text-white font-display font-semibold text-[18px]"
            >
              Fin d’intervention — {faitesEnTout.length} anomalie
              {faitesEnTout.length > 1 ? "s" : ""}
            </BoutonEnvoi>
          </form>
        </div>
      )}
    </main>
  );
}
