# Sous Nos Pieds — Mapping and predicting natural-disaster risk and costs in France

> Le Wagon Data Analytics capstone project (2026) · topic proposed by Asma Ammouri and selected by the cohort

## Business question
Which French municipalities are the most exposed to natural disasters, which physical factors explain it, and how much could these disasters cost in the coming years?

## Data
- **GASPAR** (Géorisques / data.gouv.fr): CatNat decrees, risk-prevention plans (PPRn, PPRm, PPRt), DICRIM, AZI
- **SWI Météo-France**: soil wetness index, ~50 years, 8,981 grid points
- **Géorisques API**: clay shrink-swell hazard and seismic zoning by municipality
- **CCR** cost bands of natural-disaster claims by department (1995-2021)

## What I did
**1. Data pipeline (BigQuery + Python)** — raw → staging → intermediate → marts: cleaning of 8 GASPAR tables and 50 years of SWI data (INSEE codes, dates, accents, nulls), data-quality views, joins by municipality.

**2. Geospatial processing** — GeoPandas, pyproj (Lambert-93 → WGS84), nearest-grid-point matching with a KD-tree: **100% of municipalities** linked to SWI data; maps with Plotly and contextily.

**3. Machine Learning** — multi-output **Random Forest** classifier (200 trees, balanced classes) predicting, for each municipality, the probability of a CatNat decree for each hazard (flood, drought, ground movement, earthquake…).
- Features: SWI statistics (mean, variability, min, max, number of drought months), clay shrink-swell level, seismic zone
- **Temporal validation**: trained on decrees before 2019, tested on 2019-2025
- Baseline vs. enriched model compared with **F1-score**, with decision-threshold tuning
- Predictions by municipality and department exported to BigQuery

**4. Cost projection** — recent annual frequency of decrees (2013-2022) × historical average cost per decree: projected annual cost of **≈ €1.38B for drought**, ≈ €431M for floods and ≈ €3.9M for ground movements, over 5- and 10-year horizons, distributed by department.

**5. Dashboard (Looker Studio)** — 246K CatNat decrees and €66B of costs (1982-2025), maps by hazard and department, prediction and projection pages.

## Repository structure
```
notebooks/
  01_cleaning_dicrim_gaspar.ipynb     # staging: cleaning a GASPAR table (pandas → BigQuery)
  02_build_all_risques_catnat.ipynb   # intermediate: one row per municipality (CatNat counts, PPR, SWI)
  03_geo_mapping_catnat.ipynb         # geospatial layers and maps (GeoPandas, Plotly)
  04_ml_multi_hazard_risk.ipynb       # ML: multi-hazard risk classifier + Géorisques API enrichment
  05_cost_projection.ipynb            # cost projection by hazard and department
sql/
  03_marts/marts_eu_views.sql         # financial marts: CatNat counts by hazard joined to claim costs
  04_dashboard/risques_naturels_views.sql  # serving views for the Looker Studio maps
sous-nos-pieds-final.mp4              # video walkthrough of the dashboard
```

## Stack
Python (pandas, GeoPandas, pyproj, SciPy, scikit-learn, Plotly) · SQL · Google BigQuery · Géorisques API · Looker Studio

## Why it matters
As a geological engineer with 13+ years in natural hazards, I built this project to connect field expertise with data: understanding where the data comes from, its limits, and what a decision costs.
