-- =============================================================================
-- Migration 0011 : la gouvernante peut supprimer une anomalie
-- =============================================================================
-- La suppression était réservée à la chargée des opérations et à
-- l'administrateur. Mais c'est la gouvernante qui déclare : c'est elle qui se
-- trompe de chambre, qui déclare deux fois le même robinet, qui enregistre un
-- essai sur une vraie chambre. Lui interdire de défaire son propre geste
-- l'obligeait à attendre quelqu'un d'autre pour une ligne qui n'aurait jamais
-- dû exister.
--
-- Les trois personnes sont Victoria, Sarah P et Miguel — c'est exactement
-- `fn_peut_valider()`. Le technicien, lui, n'y a toujours pas accès : il
-- traite, il ne décide pas de ce qui existe.
--
-- Ce qui reste vrai : supprimer efface une trace. L'écran le dit et demande
-- confirmation, et ce qui a été SORTI du stock pour cette anomalie n'est pas
-- annulé — `mouvements_stock.intervention_id` passe à nul, le mouvement reste.
-- Le matériel a bien quitté la réserve.

create or replace function fn_peut_supprimer() returns boolean
language sql stable as $$
  select fn_role_courant() in ('gouvernante','operations','admin');
$$;

comment on function fn_peut_supprimer() is
  'Supprimer une anomalie efface une trace : la gouvernante, la chargée des '
  'opérations et l''administrateur. Jamais un technicien.';
