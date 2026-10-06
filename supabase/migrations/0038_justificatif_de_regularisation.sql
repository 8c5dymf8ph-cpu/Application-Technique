-- =============================================================================
-- Migration 0038 : une régularisation peut porter sa pièce jointe
-- =============================================================================
-- « Régulariser le parc » (`/administration/bouteilles`) pose un mouvement
-- tracé sans dossier (règle 4) — le seul motif qu'on garde est le texte libre
-- du commentaire. Pour la régularisation de mai (« Eventuelles 2 loupés — mail
-- de Sarah »), Miguel veut joindre le mail lui-même : sans ça, la seule trace
-- de pourquoi reste une phrase, alors que le mail existe et vaut preuve.
--
-- Même principe que `factures.fichier_url` : un nom de fichier, stocké par
-- `lib/stockage.ts` (Supabase Storage ou disque selon l'environnement),
-- jamais le contenu. Nullable et a posteriori — la plupart des
-- régularisations n'ont rien à joindre, et celles déjà en base doivent
-- pouvoir recevoir leur pièce après coup.
alter table mouvements_bouteilles
  add column piece_jointe_url text;

comment on column mouvements_bouteilles.piece_jointe_url is
  'Justificatif d''une régularisation (mail, photo, PDF) — comme '
  'factures.fichier_url, jamais obligatoire, ajoutable après coup.';
