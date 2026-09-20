import { sql } from "./db";
import { colonneExiste } from "./schema";
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
    aide: "Une ligne par anomalie déclarée, avec son lieu, son état et qui l’a constatée.",
    lignes: () => sql`
      select a.reference                              as "Référence",
             e.code                                   as "Lieu",
             et.nom                                   as "Étage",
             a.description                            as "Description",
             c.libelle                                as "Libellé du catalogue",
             ti.nom                                   as "Type",
             a.statut::text                           as "État",
             a.priorite::text                         as "Priorité",
             a.declare_le                             as "Déclarée le",
             m.nom                                    as "Constatée par",
             u.nom                                    as "Saisie par",
             a.cloture_le                             as "Clôturée le",
             (select count(*) from interventions i
               where i.anomalie_id = a.id)            as "Interventions",
             (select count(*) from photos_anomalie ph
               where ph.anomalie_id = a.id)           as "Photos",
             (select count(*) from v_fil_commentaires f
               where f.anomalie_id = a.id)            as "Commentaires"
        from anomalies a
        join emplacements e   on e.id = a.emplacement_id
        join etages et        on et.id = e.etage_id
        left join catalogue_anomalies c  on c.id = a.catalogue_id
        left join types_intervention ti  on ti.id = coalesce(a.type_id, c.type_id)
        left join utilisateurs m on m.id = a.constate_par
        left join utilisateurs u on u.id = a.saisie_par
       order by a.declare_le desc`,
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
    lignes: () => sql`
      select m.date_mouvement                         as "Date",
             m.type::text                             as "Type",
             m.motif::text                            as "Motif",
             p.code                                   as "Code produit",
             p.designation                            as "Produit",
             m.quantite                               as "Quantité",
             m.prix_unitaire                          as "Prix unitaire de cette ligne",
             coalesce(u.nom, pr.nom)                  as "Par",
             e.code                                   as "Lieu",
             a.description                            as "Anomalie",
             m.commentaire                            as "Commentaire"
        from mouvements_stock m
        join produits p            on p.id = m.produit_id
        left join utilisateurs u   on u.id = m.utilisateur_id
        left join prestataires pr  on pr.id = m.prestataire_id
        left join emplacements e   on e.id = m.emplacement_id
        left join interventions i  on i.id = m.intervention_id
        left join anomalies a      on a.id = i.anomalie_id
       order by m.date_mouvement desc`,
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
