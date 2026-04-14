# Olivia Williamson, Andres Davila
# 2026-04-13

# Packages
# install.packages(c("tidyverse", "haven"))
library(tidyverse)
library(haven)

# NHANES cycles
cycles <- c("G", "H", "I", "J")

cycle_year_map <- c(
  G = "2011-2012",
  H = "2013-2014",
  I = "2015-2016",
  J = "2017-2018"
)

start_year_map <- c(
  G = "2011",
  H = "2013",
  I = "2015",
  J = "2017"
)

# Components
# Note: DR1TOT uses a different file stub pattern (DR1TOT_G, etc.)
# GLU fasting glucose is a lab sub sample — expect high missingness
# SXQ_J is excluded below (due to mode change in 2017-2018)
components <- c(
  "HIV",    # HIV status
  "DEMO",   # Demographics
  "INQ",    # Income
  "HIQ",    # Health insurance
  "DUQ",    # Drug use (injection)
  "SXQ",    # Sexual behavior
  "MCQ",    # Medical conditions (coronary heart disease)
  "HUQ",    # Health utilization
  "SMQ",    # Smoking
  "ALQ",    # Alcohol
  "BMX",    # Body measures (BMI, weight, height)
  "GLU",    # Fasting glucose (lab subsample)
  "GHB",    # HbA1c
  "HDL",    # HDL cholesterol
  "TRIGLY", # LDL cholesterol (LDL is computed in TRIGLY file)
  "PAQ",    # Physical activity (PAD680)
  "DR1TOT", # Dietary recall Day 1 (protein, carbs, fat)
  "DIQ",    # Diabetes diagnosis
  "BPQ"     # Blood pressure / hypertension
)

# Build URL
build_nhanes_url <- function(component, cycle) {
  start_year <- start_year_map[[cycle]]
  file_stub <- paste0(component, "_", cycle)
  paste0(
    "https://wwwn.cdc.gov/Nchs/Data/Nhanes/Public/",
    start_year,
    "/DataFiles/",
    file_stub,
    ".xpt"
  )
}

# Read one file safely
read_nhanes_url <- function(component, cycle) {
  
  # SXQ was not released publicly for 2017-2018 in standard format
  if (component == "SXQ" & cycle == "J") {
    message("Skipping SXQ_J (not available for 2017-2018 cycle)")
    return(NULL)
  }
  
  file_url <- build_nhanes_url(component, cycle)
  
  out <- tryCatch(
    {
      message("Reading: ", file_url)
      read_xpt(file_url) %>%
        mutate(
          cycle_code = cycle,
          cycle      = cycle_year_map[[cycle]]
        )
    },
    error = function(e) {
      warning("Skipping file: ", file_url, " — ", conditionMessage(e))
      NULL
    }
  )
  out
}

# Stack one component across all cycles
stack_component <- function(component, cycles) {
  map(cycles, ~ read_nhanes_url(component, .x)) %>%
    compact() %>%
    bind_rows()
}

# Download all components
nhanes_list <- map(components, ~ stack_component(.x, cycles))
names(nhanes_list) <- components

# Merge all components on SEQN + cycle identifiers
nhanes_merged <- nhanes_list$DEMO %>%
  left_join(nhanes_list$HIV,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$INQ,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$HIQ,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$DUQ,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$SXQ,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$MCQ,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$HUQ,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$SMQ,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$ALQ,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$BMX,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$GLU,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$GHB,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$HDL,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$TRIGLY, by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$PAQ,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$DR1TOT, by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$DIQ,    by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$BPQ,    by = c("SEQN", "cycle_code", "cycle"))

# Sanity checks
glimpse(nhanes_merged)

nrow(nhanes_merged) == nrow(nhanes_list$DEMO) # Should return TRUE

nhanes_merged %>%
  count(SEQN, cycle_code) %>%
  filter(n > 1)

nhanes_merged %>% count(cycle)
nhanes_list$DEMO %>% count(cycle) # Should match

# Non-missingness check for all target variables
# Note: HDL check includes both possible variable names across cycles
nhanes_merged %>%
  summarise(
    hiv_status        = sum(!is.na(LBXHIVC)),
    age               = sum(!is.na(RIDAGEYR)),
    sex               = sum(!is.na(RIAGENDR)),
    race              = sum(!is.na(RIDRETH1)),
    ethnicity         = sum(!is.na(RIDRETH3)),
    education         = sum(!is.na(DMDEDUC2)),
    poverty_ratio     = sum(!is.na(INDFMPIR)),
    smoking           = sum(!is.na(SMQ040)),
    alcohol           = sum(!is.na(ALQ130)),
    bmi               = sum(!is.na(BMXBMI)),
    weight            = sum(!is.na(BMXWT)),
    height            = sum(!is.na(BMXHT)),
    fasting_glucose   = sum(!is.na(LBXGLU)),
    hba1c             = sum(!is.na(LBXGH)),
    hdl_dd            = sum(!is.na(LBDHDD)),   # check which is populated
    ldl               = sum(!is.na(LBDLDL)),
    sedentary_minutes = sum(!is.na(PAD680)),
    protein           = sum(!is.na(DR1TPROT)),
    carbs             = sum(!is.na(DR1TCARB)),
    total_fat         = sum(!is.na(DR1TTFAT)),
    diabetes_dx       = sum(!is.na(DIQ010)),
    chd               = sum(!is.na(MCQ160C)),
    hypertension      = sum(!is.na(BPQ020)),
    sexual_partners   = sum(!is.na(SXQ292)),
    condom_use        = sum(!is.na(SXQ294)),
    injection_drug    = sum(!is.na(DUQ250))
  ) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "n_nonmissing") %>%
  arrange(n_nonmissing)

# Pooled survey weight for 4 cycles (CDC recommendation)
nhanes_merged <- nhanes_merged %>%
  mutate(WTMEC8YR = WTMEC2YR / 4)

# Restrict to analytic sample:
# MEC-examined adults only, valid survey weight
nhanes_analytic <- nhanes_merged %>%
  filter(
    RIDSTATR == 2,
    WTMEC2YR > 0,
    !is.na(WTMEC2YR),
    RIDAGEYR >= 18
  )

# Select only needed columns before export
# Update HDL variable name below based on missingness check results above:
# if hdl_dd > 0 keep LBDHDD; if hdl_dl > 0 keep LBDHDL; keep both if unsure
nhanes_analytic <- nhanes_analytic %>%
  select(
    # Survey design variables — required for PROC SURVEYLOGISTIC
    SEQN, cycle, cycle_code,
    WTMEC2YR, WTMEC8YR, SDMVPSU, SDMVSTRA,
    RIDSTATR,
    
    # Outcome
    LBXHIVC,
    
    # Predictors
    RIDAGEYR,    # age
    RIAGENDR,    # sex
    RIDRETH1,    # race/ethnicity v1
    RIDRETH3,    # race/ethnicity v3
    DMDEDUC2,    # education
    INDFMPIR,    # income-to-poverty ratio
    SMQ040,      # smoking
    ALQ130,      # alcohol
    BMXBMI,      # BMI
    BMXWT,       # weight
    BMXHT,       # height
    LBXGLU,      # fasting glucose
    LBXGH,       # HbA1c
    LBDHDD,      # HDL (confirm name from missingness check)
    LBDLDL,      # LDL
    PAD680,      # sedentary minutes
    DR1TPROT,    # protein
    DR1TCARB,    # carbohydrates
    DR1TTFAT,    # total fat
    DIQ010,      # diabetes diagnosis
    MCQ160C,     # coronary heart disease
    BPQ020,      # hypertension
    SXQ292,      # number of sexual partners
    SXQ294,      # condom use
    DUQ250       # injection drug use
  )

# Export as CSV
write_csv(nhanes_analytic, "nhanes_analytic.csv")

# Export to SAS
write_xpt(nhanes_analytic, "nhanes_analytic.sas7bdat")
