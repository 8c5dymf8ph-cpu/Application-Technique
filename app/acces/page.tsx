import type { Route } from "next";
import { cookies, headers } from "next/headers";
import { redirect } from "next/navigation";
import {
  COOKIE_ACCES,
  ESSAIS_PERMIS,
  adresseDe,
  attente,
  codeJuste,
  etatAcces,
  jeton,
  noterEssai,
} from "@/lib/acces-hotel";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";

export const dynamic = "force-dynamic";

/** On ne revient que vers un écran de l'application, jamais vers un autre site. */
function suiteSure(suite: string): string {
  return suite.startsWith("/") && !suite.startsWith("//") && !suite.startsWith("/acces")
    ? suite
    : "/";
}

async function entrer(donnees: FormData) {
  "use server";
  const suite = suiteSure(String(donnees.get("suite") ?? "/"));
  const retour = (q: string) =>
    `/acces?${q}${suite !== "/" ? `&suite=${encodeURIComponent(suite)}` : ""}`;

  const etat = await etatAcces();
  if (!etat.actif) redirect(suite as Route);

  const ip = adresseDe(await headers());
  const bloque = await attente(ip);
  if (bloque.bloque) redirect(retour(`attente=${bloque.minutes}`) as Route);

  const code = String(donnees.get("code") ?? "");
  const juste = code.trim().length > 0 && (await codeJuste(code));
  await noterEssai(ip, juste);
  if (!juste) redirect(retour("erreur=code") as Route);

  const { valeur, expire } = jeton(etat);
  (await cookies()).set(COOKIE_ACCES, valeur, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    expires: expire,
  });
  redirect(suite as Route);
}

export default async function Acces({
  searchParams,
}: {
  searchParams: Promise<{ suite?: string; erreur?: string; attente?: string }>;
}) {
  const q = await searchParams;
  const etat = await etatAcces();
  // Rien à demander : la porte est ouverte.
  if (!etat.actif) redirect(suiteSure(q.suite ?? "/") as Route);

  const minutes = Number(q.attente ?? 0);

  return (
    <main className="min-h-dvh px-5 pt-16 pb-10 flex flex-col gap-8 max-w-md mx-auto">
      <div className="flex flex-col gap-1">
        <h1 className="font-display font-bold text-[32px] leading-tight">Hôtel Parisianer</h1>
        <p className="text-[14px] text-ink-faint">Application technique</p>
      </div>

      <form action={entrer} className="relief rounded-[24px] px-5 py-6 flex flex-col gap-4">
        <input type="hidden" name="suite" value={q.suite ?? "/"} />
        <label className="flex flex-col gap-2">
          <span className="titre text-[17px]">Code d’accès de l’hôtel</span>
          <span className="text-[13px] text-ink-soft text-pretty leading-snug">
            Demandé une fois sur cet appareil, puis retenu trente jours.
          </span>
          <input
            name="code"
            type="password"
            required
            autoFocus
            autoComplete="current-password"
            autoCapitalize="none"
            autoCorrect="off"
            spellCheck={false}
            className="h-[52px] rounded-[14px] px-4 text-[18px] tracking-[0.12em]"
          />
        </label>

        {q.erreur === "code" && (
          <p role="alert" className="rounded-card bg-red-soft px-3.5 py-2.5 text-[13px] text-red text-pretty">
            Ce n’est pas le bon code. Après {ESSAIS_PERMIS} erreurs, cet appareil devra patienter
            quelques minutes.
          </p>
        )}
        {minutes > 0 && (
          <p role="alert" className="rounded-card bg-amber-soft px-3.5 py-2.5 text-[13px] text-amber text-pretty">
            Trop d’essais depuis ce réseau. Réessayez dans {minutes} minute
            {minutes > 1 ? "s" : ""}.
          </p>
        )}

        <BoutonEnvoi
          pendant="Vérification…"
          className="h-[52px] rounded-[14px] bg-plum text-white font-display font-semibold text-[16px]"
        >
          Entrer
        </BoutonEnvoi>
      </form>

      <p className="text-[12.5px] text-ink-faint text-pretty leading-snug">
        Le code est le même pour toute l’équipe ; Miguel le change depuis l’administration.
      </p>
    </main>
  );
}
