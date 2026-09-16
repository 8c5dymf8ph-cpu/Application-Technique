import { notFound, redirect } from "next/navigation";
import { revalidatePath } from "next/cache";
import { sql } from "@/lib/db";
import { profilActif } from "@/lib/profil";
import { jours, LIBELLE_STATUT, TON_STATUT, type StatutAnomalie } from "@/lib/domaine";
import { Entete } from "@/app/composants/ui";
import { ChampPhotos, Vignettes } from "@/app/composants/photos";
import { ChampCommentaire, Fil, type Message } from "@/app/composants/fil";
import { enregistrerPhoto } from "@/lib/stockage";

export const dynamic = "force-dynamic";

type Anomalie = {
  id: string;
  reference: number;
  description: string;
  statut: StatutAnomalie;
  emplacement: string;
  etage: string;
  constate_par: string | null;
  jours_depuis: number;
};

export default async function DetailAnomalie({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const profil = await profilActif();
  if (!profil) redirect("/profil");
  const { id } = await params;

  const [anomalie] = await sql<Anomalie[]>`
    select anomalie_id as id, reference, description, statut, emplacement,
           (select et.nom from etages et join emplacements e on e.etage_id = et.id
             where e.id = v.emplacement_id) as etage,
           constate_par, jours_depuis
    from v_anomalies_du_lieu v where anomalie_id = ${id}`;
  if (!anomalie) notFound();

  const messages = await sql<Message[]>`
    select commentaire_id, source, auteur, texte, date_commentaire, decision::text
    from v_fil_commentaires where anomalie_id = ${id}
    order by date_commentaire`;

  const photos = await sql<{ chemin: string; moment: string }[]>`
    select chemin, moment::text from photos_anomalie
    where anomalie_id = ${id} order by prise_le`;

  async function commenter(donnees: FormData) {
    "use server";
    const profil_ = await profilActif();
    if (!profil_) redirect("/profil");

    const texte = String(donnees.get("commentaire") ?? "").trim();
    if (texte) {
      await sql`
        insert into commentaires (anomalie_id, texte, auteur_id, saisie_par)
        values (${id}, ${texte}, ${profil_.id}, ${profil_.id})`;
    }

    for (const fichier of donnees.getAll("photos")) {
      if (!(fichier instanceof File)) continue;
      const chemin = await enregistrerPhoto(fichier);
      if (!chemin) continue;
      await sql`
        insert into photos_anomalie (anomalie_id, chemin, moment, prise_par)
        values (${id}, ${chemin}, 'constat', ${profil_.id})`;
    }

    revalidatePath(`/anomalie/${id}`);
  }

  return (
    <main className="min-h-dvh flex flex-col max-w-md mx-auto">
      <Entete titre={anomalie.emplacement} sous_titre={anomalie.etage} />

      <div className="px-5 py-5 flex flex-col gap-6">
        <div className="flex flex-col gap-2">
          <h1 className="font-display font-semibold text-[19px] leading-snug text-pretty">
            {anomalie.description}
          </h1>
          <p className="flex flex-wrap items-center gap-2 text-[11.5px]">
            <span
              className={`px-2 py-0.5 rounded-md ${TON_STATUT[anomalie.statut].fond} ${TON_STATUT[anomalie.statut].texte}`}
            >
              {LIBELLE_STATUT[anomalie.statut]}
            </span>
            <span className="text-ink-faint">
              {anomalie.constate_par ? `${anomalie.constate_par}, ` : ""}
              {jours(anomalie.jours_depuis)}
            </span>
          </p>
        </div>

        <Vignettes
          chemins={photos.filter((p) => p.moment === "constat").map((p) => p.chemin)}
          titre="Au constat"
          ton="text-blue"
        />
        <Vignettes
          chemins={photos.filter((p) => p.moment === "apres").map((p) => p.chemin)}
          titre="Après intervention"
          ton="text-green"
        />

        <section className="flex flex-col gap-2.5">
          <h2 className="etiquette">Le fil · {messages.length}</h2>
          <Fil messages={messages} />
        </section>

        <form action={commenter} className="flex flex-col gap-3 border-t border-line pt-5">
          <ChampCommentaire libelle="Ajouter un commentaire" />
          <ChampPhotos libelle="Ajouter une photo" />
          <button className="h-[50px] rounded-[14px] bg-plum text-white font-display font-semibold text-[15px]">
            Ajouter au fil
          </button>
        </form>
      </div>
    </main>
  );
}
