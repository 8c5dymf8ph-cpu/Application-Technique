-- =============================================================================
-- Migration 0012 : savoir quand un envoi a été retenté
-- =============================================================================
-- Un message en échec garde son erreur jusqu'au prochain essai. C'est voulu —
-- on ne perd pas la raison du refus. Mais l'écran affichait ce texte sans dire
-- de quand il datait : on corrigeait le réglage, on rouvrait l'écran, la même
-- erreur s'affichait, et on croyait que la correction n'avait rien changé.
--
-- Alors qu'en réalité rien n'avait été retenté. Et surtout, les messages déjà
-- déposés portent les destinataires QU'ILS AVAIENT au moment du dépôt :
-- changer le réglage ne les réadresse pas. C'est juste — un message est un
-- fait, pas une intention — mais il fallait pouvoir les reprendre.
--
-- On note donc la date du dernier essai. L'écran peut alors dire « erreur du
-- dernier essai, il y a deux jours » au lieu de laisser croire à un échec qui
-- vient d'avoir lieu.

alter table emails_envoyes
  add column if not exists dernier_essai_le timestamptz;

comment on column emails_envoyes.dernier_essai_le is
  'Quand l''envoi a été tenté pour la dernière fois. Sert à dater l''erreur '
  'affichée : sans elle, un refus d''il y a deux jours passe pour un refus '
  'de maintenant.';

-- Les messages déjà en échec ont bien été tentés : sans date, l'écran les
-- présenterait comme jamais essayés. Leur date de dépôt est la meilleure
-- approximation dont on dispose.
update emails_envoyes
   set dernier_essai_le = cree_le
 where envoye_le is null and erreur is not null and dernier_essai_le is null;
