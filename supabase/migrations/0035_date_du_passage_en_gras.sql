-- =============================================================================
-- Migration 0035 : la date du passage se lit d'un coup d'œil dans le mail
-- =============================================================================
-- « Il faudrait que la date du passage arrive en gras. » Les récapitulatifs
-- ne partaient qu'en texte brut (Resend accepte `text`) : rien n'y peut être
-- mis en gras. Quand plusieurs passages se suivent de près, retrouver celui
-- dont on a besoin demande d'ouvrir chaque mail en entier.
--
-- `emails_envoyes.corps` reste le texte brut — c'est lui qui sert si un
-- client mail ne sait pas afficher l'HTML. `corps_html` porte la même
-- rédaction, avec la date entourée de `<strong>` ; `lib/envoi.ts` envoie les
-- deux, Resend choisit. Colonne nullable : seuls les récapitulatifs
-- (deposerRecap) l'alimentent, le reste des mails (alerte bouteille, seuil,
-- devis) continue en texte brut, inchangé.
alter table emails_envoyes add column if not exists corps_html text;

comment on column emails_envoyes.corps_html is
  'Même message que corps, en HTML, avec la date du passage en gras. Nul pour '
  'tout ce qui n''est pas un récapitulatif de tournée.';

-- Le service d'envoi lit cette vue, pas la table : sans la rejouer, il ne
-- verrait jamais la colonne qui vient d'apparaître. `corps_html` en dernier :
-- Postgres refuse de réinsérer une colonne au milieu d'une vue existante
-- (« cannot change name of view column »), seul l'ajout en fin est permis.
create or replace view v_courriels_en_attente as
select id, categorie, reference_id, destinataires, sujet, corps, cree_le, corps_html
from emails_envoyes
where envoye_le is null
order by cree_le;
