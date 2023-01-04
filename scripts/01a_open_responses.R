# INFO -------------------------------------------------------------------------
# File name: 	          01a_open_responses.R	      
# Creation date:        08/02/2022
# Last modified date:   08/08/2022
# Author:          		  Erick F Molina
# Modifications:        None
# Inputs:           
#	Outputs:        
#                       
#	                      
# Purpose:              Produce a dataset of open responses to be classified
#                       and recoded
#	                       

# 0. LOAD PACKAGES AND FUNCTIONS -----------------------------------------------
library(here)
library(haven)
library(tidyr)
library(dplyr)
library(lubridate)
library(readr)

# Functions
source(file = here("scripts", "programs", "empty_as_na.R"))

# 1. READ IN SURVEY DATA -------------------------------------------------------
surveyraw <- read_dta(here("data", "fta_mexico_clean_nopii.dta"), encoding = "UTF-8")

# 2. DATA MANIPULATION ---------------------------------------------------------

# Keep just open responses and survey identifiers
open_questions <- surveyraw |>
  mutate(submission_date = ymd(surveydate)) |>
  select(
    surveyid,
    submission_date,
    reason_replaced_pos,
    reason_many_pos,
    reason_one_pos_used,
    num_cust_decr_reason,
    sales_decr_reason,
    profits_decr_reason,
    cust_fee_card_payment_reason,
    no_incr_prices_reason,
    no_min_amount_reason,
    min_amount_reason,
    vat_card_reason,
    vat_cash_reason,
    num_cust_wd_decr_reason,
    sales_wd_decr_reason,
    profits_wd_incr_reason,
    profits_wd_decr_reason,
    vat_reason_b,
    reason_replaced_pos_c,
    reason_many_pos_c,
    reason_one_pos_used_c,
    num_cust_decr_reason_c,
    sales_decr_reason_c,
    profits_decr_reason_c,
    cust_fee_card_payment_reason_c,
    no_incr_prices_reason_c,
    no_min_amount_reason_c,
    min_amount_reason_c,
    vat_card_reason_before_c,
    vat_cash_reason_before_c,
    vat_reason_c
  ) |> 
  mutate_all(list(empty_as_na)) |>
  mutate(submission_date = as_date(submission_date))

# Reshape
open_questions_long <- open_questions |>
  pivot_longer(cols = 3:length(open_questions)) |>
  filter(!is.na(value) 
    & value != "-777" 
    & value != "-888"
    & value != "--777"
    & value != "10"     # Surveyor's mistake
    & value != "5") |>  # Surveyor's mistake
  rename(question = name) |>
  arrange(question) 

# Date filtering: historical data (before this script)
open_questions_long_historical <- open_questions_long |>
  filter(submission_date <= ymd(20220806))

# Date filtering: renewable
open_questions_long_filtered <- open_questions_long |>
  mutate(category = "") |>
  filter(submission_date > ymd(20220806)) |> # Last update
  filter(submission_date <= ymd(today()))

# 3. SAVE ----------------------------------------------------------------------
open_questions_long_historical |> saveRDS(here("proc", "open_questions_2022-08-06.rds"))
open_questions_long_filtered |> write.csv(here("proc", paste0("open_questions_", today(), ".csv")))



