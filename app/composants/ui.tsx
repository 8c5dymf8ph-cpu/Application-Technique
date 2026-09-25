import Link from "next/link";
import { Retour } from "./retour";
import type { Route } from "next";

/** Une adresse construite à partir d'un segment dynamique. */
type Adresse = Route | (string & {});

/**
 * L'en-tête d'un écran : d'où l'on vient, où l'on est, et comment rentrer.
 *
 * Le retour remonte d'un cran. Il ne suffit pas : depuis le fil d'une anomalie
 * ouverte au bout de cinq écrans, revenir à l'accueil demandait cinq appuis, et
 * on finissait par fermer l'application pour la rouvrir. La maison, à droite,
 * ramène d'un seul geste — de n'importe où, sans rien perdre : tout ce qui est
 * enregistré l'est déjà.
 *
 * Elle est à l'opposé du retour, parce que ce sont deux gestes différents : le
 * pouce ne doit pas hésiter entre les deux.
 */
export function Entete({
  titre,
  sous_titre,
  retour,
  accueil = true,
}: {
  titre: string;
  sous_titre?: string;
  retour?: Adresse;
  /** L'accueil lui-même n'a pas besoin d'un bouton vers lui-même. */
  accueil?: boolean;
}) {
  return (
    <header className="bg-plum px-5 pb-[18px] pt-5 flex items-center gap-3">
      {retour && (
        <Retour
          vers={retour as Route}
          classe="w-11 h-11 shrink-0 rounded-[13px] bg-white/15 grid place-items-center active:bg-white/25"
        />
      )}
      <div className="min-w-0 grow">
        <h1 className="font-display font-bold text-[21px] text-white leading-tight">{titre}</h1>
        {sous_titre && <p className="text-[11.5px] text-white/70 truncate">{sous_titre}</p>}
      </div>
      {accueil && (
        <Link
          href={"/" as Route}
          aria-label="Revenir à l’accueil"
          className="w-11 h-11 shrink-0 rounded-[13px] bg-white/15 grid place-items-center active:bg-white/25"
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#fff"
               strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
            <path d="M4 10.5L12 4l8 6.5" />
            <path d="M6 9.8V19a1 1 0 001 1h10a1 1 0 001-1V9.8" />
          </svg>
        </Link>
      )}
    </header>
  );
}

export function Compteur({
  valeur,
  libelle,
  ton = "text-ink",
}: {
  valeur: number | string;
  libelle: string;
  ton?: string;
}) {
  return (
    <div className="carte px-2 py-5 flex flex-col items-center gap-1">
      <span className={`font-display font-semibold text-[30px] leading-none tabular-nums ${ton}`}>
        {valeur}
      </span>
      <span className="etiquette">{libelle}</span>
    </div>
  );
}

export function Tuile({
  href,
  titre,
  detail,
  badge,
  ton = "bg-plum-soft",
}: {
  href: Adresse;
  titre: string;
  detail: string;
  badge?: string | number;
  ton?: string;
}) {
  return (
    <Link
      href={href as Route}
      className={`${ton} rounded-tile px-5 py-[22px] flex items-center gap-4 min-h-[96px]`}
    >
      <div className="flex flex-col gap-[3px] grow min-w-0">
        <span className="font-display font-bold text-[22px] text-ink">{titre}</span>
        <span className="text-[13px] text-ink-soft">{detail}</span>
      </div>
      {badge !== undefined && badge !== 0 && (
        <span className="shrink-0 min-w-[34px] h-[34px] px-2 rounded-[10px] bg-white grid place-items-center font-display font-semibold text-[16px] text-ink tabular-nums">
          {badge}
        </span>
      )}
    </Link>
  );
}

export function Vide({ children }: { children: React.ReactNode }) {
  return (
    <p className="text-[14px] text-ink-faint text-center py-8 px-4 text-pretty">{children}</p>
  );
}

/**
 * Ce qui accompagne une anomalie : une photo du constat, un commentaire.
 * Le technicien doit le voir depuis la liste, sans ouvrir : une photo lui dit
 * ce qu'il va trouver, un commentaire lui dit ce qu'on attend de lui.
 */
export function Indices({
  photos = 0,
  commentaires = 0,
  eteint = false,
}: {
  photos?: number;
  commentaires?: number;
  eteint?: boolean;
}) {
  if (photos === 0 && commentaires === 0) return null;
  const ton = eteint ? "text-ink-faint bg-surface-muted" : "text-plum bg-plum-soft";
  return (
    <span className="flex items-center gap-1.5 shrink-0">
      {photos > 0 && (
        <span
          className={`${ton} h-[22px] pl-1.5 pr-2 rounded-md flex items-center gap-1 text-[11.5px] font-medium tabular-nums`}
          aria-label={`${photos} photo${photos > 1 ? "s" : ""}`}
        >
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
            <path d="M3 8.5A1.5 1.5 0 014.5 7h2L8 4.8h8L17.5 7h2A1.5 1.5 0 0121 8.5v9A1.5 1.5 0 0119.5 19h-15A1.5 1.5 0 013 17.5z" />
            <circle cx="12" cy="12.7" r="3.3" />
          </svg>
          {photos}
        </span>
      )}
      {commentaires > 0 && (
        <span
          className={`${ton} h-[22px] pl-1.5 pr-2 rounded-md flex items-center gap-1 text-[11.5px] font-medium tabular-nums`}
          aria-label={`${commentaires} commentaire${commentaires > 1 ? "s" : ""}`}
        >
          <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor"
               strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
            <path d="M20 12.5c0 3.9-3.6 7-8 7a9.3 9.3 0 01-2.7-.4L4.5 20.5l1.2-3.4A6.7 6.7 0 014 12.5c0-3.9 3.6-7 8-7s8 3.1 8 7z" />
          </svg>
          {commentaires}
        </span>
      )}
    </span>
  );
}

/**
 * Le mot qui confirme — ou qui alerte.
 *
 * Un geste qui réussit sans rien dire laisse douter : on recommence, ou on
 * abandonne. Un geste qui échoue sans rien dire est pire. Les écrans passent
 * donc un `?fait=` dans l'adresse après une action, et ce bandeau le rend.
 */
const MOTS: Record<string, { ton: string; texte: string }> = {
  acte: { ton: "green", texte: "Acte enregistré. La chronologie est à jour." },
  "acte-sans-piece": {
    ton: "red",
    texte:
      "Acte enregistré, mais la pièce jointe n’a pas pu l’être. " +
      "Vérifiez le dépôt des fichiers dans Administration.",
  },
  episode: { ton: "green", texte: "Épisode ouvert." },
  etat: { ton: "green", texte: "L’état de l’épisode est à jour." },
  photo: { ton: "green", texte: "Photo enregistrée." },
  photos: { ton: "green", texte: "Photos enregistrées." },
  "photo-refusee": {
    ton: "red",
    texte:
      "La photo n’a pas pu être enregistrée : elle n’apparaîtra nulle part. " +
      "Vérifiez le dépôt des fichiers dans Administration.",
  },
  enregistre: { ton: "green", texte: "Enregistré." },
  "facture-supprimee": {
    ton: "green",
    texte:
      "Facture supprimée. Les interventions qu’elle couvrait reprennent leur " +
      "coût matériel seul.",
  },
  "passage-repris": {
    ton: "green",
    texte:
      "Passage repris. Le récapitulatif n’était pas encore parti : il a été " +
      "retiré de la file, et repartira complet à la fin de la journée.",
  },
  "passage-repris-mail-parti": {
    ton: "amber",
    texte:
      "Passage repris. Le récapitulatif était DÉJÀ parti : à la fin de la " +
      "journée, un complément suivra.",
  },
  fournisseur: { ton: "green", texte: "Fournisseur enregistré." },
  montant: { ton: "green", texte: "Montant et facture enregistrés." },
  profil: { ton: "green", texte: "Réglage enregistré." },
  adresse: { ton: "green", texte: "Adresse enregistrée." },
  declare: { ton: "green", texte: "Anomalie déclarée." },
  supprime: { ton: "green", texte: "Anomalie supprimée." },
  "alerte-partie": {
    ton: "green",
    texte:
      "La réception est prévenue : le message lui est parti, prêt à être " +
      "transféré au client.",
  },
  "alerte-sans-destinataire": {
    ton: "red",
    texte:
      "Dossier enregistré, mais PERSONNE n’a été prévenu : aucune adresse n’est " +
      "notée pour l’alerte bouteille. Réglez-la dans Administration → " +
      "Destinataires des alertes.",
  },
  "alerte-eteinte": {
    ton: "red",
    texte:
      "Dossier enregistré, mais l’alerte bouteille est désactivée : la réception " +
      "n’a rien reçu. Réactivez-la dans Administration → Destinataires des alertes.",
  },
  "alerte-sans-cle": {
    ton: "red",
    texte:
      "Dossier enregistré et message rédigé, mais aucune clé d’envoi n’est " +
      "configurée : il attend dans la file et ne partira pas tant que " +
      "RESEND_API_KEY n’est pas renseignée dans Vercel.",
  },
  modifie: { ton: "green", texte: "Modification enregistrée." },
  "en-avant": {
    ton: "green",
    texte: "Mise en avant. C’est celle que le technicien voit en premier.",
  },
  "photo-retiree": { ton: "green", texte: "Photo supprimée." },
  "dossier-supprime": {
    ton: "green",
    texte:
      "Dossier supprimé. Les bouteilles qu’il avait déplacées sont revenues : " +
      "le parc est exactement ce qu’il était.",
  },
  "sans-type": {
    ton: "red",
    texte:
      "Rien n’a été enregistré : un dossier porte au moins une bouteille. " +
      "Cochez la filtrée, la gazeuse, ou les deux.",
  },
  "deja-ouverte": {
    ton: "red",
    texte:
      "Rien n’a été changé : ce même problème est déjà ouvert dans le lieu " +
      "choisi. Clôturez l’un des deux avant de les rapprocher.",
  },
  intervenant: { ton: "green", texte: "Ajouté à la liste des intervenants." },
  retire: { ton: "green", texte: "Retiré de la liste. Son historique lui reste attaché." },
  remis: { ton: "green", texte: "Remis dans la liste des intervenants." },
  "declare-sans-photo": {
    ton: "red",
    texte:
      "Anomalie déclarée, mais la photo n’a pas pu être enregistrée. " +
      "Vérifiez le dépôt des fichiers dans Administration.",
  },
  deplace: {
    ton: "green",
    texte:
      "Journée déplacée sur cette facture. Elle a quitté l’autre pièce : une " +
      "ligne portée deux fois serait comptée deux fois.",
  },
  rattache: {
    ton: "green",
    texte:
      "Ce passage fait maintenant partie de cette facture. S’il en quittait " +
      "une autre, celle-ci reste dans la liste des factures — sans journée si " +
      "elle n’en couvre plus aucune.",
  },
  lot: {
    ton: "green",
    texte:
      "Passage entièrement validé. Le récapitulatif part — avec ce qui n’a pas " +
      "été validé, dit en clair.",
  },
};

export function Confirmation({ quoi, qui }: { quoi?: string; qui?: string }) {
  const mot = quoi ? MOTS[quoi] : undefined;
  if (!mot) return null;
  return (
    <p
      className={`rounded-card px-4 py-3 text-[13.5px] text-pretty leading-snug animate-[apparait_.25s_ease-out] ${
        // Trois tons, pas deux. « Le message était déjà parti » n'est pas un
        // échec : c'est une nuance, et la peindre en rouge fait croire que
        // quelque chose s'est mal passé.
        mot.ton === "green"
          ? "bg-green-soft text-green"
          : mot.ton === "amber"
            ? "bg-amber-soft text-amber"
            : "bg-red-soft text-red"
      }`}
      role="status"
    >
      {qui ? <strong>{qui} — </strong> : null}
      {mot.texte}
    </p>
  );
}
