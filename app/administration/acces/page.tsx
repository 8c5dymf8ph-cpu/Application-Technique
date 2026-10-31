import type { Route } from "next";
import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import {
  COOKIE_ACCES,
  DUREE_ACCES_JOURS,
  LONGUEUR_MINIMALE,
  etatAcces,
  jeton,
  poserCode,
} from "@/lib/acces-hotel";
import { Confirmation, Entete } from "@/app/composants/ui";
import { BoutonEnvoi } from "@/app/composants/bouton-envoi";

export const dynamic = "force-dynamic";

/**
 * Le code de l'hôtel : le poser, le changer.
 *
 * Réservé à l'administrateur. Changer le code met tous les appareils dehors —
 * c'est le geste quand quelqu'un quitte l'hôtel —, sauf celui d'où on le
 * change : se fermer la porte au nez en la verrouillant n'aurait pas de sens.
 */
async function changerLeCode(donnees: FormData) {
  "use server";
  const p = await profilActif();
  if (!p || p.role !== "admin") redirect("/administration" as Route);

  const code = String(donnees.get("code") ?? "").trim();
  const encore = String(donnees.get("encore") ?? "").trim();
  if (code.length < LONGUEUR_MINIMALE) redirect("/administration/acces?fait=code-court" as Route);
  if (code !== encore) redirect("/administration/acces?fait=code-different" as Route);

  await poserCode(code, p.id);
  const { valeur, expire } = jeton(await etatAcces());
  (await cookies()).set(COOKIE_ACCES, valeur, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    expires: expire,
  });
  redirect("/administration/acces?fait=code-pose" as Route);
}

export default async function CodeAcces({
  searchParams,
}: {
  searchParams: Promise<{ fait?: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  if (profil.role !== "admin") redirect("/administration");
  const { fait } = await searchParams;

  const etat = await etatAcces();
  const [refus] = etat.pret
    ? await sql<{ n: number }[]>`
        select count(*)::int as n from acces_essais
         where not reussi and le > now() - interval '1 day'`
    : [{ n: 0 }];

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Code d’accès" sous_titre="Qui peut ouvrir l’application" retour="/administration" />

      <div className="px-5 py-5 flex flex-col gap-5">
        <Confirmation quoi={fait} />

        {!etat.pret ? (
          <p className="rounded-card bg-amber-soft px-4 py-3 text-[13.5px] text-amber text-pretty leading-snug">
            La base ne sait pas encore garder un code. Ouvrez « État de l’application » et
            jouez les migrations, puis revenez ici.
          </p>
        ) : etat.actif ? (
          <section className="carte px-4 py-4 flex flex-col gap-1.5">
            <span className="titre text-[17px]">La porte est fermée</span>
            <p className="text-[13.5px] text-ink-soft text-pretty leading-snug">
              Il faut le code de l’hôtel pour ouvrir l’application, ses photos et ses exports.
              Un appareil qui l’a donné le garde {DUREE_ACCES_JOURS} jours.
              {etat.changeLe &&
                ` Code posé le ${new Date(etat.changeLe).toLocaleDateString("fr-FR")}.`}
            </p>
            {refus.n > 0 && (
              <p className="text-[12.5px] text-amber">
                {refus.n} code{refus.n > 1 ? "s" : ""} refusé{refus.n > 1 ? "s" : ""} ces
                dernières 24 heures.
              </p>
            )}
          </section>
        ) : (
          <p className="rounded-card bg-red-soft px-4 py-3 text-[13.5px] text-red text-pretty leading-snug">
            Aucun code : l’application est ouverte à quiconque connaît son adresse — coûts,
            factures, exports compris. Choisissez-en un ci-dessous.
          </p>
        )}

        {etat.pret && (
          <form action={changerLeCode} className="carte px-4 py-4 flex flex-col gap-3">
            <span className="titre text-[17px]">
              {etat.actif ? "Changer le code" : "Choisir le code"}
            </span>
            <label className="flex flex-col gap-1">
              <span className="etiquette">Nouveau code — {LONGUEUR_MINIMALE} caractères au moins</span>
              <input
                name="code"
                type="password"
                required
                minLength={LONGUEUR_MINIMALE}
                autoComplete="new-password"
                autoCapitalize="none"
                autoCorrect="off"
                spellCheck={false}
                className="h-[48px] rounded-[12px] px-3"
              />
            </label>
            <label className="flex flex-col gap-1">
              <span className="etiquette">Le même, une seconde fois</span>
              <input
                name="encore"
                type="password"
                required
                minLength={LONGUEUR_MINIMALE}
                autoComplete="new-password"
                autoCapitalize="none"
                autoCorrect="off"
                spellCheck={false}
                className="h-[48px] rounded-[12px] px-3"
              />
            </label>
            {etat.actif && (
              <p className="text-[12.5px] text-ink-faint text-pretty leading-snug">
                Tous les autres appareils devront saisir le nouveau code. C’est aussi le geste
                à faire quand quelqu’un quitte l’hôtel.
              </p>
            )}
            <BoutonEnvoi
              pendant="Enregistrement…"
              className="h-[50px] rounded-[13px] bg-plum text-white font-display font-semibold text-[15.5px]"
            >
              {etat.actif ? "Changer le code" : "Fermer la porte avec ce code"}
            </BoutonEnvoi>
          </form>
        )}

        <details className="text-[12.5px] text-ink-faint">
          <summary className="cursor-pointer text-ink-soft">Si le code est perdu</summary>
          <p className="pt-2 text-pretty leading-snug">
            Dans Supabase, éditeur SQL :{" "}
            <code className="text-ink">update acces_hotel set code_empreinte = null;</code> —
            la porte se rouvre, et l’on choisit un nouveau code ici.
          </p>
        </details>
      </div>
    </main>
  );
}
