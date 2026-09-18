import type { Profil } from "@/lib/profil";

/**
 * Qui a constaté, et à qui c'est remonté.
 *
 * Deux questions que la gouvernante doit pouvoir répondre en deux appuis : ce
 * n'est presque jamais elle qui a vu la bouteille manquante, et ce n'est jamais
 * elle qui écrit au client. Les prénoms sont montrés en clair — une liste de
 * huit personnes n'a pas besoin d'un menu déroulant.
 */
export function ChoixPrenom({
  nom,
  libelle,
  aide,
  personnes,
  defaut,
  facultatif = false,
}: {
  nom: string;
  libelle: string;
  aide?: string;
  personnes: Profil[];
  defaut?: string;
  facultatif?: boolean;
}) {
  const initiales = (n: string) =>
    n
      .split(/[\s-]+/)
      .slice(0, 2)
      .map((m) => m[0])
      .join("")
      .toUpperCase();

  return (
    <fieldset className="flex flex-col gap-2">
      <legend className="etiquette mb-2">{libelle}</legend>
      <div className="flex flex-wrap gap-2">
        {facultatif && (
          <label className="rounded-pill border border-line bg-surface h-[46px] px-4 flex items-center text-[13.5px] text-ink-faint cursor-pointer has-[:checked]:border-plum has-[:checked]:bg-plum-soft has-[:checked]:text-plum">
            <input type="radio" name={nom} value="" defaultChecked={!defaut} className="sr-only" />
            Personne
          </label>
        )}
        {personnes.map((p) => (
          <label
            key={p.id}
            className="rounded-pill border border-line bg-surface h-[46px] pl-1.5 pr-4 flex items-center gap-2 text-[14px] cursor-pointer has-[:checked]:border-plum has-[:checked]:bg-plum-soft"
          >
            <input
              type="radio"
              name={nom}
              value={p.id}
              defaultChecked={defaut === p.id}
              className="sr-only"
            />
            <span
              aria-hidden
              className="w-[34px] h-[34px] rounded-full bg-plum-soft grid place-items-center font-display text-[12px] text-plum"
            >
              {initiales(p.nom)}
            </span>
            {p.nom}
          </label>
        ))}
      </div>
      {aide && <p className="text-[11.5px] text-ink-faint text-pretty">{aide}</p>}
    </fieldset>
  );
}
