# INFO -------------------------------------------------------------------------
# File name: 	          14_other_questions.R	      
# Creation date:        08/03/2022
# Last modified date:   08/03/2022
# Author:          		  Anahí Reyes Miguel
# Modifications:        None 
# Inputs:           
#	Outputs:        
#                       
#	                      
# Purpose:              Produce a dataset with the other responses in a longer format.
#	                       

# 0. LOAD PACKAGES AND FUNCTIONS -----------------------------------------------

# PACKAGES
library(here)
library(openxlsx)
library(haven)
library(dplyr)
library(tidyr)
library(magrittr)

# Functions


# 1. DATA ----------------------------------------------------------------------

# Read in data
survey <- read_dta(here::here("dtafiles", "data_collection", "fta_mexico_prepped.dta"))

# 2. DATA MANIPULATION ---------------------------------------------------------

survey %<>% 
  mutate_all(as.character()) %>% 
  mutate_if(is.character, list(~na_if(.,""))) 

# Filter successful surveys and select the other questions
other_questions <- survey %>%
  filter(successful == 1) %>%
  select(surveyid, key, surveydate, 
    advantages_pos_other,
    advantages_pos_other_b,
    advantages_pos_other_c,
    disadvantages_pos_other,
    disadvantages_pos_other_b,
    disadvantages_pos_other_c,
    pos_firm_per_of_payment_other_1,
    reason_of_adoption_other_c,
    pos_firm_other_2,
    pos_firm_per_of_payment_b_other,
    pos_firm_other_replaced,
    reason_of_adoption_other,
    pos_firm_other_1,
    pos_firm_other_c_1,
    pos_firm_other_replaced_c,
    reason_of_canceling_other,
    surveyor_name
  ) 

# Return NAs
na_count <- sapply(other_questions, function(y) sum(length(which(is.na(y)))))
na_count <- data.frame(na_count)
 
# All observations as character   
other_questions$surveyid <- as.character(other_questions$surveyid)

# Longer format of the other questions and removing NAs
other_questions_wide <- other_questions %>% 
  pivot_longer(cols = !c("surveyid", "key", "surveydate", "surveyor_name"), names_to = "question",
               values_to = "response", values_drop_na = TRUE) %>% 
  arrange(question)


# 3. SAVE ---------------------------------------------------------------------

#write.xlsx(other_last_day, here("proc", paste0(today(), "_other_to_monitor.xlsx")), sheetName = "All")
write.xlsx(open_questions_wide_proposal, here("proc", "other_questions.xlsx"), sheetName = "Proposal", append = TRUE)


