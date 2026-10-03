import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { aujourdhuiISO, heureISO, peutSupprimer, peutValider, suitLesDossiers } from "@/lib/domaine";
import { intervenants, tourneeEnCours } from "@/lib/tournee";
import { annulerRecapNonParti, deposerRecap } from "@/lib/recap";
import { Confirmation, Entete, Indices, Vide } from "@/app/composants/ui";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { ApercuFil } from "@/app/composants/apercu-fil";
import { RechercheVive } from "@/app/composants/recherche-vive";
import { AvisReprise, type Compteur } from "@/app/composants/avis-reprise";
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
  /**
   * La gouvernante l'a remise « en cours » ou « à refaire » sur un passage
   * déjà rendu (migration 0034) : `traitee` seul ne le distingue plus d'une
   * anomalie vraiment terminée — c'est ce champ qui porte la différence, posé
   * en JS une fois `tournee` connu (voir le calcul de `uniques`).
   */
  aReprendre: boolean;
  /** Le dernier avis posé sur l'intervention liée — voir `aReprendre`. */
  dernier_acteur: string | null;
  materiel: string | null;
  photos: number;
  commentaires: number;
};

/**
 * L'adresse de la liste, en gardant la journée saisie.
 *
 * Au niveau du MODULE, pas dans le composant. Une action serveur qui se
 * referme sur une fonction déclarée à côté d'elle ne se sérialise pas : Next
 * essaie de l'envoyer au navigateur et l'action ne part jamais — « Functions
 * cannot be passed directly to Client Components ». Le typage n'en dit rien,
 * et l'écran se tait : ici, « Reprendre le passage » ne faisait simplement
 * rien. C'est la même règle que 7undecies, du côté des fonctions ordinaires.
 */
function versLaListe(
  nom: string,
  jour: string | undefined,
  extra: Record<string, string> = {},
) {
  const p = new URLSearchParams({ ...(jour ? { jour } : {}), ...extra });
  return `/technique/${encodeURIComponent(nom)}${p.size ? `?${p}` : ""}`;
}

/**
 * Les deux phrases de `AvisReprise`, composées en UNE chaîne chacune.
 *
 * Un premier essai les écrivait en JSX, mot à mot, avec des accords au
 * milieu (`{n > 1 ? "s" : ""}`) : chaque fragment devient son propre nœud
 * texte dans le DOM, et un copier-coller (constaté sur téléphone) insère un
 * espace entre deux nœuds voisins que rien ne sépare dans le texte voulu —
 * « validée s », « ont   déjà ». Composer la phrase ENTIÈRE côté serveur,
 * comme une seule chaîne, règle ça à la racine : un seul nœud texte, aucune
 * frontière où un espace pourrait s'inviter.
 */
function phraseValidees(n: number): string {
  const pluriel = n > 1;
  return (
    `${n} anomalie${pluriel ? "s" : ""} déjà validée${pluriel ? "s" : ""} par la gouvernante — ` +
    `décision définitive, ${pluriel ? "elles ne reviennent" : "elle ne revient"} pas ici.`
  );
}

function phraseAReprendre(n: number): string {
  const pluriel = n > 1;
  return (
    `${n} anomalie${pluriel ? "s" : ""} renvoyée${pluriel ? "s" : ""} par la gouvernante (à ` +
    `refaire / en cours) : décochée${pluriel ? "s" : ""} pour être retraitée${pluriel ? "s" : ""}. ` +
    `Sans action, ${pluriel ? "elles restent" : "elle reste"} simplement à faire. Recoche ` +
    `« C'est fait » pour ajouter un nouvel avis, sans effacer le sien.`
  );
}

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
  searchParams: Promise<{
    fait?: string;
    etage?: string;
    q?: string;
    rendre?: string;
    jour?: string;
    vue?: string;
  }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  const nom = decodeURIComponent((await params).intervenant);
  const intervenant = (await intervenants()).find((i) => i.nom === nom);
  if (!intervenant) notFound();

  // Celle qu'on vient de déclarer : elle se retrouve cochée, mise en avant, et
  // l'ancre du navigateur amène l'écran dessus. Sans cela on revenait en haut
  // d'une liste de douze lignes sans savoir ce qui avait changé.
  const { fait, etage, q = "", rendre, jour, vue } = await searchParams;

  /**
   * Saisir un passage d'un autre jour.
   *
   * Miguel et Sarah P reprennent de l'historique : un passage d'il y a trois
   * semaines se saisit à SA date, sinon il arrive daté d'aujourd'hui et la
   * facture ne se rapproche plus (règle 16). Le reste de l'écran ne change
   * pas d'un mot — mêmes étages, même liste, même « C'est fait », même
   * matériel. Un passage passé est un passage.
   *
   * Un technicien ne date pas son propre passage : il vient aujourd'hui.
   */
  const passe =
    jour && /^\d{4}-\d{2}-\d{2}$/.test(jour) && suitLesDossiers(profil.role)
      ? jour
      : undefined;
  const historique = passe !== undefined && passe !== aujourdhuiISO();

  const tournee = await tourneeEnCours(intervenant, passe);

  /** Le suffixe à recoller sur chaque lien de l'écran, pour ne pas perdre le jour. */
  const jourEnPlus = historique ? `jour=${passe}` : "";

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
           (select v.acteur::text from validations v
             where v.intervention_id = i.id order by v.decide_le desc limit 1) as dernier_acteur,
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
           (select v.acteur::text from validations v
             where v.intervention_id = i.id order by v.decide_le desc limit 1),
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
      -- Une anomalie VALIDÉE n'a plus rien à faire ici : la gouvernante a
      -- tranché, pour de bon (règle 11 — « validée » ne revient jamais en
      -- arrière, contrairement à « en cours »/« à refaire »). La garder
      -- cochée-barrée dans « Ce qu'il y a à traiter » aux côtés des
      -- anomalies du jour laissait croire qu'elle avait encore un rapport
      -- avec le travail en cours. Elle reste lisible ailleurs — fiche,
      -- historique — juste plus sur cet écran de travail.
      and a.statut not in ('a_faire','en_cours','validee')
    order by 2, 1`;

  /**
   * `traitee` seul ne distingue plus deux cas très différents depuis la
   * 0034 : une anomalie vraiment terminée (plus rien à faire), et une que
   * la gouvernante vient de renvoyer — qui doit au contraire redevenir
   * actionnable, comme si elle n'avait jamais été cochée, avec juste un mot
   * sur pourquoi elle revient.
   *
   * Deux décisions renvoient ainsi le travail, pas une seule : « remise en
   * cours » (statut `en_cours`) ET « à refaire » (statut `a_faire` — c'est
   * le même renvoi que pour une anomalie jamais traitée, règle 3).
   *
   * Le signal n'est PAS `tournee.cloturee_le` : un premier essai testait
   * « passage encore fermé », et ça se défaisait au pire moment — dès que
   * « Reprendre le passage » est réellement pressé (`cloturee_le` repasse à
   * null), le signal disparaissait et l'anomalie revenait cochée-barrée,
   * EXACTEMENT le bug qu'il corrigeait, un cran plus loin dans le parcours.
   * Le bon signal est « qui a parlé en dernier sur cette intervention » :
   * tant que le dernier avis vient de la gouvernante, il reste à traiter —
   * que le passage soit encore fermé, tout juste repris, ou refermé sans
   * qu'on y ait touché. Dès que le technicien redéclare, son avis devient
   * le dernier, et l'anomalie redevient cochée normalement.
   * On le calcule une fois ici, `tournee` connu, et tout le reste de
   * l'écran (tri, regroupement, affichage) suit `traitee` sans plus s'en
   * soucier.
   */
  const uniques = [...new Map(lignes.map((l) => [l.anomalie_id, l])).values()].map((l) => {
    const aReprendre =
      (l.statut === "en_cours" || l.statut === "a_faire") && l.dernier_acteur === "gouvernante";
    return { ...l, aReprendre, traitee: l.traitee && !aReprendre };
  });
  const nbAReprendre = uniques.filter((l) => l.aReprendre).length;
  const nbARefaire = uniques.filter((l) => l.aReprendre && l.statut === "a_faire").length;
  const nbEnCoursGouvernante = uniques.filter(
    (l) => l.aReprendre && l.statut === "en_cours",
  ).length;

  /**
   * Combien d'anomalies de CE passage sont validées — donc absentes des deux
   * requêtes ci-dessus (règle 11 : « validée » ne revient jamais en arrière).
   * Reprendre le passage ne les ramène jamais : sa décision est un fait. Sans
   * ce chiffre, elles disparaissaient de l'écran sans un mot — on avait
   * déclaré quatre choses le matin, on n'en revoyait que trois en reprenant,
   * et rien ne disait où était passée la quatrième.
   */
  const [{ n: nbValidees }] = await sql<{ n: number }[]>`
    select count(*)::int as n
      from interventions i
      join anomalies a on a.id = i.anomalie_id
     where i.tournee_id = ${tournee.id} and a.statut = 'validee'`;

  // Le petit récapitulatif de la fenêtre d'avis : ce que la gouvernante a
  // décidé sur ce passage, compté une fois ici — la fenêtre n'a plus qu'à
  // l'afficher.
  const compteursAvis: Compteur[] = [
    { label: "VALIDÉES", valeur: nbValidees, couleur: "green" as const },
    { label: "EN COURS", valeur: nbEnCoursGouvernante, couleur: "amber" as const },
    { label: "À REFAIRE", valeur: nbARefaire, couleur: "red" as const },
  ].filter((c) => c.valeur > 0);
  const messagesAvis = [
    nbValidees > 0 ? phraseValidees(nbValidees) : null,
    nbAReprendre > 0 ? phraseAReprendre(nbAReprendre) : null,
  ].filter((m): m is string => m !== null);

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

  /**
   * Ne voir QUE ce qu'on a déclaré.
   *
   * Ce qui est coché passe en bas de la liste — c'est de l'avancement, pas du
   * travail (14sexies) — mais sur cent dix-neuf lignes, le relire demandait de
   * tout faire défiler, et on rend son lot sans avoir revu ce qu'on rend. Le
   * compteur du haut bascule la liste ; le même appui la ramène.
   */
  const vues = uniques.filter(
    (l) =>
      (choisi === null || l.etage === choisi) &&
      correspond(l) &&
      (vue !== "faites" || l.traitee),
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

  /**
   * Celle qu'on vient de déclarer reste À SA PLACE.
   *
   * Ce qui est coché passe à la fin — c'est de l'avancement, pas du travail.
   * Mais le renvoi porte son ancre : en la déplaçant tout en bas, l'écran
   * s'ouvrait EN BAS de cent dix-neuf lignes, et il fallait tout remonter pour
   * reprendre. On la laisse donc où elle était le temps de ce retour : cochée,
   * barrée, sur fond vert, au milieu de ce qui reste — c'est exactement ce
   * qu'on veut voir. Au chargement suivant elle rejoint les autres.
   */
  const vientDeDeclarer = Boolean(fait && uniques.some((l) => l.anomalie_id === fait));
  const ordonnees = vientDeDeclarer
    ? [...vues].sort(
        (a, b) =>
          Number(a.traitee && a.anomalie_id !== fait) -
            Number(b.traitee && b.anomalie_id !== fait) || parLieu(a, b),
      )
    : [...restantes.sort(parLieu), ...faites.sort(parLieu)];

  const encadre = peutValider(profil.role);
  const supprimable = peutSupprimer(profil.role);

  // Le jour affiché en grand est celui du PASSAGE, pas celui de l'horloge.
  // Saisir un passage du 3 septembre en lisant « 23.mar » en haut de l'écran,
  // c'est se tromper de journée sans s'en apercevoir.
  //
  // Ancré à midi, dans les deux cas : un `new Date()` brut, formaté sans
  // préciser le fuseau, lit l'horloge UTC du serveur — entre 22h et minuit
  // UTC (minuit à 2h du matin heure française), le jour affiché reculait
  // d'un jour entier. `aujourdhuiISO()` calcule le bon jour en heure de
  // Paris ; l'ancrer à midi, comme le fait déjà le cas historique, met le
  // reste de l'écran (qui lit `aujourdhui` sans fuseau explicite) à l'abri
  // du même piège.
  const aujourdhui = new Date(`${historique ? passe : aujourdhuiISO()}T12:00:00`);
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
    if (!peutSupprimer(profil_?.role)) redirect(versLaListe(nom, passe) as Route);
    await sql`delete from anomalies where id = ${String(donnees.get("anomalie"))}`;
    revalidatePath(`/technique/${encodeURIComponent(nom)}`);
    redirect(versLaListe(nom, passe, { fait: "supprime" }) as Route);
  }

  async function cloturer() {
    "use server";
    await sql`
      update tournees set cloturee_le = now()
       where id = ${tournee.id} and cloturee_le is null`;
    // Le lot est rendu : le récapitulatif de ce que le technicien déclare part
    // maintenant, pas à une heure fixe. Un mail par anomalie en aurait fait dix.
    // Un seul par passage, et un seul passage par jour : c'est ce qui borne le
    // nombre de messages, pas une heure d'envoi.
    await deposerRecap(tournee.id, false);
    // L'accueil, pas /technique : un intervenant n'y a pas accès et serait
    // renvoyé sur cette même tournée, qu'il vient de rendre.
    redirect("/");
  }

  /**
   * Reprendre un passage rendu trop tôt.
   *
   * C'est la même journée, donc le même passage : rien n'est recréé. Ce que la
   * gouvernante n'a pas encore tranché lui est retiré (`tg_reouverture_tournee`)
   * — elle ne doit pas valider un travail qu'il est en train de reprendre — et
   * le récapitulatif qui n'était pas encore parti est retiré de la file.
   */
  async function reprendre() {
    "use server";
    await sql`
      update tournees set cloturee_le = null
       where id = ${tournee.id} and cloturee_le is not null`;
    const retire = await annulerRecapNonParti(tournee.id);
    redirect(
      versLaListe(nom, passe, {
        fait: retire ? "passage-repris" : "passage-repris-mail-parti",
      }) as Route,
    );
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
              href={`/technique/${encodeURIComponent(nom)}${
                new URLSearchParams({ ...(q ? { q } : {}), ...(historique ? { jour: passe! } : {}) }).size
                  ? `?${new URLSearchParams({ ...(q ? { q } : {}), ...(historique ? { jour: passe! } : {}) })}`
                  : ""
              }` as Route}
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
              const p = new URLSearchParams({
                etage: e.nom,
                ...(q ? { q } : {}),
                ...(historique ? { jour: passe! } : {}),
              });
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
          className="grow min-h-0 overflow-y-auto pl-3 pr-5 pt-3 pb-4 flex flex-col gap-4"
        >
        {fait === "supprime" && <Confirmation quoi="supprime" />}
        {fait?.startsWith("passage-repris") && <Confirmation quoi={fait} />}

        {/* On ne saisit pas un passage d'il y a trois semaines en croyant être
            aujourd'hui. Le bandeau le dit, et il est de la couleur d'un
            avertissement : tout ce qui sera coché ici portera CETTE date. */}
        {historique && (
          <p className="rounded-card bg-amber-soft px-4 py-3 text-[13px] text-amber text-pretty">
            <strong>Passage du {aujourdhui.toLocaleDateString("fr-FR", {
              weekday: "long",
              day: "numeric",
              month: "long",
              year: "numeric",
            })}.</strong>{" "}
            Tout ce que vous cochez ici sera daté de ce jour-là — le matériel
            sorti comme les déclarations. Aucun récapitulatif ne part avant que
            vous ne rendiez le passage.
          </p>
        )}

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
          {/* Le compteur est un bouton : ce qu'on a déclaré est en bas de
              cent dix-neuf lignes, et le relire demandait de tout faire
              défiler. Un appui ne montre que ça ; le même appui revient. */}
          {faitesEnTout.length > 0 ? (
            <Link
              replace
              href={
                `/technique/${encodeURIComponent(nom)}?${new URLSearchParams({
                  ...(choisi ? { etage: choisi } : {}),
                  ...(q ? { q } : {}),
                  ...(historique ? { jour: passe! } : {}),
                  ...(vue === "faites" ? {} : { vue: "faites" }),
                })}` as Route
              }
              className={`shrink-0 flex items-center gap-1.5 rounded-[11px] px-2.5 py-1.5 border ${
                vue === "faites"
                  ? "bg-green-soft border-green/30"
                  : "bg-surface border-line"
              }`}
              aria-label={
                vue === "faites"
                  ? "Revoir tout ce qu’il y a à traiter"
                  : "Ne voir que ce que j’ai déclaré"
              }
            >
              {/* Un chiffre seul ne ressemble pas à un bouton : on ne sait pas
                  qu'on peut appuyer dessus. Un mot et un œil le disent. */}
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                   stroke="currentColor" strokeWidth="1.9" strokeLinecap="round"
                   strokeLinejoin="round" aria-hidden
                   className={vue === "faites" ? "text-green" : "text-ink-faint"}>
                {vue === "faites" ? (
                  <>
                    <path d="M4 12h16" />
                    <path d="M4 6h16" />
                    <path d="M4 18h16" />
                  </>
                ) : (
                  <>
                    <path d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6-10-6-10-6z" />
                    <circle cx="12" cy="12" r="2.6" />
                  </>
                )}
              </svg>
              <span className="text-right">
                <span
                  className={`block font-display font-semibold text-[17px] leading-none tabular-nums ${
                    vue === "faites" ? "text-green" : ""
                  }`}
                >
                  {faitesEnTout.length}
                  <span className="text-ink-faint">/{uniques.length}</span>
                </span>
                <span className="block text-[10.5px] text-ink-faint leading-tight pt-0.5">
                  {vue === "faites" ? "tout revoir" : "voir mes déclarées"}
                </span>
              </span>
            </Link>
          ) : (
            <span className="shrink-0 text-right">
              <span className="block font-display font-semibold text-[19px] tabular-nums">
                {faitesEnTout.length}
                <span className="text-ink-faint">/{uniques.length}</span>
              </span>
              <span className="block text-[11px] text-ink-faint">traitées</span>
            </span>
          )}
        </div>

        {/* Chercher plutôt que faire défiler. On tape « mitigeur » ou « 27 » :
            la description et le lieu, rien d'autre — un numéro de référence ne
            se retient pas. La recherche garde l'étage regardé. */}
        {/* Chercher, et déclarer, sur la même ligne. Le « + » flottait dans
            le coin bas-droit, par-dessus la liste : il masquait la dernière
            ligne, le pouce l'attrapait en faisant défiler, et il n'a rien à
            voir avec le geste du bas de l'écran, qui est « j'ai fini ». */}
        {uniques.length > 0 && (
          <div className="flex items-center gap-2">
            <span className="grow min-w-0">
              <RechercheVive
                valeur={q}
                base={`/technique/${encodeURIComponent(nom)}`}
                garde={choisi ? { etage: choisi } : {}}
                placeholder="Chercher une anomalie, une chambre…"
              />
            </span>
            {encadre && (
              <Link
                href={
                  (historique
                    ? `/gouvernante/declarer?jour=${passe}`
                    : "/gouvernante/declarer") as Route
                }
                aria-label="Déclarer une anomalie"
                className="shrink-0 w-12 h-12 rounded-[13px] bg-plum text-white grid place-items-center"
              >
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                     strokeWidth="2.4" strokeLinecap="round" aria-hidden>
                  <path d="M6 12h12" /><path d="M12 6v12" />
                </svg>
              </Link>
            )}
          </div>
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

        {/* Ce que la gouvernante a décidé pendant qu'on avait le dos tourné
            ne se glisse plus dans le fil de la page, à lire ou pas selon
            qu'on fait défiler : une fenêtre s'ouvre d'elle-même, à fermer
            sur « Compris ». `key` force une nouvelle instance — donc une
            nouvelle ouverture — à chaque arrivée sur l'écran tant qu'il y a
            quelque chose à dire ; sans décompte à montrer, pas de fenêtre. */}
        {messagesAvis.length > 0 && (
          <AvisReprise
            key={`avis-${tournee.id}-${nbValidees}-${nbAReprendre}`}
            compteurs={compteursAvis}
            messages={messagesAvis}
          />
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
                        rendue, on peut revenir sur ce qu'on a déclaré. Une fois
                        rendue, ce n'est plus vrai — la croix ne ferait plus rien
                        (`deselectionner` exige une tournée ouverte) — et une
                        anomalie en attente_validation n'est de toute façon pas
                        « finie » comme le reste : montrer le même coché-plum que
                        ce qui est réellement terminé laissait croire qu'il n'y
                        avait plus rien à attendre, alors que c'est l'avis de la
                        gouvernante qui manque encore. */}
                    {l.statut === "attente_validation" ? (
                      <span
                        aria-label="En attente de l'avis de la gouvernante"
                        title="En attente de l'avis de la gouvernante"
                        className="w-[26px] h-[26px] mt-[1px] shrink-0 rounded-[7px] bg-amber-soft grid place-items-center"
                      >
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                             className="text-amber" stroke="currentColor" strokeWidth="2.4"
                             strokeLinecap="round" strokeLinejoin="round">
                          <circle cx="12" cy="12" r="9" />
                          <path d="M12 7v5l3 3" />
                        </svg>
                      </span>
                    ) : l.traitee ? (
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
                        href={`/technique/anomalie/${l.anomalie_id}?par=${encodeURIComponent(nom)}${
                          historique ? `&jour=${passe}` : ""
                        }`}
                        aria-label="Traiter cette anomalie"
                        className="w-[26px] h-[26px] mt-[1px] shrink-0 rounded-[7px] border-[2px] border-[#C9C5D8] active:bg-plum-soft"
                      />
                    )}

                    <Link
                      href={`/technique/anomalie/${l.anomalie_id}?par=${encodeURIComponent(nom)}${
                          historique ? `&jour=${passe}` : ""
                        }`}
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
                        {l.statut === "attente_validation" && (
                          <span className="text-[12.5px] text-amber font-medium">
                            · en attente de l’avis de la gouvernante
                          </span>
                        )}
                        {l.aReprendre && (
                          <span className="text-[12.5px] text-blue font-medium">
                            ·{" "}
                            {l.statut === "a_faire"
                              ? "à refaire, d’après la gouvernante"
                              : "remise en cours par la gouvernante"}
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

      {/* Rendre son lot, en deux temps.
          « Fin d'intervention » envoie un message, et c'est irréversible pour
          qui le reçoit : un appui de trop en début de journée, et le
          récapitulatif annonce deux anomalies sur douze. Un décompte ferait
          attendre sans rien apprendre ; ce qui empêche l'erreur, c'est de VOIR
          ce qui part et à qui. Et puisqu'un passage se reprend maintenant — même
          jour, même lot — l'erreur ne coûte plus une journée. */}
      {tournee.cloturee_le ? (
        <div className="px-5 pb-6 pt-2 sticky bottom-0 bg-ground flex flex-col gap-2">
          <p className="text-[13px] text-ink-faint text-pretty">
            Passage rendu à {heureISO(tournee.cloturee_le)}. Si tu reviens
            aujourd’hui, reprends-le : c’est la même journée,
            donc le même passage.
          </p>
          <form action={reprendre}>
            <BoutonEnvoi
              pendant="Reprise…"
              className="w-full h-[52px] rounded-[15px] border-[1.5px] border-plum text-plum font-display font-semibold text-[16px]"
            >
              Reprendre le passage
            </BoutonEnvoi>
          </form>
        </div>
      ) : faitesEnTout.length > 0 ? (
        rendre ? (
          /* Un appui de trop envoie un message irréversible pour qui le
             reçoit : rien ne doit permettre de glisser dessus sans le voir.
             Au milieu de l'écran, par-dessus tout, impossible à manquer ni
             à confondre avec un autre bouton de la page. */
          <div className="fixed inset-0 z-50 bg-black/60 grid place-items-center p-5">
            <div className="w-full max-w-md flex flex-col gap-3">
              <div className="rounded-card bg-surface px-4 py-3.5 flex flex-col gap-2">
                <p className="font-display font-semibold text-[16px]">
                  Tu as fini pour aujourd’hui ?
                </p>
                {/* Ce qui part, nommé. Un compte ne dit pas ce qu'on rend :
                    on relit les lignes, pas un chiffre. La liste défile dans
                    elle-même pour ne pas repousser les deux boutons hors de
                    l'écran. */}
                <ul className="max-h-[34dvh] overflow-y-auto flex flex-col gap-1 -mx-1 px-1">
                  {faitesEnTout.map((l) => (
                    <li key={l.anomalie_id} className="flex items-baseline gap-2">
                      <span className="shrink-0 px-1.5 py-0.5 rounded-md bg-surface-muted text-ink-soft text-[11px]">
                        {l.emplacement}
                      </span>
                      <span className="grow min-w-0 text-[12.5px] leading-snug text-pretty">
                        {l.description}
                      </span>
                    </li>
                  ))}
                </ul>
                <p className="text-[13.5px] text-ink-faint text-pretty">
                  {faitesEnTout.length} anomalie{faitesEnTout.length > 1 ? "s" : ""}{" "}
                  déclarée{faitesEnTout.length > 1 ? "s" : ""} faite
                  {faitesEnTout.length > 1 ? "s" : ""}
                  {uniques.length - faitesEnTout.length > 0
                    ? `, ${uniques.length - faitesEnTout.length} encore à traiter`
                    : ""}
                  . Le récapitulatif part tout de suite, et la gouvernante reçoit
                  le lot à vérifier.
                </p>
              </div>
              <div className="flex gap-2.5">
                <Link
                  replace
                  href={`/technique/${encodeURIComponent(nom)}${
                new URLSearchParams({ ...(q ? { q } : {}), ...(historique ? { jour: passe! } : {}) }).size
                  ? `?${new URLSearchParams({ ...(q ? { q } : {}), ...(historique ? { jour: passe! } : {}) })}`
                  : ""
              }` as Route}
                  className="flex-1 h-[52px] rounded-[15px] border-[1.5px] border-line bg-surface text-ink-faint font-display font-semibold text-[16px] grid place-items-center active:opacity-70"
                >
                  Pas encore
                </Link>
                <form action={cloturer} className="flex-1">
                  <BoutonEnvoi
                    pendant="Clôture…"
                    className="w-full h-[52px] rounded-[15px] bg-plum text-white font-display font-semibold text-[16px]"
                  >
                    Oui, j’ai fini
                  </BoutonEnvoi>
                </form>
              </div>
            </div>
          </div>
        ) : (
          <div className="px-5 pb-6 pt-2 sticky bottom-0 bg-ground">
            <Link
              replace
              href={
                `/technique/${encodeURIComponent(nom)}?${new URLSearchParams({
                  rendre: "1",
                  ...(q ? { q } : {}),
                  ...(historique ? { jour: passe! } : {}),
                })}` as Route
              }
              className="w-full h-[58px] rounded-[15px] bg-plum text-white font-display font-semibold text-[18px] grid place-items-center active:opacity-80"
            >
              Fin d’intervention — {faitesEnTout.length} anomalie
              {faitesEnTout.length > 1 ? "s" : ""}
            </Link>
          </div>
        )
      ) : null}
    </main>
  );
}
