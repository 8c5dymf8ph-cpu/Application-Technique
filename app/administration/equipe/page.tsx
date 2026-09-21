import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { colonneExiste } from "@/lib/schema";
import { profilActif } from "@/lib/profil";
import { LIBELLE_ROLE, peutValider, type RoleUtilisateur } from "@/lib/domaine";
import { Confirmation, Entete } from "@/app/composants/ui";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";
import { Depliant, LigneDepliante } from "@/app/composants/depliant";

export const dynamic = "force-dynamic";

type Personne = {
  id: string;
  nom: string;
  role: RoleUtilisateur;
  actif: boolean;
  citations: number;
};

type Intervenant = {
  nom: string;
  prestataire_id: string | null;
  utilisateur_id: string | null;
  compte: boolean;
  courriel: string | null;
  interventions: number;
  actif: boolean;
};

/**
 * Les deux listes de l'écran de déclaration d'une bouteille.
 *
 * `roles` dit qui y figure — c'est exactement ce que l'écran de déclaration
 * propose. `ajoutable` dit qui l'on peut ajouter ou retirer ici : on n'ajoute
 * pas un administrateur depuis cet écran, mais il faut le VOIR, sinon on
 * croit qu'il manque et on essaie de l'ajouter en vain.
 */
const LISTES: {
  cle: string;
  roles: RoleUtilisateur[];
  ajoutable: RoleUtilisateur | null;
  titre: string;
  aide: string;
}[] = [
  {
    cle: "constat",
    roles: ["menage", "gouvernante"],
    ajoutable: "menage",
    titre: "Qui constate",
    aide: "Les prénoms proposés quand la gouvernante dit qui a vu la bouteille manquante.",
  },
  {
    cle: "transmission",
    roles: ["reception", "admin"],
    ajoutable: "reception",
    titre: "À qui l’on transmet",
    aide: "Les prénoms proposés pour dire à qui le dossier a été remonté.",
  },
];

export default async function Equipe({
  searchParams,
}: {
  searchParams: Promise<{ deja?: string; role?: string; fait?: string; qui?: string }>;
}) {
  const { deja, role: roleDeja, fait, qui } = await searchParams;
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  // La composition de l'étage change souvent : la gouvernante doit pouvoir la
  // tenir à jour sans attendre l'administrateur.
  if (!peutValider(profil.role)) redirect("/");

  const personnes = await sql<Personne[]>`
    select u.id, u.nom, u.role, u.actif,
           ((select count(*) from incidents_bouteille i where i.constate_par = u.id)
          + (select count(*) from incidents_bouteille i where i.transmis_a = u.id))::int
             as citations
    from utilisateurs u
    -- Les deux sections reflètent les deux listes de l'écran de déclaration :
    -- qui constate, et à qui l'on transmet. La gouvernante et l'administrateur
    -- y figurent sans être « gérables » — on ne les ajoute ni ne les retire
    -- ici, mais les cacher faisait croire qu'ils n'y étaient pas.
    where u.role in ('menage', 'reception', 'gouvernante', 'admin')
    order by u.actif desc, u.nom`;

  // Qui figure dans la liste des intervenants techniques. Elle ne se déduit pas
  // d'un rôle : la chargée des opérations n'intervient pas, le réceptionniste
  // qui donne un coup de main, si.
  /**
   * Les quinze intervenants, d'où qu'ils viennent.
   *
   * `v_intervenants` réunit les personnes inscrites et les entreprises
   * extérieures. `compte` dit si quelqu'un peut ouvrir l'application à ce nom,
   * `courriel` où part son récapitulatif de fin de passage.
   */
  /**
   * La liste ne dépend JAMAIS de la migration.
   *
   * Elle était vide tant que `peut_se_connecter` n'existait pas : on voyait
   * « les 0 noms » et une bannière rouge, alors que les quinze intervenants
   * étaient bien là. `v_intervenants` porte les mêmes colonnes avant et après
   * la migration — seuls les RÉGLAGES l'attendent, pas les noms.
   */
  const reglable = await colonneExiste("utilisateurs", "peut_se_connecter");
  const courriels = await colonneExiste("prestataires", "email");

  const intervenants = reglable
    ? await sql<Intervenant[]>`
        select v.nom, v.prestataire_id, v.utilisateur_id,
               coalesce(u.peut_se_connecter, false) as compte,
               coalesce(u.email, p.email)           as courriel,
               v.actif,
               (select count(*) from interventions i
                 where i.technicien_id is not distinct from v.utilisateur_id
                   and i.prestataire_id is not distinct from v.prestataire_id)::int
                 as interventions
          from v_intervenants v
          left join utilisateurs u on u.id = v.utilisateur_id
          left join prestataires p on p.id = v.prestataire_id
         order by v.actif desc, v.nom`
    : courriels
      ? await sql<Intervenant[]>`
          select v.nom, v.prestataire_id, v.utilisateur_id,
                 false                      as compte,
                 coalesce(u.email, p.email) as courriel,
                 v.actif,
                 (select count(*) from interventions i
                   where i.technicien_id is not distinct from v.utilisateur_id
                     and i.prestataire_id is not distinct from v.prestataire_id)::int
                   as interventions
            from v_intervenants v
            left join utilisateurs u on u.id = v.utilisateur_id
            left join prestataires p on p.id = v.prestataire_id
           order by v.actif desc, v.nom`
      : await sql<Intervenant[]>`
          select v.nom, v.prestataire_id, v.utilisateur_id,
                 false      as compte,
                 u.email    as courriel,
                 v.actif,
                 (select count(*) from interventions i
                   where i.technicien_id is not distinct from v.utilisateur_id
                     and i.prestataire_id is not distinct from v.prestataire_id)::int
                   as interventions
            from v_intervenants v
            left join utilisateurs u on u.id = v.utilisateur_id
           order by v.actif desc, v.nom`;


  const actifs = intervenants.filter((i) => i.actif);

  /**
   * Ceux qu'on a retirés de la liste.
   *
   * Ils ne peuvent pas venir de `v_intervenants` : la vue ne retient que les
   * personnes dont `intervient_technique` est vrai, et c'est précisément ce
   * qu'on a mis à faux pour les retirer. Ils en disparaissaient entièrement —
   * on ne pouvait plus les remettre. On va donc les chercher là où ils sont.
   */
  const retires = reglable
    ? await sql<Intervenant[]>`
        select u.nom, null::uuid as prestataire_id, u.id as utilisateur_id,
               false as compte, u.email as courriel,
               (select count(*) from interventions i
                 where i.technicien_id = u.id)::int as interventions,
               false as actif
          from utilisateurs u
         where not u.intervient_technique and u.prestataire_id is null
           and (u.role = 'technicien'
                or exists (select 1 from interventions i where i.technicien_id = u.id))
        union all
        select p.nom, p.id, null::uuid, false, p.email,
               (select count(*) from interventions i
                 where i.prestataire_id = p.id)::int,
               false
          from prestataires p where not p.actif
         order by 1`
    : await sql<Intervenant[]>`
        select u.nom, null::uuid as prestataire_id, u.id as utilisateur_id,
               false as compte, u.email as courriel,
               (select count(*) from interventions i
                 where i.technicien_id = u.id)::int as interventions,
               false as actif
          from utilisateurs u
         where not u.intervient_technique
           and (u.role = 'technicien'
                or exists (select 1 from interventions i where i.technicien_id = u.id))
        union all
        select p.nom, p.id, null::uuid, false, null,
               (select count(*) from interventions i
                 where i.prestataire_id = p.id)::int,
               false
          from prestataires p where not p.actif
         order by 1`;

  /**
   * Ouvrir ou fermer un profil.
   *
   * Pour une entreprise extérieure, cela crée un compte qui la porte : la
   * tournée qu'il ouvrira restera rattachée au prestataire, et la facture se
   * rapprochera comme avant. `utilisateurs.prestataire_id` fait ce lien, et
   * évite que la personne apparaisse deux fois dans la liste.
   */
  async function basculerCompte(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    const nom = String(donnees.get("nom") ?? "").trim();
    const prestataire = String(donnees.get("prestataire") ?? "").trim() || null;
    if (!nom) return;

    const [existe] = await sql<{ id: string; peut: boolean }[]>`
      select id, peut_se_connecter as peut from utilisateurs where nom = ${nom}`;

    if (existe) {
      await sql`
        update utilisateurs
           set peut_se_connecter = not peut_se_connecter,
               intervient_technique = true,
               actif = true
         where id = ${existe.id}`;
    } else {
      await sql`
        insert into utilisateurs (nom, role, intervient_technique,
                                  peut_se_connecter, prestataire_id, actif)
        values (${nom}, 'technicien', true, true, ${prestataire}::uuid, true)`;
    }
    revalidatePath("/administration/equipe");
    // Sans un mot, on ne sait pas si l'appui a porté : la pastille change,
    // mais elle est en bas d'une liste de quinze.
    redirect("/administration/equipe?fait=profil" as Route);
  }

  /** Où part son récapitulatif de fin de passage. */
  async function enregistrerCourriel(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    const nom = String(donnees.get("nom") ?? "").trim();
    const prestataire = String(donnees.get("prestataire") ?? "").trim() || null;
    const email = String(donnees.get("email") ?? "").trim() || null;
    if (!nom) return;

    // L'adresse se pose sur le compte s'il existe, sinon sur l'entreprise :
    // un intervenant sans profil reçoit quand même son récapitulatif.
    const majFaite = await sql`
      update utilisateurs set email = ${email} where nom = ${nom}`;
    if (majFaite.count === 0 && prestataire) {
      await sql`update prestataires set email = ${email} where id = ${prestataire}::uuid`;
    } else if (prestataire) {
      await sql`update prestataires set email = ${email} where id = ${prestataire}::uuid`;
    }
    revalidatePath("/administration/equipe");
    redirect("/administration/equipe?fait=adresse" as Route);
  }

  async function ajouterIntervenant(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    const nom = String(donnees.get("nom") ?? "").trim();
    if (!nom) return;
    // Un renfort ponctuel : il existe, il intervient, et il se retire d'un
    // appui quand il repart. Rien de ce qu'il a fait ne disparaît avec lui.
    // Un prénom déjà connu est réactivé, jamais dupliqué : son historique lui
    // revient.
    await sql`
      insert into utilisateurs (nom, role, intervient_technique, actif)
      values (${nom}, 'technicien', true, true)
      on conflict (nom) do update set intervient_technique = true, actif = true`;
    revalidatePath("/administration/equipe");
    // L'ajout ne se voyait pas : la section se refermait en se rechargeant, et
    // le nouveau nom se rangeait au milieu de quinze autres.
    redirect(`/administration/equipe?fait=intervenant&qui=${encodeURIComponent(nom)}` as Route);
  }

  /**
   * Retirer un intervenant de la liste — ou l'y remettre.
   *
   * On ne supprime jamais : l'hôtel change d'intervenants, et ce qu'ils ont
   * fait reste attaché à leur nom des années après. Retirer, c'est sortir des
   * listes de saisie, rien de plus.
   *
   * Un salarié garde son compte — Taibi reste réceptionniste, il cesse
   * seulement d'être proposé comme intervenant. Une entreprise extérieure se
   * désactive : c'est le lien qui sert au rapprochement des factures, on ne le
   * casse pas.
   */
  async function basculerIntervenant(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    const nom = String(donnees.get("nom") ?? "").trim();
    const prestataire = String(donnees.get("prestataire") ?? "").trim() || null;
    const remettre = donnees.get("remettre") === "1";
    if (!nom) return;

    if (prestataire) {
      await sql`
        update prestataires set actif = ${remettre} where id = ${prestataire}::uuid`;
    } else {
      await sql`
        update utilisateurs set intervient_technique = ${remettre} where nom = ${nom}`;
    }
    revalidatePath("/administration/equipe");
    redirect(
      `/administration/equipe?fait=${remettre ? "remis" : "retire"}&qui=${encodeURIComponent(nom)}` as Route,
    );
  }

  async function ajouter(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    const nom = String(donnees.get("nom") ?? "").trim();
    const role = String(donnees.get("role"));
    if (!nom || !["menage", "reception"].includes(role)) return;

    // Un prénom déjà pris par quelqu'un qui utilise l'application ne change pas
    // de rôle : Miguel est administrateur, l'inscrire comme réceptionniste lui
    // retirerait ses écrans. Il figure DÉJÀ dans la liste par son rôle — mais
    // l'ajout ne faisait rien et ne disait rien, alors on recommençait.
    const [existe] = await sql<{ role: string }[]>`
      select role::text from utilisateurs where nom = ${nom}`;
    if (existe && existe.role !== role) {
      redirect(
        `/administration/equipe?deja=${encodeURIComponent(nom)}&role=${existe.role}` as Route,
      );
    }

    // Un prénom déjà connu est réactivé plutôt que dupliqué : son historique
    // lui revient.
    await sql`
      insert into utilisateurs (nom, role, actif)
      values (${nom}, ${role}::role_utilisateur, true)
      on conflict (nom) do update set actif = true`;
    revalidatePath("/administration/equipe");
  }

  async function basculer(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    // On ne supprime jamais : on désactive. Les dossiers gardent le nom de qui
    // a constaté, même des années après son départ.
    await sql`
      update utilisateurs set actif = not actif
       where id = ${String(donnees.get("personne"))}
         and role in ('menage', 'reception')`;
    revalidatePath("/administration/equipe");
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="L’équipe" sous_titre="Qui constate, à qui l’on transmet" retour="/administration" />

      <div className="px-5 py-4 flex flex-col gap-6">
        <Confirmation quoi={fait} qui={qui} />
        {deja && (
          <p className="rounded-card bg-amber-soft px-4 py-3 text-[13.5px] text-amber text-pretty leading-snug">
            <strong>{deja}</strong> est déjà inscrit comme{" "}
            {LIBELLE_ROLE[(roleDeja ?? "admin") as RoleUtilisateur].toLowerCase()} : son prénom
            figure déjà dans les listes, plus bas. Son rôle n’a pas été changé — il perdrait ses
            écrans.
          </p>
        )}

        <p className="text-[13px] text-ink-soft text-pretty leading-snug">
          Retirer quelqu’un ne l’efface pas : son prénom disparaît des listes de saisie, mais
          reste sur les dossiers qu’il a constatés. Le réajouter lui rend sa place.
        </p>

        {LISTES.map((g) => {
          const dedans = personnes.filter((p) => g.roles.includes(p.role));
          return (
            <Depliant
              key={g.cle}
              titre={g.titre}
              aide={g.aide}
              enCarte={false}
              indice={`${dedans.filter((p) => p.actif).length} prénom${
                dedans.filter((p) => p.actif).length > 1 ? "s" : ""
              }`}
            >

              <ul className="carte divide-y divide-line">
                {dedans.map((p) => (
                  <li key={p.id} className="px-3.5 py-2.5 flex items-center gap-3">
                    <span className="grow min-w-0">
                      <span
                        className={`block text-[15px] ${p.actif ? "" : "text-ink-faint line-through"}`}
                      >
                        {p.nom}
                      </span>
                      <span className="block text-[11.5px] text-ink-faint">
                        {LIBELLE_ROLE[p.role]} ·{" "}
                        {p.citations === 0
                          ? "aucun dossier"
                          : `${p.citations} dossier${p.citations > 1 ? "s" : ""}`}
                      </span>
                    </span>
                    {p.role === g.ajoutable ? (
                      <form action={basculer}>
                        <input type="hidden" name="personne" value={p.id} />
                        <button
                          className={`h-[38px] px-3 rounded-[10px] text-[12.5px] ${
                            p.actif
                              ? "bg-surface-muted border border-line text-ink-soft"
                              : "bg-plum-soft text-plum"
                          }`}
                        >
                          {p.actif ? "Retirer" : "Réintégrer"}
                        </button>
                      </form>
                    ) : (
                      // Une personne qui utilise l'application ne se retire pas
                      // d'ici : son rôle la met dans la liste, et l'en sortir
                      // lui ferait perdre ses écrans.
                      <span className="text-[11.5px] text-ink-faint shrink-0">
                        par son rôle
                      </span>
                    )}
                  </li>
                ))}
                {dedans.length === 0 && (
                  <li className="px-3.5 py-3 text-[13px] text-ink-faint">Personne pour l’instant.</li>
                )}
              </ul>

              <form action={ajouter} className="flex gap-2">
                <input type="hidden" name="role" value={g.ajoutable ?? ""} />
                <input
                  name="nom"
                  autoComplete="off"
                  placeholder="Prénom à ajouter…"
                  className="carte grow min-w-0 px-4 h-[46px] text-[16px] placeholder:text-ink-faint"
                />
                <button className="px-4 rounded-card bg-plum text-white text-[14.5px]">
                  Ajouter
                </button>
              </form>
            </Depliant>
          );
        })}

        {/* Les intervenants techniques */}
        {/* Elle se rouvre après un ajout ou un retrait : sans cela, la page se
            rechargeait repliée et le geste paraissait n'avoir rien fait. */}
        <Depliant
          titre="Intervenants techniques"
          enCarte={false}
          ouvert={["profil", "adresse", "intervenant", "retire", "remis"].includes(fait ?? "")}
          indice={
            reglable
              ? `${actifs.filter((i) => i.compte).length}/${actifs.length} avec profil`
              : `${actifs.length} noms`
          }
        >

          {!reglable && (
            <p className="rounded-card bg-amber-soft px-4 py-3 text-[13px] text-amber text-pretty leading-snug">
              Les noms sont là, mais donner un profil — et noter une adresse — attend une mise à
              jour de la base. Le détail et le geste à faire sont dans{" "}
              <Link href={"/administration" as Route} className="underline underline-offset-4">
                l’état de la base
              </Link>
              .
            </p>
          )}

          <p className="text-[12px] text-ink-faint text-pretty leading-snug">
            Les {actifs.length} noms proposés dans l’écran technique. Ouvrez un nom pour
            lui donner un profil — il pourra alors ouvrir l’application à son nom — et pour
            noter l’adresse où part son récapitulatif de fin de passage. Vous êtes en copie.
          </p>

          <ul className="flex flex-col gap-1.5">
            {actifs.map((i) => (
              <li key={i.nom}>
                <LigneDepliante
                  titre={i.nom}
                  detail={
                    <>
                      {i.prestataire_id ? "entreprise extérieure" : "inscrit"}
                      {i.interventions > 0 &&
                        ` · ${i.interventions} intervention${i.interventions > 1 ? "s" : ""}`}
                      {i.courriel ? " · adresse notée" : ""}
                    </>
                  }
                  marque={
                    <span
                      className={`shrink-0 px-2.5 py-1 rounded-lg text-[12px] ${
                        i.compte ? "bg-plum-soft text-plum" : "bg-surface-muted text-ink-faint"
                      }`}
                    >
                      {i.compte ? "profil ✓" : "pas de profil"}
                    </span>
                  }
                >
                  <div className="flex flex-col gap-2 border-t border-line pt-2.5">
                    <form action={basculerCompte} className="flex items-center gap-3">
                      <input type="hidden" name="nom" value={i.nom} />
                      <input type="hidden" name="prestataire" value={i.prestataire_id ?? ""} />
                      <span className="grow text-[13px] text-ink-soft text-pretty leading-snug">
                        {i.compte
                          ? "Apparaît au choix des profils."
                          : "N’apparaît pas au choix des profils."}
                      </span>
                      <BoutonEnvoi
                        disabled={!reglable}
                        pendant="…"
                        className={`h-[38px] px-3 rounded-[10px] text-[12.5px] shrink-0 ${
                          reglable
                            ? i.compte
                              ? "bg-surface-muted border border-line text-ink-soft"
                              : "bg-plum text-white"
                            : "bg-surface-muted border border-line text-ink-faint opacity-60"
                        }`}
                      >
                        {i.compte ? "Retirer le profil" : "Donner un profil"}
                      </BoutonEnvoi>
                    </form>

                    <form action={enregistrerCourriel} className="flex gap-2">
                      <input type="hidden" name="nom" value={i.nom} />
                      <input type="hidden" name="prestataire" value={i.prestataire_id ?? ""} />
                      <input
                        name="email"
                        type="email"
                        inputMode="email"
                        autoComplete="off"
                        disabled={!courriels}
                        defaultValue={i.courriel ?? ""}
                        placeholder={
                          courriels
                            ? "Adresse pour le récapitulatif"
                            : "Adresse — après la mise à jour"
                        }
                        className="grow min-w-0 h-[42px] px-3 rounded-[11px] border border-line bg-surface text-[15px] placeholder:text-ink-faint disabled:bg-surface-muted disabled:text-ink-faint"
                      />
                      <BoutonEnvoi
                        disabled={!courriels}
                        pendant="…"
                        className="px-3 rounded-[11px] bg-surface-muted border border-line text-[13px]"
                      >
                        Noter
                      </BoutonEnvoi>
                    </form>

                    {/* On ne supprime jamais quelqu'un : on le retire des
                        listes de saisie. Ce qu'il a fait lui reste attaché. */}
                    <form action={basculerIntervenant} className="self-start">
                      <input type="hidden" name="nom" value={i.nom} />
                      <input type="hidden" name="prestataire" value={i.prestataire_id ?? ""} />
                      <BoutonEnvoi
                        pendant="…"
                        className="text-[12.5px] text-ink-faint underline underline-offset-4"
                      >
                        Retirer de la liste
                      </BoutonEnvoi>
                    </form>
                  </div>
                </LigneDepliante>
              </li>
            ))}
            {actifs.length === 0 && (
              <li className="carte px-3.5 py-3 text-[13px] text-ink-faint">
                Aucun intervenant actif.
              </li>
            )}
          </ul>

          <form action={ajouterIntervenant} className="flex gap-2">
            <input
              name="nom"
              autoComplete="off"
              placeholder="Renfort ponctuel à ajouter…"
              className="carte grow min-w-0 px-4 h-[46px] text-[16px] placeholder:text-ink-faint"
            />
            <BoutonEnvoi
              pendant="…"
              className="px-4 rounded-card bg-plum text-white text-[14.5px]"
            >
              Ajouter
            </BoutonEnvoi>
          </form>

          {retires.length > 0 && (
            <Depliant
              titre="Retirés de la liste"
              aide="Leur travail reste attaché à leur nom. Un appui les remet."
              indice={`${retires.length} personne${retires.length > 1 ? "s" : ""}`}
            >
              <ul className="flex flex-col gap-2">
                {retires.map((i) => (
                  <li key={i.nom} className="flex items-center gap-3">
                    <span className="grow min-w-0">
                      <span className="block text-[14.5px] text-ink-faint">{i.nom}</span>
                      <span className="block text-[11.5px] text-ink-faint">
                        {i.interventions > 0
                          ? `${i.interventions} intervention${i.interventions > 1 ? "s" : ""} à son nom`
                          : "aucune intervention"}
                      </span>
                    </span>
                    <form action={basculerIntervenant} className="shrink-0">
                      <input type="hidden" name="nom" value={i.nom} />
                      <input type="hidden" name="prestataire" value={i.prestataire_id ?? ""} />
                      <input type="hidden" name="remettre" value="1" />
                      <BoutonEnvoi
                        pendant="…"
                        className="h-[36px] px-3 rounded-[10px] bg-plum-soft text-plum text-[12.5px]"
                      >
                        Remettre
                      </BoutonEnvoi>
                    </form>
                  </li>
                ))}
              </ul>
            </Depliant>
          )}
        </Depliant>

      </div>
    </main>
  );
}
