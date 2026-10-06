-- =============================================================================
-- Migration 0040 : un inventaire porte sa pièce jointe, son commentaire se voit
-- =============================================================================
-- `inventaires.commentaire` existe depuis la 0001 — personne ne l'a jamais
-- lu ni écrit. Et un inventaire, comme une régularisation manuelle (0038),
-- peut avoir besoin d'un justificatif ajouté après coup : Miguel veut
-- documenter un comptage déjà validé sans avoir à le refaire.
--
-- Les deux s'ajoutent, à tout moment, sur un brouillon comme sur un
-- comptage validé (règle 12 : un commentaire peut s'ajouter des mois plus
-- tard) — rien n'efface le texte auto-écrit par
-- `fn_valider_inventaire_bouteilles` sur chaque mouvement de régularisation,
-- qui reste la trace du calcul (théorique, compté). Celui-ci vient en plus.
alter table inventaires
  add column piece_jointe_url text;

comment on column inventaires.piece_jointe_url is
  'Justificatif du comptage (photo, PDF) — comme mouvements_bouteilles.'
  'piece_jointe_url (0038), ajoutable à tout moment, même après validation.';
