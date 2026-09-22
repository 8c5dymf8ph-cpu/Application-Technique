-- =============================================================================
-- Migration 0017 : le stock réel, sans les ajustements de l'ancienne application
-- =============================================================================
-- Le stock est la somme des mouvements (règle 1), et rien d'autre. L'import
-- l'avait pourtant complété de vingt-deux régularisations datées de la
-- bascule, qui visaient le chiffre affiché par l'ancienne application.
--
-- Ce chiffre était faux. L'ancienne application ignorait 249 mouvements sur
-- 261 (colonne `EstHistorique`) : son stock valait `Stock_Initial` plus les
-- seuls mouvements récents. Viser ce chiffre revenait à réintroduire
-- `Stock_Initial` sous le nom de « régularisation » — exactement ce que la
-- règle 17 écarte — et à couvrir l'écart par un comptage que personne n'avait
-- fait. Un stock faux avec une ligne d'explication reste un stock faux.
--
-- On retire donc le recalage, et l'ajustement que l'ancienne application
-- portait elle-même. Ce qui reste est la somme des entrées (tableau des
-- mouvements) et des sorties (export des anomalies) — ce qui a réellement
-- quitté l'étagère et ce qui y est réellement entré.
--
-- Là où cette somme passe sous zéro, l'étagère n'était pas vide quand le
-- tableau a commencé. Ça ne se répare pas par une écriture : ça se compte,
-- dans un inventaire de l'application, et la régularisation porte alors un
-- écart que quelqu'un a constaté. C'est la règle 4, et c'est le seul chemin.
--
-- Rejouable, et sans effet sur une base neuve : tout est ciblé par ce que la
-- reprise a écrit, et une base installée depuis `outils/importer_stock.py`
-- corrigé n'en porte plus rien.

-- -----------------------------------------------------------------------------
-- 1. Le recalage de reprise, et l'ajustement de l'ancienne application
-- -----------------------------------------------------------------------------
delete from mouvements_stock
 where inventaire_id = 'cccccccc-0000-0000-0000-000000000001';

delete from inventaire_lignes_produit
 where inventaire_id = 'cccccccc-0000-0000-0000-000000000001';

delete from inventaires
 where id = 'cccccccc-0000-0000-0000-000000000001';

-- -----------------------------------------------------------------------------
-- 2. Une entrée négative est une entrée négative
-- -----------------------------------------------------------------------------
-- Le 25/09/2025, huit télérupteurs sont ressortis d'une livraison : le tableau
-- porte « Entrée −8 ». L'import prenait la valeur absolue, et la base comptait
-- +8 au lieu de −8 — seize pièces de trop, sans que rien ne le dise. Le signe
-- du tableau est une information, pas une faute de frappe.
--
-- Une entrée ne peut pas être négative — `signe_coherent` l'interdit, et à
-- juste titre : une entrée ajoute. Ce que le tableau décrit, ce sont huit
-- pièces qui ont QUITTÉ l'étagère pour retourner chez le fournisseur. C'est
-- une sortie, et c'est ainsi qu'elle est écrite.
--
-- On ne corrige que ce cas précis, et seulement s'il est encore là : deux
-- entrées jumelles, même produit, même jour, même quantité. Sur une base
-- installée avec l'import corrigé, il n'y en a qu'une et le bloc ne fait rien.
do $$
declare
  v_produit uuid;
  v_id      uuid;
begin
  select id into v_produit from produits
   where designation = 'Télérupteur électrique (YesssElectrique)';
  if v_produit is null then return; end if;

  select m.id into v_id
    from mouvements_stock m
   where m.produit_id = v_produit
     and m.type = 'entree'
     and m.date_mouvement::date = date '2025-09-25'
     and m.quantite = 8
     and (select count(*) from mouvements_stock m2
           where m2.produit_id = v_produit and m2.type = 'entree'
             and m2.date_mouvement::date = date '2025-09-25'
             and m2.quantite = 8) = 2
   limit 1;

  if v_id is not null then
    update mouvements_stock
       set type = 'sortie', quantite = -8,
           commentaire = 'Retour au fournisseur : huit pièces ressorties de la livraison '
                         '(le tableau les portait en entrée négative).'
     where id = v_id;
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- 3. Un comptage reste vrai : c'est son écart qui change
-- -----------------------------------------------------------------------------
-- Un inventaire fait DANS l'application a mesuré son écart contre un théorique
-- qui portait encore le recalage. Le comptage, lui, ne bouge pas : ce qui était
-- sur l'étagère y était. On recalcule donc le théorique sans le recalage, et la
-- régularisation suit — sinon le chiffre compté ne serait plus celui qu'on lit.
--
-- Un écart devenu nul n'a plus de mouvement : un mouvement qui ne déplace rien
-- n'est pas un mouvement, et le schéma le refuse.
do $$
declare
  l record;
  v_theorique numeric;
begin
  for l in
    select li.id, li.inventaire_id, li.produit_id, li.quantite_comptee, i.valide_le
      from inventaire_lignes_produit li
      join inventaires i on i.id = li.inventaire_id
     where i.statut = 'valide'
  loop
    select coalesce(sum(m.quantite), 0) into v_theorique
      from v_mouvements_reels m
     where m.produit_id = l.produit_id
       and m.inventaire_id is distinct from l.inventaire_id
       and m.date_mouvement <= l.valide_le;

    update inventaire_lignes_produit
       set quantite_theorique = v_theorique
     where id = l.id;

    if l.quantite_comptee - v_theorique = 0 then
      delete from mouvements_stock
       where inventaire_id = l.inventaire_id and produit_id = l.produit_id;
    else
      update mouvements_stock
         set quantite = l.quantite_comptee - v_theorique,
             commentaire = format('Régularisation d''inventaire (théorique %s, compté %s)',
                                  v_theorique, l.quantite_comptee)
       where inventaire_id = l.inventaire_id and produit_id = l.produit_id;
    end if;
  end loop;
end $$;
