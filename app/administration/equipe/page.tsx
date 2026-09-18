import { redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import Link from "next/link";
import type { Route } from "next";
import { sql } from "@/lib/db";
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
  id: string;
  nom: string;
  role: RoleUtilisateur;
  interventions: number;
};

/** Les deux listes qui bougent souvent : l'étage et la réception. */
const GERABLES: { role: RoleUtilisateur; titre: string; aide: string }[] = [
  {
    role: "menage",
    titre: "Femmes de chambre",
    aide: "Elles constatent les bouteilles manquantes. Elles n’utilisent pas l’application.",
  },
  {
    role: "reception",
    titre: "Réception",
    aide: "C’est à elles et eux que la gouvernante transmet le dossier.",
  },
];

export default async function Equipe() {
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
    where u.role in ('menage', 'reception')
    order by u.actif desc, u.role, u.nom`;

  // Qui figure dans la liste des intervenants techniques. Elle ne se déduit pas
  // d'un rôle : la chargée des opérations n'intervient pas, le réceptionniste
  // qui donne un coup de main, si.
  const intervenants = await sql<Intervenant[]>`
    select u.id, u.nom, u.role,
           (select count(*) from interventions i where i.technicien_id = u.id)::int
             as interventions
    from utilisateurs u
    where u.actif and u.intervient_technique
    order by u.nom`;

  const disponibles = await sql<Intervenant[]>`
    select u.id, u.nom, u.role, 0::int as interventions
    from utilisateurs u
    where u.actif and not u.intervient_technique
    order by u.nom`;

  async function basculerIntervenant(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_ || !peutValider(profil_.role)) redirect("/");
    // Retirer quelqu'un de la liste ne touche pas aux tournées qu'il a faites :
    // elles gardent son nom.
    await sql`
      update utilisateurs
         set intervient_technique = not intervient_technique
       where id = ${String(donnees.get("personne"))}`;
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
      <Entete titre="L’équipe" sous_titre="Qui constate, à qui l’on transmet" retour="/bouteilles" />

      <div className="px-5 py-4 flex flex-col gap-6">
        <p className="text-[13px] text-ink-soft text-pretty leading-snug">
          Retirer quelqu’un ne l’efface pas : son prénom disparaît des listes de saisie, mais
          reste sur les dossiers qu’il a constatés. Le réajouter lui rend sa place.
        </p>

        {GERABLES.map((g) => {
          const dedans = personnes.filter((p) => p.role === g.role);
          return (
            <section key={g.role} className="flex flex-col gap-2">
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
                        {p.citations === 0
                          ? "aucun dossier"
                          : `${p.citations} dossier${p.citations > 1 ? "s" : ""}`}
                      </span>
                    </span>
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
                  </li>
                ))}
                {dedans.length === 0 && (
                  <li className="px-3.5 py-3 text-[13px] text-ink-faint">Personne pour l’instant.</li>
                )}
              </ul>

              <form action={ajouter} className="flex gap-2">
                <input type="hidden" name="role" value={g.role} />
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
          <p className="text-[11.5px] text-ink-faint text-pretty leading-snug -mt-1">
            Ceux qui apparaissent dans l’écran technique. Retirer quelqu’un ne touche pas aux
            tournées qu’il a faites : elles gardent son nom.
          </p>

          <ul className="carte divide-y divide-line">
            {intervenants.map((i) => (
              <li key={i.id} className="px-3.5 py-2.5 flex items-center gap-3">
                <span className="grow min-w-0">
                  <span className="block text-[15px]">{i.nom}</span>
                  <span className="block text-[11.5px] text-ink-faint">
                    {LIBELLE_ROLE[i.role]}
                    {i.interventions > 0 &&
                      ` · ${i.interventions} intervention${i.interventions > 1 ? "s" : ""}`}
                  </span>
                </span>
                <form action={basculerIntervenant}>
                  <input type="hidden" name="personne" value={i.id} />
                  <button className="h-[38px] px-3 rounded-[10px] bg-surface-muted border border-line text-[12.5px] text-ink-soft">
                    Retirer
                  </button>
                </form>
              </li>
            ))}
          </ul>

          {disponibles.length > 0 && (
            <details className="carte px-3.5 py-3">
              <summary className="text-[12.5px] text-plum underline underline-offset-4 cursor-pointer list-none">
                Ajouter quelqu’un qui existe déjà
              </summary>
              <ul className="mt-2 flex flex-col gap-1.5">
                {disponibles.map((d) => (
                  <li key={d.id} className="flex items-center gap-3">
                    <span className="grow min-w-0">
                      <span className="block text-[14px]">{d.nom}</span>
                      <span className="block text-[11px] text-ink-faint">
                        {LIBELLE_ROLE[d.role]}
                      </span>
                    </span>
                    <form action={basculerIntervenant}>
                      <input type="hidden" name="personne" value={d.id} />
                      <button className="h-[36px] px-3 rounded-[10px] bg-plum-soft text-plum text-[12.5px]">
                        Ajouter
                      </button>
                    </form>
                  </li>
                ))}
              </ul>
            </details>
          )}

          <form action={ajouterIntervenant} className="flex gap-2">
            <input
              name="nom"
              autoComplete="off"
              placeholder="Un renfort, un nouveau nom…"
              className="carte grow min-w-0 px-4 h-[46px] text-[16px] placeholder:text-ink-faint"
            />
            <button className="px-4 rounded-card bg-plum text-white text-[14.5px]">Ajouter</button>
          </form>
          <p className="text-[11.5px] text-ink-faint text-pretty leading-snug">
            Un renfort ponctuel s’ajoute ici et se retire d’un appui quand il repart. Pour une
            entreprise extérieure qui reviendra, c’est un prestataire — dites-le moi et je
            l’ajoute au référentiel.
          </p>
        </section>

        <Link
          href={"/bouteilles" as Route}
          className="text-[12.5px] text-plum underline underline-offset-4 self-start"
        >
          Retour aux bouteilles
        </Link>
      </div>
    </main>
  );
}
