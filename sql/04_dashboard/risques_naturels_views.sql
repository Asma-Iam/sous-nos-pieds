-- Sous Nos Pieds — BigQuery views, dataset: risques_naturels (serving layer for the Looker Studio maps: CatNat by hazard, geo layers, clay shrink-swell hazard)
-- Project: wagon-bootcamp-501621 · Author: Asma Ammouri

-- ============================================
-- View: risques_naturels.carte_catnat_autres_perils
-- ============================================
SELECT *
    FROM `wagon-bootcamp-501621.risques_naturels.carte_catnat_geo`
    WHERE type_peril = 'Autres périls';

-- ============================================
-- View: risques_naturels.carte_catnat_avalanche
-- ============================================
SELECT *
    FROM `wagon-bootcamp-501621.risques_naturels.carte_catnat_geo`
    WHERE type_peril = 'Avalanche';

-- ============================================
-- View: risques_naturels.carte_catnat_departement_domtom
-- ============================================
WITH catnat_par_dept AS (
  SELECT
    CASE
      WHEN SUBSTR(code_commune, 1, 2) IN ('97', '98') THEN SUBSTR(code_commune, 1, 3)
      ELSE SUBSTR(code_commune, 1, 2)
    END AS code_departement,
    type_peril,
    SUM(nb_reconnaissances) AS nb_reconnaissances
  FROM `wagon-bootcamp-501621.risques_naturels.catnat_geo_final`
  GROUP BY code_departement, type_peril
)
SELECT
  d.code_departement,
  REPLACE(r.string_field_0, 'lareunion', 'la reunion') AS nom_departement,
  d.type_peril,
  d.nb_reconnaissances,
  g.geography
FROM catnat_par_dept d
LEFT JOIN `wagon-bootcamp-501621.pprn_garspar_raw.ref_departements` r
  ON d.code_departement = r.string_field_1
LEFT JOIN `wagon-bootcamp-501621.risques_naturels.departements_geo` g
  ON d.code_departement = g.code_departement
WHERE SUBSTR(d.code_departement, 1, 2) IN ('97', '98');

-- ============================================
-- View: risques_naturels.carte_catnat_departement_geo
-- ============================================
WITH catnat_par_dept AS (
  SELECT
    code_departement,
    nom_departement,
    type_peril,
    SUM(nb_reconnaissances) AS nb_reconnaissances
  FROM `wagon-bootcamp-501621.risques_naturels.catnat_geo_final`
  GROUP BY code_departement, nom_departement, type_peril
)
SELECT
  c.code_departement,
  c.nom_departement,
  c.type_peril,
  c.nb_reconnaissances,
  d.geography
FROM catnat_par_dept c
JOIN `wagon-bootcamp-501621.risques_naturels.departements_geo` d
  ON c.code_departement = d.code_departement;

-- ============================================
-- View: risques_naturels.carte_catnat_departement_metropole
-- ============================================
WITH all_departements AS (
  SELECT DISTINCT
    LPAD(TRIM(string_field_1), 2, '0') AS code_departement,
    TRIM(string_field_0) AS nom_departement
  FROM `wagon-bootcamp-501621.pprn_garspar_raw.ref_departements`
  WHERE SUBSTR(TRIM(string_field_1), 1, 2) NOT IN ('97', '98')
),

all_perils AS (
  SELECT DISTINCT TRIM(type_peril) AS type_peril
  FROM `wagon-bootcamp-501621.risques_naturels.catnat_geo_final`
  WHERE type_peril IS NOT NULL
),

grille_complete AS (
  SELECT d.code_departement, d.nom_departement, p.type_peril
  FROM all_departements d
  CROSS JOIN all_perils p
),

catnat_par_dept AS (
  SELECT
    LPAD(TRIM(CASE
      WHEN SUBSTR(code_commune, 1, 2) IN ('97', '98') THEN SUBSTR(code_commune, 1, 3)
      ELSE SUBSTR(code_commune, 1, 2)
    END), 2, '0') AS code_departement,
    TRIM(type_peril) AS type_peril,
    SUM(nb_reconnaissances) AS nb_reconnaissances
  FROM `wagon-bootcamp-501621.risques_naturels.catnat_geo_final`
  GROUP BY code_departement, type_peril
),

geo_dedup AS (
  SELECT code_departement, geography
  FROM `wagon-bootcamp-501621.risques_naturels.departements_geo`
  QUALIFY ROW_NUMBER() OVER (PARTITION BY LPAD(TRIM(code_departement), 2, '0') ORDER BY code_departement) = 1
)

SELECT
  gc.code_departement,
  gc.nom_departement,
  gc.type_peril,
  COALESCE(c.nb_reconnaissances, 0) AS nb_reconnaissances,
  g.geography
FROM grille_complete gc
LEFT JOIN catnat_par_dept c
  ON gc.code_departement = c.code_departement AND gc.type_peril = c.type_peril
LEFT JOIN geo_dedup g
  ON gc.code_departement = g.code_departement;

-- ============================================
-- View: risques_naturels.carte_catnat_geo
-- ============================================
SELECT
  c.code_commune,
  c.type_peril,
  c.nb_reconnaissances,
  CASE
    WHEN c.nb_reconnaissances <= 5 THEN 0
    WHEN c.nb_reconnaissances <= 10 THEN 1
    WHEN c.nb_reconnaissances <= 15 THEN 2
    WHEN c.nb_reconnaissances <= 25 THEN 3
    ELSE 4
  END AS tranche,
  c.nom_commune,
  -- recalcule au lieu de faire confiance à c.code_departement
  CASE
    WHEN SUBSTR(c.code_commune, 1, 2) IN ('97', '98') THEN SUBSTR(c.code_commune, 1, 3)
    ELSE SUBSTR(c.code_commune, 1, 2)
  END AS code_departement,
  c.nom_departement,
  g.geography
FROM `wagon-bootcamp-501621.risques_naturels.catnat_geo_final` c
JOIN `wagon-bootcamp-501621.risques_naturels.communes_geo` g
  ON c.code_commune = g.code_commune;

-- ============================================
-- View: risques_naturels.carte_catnat_geo_domtom
-- ============================================
SELECT *
FROM `wagon-bootcamp-501621.risques_naturels.carte_catnat_geo`
WHERE SUBSTR(code_commune, 1, 2) IN ('97', '98');

-- ============================================
-- View: risques_naturels.carte_catnat_geo_latlong
-- ============================================
SELECT
    code_commune,
    nom_commune,
    code_departement,
    nom_departement,
    type_peril,
    tranche,
    nb_reconnaissances,
    ST_X(ST_Centroid(geography)) AS longitude,
    ST_Y(ST_Centroid(geography)) AS latitude
FROM `wagon-bootcamp-501621.risques_naturels.carte_catnat_geo`
WHERE geography IS NOT NULL;

-- ============================================
-- View: risques_naturels.carte_catnat_geo_metropole
-- ============================================
SELECT *
FROM `wagon-bootcamp-501621.risques_naturels.carte_catnat_geo`
WHERE SUBSTR(code_commune, 1, 2) NOT IN ('97', '98');

-- ============================================
-- View: risques_naturels.carte_catnat_inondations
-- ============================================
SELECT *
    FROM `wagon-bootcamp-501621.risques_naturels.carte_catnat_geo`
    WHERE type_peril = 'Inondations';

-- ============================================
-- View: risques_naturels.carte_catnat_mouvement_terrain
-- ============================================
SELECT *
    FROM `wagon-bootcamp-501621.risques_naturels.carte_catnat_geo`
    WHERE type_peril = 'Mouvement de terrain';

-- ============================================
-- View: risques_naturels.carte_catnat_secheresse
-- ============================================
SELECT *
    FROM `wagon-bootcamp-501621.risques_naturels.carte_catnat_geo`
    WHERE type_peril = 'Sécheresse';

-- ============================================
-- View: risques_naturels.carte_catnat_seisme
-- ============================================
SELECT *
    FROM `wagon-bootcamp-501621.risques_naturels.carte_catnat_geo`
    WHERE type_peril = 'Séisme';

-- ============================================
-- View: risques_naturels.carte_catnat_tous_perils
-- ============================================
SELECT *
    FROM `wagon-bootcamp-501621.risques_naturels.carte_catnat_geo`
    WHERE type_peril = 'Tous périls';

-- ============================================
-- View: risques_naturels.carte_catnat_vent_cyclonique
-- ============================================
SELECT *
    FROM `wagon-bootcamp-501621.risques_naturels.carte_catnat_geo`
    WHERE type_peril = 'Vent cyclonique';

-- ============================================
-- View: risques_naturels.vue_alea_argiles_departement
-- ============================================
SELECT
  d.code_departement,
  ANY_VALUE(d.geography) AS geometry,
  AVG(a.niveau) AS niveau_moyen,
  MAX(a.niveau) AS niveau_max,
  SUM(a.surf_m2) AS surf_totale
FROM
  `wagon-bootcamp-501621.risques_naturels.alea_argiles_france` a
JOIN
  `wagon-bootcamp-501621.risques_naturels.departements_geo` d
ON
  a.insee_dep = d.code_departement
WHERE
  SAFE.ST_GEOGFROMTEXT(a.geometry) IS NOT NULL
GROUP BY
  d.code_departement;

-- ============================================
-- View: risques_naturels.vue_alea_argiles_map
-- ============================================
SELECT
  gid,
  insee_dep,
  niveau,
  surf_m2,
  ST_SIMPLIFY(SAFE.ST_GEOGFROMTEXT(geometry), 30) AS geometry,
  surf_m2 / 551695000000 AS ratio_surface_france
FROM
  `wagon-bootcamp-501621.risques_naturels.alea_argiles_france`
WHERE
  SAFE.ST_GEOGFROMTEXT(geometry) IS NOT NULL;
