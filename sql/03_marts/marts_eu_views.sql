-- Sous Nos Pieds — BigQuery views, dataset: marts_eu (analytics-ready financial marts)
-- Project: wagon-bootcamp-501621 · Author: Asma Ammouri

-- ============================================
-- View: marts_eu.finance-view
-- ============================================
WITH comptage_par_peril AS (
  SELECT
    code_commune,
    COUNTIF(
      REGEXP_CONTAINS(LOWER(lib_risque_jo), r'inondation|coulee.*boue|remontee.*nappe|submersion')
    ) AS nb_catnat_inondation,
    COUNTIF(LOWER(lib_risque_jo) LIKE '%secheresse%') AS nb_catnat_secheresse,
    COUNTIF(LOWER(lib_risque_jo) LIKE '%mouvement%terrain%' 
            AND LOWER(lib_risque_jo) NOT LIKE '%secheresse%') AS nb_catnat_terrain,
    COUNTIF(LOWER(lib_risque_jo) LIKE '%raz%maree%') AS nb_catnat_raz_de_maree,
    COUNTIF(LOWER(lib_risque_jo) LIKE '%seisme%') AS nb_catnat_seisme
FROM `wagon-bootcamp-501621.staging.catnat_staging`
  GROUP BY code_commune
)
SELECT m.*, c.nb_catnat_inondation, c.nb_catnat_secheresse, c.nb_catnat_terrain
FROM `wagon-bootcamp-501621.marts_eu.financier_marts` as m
LEFT JOIN comptage_par_peril c USING (code_commune);

-- ============================================
-- View: marts_eu.finance_view_2
-- ============================================
WITH comptage_par_commune AS (
  SELECT
    code_commune,
    COUNTIF(lib_risque_jo IN (
      'inondations et/ou coulees de boue',
      'inondations remontee nappe',
      'coulee de boue'
    )) AS nb_catnat_inondation,
    COUNTIF(lib_risque_jo = 'secheresse') AS nb_catnat_secheresse,
    COUNTIF(lib_risque_jo IN (
      'mouvement de terrain',
      'glissement de terrain',
      'effondrement et/ou affaisement',
      'eboulement et/ou chute de blocs',
      'glissement et effondrement de terrain',
      'glissement et eboulement rocheux'
    )) AS nb_catnat_terrain,
    COUNT(*) AS nb_catnat_total

  FROM `wagon-bootcamp-501621.staging.catnat_staging`
  GROUP BY code_commune
)

SELECT
  m.*,
  COALESCE(c.nb_catnat_inondation, 0) AS nb_catnat_inondation,
  COALESCE(c.nb_catnat_secheresse, 0) AS nb_catnat_secheresse,
  COALESCE(c.nb_catnat_terrain, 0)    AS nb_catnat_terrain,
  COALESCE(c.nb_catnat_total, 0)      AS nb_catnat_total
FROM `wagon-bootcamp-501621.marts_eu.financier_marts` m
LEFT JOIN comptage_par_commune c
  ON m.code_commune = c.code_commune;
