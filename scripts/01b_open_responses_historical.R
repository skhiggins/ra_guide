# INFO -------------------------------------------------------------------------
# File name: 	          01b_open_responses_historical.R	      
# Creation date:        08/02/2022
# Last modified date:   08/08/2022
# Author:          		  Erick F Molina
# Modifications:        None
# Inputs:           
#	Outputs:        
#                       
#	                      
# Purpose:              Merge categorized historical open responses with new
#                       data
#	                       

# 0. LOAD PACKAGES AND FUNCTIONS -----------------------------------------------
library(here)
library(tidyr)
library(dplyr)
library(readr)
library(readxl)
library(magrittr)

# Functions
source(file = here("scripts", "programs", "empty_as_na.R"))

# 1. READ IN SURVEY DATA -------------------------------------------------------
open_questions_long_historical <- readRDS(here("proc","open_questions_2022-08-06.rds")) |>
  mutate(surveyid = as.character(surveyid))
open_questions_categorized <- read_excel(here("data", "open_responses_categorized.xlsx")) |> as_tibble() |>
  mutate(surveyid = as.character(surveyid))

# 2. MANIPULATE DATA -----------------------------------------------------------

# Merge data
open_questions_long_historical %<>% 
  left_join(open_questions_categorized |> select(-answer), by = c("surveyid", "key", "question", "submission_date")) |>
  arrange(question)

# 3. SAVE ----------------------------------------------------------------------
open_questions_long_historical |> write.csv(here("proc", "open_questions_historical_categorized.csv"))



