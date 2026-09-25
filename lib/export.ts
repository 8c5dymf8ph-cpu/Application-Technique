import { sql } from "./db";
import { colonneExiste, tableExiste } from "./schema";
import { jourISO } from "./domaine";

/**
 * Sortir les données de l'application.
 *
 * L'ancienne application était un tableau : on l'ouvrait, on triait, on faisait
 * une somme. Celle-ci range mieux, mais elle range — et ce qu'on ne peut pas
 * sortir, on ne le possède pas vraiment. Chaque export est une table plate,
 * déjà jointe, lisible sans connaître le schéma : une ligne = un fait, les
 * codes remplacés par les noms.
 *
 * Le format est un CSV pour tableur français : séparateur point-virgule,
 * décimale à la virgule, BOM en tête pour qu'Excel lise les accents. Ouvert
 * d'un double-clic, il se trie et se filtre tout de suite.
 */

export type Export = {
  cle: string;
  titre: string;
  aide: string;
  /** Renvoie les lignes, déjà aplaties. */
  lignes: () => Promise<Record<string, unknown>[]>;
};

export const EXPORTS: Export[] = [
  {
    cle: "anomalies",
    titre: "Anomalies",
    aide:
      "Une ligne par anomalie déclarée, avec son lieu, son état et qui l’a constatée — " +
      "y compris celles qui ont été supprimées depuis (migration 0021).",
    // Les anomalies supprimées sont une autre TABLE (anomalies_supprimees, une
    // trace au moment du DELETE, migration 0021) mais le même FAIT — une ligne
    // par anomalie. Deux requêtes, jamais une condition dans le SQL : la table
    // n'existe pas tant que la migration n'est pas jouée.
    lignes: async () => {
      const actives = sql`
        select a.reference::text                         as "Référence",
               e.code                                     as "Lieu",
               et.nom                                     as "Étage",
               a.description                              as "Description",
               c.libelle                                  as "Libellé du catalogue",
               ti.nom                                      as "Type",
               a.statut::text                              as "État",
               a.priorite::text                            as "Priorité",
               a.declare_le                                as "Déclarée le",
               m.nom                                       as "Constatée par",
               u.nom                                       as "Saisie par",
               a.cloture_le                                as "Clôturée le",
               (select count(*) from interventions i
                 where i.anomalie_id = a.id)::int          as "Interventions",
               (select count(*) from photos_anomalie ph
                 where ph.anomalie_id = a.id)::int         as "Photos",
               (select count(*) from v_fil_commentaires f
                 where f.anomalie_id = a.id)::int          as "Commentaires",
               null::timestamptz                           as "Supprimée le",
               null::text                                  as "Supprimée par"
          from anomalies a
          join emplacements e   on e.id = a.emplacement_id
          join etages et        on et.id = e.etage_id
          left join catalogue_anomalies c  on c.id = a.catalogue_id
          left join types_intervention ti  on ti.id = coalesce(a.type_id, c.type_id)
          left join utilisateurs m on m.id = a.constate_par
          left join utilisateurs u on u.id = a.saisie_par`;

      if (!(await tableExiste("anomalies_supprimees"))) {
        return sql`${actives} order by "Déclarée le" desc`;
      }
      return sql`
        ${actives}
         union all
        select coalesce(s.sharepoint_id::text, '—'),
               s.emplacement,
               null::text,
               s.description,
               null::text,
               null::text,
               s.statut || ' (supprimée)',
               s.priorite,
               s.declare_le,
               s.constate_par,
               null::text,
               null::timestamptz,
               s.nb_interventions,
               s.nb_photos,
               s.nb_commentaires,
               s.supprimee_le,
               su.nom
          from anomalies_supprimees s
          left join utilisateurs su on su.id = s.supprimee_par
         order by "Déclarée le" desc`;
    },
  },
  {
    cle: "interventions",
    titre: "Interventions",
    aide:
      "Un passage sur une anomalie : qui, quand, ce que le technicien a déclaré, " +
      "ce que la gouvernante a validé, et le coût.",
    lignes: () => sql`
      select date_intervention                        as "Faite le",
             coalesce(intervenant, prestataire)       as "Par",
             emplacement                              as "Lieu",
             etage                                    as "Étage",
             anomalie_reference                       as "Référence anomalie",
             description                              as "Anomalie",
             type_intervention                        as "Type",
             statut_anomalie::text                    as "État de l’anomalie",
             decision_technicien::text                as "Déclaré par l’intervenant",
             declare_fait_le                          as "Déclaré le",
             commentaire_technicien                   as "Commentaire de l’intervenant",
             decision_gouvernante::text               as "Avis de la gouvernante",
             decide_gouvernante_le                    as "Validé le",
             commentaire_gouvernante                  as "Commentaire de la gouvernante",
             cout_materiel                            as "Coût matériel",
             cout_prestataire                         as "Facturé par l’intervenant",
             cout_divers                              as "Autres coûts",
             cout_total                               as "Coût total",
             case when cout_incomplet then 'oui' else 'non' end as "Coût incomplet",
             articles_sans_prix                       as "Articles sans prix",
             tournee                                  as "Passage"
        from v_recap_interventions
       order by date_intervention desc nulls last`,
  },
  {
    cle: "passages",
    titre: "Passages",
    aide: "Une ligne par tournée : l’intervenant, le jour, ce qui a été traité et le coût.",
    lignes: () => sql`
      select date_tournee                             as "Jour",
             intervenant                              as "Intervenant",
             reference                                as "Référence",
             nb_interventions                         as "Anomalies traitées",
             nb_validees                              as "Validées",
             nb_a_refaire                             as "À refaire",
             nb_en_attente                            as "En attente de validation",
             cloturee_le                              as "Clôturé le",
             case when reprise then 'oui' else 'non' end as "Reprise de l’historique",
             cout_total                               as "Coût total",
             case when cout_incomplet then 'oui' else 'non' end as "Coût incomplet"
        from v_tournees
       order by date_tournee desc`,
  },
  {
    cle: "mouvements",
    titre: "Mouvements de stock",
    aide: "Entrées, sorties et ajustements. C’est d’ici que vient tout le stock.",
    // Une sortie faite en chambre d'essai figure ici — le geste a bien eu lieu
    // — mais elle n'a rien retiré de la réserve. Sans la colonne « Compté », la
    // somme du tableur ne retomberait pas sur le stock, et on chercherait
    // l'erreur ailleurs.
    lignes: async () => {
      const essai = await colonneExiste("emplacements", "essai");
      return sql`
      select m.date_mouvement                         as "Date",
             m.type::text                             as "Type",
             m.motif::text                            as "Motif",
             p.code                                   as "Code produit",
             p.designation                            as "Produit",
             m.quantite                               as "Quantité",
             m.prix_unitaire                          as "Prix unitaire de cette ligne",
             coalesce(u.nom, pr.nom)                  as "Par",
             e.code                                   as "Lieu",
             ${essai
               ? sql`case when coalesce(e.essai, false) then 'non (essai)' else 'oui' end`
               : sql`'oui'::text`}                    as "Compté dans le stock",
             a.description                            as "Anomalie",
             m.commentaire                            as "Commentaire"
        from mouvements_stock m
        join produits p            on p.id = m.produit_id
        left join utilisateurs u   on u.id = m.utilisateur_id
        left join prestataires pr  on pr.id = m.prestataire_id
        left join emplacements e   on e.id = m.emplacement_id
        left join interventions i  on i.id = m.intervention_id
        left join anomalies a      on a.id = i.anomalie_id
       order by m.date_mouvement desc`;
    },
  },
  {
    cle: "produits",
    titre: "Produits et stock",
    aide: "Le catalogue matériel avec le stock du jour, calculé, et sa valeur.",
    lignes: () => sql`
      select code                                     as "Code",
             designation                              as "Désignation",
             categorie                                as "Métier",
             categorie_lieu                           as "Lieu",
             unite                                    as "Unité",
             stock                                    as "Stock",
             prix_unitaire                            as "Prix de référence",
             dernier_prix                             as "Dernier prix payé",
             valeur_stock                             as "Valeur du stock",
             seuil_alerte                             as "Seuil d’alerte",
             quantite_reappro                         as "Quantité à recommander",
             case when sous_seuil then 'oui' else 'non' end as "Sous le seuil",
             case when actif then 'oui' else 'non' end      as "Actif",
             fournisseur                              as "Fournisseur préféré",
             dernier_mouvement                        as "Dernier mouvement"
        from v_stock_produits order by designation`,
  },
  {
    cle: "bouteilles",
    titre: "Dossiers bouteille",
    aide: "Une ligne par dossier, avec la chambre, le client, les types et le montant.",
    lignes: () => sql`
      select reference                                as "Référence",
             constate_le                              as "Constaté le",
             emplacement                              as "Chambre",
             nature::text                             as "Nature",
             bouteille                                as "Types manquants",
             quantite                                 as "Quantité",
             client_nom                               as "Client",
             responsable::text                        as "Responsable",
             montant                                  as "Montant",
             statut::text                             as "État",
             constate_par                             as "Constaté par",
             transmis_a                               as "Transmis à",
             transmis_le                              as "Transmis le",
             client_contacte_le                       as "Client contacté le",
             resolu_le                                as "Résolu le",
             jours_ouvert                             as "Jours ouvert",
             commentaire                              as "Commentaire"
        from v_dossiers_bouteille
       order by constate_le desc`,
  },
  {
    cle: "factures",
    titre: "Factures",
    aide: "Ce que les intervenants et les fournisseurs ont facturé.",
    // Farid et Rachid facturent sans être une entreprise : `technicien_id` les
    // rattache, depuis la migration 0007. Tant qu'elle n'est pas appliquée la
    // colonne n'existe pas, et Postgres refuse la requête entière — deux
    // requêtes, donc, pas une condition.
    lignes: async () =>
      (await colonneExiste("factures", "technicien_id"))
        ? sql`
            select f.date_facture                           as "Date",
                   f.type::text                             as "Type",
                   f.reference                              as "Référence",
                   coalesce(pr.nom, u.nom, fo.nom)          as "Émetteur",
                   f.montant_ht                             as "Montant HT",
                   f.montant_ttc                            as "Montant TTC",
                   f.statut::text                           as "État",
                   f.periode_debut                          as "Période du",
                   f.periode_fin                            as "Période au",
                   (select count(*) from facture_interventions fi
                     where fi.facture_id = f.id)            as "Interventions couvertes",
                   f.fichier_url                            as "Pièce jointe",
                   f.commentaire                            as "Commentaire"
              from factures f
              left join prestataires pr  on pr.id = f.prestataire_id
              left join utilisateurs u   on u.id = f.technicien_id
              left join fournisseurs fo  on fo.id = f.fournisseur_id
             order by f.date_facture desc`
        : sql`
            select f.date_facture                           as "Date",
                   f.type::text                             as "Type",
                   f.reference                              as "Référence",
                   coalesce(pr.nom, fo.nom)                 as "Émetteur",
                   f.montant_ht                             as "Montant HT",
                   f.montant_ttc                            as "Montant TTC",
                   f.statut::text                           as "État",
                   f.periode_debut                          as "Période du",
                   f.periode_fin                            as "Période au",
                   (select count(*) from facture_interventions fi
                     where fi.facture_id = f.id)            as "Interventions couvertes",
                   f.fichier_url                            as "Pièce jointe",
                   f.commentaire                            as "Commentaire"
              from factures f
              left join prestataires pr  on pr.id = f.prestataire_id
              left join fournisseurs fo  on fo.id = f.fournisseur_id
             order by f.date_facture desc`,
  },
  {
    cle: "commentaires",
    titre: "Commentaires",
    aide: "Le fil de chaque anomalie : ce qui a été dit, par qui, et quand.",
    lignes: () => sql`
      select f.date_commentaire                       as "Date",
             e.code                                   as "Lieu",
             a.reference                              as "Référence anomalie",
             a.description                            as "Anomalie",
             f.source                                 as "Origine",
             f.auteur                                 as "Auteur",
             f.decision::text                         as "Décision",
             f.texte                                  as "Texte"
        from v_fil_commentaires f
        join anomalies a     on a.id = f.anomalie_id
        join emplacements e  on e.id = a.emplacement_id
       order by f.date_commentaire desc`,
  },
  {
    cle: "equipe",
    titre: "Équipe",
    aide: "Qui est qui : salariés et entreprises, leurs coordonnées et leur rôle.",
    lignes: () => sql`
      select nom                                       as "Nom",
             'Salarié'                                 as "Type",
             role::text                                as "Rôle ou spécialité",
             email                                     as "Email",
             null::text                                as "Téléphone",
             case when actif then 'oui' else 'non' end as "Actif",
             case when peut_se_connecter then 'oui' else 'non' end as "Se connecte à l’application",
             case when intervient_technique then 'oui' else 'non' end as "Intervient en technique"
        from utilisateurs
       union all
      select nom, 'Entreprise', specialite, email, telephone,
             case when actif then 'oui' else 'non' end,
             'non',
             'oui'
        from prestataires
       order by 1`,
  },
  {
    cle: "catalogue",
    titre: "Catalogue des anomalies",
    aide: "Les libellés autorisés à la déclaration, avec leur métier.",
    lignes: () => sql`
      select c.libelle                                 as "Libellé",
             ti.nom                                     as "Métier",
             array_to_string(c.mots_cles, ', ')         as "Mots-clés",
             c.occurrences                              as "Occurrences",
             case when c.actif then 'oui' else 'non' end as "Actif"
        from catalogue_anomalies c
        left join types_intervention ti on ti.id = c.type_id
       order by c.libelle`,
  },
  {
    cle: "mouvements_bouteilles",
    titre: "Mouvements de bouteilles",
    aide:
      "Entrées, dotations, emports, retours : c’est d’ici que vient le parc — " +
      "avec le prix de référence de chaque type, pour ne pas ouvrir une deuxième feuille.",
    lignes: () => sql`
      select m.date_mouvement                          as "Date",
             m.type::text                               as "Type",
             bt.libelle                                 as "Type de bouteille",
             m.quantite                                 as "Quantité",
             m.de_lieu::text                            as "Depuis",
             e_de.code                                  as "Lieu de départ",
             m.vers_lieu::text                          as "Vers",
             e_vers.code                                as "Lieu d’arrivée",
             coalesce(u.nom, '—')                       as "Par",
             bt.prix_vente                              as "Prix vente (référence)",
             bt.prix_achat                              as "Prix achat (référence)",
             m.commentaire                              as "Commentaire"
        from mouvements_bouteilles m
        join bouteille_types bt      on bt.id = m.bouteille_type_id
        left join emplacements e_de   on e_de.id = m.de_emplacement_id
        left join emplacements e_vers on e_vers.id = m.vers_emplacement_id
        left join utilisateurs u      on u.id = m.utilisateur_id
       order by m.date_mouvement desc`,
  },
  {
    cle: "commandes",
    titre: "Commandes fournisseurs",
    aide: "Les commandes de matériel et de bouteilles, reçues ou non.",
    lignes: () => sql`
      select reference                                 as "N°",
             fournisseur                                as "Fournisseur",
             date_commande                              as "Date de commande",
             date_livraison                             as "Livraison prévue le",
             statut::text                               as "État",
             montant_ht                                 as "Montant HT",
             montant_ttc                                as "Montant TTC",
             nb_articles                                as "Articles",
             articles                                   as "Détail",
             facture_fichier                            as "Pièce jointe"
        from v_commandes
       order by date_commande desc`,
  },
  {
    cle: "fournisseurs",
    titre: "Fournisseurs",
    aide: "Coordonnées, et pour chaque article ce qu’ils en demandent.",
    lignes: () => sql`
      select f.nom                                     as "Fournisseur",
             f.contact                                  as "Contact",
             f.email                                    as "Email",
             f.email_2                                  as "Email 2",
             f.telephone                                as "Téléphone",
             f.delai_livraison_jours                     as "Délai de livraison (jours)",
             case when f.actif then 'oui' else 'non' end as "Actif",
             coalesce(p.designation, bt.libelle)         as "Article",
             af.reference_fournisseur                    as "Référence fournisseur",
             af.prix_indicatif                           as "Prix indicatif",
             case when af.prefere then 'oui' else 'non' end as "Fournisseur préféré"
        from fournisseurs f
        left join article_fournisseurs af on af.fournisseur_id = f.id
        left join produits p              on p.id = af.produit_id
        left join bouteille_types bt      on bt.id = af.bouteille_type_id
       order by f.nom, 8`,
  },
  {
    cle: "suivis",
    titre: "Suivis (histoires)",
    aide:
      "La chronologie des histoires comme les punaises de lit : un acte par ligne, " +
      "ses lieux, ses résultats et ses conséquences.",
    // Migration 0023 (suivis) puis 0025 (conséquences) : deux tables neuves, deux
    // requêtes possibles, jamais une condition dans le SQL — voir lib/schema.ts.
    lignes: async () => {
      if (!(await tableExiste("suivis"))) return [];
      const avecConsequences = await tableExiste("consequences_acte");
      const consequences = avecConsequences
        ? sql`(select string_agg(
                 tc.libelle
                   || coalesce(' (' || ce.code || ')', '')
                   || coalesce(' — ' || cq.montant_ht::text || ' €', ''),
                 ', ' order by tc.ordre)
                 from consequences_acte cq
                 join types_consequence tc on tc.id = cq.type_consequence_id
                 left join emplacements ce on ce.id = cq.emplacement_id
                where cq.acte_id = a.id)`
        : sql`null::text`;
      return sql`
      select s.titre                                   as "Dossier",
             sp.titre                                   as "Dossier permanent",
             case when s.parent_id is null then 'Permanent' else 'Épisode' end
                                                         as "Type de dossier",
             n.libelle                                  as "Nature",
             a.date_acte                                as "Date",
             ta.libelle                                 as "Acte",
             coalesce(u.nom, pr.nom, '—')               as "Par",
             (select string_agg(
                        e.code || case al.resultat
                                    when 'positif'      then ' (positif)'
                                    when 'negatif'      then ' (négatif)'
                                    when 'non_concluant' then ' (non concluant)'
                                    else ' (résultat non écrit)'
                                  end,
                        ', ' order by e.code)
                from acte_lieux al
                join emplacements e on e.id = al.emplacement_id
               where al.acte_id = a.id)                 as "Lieux et résultats",
             a.montant_ht                                as "Montant HT",
             case when a.gratuit then 'oui' else 'non' end      as "Offert",
             case when a.hors_contrat then 'oui' else 'non' end as "Hors contrat",
             ${consequences}                             as "Conséquences",
             a.commentaire                               as "Commentaire"
        from actes a
        join suivis s        on s.id = a.suivi_id
        left join suivis sp  on sp.id = s.parent_id
        join natures_suivi n on n.code = s.nature_code
        join types_acte ta   on ta.id = a.type_acte_id
        left join utilisateurs u  on u.id = a.utilisateur_id
        left join prestataires pr on pr.id = a.prestataire_id
       order by a.date_acte desc`;
    },
  },
];

/**
 * Une valeur telle qu'un tableur français la comprend.
 *
 * Les dates en ISO se trient ; le pilote PostgreSQL rend les colonnes `date`
 * sous forme d'objet, d'où `jourISO()`. Les nombres prennent la virgule
 * décimale, sinon Excel les lit comme du texte et aucune somme ne marche.
 */
function cellule(v: unknown): string {
  if (v === null || v === undefined) return "";
  if (v instanceof Date) {
    const jour = jourISO(v);
    const heure = v.toISOString().slice(11, 16);
    return heure === "00:00" ? jour : `${jour} ${heure}`;
  }
  if (typeof v === "number") return String(v).replace(".", ",");
  const texte = String(v);
  // Un point-virgule, un guillemet ou un retour à la ligne dans le texte
  // casserait la colonne : on entoure et on double les guillemets.
  return /[";\n\r]/.test(texte) ? `"${texte.replace(/"/g, '""')}"` : texte;
}

export function enCSV(lignes: Record<string, unknown>[]): string {
  if (lignes.length === 0) return "﻿Aucune ligne\r\n";
  const colonnes = Object.keys(lignes[0]);
  const corps = lignes.map((l) => colonnes.map((c) => cellule(l[c])).join(";"));
  // Le BOM dit à Excel que le fichier est en UTF-8 : sans lui, « clé » s'ouvre
  // en « clÃ© ». Les fins de ligne en CRLF, pour la même raison.
  return "﻿" + [colonnes.join(";"), ...corps].join("\r\n") + "\r\n";
}
