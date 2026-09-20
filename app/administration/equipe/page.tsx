import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
import { colonneExiste } from "@/lib/schema";
import { profilActif } from "@/lib/profil";
import { LIBELLE_ROLE, peutValider, type RoleUtilisateur } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";

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
  searchParams: Promise<{ deja?: string; role?: string }>;
}) {
  const { deja, role: roleDeja } = await searchParams;
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
  const reglable = await colonneExiste("utilisateurs", "peut_se_connecter");
  const intervenants = reglable
    ? await sql<Intervenant[]>`
        select v.nom, v.prestataire_id, v.utilisateur_id,
               coalesce(u.peut_se_connecter, false) as compte,
               coalesce(u.email, p.email)           as courriel,
               (select count(*) from interventions i
                 where i.technicien_id is not distinct from v.utilisateur_id
                   and i.prestataire_id is not distinct from v.prestataire_id)::int
                 as interventions
          from v_intervenants v
          left join utilisateurs u on u.id = v.utilisateur_id
          left join prestataires p on p.id = v.prestataire_id
         where v.actif order by v.nom`
    : [];


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
  }

  async function ajouterIntervenant(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    const nom = String(donnees.get("nom") ?? "").trim();
    if (!nom) return;
    // Un renfort ponctuel : il existe, il intervient, et il se retire d'un
    // appui quand il repart. Rien de ce qu'il a fait ne disparaît avec lui.
    await sql`
      insert into utilisateurs (nom, role, intervient_technique, actif)
      values (${nom}, 'technicien', true, true)
      on conflict (nom) do update set intervient_technique = true, actif = true`;
    revalidatePath("/administration/equipe");
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
            <section key={g.cle} className="flex flex-col gap-2">
              <h2 className="etiquette">{g.titre}</h2>
              <p className="text-[11.5px] text-ink-faint text-pretty leading-snug -mt-1">
                {g.aide}
              </p>

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
            </section>
          );
        })}

        {/* Les intervenants techniques */}
        <section className="flex flex-col gap-2">
          <h2 className="etiquette">Intervenants techniques</h2>
          <p className="text-[12px] text-ink-faint text-pretty leading-snug -mt-1">
            Les {intervenants.length} noms proposés dans l’écran technique. Cochez « profil »
            pour que la personne puisse ouvrir l’application à son nom, et donnez son adresse
            pour qu’elle reçoive son récapitulatif à la fin de chaque passage — vous êtes en
            copie.
          </p>

          <ul className="flex flex-col gap-2">
            {intervenants.map((i) => (
              <li key={i.nom} className="carte px-3.5 py-3 flex flex-col gap-2">
                <div className="flex items-center gap-3">
                  <span className="grow min-w-0">
                    <span className="block text-[15.5px]">{i.nom}</span>
                    <span className="block text-[12px] text-ink-faint">
                      {i.prestataire_id ? "entreprise extérieure" : "inscrit"}
                      {i.interventions > 0 &&
                        ` · ${i.interventions} intervention${i.interventions > 1 ? "s" : ""}`}
                    </span>
                  </span>
                  <form action={basculerCompte}>
                    <input type="hidden" name="nom" value={i.nom} />
                    <input
                      type="hidden"
                      name="prestataire"
                      value={i.prestataire_id ?? ""}
                    />
                    <button
                      className={`h-[38px] px-3 rounded-[10px] text-[12.5px] ${
                        i.compte
                          ? "bg-plum-soft text-plum"
                          : "bg-surface-muted border border-line text-ink-soft"
                      }`}
                    >
                      {i.compte ? "profil ✓" : "pas de profil"}
                    </button>
                  </form>
                </div>

                <form action={enregistrerCourriel} className="flex gap-2">
                  <input type="hidden" name="nom" value={i.nom} />
                  <input type="hidden" name="prestataire" value={i.prestataire_id ?? ""} />
                  <input
                    name="email"
                    type="email"
                    inputMode="email"
                    autoComplete="off"
                    defaultValue={i.courriel ?? ""}
                    placeholder="Adresse pour le récapitulatif"
                    className="grow min-w-0 h-[42px] px-3 rounded-[11px] border border-line bg-surface text-[15px] placeholder:text-ink-faint"
                  />
                  <button className="px-3 rounded-[11px] bg-surface-muted border border-line text-[13px]">
                    Noter
                  </button>
                </form>
              </li>
            ))}
          </ul>
        </section>
      </div>
    </main>
  );
}
