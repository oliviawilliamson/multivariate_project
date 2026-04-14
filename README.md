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

### Stage 2 — Logistic Regression (SAS) - *TBD*
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

---

## Variable Glossary

### Survey Design Variables
| Variable | Description |
|----------|-------------|
| SEQN | Respondent sequence number — unique participant identifier |
| SDMVSTRA | Masked variance stratum — used for standard error estimation |
| SDMVPSU | Masked variance pseudo-PSU — primary sampling unit for clustering |
| WTMEC2YR | MEC examination sample weight for a single 2-year cycle |
| WTMEC8YR | Pooled 4-cycle MEC weight (WTMEC2YR ÷ 4) — used in all analyses |
| RIDSTATR | Interview and examination status (2 = MEC-examined) |

### Outcome
| Variable | Description |
|----------|-------------|
| LBXHIVC | HIV confirmatory antibody result (1 = positive, 2 = negative) |

### Demographic Variables
| Variable | Description |
|----------|-------------|
| RIDAGEYR | Age in years at time of screening |
| RIAGENDR | Sex (1 = male, 2 = female) |
| RIDRETH1 | Race/ethnicity — 5 category version (1 = Mexican American, 2 = Other Hispanic, 3 = Non-Hispanic White, 4 = Non-Hispanic Black, 5 = Other) |
| RIDRETH3 | Race/ethnicity — 6 category version, includes Non-Hispanic Asian (added in cycle I) |
| DMDEDUC2 | Education level for adults 20+ (1 = less than 9th grade, 5 = college graduate or above) |
| INDFMPIR | Family income-to-poverty ratio (0–5, higher = higher income relative to poverty threshold) |

### Behavioral Variables
| Variable | Description |
|----------|-------------|
| SMQ040 | Current cigarette smoking status (1 = every day, 2 = some days, 3 = not at all) |
| ALQ130 | Average number of alcoholic drinks consumed per day in the past 12 months |
| SXQ292 | Number of sexual partners in the past 12 months — excluded from factor analysis due to missingness |
| SXQ294 | Condom use at last sexual encounter — excluded from final model due to missingness |
| DUQ250 | Ever used a needle to inject non-prescription drugs (1 = yes, 2 = no) — excluded from final model due to missingness |

### Anthropometric Variables
| Variable | Description |
|----------|-------------|
| BMXBMI | Body mass index (kg/m²) |
| BMXWT | Weight in kilograms |
| BMXHT | Standing height in centimeters |

### Laboratory Variables
| Variable | Description |
|----------|-------------|
| LBXGLU | Fasting plasma glucose (mg/dL) — fasting subsample only, excluded from factor analysis due to missingness |
| LBXGH | Glycohemoglobin / HbA1c (%) — marker of long-term blood glucose control |
| LBDHDD | HDL cholesterol (mg/dL) — high-density lipoprotein |
| LBDLDL | LDL cholesterol (mg/dL) — low-density lipoprotein, derived from TRIGLY file |

### Physical Activity
| Variable | Description |
|----------|-------------|
| PAD680 | Minutes of sedentary activity per day |

### Dietary Intake (24-hour recall, Day 1)
| Variable | Description |
|----------|-------------|
| DR1TPROT | Total protein intake (grams) |
| DR1TCARB | Total carbohydrate intake (grams) |
| DR1TTFAT | Total fat intake (grams) |

### Clinical/Diagnosis Variables
| Variable | Description |
|----------|-------------|
| DIQ010 | Doctor told you have diabetes (1 = yes, 2 = no, 3 = borderline) |
| MCQ160C | Ever told you had coronary heart disease (1 = yes, 2 = no) |
| BPQ020 | Ever told you had high blood pressure (1 = yes, 2 = no) |

### Derived Factor Scores
| Variable | Description |
|----------|-------------|
| Factor1 | Dietary Intake — protein, carbohydrates, total fat |
| Factor2 | Body Composition — weight, BMI, HDL (inverse loading) |
| Factor3 | Metabolic/Aging Risk — age, HbA1c |
| Factor4 | Socioeconomic Status — income-to-poverty ratio, height |
| Factor5 | Alcohol Consumption — average drinks per day |
