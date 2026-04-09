# Olivia Williamson, Andres Davila
# 2026-04-08

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
components <- c("HIV", "DEMO", "INQ", "HIQ", "DUQ", "SXQ", "MCQ", "HUQ")

# Build NHANES URL
build_nhanes_url <- function(component, cycle) {
  start_year <- start_year_map[[cycle]]
  
  # Special handling for SXQ
  # Public files appear as SXQ_G, SXQ_H, SXQ_I
  # 2017-2018 is not a standard public SXQ_J.xpt
  if (component == "SXQ") {
    file_stub <- paste0("SXQ_", cycle)
  } else {
    file_stub <- paste0(component, "_", cycle)
  }
  
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
  file_url <- build_nhanes_url(component, cycle)
  
  out <- tryCatch(
    {
      message("Reading: ", file_url)
      
      read_xpt(file_url) %>%
        mutate(
          cycle_code = cycle,
          cycle = cycle_year_map[[cycle]]
        )
    },
    error = function(e) {
      warning("Skipping file: ", file_url)
      NULL
    }
  )
  
  out
}

# Stack one component across cycles
stack_component <- function(component, cycles) {
  map(cycles, ~ read_nhanes_url(component, .x)) %>%
    compact() %>%
    bind_rows()
}

# Download/read all components
nhanes_list <- map(components, ~ stack_component(.x, cycles))
# 2017-18 cycle does not have SXQ component
names(nhanes_list) <- components

# Merge
nhanes_merged <- nhanes_list$DEMO %>%
  left_join(nhanes_list$HIV, by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$INQ, by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$HIQ, by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$DUQ, by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$SXQ, by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$MCQ, by = c("SEQN", "cycle_code", "cycle")) %>%
  left_join(nhanes_list$HUQ, by = c("SEQN", "cycle_code", "cycle"))

glimpse(nhanes_merged)

# Sanity Check
nrow(nhanes_merged) == nrow(nhanes_list$DEMO) #Should be TRUE

nhanes_merged %>%
  count(SEQN, cycle_code) %>%
  filter(n > 1) #Should be 0

nhanes_merged %>%
  count(cycle)
nhanes_list$DEMO %>%
  count(cycle) #Should match 

# Non-missingness for variables
nhanes_merged %>%
  summarise(
    hiv_status  = sum(!is.na(LBXHIVC)),
    age = sum(!is.na(RIDAGEYR)),
    race  = sum(!is.na(RIDRETH1)),
    ethnicity  = sum(!is.na(RIDRETH3)),
    sex  = sum(!is.na(RIAGENDR)),
    education_level  = sum(!is.na(DMDEDUC2)),
    poverty_ratio  = sum(!is.na(INDFMPIR)),
    injection_drug_use  = sum(!is.na(DUQ250)),
    condom_use = sum(!is.na(SXQ294))
  )
