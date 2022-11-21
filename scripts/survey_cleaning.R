# INFO -------------------------------------------------------------------------
# File name: 	          05_survey_cleaning.R	      
# Creation date:        06/15/2022
# Last modified date:   07/26/2022
# Author:          		  Erick F Molina
# Modifications:        None
# Inputs:           
#	Outputs:        
#                       
#	                      
# Purpose:              Prepare the data to be used for the survey report 
#	                       

# 0. LOAD PACKAGES AND FUNCTIONS -----------------------------------------------

# Packages
library(here)
library(haven)
library(tidyr)
library(dplyr)
library(magrittr)
library(data.table)
library(readxl)
library(lubridate)
library(assertthat)
library(readr)

# 1. SURVEY --------------------------------------------------------------------

# Read in data
survey <- read_dta(here("dtafiles", "data_collection", "fta_mexico_prepped.dta"))
survey_code <- read_excel(here("xlsx", "20220824_pos_survey.xlsx")) %>% as_tibble()

# Add case (A, B, C) identifier
survey <- survey %>% 
  mutate(section = ifelse(has_pos == 1,"A",
    ifelse(has_had_pos == 1 & has_pos == 0, "C", 
    ifelse(has_pos == 0 & has_had_pos == 0, "B", NA))
    )
  )

# Basic cleaning
surveyraw <- survey
survey <- surveyraw %>% 
  as_tibble() %>%
  mutate(submission_date = ymd(surveydate)) %>%
  filter(submission_date >= ymd(20220620)) %>% # Start of survey
  filter(!is.na(successful)) 
  
# Check for duplicate keys 
assert_that(survey %>% nrow() == length(unique(survey$key)))

# Create long version on survey results and apply some caps
excluded_columns <- length(survey) - 21
survey_long <- survey %>%
  select(text_audit, key, municipality, zip_code, 33:all_of(excluded_columns)) %>% 
  mutate_all(as.character) %>% 
  pivot_longer(cols = 13:636) %>% # Length of survey_long
  left_join(survey_code %>% select(name, label), "name") %>%
  mutate(TA_filename = gsub("TA_|.csv", "", basename(text_audit))) %>%
  select(!text_audit) %>%
  rename("field_name" = "name") 

# Convert -666, -777, -888 to -6, -7, and -8 respectively
survey_long %<>% 
  mutate(value = if_else(value == "-666", "-10", value), 
         value = if_else(value == "-777", "-7", value), 
         value = if_else(value == "-888", "-8", value)
  )

# 2. TA FILES ------------------------------------------------------------------

# Look if a corrupted file exists and erase it, before listing files
corrupt_file <- "TA_a4039a66-d50a-44a3-bfc5-77d3827d889c.csv"
if (file.exists(here("rawdata", "survey", "media", corrupt_file))) {
  file.remove(here("rawdata", "survey", "media", corrupt_file))
} else {
  print("This file does not exist, there is no problem")
}

# Read in data
files <- list.files(here("rawdata", "survey", "media"), full.names = T, pattern = "^TA")
TA_files <- lapply(files, fread)

# Clean names
names(TA_files) <- gsub("TA_|.csv", "", basename(files)) # make uuid name of each TA file

# Bind files
TA_files <- rbindlist(TA_files, id = "TA_filename")

TA_files %<>% 
  rename(c("field_name" = `Field name`, 
           "duration" = "Total duration (seconds)", 
           "first_appeared" = "First appeared (seconds into survey)")) %>%
  mutate(field_name = basename(field_name)) %>%
  mutate(key = paste0("uuid:", TA_filename))  %>% 
  left_join(surveyraw %>% select(surveyor_name, section, successful, key), by = "key")

# Save all TA file data (before we apply filter)
TA_files %>% write_csv(here("proc", "TA_results_nofilter_checked.csv"))

# Get only the data for which we have survey results
TA_files %<>%
  filter(TA_filename %in% gsub("uuid:", "", survey$key))

# Sanity check: 
assert_that(length(unique(TA_files$TA_filename)) == nrow(survey))

# 3. LONG-SURVEY FORMAT ---------------------------------------------------------

# Join in TA file identifying info to long survey 
survey_long %<>%
  left_join(TA_files, by = c("field_name", "TA_filename", "key")) %>%
  group_by(TA_filename) %>%
  fill(key, surveyor_name, section, successful, .direction = "down") %>%
  fill(key, surveyor_name, section, successful, .direction = "up") 

# Quick checks
dat <- survey_long %>% group_by(TA_filename) %>% summarise(key = length(unique(key)), surveyor_name = length(unique(surveyor_name)))
assert_that(all(dat$key == 1) == T)
assert_that(all(dat$surveyor_name == 1) == T)
assert_that(survey_long %>% filter(is.na(surveyor_name)) %>% nrow() == 0)

# We want to recode missing values. If NA, keep as NA. If -666, code as Other. If -777, code as "Don't know". If -888, "Refuse to respond". 
survey_long %<>%
  mutate(value_missing = case_when(
    value == "-10"   ~ "other",
    value == "-7"    ~ "don't know", 
    value == "-8"    ~ "refuse to respond",
    is.na(value)     ~ "NA", 
    value != "-10" & value != "-7" & value != "-8" & !is.na(value) ~ value
  ) 
  ) %>%
  mutate(value_missing = ifelse(value_missing != "NA", value_missing, NA))  %>%
  select(key, field_name, value, value_missing, label, duration, first_appeared, TA_filename, surveyor_name)

# Save
survey %>% write_csv(here("proc", "survey_results_checked.csv"))
survey_long %>% write_csv(here("proc", "survey_long_results_checked.csv"))
TA_files %>% write_csv(here("proc", "TA_results_checked.csv"))

