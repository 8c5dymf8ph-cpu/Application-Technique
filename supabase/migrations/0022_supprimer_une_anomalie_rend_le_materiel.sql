-- =============================================================================
-- Migration 0022 : supprimer une anomalie emporte aussi ses mouvements
-- =============================================================================
-- « Supprimer une anomalie devrait tout supprimer, parce que souvent ce sont
-- des anomalies qui sont dans à faire ou en cours. On retouche très rarement à
-- ce qui a été fait par le passé. »
--
-- Jusqu'ici, supprimer une anomalie laissait ses sorties de stock en place,
-- détachées (`on delete set null`) : le raisonnement était que le matériel
-- avait réellement quitté l'étagère. Il vaut pour un passage ancien et clos.
-- Il ne vaut pas pour ce qu'on supprime vraiment — une anomalie déclarée dans
-- la mauvaise chambre, ou deux fois, encore `a_faire` ou `en_cours`. Là, rien
-- n'est sorti de la réserve, et la ligne détachée fausse le stock dans l'autre
-- sens : elle retire une pièce que personne n'a prise.
--
-- Et la règle était déjà incohérente avec elle-même : DÉCOCHER une déclaration
-- (règle 10bis) supprime son matériel — « qui n'a donc pas été utilisé ; le
-- laisser sorti fausserait le stock ». Le même geste, en plus large, gardait le
-- mouvement. Une règle appliquée à un endroit et pas à l'autre ne vaut rien.
--
-- Le mouvement suit donc l'intervention, comme ses avis et son rattachement de
-- facture. Ce qui ne change pas : la suppression reste réservée à trois
-- personnes (`fn_peut_supprimer`), elle se confirme en deux temps, et l'écran
-- dit AVANT ce qu'elle emporte — y compris, désormais, combien de pièces
-- reviennent en réserve. Un geste qui change le stock se voit.

alter table mouvements_stock
  drop constraint if exists mouvements_stock_intervention_id_fkey;
alter table mouvements_stock
  add constraint mouvements_stock_intervention_id_fkey
  foreign key (intervention_id) references interventions (id) on delete cascade;

comment on column mouvements_stock.intervention_id is
  'L''intervention qui a sorti ce matériel. Supprimer l''intervention emporte '
  'le mouvement : ce qu''on supprime n''a pas eu lieu, et le laisser sorti '
  'retirerait de la réserve une pièce que personne n''a prise.';

-- Le journal dit ce que la suppression a rendu. Sans ce chiffre, un stock qui
-- remonte de trois pièces n'a plus d'explication nulle part.
alter table anomalies_supprimees
  add column if not exists nb_mouvements int not null default 0;

comment on column anomalies_supprimees.nb_mouvements is
  'Combien de sorties de stock sont reparties avec elle — donc combien de '
  'pièces sont revenues en réserve.';

create or replace function fn_journal_suppression_anomalie() returns trigger
language plpgsql as $$
begin
  insert into anomalies_supprimees (
    id, sharepoint_id, emplacement, emplacement_id, description, statut,
    priorite, declare_le, constate_par, nb_photos, nb_commentaires,
    nb_interventions, nb_mouvements, supprimee_par)
  select
    old.id, old.sharepoint_id, e.code, old.emplacement_id, old.description,
    old.statut::text, old.priorite::text, old.declare_le, u.nom,
    (select count(*) from photos_anomalie p where p.anomalie_id = old.id),
    (select count(*) from commentaires c where c.anomalie_id = old.id),
    (select count(*) from interventions i where i.anomalie_id = old.id),
    -- Compté AVANT la cascade : le déclencheur est `before delete`, les
    -- interventions et leurs mouvements sont encore là.
    (select count(*) from mouvements_stock m
       join interventions i on i.id = m.intervention_id
      where i.anomalie_id = old.id),
    (select x.id from utilisateurs x where x.auth_id = auth.uid())
  from (select 1) z
  left join emplacements e  on e.id = old.emplacement_id
  left join utilisateurs u  on u.id = old.constate_par
  on conflict (id) do nothing;
  return old;
end;
$$;

drop trigger if exists tg_journal_suppression_anomalie on anomalies;
create trigger tg_journal_suppression_anomalie
before delete on anomalies
for each row execute function fn_journal_suppression_anomalie();
