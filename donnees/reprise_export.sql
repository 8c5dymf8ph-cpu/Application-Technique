-- Reprise d'un nouvel export « TEST Tech 3 » sur une base vivante.
-- Produit par outils/reprendre_export.py — 674 lignes retenues.
--
-- Ne touche QUE ce que le tableau possède, et seulement les anomalies
-- qui en viennent (sharepoint_id renseigné). Les photos, le fil, les
-- dossiers bouteille, le stock et les anomalies déclarées dans
-- l'application ne sont jamais lus ni modifiés.

begin;

alter table validations disable trigger tg_validation_maj_anomalie;

-- Le tableau, tel qu'il est aujourd'hui. Une ligne par anomalie.
create temporary table reprise (
  sharepoint_id  int primary key,
  lieu           text,
  libelle        text,
  statut         text,
  declare_le     date,
  constate_par   text,
  saisie_par     text,
  fait_le        date,
  par            text,
  externe        boolean,
  verifie_le     date,
  verifie_par    text,
  produit        text,
  quantite       numeric
) on commit drop;
insert into reprise values
  (1265, '14', 'spot plafond niveau armoire à changer', 'a_faire', '2026-09-19', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1266, '14', 'la lumiere du miroir ne s''allume pas', 'a_faire', '2026-09-19', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1263, '26', 'flexible douche à changer', 'a_faire', '2026-09-16', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1264, '01', 'télérupteur à changer - spot et leds', 'a_faire', '2026-09-16', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1262, '44', 'porte du frigo à fixer', 'a_faire', '2026-09-07', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1256, '03', 'flexible fuit au niveau du pommeau de douche', 'a_faire', '2026-09-03', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1257, '27', 'serrer le bras liseuse côté droit', 'a_faire', '2026-09-03', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1258, '37', 'lavabo bouché', 'a_faire', '2026-09-03', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1259, '24', 'lavabo bouché', 'a_faire', '2026-09-03', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1260, '16', 'remplacement bras de liseuse (coté gauche)', 'a_faire', '2026-09-03', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1261, 'Office 5 ème étage', 'spot du couloir a changer', 'a_faire', '2026-09-03', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1255, '01', 'remplacer l''économiseur d''énergie pour éclairage principal', 'a_faire', '2026-08-30', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1253, '11', 'remplacer l''économiseur d''énergie pour éclairage principal', 'a_faire', '2026-08-11', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1248, '52', 'flexible fuit au niveau du pommeau de douche', 'a_faire', '2026-08-05', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1249, '58', 'flexible fuit au niveau du pommeau de douche', 'a_faire', '2026-08-05', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1250, '42', 'flexible fuit au niveau du pommeau de douche', 'a_faire', '2026-08-05', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1251, '45', 'lavabo bouché', 'a_faire', '2026-08-05', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1252, '22', 'refixer la liseuse de droite', 'a_faire', '2026-08-05', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1246, '25', 'flexible douche à changer', 'a_faire', '2026-08-03', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1247, '56', 'flexible fuit au niveau du pommeau de douche', 'a_faire', '2026-08-03', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1161, 'Lobby', 'Attache mural de la porte de secours devant la porte des escaliers à fixer', 'a_faire', '2026-07-27', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1240, '45', 'lit côté gauche cassé', 'a_faire', '2026-07-24', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1241, '45', 'changement support lait corporel', 'a_faire', '2026-07-24', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1242, '2eme étage', 'Spot du couloir a changer', 'a_faire', '2026-07-24', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1243, '02', 'remplacer l''économiseur d''énergie pour éclairage principal', 'a_faire', '2026-07-24', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1244, '36', 'Lunette des WC à changer', 'a_faire', '2026-07-24', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (1239, 'Lobby', 'Il faut changer le fil du Chafing dish rond (réchaud de buffet)', 'validee', '2026-07-22', 'Victoria', 'Miguel', '2026-07-23', null, true, '2026-07-23', 'Miguel', null, null),
  (1160, 'WC Clients', 'Lave-main à installer', 'a_faire', '2026-07-20', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1229, 'WC Clients', 'Il faut changer le sèche-main', 'validee', '2026-07-19', 'Victoria', 'Miguel', '2026-07-20', null, true, '2026-07-20', 'Miguel', null, null),
  (1225, '37', 'lit côté gauche cassé', 'a_faire', '2026-07-01', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1226, '37', 'lit côté droit cassé', 'a_faire', '2026-07-01', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1227, 'Lobby', 'Spot à changer (celui du milieu) côté machine à café', 'a_faire', '2026-07-01', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (1223, '16', 'Il faut refaire les joints mitigeur de douche', 'a_faire', '2026-06-25', 'Sarah P', 'Miguel', null, null, false, null, null, null, null),
  (1224, '18', 'Il faut refaire les joints mitigeur de douche', 'a_faire', '2026-06-25', 'Sarah P', 'Miguel', null, null, false, null, null, null, null),
  (1158, 'COUR intèrieure', 'Il faut repeindre les deux pots de fleurs', 'a_faire', '2026-06-23', 'Sarah P', 'Miguel', null, null, false, null, null, null, null),
  (1148, '01', 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', '2026-06-18', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1149, '03', 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', '2026-06-18', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1150, '14', 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', '2026-06-18', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1151, '18', 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', '2026-06-18', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1152, '26', 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', '2026-06-18', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1153, '45', 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', '2026-06-18', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1154, '51', 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', '2026-06-18', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1155, '54', 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', '2026-06-18', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1156, '55', 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', '2026-06-18', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1157, '58', 'Voir ce qu''il est possible de faire pour l’espace entre le mitigeur et le mur', 'a_faire', '2026-06-18', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1159, 'Lobby', 'Il faut faire les joints', 'a_faire', '2026-06-16', 'Sarah P', 'Miguel', null, null, false, null, null, null, null),
  (1214, '56', 'flexible douche à changer', 'validee', '2026-06-16', 'Victoria', 'Victoria', '2026-06-16', 'Miguel', false, '2026-06-16', 'Victoria', 'Flexible (Fournis par Serafino)', 1.0),
  (1215, '16', 'voir avec miroitier pour miroir placard cassé en bas (grand)', 'a_faire', '2026-06-16', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1216, '02', 'lit côté gauche cassé', 'validee', '2026-06-16', 'Victoria', 'Victoria', '2026-06-25', null, true, '2026-07-01', 'Victoria', null, null),
  (1217, '48', 'urgent - joints sillicone douche', 'validee', '2026-06-16', 'Victoria', 'Victoria', '2026-06-25', null, true, '2026-07-01', 'Victoria', null, null),
  (1218, '44', 'urgent - joints sillicone douche', 'validee', '2026-06-16', 'Victoria', 'Victoria', '2026-06-25', null, true, '2026-07-01', 'Victoria', null, null),
  (1219, '58', 'refixer la liseuse de droite', 'validee', '2026-06-16', 'Victoria', 'Victoria', '2026-06-25', null, true, '2026-07-01', 'Victoria', null, null),
  (1205, '54', 'lavabo bouché', 'a_faire', '2026-06-15', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-16', 'Victoria', null, null),
  (1206, '55', 'lavabo bouché', 'validee', '2026-06-15', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-16', 'Victoria', null, null),
  (1207, '52', 'flexible douche à changer', 'validee', '2026-06-15', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-16', 'Victoria', null, null),
  (1208, '44', 'flexible douche à changer', 'validee', '2026-06-15', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-16', 'Victoria', 'Flexible (Fournis par Serafino)', 1.0),
  (1209, '4eme étage', 'lavabo bouché', 'a_faire', '2026-06-15', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1210, '44', 'lavabo bouché', 'validee', '2026-06-15', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-16', 'Victoria', null, null),
  (1211, '51', 'lavabo bouché', 'validee', '2026-06-15', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-16', 'Victoria', null, null),
  (1212, '56', 'lavabo bouché', 'validee', '2026-06-15', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-16', 'Victoria', null, null),
  (1213, '21', 'lavabo bouché', 'validee', '2026-06-15', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-16', 'Victoria', null, null),
  (1202, '56', 'flexible douche à changer', 'validee', '2026-06-09', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-15', 'Victoria', null, null),
  (1203, '58', 'serrer le bras liseuse côté droit', 'validee', '2026-06-09', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-15', 'Victoria', null, null),
  (1204, '52', 'miroir plateau à changé', 'a_faire', '2026-06-09', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1192, '34', 'lit côté gauche cassé', 'validee', '2026-06-02', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1193, '34', 'lit côté gauche cassé', 'validee', '2026-06-02', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1194, '38', 'lit côté droit cassé', 'validee', '2026-06-02', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1195, '38', 'urgent - joints sillicone douche - lavabo  et wc à refaire complètement', 'a_faire', '2026-06-02', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-16', 'Victoria', null, null),
  (1196, '24', 'lit côté gauche cassé', 'validee', '2026-06-02', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1197, '21', 'flexible douche à changer', 'validee', '2026-06-02', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-16', 'Victoria', null, null),
  (1198, 'Lobby', 'recoller les cornières dorées sur les deux pilliers', 'validee', '2026-06-02', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1199, '38', 'lit côté gauche cassé', 'validee', '2026-06-02', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1200, '36', 'serrer le bras liseuse côté droit', 'validee', '2026-06-02', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1201, '57', 'serrer le bras liseuse côté gauche', 'validee', '2026-06-02', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1190, '45', 'télécommande clim à remplacer', 'a_faire', '2026-05-28', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1191, '57', 'télécommande clim à remplacer', 'a_faire', '2026-05-28', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1133, 'Lobby', 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs', 'validee', '2026-05-26', 'Miguel', 'Miguel', '2026-05-26', 'Rachid', false, '2026-05-26', 'Miguel', null, null),
  (1144, 'Lobby', 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs', 'validee', '2026-05-26', 'Miguel', 'Miguel', '2026-05-26', 'Rachid', false, '2026-05-26', 'Miguel', null, null),
  (1145, 'Cuisine', 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs', 'validee', '2026-05-26', 'Miguel', 'Miguel', '2026-05-26', 'Rachid', false, '2026-05-26', 'Miguel', null, null),
  (1146, 'Local TGBT', 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs', 'validee', '2026-05-26', 'Miguel', 'Miguel', '2026-05-26', 'Rachid', false, '2026-05-26', 'Miguel', null, null),
  (1147, 'Lingerie', 'Verification contractuelle pour vérifier si''il n''y a pas de présence de rongeurs', 'validee', '2026-05-26', 'Miguel', 'Miguel', '2026-05-26', 'Rachid', false, '2026-05-26', 'Miguel', null, null),
  (1185, '2eme étage', 'spot à changer', 'validee', '2026-05-26', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', 'spots noir (yess electrique)', 1.0),
  (1186, '54', 'serrer le bras liseuse côté gauche', 'validee', '2026-05-26', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1187, '54', 'serrer le bras liseuse côté droit', 'validee', '2026-05-26', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1188, '54', 'lit cassé côté gauche', 'validee', '2026-05-26', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1136, '58', 'La chasse d''eau ne fonctionne pas', 'validee', '2026-05-20', 'Miguel', 'Miguel', '2026-05-20', null, true, '2026-05-21', 'Victoria', null, null),
  (1137, '51', 'Faire la pose du Lino afin d''éviter toute fuite en chambre 41', 'a_faire', '2026-05-20', 'Sarah P', 'Miguel', null, null, false, null, null, null, null),
  (1138, '11', 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', 'validee', '2026-05-20', 'Sarah P', 'Miguel', '2026-05-20', null, true, '2026-05-26', 'Victoria', null, null),
  (1139, '12', 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', 'validee', '2026-05-20', 'Sarah P', 'Miguel', '2026-05-20', null, true, '2026-05-26', 'Victoria', null, null),
  (1140, '14', 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', 'validee', '2026-05-20', 'Sarah P', 'Miguel', '2026-05-20', null, true, '2026-05-26', 'Victoria', null, null),
  (1141, '15', 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', 'validee', '2026-05-20', 'Sarah P', 'Miguel', '2026-05-20', null, true, '2026-05-26', 'Victoria', null, null),
  (1142, '16', 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', 'validee', '2026-05-20', 'Sarah P', 'Miguel', '2026-05-20', null, true, '2026-05-26', 'Victoria', null, null),
  (1143, '18', 'Vérifier que tous les joints de la douche et de la salle de bain ne présentent aucun defaut', 'validee', '2026-05-20', 'Sarah P', 'Miguel', '2026-05-20', null, true, '2026-05-26', 'Victoria', null, null),
  (1182, '12', 'serrer le bras liseuse côté droit', 'validee', '2026-05-20', 'Victoria', 'Victoria', '2026-05-20', null, true, '2026-05-21', 'Victoria', null, null),
  (1183, '51', 'Joint de silicone à enlever pour ensuite poser des nouveaux au niveau du bac à douche', 'validee', '2026-05-20', 'Miguel', 'Sarah P', '2026-05-20', null, true, '2026-05-26', 'Victoria', null, null),
  (1184, '46', 'voir avec miroitier pour miroir placard cassé en bas (grand)', 'a_faire', '2026-05-20', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1093, '15', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-19', 'Sarah P', 'Miguel', '2026-05-19', null, true, '2026-05-19', 'Victoria', null, null),
  (1102, '28', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-19', 'Sarah P', 'Miguel', '2026-05-19', null, true, '2026-05-19', 'Victoria', null, null),
  (1110, '41', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-19', 'Sarah P', 'Miguel', '2026-05-19', null, true, '2026-05-19', 'Victoria', null, null),
  (1112, '44', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-19', 'Sarah P', 'Miguel', '2026-05-19', null, true, '2026-05-19', 'Victoria', null, null),
  (1114, '47', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-19', 'Sarah P', 'Miguel', '2026-05-19', null, true, '2026-05-19', 'Victoria', null, null),
  (1126, 'Parties communes', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-19', 'Sarah P', 'Miguel', '2026-05-19', null, true, '2026-05-19', 'Victoria', null, null),
  (1087, '01', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1088, '02', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1089, '03', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1090, '11', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1091, '12', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1092, '14', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1094, '16', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1095, '18', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1096, '21', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1097, '22', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1098, '24', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1099, '25', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1100, '26', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1101, '27', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1103, '31', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1104, '32', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1105, '34', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1106, '35', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1107, '36', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1108, '37', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1109, '38', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1111, '42', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1113, '45', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1115, '48', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1116, '51', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1117, '52', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1118, '54', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1119, '55', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1120, '56', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1121, '57', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1122, '58', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1123, 'Lobby', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1124, 'Salle de sport', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1130, '46', 'Nettoyage des filtres prévu dans le contrat avec Avir', 'validee', '2026-05-18', 'Sarah P', 'Miguel', '2026-05-18', null, true, '2026-05-18', 'Victoria', null, null),
  (1081, '12', 'cale porte à refixer (la piece est encore dans la chambre)', 'a_faire', '2026-05-16', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1080, 'Cuisine', 'Fuite au niveau du lave-vaisselle', 'en_cours', '2026-05-15', 'Victoria', 'Miguel', '2026-05-15', null, true, '2026-05-15', 'Victoria', null, null),
  (1046, '37', 'changer connecteur lumiéres miroir sdb', 'a_faire', '2026-05-14', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1047, '44', 'urgent - joints sillicone douche - lavabo  et wc à refaire complètement', 'validee', '2026-05-14', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-15', 'Victoria', null, null),
  (1048, '02', 'lit côté gauche cassé', 'validee', '2026-05-14', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-15', 'Victoria', null, null),
  (1049, '32', 'miroir plateau à changé', 'en_cours', '2026-05-14', 'Victoria', 'Victoria', '2026-05-20', null, true, '2026-05-26', 'Victoria', null, null),
  (1050, '16', 'miroir plateau à changé', 'a_faire', '2026-05-14', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1051, '02', 'bouton mitigeur douche manquant', 'a_faire', '2026-05-14', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1052, '26', 'bouton mitigeur douche manquant', 'a_faire', '2026-05-14', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1053, '27', 'bouton mitigeur douche manquant', 'a_faire', '2026-05-14', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1054, '28', 'urgent - joints sillicone douche - lavabo  et wc à refaire complètement', 'a_faire', '2026-05-14', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-16', 'Victoria', null, null),
  (1055, '46', 'urgent - joints sillicone douche - lavabo  et wc à refaire complètement', 'validee', '2026-05-14', 'Victoria', 'Victoria', '2026-06-25', null, true, '2026-07-01', 'Victoria', null, null),
  (1056, '48', 'urgent - joints sillicone douche - lavabo  et wc à refaire complètement', 'validee', '2026-05-14', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-15', 'Victoria', null, null),
  (1057, '58', 'bouton mitigeur douche manquant', 'a_faire', '2026-05-14', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1059, '58', 'serrer le bras liseuse côté droit', 'validee', '2026-05-14', 'Victoria', 'Victoria', '2026-05-20', null, true, '2026-05-21', 'Victoria', null, null),
  (1060, '57', 'serrer le bras liseuse côté gauche', 'validee', '2026-05-14', 'Victoria', 'Victoria', '2026-05-20', null, true, '2026-05-26', 'Victoria', null, null),
  (1061, '57', 'difficulté à fermer la porte de chambre -', 'validee', '2026-05-14', 'Victoria', 'Victoria', '2026-05-15', null, true, '2026-05-15', 'Victoria', null, null),
  (1062, '01', 'lit côté gauche cassé', 'validee', '2026-05-14', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-15', 'Victoria', null, null),
  (1063, '12', 'bouton mitigeur douche manquant', 'a_faire', '2026-05-14', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1064, '15', 'bouton mitigeur douche manquant', 'a_faire', '2026-05-14', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1065, '41', 'Le scratch du rideau est défaillant', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1066, '48', 'Le scratch du rideau est défaillant (SDB)', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1067, '31', 'Bruit provenant du panneau électrique', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1068, '27', 'Il manque des crochets pour faire tenir le rideau', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1069, '01', 'Il manque des crochets pour faire tenir le rideau', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1070, '18', 'Il manque des crochets pour faire tenir le rideau', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1071, '18', 'Vérifier s''il ne faut pas changer entièrement la colonne de douche', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1072, '42', 'Vérifier s''il ne faut pas changer entièrement la colonne de douche', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1073, '46', 'Vérifier s''il ne faut pas changer entièrement la colonne de douche', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', '2026-06-16', 'Miguel', false, '2026-06-18', 'Victoria', 'Flexible (Fournis par Serafino)', 1.0),
  (1074, '48', 'Vérifier s''il ne faut pas changer entièrement la colonne de douche', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1076, '42', 'Moisissure présente sans la salle de bain', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1077, '46', 'Moisissure présente sans la salle de bain', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1078, '48', 'Moisissure présente sans la salle de bain', 'a_faire', '2026-05-14', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1043, '12', 'lavabo bouché', 'validee', '2026-05-13', 'Victoria', 'Victoria', '2026-06-15', null, true, '2026-06-16', 'Victoria', null, null),
  (1044, 'WC Clients', 'Toilettes bouchés', 'validee', '2026-05-13', 'Miguel', 'Miguel', '2026-05-13', null, true, '2026-05-14', 'Victoria', null, null),
  (1045, '22', 'Il faut fixer la barre de douche au support mural', 'validee', '2026-05-13', 'Miguel', 'Miguel', '2026-05-13', null, true, '2026-05-19', 'Victoria', null, null),
  (1041, '32', 'batterie du bloc secours changé (celui au dessus de la porte d''entrée)', 'a_faire', '2026-05-11', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1042, '32', 'lavabo bouché', 'validee', '2026-05-11', 'Victoria', 'Victoria', '2026-05-13', null, true, '2026-05-14', 'Victoria', null, null),
  (1039, '41', 'Fuite au niveau du spot dans la douche', 'en_cours', '2026-05-10', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1040, 'WC Clients', 'flexible douche à changer', 'validee', '2026-05-10', 'Victoria', 'Victoria', '2026-05-20', null, true, '2026-05-21', 'Victoria', 'Flexible (Fournis par Serafino)', 1.0),
  (1038, '27', 'flexible fuit au niveau du pommeau de douche', 'validee', '2026-05-07', 'Victoria', 'Victoria', '2026-05-11', null, true, '2026-05-14', 'Victoria', null, null),
  (1033, '45', 'La base du fauteuil doit être visée', 'a_faire', '2026-05-04', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (1037, '45', 'Pièce qui sert à ajuster la hauteur du pommeau de douche à viser', 'validee', '2026-05-04', 'Victoria', 'Miguel', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1036, '14', 'changement du séche cheveux', 'validee', '2026-05-03', 'Victoria', 'Victoria', '2026-05-03', 'Miguel', false, '2026-05-03', 'Victoria', 'JVD - seche cheveux - Filfa', 1.0),
  (1034, 'Lobby', 'spot à changer (le premier devant la porte d’entrée)', 'validee', '2026-04-29', 'Miguel', 'Miguel', '2026-04-29', null, true, '2026-04-29', 'Victoria', 'spots blanc (yess electrique)', 1.0),
  (1035, 'Lobby', 'spot à changer (celui en face de la fenêtre et a cote de l''enceinte Bose)', 'a_faire', '2026-04-29', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (1028, 'PDJ', 'Fuite constatée au niveau du deuxième lustre.', 'en_cours', '2026-04-27', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (1029, 'PDJ', 'Il faut rattacher le support du lustre au plafond.', 'en_cours', '2026-04-27', 'Miguel', 'Miguel', '2026-04-26', null, true, '2026-04-27', 'Sarah P', null, null),
  (1030, '45', 'lit côté droit cassé', 'validee', '2026-04-27', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (1031, '26', 'flexible douche à changer', 'validee', '2026-04-27', 'Victoria', 'Victoria', '2026-04-23', null, true, '2026-04-27', 'Victoria', 'Flexible (Fournis par Serafino)', 1.0),
  (1027, '18', 'urgent! priorite coffre à reprogrammer', 'a_faire', '2026-04-24', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (1019, '22', 'flexible douche qui fuit', 'validee', '2026-04-21', 'Victoria', 'Victoria', '2026-04-23', null, true, '2026-04-27', 'Victoria', 'Flexible (Fournis par Serafino)', 1.0),
  (1018, '57', 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', '2026-04-20', 'Victoria', 'Victoria', '2026-04-22', null, true, '2026-04-23', 'Victoria', 'Économisseur d''énergie', 1.0),
  (1016, '37', 'Pommeau de douche à changer', 'validee', '2026-04-17', 'Miguel', 'Miguel', '2026-04-17', 'Miguel', false, '2026-04-17', 'Miguel', 'Pommeau de douche', 1.0),
  (1011, '57', 'porte d''entrée qui ne se verouille pas - urgent', 'validee', '2026-04-16', 'Victoria', 'Victoria', '2026-04-17', 'Miguel', false, '2026-04-17', 'Victoria', null, null),
  (1012, '58', 'porte d''entrée qui ne se verouille pas - urgent', 'validee', '2026-04-16', 'Victoria', 'Victoria', '2026-04-17', 'Miguel', false, '2026-04-17', 'Victoria', null, null),
  (1010, '35', 'La prise derrière la télévision ne fonctionne pas (à confirmer)', 'a_faire', '2026-04-14', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (1009, '25', 'lavabo bouché', 'validee', '2026-04-13', 'Victoria', 'Victoria', '2026-04-13', 'Miguel', false, '2026-04-13', 'Victoria', null, null),
  (1008, '15', 'prise arrachée du mur sdb', 'validee', '2026-04-11', 'Victoria', 'Victoria', '2026-04-16', null, true, '2026-04-17', 'Victoria', null, null),
  (1003, '52', 'télérupteur à changer - spot et leds', 'validee', '2026-04-09', 'Victoria', 'Victoria', '2026-04-16', null, true, '2026-04-17', 'Victoria', 'Télérupteurs (Mécaniques) Paris Elec ou YesssElectrique', 1.0),
  (1004, '16', 'prise arrachée du mur sdb', 'validee', '2026-04-09', 'Victoria', 'Victoria', '2026-04-16', null, true, '2026-04-17', 'Victoria', null, null),
  (1005, '16', 'lavabo bouché', 'validee', '2026-04-09', 'Victoria', 'Victoria', '2026-04-23', 'Victoria', false, '2026-05-14', 'Victoria', null, null),
  (1006, '28', 'lavabo bouché', 'validee', '2026-04-09', 'Victoria', 'Victoria', '2026-04-23', null, true, '2026-04-27', 'Victoria', null, null),
  (1007, '32', 'lavabo bouché', 'validee', '2026-04-09', 'Victoria', 'Victoria', '2026-04-23', null, true, '2026-04-27', 'Victoria', null, null),
  (1001, '27', 'flexible douche qui fuit', 'validee', '2026-04-05', 'Victoria', 'Miguel', '2026-04-23', null, true, '2026-04-27', 'Victoria', null, null),
  (1002, '25', 'Flexible douche à changer', 'validee', '2026-04-05', 'Victoria', 'Miguel', '2026-04-23', null, true, '2026-04-27', 'Victoria', 'flexibles douche ( noirs )', 1.0),
  (1000, '22', 'serrer le bras liseuse côté droit', 'validee', '2026-04-01', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (985, '36', 'refixer la liseuse de droite', 'validee', '2026-03-31', 'Victoria', 'Victoria', '2026-04-23', null, true, '2026-05-14', 'Victoria', null, null),
  (986, '36', 'barriere de douche à fixer', 'validee', '2026-03-31', 'Victoria', 'Victoria', '2026-04-23', null, true, '2026-05-14', 'Victoria', null, null),
  (987, '37', 'refixer le miroir grossissant', 'a_faire', '2026-03-31', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (988, '24', 'serrer le bras liseuse côté droit', 'validee', '2026-03-31', 'Victoria', 'Victoria', '2026-06-02', null, true, '2026-06-02', 'Victoria', null, null),
  (989, '27', 'serrer le bras liseuse côté droit', 'validee', '2026-03-31', 'Victoria', 'Victoria', '2026-05-11', null, true, '2026-05-14', 'Victoria', null, null),
  (990, '27', 'serrer le bras liseuse côté gauche', 'validee', '2026-03-31', 'Victoria', 'Victoria', '2026-05-11', null, true, '2026-05-14', 'Victoria', null, null),
  (991, '55', 'serrer le bras liseuse côté gauche', 'validee', '2026-03-31', 'Victoria', 'Victoria', '2026-04-23', null, true, '2026-04-27', 'Victoria', null, null),
  (992, '54', 'remplacement bras de liseuse (coté gauche)', 'validee', '2026-03-31', 'Victoria', 'Victoria', '2026-04-23', null, true, '2026-05-14', 'Victoria', 'Liseuses (Flexible + Source) - Brossier Saderne', 1.0),
  (993, '57', 'serrer le bras liseuse côté gauche', 'validee', '2026-03-31', 'Victoria', 'Victoria', '2026-04-23', null, true, '2026-04-27', 'Victoria', null, null),
  (994, '58', 'serrer le bras liseuse côté droit', 'validee', '2026-03-31', 'Victoria', 'Victoria', '2026-04-23', null, true, '2026-04-27', 'Victoria', null, null),
  (996, '12', 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', '2026-03-31', 'Victoria', 'Victoria', '2026-04-16', null, true, '2026-04-17', 'Victoria', 'Économisseur d''énergie', 1.0),
  (998, 'WC Clients', 'Sport à changer', 'a_faire', '2026-03-31', 'Sarah P', 'Miguel', null, null, false, null, null, null, null),
  (999, 'WC Hommes', 'Spot à changer', 'a_faire', '2026-03-31', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (984, '03', 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', '2026-03-30', 'Miguel', 'Miguel', '2026-04-22', null, true, '2026-04-22', 'Victoria', 'Économisseur d''énergie', 1.0),
  (979, '37', 'refixer la liseuse de droite', 'validee', '2026-03-24', 'Victoria', 'Victoria', '2026-04-23', null, true, '2026-05-14', 'Victoria', null, null),
  (981, '41', 'Fuite depuis joint d’évacuation en dessous d’évier', 'validee', '2026-03-24', 'Victoria', 'Miguel', '2026-03-24', null, true, '2026-03-24', 'Victoria', null, null),
  (982, '58', 'Fuite depuis joint d’évacuation en dessous d’évier', 'validee', '2026-03-24', 'Victoria', 'Miguel', '2026-05-20', null, true, '2026-05-26', 'Victoria', null, null),
  (980, '38', 'Fuite depuis joint d’évacuation en dessous d’évier', 'validee', '2026-03-23', 'Miguel', 'Miguel', '2026-03-24', null, true, '2026-03-24', 'Victoria', null, null),
  (975, '01', 'télérupteur à changer - appliques murales sautent', 'validee', '2026-03-10', 'Victoria', 'Victoria', '2026-04-22', null, true, '2026-04-27', 'Victoria', null, null),
  (976, 'Réception', 'spot à changer', 'validee', '2026-03-10', 'Victoria', 'Victoria', '2026-03-17', null, true, '2026-03-31', 'Victoria', 'spots blanc (yess electrique)', 1.0),
  (974, '27', 'refixer la prise', 'validee', '2026-03-08', 'Victoria', 'Victoria', '2026-05-11', null, true, '2026-05-14', 'Victoria', null, null),
  (1086, '24', 'La serrure électronique de chez dormakaba ne fonctionne plus', 'validee', '2026-02-26', 'Miguel', 'Miguel', '2026-03-06', null, false, null, null, null, null),
  (1127, 'Ascenseur', 'Visite contractuelle afin de vérifier si tout fonctionne correctement - Kone', 'validee', '2026-02-26', 'Sarah P', 'Miguel', '2026-02-26', null, true, '2026-02-26', 'Victoria', null, null),
  (949, '11', 'Objet coincé dans la prise électrique', 'validee', '2026-02-24', 'Miguel', 'Miguel', '2026-02-24', null, true, '2026-02-24', 'Miguel', null, null),
  (950, 'Lobby', 'Objet coincé dans la prise électrique', 'validee', '2026-02-24', 'Miguel', 'Miguel', '2026-02-24', null, true, '2026-02-24', 'Miguel', null, null),
  (946, '37', 'Liseuse côté gauche à changer', 'validee', '2026-02-23', 'Victoria', 'Miguel', '2026-02-23', null, true, '2026-02-23', 'Victoria', 'Liseuses  (flexibles)', 1.0),
  (947, '51', 'Sol du bac de douche decoller (pour montrer à l''inspecteur) puis recoller de nouveau)', 'validee', '2026-02-23', 'Sarah P', 'Miguel', '2026-02-23', null, true, '2026-02-24', 'Victoria', null, null),
  (948, '45', 'Sol du bac de douche decoller (pour montrer à l''inspecteur) puis recoller de nouveau)', 'validee', '2026-02-23', 'Sarah P', 'Miguel', '2026-02-23', null, true, '2026-02-24', 'Victoria', null, null),
  (900, '32', 'tablette miroir cassée pendant le remplacement + casse du grand miroir intèrieur placard', 'a_faire', '2026-02-05', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (901, 'WC Clients', 'Flexible à changer', 'validee', '2026-02-05', 'Miguel', 'Miguel', '2026-02-05', null, true, '2026-02-05', 'Miguel', 'flexibles douche ( noirs )', 1.0),
  (977, 'Lobby', 'Batterie du bloc secours à changer (celui en face de la sortie de secours)', 'validee', '2026-02-05', 'Miguel', 'Miguel', '2026-03-17', null, true, '2026-03-17', 'Miguel', 'Batteries Telec', 1.0),
  (891, '03', 'sol parquet abîmé – mettre pate à bois', 'validee', '2026-01-29', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (899, 'Salle de repos', 'Neon salle de repos à changer', 'validee', '2026-01-29', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (892, 'COUR intèrieure', 'passer le produit sur le parquet ( même dessoous les bacs à plantes) - produit dans la bagagerie', 'en_cours', '2026-01-27', 'Sarah P', 'Sarah P', null, null, false, null, null, null, null),
  (893, '02', 'flexible de douche à changer', 'validee', '2026-01-23', 'Victoria', 'Miguel', '2026-02-05', null, true, '2026-02-05', 'Victoria', null, null),
  (895, '11', 'flexible de douche à changer', 'validee', '2026-01-23', 'Victoria', 'Miguel', '2026-02-05', null, true, '2026-02-05', 'Victoria', null, null),
  (896, '22', 'flexible de douche à changer', 'validee', '2026-01-23', 'Victoria', 'Miguel', '2026-02-05', null, true, '2026-02-05', 'Victoria', null, null),
  (898, '18', 'flexible douche qui fuit', 'validee', '2026-01-23', 'Victoria', 'Miguel', '2026-06-02', null, true, '2026-06-02', 'Victoria', 'Flexible (Fournis par Serafino)', 1.0),
  (803, '58', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-14', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (483, '22', 'Changement flexible liseuse droite', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', 'Liseuses  (flexibles)', 1.0),
  (492, '22', 'Changement ampoule lampe bureau', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', null, null),
  (504, '24', 'Changement flexible liseuse droite', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', 'Liseuses  (flexibles)', 1.0),
  (505, '24', 'barre de pare douche à refixer', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', null, null),
  (516, '25', 'Changement flexible liseuse droite', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', 'Liseuses  (flexibles)', 1.0),
  (517, '25', 'Télérupteur appliques changé', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, null, 'Télérupteurs (Mécaniques) Paris Elec ou YesssElectrique', 1.0),
  (609, '37', 'Miroir plateau à changé', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-02-05', null, true, '2026-02-05', 'Victoria', null, null),
  (632, '41', 'Grand miroir côté armoire cassé', 'a_faire', '2026-01-13', 'Victoria', 'Sarah P', null, null, false, null, null, null, null),
  (643, '42', 'spot chambre à remplacer', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', 'spots blanc (yess electrique)', 1.0),
  (664, '45', 'frein de chute abattant WC non fonctionnel -', 'a_acheter', '2026-01-13', 'Victoria', 'Sarah P', null, null, false, null, null, null, null),
  (666, '45', 'Cadre porte SDB bois - décollé du mur', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', null, null),
  (701, '47', 'Miroir plateau à changé', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-05-11', null, true, '2026-05-14', 'Victoria', null, null),
  (702, '47', 'Grand miroir côté armoire cassé', 'a_faire', '2026-01-13', 'Victoria', 'Sarah P', null, null, false, null, null, null, null),
  (703, '47', 'spot chambre à remplacer', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', 'spots blanc (yess electrique)', 1.0),
  (704, '47', 'Lavabo bouché', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', null, null),
  (725, '51', 'Miroir plateau à changé', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-02-05', null, true, '2026-02-05', 'Victoria', null, null),
  (726, '51', 'Changement support lait corporel', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', null, null),
  (762, '54', 'Miroir plateau à changé', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-02-05', null, true, '2026-02-05', 'Victoria', null, null),
  (772, '55', 'Lèvre de douche à changer sur le côté pare douche', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', null, null),
  (786, '56', 'fuite mitigeur douche', 'a_acheter', '2026-01-13', 'Victoria', 'Sarah P', null, null, false, null, null, null, null),
  (787, '56', 'Lèvre de douche à changer sur le côté pare douche', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', null, null),
  (789, '57', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-13', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (798, '57', 'Refixer liseuse gauche', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', null, null),
  (799, '57', 'poignée porte principale à resserrer', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', null, null),
  (815, '58', 'liseuse gauche à resserer', 'validee', '2026-01-13', 'Victoria', 'Sarah P', '2026-01-13', null, true, null, 'Victoria', null, null),
  (775, '56', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-12', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (845, 'Lobby', 'Spot à changer', 'validee', '2026-01-12', 'Sarah P', 'Miguel', '2026-03-17', null, true, '2026-03-17', 'Miguel', 'spots blanc (yess electrique)', 1.0),
  (764, '55', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-11', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (746, '54', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-10', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (727, '52', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-09', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (588, '35', 'Il faut changer la bouilloire', 'validee', '2026-01-08', 'Miguel', 'Miguel', '2026-01-08', 'Victoria', false, null, null, 'BOUILLOIRE BONJOUR 600ML NOIR MAT ALISEO', 1.0),
  (717, '51', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-08', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (706, '48', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-07', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (470, '18', 'Sèche serviette à refixer -', 'validee', '2026-01-06', 'Sarah P', 'Sarah P', '2026-02-05', null, true, '2026-02-05', 'Victoria', null, null),
  (692, '47', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-06', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (668, '46', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-05', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (652, '45', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-04', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (644, '44', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-03', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (623, '38', 'Serrer le bras liseuse côté droit', 'validee', '2026-01-02', 'Victoria', 'Miguel', '2026-04-23', null, true, '2026-04-27', 'Victoria', null, null),
  (633, '42', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-02', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (625, '41', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2026-01-01', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (611, '38', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-31', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (602, '37', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-30', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (590, '36', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-29', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (575, '35', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-28', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (565, '34', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-27', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (558, '32', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-26', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (551, '31', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-25', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (844, 'Lobby', 'URGENT - Difficulté à fermer la porte qui mene à la cour', 'validee', '2025-12-25', 'Victoria', 'Miguel', '2026-01-12', null, true, null, null, null, null),
  (535, '28', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-24', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (882, 'WC Femmes', 'Serrer le bras liseuse côté droit', 'validee', '2025-12-24', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', 'spots blanc (yess electrique)', 1.0),
  (398, '11', 'Lavabo bouché', 'validee', '2025-12-23', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (456, '18', 'Lavabo bouché', 'validee', '2025-12-23', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (471, '21', 'Lavabo bouché', 'validee', '2025-12-23', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (472, '21', 'Resserrer la poignée de la porte d''entrée', 'validee', '2025-12-23', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (525, '27', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-23', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (589, '36', 'Lit côté droit cassé', 'validee', '2025-12-23', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (595, '36', 'flexible liseuse côté droit à resserer', 'validee', '2025-12-23', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (667, '46', 'La poignée de la fenêtre s''enlève', 'validee', '2025-12-23', 'Victoria', 'Sarah P', '2025-12-23', null, true, null, 'Victoria', null, null),
  (801, '58', 'Lavabo bouché', 'validee', '2025-12-23', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (802, '58', 'Serrer le bras liseuse côté droit', 'validee', '2025-12-23', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (518, '26', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-22', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (509, '25', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-21', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (495, '24', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-20', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (485, '22', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-19', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (474, '21', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-18', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (458, '18', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-17', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (446, '16', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-16', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (435, '15', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-15', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (427, '14', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-14', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (413, '12', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-13', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (400, '11', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-12', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (386, '03', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-11', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (1128, 'Ascenseur', 'Ascenseur en panne - Il faut contacter KONE', 'validee', '2025-12-11', 'Miguel', 'Miguel', '2025-12-11', null, true, '2025-12-11', 'Miguel', null, null),
  (380, '02', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-10', 'Sarah P', 'Miguel', '2025-12-09', null, true, null, 'Miguel', null, null),
  (573, '34', 'Refixer le miroir grossissant', 'a_faire', '2025-12-10', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (622, '38', 'Refixer le miroir grossissant', 'a_faire', '2025-12-10', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (876, 'Sous-sol divers', 'Fortes odeurs constaté au niveau de la colonne, il faut trouver une solution pour reboucher', 'validee', '2025-12-10', 'Miguel', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (370, '01', 'Changement des circuits électriques pour que la TV ne s''éteigne plus quand la carte est retirée', 'validee', '2025-12-09', 'Sarah P', 'Victoria', '2025-12-09', null, true, null, 'Miguel', null, null),
  (379, '02', 'Lit côté gauche cassé', 'validee', '2025-12-09', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (412, '12', 'Spot à changer', 'validee', '2025-12-09', 'Miguel', 'Miguel', '2025-12-09', null, true, null, 'Miguel', 'spots blanc (yess electrique)', 1.0),
  (484, '22', 'Télérupteur à changer - spot et leds', 'validee', '2025-12-09', 'Miguel', 'Miguel', '2025-12-09', null, true, null, 'Miguel', 'Télérupteurs (Mécaniques) Paris Elec ou YesssElectrique', 1.0),
  (506, '24', 'Liseuse côté droit à changer', 'validee', '2025-12-09', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (507, '25', 'Télérupteur à changer - spot et leds', 'validee', '2025-12-09', 'Miguel', 'Miguel', '2025-12-09', null, true, null, 'Miguel', 'Télérupteurs (Mécaniques) Paris Elec ou YesssElectrique', 1.0),
  (508, '25', 'Spot à changer', 'validee', '2025-12-09', 'Miguel', 'Miguel', '2025-12-09', null, true, null, 'Miguel', 'spots blanc (yess electrique)', 1.0),
  (691, '47', 'Télérupteur à changer - appliques murales sautent', 'validee', '2025-12-09', 'Miguel', 'Miguel', '2025-12-09', null, true, null, 'Miguel', 'Télérupteurs (Mécaniques) Paris Elec ou YesssElectrique', 1.0),
  (773, '56', 'Télérupteur à changer - appliques murales sautent', 'validee', '2025-12-09', 'Miguel', 'Miguel', '2025-12-09', null, true, null, 'Miguel', 'Télérupteurs (Mécaniques) Paris Elec ou YesssElectrique', 1.0),
  (774, '56', 'Spot à changer', 'validee', '2025-12-09', 'Miguel', 'Miguel', '2025-12-09', null, true, null, 'Miguel', 'spots blanc (yess electrique)', 1.0),
  (788, '57', 'Liseuse côté gauche à changer', 'validee', '2025-12-09', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', 'Liseuses  (flexibles)', 1.0),
  (459, '18', 'La poignée de la fenêtre s''enlève', 'validee', '2025-12-02', 'Victoria', 'Sarah P', '2025-12-03', null, true, null, 'Victoria', null, null),
  (462, '18', 'Porte placard du haut à remettre / se trouve dans le local technique', 'a_faire', '2025-12-02', 'Victoria', 'Sarah P', null, null, false, null, null, null, null),
  (716, '51', 'lit côté droit cassé - à agrafer', 'validee', '2025-12-02', 'Victoria', 'Sarah P', '2025-12-23', null, true, null, 'Victoria', null, null),
  (744, '54', 'lit côté droit cassé - à agrafer', 'validee', '2025-12-02', 'Victoria', 'Sarah P', '2025-12-23', null, true, null, 'Victoria', null, null),
  (576, '35', 'Changement du séche cheveux', 'validee', '2025-11-25', 'Victoria', 'Miguel', '2025-11-26', 'Victoria', false, null, 'Victoria', 'JVD - seche cheveux - Filfa', 1.0),
  (396, '03', 'Fuite au niveau du bac de douche', 'validee', '2025-11-16', 'Miguel', 'Miguel', '2025-11-16', null, true, null, null, null, null),
  (469, '18', 'flexible douche à changer', 'validee', '2025-11-15', 'Victoria', 'Miguel', '2025-11-16', null, true, null, null, 'Flexible de douche (stockB)', 1.0),
  (399, '11', 'Resserrer la poignée', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (447, '16', 'La poignée de la fenêtre s''enlève', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-03', null, true, null, 'Victoria', null, null),
  (473, '21', 'Télérupteur à changer - appliques murales sautent', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-09', null, true, null, 'Miguel', 'Télérupteurs (Mécaniques) Paris Elec ou YesssElectrique', 1.0),
  (493, '22', 'barriere de douche à fixer', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2026-02-25', null, true, '2026-02-25', 'Victoria', null, null),
  (494, '24', 'Lit côté droit cassé', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (534, '28', 'Plinthe de la fenêtre à recoller', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (548, '28', 'Cache pile du coffre manquant', 'a_faire', '2025-11-11', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (574, '35', 'Serrer le bras liseuse côté gauche', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (610, '38', 'Serrer le bras liseuse côté gauche', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (626, '41', 'Cale porte à refixer (la piece est encore dans la chambre)', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-03', null, true, null, 'Victoria', null, null),
  (634, '42', 'Refixer le miroir grossissant', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-03', null, true, null, 'Victoria', null, null),
  (641, '42', 'Bac de douche à changer - URGENT', 'en_cours', '2025-11-11', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (642, '42', 'fenêtre se ferme mal', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2026-01-13', null, true, null, 'Victoria', null, null),
  (689, '46', 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)', 'a_faire', '2025-11-11', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (700, '47', 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)', 'a_faire', '2025-11-11', 'Victoria', 'Miguel', '2026-05-11', null, true, '2026-05-14', 'Victoria', null, null),
  (705, '48', 'Lit côté droit cassé', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-23', null, true, null, 'Victoria', null, null),
  (729, '52', 'Il faut changer la bouilloire', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-11-26', 'Victoria', false, null, 'Victoria', 'BOUILLOIRE BONJOUR 600ML NOIR MAT ALISEO', 1.0),
  (743, '52', 'barriere de douche à fixer', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2026-02-23', null, true, '2026-02-23', 'Victoria', null, null),
  (745, '54', 'Liseuse côté droit à changer', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-03', null, true, null, 'Victoria', 'Liseuses (Flexible + Source) - Brossier Saderne', 1.0),
  (763, '55', 'Spot  à changer - côté du miroir', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-03', null, true, null, 'Victoria', null, null),
  (800, '58', 'Serrer le bras liseuse côté droit', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-03', null, true, null, 'Victoria', null, null),
  (820, '3eme étage', 'Spot noir à changer - en face de la chambre 38', 'validee', '2025-11-11', 'Victoria', 'Miguel', '2025-12-03', null, true, null, 'Victoria', 'spots blanc (yess electrique)', 1.0),
  (825, '4eme étage', 'Batterie du bloc secours à changer (celui en face de la chambre 48)', 'a_faire', '2025-11-11', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (826, 'Palier 5ème', 'Batterie du bloc secours à changer (celui en face de la chambre 58)', 'a_faire', '2025-11-11', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (850, 'Local TGBT', 'Il manque juste le petit papier qui va à l''interieur et non le cache', 'en_cours', '2025-11-09', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (455, '16', 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', '2025-11-07', 'Victoria', 'Miguel', '2026-04-22', null, true, '2026-04-22', 'Victoria', 'Économisseur d''énergie', 1.0),
  (819, '2eme étage', 'Batterie du bloc secours à changer (celui en face de la chambre 28)', 'validee', '2025-11-03', 'Miguel', 'Miguel', '2025-11-16', null, true, null, null, 'Batteries Telec', 0.0),
  (615, '38', 'flexible liseuse côté droit à changer', 'validee', '2025-10-28', 'Victoria', 'Miguel', '2025-11-16', null, true, null, null, 'Liseuses  (flexibles)', 1.0),
  (616, '38', 'flexible liseuse côté gauche à fixer', 'validee', '2025-10-28', 'Victoria', 'Miguel', '2025-11-16', null, true, null, null, null, null),
  (710, '48', 'flexible liseuse côté gauche à fixer', 'validee', '2025-10-28', 'Victoria', 'Miguel', '2025-11-16', null, true, null, null, null, null),
  (728, '52', 'flexible liseuse côté droit à changer', 'validee', '2025-10-28', 'Victoria', 'Miguel', '2025-11-16', null, true, null, null, 'Liseuses  (flexibles)', 1.0),
  (824, '4eme étage', 'Batterie du bloc secours à changer (celui en face de la chambre 44)', 'validee', '2025-10-22', 'Miguel', 'Miguel', '2025-10-23', null, true, null, 'Miguel', 'Batteries Telec', 2.0),
  (784, '56', 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', '2025-10-17', 'Victoria', 'Miguel', '2026-04-16', null, true, '2026-04-17', 'Victoria', 'Économisseur d''énergie', 1.0),
  (376, '01', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (384, '02', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (394, '03', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (407, '11', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (420, '12', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (433, '14', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (444, '15', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (452, '16', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (465, '18', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (480, '21', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (488, '22', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (500, '24', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (514, '25', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (520, '26', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (527, '27', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (542, '28', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (556, '31', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (563, '32', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (570, '34', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (581, '35', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (597, '36', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (605, '37', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (618, '38', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (631, '41', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (640, '42', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (648, '44', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (661, '45', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (681, '46', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (697, '47', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (713, '48', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (722, '51', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (736, '52', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (759, '54', 'Détection de punaises de lit au niveau de la tête de lit constaté le 30/09/25 par la societe Ecoflair', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-10-01', 'Rachid', false, null, null, 'Traitement chimique', 1.0),
  (760, '54', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (769, '55', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (782, '56', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (795, '57', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (811, '58', 'Demande de vérification s''il y a la présence de punaises', 'validee', '2025-09-30', 'Sarah P', 'Miguel', '2025-09-30', null, true, null, null, 'Détection Canine', 1.0),
  (510, '25', 'Coffre fort HS', 'validee', '2025-09-28', 'Sarah P', 'Sarah P', '2025-11-03', null, true, null, 'Miguel', 'Coffre-Fort (EUROPROH)', 1.0),
  (385, '03', 'Serrer le bras liseuse côté gauche', 'validee', '2025-09-26', 'Victoria', 'Miguel', '2025-09-26', null, true, null, 'Victoria', null, null),
  (503, '24', 'Lit côté gauche cassé', 'validee', '2025-09-26', 'Victoria', 'Miguel', '2025-11-16', null, true, null, null, null, null),
  (550, '31', 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)', 'validee', '2025-09-26', 'Victoria', 'Miguel', '2025-09-26', null, true, null, 'Victoria', null, null),
  (843, 'Lingerie', 'Nettoyage du tuyau d''évacuation du séche linge', 'validee', '2025-09-26', 'Victoria', 'Miguel', '2025-09-26', null, true, null, 'Victoria', null, null),
  (693, '47', 'Il faut changer la bouilloire', 'validee', '2025-09-22', 'Victoria', 'Miguel', '2025-09-22', 'Victoria', false, null, 'Victoria', 'BOUILLOIRE BONJOUR 600ML NOIR MAT ALISEO', 1.0),
  (686, '46', 'Flexible de douche à changer', 'validee', '2025-09-18', 'Victoria', 'Miguel', '2026-06-15', null, true, '2026-06-15', 'Victoria', 'Flexible (Fournis par Serafino)', 1.0),
  (823, '4eme étage', 'Batterie du bloc secours à changer (celui en face de l''ascenseur)', 'validee', '2025-09-17', 'Miguel', 'Miguel', '2025-10-23', null, true, null, 'Miguel', 'Batteries Telec', 2.0),
  (676, '46', 'télérupteur pour spots plafond à changer', 'validee', '2025-09-12', 'Miguel', 'Miguel', '2025-09-12', null, true, null, null, 'Télérupteur électrique (YesssElectrique)', 1.0),
  (816, 'Palier 1er', 'Spot à coté de l''ascenseur à changer', 'validee', '2025-09-12', 'Miguel', 'Miguel', null, null, false, null, null, 'spots blanc (yess electrique)', 1.0),
  (463, '18', 'Spot plafond au fond à changer', 'validee', '2025-09-11', 'Victoria', 'Miguel', '2025-09-12', null, true, null, null, 'spots blanc (yess electrique)', 1.0),
  (536, '28', 'Cadre de la porte de la salle de bain à fixer', 'validee', '2025-09-11', 'Victoria', 'Miguel', '2025-09-18', null, true, null, 'Victoria', null, null),
  (547, '28', 'Lumiéres miroir SDB', 'validee', '2025-09-11', 'Victoria', 'Miguel', '2026-04-29', null, true, '2026-04-29', 'Victoria', null, null),
  (587, '35', 'télécommande CLIM à remplacer', 'a_faire', '2025-09-11', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (621, '38', 'changer connecteur lumiéres miroir SDB', 'validee', '2025-09-11', 'Victoria', 'Miguel', '2026-04-29', null, true, '2026-04-29', 'Victoria', null, null),
  (685, '46', 'changer connecteur lumiéres miroir SDB', 'validee', '2025-09-11', 'Victoria', 'Miguel', '2025-09-12', null, true, null, null, null, null),
  (869, 'Réception', 'Spot plafond derrière la réception à changer', 'validee', '2025-09-11', 'Victoria', 'Miguel', '2025-09-12', null, true, null, null, 'spots blanc (yess electrique)', 1.0),
  (619, '38', 'Refixer la liseuse de gauche', 'validee', '2025-09-09', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (1129, 'Ascenseur', 'Ascenseur en panne - Il faut contacter KONE', 'validee', '2025-09-09', 'Miguel', 'Miguel', '2025-09-13', null, true, '2025-09-13', 'Miguel', null, null),
  (478, '21', 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', '2025-09-07', 'Miguel', 'Miguel', '2025-09-12', null, true, null, null, 'Économisseur d''énergie', 1.0),
  (591, '36', 'L''eau coule dans la cuvette des WC', 'validee', '2025-09-07', 'Victoria', 'Miguel', '2025-09-18', null, true, null, 'Victoria', null, null),
  (669, '46', 'barriere de douche à fixer', 'validee', '2025-09-07', 'Victoria', 'Miguel', '2025-09-18', null, true, null, 'Victoria', null, null),
  (730, '52', 'Refixer correctement le miroir grossissant au mur SDB', 'validee', '2025-09-07', 'Victoria', 'Miguel', '2025-09-18', null, true, null, 'Victoria', null, null),
  (747, '54', 'barriere de douche à fixer', 'validee', '2025-09-07', 'Victoria', 'Miguel', '2025-09-18', null, true, null, 'Victoria', null, null),
  (834, 'Entrée', 'Porte d''entrée qui ne se verouille pas - URGENT', 'validee', '2025-09-02', 'Miguel', 'Miguel', '2025-09-12', null, true, null, 'Miguel', null, null),
  (831, 'Cuisine', 'Spot à changer', 'validee', '2025-08-31', 'Miguel', 'Miguel', null, null, false, null, null, 'spots blanc (yess electrique)', 1.0),
  (426, '14', 'L''eau coule dans la cuvette des WC', 'validee', '2025-08-28', 'Victoria', 'Miguel', '2025-09-26', null, true, null, 'Victoria', null, null),
  (448, '16', 'L''eau coule dans la cuvette des WC', 'validee', '2025-08-28', 'Victoria', 'Miguel', '2025-09-20', null, true, null, 'Victoria', null, null),
  (475, '21', 'L''eau coule dans la cuvette des WC', 'validee', '2025-08-28', 'Victoria', 'Miguel', '2025-09-20', null, true, null, 'Victoria', null, null),
  (838, 'Parties communes', 'Ampoule de l''applique à changer', 'validee', '2025-08-28', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (840, 'escalier qui mène au 5ème', 'bloc secour/batterie a changer', 'validee', '2025-08-28', 'Miguel', 'Miguel', '2025-10-23', null, true, null, 'Miguel', 'Batteries Telec', 2.0),
  (848, 'Local TGBT', 'bloc secour/batterie a changer', 'validee', '2025-08-28', 'Miguel', 'Miguel', '2025-10-23', null, true, null, 'Miguel', 'Batteries Telec (LOCAL TGBT)', 1.0),
  (1131, 'Ascenseur', 'Ascenseur en panne - Il faut contacter KONE', 'validee', '2025-08-18', 'Sarah P', 'Miguel', '2025-08-18', null, true, '2025-08-18', 'Sarah P', null, null),
  (421, '12', 'Flexible fuit au niveau du pommeau de douche', 'validee', '2025-08-15', 'Victoria', 'Sarah P', '2025-09-18', null, true, null, null, 'Flexible de douche (stockB)', 1.0),
  (425, '14', 'Lit cassé côté gauche', 'validee', '2025-08-15', 'Victoria', 'Sarah P', '2025-09-26', null, true, null, 'Victoria', null, null),
  (709, '48', 'flexible liseuse côté droit à changer', 'validee', '2025-08-15', 'Victoria', 'Sarah P', '2025-11-16', null, true, null, null, 'Liseuses  (flexibles)', 1.0),
  (875, 'WC Femmes', 'ecoulement faible eau chasse d''eau vestiaire femme', 'validee', '2025-08-15', 'Victoria', 'Sarah P', '2025-09-18', null, true, null, 'Victoria', null, null),
  (879, 'Sous-sol divers', 'évier salle de pause  qui fuit', 'a_acheter', '2025-08-15', 'Victoria', 'Sarah P', null, null, false, null, null, null, null),
  (733, '52', 'télérupteur pour spots plafond à changer', 'validee', '2025-08-11', 'Sarah P', 'Sarah P', '2025-09-12', null, true, null, null, 'Télérupteur électrique (YesssElectrique)', 1.0),
  (839, 'escalier qui mène au 4ème', 'bloc secour/batterie à changer', 'validee', '2025-08-04', 'Sarah P', 'Sarah P', '2025-10-23', null, true, null, 'Miguel', 'Batteries Telec', 2.0),
  (852, 'Office 5 ème étage', 'trappe au plafond à refermer', 'en_cours', '2025-08-02', 'Sarah P', 'Sarah P', '2025-08-04', null, true, null, null, null, null),
  (853, 'Office 5 ème étage', 'voir comment rendre le boitier élec étanche en cas de nouvelle fuite', 'en_cours', '2025-08-02', 'Sarah P', 'Sarah P', null, null, false, null, null, null, null),
  (496, '24', 'La porte principale ne se fermait pas bien', 'validee', '2025-08-01', 'Miguel', 'Miguel', '2025-08-05', null, true, null, null, null, null),
  (502, '24', 'Il manque un joint sur la porte de la salle de bain et elle est désaxée', 'validee', '2025-08-01', 'Miguel', 'Miguel', '2025-08-05', null, true, null, null, null, null),
  (835, 'Entrée', 'Spot côté à changer devant la camera', 'validee', '2025-07-31', 'Miguel', 'Miguel', '2025-08-04', null, true, null, null, 'spots blanc (yess electrique)', 1.0),
  (866, 'Réception', 'Spot côté à changer à côté du miroir', 'validee', '2025-07-31', 'Miguel', 'Miguel', '2025-08-04', null, true, null, null, 'spots blanc (yess electrique)', 1.0),
  (867, 'Réception', 'Spot côté à changer derriere la réception', 'validee', '2025-07-31', 'Miguel', 'Miguel', '2025-08-04', null, true, null, 'Sarah P', 'spots blanc (yess electrique)', 1.0),
  (409, '11', 'Serrer le bras liseuse côté gauche', 'validee', '2025-07-30', 'Miguel', 'Miguel', '2025-08-05', null, true, null, null, null, null),
  (533, '27', 'deboucher l''evier', 'validee', '2025-07-30', 'Miguel', 'Miguel', '2025-07-31', null, false, null, null, null, null),
  (572, '34', 'Vis tombé de la douche à la reception - à la reception', 'validee', '2025-07-30', 'Miguel', 'Miguel', '2025-08-05', null, true, null, null, null, null),
  (601, '37', 'Vis seche serviette à la reception', 'validee', '2025-07-30', 'Miguel', 'Miguel', '2025-09-26', null, true, null, 'Victoria', null, null),
  (780, '56', 'Changement du séche cheveux', 'validee', '2025-07-27', 'Miguel', 'Miguel', '2025-07-22', 'Victoria', false, null, null, 'JVD - seche cheveux - Filfa', 1.0),
  (395, '03', 'bouton mitigeur douche manquant', 'validee', '2025-07-25', 'Sarah P', 'Sarah P', '2026-04-23', null, true, '2026-05-14', 'Victoria', null, null),
  (860, 'PDJ', 'Faire installer la machine café -', 'validee', '2025-07-25', 'Sarah P', 'Sarah P', '2025-08-05', null, true, null, 'Sarah P', null, null),
  (861, 'PDJ', 'demander à Hedi de contrôler l''état des crépines, des gouttières et de la descente de pluie et les dégager si beoin', 'a_faire', '2025-07-25', 'Sarah P', 'Sarah P', null, null, false, null, null, null, null),
  (880, 'Toit', 'acheter crépines pour les 2 gouttières sur le toit terrasse', 'a_acheter', '2025-07-25', 'Sarah P', 'Sarah P', null, null, false, null, null, null, null),
  (372, '01', 'Vis du haut de la gâche à changer', 'validee', '2025-07-24', 'Miguel', 'Miguel', '2025-09-18', null, true, null, 'Victoria', null, null),
  (486, '22', 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', '2025-07-24', 'Miguel', 'Miguel', '2025-08-04', null, true, null, null, 'Économisseur d''énergie', 1.0),
  (809, '58', 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', '2025-07-24', 'Miguel', 'Miguel', '2025-08-04', null, true, null, null, 'Économisseur d''énergie', 1.0),
  (855, 'Palier 1er', 'bloc secour/batterie a changer (en face de la chambre 14)', 'validee', '2025-07-24', 'Victoria', 'Miguel', '2025-08-04', null, true, null, null, 'Batteries Telec', 2.0),
  (635, '42', 'Lavabo bouché', 'validee', '2025-07-11', 'Victoria', 'Miguel', '2025-07-11', null, true, null, 'Victoria', null, null),
  (653, '45', 'Lavabo bouché', 'validee', '2025-07-11', 'Victoria', 'Miguel', '2025-07-11', null, true, null, 'Victoria', null, null),
  (670, '46', 'Lavabo bouché', 'validee', '2025-07-11', 'Victoria', 'Miguel', '2025-07-11', null, true, null, 'Victoria', null, null),
  (827, 'Bagagerie', 'Ampoule de la suspension lumineuse à côté de l''ascenseur qui clignote parfois', 'validee', '2025-07-08', 'Miguel', 'Miguel', '2025-08-04', null, true, null, null, null, null),
  (577, '35', 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', '2025-06-25', 'Miguel', 'Miguel', '2025-06-24', null, true, null, 'Victoria', 'Économisseur d''énergie', 1.0),
  (645, '44', 'Lavabo bouché', 'validee', '2025-06-24', 'Victoria', 'Miguel', '2025-06-24', null, true, null, 'Victoria', null, null),
  (833, 'Parties communes', 'Fil de d''aspirateur à changer', 'validee', '2025-06-24', 'Victoria', 'Miguel', '2025-06-24', null, true, null, 'Victoria', 'Cable aspirateur 15 mètres - 32 mm (pour Nupro)', 1.0),
  (828, 'PDJ', 'Spot à changer (celui de droite)', 'validee', '2025-06-21', 'Miguel', 'Miguel', '2025-08-04', null, true, null, null, 'spots blanc (yess electrique)', 1.0),
  (854, 'Office 5 ème étage', 'Spot à changer', 'validee', '2025-06-21', 'Miguel', 'Miguel', '2025-06-24', null, true, null, 'Victoria', null, null),
  (624, '41', 'Joint pour faire tenir le pommeau de douche', 'validee', '2025-06-09', 'Miguel', 'Miguel', '2025-09-26', null, true, null, 'Victoria', null, null),
  (599, '36', 'Lumiere miroir à vérifier', 'validee', '2025-06-04', 'Victoria', 'Miguel', '2026-04-29', null, true, '2026-04-29', 'Victoria', null, null),
  (579, '35', 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', '2025-06-02', 'Miguel', 'Miguel', '2025-08-04', null, true, null, null, 'Économisseur d''énergie', 1.0),
  (663, '45', 'Mur gauche côté fenêtre endommagé', 'a_faire', '2025-06-02', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (688, '46', 'Mur gauche côté fenêtre endommagé', 'a_faire', '2025-06-02', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (571, '34', 'flexible douche qui fuit', 'validee', '2025-06-01', 'Victoria', 'Miguel', '2025-09-18', null, true, null, null, 'Flexible de douche (stockB)', 1.0),
  (813, '58', 'flexible douche qui fuit', 'validee', '2025-06-01', 'Victoria', 'Miguel', '2025-08-05', null, true, null, null, null, null),
  (863, 'Lobby', 'Porte d''entrée qui grince', 'validee', '2025-06-01', 'Miguel', 'Miguel', '2025-05-30', null, true, null, 'Miguel', null, null),
  (389, '03', 'joint étanchéité pare douche', 'validee', '2025-05-30', null, 'Sarah P', '2025-05-30', null, true, null, 'Victoria', null, null),
  (578, '35', 'joint étanchéité pare douche', 'validee', '2025-05-30', 'Victoria', 'Sarah P', '2025-05-30', null, true, null, 'Victoria', null, null),
  (637, '42', 'joint étanchéité pare douche', 'validee', '2025-05-30', 'Victoria', 'Sarah P', '2025-05-30', null, true, null, 'Victoria', null, null),
  (862, 'Lobby', 'recoller les cornières dorées sur les deux pilliers', 'validee', '2025-05-30', 'Miguel', 'Sarah P', '2025-05-30', null, true, null, 'Victoria', null, null),
  (881, 'WC Clients', 'Robinet à changer + flexible', 'validee', '2025-05-30', 'Sarah P', 'Miguel', '2025-05-30', null, true, null, 'Victoria', null, null),
  (1132, 'Ascenseur', 'Ascenseur en panne - Il faut contacter KONE', 'validee', '2025-05-29', 'Sarah P', 'Miguel', '2025-05-29', null, true, '2025-05-29', 'Sarah P', null, null),
  (1134, 'Ascenseur', 'Ascenseur en panne - Il faut contacter KONE', 'validee', '2025-05-21', 'Sarah P', 'Miguel', '2025-05-23', null, true, '2025-05-23', 'Sarah P', null, null),
  (559, '32', 'flexible douche à changer', 'validee', '2025-05-20', 'Victoria', 'Miguel', '2025-05-30', null, true, null, 'Victoria', null, null),
  (636, '42', 'joint sillicone lavabo et douche', 'validee', '2025-05-20', 'Victoria', 'Miguel', '2025-05-30', null, true, null, 'Victoria', null, null),
  (694, '47', 'joint sillicone lavabo douche et WC', 'validee', '2025-05-20', 'Victoria', 'Miguel', '2025-05-30', null, true, null, 'Victoria', null, null),
  (708, '48', 'joint sillicone lavabo', 'validee', '2025-05-20', 'Victoria', 'Miguel', '2025-06-24', null, true, null, 'Victoria', null, null),
  (586, '35', 'Bouton pour le mitigeur douche à changer', 'a_faire', '2025-05-19', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (659, '45', 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', '2025-05-18', 'Miguel', 'Miguel', '2025-05-20', null, true, null, null, 'Économisseur d''énergie', 1.0),
  (522, '26', 'Refixer la prise', 'validee', '2025-05-16', 'Victoria', 'Miguel', '2025-08-05', null, true, null, null, null, null),
  (829, 'Chaufferie', 'inverser la VMC pour un meilleur fonctionnement', 'a_faire', '2025-05-05', 'Sarah P', 'Sarah P', null, null, false, null, null, null, null),
  (552, '31', 'Serrer le bras liseuse côté gauche', 'validee', '2025-04-29', 'Victoria', 'Miguel', '2025-04-29', null, true, null, 'Victoria', null, null),
  (532, '27', 'support de douche à viser', 'validee', '2025-04-24', 'Miguel', 'Miguel', '2025-04-25', 'Victoria', false, null, null, null, null),
  (598, '36', 'Lit côté droit cassé', 'validee', '2025-04-24', 'Victoria', 'Miguel', '2025-11-16', null, true, null, null, null, null),
  (544, '28', 'Refixer la liseuse de gauche', 'validee', '2025-04-23', 'Victoria', 'Miguel', '2025-11-16', null, true, null, null, 'Liseuses (Flexible + Source) - Brossier Saderne', 1.0),
  (546, '28', 'Télérupteur à changer - spot et leds', 'validee', '2025-04-22', 'Victoria', 'Miguel', '2025-04-23', null, true, null, null, null, null),
  (847, 'Local TGBT', 'Cache Rosace de la poignée (exterieure) de porte à changer', 'validee', '2025-04-17', 'Miguel', 'Miguel', '2025-12-23', null, true, null, 'Miguel', null, null),
  (482, '21', 'Fissure constaté au plafond', 'a_faire', '2025-04-15', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (758, '54', 'télérupteur lumière néons et spots plafond sautent', 'validee', '2025-04-15', 'Miguel', 'Victoria', '2025-04-18', null, true, null, null, 'Télérupteurs (Mécaniques) Paris Elec ou YesssElectrique', 1.0),
  (678, '46', 'remplacer l''économiseur d''énergie pour éclairage principal', 'validee', '2025-04-14', 'Sarah P', 'Sarah P', '2025-05-14', null, true, null, null, 'Économisseur d''énergie', 1.0),
  (477, '21', 'Télérupteur à changer appliques', 'validee', '2025-04-13', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (566, '34', 'joint sillicone dans le bac à douche', 'validee', '2025-04-10', 'Victoria', 'Miguel', '2025-04-29', null, true, null, 'Victoria', null, null),
  (603, '37', 'joint sillicone dans le bac à douche', 'validee', '2025-04-10', 'Victoria', 'Miguel', '2025-04-29', null, true, null, 'Victoria', null, null),
  (613, '38', 'Joint de pare douche à changer', 'validee', '2025-04-08', 'Victoria', 'Sarah P', '2025-04-08', null, true, null, 'Victoria', null, null),
  (646, '44', 'joint pare douche à remplacer', 'validee', '2025-04-08', 'Victoria', 'Sarah P', '2025-04-08', null, true, null, 'Victoria', null, null),
  (656, '45', 'Joint pare douche à changer', 'validee', '2025-04-08', 'Victoria', 'Sarah P', '2025-04-08', null, true, null, 'Victoria', null, null),
  (657, '45', 'remettre le joint noir porte coulissante SDB qui est decollé', 'validee', '2025-04-08', 'Victoria', 'Sarah P', '2025-04-08', null, true, null, 'Victoria', null, null),
  (673, '46', 'Joint pare douche à changer car laisse passer l''eau', 'validee', '2025-04-08', 'Victoria', 'Sarah P', '2025-04-08', null, true, null, 'Victoria', null, null),
  (749, '54', 'joint pare douche à remplacer', 'validee', '2025-04-08', 'Victoria', 'Sarah P', '2025-04-08', null, true, null, 'Victoria', null, null),
  (750, '54', 'Resserer liseuse côté droit', 'validee', '2025-04-08', 'Victoria', 'Sarah P', '2025-04-08', null, true, null, 'Victoria', null, null),
  (776, '56', 'Refixer correctement le miroir grossissant au mur SDB', 'validee', '2025-04-08', 'Victoria', 'Sarah P', '2025-04-08', null, true, null, 'Victoria', null, null),
  (821, '4eme étage', '4 eme spot plafond couloir du fond à changer', 'validee', '2025-04-08', 'Victoria', 'Sarah P', '2025-04-08', null, true, null, 'Victoria', null, null),
  (868, 'Réception', 'Resserer liseuse gauche', 'validee', '2025-04-08', 'Sarah P', 'Sarah P', '2025-04-08', null, true, null, 'Victoria', null, null),
  (872, 'Réception', 'Système carte pour lumière chambre cassé', 'validee', '2025-04-08', 'Sarah P', 'Sarah P', null, null, false, null, null, null, null),
  (373, '01', 'Flexible douche à changer', 'validee', '2025-04-07', 'Victoria', 'Miguel', '2025-05-30', null, true, null, 'Victoria', 'flexibles douche ( noirs )', 1.0),
  (592, '36', 'Refixer la liseuse de gauche', 'validee', '2025-04-07', 'Victoria', 'Miguel', '2025-04-29', null, true, null, 'Victoria', null, null),
  (612, '38', 'Refixer la liseuse de droite', 'validee', '2025-04-07', 'Victoria', 'Miguel', '2025-04-08', null, true, null, 'Victoria', null, null),
  (797, '57', 'Charnière de la porte du bas à changer', 'a_faire', '2025-04-07', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (424, '14', 'Joint pare douche', 'validee', '2025-04-01', 'Victoria', 'Victoria', '2025-09-26', null, true, null, 'Victoria', null, null),
  (443, '15', 'flexible douche à changer', 'validee', '2025-04-01', 'Victoria', 'Miguel', '2025-11-16', null, true, null, null, 'Flexible de douche (stockB)', 1.0),
  (699, '47', 'repeindre porte chambre côté extèrieur', 'a_faire', '2025-04-01', 'Victoria', 'Sarah P', '2026-05-11', null, true, '2026-05-14', 'Victoria', null, null),
  (748, '54', 'Joint pare douche', 'validee', '2025-04-01', 'Victoria', 'Sarah P', '2025-04-08', null, true, null, 'Victoria', null, null),
  (761, '54', 'Réparer fissure cadre fenêtre chambre avec pâte à bois et repeindre', 'a_faire', '2025-04-01', 'Victoria', 'Sarah P', null, null, false, null, null, null, null),
  (796, '57', 'reprendre peinture cause éclat mur dessous TV', 'a_faire', '2025-04-01', 'Victoria', 'Sarah P', null, null, false, null, null, null, null),
  (871, 'Réception', 'spot dans le lobby devant la cuisine', 'validee', '2025-04-01', 'Sarah P', 'Sarah P', '2025-05-21', null, true, null, null, null, null),
  (545, '28', 'Télérupteur à changer - appliques murales sautent', 'validee', '2025-03-25', 'Victoria', 'Miguel', '2025-05-21', null, true, null, null, null, null),
  (553, '31', 'télérupteur lumière néons et spots plafond sautent', 'validee', '2025-03-25', 'Victoria', 'Miguel', '2025-04-18', null, true, null, null, 'Télérupteurs (Mécaniques) Paris Elec ou YesssElectrique', 1.0),
  (740, '52', 'Télérupteur à changer lumière appliques murales saute', 'validee', '2025-03-25', 'Victoria', 'Miguel', '2025-05-21', null, true, null, null, null, null),
  (870, 'Réception', 'Spot côté gauche du bar à changer', 'validee', '2025-03-24', 'Sarah P', 'Sarah P', '2025-04-01', null, true, null, null, null, null),
  (978, '38', 'Lavabo qui coule', 'validee', '2025-03-23', 'Miguel', 'Miguel', '2026-04-23', null, true, '2026-04-27', 'Victoria', null, null),
  (849, 'Local TGBT', 'Réparation de la poignée de porte du TGBT', 'validee', '2025-03-20', 'MR NEGRONI', 'Sarah P', '2025-03-20', null, true, null, null, null, null),
  (757, '54', 'Evier qui coule', 'validee', '2025-03-12', 'Victoria', 'Miguel', '2025-08-05', null, true, null, null, null, null),
  (378, '01', 'changer connecteur lumiéres miroir SDB', 'validee', '2025-03-11', 'Victoria', 'Miguel', '2026-04-29', null, true, '2026-04-29', 'Victoria', null, null),
  (381, '02', 'Lit côté gauche cassé', 'validee', '2025-03-11', 'Victoria', 'Miguel', '2025-09-26', null, true, null, 'Victoria', null, null),
  (390, '03', 'Serrer le bras liseuse côté gauche', 'validee', '2025-03-11', 'Victoria', 'Miguel', '2025-04-08', null, true, null, 'Victoria', null, null),
  (436, '15', 'Joint pare douche', 'validee', '2025-03-11', 'Victoria', 'Miguel', null, null, false, null, 'Victoria', null, null),
  (655, '45', 'Lavabo qui coule', 'validee', '2025-03-11', 'Victoria', 'Miguel', null, null, false, null, 'Victoria', null, null),
  (818, 'Palier 1er', 'Spot à coté de l''ascenseur à changer', 'validee', '2025-03-11', 'Victoria', 'Miguel', '2025-04-01', null, true, null, null, null, null),
  (858, '3eme étage', 'Spot devant la chambre 34 à changer', 'validee', '2025-03-11', 'Victoria', 'Miguel', '2025-04-01', null, true, null, null, null, null),
  (690, '47', 'Mettre une vis pour l''aimant de la porte dorée armoire (bas)', 'validee', '2025-02-21', 'Victoria', 'Miguel', '2025-09-18', null, true, null, 'Victoria', null, null),
  (698, '47', 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)', 'validee', '2025-02-21', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (371, '01', 'Recoller la plinthe bois noire porte SDB côté SDB', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-09-18', null, true, null, 'Victoria', null, null),
  (374, '01', 'URGENT - Joints sillicone douche - lavabo  et WC à refaire complètement', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-05-30', null, true, null, 'Victoria', null, null),
  (377, '01', 'Difficulté à fermer la porte de chambre -', 'validee', '2025-02-18', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (382, '02', 'URGENT - Joints sillicone douche et lavabo à refaire complètement', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-05-30', null, true, null, 'Victoria', null, null),
  (388, '03', 'URGENT - Joints sillicone douche - lavabo & WC', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-05-30', null, true, null, 'Victoria', null, null),
  (401, '11', 'Remettre le joint porte coulissante de la salle de bains - côté chambre', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-06-24', null, true, null, 'Victoria', null, null),
  (402, '11', 'URGENT - Joints sillicone douche', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-06-24', null, true, null, 'Victoria', null, null),
  (408, '11', 'Bouton pour le mitigeur douche à acheter car il n''y en a plus', 'a_acheter', '2025-02-18', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (410, '11', 'Changer le miroir SDB car rouillé de l''interieur', 'a_acheter', '2025-02-18', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (414, '12', 'URGENT - Joints sillicone douche et lavabo à refaire complètement', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-06-24', null, true, null, 'Victoria', null, null),
  (422, '12', 'Bouton pour le mitigeur douche à acheter car il n''y en a plus', 'a_acheter', '2025-02-18', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (423, '14', 'URGENT - Joints sillicone douche - lavabo', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-09-26', null, true, null, 'Victoria', null, null),
  (431, '14', 'Remettre le joint porte coulissante de la salle de bains', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-09-18', null, true, '2026-02-05', 'Victoria', null, null),
  (441, '15', 'URGENT - Joints sillicone douche et lavabo à refaire complètement', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-04-01', null, true, null, null, null, null),
  (442, '15', 'Bouton pour le mitigeur douche à acheter car il n''y en a plus', 'a_acheter', '2025-02-18', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (449, '16', 'URGENT - Joints sillicone douche et lavabo à refaire complètement', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-08-05', null, true, null, 'Victoria', null, null),
  (450, '16', 'Mettre un joint pare douche à la bonne taille car pas assez long et l''eau passe', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-06-24', null, true, null, 'Victoria', null, null),
  (453, '16', 'Voir avec miroitier pour miroir placard cassé en bas (grand)', 'annulee', '2025-02-18', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (454, '16', 'Joint pour faire tenir le pommeau de douche', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-11-16', null, true, null, null, null, null),
  (460, '18', 'URGENT - Joints sillicone douche', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-06-24', null, true, null, 'Victoria', null, null),
  (467, '18', 'Spot plafond entrée HS', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2025-04-01', null, true, null, null, null, null),
  (468, '18', 'Joint pour faire tenir le pommeau de douche', 'a_acheter', '2025-02-18', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (608, '37', 'Lumière grand miroir SDB', 'validee', '2025-02-18', 'Victoria', 'Victoria', '2026-02-05', null, true, '2026-02-05', 'Victoria', null, null),
  (672, '46', 'Lampe bureau cassée - faire réparer comme M Negroni', 'validee', '2025-02-18', 'Victoria', 'Victoria', null, null, true, null, 'Victoria', null, null),
  (515, '25', 'Refixer la liseuse de gauche', 'validee', '2025-02-17', 'Victoria', 'Miguel', '2025-08-05', null, true, null, null, null, null),
  (600, '36', 'Manque porte placard du haut', 'a_faire', '2025-02-17', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (658, '45', 'Remplacement de la bonde lavabo', 'validee', '2025-02-17', 'FARID', 'Sarah P', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (662, '45', 'De l''eau coule à l''interier depuis la fenetre', 'a_faire', '2025-02-17', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (403, '11', 'Serrer le bras liseuse côté droit', 'validee', '2025-02-15', 'Victoria', 'Sarah P', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (404, '11', 'Spot dans la salle de bain', 'validee', '2025-02-15', 'Victoria', 'Miguel', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (806, '58', 'Serrer le bras liseuse côté droit', 'validee', '2025-02-15', 'Victoria', 'Miguel', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (718, '51', 'joint sillicone dans le bac à douche', 'validee', '2025-02-14', 'Victoria', 'Sarah P', '2025-06-24', null, true, null, 'Victoria', null, null),
  (741, '52', 'joint sillicone dans le bac à douche', 'validee', '2025-02-14', 'Victoria', 'Sarah P', '2025-11-16', null, true, null, null, null, null),
  (756, '54', 'joint sillicone dans le bac à douche et lavabo', 'validee', '2025-02-14', 'Victoria', 'Sarah P', '2025-04-01', null, true, null, null, null, null),
  (765, '55', 'joint sillicone dans le bac à douche', 'validee', '2025-02-14', 'Victoria', 'Sarah P', null, null, true, null, 'Victoria', null, null),
  (785, '56', 'joint sillicone dans le bac à douche', 'validee', '2025-02-14', 'Victoria', 'Sarah P', '2026-06-15', null, true, '2026-06-15', 'Victoria', null, null),
  (790, '57', 'joint sillicone dans le bac à douche', 'validee', '2025-02-14', 'Victoria', 'Sarah P', '2025-05-30', null, true, null, 'Victoria', null, null),
  (804, '58', 'joint sillicone dans le bac à douche', 'validee', '2025-02-14', 'Victoria', 'Sarah P', '2025-05-30', null, true, null, 'Victoria', null, null),
  (837, 'Palier 1er', 'La moquette de la premiere marche en partant du haut est decollée', 'a_faire', '2025-02-13', 'Miguel', 'Miguel', null, null, false, null, null, null, null),
  (498, '24', 'Changement des rideaux', 'validee', '2025-02-12', 'Sarah P', 'Miguel', '2025-03-14', 'Victoria', false, null, null, 'Silva - Rideaux', 2.0),
  (568, '34', 'Changement des rideaux - salle de bain', 'validee', '2025-02-12', 'Sarah P', 'Miguel', '2025-03-14', 'Victoria', false, null, null, 'Silva - Rideaux', 2.0),
  (677, '46', 'Changement des rideaux', 'validee', '2025-02-12', 'Sarah P', 'Miguel', '2025-03-14', 'Victoria', false, null, null, 'Silva - Rideaux', 2.0),
  (720, '51', 'Changement des rideaux', 'validee', '2025-02-12', 'Sarah P', 'Miguel', '2025-03-14', 'Victoria', false, null, null, 'Silva - Rideaux', 2.0),
  (734, '52', 'Changement des rideaux', 'validee', '2025-02-12', 'Sarah P', 'Miguel', '2025-03-14', 'Victoria', false, null, null, 'Silva - Rideaux', 2.0),
  (754, '54', 'Changement des rideaux', 'validee', '2025-02-12', 'Sarah P', 'Miguel', '2025-03-14', 'Victoria', false, null, null, 'Silva - Rideaux', 2.0),
  (755, '54', 'Changement des rideaux - salle de bain', 'validee', '2025-02-12', 'Sarah P', 'Miguel', '2025-03-14', 'Victoria', false, null, null, 'Silva - Rideaux', 2.0),
  (767, '55', 'Changement des rideaux', 'validee', '2025-02-12', 'Sarah P', 'Miguel', '2025-03-14', 'Victoria', false, null, null, 'Silva - Rideaux', 2.0),
  (779, '56', 'Changement des rideaux', 'validee', '2025-02-12', 'Sarah P', 'Miguel', '2025-03-14', 'Victoria', false, null, null, 'Silva - Rideaux', 2.0),
  (793, '57', 'Changement des rideaux', 'validee', '2025-02-12', 'Sarah P', 'Miguel', '2025-03-14', 'Victoria', false, null, null, 'Silva - Rideaux', 2.0),
  (807, '58', 'Changement des rideaux', 'validee', '2025-02-12', 'Sarah P', 'Miguel', '2025-03-14', 'Victoria', false, null, null, 'Silva - Rideaux', 2.0),
  (808, '58', 'Changement des rideaux - salle de bain', 'validee', '2025-02-12', 'Sarah P', 'Miguel', '2025-03-14', 'Victoria', false, null, null, 'Silva - Rideaux', 2.0),
  (416, '12', 'Refixer la liseuse de droite', 'validee', '2025-02-09', 'Victoria', 'Miguel', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (429, '14', 'Refixer la liseuse de gauche', 'validee', '2025-02-09', 'Victoria', 'Miguel', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (434, '15', 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)', 'validee', '2025-02-09', 'Victoria', 'Miguel', '2025-09-18', null, true, null, 'Victoria', null, null),
  (585, '35', 'Il manque la porte du placard du bas', 'a_faire', '2025-02-09', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (461, '18', 'lampe bureau à réparer', 'validee', '2025-02-07', 'Sarah P', 'Sarah P', '2025-02-06', null, true, null, null, null, null),
  (537, '28', 'lampe bureau à réparer', 'validee', '2025-02-07', 'Sarah P', 'Sarah P', '2025-02-06', null, true, null, null, null, null),
  (638, '42', 'lampe bureau à réparer', 'validee', '2025-02-07', 'Sarah P', 'Sarah P', '2025-02-06', null, true, null, null, null, null),
  (719, '51', 'Manque porte placard ( grande) / visser aimant', 'validee', '2025-02-07', 'Victoria', 'Sarah P', '2025-02-07', 'FARID', false, null, 'Victoria', null, null),
  (742, '52', 'Manque porte placard ( grande) / visser aimant', 'validee', '2025-02-07', 'Victoria', 'Sarah P', '2026-04-23', null, true, '2026-05-14', 'Victoria', null, null),
  (752, '54', 'lampe bureau à réparer', 'validee', '2025-02-07', 'Sarah P', 'Sarah P', '2025-02-06', null, true, null, null, null, null),
  (771, '55', 'lampe bureau à réparer', 'validee', '2025-02-07', 'Sarah P', 'Sarah P', null, null, false, null, null, null, null),
  (777, '56', 'lampe bureau à réparer', 'validee', '2025-02-07', 'Sarah P', 'Sarah P', '2025-02-06', null, true, null, null, null, null),
  (791, '57', 'Prise arrachée du mur SDB', 'validee', '2025-02-07', 'Victoria', 'Sarah P', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (846, 'Local Technique', 'Installer un interupteur', 'validee', '2025-02-06', 'MR NEGRONI', 'Miguel', null, null, false, null, null, null, null),
  (851, 'Réception', 'faire un trou et ensuite avec un fil de fer tirer les fils pour installer la prise pour le nouveau cadre', 'validee', '2025-02-06', 'MR NEGRONI', 'Miguel', null, null, false, null, null, null, null),
  (557, '31', 'flexible liseuse côté gauche à changer', 'validee', '2025-02-05', 'Victoria', 'Miguel', '2025-04-08', null, true, null, 'Victoria', null, null),
  (654, '45', 'flexible liseuse côté gauche à changer', 'validee', '2025-02-05', 'Victoria', 'Miguel', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (671, '46', 'Support gel douche à changer', 'validee', '2025-02-05', 'Victoria', 'Miguel', '2025-04-08', null, true, null, 'Victoria', null, null),
  (707, '48', 'Joint porte sdb', 'validee', '2025-02-05', 'Victoria', 'Miguel', '2025-06-24', null, true, null, 'Victoria', null, null),
  (739, '52', 'Lavabo qui coule', 'validee', '2025-02-05', 'Sarah P', 'Miguel', '2025-08-05', null, true, null, null, null, null),
  (564, '32', 'Miroir plateau à changé', 'validee', '2025-02-04', 'Victoria', 'Miguel', '2026-02-05', null, true, '2026-02-05', 'Victoria', null, null),
  (583, '35', 'flexible liseuse côté droit à resserer', 'validee', '2025-02-04', 'Victoria', 'Miguel', '2025-04-08', null, true, null, 'Victoria', null, null),
  (594, '36', 'Refixer la liseuse de gauche', 'validee', '2025-02-04', 'Victoria', 'Miguel', '2025-02-07', 'FARID', false, null, 'Victoria', null, null),
  (614, '38', 'flexible liseuse côté gauche à changer', 'validee', '2025-02-04', 'Victoria', 'Miguel', '2025-04-08', null, true, null, 'Victoria', 'Liseuses (Flexible + Source) - Brossier Saderne', 1.0),
  (620, '38', 'Miroir plateau à changé', 'validee', '2025-02-04', 'Victoria', 'Miguel', '2026-05-11', null, true, '2026-05-14', 'Victoria', null, null),
  (812, '58', 'Miroir plateau à changé', 'validee', '2025-02-04', 'Victoria', 'Miguel', '2026-02-05', null, true, '2026-02-05', 'Victoria', null, null),
  (873, 'Salle de repos', 'Neon salle de repos à changer', 'validee', '2025-02-01', 'Victoria', 'Miguel', '2025-03-20', null, true, null, null, null, null),
  (983, '03', 'Changement des rideaux', 'validee', '2025-01-29', 'Sarah P', 'Miguel', '2026-03-31', 'Victoria', false, null, null, 'Silva - Rideaux', 1.0),
  (457, '18', 'URGENT! PRIORITE Coffre à reprogrammer', 'validee', '2025-01-28', 'Miguel', 'Miguel', '2025-11-03', null, true, null, 'Miguel', 'Coffre-Fort (EUROPROH)', 1.0),
  (415, '12', 'Spot plafond niveau armoire à changer', 'validee', '2025-01-27', 'Sarah P', 'Miguel', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (428, '14', 'Mettre une vis pour l''aimant de la porte dorée armoire (bas)', 'validee', '2025-01-27', 'Sarah P', 'Miguel', '2025-09-18', null, true, null, 'Victoria', null, null),
  (627, '41', 'flexible liseuse côté SDB à changer', 'validee', '2025-01-27', 'Sarah P', 'Sarah P', '2025-01-30', 'FARID', false, null, null, 'Liseuses (Flexible + Source) - Brossier Saderne', 1.0),
  (650, '44', 'Barrre de douche à refixer', 'validee', '2025-01-27', 'Victoria', 'Miguel', '2025-01-30', 'FARID', false, null, null, null, null),
  (814, '58', 'plafond douche SDB cloqué - voir avec Kamel', 'a_faire', '2025-01-27', 'Sarah P', 'Sarah P', null, null, false, null, null, null, null),
  (878, 'Sous-sol divers', 'réparation enduit mur blanc niveau lingerie + peinture Farid + baguettes plastiques larges et resistantes car les livreurs abîment les angles avec leurs charriots', 'validee', '2025-01-27', 'Sarah P', 'Sarah P', '2025-03-20', null, true, null, null, null, null),
  (584, '35', 'Mettre feutrine découpée sur mesure au dos de la table de chevet pour protéger le mur', 'a_faire', '2025-01-24', 'Sarah P', 'Sarah P', null, null, false, null, null, null, null),
  (392, '03', 'mettre des cornieres noires à l''entrée de la chambe', 'a_faire', '2025-01-23', 'Sarah P', 'Sarah P', null, null, false, null, null, null, null),
  (842, 'Parties communes', 'Voilages dechirés', 'validee', '2025-01-23', 'Sarah P', 'Sarah P', null, 'Victoria', false, null, 'Victoria', null, null),
  (411, '11', 'changement du flexible de la liseuse de droite', 'validee', '2025-01-21', 'Sarah P', 'Sarah P', '2025-01-21', 'FARID', false, null, null, 'Liseuses (Flexible + Source) - Brossier Saderne', 1.0),
  (490, '22', 'Refixer le miroir grossissant', 'validee', '2025-01-21', 'Sarah P', 'Miguel', '2025-02-17', 'FARID', false, null, null, null, null),
  (491, '22', 'problème de joint sur la paroi de douche car l''eau coule à travers -', 'validee', '2025-01-21', 'Sarah P', 'Sarah P', '2024-01-24', null, true, null, null, null, null),
  (521, '26', 'Mettre une vis pour l''aimant de la porte dorée armoire (bas)', 'validee', '2025-01-21', 'Sarah P', 'Sarah P', '2025-01-21', 'FARID', false, null, null, null, null),
  (523, '26', 'flexible liseuse côté droit à changer', 'validee', '2025-01-21', 'Victoria', 'Miguel', '2025-04-08', null, true, null, 'Victoria', 'Liseuses (Flexible + Source) - Brossier Saderne', 1.0),
  (524, '26', 'flexible liseuse côté gauche à resserer', 'validee', '2025-01-21', 'Sarah P', 'Sarah P', '2025-01-21', 'FARID', false, null, 'Victoria', 'Liseuses (Flexible + Source) - Brossier Saderne', 1.0),
  (530, '27', 'Refixer la liseuse de droite', 'validee', '2025-01-21', 'Sarah P', 'Sarah P', null, null, false, null, null, null, null),
  (531, '27', 'Plainte rose coté lit SDB à recoller', 'validee', '2025-01-21', 'Sarah P', 'Miguel', '2025-08-05', null, true, null, null, null, null),
  (538, '28', 'La porte principale ne se fermait pas bien', 'validee', '2025-01-21', 'Miguel', 'Miguel', '2025-01-21', 'FARID', false, null, 'Miguel', null, null),
  (582, '35', 'Mettre une vis pour l''aimant de la porte dorée armoire (haut)', 'validee', '2025-01-21', 'Sarah P', 'Miguel', null, null, false, null, null, null, null),
  (607, '37', 'Plinthe bois chambre (Mur a gauche du lit) à recoller', 'validee', '2025-01-21', 'Sarah P', 'Miguel', '2025-09-18', null, true, null, null, null, null),
  (684, '46', 'Fuite syphon Lavabo SDB', 'validee', '2025-01-21', 'Victoria', 'Miguel', '2025-01-21', 'FARID', false, null, null, null, null),
  (732, '52', 'Refixer la liseuse de gauche', 'validee', '2025-01-21', 'Sarah P', 'Sarah P', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (737, '52', 'Mettre une vise sur la Porte dorée armoire (haut)', 'validee', '2025-01-21', 'Sarah P', 'Miguel', '2025-01-21', 'FARID', false, null, null, null, null),
  (738, '52', 'Refixer le miroir grossissant', 'validee', '2025-01-21', 'Sarah P', 'Miguel', '2025-08-05', null, true, null, null, null, null),
  (751, '54', 'Refixer le miroir grossissant', 'validee', '2025-01-21', 'Sarah P', 'Miguel', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (770, '55', 'Baguette d''angle noir a recollé - mur entree chambre', 'validee', '2025-01-21', 'Sarah P', 'Miguel', '2025-01-21', 'FARID', false, null, null, null, null),
  (778, '56', 'Fuite syphon Lavabo SDB', 'validee', '2025-01-21', 'Victoria', 'Miguel', '2025-01-21', 'FARID', false, null, 'Victoria', null, null),
  (865, 'Ascenseur', 'coller deux baguettes d''angle noires dans l''encadrement porte DAES', 'validee', '2025-01-21', 'Sarah P', 'Sarah P', '2025-01-21', 'FARID', false, null, null, null, null),
  (877, 'Sous-sol divers', 'Mettre le tableau  pour l''affichage obligatoire', 'validee', '2025-01-21', 'Sarah P', 'Miguel', '2025-01-21', 'FARID', false, null, null, null, null),
  (817, 'Palier 1er', 'Spot du couloir a changer à coté de la chambre 18', 'validee', '2025-01-16', 'Victoria', 'Miguel', '2025-01-30', 'FARID', false, null, null, null, null),
  (440, '15', 'Porte du frigo à fixer', 'validee', '2025-01-11', 'Victoria', 'Miguel', '2025-08-05', null, true, null, null, null, null),
  (649, '44', 'Lavabo bouché', 'validee', '2025-01-11', 'Victoria', 'Miguel', '2025-01-16', 'Victoria', false, null, null, null, null),
  (723, '51', 'Bouton on/off pour regler la temperature non fonctionnel', 'validee', '2025-01-11', 'Victoria', 'Miguel', null, null, false, null, null, null, null),
  (805, '58', 'La lumiere du miroir ne s''allume pas', 'validee', '2025-01-11', 'Victoria', 'Miguel', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (417, '12', 'joint porte sdb', 'validee', '2025-01-09', 'Victoria', 'Victoria', '2025-01-11', 'FARID', false, null, 'Victoria', null, null),
  (497, '24', 'change bonde lavabo', 'validee', '2025-01-09', 'Victoria', 'Victoria', '2025-02-17', 'FARID', false, null, 'Victoria', 'Télérupteur électrique (YesssElectrique)', 1.0),
  (511, '25', 'deboucher l''evier', 'validee', '2025-01-09', 'Victoria', 'Victoria', '2025-01-11', 'FARID', false, null, 'Victoria', null, null),
  (529, '27', 'deboucher l''evier', 'validee', '2025-01-09', 'Victoria', 'Victoria', null, null, false, null, null, null, null),
  (560, '32', 'Télérupteur spot et led à changer', 'validee', '2025-01-09', 'Victoria', 'Victoria', '2025-01-22', null, true, null, 'Victoria', 'Télérupteurs (Mécaniques) Paris Elec ou YesssElectrique', 1.0),
  (731, '52', 'changer la bonde du lavabo', 'validee', '2025-01-09', 'Victoria', 'Victoria', '2025-02-17', 'FARID', false, null, 'Victoria', null, null),
  (783, '56', 'deboucher l''evier', 'validee', '2025-01-09', 'Victoria', 'Victoria', '2025-01-16', 'Victoria', false, null, null, null, null),
  (387, '03', 'Applique coté entrée à refixer correctement', 'validee', '2025-01-05', 'Miguel', 'Miguel', '2025-09-18', null, true, null, 'Victoria', null, null),
  (822, '4eme étage', 'Spot à coté de l''ascenseur à changer', 'validee', '2025-01-05', 'Miguel', 'Miguel', '2025-04-01', null, true, null, null, null, null);

-- Le nom d'un intervenant extérieur, à part : il n'est pas utilisateur.
alter table reprise add column prestataire text;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 1239;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 1229;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1216;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1217;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1218;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1219;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1205;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1206;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1207;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1208;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1210;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1211;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1212;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1213;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1202;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1203;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1192;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1193;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1194;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1195;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1196;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1197;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1198;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1199;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1200;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1201;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1185;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1186;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1187;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1188;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1136;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1138;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1139;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1140;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1141;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1142;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1143;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1182;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1183;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1093;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1102;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1110;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1112;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1114;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1126;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1087;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1088;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1089;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1090;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1091;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1092;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1094;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1095;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1096;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1097;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1098;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1099;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1100;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1101;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1103;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1104;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1105;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1106;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1107;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1108;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1109;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1111;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1113;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1115;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1116;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1117;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1118;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1119;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1120;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1121;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1122;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1123;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1124;
update reprise set prestataire = 'Technicien AVIR' where sharepoint_id = 1130;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1080;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1047;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1048;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1049;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1054;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1055;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1056;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1059;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1060;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1061;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1062;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1043;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1044;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1045;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1042;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1040;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1038;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1037;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 1034;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1029;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1030;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1031;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1019;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 1018;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 1008;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 1003;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 1004;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1006;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1007;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1001;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1002;
update reprise set prestataire = 'Serafino' where sharepoint_id = 1000;
update reprise set prestataire = 'Serafino' where sharepoint_id = 985;
update reprise set prestataire = 'Serafino' where sharepoint_id = 986;
update reprise set prestataire = 'Serafino' where sharepoint_id = 988;
update reprise set prestataire = 'Serafino' where sharepoint_id = 989;
update reprise set prestataire = 'Serafino' where sharepoint_id = 990;
update reprise set prestataire = 'Serafino' where sharepoint_id = 991;
update reprise set prestataire = 'Serafino' where sharepoint_id = 992;
update reprise set prestataire = 'Serafino' where sharepoint_id = 993;
update reprise set prestataire = 'Serafino' where sharepoint_id = 994;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 996;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 984;
update reprise set prestataire = 'Serafino' where sharepoint_id = 979;
update reprise set prestataire = 'Serafino' where sharepoint_id = 981;
update reprise set prestataire = 'Serafino' where sharepoint_id = 982;
update reprise set prestataire = 'Serafino' where sharepoint_id = 980;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 975;
update reprise set prestataire = 'Serafino' where sharepoint_id = 976;
update reprise set prestataire = 'Serafino' where sharepoint_id = 974;
update reprise set prestataire = 'Technicien Kone' where sharepoint_id = 1127;
update reprise set prestataire = 'Serafino' where sharepoint_id = 949;
update reprise set prestataire = 'Serafino' where sharepoint_id = 950;
update reprise set prestataire = 'Serafino' where sharepoint_id = 946;
update reprise set prestataire = 'Serafino' where sharepoint_id = 947;
update reprise set prestataire = 'Serafino' where sharepoint_id = 948;
update reprise set prestataire = 'MR NEGRONI' where sharepoint_id = 901;
update reprise set prestataire = 'Serafino' where sharepoint_id = 977;
update reprise set prestataire = 'Serafino' where sharepoint_id = 893;
update reprise set prestataire = 'Serafino' where sharepoint_id = 895;
update reprise set prestataire = 'Serafino' where sharepoint_id = 896;
update reprise set prestataire = 'Serafino' where sharepoint_id = 898;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 803;
update reprise set prestataire = 'Serafino' where sharepoint_id = 483;
update reprise set prestataire = 'Serafino' where sharepoint_id = 492;
update reprise set prestataire = 'Serafino' where sharepoint_id = 504;
update reprise set prestataire = 'Serafino' where sharepoint_id = 505;
update reprise set prestataire = 'Serafino' where sharepoint_id = 516;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 517;
update reprise set prestataire = 'Serafino' where sharepoint_id = 609;
update reprise set prestataire = 'Serafino' where sharepoint_id = 643;
update reprise set prestataire = 'Serafino' where sharepoint_id = 666;
update reprise set prestataire = 'Serafino' where sharepoint_id = 701;
update reprise set prestataire = 'Serafino' where sharepoint_id = 703;
update reprise set prestataire = 'Serafino' where sharepoint_id = 704;
update reprise set prestataire = 'Serafino' where sharepoint_id = 725;
update reprise set prestataire = 'Serafino' where sharepoint_id = 726;
update reprise set prestataire = 'Serafino' where sharepoint_id = 762;
update reprise set prestataire = 'Serafino' where sharepoint_id = 772;
update reprise set prestataire = 'Serafino' where sharepoint_id = 787;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 789;
update reprise set prestataire = 'Serafino' where sharepoint_id = 798;
update reprise set prestataire = 'Serafino' where sharepoint_id = 799;
update reprise set prestataire = 'Serafino' where sharepoint_id = 815;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 775;
update reprise set prestataire = 'Serafino' where sharepoint_id = 845;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 764;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 746;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 727;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 717;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 706;
update reprise set prestataire = 'Serafino' where sharepoint_id = 470;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 692;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 668;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 652;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 644;
update reprise set prestataire = 'Serafino' where sharepoint_id = 623;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 633;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 625;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 611;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 602;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 590;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 575;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 565;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 558;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 551;
update reprise set prestataire = 'MR NEGRONI' where sharepoint_id = 844;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 535;
update reprise set prestataire = 'Serafino' where sharepoint_id = 882;
update reprise set prestataire = 'Serafino' where sharepoint_id = 398;
update reprise set prestataire = 'Serafino' where sharepoint_id = 456;
update reprise set prestataire = 'Serafino' where sharepoint_id = 471;
update reprise set prestataire = 'Serafino' where sharepoint_id = 472;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 525;
update reprise set prestataire = 'Serafino' where sharepoint_id = 589;
update reprise set prestataire = 'Serafino' where sharepoint_id = 595;
update reprise set prestataire = 'Serafino' where sharepoint_id = 667;
update reprise set prestataire = 'Serafino' where sharepoint_id = 801;
update reprise set prestataire = 'Serafino' where sharepoint_id = 802;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 518;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 509;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 495;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 485;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 474;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 458;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 446;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 435;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 427;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 413;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 400;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 386;
update reprise set prestataire = 'Technicien Kone' where sharepoint_id = 1128;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 380;
update reprise set prestataire = 'Serafino' where sharepoint_id = 876;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 370;
update reprise set prestataire = 'Serafino' where sharepoint_id = 379;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 412;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 484;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 507;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 508;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 691;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 773;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 774;
update reprise set prestataire = 'Serafino' where sharepoint_id = 788;
update reprise set prestataire = 'Serafino' where sharepoint_id = 459;
update reprise set prestataire = 'Serafino' where sharepoint_id = 716;
update reprise set prestataire = 'Serafino' where sharepoint_id = 744;
update reprise set prestataire = 'Hedi' where sharepoint_id = 396;
update reprise set prestataire = 'Hedi' where sharepoint_id = 469;
update reprise set prestataire = 'Serafino' where sharepoint_id = 399;
update reprise set prestataire = 'Serafino' where sharepoint_id = 447;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 473;
update reprise set prestataire = 'Serafino' where sharepoint_id = 493;
update reprise set prestataire = 'Serafino' where sharepoint_id = 494;
update reprise set prestataire = 'Serafino' where sharepoint_id = 534;
update reprise set prestataire = 'Serafino' where sharepoint_id = 574;
update reprise set prestataire = 'Serafino' where sharepoint_id = 610;
update reprise set prestataire = 'Serafino' where sharepoint_id = 626;
update reprise set prestataire = 'Serafino' where sharepoint_id = 634;
update reprise set prestataire = 'Serafino' where sharepoint_id = 642;
update reprise set prestataire = 'Serafino' where sharepoint_id = 700;
update reprise set prestataire = 'Serafino' where sharepoint_id = 705;
update reprise set prestataire = 'Serafino' where sharepoint_id = 743;
update reprise set prestataire = 'Serafino' where sharepoint_id = 745;
update reprise set prestataire = 'Serafino' where sharepoint_id = 763;
update reprise set prestataire = 'Serafino' where sharepoint_id = 800;
update reprise set prestataire = 'Serafino' where sharepoint_id = 820;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 455;
update reprise set prestataire = 'Hedi' where sharepoint_id = 819;
update reprise set prestataire = 'Hedi' where sharepoint_id = 615;
update reprise set prestataire = 'Hedi' where sharepoint_id = 616;
update reprise set prestataire = 'Hedi' where sharepoint_id = 710;
update reprise set prestataire = 'Hedi' where sharepoint_id = 728;
update reprise set prestataire = 'Technicien TELEC' where sharepoint_id = 824;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 784;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 376;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 384;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 394;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 407;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 420;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 433;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 444;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 452;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 465;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 480;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 488;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 500;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 514;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 520;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 527;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 542;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 556;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 563;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 570;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 581;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 597;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 605;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 618;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 631;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 640;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 648;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 661;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 681;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 697;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 713;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 722;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 736;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 760;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 769;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 782;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 795;
update reprise set prestataire = 'EcoFlair' where sharepoint_id = 811;
update reprise set prestataire = 'Technicien EUROPROH' where sharepoint_id = 510;
update reprise set prestataire = 'Hedi' where sharepoint_id = 385;
update reprise set prestataire = 'Hedi' where sharepoint_id = 503;
update reprise set prestataire = 'Hedi' where sharepoint_id = 550;
update reprise set prestataire = 'Hedi' where sharepoint_id = 843;
update reprise set prestataire = 'Serafino' where sharepoint_id = 686;
update reprise set prestataire = 'Technicien TELEC' where sharepoint_id = 823;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 676;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 463;
update reprise set prestataire = 'Hedi' where sharepoint_id = 536;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 547;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 621;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 685;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 869;
update reprise set prestataire = 'Technicien Kone' where sharepoint_id = 1129;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 478;
update reprise set prestataire = 'Hedi' where sharepoint_id = 591;
update reprise set prestataire = 'Hedi' where sharepoint_id = 669;
update reprise set prestataire = 'Hedi' where sharepoint_id = 730;
update reprise set prestataire = 'Hedi' where sharepoint_id = 747;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 834;
update reprise set prestataire = 'Hedi' where sharepoint_id = 426;
update reprise set prestataire = 'Hedi' where sharepoint_id = 448;
update reprise set prestataire = 'Hedi' where sharepoint_id = 475;
update reprise set prestataire = 'Technicien TELEC' where sharepoint_id = 840;
update reprise set prestataire = 'Technicien TELEC' where sharepoint_id = 848;
update reprise set prestataire = 'Technicien Kone' where sharepoint_id = 1131;
update reprise set prestataire = 'Hedi' where sharepoint_id = 421;
update reprise set prestataire = 'Hedi' where sharepoint_id = 425;
update reprise set prestataire = 'Hedi' where sharepoint_id = 709;
update reprise set prestataire = 'Hedi' where sharepoint_id = 875;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 733;
update reprise set prestataire = 'Technicien TELEC' where sharepoint_id = 839;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 852;
update reprise set prestataire = 'Hedi' where sharepoint_id = 496;
update reprise set prestataire = 'Hedi' where sharepoint_id = 502;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 835;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 866;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 867;
update reprise set prestataire = 'Hedi' where sharepoint_id = 409;
update reprise set prestataire = 'Hedi' where sharepoint_id = 572;
update reprise set prestataire = 'Hedi' where sharepoint_id = 601;
update reprise set prestataire = 'Serafino' where sharepoint_id = 395;
update reprise set prestataire = 'Hedi' where sharepoint_id = 860;
update reprise set prestataire = 'Hedi' where sharepoint_id = 372;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 486;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 809;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 855;
update reprise set prestataire = 'Hedi' where sharepoint_id = 635;
update reprise set prestataire = 'Hedi' where sharepoint_id = 653;
update reprise set prestataire = 'Hedi' where sharepoint_id = 670;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 827;
update reprise set prestataire = 'Hedi' where sharepoint_id = 577;
update reprise set prestataire = 'Hedi' where sharepoint_id = 645;
update reprise set prestataire = 'Hedi' where sharepoint_id = 833;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 828;
update reprise set prestataire = 'Hedi' where sharepoint_id = 854;
update reprise set prestataire = 'Hedi' where sharepoint_id = 624;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 599;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 579;
update reprise set prestataire = 'Hedi' where sharepoint_id = 571;
update reprise set prestataire = 'Hedi' where sharepoint_id = 813;
update reprise set prestataire = 'Hedi' where sharepoint_id = 863;
update reprise set prestataire = 'Hedi' where sharepoint_id = 389;
update reprise set prestataire = 'Hedi' where sharepoint_id = 578;
update reprise set prestataire = 'Hedi' where sharepoint_id = 637;
update reprise set prestataire = 'Hedi' where sharepoint_id = 862;
update reprise set prestataire = 'Hedi' where sharepoint_id = 881;
update reprise set prestataire = 'Technicien Kone' where sharepoint_id = 1132;
update reprise set prestataire = 'Technicien Kone' where sharepoint_id = 1134;
update reprise set prestataire = 'Hedi' where sharepoint_id = 559;
update reprise set prestataire = 'Hedi' where sharepoint_id = 636;
update reprise set prestataire = 'Hedi' where sharepoint_id = 694;
update reprise set prestataire = 'Hedi' where sharepoint_id = 708;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 659;
update reprise set prestataire = 'Hedi' where sharepoint_id = 522;
update reprise set prestataire = 'Juan' where sharepoint_id = 552;
update reprise set prestataire = 'Hedi' where sharepoint_id = 598;
update reprise set prestataire = 'Hedi' where sharepoint_id = 544;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 546;
update reprise set prestataire = 'Serafino' where sharepoint_id = 847;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 758;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 678;
update reprise set prestataire = 'Juan' where sharepoint_id = 566;
update reprise set prestataire = 'Juan' where sharepoint_id = 603;
update reprise set prestataire = 'Juan' where sharepoint_id = 613;
update reprise set prestataire = 'Juan' where sharepoint_id = 646;
update reprise set prestataire = 'Juan' where sharepoint_id = 656;
update reprise set prestataire = 'Juan' where sharepoint_id = 657;
update reprise set prestataire = 'Juan' where sharepoint_id = 673;
update reprise set prestataire = 'Juan' where sharepoint_id = 749;
update reprise set prestataire = 'Juan' where sharepoint_id = 750;
update reprise set prestataire = 'Juan' where sharepoint_id = 776;
update reprise set prestataire = 'Juan' where sharepoint_id = 821;
update reprise set prestataire = 'Juan' where sharepoint_id = 868;
update reprise set prestataire = 'Hedi' where sharepoint_id = 373;
update reprise set prestataire = 'Juan' where sharepoint_id = 592;
update reprise set prestataire = 'Juan' where sharepoint_id = 612;
update reprise set prestataire = 'Hedi' where sharepoint_id = 424;
update reprise set prestataire = 'Hedi' where sharepoint_id = 443;
update reprise set prestataire = 'Serafino' where sharepoint_id = 699;
update reprise set prestataire = 'Juan' where sharepoint_id = 748;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 871;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 545;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 553;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 740;
update reprise set prestataire = 'Juan' where sharepoint_id = 870;
update reprise set prestataire = 'Serafino' where sharepoint_id = 978;
update reprise set prestataire = 'MR NEGRONI' where sharepoint_id = 849;
update reprise set prestataire = 'Hedi' where sharepoint_id = 757;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 378;
update reprise set prestataire = 'Hedi' where sharepoint_id = 381;
update reprise set prestataire = 'Juan' where sharepoint_id = 390;
update reprise set prestataire = 'Juan' where sharepoint_id = 818;
update reprise set prestataire = 'Juan' where sharepoint_id = 858;
update reprise set prestataire = 'Hedi' where sharepoint_id = 690;
update reprise set prestataire = 'Hedi' where sharepoint_id = 371;
update reprise set prestataire = 'Hedi' where sharepoint_id = 374;
update reprise set prestataire = 'Hedi' where sharepoint_id = 382;
update reprise set prestataire = 'Hedi' where sharepoint_id = 388;
update reprise set prestataire = 'Hedi' where sharepoint_id = 401;
update reprise set prestataire = 'Hedi' where sharepoint_id = 402;
update reprise set prestataire = 'Hedi' where sharepoint_id = 414;
update reprise set prestataire = 'Hedi' where sharepoint_id = 423;
update reprise set prestataire = 'Hedi' where sharepoint_id = 431;
update reprise set prestataire = 'Juan' where sharepoint_id = 441;
update reprise set prestataire = 'Hedi' where sharepoint_id = 449;
update reprise set prestataire = 'Hedi' where sharepoint_id = 450;
update reprise set prestataire = 'Hedi' where sharepoint_id = 454;
update reprise set prestataire = 'Hedi' where sharepoint_id = 460;
update reprise set prestataire = 'Juan' where sharepoint_id = 467;
update reprise set prestataire = 'Serafino' where sharepoint_id = 608;
update reprise set prestataire = 'MR NEGRONI' where sharepoint_id = 672;
update reprise set prestataire = 'Hedi' where sharepoint_id = 515;
update reprise set prestataire = 'Hedi' where sharepoint_id = 718;
update reprise set prestataire = 'Hedi' where sharepoint_id = 741;
update reprise set prestataire = 'Juan' where sharepoint_id = 756;
update reprise set prestataire = 'Hedi' where sharepoint_id = 765;
update reprise set prestataire = 'Serafino' where sharepoint_id = 785;
update reprise set prestataire = 'Hedi' where sharepoint_id = 790;
update reprise set prestataire = 'Hedi' where sharepoint_id = 804;
update reprise set prestataire = 'Hedi' where sharepoint_id = 434;
update reprise set prestataire = 'MR NEGRONI' where sharepoint_id = 461;
update reprise set prestataire = 'MR NEGRONI' where sharepoint_id = 537;
update reprise set prestataire = 'MR NEGRONI' where sharepoint_id = 638;
update reprise set prestataire = 'Serafino' where sharepoint_id = 742;
update reprise set prestataire = 'MR NEGRONI' where sharepoint_id = 752;
update reprise set prestataire = 'MR NEGRONI' where sharepoint_id = 777;
update reprise set prestataire = 'Juan' where sharepoint_id = 557;
update reprise set prestataire = 'Juan' where sharepoint_id = 671;
update reprise set prestataire = 'Hedi' where sharepoint_id = 707;
update reprise set prestataire = 'Hedi' where sharepoint_id = 739;
update reprise set prestataire = 'Serafino' where sharepoint_id = 564;
update reprise set prestataire = 'Juan' where sharepoint_id = 583;
update reprise set prestataire = 'Juan' where sharepoint_id = 614;
update reprise set prestataire = 'Serafino' where sharepoint_id = 620;
update reprise set prestataire = 'Serafino' where sharepoint_id = 812;
update reprise set prestataire = 'MR NEGRONI' where sharepoint_id = 873;
update reprise set prestataire = 'Technicien EUROPROH' where sharepoint_id = 457;
update reprise set prestataire = 'Hedi' where sharepoint_id = 428;
update reprise set prestataire = 'MR NEGRONI' where sharepoint_id = 878;
update reprise set prestataire = 'MR NEGRONI' where sharepoint_id = 491;
update reprise set prestataire = 'Juan' where sharepoint_id = 523;
update reprise set prestataire = 'Hedi' where sharepoint_id = 531;
update reprise set prestataire = 'Hedi' where sharepoint_id = 607;
update reprise set prestataire = 'Hedi' where sharepoint_id = 738;
update reprise set prestataire = 'Hedi' where sharepoint_id = 440;
update reprise set prestataire = 'ALAIN' where sharepoint_id = 560;
update reprise set prestataire = 'Hedi' where sharepoint_id = 387;
update reprise set prestataire = 'Juan' where sharepoint_id = 822;

-- 1. Les lignes retirées de l'export.
--    Une anomalie que le tableau ne porte plus n'a plus lieu d'être :
--    elle a été supprimée à la source. Ce qu'elle a sorti du stock
--    reste (le matériel a bien quitté l'étagère) — c'est la règle de
--    la suppression d'une anomalie, posée par le schéma.
delete from anomalies a
 where a.sharepoint_id is not null
   and a.sharepoint_id <> all(array[370,371,372,373,374,376,377,378,379,380,381,382,384,385,386,387,388,389,390,392,394,395,396,398,399,400,401,402,403,404,407,408,409,410,411,412,413,414,415,416,417,420,421,422,423,424,425,426,427,428,429,431,433,434,435,436,440,441,442,443,444,446,447,448,449,450,452,453,454,455,456,457,458,459,460,461,462,463,465,467,468,469,470,471,472,473,474,475,477,478,480,482,483,484,485,486,488,490,491,492,493,494,495,496,497,498,500,502,503,504,505,506,507,508,509,510,511,514,515,516,517,518,520,521,522,523,524,525,527,529,530,531,532,533,534,535,536,537,538,542,544,545,546,547,548,550,551,552,553,556,557,558,559,560,563,564,565,566,568,570,571,572,573,574,575,576,577,578,579,581,582,583,584,585,586,587,588,589,590,591,592,594,595,597,598,599,600,601,602,603,605,607,608,609,610,611,612,613,614,615,616,618,619,620,621,622,623,624,625,626,627,631,632,633,634,635,636,637,638,640,641,642,643,644,645,646,648,649,650,652,653,654,655,656,657,658,659,661,662,663,664,666,667,668,669,670,671,672,673,676,677,678,681,684,685,686,688,689,690,691,692,693,694,697,698,699,700,701,702,703,704,705,706,707,708,709,710,713,716,717,718,719,720,722,723,725,726,727,728,729,730,731,732,733,734,736,737,738,739,740,741,742,743,744,745,746,747,748,749,750,751,752,754,755,756,757,758,759,760,761,762,763,764,765,767,769,770,771,772,773,774,775,776,777,778,779,780,782,783,784,785,786,787,788,789,790,791,793,795,796,797,798,799,800,801,802,803,804,805,806,807,808,809,811,812,813,814,815,816,817,818,819,820,821,822,823,824,825,826,827,828,829,831,833,834,835,837,838,839,840,842,843,844,845,846,847,848,849,850,851,852,853,854,855,858,860,861,862,863,865,866,867,868,869,870,871,872,873,875,876,877,878,879,880,881,882,891,892,893,895,896,898,899,900,901,946,947,948,949,950,974,975,976,977,978,979,980,981,982,983,984,985,986,987,988,989,990,991,992,993,994,996,998,999,1000,1001,1002,1003,1004,1005,1006,1007,1008,1009,1010,1011,1012,1016,1018,1019,1027,1028,1029,1030,1031,1033,1034,1035,1036,1037,1038,1039,1040,1041,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1052,1053,1054,1055,1056,1057,1059,1060,1061,1062,1063,1064,1065,1066,1067,1068,1069,1070,1071,1072,1073,1074,1076,1077,1078,1080,1081,1086,1087,1088,1089,1090,1091,1092,1093,1094,1095,1096,1097,1098,1099,1100,1101,1102,1103,1104,1105,1106,1107,1108,1109,1110,1111,1112,1113,1114,1115,1116,1117,1118,1119,1120,1121,1122,1123,1124,1126,1127,1128,1129,1130,1131,1132,1133,1134,1136,1137,1138,1139,1140,1141,1142,1143,1144,1145,1146,1147,1148,1149,1150,1151,1152,1153,1154,1155,1156,1157,1158,1159,1160,1161,1182,1183,1184,1185,1186,1187,1188,1190,1191,1192,1193,1194,1195,1196,1197,1198,1199,1200,1201,1202,1203,1204,1205,1206,1207,1208,1209,1210,1211,1212,1213,1214,1215,1216,1217,1218,1219,1223,1224,1225,1226,1227,1229,1239,1240,1241,1242,1243,1244,1246,1247,1248,1249,1250,1251,1252,1253,1255,1256,1257,1258,1259,1260,1261,1262,1263,1264,1265,1266]);

-- 2. L'anomalie : ce que le tableau dit d'elle.
--    Le lieu se corrige aussi — la reprise s'était trompée de porte.
--
--    En DEUX temps, et l'ordre compte. `anomalie_unique_ouverte_par_lieu`
--    interdit le même libellé ouvert deux fois au même endroit, et il le
--    vérifie ligne par ligne, pas à la fin de l'instruction. Si une
--    anomalie se ferme pour laisser la place à une autre, la fermer
--    d'abord évite un refus au milieu du chemin.
update anomalies a
   set statut = r.statut::statut_anomalie
  from reprise r
 where a.sharepoint_id = r.sharepoint_id
   and a.statut::text is distinct from r.statut
   and r.statut in ('validee', 'annulee');

update anomalies a
   set declare_le   = r.declare_le,
       description  = r.libelle,
       statut       = r.statut::statut_anomalie,
       emplacement_id = e.id,
       constate_par = coalesce(uc.id, a.constate_par),
       saisie_par   = coalesce(us.id, a.saisie_par)
  from reprise r
  join emplacements e   on e.code = r.lieu
  left join utilisateurs uc on lower(uc.nom) = lower(r.constate_par)
  left join utilisateurs us on lower(us.nom) = lower(r.saisie_par)
 where a.sharepoint_id = r.sharepoint_id
   and (a.declare_le::date is distinct from r.declare_le
     or a.description  is distinct from r.libelle
     or a.statut::text is distinct from r.statut
     or a.emplacement_id is distinct from e.id
     or (uc.id is not null and a.constate_par is distinct from uc.id));

-- 3. L'intervention : sa date, et qui l'a faite.
--    C'est la correction la plus lourde : une date d'intervention
--    fausse met le passage au mauvais jour, et la facture ne se
--    rapproche plus. Le regroupement suit, plus bas.
--    Une reprise ne remplace jamais une valeur par du vide : si le nom
--    ne se rattache à personne, on garde ce que la base sait déjà.
--    Écraser l'intervenant d'un passage parce qu'un export l'écrit
--    « ALAIN » et la table « Alain » serait une perte, pas une
--    correction.
update interventions i
   set date_intervention = r.fait_le,
       technicien_id  = case when r.externe then i.technicien_id
                             else coalesce(u.id, i.technicien_id) end,
       prestataire_id = case when r.externe then coalesce(p.id, i.prestataire_id)
                             else i.prestataire_id end
  from reprise r
  join anomalies a on a.sharepoint_id = r.sharepoint_id
  left join utilisateurs u on lower(u.nom) = lower(r.par)
  left join prestataires p on lower(p.nom) = lower(r.prestataire)
 where i.anomalie_id = a.id
   and r.fait_le is not null
   and (i.date_intervention is distinct from r.fait_le
     or (not r.externe and u.id is not null
         and i.technicien_id is distinct from u.id)
     or (r.externe and p.id is not null
         and i.prestataire_id is distinct from p.id));

-- Une intervention que le tableau annonce et que la base n'a pas.
insert into interventions (anomalie_id, tournee_id, technicien_id,
                           prestataire_id, date_intervention, cree_le)
select a.id, null,
       case when r.externe then null else u.id end,
       case when r.externe then p.id else null end,
       r.fait_le, r.fait_le::timestamptz
  from reprise r
  join anomalies a on a.sharepoint_id = r.sharepoint_id
  left join utilisateurs u on lower(u.nom) = lower(r.par)
  left join prestataires p on lower(p.nom) = lower(r.prestataire)
 where r.fait_le is not null
   and not exists (select 1 from interventions i where i.anomalie_id = a.id);

-- 4. Les deux avis. Les dates suivent, elles aussi.
update validations v
   set decide_le = r.fait_le::timestamptz
  from reprise r
  join anomalies a on a.sharepoint_id = r.sharepoint_id
  join interventions i on i.anomalie_id = a.id
 where v.intervention_id = i.id and v.acteur = 'technicien'
   and r.fait_le is not null
   and v.decide_le::date is distinct from r.fait_le;

update validations v
   set decide_le = r.verifie_le::timestamptz
  from reprise r
  join anomalies a on a.sharepoint_id = r.sharepoint_id
  join interventions i on i.anomalie_id = a.id
 where v.intervention_id = i.id and v.acteur = 'gouvernante'
   and r.verifie_le is not null
   and v.decide_le::date is distinct from r.verifie_le;

-- L'avis du technicien, quand le tableau le donne et que la base
-- ne l'a pas : sans lui, l'anomalie n'a personne qui la déclare faite.
insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le)
select i.id, 'technicien', 'fait',
       case when r.externe then null else u.id end, r.fait_le::timestamptz
  from reprise r
  join anomalies a on a.sharepoint_id = r.sharepoint_id
  join interventions i on i.anomalie_id = a.id
  left join utilisateurs u on lower(u.nom) = lower(r.par)
 where r.fait_le is not null
   and not exists (select 1 from validations v
        where v.intervention_id = i.id and v.acteur = 'technicien');

insert into validations (intervention_id, acteur, decision, utilisateur_id, decide_le)
select i.id, 'gouvernante', 'validee', u.id, r.verifie_le::timestamptz
  from reprise r
  join anomalies a on a.sharepoint_id = r.sharepoint_id
  join interventions i on i.anomalie_id = a.id
  left join utilisateurs u on lower(u.nom) = lower(r.verifie_par)
 where r.verifie_le is not null
   and not exists (select 1 from validations v
        where v.intervention_id = i.id and v.acteur = 'gouvernante');

-- 5. Le matériel sorti : sa date suit l'intervention, et son nom
--    se corrige (l'export portait « Télérupteurs (Mécaniques) » avec
--    un retour à la ligne au milieu).
update mouvements_stock m
   set date_mouvement = r.fait_le::timestamptz
  from reprise r
  join anomalies a on a.sharepoint_id = r.sharepoint_id
  join interventions i on i.anomalie_id = a.id
 where m.intervention_id = i.id
   and r.fait_le is not null
   and m.date_mouvement::date is distinct from r.fait_le;

-- Une sortie que le tableau annonce et que la base n'a pas. On ne
-- sort que ce que le catalogue connaît : un nom inconnu est signalé
-- dans le compte-rendu plutôt que d'inventer un produit.
insert into mouvements_stock (produit_id, type, quantite, utilisateur_id,
                             prestataire_id, emplacement_id, intervention_id,
                             date_mouvement, commentaire)
select pr.id, 'sortie', -greatest(coalesce(r.quantite, 1), 1),
       case when r.externe then null else u.id end,
       case when r.externe then p.id else null end,
       a.emplacement_id, i.id, r.fait_le::timestamptz,
       'Intervention — ' || a.description
  from reprise r
  join anomalies a on a.sharepoint_id = r.sharepoint_id
  join interventions i on i.anomalie_id = a.id
  join produits pr on pr.designation = r.produit
  left join utilisateurs u on lower(u.nom) = lower(r.par)
  left join prestataires p on lower(p.nom) = lower(r.prestataire)
 where r.produit <> '' and r.fait_le is not null
   and not exists (select 1 from mouvements_stock m
        where m.intervention_id = i.id and m.produit_id = pr.id);

-- 6. Les anomalies que le tableau porte et que la base n'a pas.
insert into anomalies (sharepoint_id, emplacement_id, description, statut,
                       declare_le, constate_par, saisie_par)
select r.sharepoint_id, e.id, r.libelle, r.statut::statut_anomalie,
       r.declare_le, uc.id, coalesce(us.id, uc.id)
  from reprise r
  join emplacements e on e.code = r.lieu
  left join utilisateurs uc on lower(uc.nom) = lower(r.constate_par)
  left join utilisateurs us on lower(us.nom) = lower(r.saisie_par)
 where not exists (select 1 from anomalies a
        where a.sharepoint_id = r.sharepoint_id);

alter table validations enable trigger tg_validation_maj_anomalie;

-- 7. Les passages se remettent d'aplomb : un par intervenant et par
--    jour, les interventions accrochées au bon, les passages vides
--    effacés. C'est ce qui suit la correction des dates.
select * from fn_regrouper_les_passages();

-- Ce que la reprise a laissé de côté, à relire :
select r.sharepoint_id, r.produit
  from reprise r
 where r.produit <> ''
   and not exists (select 1 from produits p where p.designation = r.produit)
 order by r.produit, r.sharepoint_id;

commit;
