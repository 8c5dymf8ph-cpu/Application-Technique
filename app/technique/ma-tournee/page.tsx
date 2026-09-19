import { redirect } from "next/navigation";
import Link from "next/link";
import type { Route } from "next";
import { profilActif } from "@/lib/profil";
import { intervenants } from "@/lib/tournee";
import { Entete } from "@/app/composants/ui";

export const dynamic = "force-dynamic";

/**
 * « Ma tournée » — l'adresse fixe d'un intervenant.
 *
 * L'accueil pointait vers /technique/<son nom>. Si ce nom n'était pas
 * exactement celui de la liste des intervenants — une capitale, une espace en
 * trop reprise d'un export — la page répondait 404, sans rien expliquer. Le
 * nom ne voyage plus dans l'adresse : il se lit depuis le profil actif, et la
 * comparaison ne s'arrête pas à la casse.
 */
export default async function MaTournee() {
  const profil = await profilActif();
  if (!profil) redirect("/profil");

  const cle = (s: string) => s.trim().toLowerCase();
  const moi = (await intervenants()).find((i) => cle(i.nom) === cle(profil.nom));

  if (moi) redirect(`/technique/${encodeURIComponent(moi.nom)}` as Route);

  // Plutôt qu'une page d'erreur : dire ce qui manque, et à qui le demander.
  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre="Ma tournée" retour="/" />
      <div className="px-5 py-6 flex flex-col gap-4">
        <p className="text-[15px] text-ink-soft text-pretty leading-relaxed">
          <strong>{profil.nom}</strong> ne figure pas dans la liste des intervenants
          techniques : aucune tournée ne peut lui être ouverte.
        </p>
        <p className="text-[14px] text-ink-faint text-pretty leading-relaxed">
          C’est un réglage, pas une panne. Miguel ou Victoria peuvent l’ajouter depuis
          l’écran Équipe, en un appui.
        </p>
        <Link
          href={"/administration/equipe" as Route}
          className="carte px-4 py-3.5 text-[15px] text-center active:bg-surface-muted"
        >
          Ouvrir l’écran Équipe
        </Link>
      </div>
    </main>
  );
}
