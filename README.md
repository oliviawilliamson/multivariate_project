# Multivariate Final Project
### NHANES-Based Risk Factor Analysis for HIV Seropositivity
**Olivia Williamson & Andres Davila | Spring 2026**

---

## Overview
This project uses National Health and Nutrition Examination Survey (NHANES) data
to investigate risk factors associated with HIV seropositivity in U.S. adults. 
Data from four survey cycles (2011–2018) were pooled and analyzed using a 
two-stage multivariate approach: factor analysis for dimension reduction, 
followed by weighted logistic regression.

---

## Data
- **Source:** CDC NHANES, cycles 2011–2012, 2013–2014, 2015–2016, 2017–2018
- **Total merged sample:** 22,807 MEC-examined adults (≥18 years)
- **Outcome:** HIV seropositivity (LBXHIVC; 1 = positive, 2 = negative)
- **Domains:** Demographic, behavioral, anthropometric, dietary, and clinical variables
- **Survey design:** Complex multistage probability sample — stratum (SDMVSTRA), 
  cluster (SDMVPSU), and pooled 4-cycle MEC weight (WTMEC8YR = WTMEC2YR ÷ 4) 
  applied in regression per CDC multi-cycle pooling guidelines

---

## Methods

### Stage 1 — Factor Analysis (SAS)
- 13 continuous variables entered into principal components extraction with varimax rotation
- Maximum likelihood method assessed for comparison; rejected due to Heywood case (BMXWT communality = 1.0)
- Factor retention based on eigenvalue > 1 criterion and scree plot inspection
- **5 factors retained**, explaining 62.77% of total variance
- Factor scores saved and carried forward as predictors

| Factor | Construct | Key Variables |
|--------|-----------|---------------|
| 1 | Dietary Intake | Protein, Carbohydrates, Total Fat |
| 2 | Body Composition | Weight, BMI, HDL (inverse) |
| 3 | Metabolic/Aging Risk | Age, HbA1c |
| 4 | Socioeconomic Status | Income-to-Poverty Ratio, Height |
| 5 | Alcohol Consumption | Avg Drinks Per Day |

### Stage 2 — Logistic Regression (SAS) **TBD**
- `PROC SURVEYLOGISTIC` used to account for complex survey design
- Factor scores entered as continuous predictors
- Final analytic sample: 1,841 participants (16 HIV positive cases)
- No factors reached statistical significance; model AUC = 0.473

---

## Key Limitations
- Low HIV event count (n=16 in analytic sample) severely limited statistical power
- Key behavioral risk variables (injection drug use, condom use, sexual partners) 
  excluded from final model due to high missingness and insufficient sample overlap
- SXQ module not publicly released for 2017–2018 cycle
- Factor analysis conducted unweighted — survey weights applied at regression stage only
- Listwise deletion used; multiple imputation was beyond scope

---

## Software
- **R** (data acquisition and preparation): `tidyverse`, `haven`
- **SAS ODA** (analysis): `PROC FACTOR`, `PROC SURVEYLOGISTIC`
