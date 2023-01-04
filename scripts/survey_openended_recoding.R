# INFO -------------------------------------------------------------------------
# File name: 	          01_survey_recoding.R	      
# Creation date:        08/02/2022
# Last modified date:   11/28/2022
# Author:          		  Erick F Molina
# Modifications:        Added one-hot encoding for new categories
# Inputs:           
#	Outputs:        
#                       
#	                      
# Purpose:              Recode some questions to interpret data
#	                       

# 0. LOAD PACKAGES -------------------------------------------------------------

# Packages
library(here)
library(haven)
library(stringr)
library(dplyr)
library(tidyr)
library(magrittr)
library(lubridate)
library(readxl)
library(data.table)
library(mltools)

# 1. READ IN SURVEY DATA -------------------------------------------------------
surveyraw <- read_dta(here("data", "fta_mexico_clean_nopii.dta"), encoding = "UTF-8")
open_questions <- read_excel(here("data", "open_responses_categorized_accepted.xlsx")) |> as_tibble()

# 2. RECODE MUNICIPALITIES -----------------------------------------------------

# Recode encoding mistakes
survey <- surveyraw |>
  rename(nom_mun = municipality) |>
  mutate(nom_mun = replace(
    nom_mun, str_detect(nom_mun, "Tepej"), "Tepeji del Río de Ocampo")) |>
  mutate(nom_mun = replace(
    nom_mun, str_detect(nom_mun, "Encarnacion"), "Encarnación de Díaz")) |>
  mutate(nom_mun = replace(
    nom_mun, str_detect(nom_mun, "Petatlan"), "Petatlán")) |>
  mutate(nom_mun = replace(
    nom_mun, str_detect(nom_mun, "San And"), "San Andrés Cholula")) |>
  mutate(nom_mun = replace(
    nom_mun, str_detect(nom_mun, "mac"), "Tecámac")) |>
  mutate(nom_mun = replace(
    nom_mun, str_detect(nom_mun, "Tecpan de"), "Técpan de Galeana")) |>
  mutate(nom_mun = replace(
    nom_mun, str_detect(nom_mun, "Xonac"), "Xonacatlán")) 

# 3. RECODE DATES --------------------------------------------------------------
survey %<>% 
  mutate(submissiondate = ymd_hms(submissiondate),
         starttime = ymd_hms(starttime),
         endtime = ymd_hms(endtime),
         submission_date = ymd(surveydate)) 

# 4. RECODE OPEN QUESIONS ------------------------------------------------------

# Reshape wide to get a dataset at a surveyid level and clean columns
open_questions %<>% 
  select(-c("author", "obs", "value")) %>% 
  rename(
    new = category,
    label = category_name
  ) %>%
  mutate(new = case_when(
    new == "-111" ~ "-666",
    TRUE ~ new
  )) %>%
  pivot_wider(names_from = "question", values_from = c("new", "label")) %>%
  rename_at(vars(starts_with("new_")),function(x) paste0(x,"_new")) %>%
  rename_all(~stringr::str_replace(.,"^new_","")) %>%
  rename_at(vars(starts_with("label_")),function(x) paste0(x,"_lab")) %>%
  rename_all(~stringr::str_replace(.,"^label_","")) %>% 
  relocate(sort(names(.))) %>%
  relocate(c(surveyid, submission_date)) %>%
  mutate(surveyid = as.character(surveyid))

# Spread answers
open_questions_numbers <- open_questions |>
  select(surveyid, ends_with("new")) |>
  mutate_all(as.factor) |>
  mutate(surveyid = as.character(surveyid))
open_questions_numbers_expanded <- one_hot(as.data.table(open_questions_numbers))

# Clean one-hot encoding mistakes
open_questions_numbers_expanded  %<>%
  mutate(no_incr_prices_reason_c_new_3 = ifelse(
    `no_incr_prices_reason_c_new_3 6` == 1, 1, no_incr_prices_reason_c_new_3)) %>%
  mutate(no_incr_prices_reason_c_new_6 = NA) %>%
  mutate(no_incr_prices_reason_c_new_6 = case_when(
    `no_incr_prices_reason_c_new_3 6` == 1 ~ 1,
    `no_incr_prices_reason_c_new_3 6` == 0 ~ 0,
    TRUE ~ NA_real_)) %>%
  mutate(no_incr_prices_reason_new_2 = ifelse(
    `no_incr_prices_reason_new_2 11` == 1, 1, no_incr_prices_reason_new_2)) %>%
  mutate(no_incr_prices_reason_new_11 = ifelse(
    `no_incr_prices_reason_new_2 11` == 1, 1, no_incr_prices_reason_new_11)) %>%
  mutate(no_incr_prices_reason_c_new_4 = ifelse(
    `no_incr_prices_reason_c_new_4 10` == 1, 1, no_incr_prices_reason_c_new_4)) %>%
  mutate(no_incr_prices_reason_c_new_10 = ifelse(
    `no_incr_prices_reason_c_new_4 10` == 1, 1, no_incr_prices_reason_c_new_10)) %>%
  mutate(no_min_amount_reason_new_3 = ifelse(
    `no_min_amount_reason_new_3 5` == 1, 1, no_min_amount_reason_new_3)) %>%
  mutate(no_min_amount_reason_new_5 = ifelse(
    `no_min_amount_reason_new_3 5` == 1, 1, no_min_amount_reason_new_5)) %>%
  mutate(no_min_amount_reason_new_4 = ifelse(
    `no_min_amount_reason_new_4 6` == 1, 1, no_min_amount_reason_new_4)) %>%
  mutate(no_min_amount_reason_new_6 = ifelse(
    `no_min_amount_reason_new_4 6` == 1, 1, no_min_amount_reason_new_6)) %>%
  mutate(no_min_amount_reason_new_1 = ifelse(
    `no_min_amount_reason_new_1 3` == 1, 1, no_min_amount_reason_new_1)) %>%
  mutate(no_min_amount_reason_new_3 = ifelse(
    `no_min_amount_reason_new_1 3` == 1, 1, no_min_amount_reason_new_3)) %>%
  mutate(num_cust_wd_decr_reason_new_1 = ifelse(
    `num_cust_wd_decr_reason_new_1 2` == 1, 1, num_cust_wd_decr_reason_new_1)) %>%
  mutate(num_cust_wd_decr_reason_new_2 = ifelse(
    `num_cust_wd_decr_reason_new_1 2` == 1, 1, num_cust_wd_decr_reason_new_2)) %>%
  mutate(num_cust_wd_decr_reason_new_1 = ifelse(
    `num_cust_wd_decr_reason_new_4 1` == 1, 1, num_cust_wd_decr_reason_new_1)) %>%
  mutate(num_cust_wd_decr_reason_new_4 = ifelse(
    `num_cust_wd_decr_reason_new_4 1` == 1, 1, num_cust_wd_decr_reason_new_4)) %>%
  mutate(profits_decr_reason_c_new_1 = ifelse(
    `profits_decr_reason_c_new_1 3` == 1, 1, profits_decr_reason_c_new_1)) %>%
  mutate(profits_decr_reason_c_new_3 = NA) %>%
  mutate(profits_decr_reason_c_new_3 = case_when(
    `profits_decr_reason_c_new_1 3` == 1 ~ 1,
    `profits_decr_reason_c_new_1 3` == 0 ~ 0,
    TRUE ~ NA_real_)) %>%
  mutate(profits_wd_decr_reason_new_1 = ifelse(
    `profits_wd_decr_reason_new_1 2` == 1, 1, profits_wd_decr_reason_new_1)) %>%
  mutate(profits_wd_decr_reason_new_2 = ifelse(
    `profits_wd_decr_reason_new_1 2` == 1, 1, profits_wd_decr_reason_new_2)) %>%
  mutate(profits_wd_incr_reason_new_1 = ifelse(
    `profits_wd_incr_reason_new_1 2` == 1, 1, profits_wd_incr_reason_new_1)) %>%
  mutate(profits_wd_incr_reason_new_2 = ifelse(
    `profits_wd_incr_reason_new_1 2` == 1, 1, profits_wd_incr_reason_new_2)) %>%
  mutate(profits_wd_incr_reason_new_1 = ifelse(
    `profits_wd_incr_reason_new_1 4` == 1, 1, profits_wd_incr_reason_new_1)) %>%
  mutate(profits_wd_incr_reason_new_4 = ifelse(
    `profits_wd_incr_reason_new_1 4` == 1, 1, profits_wd_incr_reason_new_4)) %>%
  mutate(profits_wd_incr_reason_new_1 = ifelse(
    `profits_wd_incr_reason_new_1 7` == 1, 1, profits_wd_incr_reason_new_1)) %>%
  mutate(profits_wd_incr_reason_new_7 = ifelse(
    `profits_wd_incr_reason_new_1 7` == 1, 1, profits_wd_incr_reason_new_7)) %>%
  mutate(profits_wd_incr_reason_new_1 = ifelse(
    `profits_wd_incr_reason_new_1 10` == 1, 1, profits_wd_incr_reason_new_1)) %>%
  mutate(profits_wd_incr_reason_new_10 = ifelse(
    `profits_wd_incr_reason_new_1 10` == 1, 1, profits_wd_incr_reason_new_10)) %>%
  mutate(profits_wd_incr_reason_new_2 = ifelse(
    `profits_wd_incr_reason_new_2 10` == 1, 1, profits_wd_incr_reason_new_2)) %>%
  mutate(profits_wd_incr_reason_new_10 = ifelse(
    `profits_wd_incr_reason_new_2 10` == 1, 1, profits_wd_incr_reason_new_10)) %>%
  mutate(profits_wd_incr_reason_new_3 = ifelse(
    `profits_wd_incr_reason_new_3 4` == 1, 1, profits_wd_incr_reason_new_3)) %>%
  mutate(profits_wd_incr_reason_new_4 = ifelse(
    `profits_wd_incr_reason_new_3 4` == 1, 1, profits_wd_incr_reason_new_4)) %>%
  mutate(reason_many_pos_new_1 = ifelse(
    `reason_many_pos_new_1 2` == 1, 1, reason_many_pos_new_1)) %>%
  mutate(reason_many_pos_new_2 = ifelse(
    `reason_many_pos_new_1 2` == 1, 1, reason_many_pos_new_2)) %>%
  mutate(reason_replaced_pos_new_1 = ifelse(
    `reason_replaced_pos_new_1 2` == 1, 1, reason_replaced_pos_new_1)) %>%
  mutate(reason_replaced_pos_new_2 = ifelse(
    `reason_replaced_pos_new_1 2` == 1, 1, reason_replaced_pos_new_2)) %>%
  mutate(sales_wd_decr_reason_new_1 = ifelse(
    `sales_wd_decr_reason_new_1 2` == 1, 1, sales_wd_decr_reason_new_1)) %>%
  mutate(sales_wd_decr_reason_new_2 = ifelse(
    `sales_wd_decr_reason_new_1 2` == 1, 1, sales_wd_decr_reason_new_2))
  
# Drop irrelevant columns
open_questions_numbers_expanded %<>%
  select(-c(
    `no_incr_prices_reason_c_new_3 6`,
    `no_incr_prices_reason_new_2 11`,
    `no_incr_prices_reason_c_new_4 10`,
    `no_min_amount_reason_new_3 5`,
    `no_min_amount_reason_new_4 6`,
    `no_min_amount_reason_new_1 3`,
    `num_cust_wd_decr_reason_new_1 2`,
    `num_cust_wd_decr_reason_new_4 1`,
    `profits_decr_reason_c_new_1 3`,
    `profits_wd_decr_reason_new_1 2`,
    `profits_wd_incr_reason_new_1 2`,
    `profits_wd_incr_reason_new_1 4`,
    `profits_wd_incr_reason_new_1 7`,
    `profits_wd_incr_reason_new_1 10`,
    `profits_wd_incr_reason_new_2 10`,
    `profits_wd_incr_reason_new_3 4`,
    `reason_many_pos_new_1 2`,
    `reason_replaced_pos_new_1 2`,
    `sales_wd_decr_reason_new_1 2`
  ))

# Join with original open-questions dataset
open_questions_clean <- open_questions |>
  left_join(open_questions_numbers_expanded, by = "surveyid")

# Order
open_questions_clean %<>% 
  relocate(sort(names(.))) %>%
  relocate(c(surveyid, submission_date))

# Join with survey
survey %<>% 
  left_join(open_questions_clean, by = c("surveyid", "submission_date")) %>%
  select(-submission_date)


# 5. SAVE ----------------------------------------------------------------------
survey |> saveRDS(here("proc", "fta_mexico_recoded.rds"))


