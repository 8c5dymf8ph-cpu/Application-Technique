import { LIBELLE_STATUT } from "@/lib/domaine";

export type Message = {
  commentaire_id: string;
  source: string;
  auteur: string | null;
  texte: string;
  date_commentaire: string;
  decision: string | null;
};

const TON: Record<string, { fond: string; texte: string; nom: string }> = {
  technicien: { fond: "bg-blue-soft", texte: "text-blue", nom: "Technicien" },
  gouvernante: { fond: "bg-amber-soft", texte: "text-amber", nom: "Gouvernante" },
  reprise: { fond: "bg-surface-muted", texte: "text-ink-faint", nom: "Reprise" },
  commentaire: { fond: "bg-surface", texte: "text-ink-soft", nom: "" },
};

const DECISION: Record<string, string> = {
  fait: "a déclaré fait",
  non_fait: "n’a pas pu faire",
  validee: "a validé",
  a_refaire: "demande de refaire",
  en_cours: "a mis en cours",
};

/**
 * Le fil d'une anomalie. Chaque avis garde son auteur, sa date et sa couleur ;
 * un nouveau commentaire s'ajoute dessous, il n'en remplace jamais un autre.
 */
export function Fil({ messages }: { messages: Message[] }) {
  if (messages.length === 0) {
    return <p className="text-[13.5px] text-ink-faint">Aucun commentaire pour l’instant.</p>;
  }
  return (
    <ul className="flex flex-col gap-2">
      {messages.map((m) => {
        const ton = TON[m.source] ?? TON.commentaire;
        return (
          <li
            key={m.commentaire_id}
            className={`${ton.fond} ${ton.fond === "bg-surface" ? "border border-line" : ""} rounded-card px-4 py-3 flex flex-col gap-1.5`}
          >
            <p className={`text-[11px] uppercase tracking-[0.08em] ${ton.texte}`}>
              {m.auteur ?? (ton.nom || "Système")}
              {m.decision && ` · ${DECISION[m.decision] ?? LIBELLE_STATUT.a_faire}`}
              {" · "}
              {new Date(m.date_commentaire).toLocaleDateString("fr-FR", {
                day: "numeric",
                month: "short",
                year: "numeric",
              })}
            </p>
            <p className="text-[14px] leading-snug text-ink text-pretty whitespace-pre-line">
              {m.texte}
            </p>
          </li>
        );
      })}
    </ul>
  );
}

/** La zone de saisie d'un commentaire, identique partout. */
export function ChampCommentaire({
  nom = "commentaire",
  libelle = "Commentaire (facultatif)",
  lignes = 3,
}: {
  nom?: string;
  libelle?: string;
  lignes?: number;
}) {
  return (
    <label className="flex flex-col gap-1.5">
      <span className="etiquette">{libelle}</span>
      <textarea
        name={nom}
        rows={lignes}
        className="carte px-4 py-3 text-[15px] leading-snug resize-none placeholder:text-ink-faint"
        placeholder="Ce qu’il faut savoir…"
      />
    </label>
  );
}
