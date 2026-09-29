
## Repository structure
```
sql/
  03_marts/marts_eu_views.sql              # financial marts: CatNat counts by hazard joined to claim costs
  04_dashboard/risques_naturels_views.sql  # serving views for the Looker Studio maps (by hazard, metropole / DROM, clay hazard)
sous-nos-pieds-final.mp4                   # video walkthrough of the dashboard
```

Data layers in BigQuery: `data_gouv` (raw) → `staging` (cleaned GASPAR & SWI tables + data-quality views) → `intermediate` (joins GASPAR × SWI, geolocation) → `marts_eu` / `risques_naturels` (analytics & dashboard tables, ML predictions and cost projections).
# Sous Nos Pieds — Mapping and predicting the cost of natural disasters in France

> Le Wagon Data Analytics capstone project (2026) · topic proposed by Asma Ammouri and selected by the cohort

## Business question
Which French territories are the most exposed to natural disasters, how much do they cost, and how will drought risk evolve in the coming years?

## Data
- **GASPAR** (data.gouv.fr / Géorisques): natural-disaster (CatNat) decrees by municipality — 8 tables
- **SWI Météo-France**: soil wetness index, ~50 years of history
- Costs of natural-disaster claims, as used in the project dashboard

## What I did
- **Data pipeline**: ingestion, cleaning and structuring of the GASPAR tables and SWI data in **Google BigQuery** (SQL)
- **Analysis**: 246K CatNat decrees and €66B of costs analysed (1982-2025) by hazard type, region and year
- **Machine Learning** (Python): model projecting **drought risk by department up to 2036** (projected annual cost up to €1.4B/year)
- **Dashboard** (Looker Studio): multi-risk view, maps by department, prediction page

## Stack
Python (pandas, scikit-learn) · SQL · Google BigQuery · Looker Studio

## Demo
Video walkthrough: `sous-nos-pieds-final.mp4` (in this repository)

## Why it matters
As a geological engineer with 13+ years in natural hazards, I built this project to connect field expertise with data: understanding where the data comes from, its limits, and what a decision costs.
