import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { exigerEncadrement } from "@/lib/acces";
import { peutValider, jourISO, aujourdhuiISO, euros } from "@/lib/domaine";
import { enregistrerFichier } from "@/lib/stockage";
import { tableExiste } from "@/lib/schema";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { Confirmation, Entete, Vide } from "@/app/composants/ui";
import { ChampPhotos } from "@/app/composants/photos";
import { VoirDocument } from "@/app/composants/fenetre";
import { ChoixLieux, type LieuChoix } from "@/app/composants/choix-lieux";
import {
  ChoixConsequences,
  type ConsequencePosee,
  type TypeConsequence,
} from "@/app/composants/choix-consequences";

export const dynamic = "force-dynamic";

type Suivi = {
  id: string;
  titre: string;
  nature: string;
  nature_code: string;
  parent_id: string | null;
  permanent: boolean;
  declencheur: string | null;
  ouvert_le: string | Date;
  clos_le: string | Date | null;
  commentaire: string | null;
  nb_episodes: number;
  nb_a_controler: number;
  nb_non_regles: number;
  montant: number;
  periodicite_jours: number | null;
  derniere_verification_nature: string | Date | null;
};

type Acte = {
  id: string;
  date_acte: string | Date;
  type_acte_id: string;
  type_libelle: string;
  type_code: string;
  est_verification: boolean;
  est_traitement: boolean;
  qui: string | null;
  qui_cle: string | null;
  commentaire: string | null;
  montant_ht: number | null;
  gratuit: boolean;
  hors_contrat: boolean;
  positifs: string[];
  negatifs: string[];
  autres: string[];
};

type EtatLieu = {
  emplacement: string;
  regle: boolean;
  a_controler: boolean;
  dernier_traitement: string | Date | null;
  derniere_negative: string | Date | null;
  nb_verifications: number;
  nb_traitements: number;
};

type Piece = {
  id: string;
  chemin: string;
  nom: string | null;
  nature_piece: string;
  ajoute_le: string | Date;
  acte_id: string | null;
};

/** Une conséquence telle qu'elle se lit dans la chronologie. */
type Consequence = {
  acte_id: string;
  type_consequence_id: string;
  libelle: string;
  code: string;
  lieu: string | null;
  emplacement_id: string | null;
  montant_ht: number | null;
};

type TypeActe = {
  id: string;
  libelle: string;
  code: string;
  est_verification: boolean;
  porte_sur_lieux: boolean;
};

/**
 * Les lieux d'un acte et leur résultat.
 *
 * Fonction de MODULE, pas voisine d'une action : ce qu'une action serveur
 * appelle doit être une fonction ordinaire, sinon Next essaie de l'envoyer au
 * navigateur et l'écran se tait (règles 7undecies et 7duodecies).
 */
async function poserLesLieux(
  acteId: string,
  suiviId: string,
  jour: string,
  donnees: FormData,
) {
  for (const [cle, valeur] of donnees.entries()) {
    if (!cle.startsWith("lieu_")) continue;
    const lieu = cle.slice(5);
    const v = String(valeur);
    await sql`
      insert into acte_lieux (acte_id, emplacement_id, resultat)
      values (${acteId}, ${lieu}::uuid,
              ${v === "positif" ? "positif" : v === "negatif" ? "negatif" : null}
                ::resultat_verification)
      on conflict do nothing`;
    // Un lieu touché qui n'était pas dans la portée du suivi y entre, daté :
    // on s'élargit en cours de route.
    await sql`
      insert into suivi_lieux (suivi_id, emplacement_id, entre_le, motif)
      values (${suiviId}, ${lieu}::uuid, ${jour}::date, 'ajouté par un acte')
      on conflict do nothing`;
  }
}

/** Ce qu'on a décidé parce que l'acte a eu lieu. */
async function poserLesConsequences(acteId: string, donnees: FormData) {
  const types = [...donnees.keys()]
    .filter((c) => c.startsWith("cons_") && !c.startsWith("cons_lieu_") && !c.startsWith("cons_montant_"))
    .map((c) => c.slice(5));

  for (const type of new Set(types)) {
    const brut = String(donnees.get(`cons_montant_${type}`) ?? "").replace(",", ".").trim();
    const montant = brut && !Number.isNaN(Number(brut)) ? Number(brut) : null;
    const lieux = donnees.getAll(`cons_lieu_${type}`).map(String).filter(Boolean);

    if (lieux.length === 0) {
      await sql`
        insert into consequences_acte (acte_id, type_consequence_id, montant_ht)
        values (${acteId}, ${type}::uuid, ${montant})
        on conflict do nothing`;
      continue;
    }
    for (const lieu of lieux) {
      await sql`
        insert into consequences_acte (acte_id, type_consequence_id, emplacement_id, montant_ht)
        values (${acteId}, ${type}::uuid, ${lieu}::uuid, ${montant})
        on conflict do nothing`;
    }
  }
}

/**
 * Les pièces jointes. Rend `true` si le dépôt en a refusé une.
 *
 * Ne jamais avaler un échec d'enregistrement avec un `continue` muet : on
 * croirait la facture jointe alors qu'elle n'est nulle part.
 */
async function joindreLesPieces(
  acteId: string,
  suiviId: string,
  profilId: string,
  donnees: FormData,
) {
  let refusee = false;
  for (const fichier of donnees.getAll("piece")) {
    if (!(fichier instanceof File) || fichier.size === 0) continue;
    const chemin = await enregistrerFichier(fichier);
    if (!chemin) {
      refusee = true;
      continue;
    }
    await sql`
      insert into pieces_suivi (suivi_id, acte_id, chemin, nom, nature_piece, ajoute_par)
      values (${suiviId}, ${acteId}, ${chemin}, ${fichier.name},
              ${String(donnees.get("nature_piece") ?? "facture")}, ${profilId})`;
  }
  return refusee;
}

export default async function Dossier({
  params,
  searchParams,
}: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{
    fait?: string;
    acte?: string;
    episode?: string;
    modifier?: string;
    type?: string;
  }>;
}) {
  const profil = await exigerEncadrement();
  const { id } = await params;
  const {
    fait,
    acte: ouvrirActe,
    episode: ouvrirEpisode,
    modifier,
    type: typeForce,
  } = await searchParams;

  if (!(await tableExiste("suivis"))) notFound();

  // Le code part en ligne avant la migration : sans la 0025, les conséquences
  // n'existent pas encore et l'écran se tient sans elles.
  const avecConsequences = await tableExiste("consequences_acte");

  const [suivi] = await sql<Suivi[]>`
    select id, titre, nature, nature_code, parent_id, permanent, declencheur,
           ouvert_le, clos_le, commentaire, nb_episodes::int, nb_a_controler::int,
           nb_non_regles::int, montant, periodicite_jours, derniere_verification_nature
      from v_suivis where id = ${id}`;
  if (!suivi) notFound();

  const episodes = suivi.permanent
    ? await sql<
        { id: string; titre: string; ouvert_le: string | Date; clos_le: string | Date | null;
          nb_actes: number; nb_a_controler: number; nb_non_regles: number }[]
      >`
        select id, titre, ouvert_le, clos_le, nb_actes::int, nb_a_controler::int,
               nb_non_regles::int
          from v_suivis where parent_id = ${id} order by ouvert_le desc`
    : [];

  // La chronologie : un acte = une ligne, avec sa portée et ses résultats.
  const actes = await sql<Acte[]>`
    select a.id, a.date_acte, a.type_acte_id,
           t.libelle as type_libelle, t.code as type_code,
           t.est_verification, t.est_traitement,
           coalesce(u.nom, p.nom) as qui,
           case when a.utilisateur_id is not null then 'u:' || a.utilisateur_id
                when a.prestataire_id is not null then 'p:' || a.prestataire_id
                end as qui_cle,
           a.commentaire, a.montant_ht, a.gratuit, a.hors_contrat,
           coalesce((select array_agg(e.code order by e.code) from acte_lieux al
                      join emplacements e on e.id = al.emplacement_id
                     where al.acte_id = a.id and al.resultat = 'positif'), '{}') as positifs,
           coalesce((select array_agg(e.code order by e.code) from acte_lieux al
                      join emplacements e on e.id = al.emplacement_id
                     where al.acte_id = a.id and al.resultat = 'negatif'), '{}') as negatifs,
           coalesce((select array_agg(e.code order by e.code) from acte_lieux al
                      join emplacements e on e.id = al.emplacement_id
                     where al.acte_id = a.id
                       and (al.resultat is null or al.resultat = 'non_concluant')), '{}') as autres
      from actes a
      join types_acte t on t.id = a.type_acte_id
      left join utilisateurs u on u.id = a.utilisateur_id
      left join prestataires p on p.id = a.prestataire_id
     where a.suivi_id = ${id}
     order by a.date_acte, a.cree_le`;

  const consequences: Consequence[] = avecConsequences
    ? await sql<Consequence[]>`
        select c.acte_id, c.type_consequence_id, tc.libelle, tc.code,
               e.code as lieu, c.emplacement_id, c.montant_ht
          from consequences_acte c
          join types_consequence tc on tc.id = c.type_consequence_id
          join actes a on a.id = c.acte_id
          left join emplacements e on e.id = c.emplacement_id
         where a.suivi_id = ${id}
         order by tc.ordre, e.code`
    : [];

  const etats = suivi.permanent
    ? []
    : await sql<EtatLieu[]>`
        select emplacement, regle, a_controler, dernier_traitement, derniere_negative,
               nb_verifications::int, nb_traitements::int
          from v_suivi_lieux where suivi_id = ${id} order by emplacement`;

  const pieces = await sql<Piece[]>`
    select id, chemin, nom, nature_piece, ajoute_le, acte_id
      from pieces_suivi where suivi_id = ${id} order by ajoute_le desc`;

  const types = await sql<TypeActe[]>`
    select id, libelle, code, est_verification, porte_sur_lieux
      from types_acte where nature_code = ${suivi.nature_code} order by ordre`;

  const typesConsequence: TypeConsequence[] = avecConsequences
    ? await sql<TypeConsequence[]>`
        select id, code, libelle, porte_sur_lieux, porte_montant
          from types_consequence where nature_code = ${suivi.nature_code} order by ordre`
    : [];

  const lieux = await sql<LieuChoix[]>`
    select e.id, e.code, et.nom as etage
      from emplacements e join etages et on et.id = e.etage_id
     where e.actif order by et.ordre, e.ordre, e.code`;

  /**
   * Les lieux du dossier.
   *
   * Un épisode qui vient de s'ouvrir n'a pas encore de portée : on cochait
   * alors zéro lieu, et « Tout cocher » prenait les soixante-douze lieux de
   * l'hôtel, toit et chaufferie compris. Le PÉRIMÈTRE d'une campagne vit sur
   * le dossier permanent — c'est lui qui dit ce qu'on balaie, Lobby inclus.
   * On retombe donc dessus tant que l'épisode n'a pas le sien.
   */
  const portee = await sql<{ id: string; code: string }[]>`
    with p as (
      select emplacement_id from suivi_lieux where suivi_id = ${id}
      union
      select sl.emplacement_id from suivi_lieux sl
       where sl.suivi_id = ${suivi.parent_id}::uuid
         and not exists (select 1 from suivi_lieux x where x.suivi_id = ${id})
    )
    select e.id, e.code
      from p
      join emplacements e on e.id = p.emplacement_id
      join etages et on et.id = e.etage_id
     order by et.ordre, e.ordre, e.code`;

  const gens = await sql<{ id: string; nom: string; genre: string }[]>`
    select id, nom, 'u' as genre from utilisateurs where actif
    union all
    select id, nom, 'p' as genre from prestataires where actif
    order by nom`;

  /** L'acte qu'on corrige, s'il y en a un — avec ce qu'il porte déjà. */
  const acteModifie = modifier ? actes.find((a) => a.id === modifier) : undefined;

  const lieuxDeLActe = acteModifie
    ? await sql<{ emplacement_id: string; resultat: string | null }[]>`
        select emplacement_id, resultat::text from acte_lieux where acte_id = ${acteModifie.id}`
    : [];

  const etatsDeLActe: Record<string, "negatif" | "positif" | "concerne"> = {};
  for (const l of lieuxDeLActe) {
    etatsDeLActe[l.emplacement_id] =
      l.resultat === "positif" ? "positif" : l.resultat === "negatif" ? "negatif" : "concerne";
  }

  const consequencesDeLActe: ConsequencePosee[] = acteModifie
    ? Object.values(
        consequences
          .filter((c) => c.acte_id === acteModifie.id)
          .reduce<Record<string, ConsequencePosee>>((acc, c) => {
            const courant = acc[c.type_consequence_id] ?? {
              type_id: c.type_consequence_id,
              lieux: [],
              montant: c.montant_ht != null ? String(c.montant_ht) : "",
            };
            if (c.emplacement_id) courant.lieux.push(c.emplacement_id);
            acc[c.type_consequence_id] = courant;
            return acc;
          }, {}),
      )
    : [];

  /**
   * Poser un acte.
   *
   * Aucun ordre n'est imposé : chimique puis froid, l'inverse, ou les deux —
   * ce sont trois actes, et seule leur date compte. L'écran enregistre ce qui
   * a eu lieu, il ne dicte jamais la suite.
   */
  async function ajouterActe(donnees: FormData) {
    "use server";
    const p = await profilActif();
    if (!p || !peutValider(p.role)) redirect(`/suivis/${id}` as Route);

    const type = String(donnees.get("type") ?? "");
    const jour = String(donnees.get("date_acte") ?? "");
    if (!type || !/^\d{4}-\d{2}-\d{2}$/.test(jour)) return;

    const qui = String(donnees.get("qui") ?? "");
    const [genre, quiId] = qui.includes(":") ? qui.split(":") : ["", ""];
    const montantBrut = String(donnees.get("montant_ht") ?? "").replace(",", ".").trim();
    const montant = montantBrut && !Number.isNaN(Number(montantBrut)) ? Number(montantBrut) : null;

    const [cree] = await sql<{ id: string }[]>`
      insert into actes (suivi_id, type_acte_id, date_acte, utilisateur_id, prestataire_id,
                         commentaire, montant_ht, gratuit, hors_contrat, saisie_par)
      values (${id}, ${type}::uuid, ${jour}::date,
              ${genre === "u" ? quiId : null}::uuid,
              ${genre === "p" ? quiId : null}::uuid,
              ${String(donnees.get("commentaire") ?? "").trim() || null},
              ${montant}, ${donnees.get("gratuit") === "on"},
              ${donnees.get("hors_contrat") === "on"}, ${p.id})
      returning id`;

    await poserLesLieux(cree.id, id, jour, donnees);
    if (avecConsequences) await poserLesConsequences(cree.id, donnees);
    const refusee = await joindreLesPieces(cree.id, id, p.id, donnees);

    revalidatePath(`/suivis/${id}`);
    redirect(`/suivis/${id}?fait=${refusee ? "acte-sans-piece" : "acte"}#acte-${cree.id}` as Route);
  }

  /**
   * Corriger un acte déjà posé.
   *
   * On reprend de l'historique : une date lue de travers sur une note de
   * facture, un intervenant qu'on retrouve trois jours plus tard, une chambre
   * oubliée dans un balayage. Sans correction, la chronologie fige la
   * première saisie — et c'est justement ce qu'on essaie d'éviter en la
   * tenant. Les lieux et les conséquences sont réécrits d'un bloc à partir
   * du formulaire ; les pièces déjà jointes restent.
   */
  async function modifierActe(donnees: FormData) {
    "use server";
    const p = await profilActif();
    if (!p || !peutValider(p.role)) redirect(`/suivis/${id}` as Route);

    const acteId = String(donnees.get("acte") ?? "");
    const type = String(donnees.get("type") ?? "");
    const jour = String(donnees.get("date_acte") ?? "");
    if (!acteId || !type || !/^\d{4}-\d{2}-\d{2}$/.test(jour)) return;

    const qui = String(donnees.get("qui") ?? "");
    const [genre, quiId] = qui.includes(":") ? qui.split(":") : ["", ""];
    const montantBrut = String(donnees.get("montant_ht") ?? "").replace(",", ".").trim();
    const montant = montantBrut && !Number.isNaN(Number(montantBrut)) ? Number(montantBrut) : null;

    await sql`
      update actes
         set type_acte_id   = ${type}::uuid,
             date_acte      = ${jour}::date,
             utilisateur_id = ${genre === "u" ? quiId : null}::uuid,
             prestataire_id = ${genre === "p" ? quiId : null}::uuid,
             commentaire    = ${String(donnees.get("commentaire") ?? "").trim() || null},
             montant_ht     = ${montant},
             gratuit        = ${donnees.get("gratuit") === "on"},
             hors_contrat   = ${donnees.get("hors_contrat") === "on"}
       where id = ${acteId}::uuid and suivi_id = ${id}`;

    await sql`delete from acte_lieux where acte_id = ${acteId}::uuid`;
    await poserLesLieux(acteId, id, jour, donnees);
    if (avecConsequences) {
      await sql`delete from consequences_acte where acte_id = ${acteId}::uuid`;
      await poserLesConsequences(acteId, donnees);
    }
    const refusee = await joindreLesPieces(acteId, id, p.id, donnees);

    revalidatePath(`/suivis/${id}`);
    redirect(
      `/suivis/${id}?fait=${refusee ? "acte-sans-piece" : "acte-modifie"}#acte-${acteId}` as Route,
    );
  }

  /**
   * Retirer un acte.
   *
   * Un acte saisi deux fois, ou sur le mauvais dossier. Il emporte ses lieux,
   * ses conséquences et ses pièces — c'est le geste qui défait la saisie,
   * jamais celui qui « annule » un fait : un traitement qui a eu lieu se
   * corrige, il ne s'efface pas.
   */
  async function supprimerActe(donnees: FormData) {
    "use server";
    const p = await profilActif();
    if (!p || !peutValider(p.role)) redirect(`/suivis/${id}` as Route);
    const acteId = String(donnees.get("acte") ?? "");
    if (!acteId) return;
    await sql`delete from actes where id = ${acteId}::uuid and suivi_id = ${id}`;
    revalidatePath(`/suivis/${id}`);
    redirect(`/suivis/${id}?fait=acte-supprime` as Route);
  }

  /** Ouvrir un épisode dans ce dossier permanent. */
  async function ouvrirUnEpisode(donnees: FormData) {
    "use server";
    const p = await profilActif();
    if (!p || !peutValider(p.role)) redirect(`/suivis/${id}` as Route);
    const titre = String(donnees.get("titre") ?? "").trim();
    if (titre.length < 3) return;
    const jour = String(donnees.get("ouvert_le") ?? "");
    const [cree] = await sql<{ id: string }[]>`
      insert into suivis (nature_code, parent_id, titre, declencheur, ouvert_le, cree_par)
      values (${suivi.nature_code}, ${id}, ${titre},
              ${String(donnees.get("declencheur") ?? "autre")}::declencheur_suivi,
              ${/^\d{4}-\d{2}-\d{2}$/.test(jour) ? jour : null}::date, ${p.id})
      returning id`;
    revalidatePath("/suivis");
    redirect(`/suivis/${cree.id}?fait=episode` as Route);
  }

  /** Clore ou rouvrir un épisode. Le dossier permanent, lui, ne se clôt pas. */
  async function basculerCloture() {
    "use server";
    const p = await profilActif();
    if (!p || !peutValider(p.role) || suivi.permanent) redirect(`/suivis/${id}` as Route);
    await sql`
      update suivis set clos_le = case when clos_le is null then current_date else null end
       where id = ${id}`;
    revalidatePath(`/suivis/${id}`);
    redirect(`/suivis/${id}?fait=etat` as Route);
  }

  const derniere = suivi.derniere_verification_nature
    ? new Date(jourISO(suivi.derniere_verification_nature))
    : null;
  const joursDepuis = derniere
    ? Math.round((Date.now() - derniere.getTime()) / 86_400_000)
    : null;
  const enRetard =
    joursDepuis !== null &&
    suivi.periodicite_jours !== null &&
    joursDepuis > suivi.periodicite_jours;

  const piecesDe = (a: string) => pieces.filter((p) => p.acte_id === a);
  const consequencesDe = (a: string) => consequences.filter((c) => c.acte_id === a);

  /** Le type choisi : celui qu'on force, celui de l'acte corrigé, ou le premier. */
  const typeChoisi =
    types.find((t) => t.id === (typeForce ?? ouvrirActe)) ??
    (acteModifie ? types.find((t) => t.id === acteModifie.type_acte_id) : undefined) ??
    types[0];

  /**
   * Le formulaire d'un acte — le même pour en poser un et pour en corriger un.
   *
   * Deux formulaires différents pour la même chose, c'est deux endroits où
   * l'un des deux oublie un champ.
   */
  const formulaire = (a?: Acte) => {
    const enCorrection = Boolean(a);
    // « Ce qu'il faut retenir » s'ouvrait sur tous les actes, alors qu'un
    // balayage de trente-huit chambres n'a rien à retenir. Il s'ouvre quand
    // il sert : un devis, une note, ou un acte qui porte déjà des mots.
    const motsAttendus =
      typeChoisi?.code === "devis" ||
      typeChoisi?.code === "note" ||
      Boolean(a?.commentaire) ||
      (a ? piecesDe(a.id).length > 0 : false);

    return (
      <form
        action={enCorrection ? modifierActe : ajouterActe}
        className="flex flex-col gap-3 place-pour-le-calendrier"
      >
        <input type="hidden" name="type" value={typeChoisi?.id ?? ""} />
        {a && <input type="hidden" name="acte" value={a.id} />}

        <div className="grid grid-cols-2 gap-2">
          <label className="flex flex-col gap-1">
            <span className="etiquette">Quel jour</span>
            <input
              name="date_acte"
              type="date"
              required
              defaultValue={a ? jourISO(a.date_acte) : aujourdhuiISO()}
              className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[15px]"
            />
          </label>
          <label className="flex flex-col gap-1">
            <span className="etiquette">Par qui</span>
            <select
              name="qui"
              defaultValue={a?.qui_cle ?? ""}
              className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[14.5px]"
            >
              <option value="">—</option>
              {gens.map((g) => (
                <option key={`${g.genre}:${g.id}`} value={`${g.genre}:${g.id}`}>
                  {g.nom}
                </option>
              ))}
            </select>
          </label>
        </div>

        {typeChoisi?.porte_sur_lieux && (
          <ChoixLieux
            key={`${a?.id ?? "neuf"}-${typeChoisi.id}`}
            lieux={lieux}
            defaut={portee.map((p) => p.id)}
            etats={a && Object.keys(etatsDeLActe).length > 0 ? etatsDeLActe : undefined}
            verification={typeChoisi.est_verification}
          />
        )}

        {typesConsequence.length > 0 && (
          <ChoixConsequences
            key={`cons-${a?.id ?? "neuf"}`}
            types={typesConsequence}
            lieux={portee}
            posees={a ? consequencesDeLActe : []}
          />
        )}

        <div className="grid grid-cols-2 gap-2">
          <label className="flex flex-col gap-1">
            <span className="etiquette">Montant HT</span>
            <input
              name="montant_ht"
              type="text"
              inputMode="decimal"
              defaultValue={a?.montant_ht != null ? String(a.montant_ht) : ""}
              placeholder="—"
              className="h-[46px] rounded-[12px] border border-line px-3 bg-surface text-[15px] tabular-nums"
            />
          </label>
          <div className="flex flex-col gap-1.5 justify-end pb-1.5">
            <label className="flex items-center gap-2 text-[13.5px] cursor-pointer">
              <input
                type="checkbox"
                name="gratuit"
                defaultChecked={a?.gratuit}
                className="w-4 h-4 accent-[#453A6E]"
              />
              Offert
            </label>
            <label className="flex items-center gap-2 text-[13.5px] cursor-pointer">
              <input
                type="checkbox"
                name="hors_contrat"
                defaultChecked={a?.hors_contrat}
                className="w-4 h-4 accent-[#453A6E]"
              />
              Hors contrat
            </label>
          </div>
        </div>

        {/* Un commentaire, une photo, un document — quand il y a quelque chose
            à dire. Replié sinon : l'encadré s'ouvrait sur chaque acte alors
            qu'il ne sert que sur quelques-uns. */}
        <details
          className="rounded-[12px] border border-line bg-surface"
          open={motsAttendus}
        >
          <summary className="list-none cursor-pointer px-3 h-[46px] flex items-center gap-2 text-[14px]">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#8E8AA3"
                 strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
              <path d="M9 5l7 7-7 7" />
            </svg>
            <span className="grow">Un commentaire, une photo, un document</span>
          </summary>
          <div className="px-3 pb-3 pt-1 flex flex-col gap-2.5">
            <textarea
              name="commentaire"
              rows={3}
              defaultValue={a?.commentaire ?? ""}
              placeholder="Ce que la société a dit, ce qui a été convenu…"
              className="rounded-[12px] border border-line px-3 py-2.5 bg-surface text-[15px] leading-snug resize-none placeholder:text-ink-faint"
            />
            <label className="flex flex-col gap-1">
              <span className="etiquette">La pièce jointe est…</span>
              <select
                name="nature_piece"
                defaultValue="facture"
                className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[14.5px]"
              >
                <option value="facture">Une facture</option>
                <option value="devis">Un devis</option>
                <option value="rapport">Un rapport</option>
                <option value="photo">Une photo</option>
                <option value="autre">Autre</option>
              </select>
            </label>
            <ChampPhotos nom="piece" libelle="Ajouter une photo ou un document" documents />
            {a && piecesDe(a.id).length > 0 && (
              <p className="text-[11.5px] text-ink-faint text-pretty leading-snug">
                {piecesDe(a.id).length} pièce{piecesDe(a.id).length > 1 ? "s" : ""} déjà jointe
                {piecesDe(a.id).length > 1 ? "s" : ""} : elles restent, ce qu’on ajoute ici
                s’ajoute.
              </p>
            )}
          </div>
        </details>

        <BoutonEnvoi
          pendant="Enregistrement…"
          className="h-[52px] rounded-[14px] bg-plum text-white font-display font-semibold text-[16px]"
        >
          {enCorrection ? "Enregistrer la correction" : "Enregistrer l’acte"}
        </BoutonEnvoi>
      </form>
    );
  };

  /** Les pastilles de type : elles décident si l'acte porte un résultat. */
  const pastillesDeType = (a?: Acte) => (
    <div className="flex flex-col gap-1.5">
      <span className="etiquette">Quoi</span>
      <div className="flex flex-wrap gap-1.5">
        {types.map((t) => (
          <Link
            key={t.id}
            href={
              (a
                ? `/suivis/${id}?modifier=${a.id}&type=${t.id}#acte-${a.id}`
                : `/suivis/${id}?acte=${t.id}`) as Route
            }
            replace
            scroll={false}
            className={`h-[38px] px-3 rounded-pill border text-[13px] flex items-center ${
              t.id === typeChoisi?.id
                ? "bg-plum border-plum text-white"
                : "bg-surface border-line text-ink-soft"
            }`}
          >
            {t.libelle}
          </Link>
        ))}
      </div>
    </div>
  );

  const aControler = etats.filter((e) => e.a_controler);
  const enCours = etats.filter((e) => !e.regle && !e.a_controler);
  const regles = etats.filter((e) => e.regle);

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete
        titre={suivi.titre}
        sous_titre={suivi.permanent ? "Dossier permanent" : suivi.nature}
        retour={suivi.parent_id ? `/suivis/${suivi.parent_id}` : "/suivis"}
      />

      <div className="px-5 py-4 flex flex-col gap-4">
        {fait && <Confirmation quoi={fait} />}

        {/* L'état, en un mot */}
        {!suivi.permanent && (
          <div
            className={`rounded-card px-4 py-3.5 flex flex-col gap-1 ${
              suivi.nb_a_controler > 0
                ? "bg-amber-soft"
                : suivi.nb_non_regles > 0
                  ? "bg-red-soft"
                  : "bg-green-soft"
            }`}
          >
            <p
              className={`font-display font-semibold text-[16px] ${
                suivi.nb_a_controler > 0
                  ? "text-amber"
                  : suivi.nb_non_regles > 0
                    ? "text-red"
                    : "text-green"
              }`}
            >
              {suivi.nb_a_controler > 0
                ? `${suivi.nb_a_controler} lieu${suivi.nb_a_controler > 1 ? "x" : ""} à contrôler`
                : suivi.nb_non_regles > 0
                  ? `${suivi.nb_non_regles} lieu${suivi.nb_non_regles > 1 ? "x" : ""} non réglé${suivi.nb_non_regles > 1 ? "s" : ""}`
                  : "Réglé"}
            </p>
            <p
              className={`text-[12.5px] text-pretty leading-snug ${
                suivi.nb_a_controler > 0
                  ? "text-amber"
                  : suivi.nb_non_regles > 0
                    ? "text-red"
                    : "text-green"
              }`}
            >
              {suivi.nb_a_controler > 0
                ? "Traité, et aucune vérification concluante depuis. Il faut rappeler la société."
                : suivi.nb_non_regles > 0
                  ? "Une vérification est revenue positive, ou le lieu n’a jamais été vérifié."
                  : "Une vérification négative est postérieure à tous les traitements."}
            </p>
            {suivi.montant > 0 && (
              <p className="text-[12px] text-ink-soft">
                {euros(suivi.montant)} annoncés sur les pièces jointes.
              </p>
            )}
          </div>
        )}

        {suivi.permanent && enRetard && (
          <p className="rounded-card bg-amber-soft px-4 py-3 text-[12.5px] text-amber text-pretty leading-snug">
            Dernière vérification il y a <b>{joursDepuis} jours</b>, pour un rythme attendu de{" "}
            {suivi.periodicite_jours}. <b>La campagne est en retard.</b>
          </p>
        )}

        {suivi.commentaire && (
          <p className="text-[13px] text-ink-soft text-pretty leading-snug">{suivi.commentaire}</p>
        )}

        {/* ---------------------------------------------- les épisodes */}
        {suivi.permanent && (
          <section className="flex flex-col gap-2">
            <h2 className="titre text-[15.5px]">Les épisodes · {episodes.length}</h2>
            {episodes.map((e) => (
              <Link
                key={e.id}
                href={`/suivis/${e.id}` as Route}
                className="carte px-4 py-3.5 flex items-start gap-3 active:bg-surface-muted"
              >
                <span className="grow min-w-0">
                  <span className="block font-display font-semibold text-[15px] leading-snug">
                    {e.titre}
                  </span>
                  <span className="block text-[11.5px] text-ink-faint">
                    {e.nb_actes} acte{e.nb_actes > 1 ? "s" : ""} ·{" "}
                    {e.clos_le
                      ? `clos le ${new Date(e.clos_le).toLocaleDateString("fr-FR")}`
                      : "ouvert"}
                  </span>
                </span>
                <span
                  className={`shrink-0 px-2 py-0.5 rounded-md text-[11px] ${
                    e.nb_a_controler > 0
                      ? "bg-amber-soft text-amber"
                      : e.nb_non_regles > 0
                        ? "bg-red-soft text-red"
                        : "bg-green-soft text-green"
                  }`}
                >
                  {e.nb_a_controler > 0
                    ? "à contrôler"
                    : e.nb_non_regles > 0
                      ? "en cours"
                      : "réglé"}
                </span>
              </Link>
            ))}

            <details className="carte overflow-hidden group/ep" open={Boolean(ouvrirEpisode)}>
              <summary
                data-cible
                className="px-4 flex items-center gap-3 cursor-pointer list-none select-none text-[14.5px]"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8E8AA3"
                     strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                     className="shrink-0 transition-transform group-open/ep:rotate-90">
                  <path d="M9 5l7 7-7 7" />
                </svg>
                Ouvrir un épisode
              </summary>
              <form action={ouvrirUnEpisode} className="px-4 pb-4 pt-1 flex flex-col gap-2.5">
                <label className="flex flex-col gap-1">
                  <span className="etiquette">Ce qui se passe</span>
                  <input
                    name="titre"
                    required
                    minLength={3}
                    placeholder="Automne 2026 — chambre 34"
                    className="h-[48px] rounded-[12px] border border-line px-3 bg-surface text-[16px]"
                  />
                </label>
                <div className="grid grid-cols-2 gap-2">
                  <label className="flex flex-col gap-1">
                    <span className="etiquette">Déclenché par</span>
                    <select
                      name="declencheur"
                      defaultValue="prevention"
                      className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[14.5px]"
                    >
                      <option value="client">Un client</option>
                      <option value="prevention">Une vérification de prévention</option>
                      <option value="personnel">Le personnel</option>
                      <option value="autre">Autre</option>
                    </select>
                  </label>
                  <label className="flex flex-col gap-1">
                    <span className="etiquette">Ouvert le</span>
                    <input
                      name="ouvert_le"
                      type="date"
                      defaultValue={aujourdhuiISO()}
                      className="h-[46px] rounded-[12px] border border-line px-2 bg-surface text-[15px]"
                    />
                  </label>
                </div>
                <BoutonEnvoi
                  pendant="Ouverture…"
                  className="h-[48px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15px]"
                >
                  Ouvrir l’épisode
                </BoutonEnvoi>
              </form>
            </details>
          </section>
        )}

        {/* ---------------------------------------------- la chronologie */}
        <section className="flex flex-col gap-2">
          <h2 className="titre text-[15.5px]">La chronologie · {actes.length}</h2>
          {actes.length === 0 ? (
            <Vide>Aucun acte encore. Le premier se pose ci-dessous.</Vide>
          ) : (
            <ol className="relative flex flex-col gap-4 pl-6">
              <span aria-hidden className="absolute left-[5px] top-2 bottom-2 w-[2px] bg-line" />
              {actes.map((a) => {
                const ton =
                  a.positifs.length > 0
                    ? "bg-red"
                    : a.negatifs.length > 0
                      ? "bg-green"
                      : a.est_traitement
                        ? "bg-plum"
                        : "bg-ink-faint";
                const corrige = acteModifie?.id === a.id;
                return (
                  <li key={a.id} id={`acte-${a.id}`} className="relative scroll-mt-20">
                    <span
                      aria-hidden
                      className={`absolute -left-6 top-[9px] w-[11px] h-[11px] rounded-full ${ton} ring-2 ring-surface`}
                    />

                    {/* Le titre, c'est le fait — pas la date. Un intertitre plus
                        petit que le texte qu'il annonce ne titre rien. */}
                    <p className="text-[12.5px] text-ink-faint">
                      {new Date(a.date_acte).toLocaleDateString("fr-FR", {
                        weekday: "short",
                        day: "numeric",
                        month: "long",
                        year: "numeric",
                      })}
                    </p>
                    <div className="flex items-start gap-2">
                      <h3 className="grow titre text-[16px] leading-snug text-pretty">
                        {a.type_libelle}
                        {a.qui && (
                          <span className="font-sans font-normal text-ink-soft"> — {a.qui}</span>
                        )}
                        {/* Un commentaire se voit AVANT d'être lu : sinon on ne
                            sait pas qu'il y en a un. */}
                        {a.commentaire && (
                          <svg
                            className="inline-block ml-1.5 -mb-[1px]"
                            width="14" height="14" viewBox="0 0 24 24" fill="none"
                            stroke="#453A6E" strokeWidth="2" strokeLinecap="round"
                            strokeLinejoin="round" aria-label="porte un commentaire"
                          >
                            <path d="M21 11.5a8.4 8.4 0 0 1-9 8.4 8.4 8.4 0 0 1-3.8-.9L3 21l1.9-5.1A8.4 8.4 0 0 1 12 3a8.4 8.4 0 0 1 9 8.5z" />
                          </svg>
                        )}
                      </h3>
                      {/* Corriger une étape passée : une date lue de travers sur
                          une note de facture, une chambre oubliée. */}
                      {peutValider(profil.role) && !corrige && (
                        <Link
                          href={`/suivis/${id}?modifier=${a.id}#acte-${a.id}` as Route}
                          scroll={false}
                          aria-label="Corriger cet acte"
                          className="shrink-0 w-[34px] h-[34px] -mt-1 rounded-[10px] border border-line bg-surface grid place-items-center"
                        >
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
                               stroke="#4F4B6B" strokeWidth="2" strokeLinecap="round"
                               strokeLinejoin="round">
                            <path d="M12 20h9" />
                            <path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z" />
                          </svg>
                        </Link>
                      )}
                    </div>

                    {/* Les lieux, en clair : c'est la preuve qu'une chambre a
                        été vérifiée même quand elle n'a rien relevé. */}
                    {(a.positifs.length > 0 || a.negatifs.length > 0 || a.autres.length > 0) && (
                      <div className="mt-1.5 flex flex-wrap gap-1.5">
                        {a.positifs.map((c) => (
                          <span
                            key={`p-${c}`}
                            className="px-2 py-1 rounded-md bg-red text-white text-[13px] font-semibold tabular-nums"
                          >
                            {c}
                          </span>
                        ))}
                        {a.negatifs.map((c) => (
                          <span
                            key={`n-${c}`}
                            className="px-2 py-1 rounded-md bg-green-soft text-green text-[13px] tabular-nums"
                          >
                            {c}
                          </span>
                        ))}
                        {a.autres.map((c) => (
                          <span
                            key={`a-${c}`}
                            className="px-2 py-1 rounded-md bg-surface border border-dashed border-plum/50 text-plum text-[13px] tabular-nums"
                          >
                            {c}
                          </span>
                        ))}
                      </div>
                    )}
                    {a.est_verification && a.positifs.length > 0 && (
                      <p className="mt-1 text-[11.5px] text-ink-faint">
                        En rouge, ce qui a été trouvé ; en vert, vérifié et rien relevé.
                      </p>
                    )}
                    {/* Une vérification sans résultat écrit ne conclut RIEN, et
                        c'est l'état qui manquait : traité, jamais revérifié,
                        personne ne le savait (règle 18bis). */}
                    {a.est_verification && a.autres.length > 0 && (
                      <p className="mt-1 text-[11.5px] text-amber">
                        En pointillé : le résultat n’a jamais été écrit. Ces lieux restent à
                        contrôler.
                      </p>
                    )}

                    {/* Ce qu'on a décidé parce que ça s'est passé. */}
                    {consequencesDe(a.id).length > 0 && (
                      <div className="mt-1.5 flex flex-wrap items-center gap-1.5">
                        {Object.entries(
                          consequencesDe(a.id).reduce<Record<string, string[]>>((acc, c) => {
                            const cle = c.libelle + (c.montant_ht != null ? `|${c.montant_ht}` : "");
                            (acc[cle] ??= []).push(c.lieu ?? "");
                            return acc;
                          }, {}),
                        ).map(([cle, lieuxTouches]) => {
                          const [libelle, montant] = cle.split("|");
                          const nommes = lieuxTouches.filter(Boolean);
                          return (
                            <span
                              key={cle}
                              className="px-2 py-1 rounded-md bg-amber-soft text-amber text-[12.5px]"
                            >
                              {libelle}
                              {nommes.length > 0 ? ` · ${nommes.join(", ")}` : ""}
                              {montant ? ` · ${euros(Number(montant))}` : ""}
                            </span>
                          );
                        })}
                      </div>
                    )}

                    <p className="mt-1.5 flex flex-wrap items-center gap-1.5">
                      {a.gratuit && (
                        <span className="px-2 py-0.5 rounded-md text-[11.5px] bg-blue-soft text-blue">
                          offert
                        </span>
                      )}
                      {a.hors_contrat && (
                        <span className="px-2 py-0.5 rounded-md text-[11.5px] bg-amber-soft text-amber">
                          hors contrat
                        </span>
                      )}
                      {a.montant_ht != null && !a.gratuit && (
                        <span className="px-2 py-0.5 rounded-md text-[11.5px] bg-surface-muted text-ink-soft tabular-nums">
                          {euros(Number(a.montant_ht))}
                        </span>
                      )}
                    </p>

                    {a.commentaire && (
                      <p className="mt-1.5 border-l-2 border-plum-soft pl-2.5 text-[13.5px] text-ink-soft text-pretty leading-snug">
                        {a.commentaire}
                      </p>
                    )}

                    {piecesDe(a.id).map((p) => (
                      <VoirDocument
                        key={p.id}
                        chemin={p.chemin}
                        titre={p.nom ?? p.nature_piece}
                        className="mt-1 text-[12.5px] text-plum underline underline-offset-4 self-start block"
                      >
                        {p.nature_piece} — {p.nom ?? "voir la pièce"}
                      </VoirDocument>
                    ))}

                    {/* Corriger, sur place : on ne quitte pas la chronologie
                        pour changer une date. */}
                    {corrige && (
                      <div className="mt-2.5 carte px-4 py-3.5 flex flex-col gap-3 border border-plum/30">
                        <div className="flex items-baseline gap-2">
                          <h4 className="grow titre text-[15px]">Corriger cet acte</h4>
                          <Link
                            href={`/suivis/${id}#acte-${a.id}` as Route}
                            scroll={false}
                            className="text-[12.5px] text-ink-faint underline underline-offset-4"
                          >
                            Annuler
                          </Link>
                        </div>
                        {pastillesDeType(a)}
                        {formulaire(a)}
                        <form action={supprimerActe} className="pt-1 border-t border-line">
                          <input type="hidden" name="acte" value={a.id} />
                          <BoutonEnvoi
                            pendant="…"
                            className="w-full h-[44px] rounded-[12px] bg-surface border border-red/30 text-red text-[13.5px]"
                          >
                            Retirer cet acte de la chronologie
                          </BoutonEnvoi>
                          <p className="mt-1.5 text-[11.5px] text-ink-faint text-pretty leading-snug">
                            Emporte ses lieux, ses conséquences et ses pièces jointes. Un
                            traitement qui a vraiment eu lieu se corrige — il ne s’efface pas.
                          </p>
                        </form>
                      </div>
                    )}
                  </li>
                );
              })}
            </ol>
          )}
        </section>

        {/* ---------------------------------------------- poser un acte */}
        <details className="carte overflow-hidden group/acte" open={Boolean(ouvrirActe)}>
          <summary
            data-cible
            className="px-4 flex items-center gap-3 cursor-pointer list-none select-none"
          >
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#8E8AA3"
                 strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                 className="shrink-0 transition-transform group-open/acte:rotate-90">
              <path d="M9 5l7 7-7 7" />
            </svg>
            <span className="grow text-[15px] font-display font-semibold">Ajouter un acte</span>
          </summary>

          {/* Le TYPE se choisit d'abord, parce qu'il décide si l'acte porte un
              résultat. Un lien, pas un menu : l'écran se redemande et le
              formulaire se règle en conséquence. */}
          <div className="px-4 pb-4 pt-1 flex flex-col gap-3">
            {pastillesDeType()}
            {formulaire()}
          </div>
        </details>

        {/* ---------------------------------------------- l'état par lieu */}
        {!suivi.permanent && etats.length > 0 && (
          <section className="flex flex-col gap-2">
            <h2 className="titre text-[15.5px]">Où on en est, lieu par lieu</h2>
            <p className="text-[12.5px] text-ink-soft text-pretty leading-snug">
              Les {etats.length} lieux que ce dossier couvre, et ce que la chronologie en dit
              aujourd’hui. Rien n’est saisi ici : c’est un calcul.
            </p>

            {[
              {
                cle: "a_controler",
                liste: aControler,
                titre: "À contrôler",
                phrase: "Traités, et aucune vérification concluante depuis.",
                puce: "bg-amber text-white",
                fond: "text-amber",
              },
              {
                cle: "en_cours",
                liste: enCours,
                titre: "En cours",
                phrase: "Une vérification est revenue positive, ou le lieu n’a jamais été vérifié.",
                puce: "bg-red text-white",
                fond: "text-red",
              },
              {
                cle: "regles",
                liste: regles,
                titre: "Réglés",
                phrase: "Une vérification négative est postérieure à tous les traitements.",
                puce: "bg-green-soft text-green",
                fond: "text-green",
              },
            ]
              .filter((g) => g.liste.length > 0)
              .map((g) => (
                <div key={g.cle} className="flex flex-col gap-1.5">
                  <p className={`text-[13.5px] font-medium ${g.fond}`}>
                    {g.titre} · {g.liste.length}
                  </p>
                  <div className="flex flex-wrap gap-1.5">
                    {g.liste.map((e) => (
                      <span
                        key={e.emplacement}
                        className={`px-2 py-1 rounded-md text-[13px] tabular-nums ${g.puce}`}
                      >
                        {e.emplacement}
                      </span>
                    ))}
                  </div>
                  <p className="text-[11.5px] text-ink-faint text-pretty leading-snug">
                    {g.phrase}
                  </p>
                </div>
              ))}

            {/* Le détail est là pour qui le cherche, il n'encombre plus la
                lecture : trente-neuf lignes empilées ne disaient rien. */}
            <details className="carte overflow-hidden group/detail">
              <summary className="list-none cursor-pointer px-4 h-[46px] flex items-center gap-2.5 text-[14px]">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#8E8AA3"
                     strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                     className="shrink-0 transition-transform group-open/detail:rotate-90">
                  <path d="M9 5l7 7-7 7" />
                </svg>
                <span className="grow">Le détail de chaque lieu</span>
              </summary>
              <ul className="divide-y divide-line border-t border-line">
                {etats.map((e) => (
                  <li key={e.emplacement} className="px-3.5 py-2.5 flex items-center gap-3">
                    <span className="shrink-0 px-2 py-0.5 rounded-md bg-plum-soft text-plum text-[12.5px] font-medium">
                      {e.emplacement}
                    </span>
                    <span className="grow min-w-0 text-[11.5px] text-ink-faint">
                      {e.nb_verifications} vérification{e.nb_verifications > 1 ? "s" : ""} ·{" "}
                      {e.nb_traitements} traitement{e.nb_traitements > 1 ? "s" : ""}
                      {e.dernier_traitement &&
                        ` · dernier le ${new Date(e.dernier_traitement).toLocaleDateString("fr-FR")}`}
                    </span>
                    <span
                      className={`shrink-0 px-2 py-0.5 rounded-md text-[11px] ${
                        e.regle
                          ? "bg-green-soft text-green"
                          : e.a_controler
                            ? "bg-amber-soft text-amber"
                            : "bg-red-soft text-red"
                      }`}
                    >
                      {e.regle ? "réglé" : e.a_controler ? "à contrôler" : "en cours"}
                    </span>
                  </li>
                ))}
              </ul>
            </details>
          </section>
        )}

        {/* ---------------------------------------------- clore */}
        {!suivi.permanent && (
          <form action={basculerCloture} className="pt-1">
            <BoutonEnvoi
              pendant="…"
              className="w-full h-[46px] rounded-[12px] bg-surface border border-line text-[14px] text-ink-soft"
            >
              {suivi.clos_le ? "Rouvrir cet épisode" : "Clore cet épisode"}
            </BoutonEnvoi>
          </form>
        )}
      </div>
    </main>
  );
}
