import { redirect } from "next/navigation";
import { choisirProfil, profilsDisponibles } from "@/lib/profil";
import { LIBELLE_ROLE } from "@/lib/domaine";

export const dynamic = "force-dynamic";

export default async function ChoixProfil() {
  const profils = await profilsDisponibles();

  async function selectionner(donnees: FormData) {
    "use server";
    await choisirProfil(String(donnees.get("id")));
    redirect("/");
  }

  return (
    <main className="min-h-dvh px-5 py-10 flex flex-col gap-7 max-w-md mx-auto">
      <div className="flex flex-col gap-1">
        <p className="etiquette">Hôtel Parisianer</p>
        <h1 className="font-display font-bold text-[32px] leading-tight">Qui êtes-vous&nbsp;?</h1>
        <p className="text-[14px] text-ink-soft text-pretty">
          Ce choix détermine ce que vous voyez, et reste attaché à tout ce que vous
          enregistrez.
        </p>
      </div>

      <form action={selectionner} className="flex flex-col gap-2">
        {profils.map((p) => (
          <button
            key={p.id}
            name="id"
            value={p.id}
            className="carte px-4 py-4 flex items-center gap-4 text-left active:bg-surface-muted"
          >
            <span className="w-11 h-11 shrink-0 rounded-full bg-plum-soft grid place-items-center font-display font-semibold text-[15px] text-plum">
              {p.nom.slice(0, 2).toUpperCase()}
            </span>
            <span className="flex flex-col grow min-w-0">
              <span className="font-display font-semibold text-[17px]">{p.nom}</span>
              <span className="text-[12.5px] text-ink-faint">{LIBELLE_ROLE[p.role]}</span>
            </span>
          </button>
        ))}
      </form>
    </main>
  );
}
