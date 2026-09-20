import { redirect } from "next/navigation";
import type { Route } from "next";
import { choisirProfil, profilActif, profilsDisponibles } from "@/lib/profil";
import { Retour } from "@/app/composants/retour";
import { LIBELLE_ROLE } from "@/lib/domaine";

export const dynamic = "force-dynamic";

export default async function ChoixProfil() {
  const profils = await profilsDisponibles();
  // Au premier usage il n'y a rien derrière ; une fois un profil choisi, on
  // vient d'ailleurs et on doit pouvoir s'y remettre.
  const deja = await profilActif();

  // Deux groupes, parce que ce sont deux métiers : celles et ceux qui déclarent,
  // valident et suivent — et les intervenants, qui viennent traiter. Un
  // technicien se retrouve dans sa section, sans lire toute la liste.
  const sections = [
    {
      titre: "Encadrement",
      pastille: "bg-plum-soft text-plum",
      gens: profils.filter((p) => p.role !== "technicien"),
    },
    {
      titre: "Techniciens",
      pastille: "bg-green-soft text-green",
      gens: profils.filter((p) => p.role === "technicien"),
    },
  ].filter((s) => s.gens.length > 0);

  async function selectionner(donnees: FormData) {
    "use server";
    await choisirProfil(String(donnees.get("id")));
    redirect("/");
  }

  return (
    <main className="min-h-dvh px-5 py-10 flex flex-col gap-7 max-w-md mx-auto">
      {deja && (
        <Retour
          vers={"/" as Route}
          classe="w-11 h-11 shrink-0 rounded-[13px] bg-plum grid place-items-center self-start"
        />
      )}

      <div className="flex flex-col gap-1">
        <p className="etiquette">Hôtel Parisianer</p>
        <h1 className="font-display font-bold text-[32px] leading-tight">Qui êtes-vous&nbsp;?</h1>
        <p className="text-[14px] text-ink-soft text-pretty">
          Ce choix détermine ce que vous voyez, et reste attaché à tout ce que vous
          enregistrez.
        </p>
      </div>

      <form action={selectionner} className="flex flex-col gap-6">
        {sections.map((s) => (
          <section key={s.titre} className="flex flex-col gap-2">
            <h2 className="etiquette">{s.titre}</h2>
            {s.gens.map((p) => (
              <button
                key={p.id}
                name="id"
                value={p.id}
                className="carte px-4 py-4 flex items-center gap-4 text-left active:bg-surface-muted"
              >
                <span
                  className={`w-11 h-11 shrink-0 rounded-full grid place-items-center font-display font-semibold text-[16px] ${s.pastille}`}
                >
                  {p.nom.slice(0, 2).toUpperCase()}
                </span>
                <span className="flex flex-col grow min-w-0">
                  <span className="font-display font-semibold text-[18px]">{p.nom}</span>
                  <span className="text-[13px] text-ink-faint">{LIBELLE_ROLE[p.role]}</span>
                </span>
              </button>
            ))}
          </section>
        ))}
      </form>
    </main>
  );
}
