#load in packages
library(dplyr)
library(readr)

#read in entire dataset created in create_data_for_app script
retention_data <- read_rds("Data/data_for_retention_grids.rds")
data_leavers <- read_rds("Data/data_leavers.rds")
data_entrants <- read_rds("Data/data_entrants.rds")

# Lookups
nqt_year_title_lookup <- read_csv("Data/nqt_year_title_lookup.csv")


