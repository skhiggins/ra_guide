# INFO -------------------------------------------------------------------------
# File name: 	          06_survey_report.R	      
# Creation date:        06/24/2022
# Last modified date:   08/02/2022
# Author:          		  Erick F Molina
# Modifications:        
# Inputs:           
#	Outputs:        
#                       
#	                      
# Purpose:              Produce figures and tables for the survey report 
#	                       

# 0. LOAD PACKAGES AND FUNCTIONS -----------------------------------------------

# PACKAGES
library(dplyr)
library(here)
library(purrr)
library(lubridate)
library(xtable)
library(ggplot2)
library(tidyr)
library(stringr)

# FUNCTIONS
source(file = here("scripts", "programs", "myfunctions.R"))
source(file = here("scripts", "programs", "set_theme.R"))

# Empty_as_na: Sets blanks to NAs
empty_as_na <- function(x){
  ifelse(as.character(x)!="", x, NA)
}

# 1. DATA ----------------------------------------------------------------------

# Read in data
survey <- read.csv(here("proc", "survey_results_checked.csv"), encoding = "UTF-8") %>%
  mutate_all(list(empty_as_na)) 
survey_long <- read.csv(here("proc", "survey_long_results_checked.csv"), encoding = "UTF-8")
TA_files <- read.csv(here("proc", "TA_results_checked.csv"), encoding = "UTF-8")

results <- survey_long %>% filter(!is.na(value))

missings <- results %>%
  filter(value == "-7" | value == "-8")

missing_answers <- tribble(
  ~"value", ~"n",
  "Respondió", 0,
  "No sabe", 0,
  "No quiso responder", 0
)

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# 2. TEXT AUDIT DATA -----------------------------------------------------------

# Table 1: Average time of successful surveys
table_1 <- TA_files %>% 
  filter(successful == 1) %>%
  filter(field_name == "comments") %>% # Originally using "successful", but one observation is weird
  group_by(field_name) %>% 
  summarise(average_first_appeared = mean(first_appeared), 
            n = n())
table_1 <- xtable(table_1)
print(table_1, file = here("results", "tables", "table_1.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# Table 2: Average time of successful surveys per enumerator
table_2 <- TA_files %>% 
  filter(successful == 1) %>%
  filter(field_name == "comments")  %>% # Originally using "successful", but one observation is weird
  group_by(field_name, surveyor_name) %>% 
  summarise(average_first_appeared = mean(first_appeared), 
            n = n()) 
table_2 <- xtable(table_2)
print(table_2, file = here("results", "tables", "table_2.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# Table 3: Average time of successful surveys
table_3 <- TA_files %>% 
  filter(successful == 1) %>%
  filter(field_name == "comments") %>% # Originally using "successful", but one observation is weird
  group_by(field_name, section) %>% 
  summarise(average_first_appeared = mean(first_appeared), 
            n = n()) 
table_3 <- xtable(table_3)
print(table_3, file = here("results", "tables", "table_3.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# Table 4: Average time of successful surveys by enumerator 
table_4 <- TA_files %>% 
  filter(successful == 1) %>%
  filter(field_name == "comments") %>% # Originally using "successful", but one observation is weird
  group_by(field_name, section, surveyor_name) %>% 
  summarise(average_first_appeared = mean(first_appeared), 
            n = n())
table_4 <- xtable(table_4)
print(table_4, file = here("results", "tables", "table_4.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# We now want to see incomplete surveys. 

# Table 5: Incomplete surveys
# table_5 <- TA_files %>%
#   filter(successful == 3 & !is.na(section)) # %>% # Apply this filter to select real incomplete surveys
#   group_by(TA_filename, surveyor_name) %>%
#   summarise(max_first_appeared = max(first_appeared),
#             n = n())
# table_5 <- xtable(table_5)
# print(table_5, file = here("results", "tables", "table_5.tex"), floating = F,
#       latex.environments = NULL, booktabs = T, include.rownames = F)

# 3. RESPONSE RATE STATISTICS ----------------------------------------------------

# Create data frame
response_rate <- survey %>%
  mutate(successful = if_else(successful != 1, 0, 1)) 

# Table 6: Overall response rate
table_6 <- response_rate %>%
  filter(!is.na(surveyor_name)) %>%
  summarise(successful = sum(successful), 
            n = n(), 
            response_rate = round(successful/n, digits = 4))
table_6 <- xtable(table_6)
print(table_6, file = here("results", "tables", "table_6.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# Table 7: Response rate by enumerator
table_7 <- response_rate %>%
  filter(!is.na(surveyor_name)) %>%
  group_by(surveyor_name) %>%
  summarise(successful = sum(successful), 
            n = n(), 
            response_rate = round(successful/n, digits = 4))
table_7 <- xtable(table_7)
print(table_7, file = here("results", "tables", "table_7.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# Table 8: Response rate by hour of the day

table_8 <- response_rate %>%
  mutate(hour_of_day = hour(ymd_hms(gsub(",", "", starttime)))) %>%
  group_by(hour_of_day) %>%
  summarise(successful = sum(successful), 
            n = n(),
            response_rate = round(successful/n, digits = 4))
table_8 <- xtable(table_8)
print(table_8, file = here("results", "tables", "table_8.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)


# 4. UNSUCCESFUL SURVEYS --------------------------------------------------------

# Filter just unsuccessfulls
unsuccessfuls <- survey %>%
  filter(successful != 1)

# Table 67: Reasons for surveys to be unsuccessful
table_67 <- unsuccessfuls %>%
  filter(!is.na(successful)) %>%
  mutate(successful = case_when(
    successful == "2" ~ "Rechazo total",
    successful == "3" ~ "Rechazo parcial",
    successful == "4" ~ "Negocio no localizado",
    successful == "5" ~ "Negocio no elegible",
    successful == "6" ~ "Volver a visitar",
    successful == "7" ~ "Cerrado al momento de la visita",
    successful == "8" ~ "No existe/cerrado permanentemente",
    successful == "9" ~ "Dueño no localizado sin horario de regreso",
    successful == "10" ~ "Negocio localizado sin alguien atendiendo",
    successful == "11" ~ "Negocio en fraccionamiento privado"
  )) %>%
  mutate(N_ = n()) %>%
  group_by(successful) %>%
  summarise(n = n(), 
            Percent =  round(n/max(N_), digits = 4))
table_67 <- xtable(table_67)
print(table_67, file = here("results", "tables", "table_67.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# 5. SURVEYOR PRODUCTIVITY ------------------------------------------------------

# Table 9: Hours spent on surveys
table_9 <- survey %>% 
  filter(!is.na(surveyor_name)) %>%
  select(surveyor_name, duration) %>%
  group_by(surveyor_name)  %>%
  summarise("Hours Spent on Surveys (duration)" = sum(duration)/3600) %>%
  bind_rows(ungroup(.) %>% summarise(surveyor_name = "Total",
  "Hours Spent on Surveys (duration)" = sum(`Hours Spent on Surveys (duration)`)
  ))
table_9 <- xtable(table_9)
print(table_9, file = here("results", "tables", "table_9.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# Table 10: Days spent surveying
table_10 <- survey %>%
  mutate(date = ymd(submission_date)) %>%
  mutate(day = ymd(gsub(" .*$", "", date))) %>%
  summarise("Unique Days spent surveying" = length(unique(day)))
table_10 <- xtable(table_10)
print(table_10, file = here("results", "tables", "table_10.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# Table 11: Surveys per hour attempted per enumerator
table_11 <- survey %>% 
  filter(!is.na(surveyor_name)) %>%
  group_by(surveyor_name)  %>%
  summarise("Hours Spent on Surveys" = sum(duration)/3600, 
            "Surveys attempted" = length(unique(text_audit)), 
            "Surveys attempted per hour"  = `Surveys attempted`/`Hours Spent on Surveys` )
table_11 <- xtable(table_11)
print(table_11, file = here("results", "tables", "table_11.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# Table 12: Completed surveys per day
table_12 <- survey %>% 
  filter(successful == 1) %>%
  group_by(surveyor_name) %>% 
  summarise("Completed surveys" = n(), 
            "Days surveying" = length(unique(submission_date)), 
            "Surveys per day" = `Completed surveys`/`Days surveying`) 
table_12 <- xtable(table_12)
print(table_12, file = here("results", "tables", "table_12.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# 6. CONSENT QUESTIONS -------------------------------------------------------

# Choose only successful surveys
successfuls <- survey %>% 
  filter(successful == 1)

# Table 13: Authorized to be recorded
table_13 <- successfuls %>%
  summarise("Authorized recording" = sum(authorize_recording),
            "Successful surveys" = n(),
            "Rate" = round(`Authorized recording`/`Successful surveys`, digits = 4) )
table_13 <- xtable(table_13)
print(table_13, file = here("results", "tables", "table_13.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# Table 13a: Authorized to be recorded per enumerator
table_13a <- successfuls %>%
  group_by(surveyor_name)  %>%
  summarise("Authorized recording" = sum(authorize_recording),
            "Successful surveys" = n(),
            "Rate" = round(`Authorized recording`/`Successful surveys`, digits = 4) )
table_13a <- xtable(table_13a)
print(table_13a, file = here("results", "tables", "table_13a.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# Table 14: Authorized follow-up survey
table_14 <- successfuls %>%
  summarise("Authorized follow-up" = sum(followup_surveys),
            "Successful surveys" = n(),
            "Rate" = round(`Authorized follow-up`/`Successful surveys`, digits = 4) )
table_14 <- xtable(table_14)
print(table_14, file = here("results", "tables", "table_14.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# Table 14a: Authorized follow-up survey per enumerator
table_14a <- successfuls %>%
  group_by(surveyor_name)  %>%
  summarise("Authorized follow-up" = sum(followup_surveys),
            "Successful surveys" = n(),
            "Rate" = round(`Authorized follow-up`/`Successful surveys`, digits = 4) )
table_14a <- xtable(table_14a)
print(table_14a, file = here("results", "tables", "table_14a.tex"), floating = F,
      latex.environments = NULL, booktabs = T, include.rownames = F)

# 7. SCREENING QUESTIONS -------------------------------------------------------

# FOR EACH QUESTION, I PRODUCE 2 GRAPHS: QUESTION AND DURATION

# Is owner there?
survey %>%
  select(is_owner_there) %>%
  filter(!is.na(is_owner_there)) %>%
  mutate(is_owner_there = case_when(
    is_owner_there == "1" ~ "Sí, y es quien atiende",
    is_owner_there == "0" ~ "No",
    is_owner_there == "2" ~ "Sí, pero no es quien atiende",
    is_owner_there == "-777" ~ "No sabe",
    is_owner_there == "-888" ~ "No quiso responder"
  )) %>%
  ggplot(aes(x = is_owner_there)) +
  geom_histogram(stat = "count") +
  theme_bw() +
  xlab("Is owner there") +
  set_theme() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
ggsave(here("results", "figures", "is_owner_there.jpg"))

# Is owner there? (successful)
successfuls %>%
  select(is_owner_there) %>%
  filter(!is.na(is_owner_there)) %>%
  mutate(is_owner_there = case_when(
    is_owner_there == "1" ~ "Sí, y es quien atiende",
    is_owner_there == "0" ~ "No",
    is_owner_there == "2" ~ "Sí, pero no es quien atiende",
    is_owner_there == "-777" ~ "No sabe",
    is_owner_there == "-888" ~ "No quiso responder"
  )) %>%
  ggplot(aes(x = is_owner_there)) +
  geom_histogram(stat = "count") +
  theme_bw() +
  xlab("Is owner there") +
  set_theme() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
ggsave(here("results", "figures", "is_owner_there_successfuls.jpg"))


# Power of decision
survey %>%
  select(power_of_decision) %>%
  filter(!is.na(power_of_decision)) %>%
  mutate(power_of_decision = case_when(
    power_of_decision == "1" ~ "Sí",
    power_of_decision == "0" ~ "No",
    power_of_decision == "2" ~ "Menor de edad",
    power_of_decision == "-777" ~ "No sabe",
    power_of_decision == "-888" ~ "No quiso responder"
  )) %>%
  ggplot(aes(x = power_of_decision)) +
  geom_histogram(stat = "count") +
  theme_bw() +
  xlab("Power of decision") +
  set_theme() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
ggsave(here("results", "figures", "power_of_decision.jpg"))

# Power of decision (successful)
successfuls %>%
  select(power_of_decision) %>%
  filter(!is.na(power_of_decision)) %>%
  mutate(power_of_decision = case_when(
    power_of_decision == "1" ~ "Sí",
    power_of_decision == "0" ~ "No",
    power_of_decision == "2" ~ "Menor de edad",
    power_of_decision == "-777" ~ "No sabe",
    power_of_decision == "-888" ~ "No quiso responder"
  )) %>%
  ggplot(aes(x = power_of_decision)) +
  geom_histogram(stat = "count") +
  theme_bw() +
  xlab("Power of decision") +
  set_theme() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
ggsave(here("results", "figures", "power_of_decision_successfuls.jpg"))

# date_owner_available_yesno
survey %>%
  select(date_owner_available_yesno) %>%
  filter(!is.na(date_owner_available_yesno)) %>%
  mutate(date_owner_available_yesno = case_when(
    date_owner_available_yesno == "1" ~ "Sí",
    date_owner_available_yesno == "0" ~ "No",
    date_owner_available_yesno == "-777" ~ "No sabe",
    date_owner_available_yesno == "-888" ~ "No quiso responder"
  )) %>%
  ggplot(aes(x = date_owner_available_yesno)) +
  geom_histogram(stat = "count") +
  theme_bw() +
  xlab("Is there a date in which owner is available?") +
  set_theme() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
ggsave(here("results", "figures", "date_owner_available_yesno.jpg"))


# 8. ALL RESULTS ---------------------------------------------------------------

# FOR EACH QUESTION, I PRODUCE 3 GRAPHS: QUESTION, DURATION AND MISSING ANSWERS

# Number of employees
results %>%
  filter(field_name == "employees_num") %>%
  filter(!is.na(value)) %>%
  select(field_name,label, value) %>%
  mutate(value = as.numeric(value)) %>%
  filter(value >= 0) %>%
  ggplot(aes(x = value)) +  
  geom_histogram() + 
  theme_bw() + 
  xlab("Number of Employees") +
  set_theme()
ggsave(here("results", "figures", "employees_num.jpg"))

results %>% 
  filter(field_name == "employees_num") %>%
  filter(!is.na(value)) %>%
  select(field_name,label, duration) %>%
  mutate(duration = as.numeric(duration))  %>%
  ggplot(aes(x = duration)) +  
  geom_histogram() + 
  theme_bw() + 
  xlab("Duration (seconds)")   + 
  set_theme()
ggsave(here("results", "figures", "employees_num_.jpg"))

results %>%
  filter(field_name == "employees_num") %>%
  filter(!is.na(value)) %>%
  select(field_name,label, value) %>%
  mutate(value = case_when(
    value != "-7" & value != "-8" ~ "Respondió",
    value == "-7" ~ "No sabe",
    value == "-8" ~ "No quiso responder"
  )) %>%
  count(value) %>%
  rbind(missing_answers) %>%
  group_by(value) %>% 
  summarise(n = sum(n)) %>% 
  mutate(prop = n/sum(n)) %>%
  ggplot(aes(x = value,y = n)) + 
  geom_col()  +
  geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
  theme_bw() +
  xlab("Answers") +
  set_theme() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
ggsave(here("results", "figures", "employees_num_m.jpg"))

# Has POS
results %>%
  filter(field_name == "has_pos") %>%
  filter(!is.na(value)) %>%
  select(field_name,label, value) %>%
  mutate(value = case_when(
    field_name == "has_pos" & value == "1" ~ "Sí",
    field_name == "has_pos" & value == "0" ~ "No"
  )) %>%
  filter(!is.na(value)) %>%
  ggplot(aes(x = value)) +
  geom_histogram(stat = "count") +
  theme_bw() +
  xlab("Has POS now") +
  set_theme() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
ggsave(here("results", "figures", "has_pos.jpg"))

results %>%
  filter(field_name == "has_pos") %>%
  filter(!is.na(value)) %>%
  select(field_name,label, duration) %>%
  mutate(duration = as.numeric(duration))  %>%
  ggplot(aes(x = duration)) +
  geom_histogram() +
  theme_bw() +
  xlab("Duration (seconds)")   +
  set_theme()
ggsave(here("results", "figures", "has_pos_.jpg"))

results %>%
  filter(field_name == "has_pos") %>%
  filter(!is.na(value)) %>%
  select(field_name,label, value) %>%
  mutate(value = case_when(
    value != "-7" & value != "-8" ~ "Respondió",
    value == "-7" ~ "No sabe",
    value == "-8" ~ "No quiso responder"
  )) %>%
  count(value) %>%
  rbind(missing_answers) %>%
  group_by(value) %>% 
  summarise(n = sum(n)) %>% 
  mutate(prop = n/sum(n)) %>%
  ggplot(aes(x = value,y = n)) + 
  geom_col()  +
  geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
  theme_bw() +
  xlab("Answers") +
  set_theme() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
ggsave(here("results", "figures", "has_pos_m.jpg"))


# Has had POS
results %>%
  filter(field_name == "has_had_pos") %>%
  filter(!is.na(value)) %>%
  select(field_name,label, value) %>%
  mutate(value = case_when(
    field_name == "has_had_pos" & value == "1" ~ "Sí",
    field_name == "has_had_pos" & value == "0" ~ "No"
  )) %>%
  filter(!is.na(value)) %>%
  ggplot(aes(x = value)) +
  geom_histogram(stat = "count") +
  theme_bw() +
  xlab("Has had POS") +
  set_theme() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
ggsave(here("results", "figures", "has_had_pos.jpg"))

results %>%
  filter(field_name == "has_had_pos") %>%
  filter(!is.na(value)) %>%
  select(field_name,label, duration) %>%
  mutate(duration = as.numeric(duration))  %>%
  ggplot(aes(x = duration)) +
  geom_histogram() +
  theme_bw() +
  xlab("Duration (seconds)")   +
  set_theme()
ggsave(here("results", "figures", "has_had_pos_.jpg"))

results %>%
  filter(field_name == "has_had_pos") %>%
  filter(!is.na(value)) %>%
  select(field_name,label, value) %>%
  mutate(value = case_when(
    value != "-7" & value != "-8" ~ "Respondió",
    value == "-7" ~ "No sabe",
    value == "-8" ~ "No quiso responder"
  )) %>%
  count(value) %>%
  rbind(missing_answers) %>%
  group_by(value) %>% 
  summarise(n = sum(n)) %>% 
  mutate(prop = n/sum(n)) %>%
  ggplot(aes(x = value,y = n)) + 
  geom_col()  +
  geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
  theme_bw() +
  xlab("Answers") +
  set_theme() +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
ggsave(here("results", "figures", "has_had_pos_m.jpg"))

  # 8.1 SECTION B (DOES NOT HAVE POS) --------------------------------------------
  
  # considered_adopting
  results %>%
    filter(field_name == "considered_adopting") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "considered_adopting" & value == "1" ~ "Sí",
      field_name == "considered_adopting" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Considered adopting") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "considered_adopting.jpg"))
  
  results %>%
    filter(field_name == "considered_adopting") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "considered_adopting_.jpg"))
  
  results %>%
    filter(field_name == "considered_adopting") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 2), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "considered_adopting_m.jpg"))
  
  # considered_adoption_reason
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select(starts_with("considered_adoption_reason")) %>%
    pivot_longer(cols = 2:12) %>%
    filter(value == 1)  %>%
    select(name) %>%
      mutate(name = case_when(
        name == "considered_adoption_reason_1" ~ "Clientes sin tarjeta",
        name == "considered_adoption_reason_2" ~ "Costos altos",
        name == "considered_adoption_reason_3" ~ "Requiere internet",
        name == "considered_adoption_reason_4" ~ "Se pueden rastrear transacciones", 
        name == "considered_adoption_reason_5" ~ "Necesidad de efectivo",
        name == "considered_adoption_reason_6" ~ "No confío en bancos",
        name == "considered_adoption_reason_7" ~ "Dificultad de manejarlas",
        name == "considered_adoption_reason_8" ~ "Dinámica se hace más lenta",
        name == "considered_adoption_reason__666" ~ "Otra"
      )) %>%
    filter(!is.na(name))  %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Reasons to consider adoption") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "considered_adoption_reason.jpg"), width = 12, height = 9)
  
  results %>%
    filter(field_name == "considered_adoption_reason") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "considered_adoption_reason_.jpg"))
  
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select(starts_with("considered_adoption_reason")) %>%
    pivot_longer(cols = 2:12) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name != "considered_adoption_reason__777" & name != "considered_adoption_reason__888" ~ "Respondió",
      name == "considered_adoption_reason__777" ~ "No sabe",
      name == "considered_adoption_reason__888" ~ "No quiere responder"
    )) %>%
    count(name) %>%
    rename(value = name) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "considered_adoption_reason_m.jpg"), width = 12, height = 9)
  
  
  # considered_adoption_reason_other
  table_15 <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select("considered_adoption_reason_other") %>%
    filter(!is.na(considered_adoption_reason_other))
  table_15 <- xtable(table_15)
  print(table_15, file = here("results", "tables", "table_15.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  # no_considered_adoption_reason
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select(starts_with("no_considered_adoption_reason")) %>%
    pivot_longer(cols = 2:12) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name == "no_considered_adoption_reason_1" ~ "Clientes sin tarjeta",
      name == "no_considered_adoption_reason_2" ~ "Costos altos",
      name == "no_considered_adoption_reason_3" ~ "Requiere internet",
      name == "no_considered_adoption_reason_4" ~ "Se pueden rastrear transacciones", 
      name == "no_considered_adoption_reason_5" ~ "Necesidad de efectivo",
      name == "no_considered_adoption_reason_6" ~ "No confío en bancos",
      name == "no_considered_adoption_reason_7" ~ "Dificultad de manejarlas",
      name == "no_considered_adoption_reason_8" ~ "Dinámica se hace más lenta",
      name == "no_considered_adoption_reason__6" ~ "Otra"
    )) %>%
    filter(!is.na(name)) %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Reasons has not considered adoption") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "no_considered_adoption_reason.jpg"), width = 12, height = 9)
  
  results %>%
    filter(field_name == "no_considered_adoption_reason") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "no_considered_adoption_reason_.jpg"))
  
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select(starts_with("no_considered_adoption_reason")) %>%
    pivot_longer(cols = 2:12) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name != "no_considered_adoption_reason" & name != "no_considered_adoption_reason" ~ "Respondió",
      name == "no_considered_adoption_reason" ~ "No sabe",
      name == "no_considered_adoption_reason" ~ "No quiere responder"
    )) %>%
    count(name) %>%
    rename(value = name) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "no_considered_adoption_reason_m.jpg"), width = 12, height = 9)
  
  
  # no_considered_adoption_reason_other
  table_16 <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select("b3_other") %>%
    filter(!is.na(b3_other)) %>%
    rename(no_considered_adoption_reason_other = b3_other)
  table_16 <- xtable(table_16)
  print(table_16, file = here("results", "tables", "table_16.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  
  # cust_ask_card_payment_p
  results %>%
    filter(field_name == "cust_ask_card_payment_p") %>%
    select(field_name,label, value) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of customers who ask to pay by card") +
    set_theme()
  ggsave(here("results", "figures", "cust_ask_card_payment_p.jpg"))
  
  results %>%
    filter(field_name == "cust_ask_card_payment_p") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_ask_card_payment_p_.jpg"))
  
  results %>%
    filter(field_name == "cust_ask_card_payment_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_ask_card_payment_p_m.jpg"))
  
  
  # cust_ask_card_payment
  results %>%
    filter(field_name == "cust_ask_card_payment") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_ask_card_payment" & value == "1" ~ "Sí",
      field_name == "cust_ask_card_payment" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Customers have asked to pay by card") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_ask_card_payment.jpg"))
  
  results %>%
    filter(field_name == "cust_ask_card_payment") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_ask_card_payment_.jpg"))
  
  results %>%
    filter(field_name == "cust_ask_card_payment") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_ask_card_payment_m.jpg"))
  
  
  #cust_left
  results %>%
    filter(field_name == "cust_left") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_left" & value == "1" ~ "Sí",
      field_name == "cust_left" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Has a customer left") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left.jpg"))
  
  results %>%
    filter(field_name == "cust_left") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_left_.jpg"))
  
  results %>%
    filter(field_name == "cust_left") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_m.jpg"))
  
  
  # cust_left_p
  results %>%
    filter(field_name == "cust_left_p") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of customers who left store") +
    set_theme()
  ggsave(here("results", "figures", "cust_left_p.jpg"))
  
  results %>%
    filter(field_name == "cust_left_p") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_left_p_.jpg"))
  
  results %>%
    filter(field_name == "cust_left_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_p_m.jpg"))
  
  
  # cust_left_conf
  results %>%
    filter(field_name == "cust_left_conf") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_left_conf" & value == "1" ~ "Sí",
      field_name == "cust_left_conf" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Confirmed?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_conf.jpg"))
  
  results %>%
    filter(field_name == "cust_left_conf") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_left_conf_.jpg"))
  
  results %>%
    filter(field_name == "cust_left_conf") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_conf_m.jpg"))
    
    
  # num_cust_wd_change
  results %>%
    filter(field_name == "num_cust_wd_change") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "num_cust_wd_change" & value == "1" ~ "Aumentaría",
      field_name == "num_cust_wd_change" & value == "0" ~ "Se mantendría igual",
      field_name == "num_cust_wd_change" & value == "-1" ~ "Disminuiría"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Number of customers: change") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_wd_change.jpg"))
  
  results %>%
    filter(field_name == "num_cust_wd_change") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "num_cust_wd_change_.jpg"))
  
  results %>%
    filter(field_name == "num_cust_wd_change") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_wd_change_m.jpg"))
  
  # num_cust_wd_incr
  results %>%
    filter(field_name == "num_cust_wd_incr_p") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of increase in num customers") +
    set_theme()
  ggsave(here("results", "figures", "num_cust_wd_incr.jpg"))
  
  results %>%
    filter(field_name == "num_cust_wd_incr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "num_cust_wd_incr_.jpg"))
  
  results %>%
    filter(field_name == "num_cust_wd_incr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_wd_incr_m.jpg"))
    
  # cust_shop_others
  results %>%
    filter(field_name == "cust_shop_others") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_shop_others" & value == "1" ~ "Sí",
      field_name == "cust_shop_others" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("New customers if adopted") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_shop_others.jpg"))
  
  results %>%
    filter(field_name == "cust_shop_others") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_shop_others_.jpg"))
  
  results %>%
    filter(field_name == "cust_shop_others") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_shop_others_m.jpg"))
    
  # num_cust_wd_decr
  results %>%
    filter(field_name == "num_cust_wd_decr_p") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of decrease in num customers") +
    set_theme()
  ggsave(here("results", "figures", "num_cust_wd_decr.jpg"))
  
  results %>%
    filter(field_name == "num_cust_wd_decr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "num_cust_wd_decr_.jpg"))
  
  results %>%
    filter(field_name == "num_cust_wd_decr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_wd_decr_m.jpg"))
    
  # num_cust_wd_decr_reason
  table_17a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select("num_cust_wd_decr_reason") %>%
    filter(!is.na(num_cust_wd_decr_reason))
  table_17 <- xtable(table_17a)
  print(table_17, file = here("results", "tables", "table_17.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_17a %>%
    mutate(num_cust_wd_decr_reason = case_when(
      num_cust_wd_decr_reason != "-777" & num_cust_wd_decr_reason != "-888" ~ "Respondió",
      num_cust_wd_decr_reason == "-777" ~ "No sabe",
      num_cust_wd_decr_reason == "-888" ~ "No quiere responder"
    )) %>%
    rename(value = num_cust_wd_decr_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_wd_decr_reason_m.jpg"))
  
  
  # sales_wd_change
  results %>%
    filter(field_name == "sales_wd_change") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "sales_wd_change" & value == "1" ~ "Aumentaría",
      field_name == "sales_wd_change" & value == "0" ~ "Se mantendría igual",
      field_name == "sales_wd_change" & value == "-1" ~ "Disminuiría"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Sales: change") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_wd_change.jpg"))
  
  results %>%
    filter(field_name == "sales_wd_change") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_wd_change_.jpg"))
  
  results %>%
    filter(field_name == "sales_wd_change") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_wd_change_m.jpg"))
    
    
  # sales_wd_incr_p
  results %>%
    filter(field_name == "sales_wd_incr_p") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of increase in sales") +
    set_theme()
  ggsave(here("results", "figures", "sales_wd_incr.jpg"))
  
  results %>%
    filter(field_name == "sales_wd_incr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_wd_incr_.jpg"))
  
  results %>%
    filter(field_name == "sales_wd_incr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_wd_incr_m.jpg"))
    
    
  # sales_wd_decr
  results %>%
    filter(field_name == "sales_wd_decr_p") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of decrease in sales") +
    set_theme()
  ggsave(here("results", "figures", "sales_wd_decr.jpg"))
  
  results %>%
    filter(field_name == "sales_wd_decr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_wd_decr_.jpg"))
  
  results %>%
    filter(field_name == "sales_wd_decr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_wd_decr_m.jpg"))
    
    
  # sales_wd_decr_reason
  table_18a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select("sales_wd_decr_reason") %>%
    filter(!is.na(sales_wd_decr_reason))
  table_18 <- xtable(table_18a)
  print(table_18, file = here("results", "tables", "table_18.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_18a %>%
    mutate(sales_wd_decr_reason = case_when(
      sales_wd_decr_reason != "-777" & sales_wd_decr_reason != "-888" ~ "Respondió",
      sales_wd_decr_reason == "-777" ~ "No sabe",
      sales_wd_decr_reason == "-888" ~ "No quiere responder"
    )) %>%
    rename(value = sales_wd_decr_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_wd_decr_reason_m.jpg"))
  
  
  # profits_wd_change
  results %>%
    filter(field_name == "profits_wd_change") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "profits_wd_change" & value == "1" ~ "Aumentaría",
      field_name == "profits_wd_change" & value == "0" ~ "Se mantendría igual",
      field_name == "profits_wd_change" & value == "-1" ~ "Disminuiría"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Profits: change") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_wd_change.jpg"))
  
  results %>%
    filter(field_name == "profits_wd_change") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_wd_change_.jpg"))
  
  results %>%
    filter(field_name == "profits_wd_change") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_wd_change_m.jpg"))
  
  # profits_wd_incr
  results %>%
    filter(field_name == "profits_wd_incr_p") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of increase in profits") +
    set_theme()
  ggsave(here("results", "figures", "profits_wd_incr.jpg"))
  
  results %>%
    filter(field_name == "profits_wd_incr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_wd_incr_.jpg"))
  
  results %>%
    filter(field_name == "profits_wd_incr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_wd_incr_m.jpg"))
  
  
  # profits_wd_incr_reason
  table_24a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select("profits_wd_incr_reason") %>%
    filter(!is.na(profits_wd_incr_reason)) 
  table_24 <- xtable(table_24a)
  print(table_24, file = here("results", "tables", "table_24.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_24a %>%
    mutate(profits_wd_incr_reason = case_when(
      profits_wd_incr_reason != "-777" & profits_wd_incr_reason != "-888" ~ "Respondió",
      profits_wd_incr_reason == "-777" ~ "No sabe",
      profits_wd_incr_reason == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = profits_wd_incr_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_wd_incr_reason_m.jpg"))
    
  
  # profits_wd_decr
  results %>%
    filter(field_name == "profits_wd_decr_p") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of decrease in profits") +
    set_theme()
  ggsave(here("results", "figures", "profits_wd_decr.jpg"))
  
  results %>%
    filter(field_name == "profits_wd_decr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_wd_decr_.jpg"))
  
  results %>%
    filter(field_name == "profits_wd_decr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_wd_decr_m.jpg"))
  
  # profits_wd_decr_reason
  table_19a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select("profits_wd_decr_reason") %>%
    filter(!is.na(profits_wd_decr_reason))
  table_19 <- xtable(table_19a)
  print(table_19, file = here("results", "tables", "table_19.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_19a %>%
    mutate(profits_wd_decr_reason = case_when(
      profits_wd_decr_reason != "-777" & profits_wd_decr_reason != "-888" ~ "Respondió",
      profits_wd_decr_reason == "-777" ~ "No sabe",
      profits_wd_decr_reason == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = profits_wd_decr_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_wd_decr_reason_m.jpg"))
  
  
  # pos_firm_fee_b
  pos_firm_fee_b <- survey %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select(starts_with("pos_firm_fee_b")) %>%
    mutate(pos_firm_fee_b_format = case_when(
      pos_firm_fee_b_format == "1" ~ "Porcentaje",
      pos_firm_fee_b_format == "0" ~ "Pesos",
      pos_firm_fee_b != -777 & pos_firm_fee_b != -888 & !is.na(pos_firm_fee_b) ~ "Porcentaje"
      # Due to late implementation of format
    ))
  
  pos_firm_fee_b %>%
    filter(pos_firm_fee_b_format == "Porcentaje") %>%
    mutate(value = as.numeric(pos_firm_fee_b)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent fee charged by banks/firms") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_fee_b_percent.jpg"))
  
  results %>%
    filter(field_name == "pos_firm_fee_b") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_fee_b_.jpg"))
  
  pos_firm_fee_b %>%
    filter(pos_firm_fee_b_format == "Pesos") %>%
    mutate(value = as.numeric(pos_firm_fee_b)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Fee (pesos) charged by banks/firms") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_fee_b_pesos.jpg"))
  
  pos_firm_fee_b %>%
    mutate(value = pos_firm_fee_b) %>%
    select(value) %>%
    mutate_all(as.character()) %>%
    mutate(value = case_when(
      value != "-777" & value != "-888" ~ "Respondió",
      value == "-777" ~ "No sabe",
      value == "-888" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_fee_b_m.jpg"))
  
  
  # pos_firm_price_b
  results %>%
    filter(field_name == "pos_firm_price_b") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Price of getting a POS") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_price_b.jpg"))
  
  results %>%
    filter(field_name == "pos_firm_price_b") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_price_b_.jpg"))
  
  results %>%
    filter(field_name == "pos_firm_price_b") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_price_b_m.jpg"))
  
  
  # pos_firm_per_payment_b
  pos_firm_per_payment_b <- survey %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select("pos_firm_per_payment_b",
           "pos_firm_per_of_payment_b",
           "pos_firm_per_of_payment_b_other") %>%
    mutate_all(as.character()) %>%
    rename(
      pos_firm_per_payment = pos_firm_per_payment_b,
      pos_firm_per_of_payment = pos_firm_per_of_payment_b,
      pos_firm_per_of_payment_other = pos_firm_per_of_payment_b_other
    ) %>%
    filter(!is.na(pos_firm_per_payment)) %>%
    filter(!is.na(pos_firm_per_of_payment)) %>%
    mutate(pos_firm_per_of_payment = case_when(
      pos_firm_per_of_payment == "1" ~ "Dia",
      pos_firm_per_of_payment == "2" ~ "Semana",
      pos_firm_per_of_payment == "3" ~ "Mes",
      pos_firm_per_of_payment == "4" ~ "Año",
      pos_firm_per_of_payment == "-666" ~ "Otra",
      pos_firm_per_of_payment == "-777" ~ "No sabe",
      pos_firm_per_of_payment == "-888" ~ "No quiso responder"
    )) %>%
    mutate(pos_firm_per_of_payment = case_when(
      pos_firm_per_of_payment_other == "Quincena" ~ pos_firm_per_of_payment_other,
      pos_firm_per_of_payment_other == "Bimestre" ~ pos_firm_per_of_payment_other,
      pos_firm_per_of_payment_other == "Semestre" ~ pos_firm_per_of_payment_other,
      pos_firm_per_of_payment_other == "Por transacción" ~ pos_firm_per_of_payment_other,
      pos_firm_per_of_payment_other == "No se cobra renta" ~ pos_firm_per_of_payment_other,
      pos_firm_per_of_payment_other == "Porcentaje" ~ pos_firm_per_of_payment_other,
      TRUE ~ pos_firm_per_of_payment
    ))
  
  pos_firm_per_payment_b %>%
    filter(pos_firm_per_of_payment == "Dia") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Daily periodic payment") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_daily_b.jpg"))
  
  pos_firm_per_payment_b %>%
    filter(pos_firm_per_of_payment == "Mes") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Monthly periodic payment") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_monthly_b.jpg"))
  
  pos_firm_per_payment_b %>%
    filter(pos_firm_per_of_payment == "Semana") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Weekly periodic payment") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_weekly_b.jpg"))
  
  pos_firm_per_payment_b %>%
    filter(pos_firm_per_of_payment == "Año") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Yearly periodic payment") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_yearly_b.jpg"))
  
  pos_firm_per_payment_b %>%
    filter(pos_firm_per_of_payment == "Bimestre") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Bimonthly periodic payment") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_bimonthly_b.jpg"))
  
  pos_firm_per_payment_b %>%
    filter(pos_firm_per_of_payment == "Semestre") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Once every semester periodic payment") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_semester_b.jpg"))
  
  pos_firm_per_payment_b %>%
    filter(pos_firm_per_of_payment == "Quincena") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Biweekly periodic payment") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_biweekly_b.jpg"))
  
  pos_firm_per_payment_b %>%
    filter(pos_firm_per_of_payment == "Por transacción") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Periodic payment (per transaction)") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_per_transaction_b.jpg"))
  
  pos_firm_per_payment_b %>% 
    select(pos_firm_per_of_payment) %>%
    filter(!is.na(pos_firm_per_of_payment)) %>%
    mutate(value = case_when(
      pos_firm_per_of_payment != "No sabe" & pos_firm_per_of_payment != "No quiso responder" ~ "Respondió",
      TRUE ~ pos_firm_per_of_payment
    )) %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_per_payment_b_m.jpg"))
  
  
  # adopt_if_price_decreases
  results %>%
    filter(field_name == "adopt_if_price_decreases") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "adopt_if_price_decreases" & value == "1" ~ "Sí",
      field_name == "adopt_if_price_decreases" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Adopt if price decreases") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "adopt_if_price_decreases.jpg"))
  
  results %>%
    filter(field_name == "adopt_if_price_decreases") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "adopt_if_price_decreases_.jpg"))
  
  results %>%
    filter(field_name == "adopt_if_price_decreases") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "adopt_if_price_decreases_m.jpg"))
  
  
  # adopt_if_fee_decreases
  results %>%
    filter(field_name == "adopt_if_fee_decreases") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "adopt_if_fee_decreases" & value == "1" ~ "Sí",
      field_name == "adopt_if_fee_decreases" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Adopt if fee decreases") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "adopt_if_fee_decreases.jpg"))
  
  results %>%
    filter(field_name == "adopt_if_fee_decreases") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "adopt_if_fee_decreases_.jpg"))
  
  results %>%
    filter(field_name == "adopt_if_fee_decreases") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "adopt_if_fee_decreases_m.jpg"))
  
  
  # advantages_pos_b
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select(starts_with("advantages_pos_b")) %>%
    pivot_longer(cols = 2:18) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name == "advantages_pos_b_1" ~ "Mas clientes",
      name == "advantages_pos_b_2" ~ "Mayores ventas",
      name == "advantages_pos_b_3" ~ "Clientes sin efectivo",
      name == "advantages_pos_b_4" ~ "El pago es mas facil", 
      name == "advantages_pos_b_5" ~ "Es mas seguro",
      name == "advantages_pos_b_6" ~ "Me ayudaria a administrar el negocio",
      name == "advantages_pos_b_7" ~ "El poder cobrar donde sea",
      name == "advantages_pos_b_8" ~ "Podria hacer recargas/pagar servicios",
      name == "advantages_pos_b_9" ~ "Ninguna",
      name == "advantages_pos_b_10" ~ "No perder ventas de quienes no llevan efectivo",
      name == "advantages_pos_b_11" ~ "Poder competir con otras tiendas con terminal",
      name == "advantages_pos_b_12" ~ "Innovación en la tienda/ Actualizar la tienda",
      name == "advantages_pos_b_13" ~ "Cobrar más rápido",
      name == "advantages_pos_b_14" ~ "Ahorrar en el banco",
      name == "advantages_pos_b__666" ~ "Otra"
    ))  %>%
    filter(!is.na(name))  %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Advantages of POS") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "advantages_pos_b.jpg"), width = 12, height = 9)
  
  results %>%
    filter(field_name == "advantages_pos_b") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "advantages_pos_b_.jpg"))
  
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select(starts_with("advantages_pos_b")) %>%
    pivot_longer(cols = 2:18) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name != "advantages_pos_b__777" & name != "advantages_pos_b__888" ~ "Respondió",
      name == "advantages_pos_b__777" ~ "No sabe",
      name == "advantages_pos_b__888" ~ "No quiso responder"
    )) %>%
    count(name) %>%
    rename(value = name) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "advantages_pos_b_m.jpg"), width = 12, height = 9)
  
  
  # advantages_of_pos_other_b
  table_22 <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select("advantages_pos_other_b") %>%
    filter(!is.na(advantages_pos_other_b))
  table_22 <- xtable(table_22)
  print(table_22, file = here("results", "tables", "table_22.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  
  # disadvantages_pos_b
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select(starts_with("disadvantages_pos_b")) %>%
    pivot_longer(cols = 2:17) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name == "disadvantages_pos_b_1" ~ "El costo",
      name == "disadvantages_pos_b_2" ~ "Otros costos",
      name == "disadvantages_pos_b_3" ~ "Hacienda",
      name == "disadvantages_pos_b_4" ~ "Los fondos se depositan tarde", 
      name == "disadvantages_pos_b_5" ~ "Se necesita señal de internet para cobrar",
      name == "disadvantages_pos_b_6" ~ "Dificultad de manejarlas",
      name == "disadvantages_pos_b_7" ~ "Hace lenta la dinámica",
      name == "disadvantages_pos_b_8" ~ "Ninguna",
      name == "disadvantages_pos_b_9" ~ "Necesidad de efectivo",
      name == "disadvantages_pos_b_10" ~ "Pocos usan tarjetas",
      name == "disadvantages_pos_b_11" ~ "Miedo a fraudes o a que no lleguen fondos",
      name == "disadvantages_pos_b_12" ~ "Crear una cuenta bancaria/ desconfiar en bancos",
      name == "disadvantages_pos_b_13" ~ "Errores en los cobros",
      name == "disadvantages_pos_b__666" ~ "Otra"
    ))  %>%
    filter(!is.na(name))  %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Disadvantages of POS") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "disadvantages_pos_b.jpg"), width = 12, height = 9)
  
  results %>%
    filter(field_name == "disadvantages_pos_b") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "disadvantages_pos_b_.jpg"))
  
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select(starts_with("disadvantages_pos_b")) %>%
    pivot_longer(cols = 2:17) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name != "disadvantages_pos_b__777" & name != "disadvantages_pos_b__888" ~ "Respondió",
      name == "disadvantages_pos_b__777" ~ "No sabe",
      name == "disadvantages_pos_b__888" ~ "No quiso responder"
    )) %>%
    count(name) %>%
    rename(value = name) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "disadvantages_pos_b_m.jpg"), width = 12, height = 9)
  
  
  # disadvantages_of_pos_other_b
  table_23 <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select("disadvantages_pos_other_b") %>%
    filter(!is.na(disadvantages_pos_other_b))
  table_23 <- xtable(table_23)
  print(table_23, file = here("results", "tables", "table_23.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  
  # people_wd_adopt_after_pos
  results %>%
    filter(field_name == "people_wd_adopt_after_pos") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "people_wd_adopt_after_pos" & value == "1" ~ "Sí",
      field_name == "people_wd_adopt_after_pos" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("People would adopt if you adopt?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "people_wd_adopt_after_pos.jpg"))
  
  results %>%
    filter(field_name == "people_wd_adopt_after_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "people_wd_adopt_after_pos_.jpg"))
  
  results %>%
    filter(field_name == "people_wd_adopt_after_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "people_wd_adopt_after_pos_m.jpg"))
  
  
  # people_wd_adopt_after_pos_others
  results %>%
    filter(field_name == "people_wd_adopt_after_pos_others") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "people_wd_adopt_after_pos_others" & value == "1" ~ "Sí",
      field_name == "people_wd_adopt_after_pos_others" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("People would adopt if others adopt?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "people_wd_adopt_after_pos_others.jpg"))
  
  results %>%
    filter(field_name == "people_wd_adopt_after_pos_others") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "people_wd_adopt_after_pos_others_.jpg"))
  
  results %>%
    filter(field_name == "people_wd_adopt_after_pos_others") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "people_wd_adopt_after_pos_others_m.jpg"))
  
  
  # cust_wd_card_payment_p
  results %>%
    filter(field_name == "cust_wd_card_payment_p") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of customers that would use card") +
    set_theme()
  ggsave(here("results", "figures", "cust_wd_card_payment_p.jpg"))
  
  results %>%
    filter(field_name == "cust_wd_card_payment_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_wd_card_payment_p_.jpg"))
  
  results %>%
    filter(field_name == "cust_wd_card_payment_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_wd_card_payment_p_m.jpg"))
  
  
  # sales_wd_card_payment_p
  results %>%
    filter(field_name == "sales_wd_card_payment_p") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of sales would come from card") +
    set_theme()
  ggsave(here("results", "figures", "sales_wd_card_payment_p.jpg"))
  
  results %>%
    filter(field_name == "sales_wd_card_payment_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_wd_card_payment_p_.jpg"))
  
  results %>%
    filter(field_name == "sales_wd_card_payment_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_wd_card_payment_p_m.jpg"))
  
  
  # vat_whom_b
  results %>%
    filter(field_name == "vat_whom_b") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = case_when(
      field_name == "vat_whom_b" & value == "1" ~ "Todos",
      field_name == "vat_whom_b" & value == "2" ~ "Algunos",
      field_name == "vat_whom_b" & value == "3" ~ "Ninguno"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Who do you VAT to?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_whom_b.jpg"))
  
  results %>%
    filter(field_name == "vat_whom_b") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "vat_whom_b_.jpg"))
  
  results %>%
    filter(field_name == "vat_whom_b") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_whom_b_m.jpg"))
  
  
  # vat_reason_b
  table_21a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select("vat_reason_b") %>%
    filter(!is.na(vat_reason_b))
  table_21 <- xtable(table_21a)
  print(table_21, file = here("results", "tables", "table_21.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_21a %>%
    mutate(vat_reason_b = case_when(
      vat_reason_b != "-777" & vat_reason_b != "-888" ~ "Respondió",
      vat_reason_b == "-777" ~ "No sabe",
      vat_reason_b == "-888" ~ "No quiere responder"
    )) %>%
    rename(value = vat_reason_b)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_reason_b_m.jpg"))
  
  
  # 8.2 SECTION A (HAS POS) ------------------------------------------------------
  
  # started_business_w_pos
  results %>%
    filter(field_name == "started_business_w_pos") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "started_business_w_pos" & value == "1" ~ "Sí",
      field_name == "started_business_w_pos" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Started business with POS") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "started_business_w_pos.jpg"))
  
  results %>%
    filter(field_name == "started_business_w_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "started_business_w_pos_.jpg"))
  
  results %>%
    filter(field_name == "started_business_w_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "started_business_w_pos_m.jpg"))
  
  
  # pos_num
  results %>%
    filter(field_name == "pos_num") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value == "1" ~ "1",
      value == "2" ~ "2",
      value == "3" ~ "3",
      value == "4" ~ "4",
      value == "5" ~ "5",
      value == "6" ~ "6"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Number of POS") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_num.jpg"))
  
  results %>%
    filter(field_name == "pos_num") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "pos_num_.jpg"))
  
  results %>%
    filter(field_name == "pos_num") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_num_m.jpg"))
  
  
  # pos_firm_name
  survey %>%
    select(starts_with("pos_firm_name")) %>%
    select(1:6) %>%
    pivot_longer(1:6) %>%
    filter(!is.na(value)) %>%
    select(value) %>%
    mutate(value = case_when(
      value == "Zettle/iZettle" ~ "Zettle",
      value == "SíHay/Grupo Modelo" ~ "Gpo Modelo",
      value == "Citibanamex/Banamex/Citi" ~ "Citibanamex",
      value == "Tienda tec" ~ "TiendaTec",
      value == "Ya ganaste" ~ "Yaganaste",
      value == "Sicar" ~ "SICAR",
      value == "BBVA/Bancomer/BBVA Bancomer" ~ "BBVA",
      TRUE ~ value
    )) %>%
    filter(value != "No sabe" & value != "No quiere responder")  %>%
    ggplot(aes(y = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    ylab("POS firms/banks") +
    set_theme() +
    scale_y_discrete(labels = function(x) str_wrap(x, width = 8))
  ggsave(here("results", "figures", "pos_firm_name.jpg"), width = 16, height = 12)
  
  
  # Time with pos
  timepos_1 <- survey %>%
    filter(has_pos == 1)  %>%
    mutate_all(as.character) %>%
    select(years_with_pos_1, months_with_pos_1) %>%
    mutate_all(as.numeric)  %>%
    rename(years_with_pos = years_with_pos_1, months_with_pos = months_with_pos_1)
  
  timepos_2 <- survey %>%
    filter(has_pos == 1)  %>%
    mutate_all(as.character) %>%
    select(years_with_pos_2, months_with_pos_2) %>%
    filter(!is.na(years_with_pos_2)) %>%
    mutate_all(as.numeric)  %>%
    rename(years_with_pos = years_with_pos_2, months_with_pos = months_with_pos_2)
  
  timepos_3 <- survey %>%
    filter(has_pos == 1)  %>%
    mutate_all(as.character) %>%
    select(years_with_pos_3, months_with_pos_3) %>%
    filter(!is.na(years_with_pos_3)) %>%
    mutate_all(as.numeric)  %>%
    rename(years_with_pos = years_with_pos_3, months_with_pos = months_with_pos_3)
  
  timepos_4 <- survey %>%
    filter(has_pos == 1)  %>%
    mutate_all(as.character) %>%
    select(years_with_pos_4, months_with_pos_4) %>%
    filter(!is.na(years_with_pos_4)) %>%
    mutate_all(as.numeric)  %>%
    rename(years_with_pos = years_with_pos_4, months_with_pos = months_with_pos_4)
  
  timepos_5 <- survey %>%
    filter(has_pos == 1)  %>%
    mutate_all(as.character) %>%
    select(years_with_pos_5, months_with_pos_5) %>%
    filter(!is.na(years_with_pos_5)) %>%
    mutate_all(as.numeric)  %>%
    rename(years_with_pos = years_with_pos_5, months_with_pos = months_with_pos_5)
  
  timepos <- rbind(timepos_1, timepos_2, timepos_3, timepos_4, timepos_5) %>%
    mutate(time_with_pos = years_with_pos + months_with_pos/12) %>%
    select(time_with_pos) %>%
    filter(!is.na(time_with_pos)) %>%
    filter(time_with_pos >= 0)
  
  timepos %>%
    ggplot(aes(x = time_with_pos)) +
    geom_histogram() +
    theme_bw() +
    xlab("Time with POS (years)") +
    set_theme()
  ggsave(here("results", "figures", "time_pos.jpg"))
  
  
  # replaced_pos
  results %>%
    filter(field_name == "replaced_pos") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "replaced_pos" & value == "1" ~ "Sí",
      field_name == "replaced_pos" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Replaced POS somewhere in time") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "replaced_pos.jpg"))
  
  results %>%
    filter(field_name == "replaced_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "replaced_pos_.jpg"))
  
  results %>%
    filter(field_name == "replaced_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "replaced_pos_m.jpg"))
  
  
  # pos_firm_replaced
  survey %>%
    filter(has_pos == 1)   %>%
    select(pos_firm_replaced_name) %>%
    filter(!is.na(pos_firm_replaced_name)) %>%
    ggplot(aes(x = pos_firm_replaced_name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Replaced POS firms") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_replaced_name.jpg"))
  
  survey %>%
    filter(has_pos == 1)   %>%
    select(pos_firm_replaced_name) %>%
    filter(!is.na(pos_firm_replaced_name)) %>%
    mutate(pos_firm_replaced_name = case_when(
      pos_firm_replaced_name != "-777" & pos_firm_replaced_name != "-888" ~ "Respondió",
      pos_firm_replaced_name == "-777" ~ "No sabe",
      pos_firm_replaced_name == "-888" ~ "No quiso responder"
    )) %>%
    count(pos_firm_replaced_name) %>%
    rename(value = pos_firm_replaced_name) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_replaced_name_m.jpg"), width = 12, height = 9)
    
  
  # reason_replaced_pos
  table_25a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("reason_replaced_pos") %>%
    filter(!is.na(reason_replaced_pos))
  table_25 <- xtable(table_25a)
  print(table_25, file = here("results", "tables", "table_25.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_25a %>%
    mutate(reason_replaced_pos = case_when(
      reason_replaced_pos != "-777" & reason_replaced_pos != "-888" ~ "Respondió",
      reason_replaced_pos == "-777" ~ "No sabe",
      reason_replaced_pos == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = reason_replaced_pos)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_replaced_pos_m.jpg"))
  
  
  # pos_usage
  results %>%
    filter(field_name == "pos_usage") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "pos_usage" & value == "1" ~ "Usa todas",
      field_name == "pos_usage" & value == "2" ~ "Solo la de uno",
      field_name == "pos_usage" & value == "-6" ~ "Otra"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("POS usage") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_usage.jpg"))
  
  results %>%
    filter(field_name == "pos_usage") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "pos_usage_.jpg"))
  
  results %>%
    filter(field_name == "pos_usage") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_usage_m.jpg"))
  
  
  # reason_many_pos
  table_26a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("reason_many_pos") %>%
    filter(!is.na(reason_many_pos))
  table_26 <- xtable(table_26a)
  print(table_26, file = here("results", "tables", "table_26.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_26a %>%
    mutate(reason_many_pos = case_when(
      reason_many_pos != "-777" & reason_many_pos != "-888" ~ "Respondió",
      reason_many_pos == "-777" ~ "No sabe",
      reason_many_pos == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = reason_many_pos)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_many_pos_m.jpg"))
  
  
  # reason_one_pos_used
  table_27a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("reason_one_pos_used") %>%
    filter(!is.na(reason_one_pos_used))
  table_27 <- xtable(table_27a)
  print(table_27, file = here("results", "tables", "table_27.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_27a %>%
    mutate(reason_one_pos_used = case_when(
      reason_one_pos_used != "-777" & reason_one_pos_used != "-888" ~ "Respondió",
      reason_one_pos_used == "-777" ~ "No sabe",
      reason_one_pos_used == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = reason_one_pos_used)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_one_pos_used_m.jpg"))
  
  
  # reason_of_adoption
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select(starts_with("reason_of_adoption")) %>%
    select(!starts_with("reason_of_adoption_c"))  %>%
    pivot_longer(cols = 2:12)  %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name == "reason_of_adoption_1" ~ "Clientes querían pagar con tarjeta",
      name == "reason_of_adoption_2" ~ "Atraer nuevos clientes",
      name == "reason_of_adoption_3" ~ "Mas seguridad",
      name == "reason_of_adoption_4" ~ "Permiten mantener registro de ventas", 
      name == "reason_of_adoption_5" ~ "Transacciones se depositan en el banco",
      name == "reason_of_adoption_6" ~ "Por promoción/ Fue gratis",
      name == "reason_of_adoption_7" ~ "Por la competencia/ otras tiendas/ Oxxo",
      name == "reason_of_adoption_8" ~ "Para ofrecer recargas/ pago de servicios ",
      name == "reason_of_adoption__666" ~ "Otra"
    )) %>%
    filter(!is.na(name)) %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Reasons of adoption") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_of_adoption.jpg"), width = 12, height = 9)
  
  results %>%
    filter(field_name == "reason_of_adoption") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "reason_of_adoption_.jpg"))
  
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select(starts_with("reason_of_adoption")) %>%
    select(!starts_with("reason_of_adoption_c"))  %>%
    pivot_longer(cols = 2:12)  %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name != "reason_of_adoption__777" & name != "reason_of_adoption__888" ~ "Respondió",
      name == "reason_of_adoption__777" ~ "No sabe",
      name == "reason_of_adoption__888" ~ "No quiso responder"
    )) %>%
    count(name) %>%
    rename(value = name) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_of_adoption_m.jpg"), width = 12, height = 9)
  
  
  # reason_of_adoption_other
  table_28a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("reason_of_adoption_other") %>%
    filter(!is.na(reason_of_adoption_other))
  table_28 <- xtable(table_28a)
  print(table_28, file = here("results", "tables", "table_28.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_28a %>%
    mutate(reason_of_adoption_other = case_when(
      reason_of_adoption_other != "-777" & reason_of_adoption_other != "-888" ~ "Respondió",
      reason_of_adoption_other == "-777" ~ "No sabe",
      reason_of_adoption_other == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = reason_of_adoption_other)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_of_adoption_other_m.jpg"))
  
  
  # cust_ask_before_pos
  results %>%
    filter(field_name == "cust_ask_before_pos") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of customers who asked to pay by card") +
    set_theme()
  ggsave(here("results", "figures", "cust_ask_before_pos.jpg"))
  
  results %>%
    filter(field_name == "cust_ask_before_pos") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_ask_before_pos_.jpg"))
  
  results %>%
    filter(field_name == "cust_ask_before_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_ask_before_pos_m.jpg"))
  
  
  # cust_ask_before_pos_pay
  results %>%
    filter(field_name == "cust_ask_before_pos_pay") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_ask_before_pos_pay" & value == "1" ~ "Sí",
      field_name == "cust_ask_before_pos_pay" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Have customers asked to pay by card?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_ask_before_pos_pay.jpg"))

  results %>%
    filter(field_name == "cust_ask_before_pos_pay") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_ask_before_pos_pay_.jpg"))
  
  results %>%
    filter(field_name == "cust_ask_before_pos_pay") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_ask_before_pos_pay_m.jpg"))
  
  
  # cust_left_before_pos
  results %>%
    filter(field_name == "cust_left_before_pos") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_left_before_pos" & value == "1" ~ "Sí",
      field_name == "cust_left_before_pos" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Did a customer leave?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_before_pos.jpg"))
  
  results %>%
    filter(field_name == "cust_left_before_pos") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_left_before_pos_.jpg"))
  
  results %>%
    filter(field_name == "cust_left_before_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_before_pos_m.jpg"))
  
  
  # cust_left_before_pos_p
  results %>%
    filter(field_name == "cust_left_before_pos_p") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of customers who left store") +
    set_theme()
  ggsave(here("results", "figures", "cust_left_before_pos_p.jpg"))
  
  results %>%
    filter(field_name == "cust_left_before_pos_p") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_left_before_pos_p_.jpg"))
  
  results %>%
    filter(field_name == "cust_left_before_pos_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_before_pos_p_m.jpg"))
  
  
  # cust_left_be4_pos_conf
  results %>%
    filter(field_name == "cust_left_be4_pos_conf") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_left_be4_pos_conf" & value == "1" ~ "Sí",
      field_name == "cust_left_be4_pos_conf" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Confirmed?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_be4_pos_conf.jpg"))
  
  results %>%
    filter(field_name == "cust_left_be4_pos_conf") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_left_be4_pos_conf_.jpg"))
  
  results %>%
    filter(field_name == "cust_left_be4_pos_conf") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_be4_pos_conf_m.jpg"))
  
  
  # num_cust_changed
  results %>%
    filter(field_name == "num_cust_changed") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "num_cust_changed" & value == "1" ~ "Aumentó",
      field_name == "num_cust_changed" & value == "0" ~ "Se mantuvo igual",
      field_name == "num_cust_changed" & value == "-1" ~ "Disminuyó"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Number of customers: change") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_changed.jpg"))
  
  results %>%
    filter(field_name == "num_cust_changed") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "num_cust_changed_.jpg"))
  
  results %>%
    filter(field_name == "num_cust_changed") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_changed_m.jpg"))
  
  
  # num_cust_incr_p
  results %>%
    filter(field_name == "num_cust_incr_p") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value))  %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of increase in num customers") +
    set_theme()
  ggsave(here("results", "figures", "num_cust_incr_p.jpg"))
  
  results %>%
    filter(field_name == "num_cust_incr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "num_cust_incr_p_.jpg"))
  
  results %>%
    filter(field_name == "num_cust_incr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_incr_p_m.jpg"))
  
  
  # incr_vs_expected
  results %>%
    filter(field_name == "incr_vs_expected") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "incr_vs_expected" & value == "1" ~ "Mayor",
      field_name == "incr_vs_expected" & value == "0" ~ "Igual",
      field_name == "incr_vs_expected" & value == "-1" ~ "Menor"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Number of customers: reality vs expected") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "incr_vs_expected.jpg"))
  
  results %>%
    filter(field_name == "incr_vs_expected") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "incr_vs_expected_.jpg"))
  
  results %>%
    filter(field_name == "incr_vs_expected") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "incr_vs_expected_m.jpg"))
  
  
  # cust_shop_others_before_pos
  results %>%
    filter(field_name == "cust_shop_others_before_pos") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_shop_others_before_pos" & value == "1" ~ "Sí",
      field_name == "cust_shop_others_before_pos" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("New customers if adopted") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_shop_others_before_pos.jpg"))
  
  results %>%
    filter(field_name == "cust_shop_others_before_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_shop_others_before_pos_.jpg"))
  
  results %>%
    filter(field_name == "cust_shop_others_before_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_shop_others_before_pos_m.jpg"))
  
  
  # num_cust_decr_p
  results %>%
    filter(field_name == "num_cust_decr_p") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of decrease in num customers") +
    set_theme()
  ggsave(here("results", "figures", "num_cust_decr_p.jpg"))
  
  results %>%
    filter(field_name == "num_cust_decr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "num_cust_decr_p_.jpg"))
  
  results %>%
    filter(field_name == "num_cust_decr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_decr_p_m.jpg"))
  
  
  # num_cust_decr_reason
  table_29a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("num_cust_decr_reason") %>%
    filter(!is.na(num_cust_decr_reason))
  table_29 <- xtable(table_29a)
  print(table_29, file = here("results", "tables", "table_29.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_29a %>%
    mutate(num_cust_decr_reason = case_when(
      num_cust_decr_reason != "-777" & num_cust_decr_reason != "-888" ~ "Respondió",
      num_cust_decr_reason == "-777" ~ "No sabe",
      num_cust_decr_reason == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = num_cust_decr_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_decr_reason_m.jpg"))
  
  
  # sales_changed
  results %>%
    filter(field_name == "sales_changed") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "sales_changed" & value == "1" ~ "Aumentó",
      field_name == "sales_changed" & value == "0" ~ "Se mantuvo igual",
      field_name == "sales_changed" & value == "-1" ~ "Disminuyó"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Sales: change") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_changed.jpg"))
  
  results %>%
    filter(field_name == "sales_changed") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_changed_.jpg"))
  
  results %>%
    filter(field_name == "sales_changed") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_changed_m.jpg"))
  
  
  # sales_incr_p
  results %>%
    filter(field_name == "sales_incr_p") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of increase in sales") +
    set_theme()
  ggsave(here("results", "figures", "sales_incr_p.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_incr_p_.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_incr_p_m.jpg"))
  
  
  # sales_incr_vs_expected
  results %>%
    filter(field_name == "sales_incr_vs_expected") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "sales_incr_vs_expected" & value == "1" ~ "Mayor",
      field_name == "sales_incr_vs_expected" & value == "0" ~ "Igual",
      field_name == "sales_incr_vs_expected" & value == "-1" ~ "Menor"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Sales: reality vs expected") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_incr_vs_expected.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_vs_expected") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_incr_vs_expected_.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_vs_expected") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_incr_vs_expected_m.jpg"))
  
  
  # sales_incr_reason
  results %>%
    filter(field_name == "sales_incr_reason") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "sales_incr_reason" & value == "1" ~ "Más clientes",
      field_name == "sales_incr_reason" & value == "2" ~ "Mayor gasto",
      field_name == "sales_incr_reason" & value == "3" ~ "Ambas",
      field_name == "sales_incr_reason" & value == "-6" ~ "Otra"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Sales: reality vs expected") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_incr_reason.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_reason") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_incr_reason_.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_reason") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_incr_reason_m.jpg"))
  
  
  # sales_decr_p
  results %>%
    filter(field_name == "sales_decr_p") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of decrease in sales") +
    set_theme()
  ggsave(here("results", "figures", "sales_decr_p.jpg"))
  
  results %>%
    filter(field_name == "sales_decr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_decr_p_.jpg"))
  
  results %>%
    filter(field_name == "sales_decr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_decr_p_m.jpg"))
  
  
  # sales_decr_reason
  table_30a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("sales_decr_reason") %>%
    filter(!is.na(sales_decr_reason))
  table_30 <- xtable(table_30a)
  print(table_30, file = here("results", "tables", "table_30.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_30a %>%
    mutate(sales_decr_reason = case_when(
      sales_decr_reason != "-777" & sales_decr_reason != "-888" ~ "Respondió",
      sales_decr_reason == "-777" ~ "No sabe",
      sales_decr_reason == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = sales_decr_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_decr_reason_m.jpg"))
  
  
  # profits_changed
  results %>%
    filter(field_name == "profits_changed") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "profits_changed" & value == "1" ~ "Aumentaron",
      field_name == "profits_changed" & value == "0" ~ "Se mantuvieron igual",
      field_name == "profits_changed" & value == "-1" ~ "Disminuyeron"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Profits: change") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_changed.jpg"))
  
  results %>%
    filter(field_name == "profits_changed") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_changed_.jpg"))
  
  results %>%
    filter(field_name == "profits_changed") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_changed_m.jpg"))
  
  
  # profits_incr_p
  results %>%
    filter(field_name == "profits_incr_p") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of increase in profits") +
    set_theme()
  ggsave(here("results", "figures", "profits_incr_p.jpg"))
  
  results %>%
    filter(field_name == "profits_incr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_incr_p_.jpg"))
  
  results %>%
    filter(field_name == "profits_incr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_incr_p_m.jpg"))
  
  
  # profits_incr_vs_expected
  results %>%
    filter(field_name == "profits_incr_vs_expected") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "profits_incr_vs_expected" & value == "1" ~ "Mayor",
      field_name == "profits_incr_vs_expected" & value == "0" ~ "Igual",
      field_name == "profits_incr_vs_expected" & value == "-1" ~ "Menor"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("profits: reality vs expected") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_incr_vs_expected.jpg"))
  
  results %>%
    filter(field_name == "profits_incr_vs_expected") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_incr_vs_expected_.jpg"))
  
  results %>%
    filter(field_name == "profits_incr_vs_expected") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_incr_vs_expected_m.jpg"))
  
  
  # profits_decr_p
  results %>%
    filter(field_name == "profits_decr_p") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of decrease in profits") +
    set_theme()
  ggsave(here("results", "figures", "profits_decr_p.jpg"))
  
  results %>%
    filter(field_name == "profits_decr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_decr_p_.jpg"))
  
  results %>%
    filter(field_name == "profits_decr_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_decr_p_m.jpg"))
  
  
  # profits_decr_reason
  table_31a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("profits_decr_reason") %>%
    filter(!is.na(profits_decr_reason))
  table_31 <- xtable(table_31a)
  print(table_31, file = here("results", "tables", "table_31.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_31a %>%
    mutate(profits_decr_reason = case_when(
      profits_decr_reason != "-777" & profits_decr_reason != "-888" ~ "Respondió",
      profits_decr_reason == "-777" ~ "No sabe",
      profits_decr_reason == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = profits_decr_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_decr_reason_m.jpg"))
  
  
  # pos_firm_fee
  pos_firm_fee <- survey %>%
    filter(has_pos == 1) %>%
    select(starts_with("pos_firm_fee_")) %>%
    select(-c(starts_with("pos_firm_fee_format"))) %>%
    select(1:5) %>%
    mutate_all(as.character()) %>%
    pivot_longer(1:5) %>%
    filter(!is.na(value))
  
  pos_firm_fee %>%
    select(value) %>%
    rename(pos_firm_fee = value)%>%
    filter(pos_firm_fee >= 0) %>%
    ggplot(aes(x = pos_firm_fee)) +
    geom_histogram() +
    theme_bw() +
    xlab("Fee charged by firms") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_fee.jpg"))
  
  pos_firm_fee %>%
    select(value) %>%
    mutate_all(as.character()) %>%
    mutate(value = case_when(
      value != "-777" & value != "-888" ~ "Respondió",
      value == "-777" ~ "No sabe",
      value == "-888" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_fee_m.jpg"))
  
  
  # pos_firm_price_yesno
  pos_firm_price_yesno <- survey %>%
    filter(has_pos == 1) %>%
    select(starts_with("pos_firm_price_yesno_")) %>%
    select(1:5) %>%
    mutate_all(as.character()) %>%
    pivot_longer(1:5) 
  
  pos_firm_price_yesno %>%
    mutate(value = case_when(
      value == "1" ~ "Sí",
      value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Price of getting a POS (yesno)") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_price_yesno.jpg"))
    
  pos_firm_price_yesno %>%
    mutate(value = case_when(
      value != "-777" & value != "-888" ~ "Respondió",
      value == "-777" ~ "No sabe",
      value == "-888" ~ "No quiso responder"
    ))  %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_price_yesno_m.jpg"))
  
  
  # pos_firm_price
  pos_firm_price <- survey %>%
    filter(has_pos == 1) %>%
    select(starts_with("pos_firm_price_")) %>%
    select(-c(starts_with("pos_firm_price_yesno"))) %>%
    select(1:5) %>%
    mutate_all(as.character()) %>%
    pivot_longer(1:5) 
  
  pos_firm_price %>%
    select(value) %>%
    rename(pos_firm_price = value)%>%
    filter(pos_firm_price >= 0) %>%
    ggplot(aes(x = pos_firm_price)) +
    geom_histogram() +
    theme_bw() +
    xlab("Price charged by firms") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_price.jpg"))
  
  pos_firm_price %>%
    select(value) %>%
    mutate_all(as.character()) %>%
    mutate(value = case_when(
      value != "-777" & value != "-888" ~ "Respondió",
      value == "-777" ~ "No sabe",
      value == "-888" ~ "No quiso responder"
    )) %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_price_m.jpg"))
  
  
  # pos_firm_per_yesno
  pos_firm_per_yesno <- survey %>%
    filter(has_pos == 1) %>%
    select(starts_with("pos_firm_per_yesno_")) %>%
    select(1:5) %>%
    mutate_all(as.character()) %>%
    pivot_longer(1:5) 
  
  pos_firm_per_yesno %>%
    mutate(value = case_when(
      value == "1" ~ "Sí",
      value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Periodic payment POS (yesno)") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_per_yesno.jpg"))
  
  pos_firm_per_yesno %>%
    mutate(value = case_when(
      value != "-777" & value != "-888" ~ "Respondió",
      value == "-777" ~ "No sabe",
      value == "-888" ~ "No quiso responder"
    ))  %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_per_yesno_m.jpg"))
  
  
  # pos_firm_per_payment
  pos_firm_per_payment <- survey  %>% 
    filter(has_pos == 1) %>% 
    select(key, surveyid, (starts_with("pos_firm_per_")))  %>% 
    select(-c(starts_with("pos_firm_per_yesno"))) %>% 
    select(1:17) %>% 
    pivot_longer(3:17, names_to = c(".value", "number"),
                 names_pattern = "(.+)_(.+$)")  %>%  
    filter(!is.na(pos_firm_per_payment))  %>% 
    mutate_all(as.character) %>%  
    mutate(pos_firm_per_of_payment = case_when(
      pos_firm_per_of_payment == "1" ~ "Dia",
      pos_firm_per_of_payment == "2" ~ "Semana",
      pos_firm_per_of_payment == "3" ~ "Mes",
      pos_firm_per_of_payment == "4" ~ "Año",
      pos_firm_per_of_payment == "-666" ~ "Otra",
      pos_firm_per_of_payment == "-777" ~ "No sabe",
      pos_firm_per_of_payment == "-888" ~ "No quiso responder"
    ))  %>% 
    mutate(pos_firm_per_of_payment = case_when(
      pos_firm_per_of_payment_other == "Quincena" ~ pos_firm_per_of_payment_other,
      pos_firm_per_of_payment_other == "Por transacción" ~ pos_firm_per_of_payment_other,
      TRUE ~ pos_firm_per_of_payment
    )) %>% 
    select(-c(number, ends_with("_other")))
  
  pos_firm_per_payment %>%
    filter(pos_firm_per_of_payment == "Dia") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Periodicidad: diaria") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_daily.jpg"))
  
  pos_firm_per_payment %>%
    filter(pos_firm_per_of_payment == "Mes") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Periodicidad: mes") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_monthly.jpg"))
  
  pos_firm_per_payment %>%
    filter(pos_firm_per_of_payment == "Año") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Periodicidad: año") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_yearly.jpg"))
  
  pos_firm_per_payment %>%
    filter(pos_firm_per_of_payment == "Por transacción") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Por transacción") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_per_transaction.jpg"))
  
  pos_firm_per_payment %>% 
    select(pos_firm_per_of_payment) %>%
    filter(!is.na(pos_firm_per_of_payment)) %>%
    mutate(value = case_when(
      pos_firm_per_of_payment != "No sabe" & pos_firm_per_of_payment != "No quiso responder" ~ "Respondió",
      TRUE ~ pos_firm_per_of_payment
    )) %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_per_payment_m.jpg"))
  
  
  # cust_fee_card_payment_yesno
  results %>%
    filter(field_name == "cust_fee_card_payment_yesno") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_fee_card_payment_yesno" & value == "1" ~ "Sí",
      field_name == "cust_fee_card_payment_yesno" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Fee to customers paying with card") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_payment_yesno.jpg"))
  
  results %>%
    filter(field_name == "cust_fee_card_payment_yesno") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_fee_card_payment_yesno_.jpg"))
  
  results %>%
    filter(field_name == "cust_fee_card_payment_yesno") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_payment_yesno_m.jpg"))
  
  
  # cust_fee_card_payment
  cust_fee_card_payment <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select(c("cust_fee_card_payment", "cust_fee_card_payment_format"))  %>%
    filter(!is.na(cust_fee_card_payment) & !is.na(cust_fee_card_payment_format))  %>%
    mutate(as.character(cust_fee_card_payment_format)) %>%
    mutate(cust_fee_card_payment_format = case_when(
      cust_fee_card_payment_format == "0" ~ "Pesos",
      cust_fee_card_payment_format == "1" ~ "Porcentaje",
      cust_fee_card_payment == -777 ~ "No sabe",
      cust_fee_card_payment == -888 ~ "No quiso responder"
    ))
  
  cust_fee_card_payment %>%
    filter(cust_fee_card_payment_format == "Pesos") %>%
    filter(cust_fee_card_payment >= 0) %>%
    ggplot(aes(x = cust_fee_card_payment)) +
    geom_histogram() +
    theme_bw() +
    xlab("Pesos") +
    set_theme()
  ggsave(here("results", "figures", "cust_fee_card_payment_pesos.jpg"))
  
  cust_fee_card_payment %>%
    filter(cust_fee_card_payment_format == "Porcentaje") %>%
    filter(cust_fee_card_payment >= 0) %>%
    ggplot(aes(x = cust_fee_card_payment)) +
    geom_histogram() +
    theme_bw() +
    xlab("Porcentaje") +
    set_theme()
  ggsave(here("results", "figures", "cust_fee_card_payment_percent.jpg"))
  
  cust_fee_card_payment %>% 
    select(cust_fee_card_payment_format) %>%
    filter(!is.na(cust_fee_card_payment_format)) %>%
    mutate(value = case_when(
      cust_fee_card_payment_format != "No sabe" & cust_fee_card_payment_format != "No quiso responder" ~ "Respondió",
      TRUE ~ cust_fee_card_payment_format
    )) %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_payment_m.jpg"))
  
  # cust_fee_card_payment_when
  results %>%
    filter(field_name == "cust_fee_card_payment_when") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_fee_card_payment_when" & value == "1" ~ "Siempre he cobrado comisión",
      field_name == "cust_fee_card_payment_when" & value == "2" ~ "En algún momento no cobraba comisión"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Have you always charged fee to customers who pay with card?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_payment_when.jpg"))
  
  results %>%
    filter(field_name == "cust_fee_card_payment_when") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_fee_card_payment_when_.jpg")) 
  
  results %>%
    filter(field_name == "cust_fee_card_payment_when") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_payment_when_m.jpg"))
  
  
  # cust_fee_card_payment_reason
  table_36a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("cust_fee_card_payment_reason") %>%
    filter(!is.na(cust_fee_card_payment_reason))
  table_36 <- xtable(table_36a)
  print(table_36, file = here("results", "tables", "table_36.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_36a %>%
    mutate(cust_fee_card_payment_reason = case_when(
      cust_fee_card_payment_reason != "-777" & cust_fee_card_payment_reason != "-888" ~ "Respondió",
      cust_fee_card_payment_reason == "-777" ~ "No sabe",
      cust_fee_card_payment_reason == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = cust_fee_card_payment_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_payment_reason_m.jpg"))
  
  
  # cust_fee_card_pymnt_when_no
  results %>%
    filter(field_name == "cust_fee_card_pymnt_when_no") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_fee_card_pymnt_when_no" & value == "1" ~ "Nunca he cobrado comisión",
      field_name == "cust_fee_card_pymnt_when_no" & value == "2" ~ "En algún momento sí cobraba comisión"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Have you ever charged fee to customers who pay with card?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_pymnt_when_no.jpg"))
  
  results %>%
    filter(field_name == "cust_fee_card_pymnt_when_no") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_fee_card_pymnt_when_no_.jpg"))
  
  results %>%
    filter(field_name == "cust_fee_card_pymnt_when_no") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_pymnt_when_no_m.jpg"))
  
  
  # incr_prices_after_pos
  results %>%
    filter(field_name == "incr_prices_after_pos") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "incr_prices_after_pos" & value == "1" ~ "Sí",
      field_name == "incr_prices_after_pos" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Increased prices after adopting") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "incr_prices_after_pos.jpg"))
  
  results %>%
    filter(field_name == "incr_prices_after_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "incr_prices_after_pos_.jpg"))
  
  results %>%
    filter(field_name == "incr_prices_after_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "incr_prices_after_pos_m.jpg"))
  
  
  # incr_prices_after_pos_p
  incr_prices_after_pos_p <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select(c("incr_prices_after_pos_p", "incr_prices_after_pos_format"))  %>%
    filter(!is.na(incr_prices_after_pos_p) & !is.na(incr_prices_after_pos_format))  %>%
    mutate(as.character(incr_prices_after_pos_format)) %>%
    mutate(incr_prices_after_pos_format = case_when(
      incr_prices_after_pos_format == "0" ~ "Pesos",
      incr_prices_after_pos_format == "1" ~ "Porcentaje",
      incr_prices_after_pos_p == -777 ~ "No sabe",
      incr_prices_after_pos_p == -888 ~ "No quiso responder"
    ))
  
  incr_prices_after_pos_p %>%
    filter(incr_prices_after_pos_format == "Pesos") %>%
    filter(incr_prices_after_pos_p >= 0) %>%
    ggplot(aes(x = incr_prices_after_pos_p)) +
    geom_histogram() +
    theme_bw() +
    xlab("Pesos") +
    set_theme()
  ggsave(here("results", "figures", "incr_prices_after_pos_p_pesos.jpg"))
  
  incr_prices_after_pos_p %>%
    filter(incr_prices_after_pos_format == "Porcentaje") %>%
    filter(incr_prices_after_pos_p >= 0) %>%
    ggplot(aes(x = incr_prices_after_pos_p)) +
    geom_histogram() +
    theme_bw() +
    xlab("Porcentaje") +
    set_theme()
  ggsave(here("results", "figures", "incr_prices_after_pos_p_percent.jpg"))
  
  incr_prices_after_pos_p %>% 
    select(incr_prices_after_pos_format) %>%
    filter(!is.na(incr_prices_after_pos_format)) %>%
    mutate(value = case_when(
      incr_prices_after_pos_format != "No sabe" & incr_prices_after_pos_format != "No quiso responder" ~ "Respondió",
      TRUE ~ incr_prices_after_pos_format
    )) %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "incr_prices_after_pos_p_m.jpg"))
  
  
  # no_incr_prices_reason
  table_38a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("no_incr_prices_reason") %>%
    filter(!is.na(no_incr_prices_reason))
  table_38 <- xtable(table_38a)
  print(table_38, file = here("results", "tables", "table_38.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_38a %>%
    mutate(no_incr_prices_reason = case_when(
      no_incr_prices_reason != "-777" & no_incr_prices_reason != "-888" ~ "Respondió",
      no_incr_prices_reason == "-777" ~ "No sabe",
      no_incr_prices_reason == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = no_incr_prices_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "no_incr_prices_reason_m.jpg"))
  
  
  # advantages_pos
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select(starts_with("advantages_pos")) %>%
    select(1:18) %>%
    pivot_longer(cols = 2:18) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name == "advantages_pos_1" ~ "Mas clientes",
      name == "advantages_pos_2" ~ "Mayores ventas",
      name == "advantages_pos_3" ~ "Clientes sin efectivo",
      name == "advantages_pos_4" ~ "El pago es mas facil", 
      name == "advantages_pos_5" ~ "Es mas seguro",
      name == "advantages_pos_6" ~ "Me ayuda a administrar el negocio",
      name == "advantages_pos_7" ~ "El poder cobrar donde sea",
      name == "advantages_pos_8" ~ "Permite hacer recargas/pagar servicios",
      name == "advantages_pos_9" ~ "Ninguna",
      name == "advantages_pos_10" ~ "No perder ventas de quienes no llevan efectivo",
      name == "advantages_pos_11" ~ "Poder competir con otras tiendas con TPV",
      name == "advantages_pos_10" ~ "No perder ventas de quienes no llevan efectivo",
      name == "advantages_pos_11" ~ "Poder competir con otras tiendas con terminal",
      name == "advantages_pos_12" ~ "Innovación en la tienda/ Actualizar la tienda",
      name == "advantages_pos_13" ~ "Cobrar más rápido",
      name == "advantages_pos_14" ~ "Ahorrar en el banco",
      name == "advantages_pos__666" ~ "Otra"
    ))  %>%
    filter(!is.na(name)) %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Advantages of POS") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "advantages_pos.jpg"), width = 16, height = 12)
  
  results %>%
    filter(field_name == "advantages_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name, label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "advantages_pos_.jpg"))
  
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select(starts_with("advantages_pos")) %>%
    select(1:18) %>%
    pivot_longer(cols = 2:18) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name != "advantages_pos__777" & name != "advantages_pos__888" ~ "Respondió",
      name == "advantages_pos__777" ~ "No sabe",
      name == "advantages_pos__888" ~ "No quiere responder"
    )) %>%
    count(name) %>%
    rename(value = name) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "advantages_pos_m.jpg"), width = 12, height = 9)
  
  
  # advantages_of_pos_other
  table_39 <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("advantages_pos_other") %>%
    filter(!is.na(advantages_pos_other))
  table_39 <- xtable(table_39)
  print(table_39, file = here("results", "tables", "table_39.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  
  # disadvantages_pos
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select(starts_with("disadvantages_pos")) %>%
    select(1:17) %>%
    pivot_longer(cols = 2:17) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name == "disadvantages_pos_1" ~ "El costo de manejarla",
      name == "disadvantages_pos_2" ~ "Otros costos",
      name == "disadvantages_pos_3" ~ "Hacienda",
      name == "disadvantages_pos_4" ~ "Los fondos se depositan tarde", 
      name == "disadvantages_pos_5" ~ "Se necesita señal de internet para cobrar",
      name == "disadvantages_pos_6" ~ "Necesidad de efectivo en el negocio",
      name == "disadvantages_pos_7" ~ "Dificultad de manejarlas",
      name == "disadvantages_pos_8" ~ "Hace lenta la dinámica",
      name == "disadvantages_pos_9" ~ "Ninguna",
      name == "disadvantages_pos_10" ~ "Pocos usan tarjetas",
      name == "disadvantages_pos_11" ~ "Miedo a fraudes o a que no lleguen fondos",
      name == "disadvantages_pos_12" ~ "Crear una cuenta bancaria/ desconfiar en bancos",
      name == "disadvantages_pos_13" ~ "Errores en los cobros",
      name == "disadvantages_pos__666" ~ "Otra"
    ))  %>%
    filter(!is.na(name)) %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Disadvantages of POS") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "disadvantages_pos.jpg"), width = 16, height = 12)
  
  results %>%
    filter(field_name == "disadvantages_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "disadvantages_pos_.jpg"))
  
  survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select(starts_with("disadvantages_pos")) %>%
    select(1:17) %>%
    pivot_longer(cols = 2:17) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name != "disadvantages_pos__777" & name != "disadvantages_pos__888" ~ "Respondió",
      name == "disadvantages_pos__777" ~ "No sabe",
      name == "disadvantages_pos__888" ~ "No quiso responder"
    )) %>%
    count(name) %>%
    rename(value = name) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "disadvantages_pos_m.jpg"), width = 12, height = 9)
  
  
  # disadvantages_of_pos_other
  table_40 <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("disadvantages_pos_other") %>%
    filter(!is.na(disadvantages_pos_other))
  table_40 <- xtable(table_40)
  print(table_40, file = here("results", "tables", "table_40.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  
  # people_adopted_after_pos
  results %>%
    filter(field_name == "people_adopted_after_pos") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "people_adopted_after_pos" & value == "1" ~ "Sí",
      field_name == "people_adopted_after_pos" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("People adopted because you adopted?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "people_adopted_after_pos.jpg"))
  
  results %>%
    filter(field_name == "people_adopted_after_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "people_adopted_after_pos_.jpg"))
  
  results %>%
    filter(field_name == "people_adopted_after_pos") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "people_adopted_after_pos_m.jpg"))
  
  
  # people_adopted_after_pos_others
  results %>%
    filter(field_name == "people_adopted_after_pos_others") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "people_adopted_after_pos_others" & value == "1" ~ "Sí",
      field_name == "people_adopted_after_pos_others" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("People adopted because others adopted?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "people_adopted_after_pos_others.jpg"))
  
  results %>%
    filter(field_name == "people_adopted_after_pos_others") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "people_adopted_after_pos_others_.jpg"))
  
  results %>%
    filter(field_name == "people_adopted_after_pos_others") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "people_adopted_after_pos_others_m.jpg"))
  
  
  # cust_card_payment_p
  results %>%
    filter(field_name == "cust_card_payment_p") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of customers that use card") +
    set_theme()
  ggsave(here("results", "figures", "cust_card_payment_p.jpg"))
  
  results %>%
    filter(field_name == "cust_card_payment_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_card_payment_p_.jpg"))
  
  results %>%
    filter(field_name == "cust_card_payment_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_card_payment_p_m.jpg"))
  
  
  # sales_card_payment_p
  results %>%
    filter(field_name == "sales_card_payment_p") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of sales that come from card") +
    set_theme()
  ggsave(here("results", "figures", "sales_card_payment_p.jpg"))
  
  
  results %>%
    filter(field_name == "sales_card_payment_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_card_payment_p_.jpg"))
  
  results %>%
    filter(field_name == "sales_card_payment_p") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_card_payment_p_m.jpg"))
  
  
  # min_amount_card_payment
  results %>%
    filter(field_name == "min_amount_card_payment") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "min_amount_card_payment" & value == "0" ~ "Acepto cualquier monto",
      field_name == "min_amount_card_payment" & value == "1" ~ "Hay un monto mínimo"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Minimum amount") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "min_amount_card_payment.jpg"))
  
  results %>%
    filter(field_name == "min_amount_card_payment") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "min_amount_card_payment_.jpg"))
  
  results %>%
    filter(field_name == "min_amount_card_payment") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "min_amount_card_payment_m.jpg"))
  
  
  # no_min_amount_reason
  table_41a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("no_min_amount_reason") %>%
    filter(!is.na(no_min_amount_reason))
  table_41 <- xtable(table_41a)
  print(table_41, file = here("results", "tables", "table_41.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_41a %>%
    mutate(no_min_amount_reason = case_when(
      no_min_amount_reason != "-777" & no_min_amount_reason != "-888" ~ "Respondió",
      no_min_amount_reason == "-777" ~ "No sabe",
      no_min_amount_reason == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = no_min_amount_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "no_min_amount_reason_m.jpg"))
  
  
  # no_min_amount_when
  results %>%
    filter(field_name == "no_min_amount_when") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "no_min_amount_when" & value == "1" ~ "Siempre he aceptado pagos de cualquier monto",
      field_name == "no_min_amount_when" & value == "2" ~ "En algún momento hubo un monto mínimo",
      field_name == "no_min_amount_when" & value == "-7" ~ "No sabe",
      field_name == "no_min_amount_when" & value == "-8" ~ "No quiso responder"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Has a minimum amount ever existed?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "no_min_amount_when.jpg"))
  
  results %>%
    filter(field_name == "no_min_amount_when") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "no_min_amount_when_.jpg"))
  
  results %>%
    filter(field_name == "no_min_amount_when") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "no_min_amount_when_m.jpg"))
  
  
  # min_amount_c
  results %>%
    filter(field_name == "min_amount_c") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Minimum amount") +
    set_theme()
  ggsave(here("results", "figures", "min_amount_c.jpg"))
  
  results %>%
    filter(field_name == "min_amount_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "min_amount_c_.jpg"))
  
  results %>%
    filter(field_name == "min_amount_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "min_amount_c_m.jpg"))
  
  
  # min_amount_reason
  table_42a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("min_amount_reason") %>%
    filter(!is.na(min_amount_reason))
  table_42 <- xtable(table_42a)
  print(table_42, file = here("results", "tables", "table_42.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_42a %>%
    mutate(min_amount_reason = case_when(
      min_amount_reason != "-777" & min_amount_reason != "-888" ~ "Respondió",
      min_amount_reason == "-777" ~ "No sabe",
      min_amount_reason == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = min_amount_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "min_amount_reason_m.jpg"))
  
  
  # min_amount_when
  results %>%
    filter(field_name == "min_amount_when") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "min_amount_when" & value == "1" ~ "Siempre ha habido un monto mínimo",
      field_name == "min_amount_when" & value == "2" ~ "En algún aceptaba pagos de cualquier monto"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Has a minimum amount ever existed?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "min_amount_when.jpg"))
  
  results %>%
    filter(field_name == "min_amount_when") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "min_amount_when_.jpg"))
  
  results %>%
    filter(field_name == "min_amount_when") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "min_amount_when_m.jpg"))
  
  
  # vat_whom
  results %>%
    filter(field_name == "vat_whom") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "vat_whom" & value == "1" ~ "Todos",
      field_name == "vat_whom" & value == "2" ~ "Algunos",
      field_name == "vat_whom" & value == "3" ~ "Ninguno"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Who do you VAT to?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_whom.jpg"))
  
  results %>%
    filter(field_name == "vat_whom") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "vat_whom_.jpg"))
  
  results %>%
    filter(field_name == "vat_whom") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_whom_m.jpg"))
  
  
  # vat_card
  results %>%
    filter(field_name == "vat_card") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "vat_card" & value == "1" ~ "Todos",
      field_name == "vat_card" & value == "2" ~ "Algunos",
      field_name == "vat_card" & value == "3" ~ "Ninguno"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Who do you VAT to? (card)") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_card.jpg"))
  
  results %>%
    filter(field_name == "vat_card") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "vat_card_.jpg"))
  
  results %>%
    filter(field_name == "vat_card") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_card_m.jpg"))
  
  
  # vat_card_reason
  table_43a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("vat_card_reason") %>%
    filter(!is.na(vat_card_reason))
  table_43 <- xtable(table_43a)
  print(table_43, file = here("results", "tables", "table_43.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_43a %>%
    mutate(vat_card_reason = case_when(
      vat_card_reason != "-777" & vat_card_reason != "-888" ~ "Respondió",
      vat_card_reason == "-777" ~ "No sabe",
      vat_card_reason == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = vat_card_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_card_reason_m.jpg"))
  
  
  # vat_cash
  results %>%
    filter(field_name == "vat_cash") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "vat_cash" & value == "1" ~ "Todos",
      field_name == "vat_cash" & value == "2" ~ "Algunos",
      field_name == "vat_cash" & value == "3" ~ "Ninguno"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Who do you VAT to?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_cash.jpg"))
  
  results %>%
    filter(field_name == "vat_cash") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "vat_cash_.jpg"))
  
  results %>%
    filter(field_name == "vat_cash") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_cash_m.jpg"))
  
  
  # vat_cash_reason
  table_44a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 1) %>%
    select("vat_cash_reason") %>%
    filter(!is.na(vat_cash_reason))
  table_44 <- xtable(table_44a)
  print(table_44, file = here("results", "tables", "table_44.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_44a %>%
    mutate(vat_cash_reason = case_when(
      vat_cash_reason != "-777" & vat_cash_reason != "-888" ~ "Respondió",
      vat_cash_reason == "-777" ~ "No sabe",
      vat_cash_reason == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = vat_cash_reason)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_cash_reason_m.jpg"))
  
  
  
  # 8.3 SECTION C (DOES NOT HAVE POS, BUT HAD ONE ONCE) --------------------------
  
  # started_business_w_pos_c
  results %>%
    filter(field_name == "started_business_w_pos_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "started_business_w_pos_c" & value == "1" ~ "Sí",
      field_name == "started_business_w_pos_c" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Started business with POS") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "started_business_w_pos_c.jpg"))
  
  results %>%
    filter(field_name == "started_business_w_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "started_business_w_pos_c_.jpg"))
  
  results %>%
    filter(field_name == "started_business_w_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "started_business_w_pos_c_m.jpg"))
  
  
  # pos_num_c
  results %>%
    filter(field_name == "pos_num_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value == "1" ~ "1",
      value == "2" ~ "2",
      value == "3" ~ "3",
      value == "4" ~ "4"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Number of POS") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_num_c.jpg"))
  
  results %>%
    filter(field_name == "pos_num_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "pos_num_c_.jpg"))
  
  results %>%
    filter(field_name == "pos_num_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_num_c_m.jpg"))
  
  
  # pos_firm_name_c
  survey %>%
    filter(has_pos ==  0 & has_had_pos == 1)   %>%
    select(starts_with("pos_firm_name_c")) %>%
    pivot_longer(1:3) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(y = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    ylab("POS firms/banks") +
    set_theme() +
    scale_y_discrete(labels = function(x) str_wrap(x, width = 8))
  ggsave(here("results", "figures", "pos_firm_name_c.jpg"), width = 12, height = 9)
  
  
  # Time with pos c
  timepos_c_1 <- survey %>%
    filter(has_had_pos == 1)  %>%
    mutate_all(as.character) %>%
    select(years_with_pos_c_1, months_with_pos_c_1) %>%
    mutate_all(as.numeric)  %>%
    rename(years_with_pos = years_with_pos_c_1, months_with_pos = months_with_pos_c_1)
  
  timepos_c_2 <- survey %>%
    filter(has_had_pos == 1)  %>%
    mutate_all(as.character) %>%
    select(years_with_pos_c_2, months_with_pos_c_2) %>%
    filter(!is.na(years_with_pos_c_2)) %>%
    mutate_all(as.numeric)  %>%
    rename(years_with_pos = years_with_pos_c_2, months_with_pos = months_with_pos_c_2)

  timepos_c_3 <- survey %>%
    filter(has_had_pos == 1)  %>%
    mutate_all(as.character) %>%
    select(years_with_pos_c_3, months_with_pos_c_3) %>%
    filter(!is.na(years_with_pos_c_3)) %>%
    mutate_all(as.numeric)  %>%
    rename(years_with_pos = years_with_pos_c_3, months_with_pos = months_with_pos_c_3)
  
  timepos_c <- rbind(timepos_c_1, timepos_c_2, timepos_c_3) %>%
    filter(months_with_pos != -777) %>%
    mutate(months_with_pos = months_with_pos/12,
           time_with_pos = months_with_pos + years_with_pos) %>%
    select(time_with_pos)
  
  timepos_c %>%
    ggplot(aes(x = time_with_pos)) +
    geom_histogram() +
    theme_bw() +
    xlab("Time with POS (years)") +
    set_theme()
  ggsave(here("results", "figures", "time_pos_c.jpg"))
  
  
  # replaced_pos_c
  results %>%
    filter(field_name == "replaced_pos_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "replaced_pos_c" & value == "1" ~ "Sí",
      field_name == "replaced_pos_c" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Replaced POS somewhere in time") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "replaced_pos_c.jpg"))
  
  results %>%
    filter(field_name == "replaced_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "replaced_pos_c_.jpg"))
  
  results %>%
    filter(field_name == "replaced_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "replaced_pos_c_m.jpg"))
  
  
  # pos_firm_replaced_c
  survey %>%
    filter(has_had_pos == 1)   %>%
    select(pos_firm_replaced_name_c) %>%
    filter(!is.na(pos_firm_replaced_name_c)) %>%
    ggplot(aes(x = pos_firm_replaced_name_c)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Replaced POS firms") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_replaced_name_c.jpg"))
  
  survey %>%
    filter(has_had_pos == 1)   %>%
    select(pos_firm_replaced_name_c) %>%
    filter(!is.na(pos_firm_replaced_name_c)) %>%
    mutate(pos_firm_replaced_name_c = case_when(
      pos_firm_replaced_name_c != "-777" & pos_firm_replaced_name_c != "-888" ~ "Respondió",
      pos_firm_replaced_name_c == "-777" ~ "No sabe",
      pos_firm_replaced_name_c == "-888" ~ "No quiso responder"
    )) %>%
    count(pos_firm_replaced_name_c) %>%
    rename(value = pos_firm_replaced_name_c) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_replaced_name_c_m.jpg"), width = 12, height = 9)
  
  
  # reason_replaced_pos_c
  table_63a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("reason_replaced_pos_c") %>%
    filter(!is.na(reason_replaced_pos_c))
  table_63 <- xtable(table_63a)
  print(table_63, file = here("results", "tables", "table_63.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_63a %>%
    mutate(reason_replaced_pos_c = case_when(
      reason_replaced_pos_c != "-777" & reason_replaced_pos_c != "-888" ~ "Respondió",
      reason_replaced_pos_c == "-777" ~ "No sabe",
      reason_replaced_pos_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = reason_replaced_pos_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_replaced_pos_c_m.jpg"))
  
  
  
  # pos_usage_c
  results %>%
    filter(field_name == "pos_usage_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "pos_usage_c" & value == "1" ~ "Usaba todas",
      field_name == "pos_usage_c" & value == "2" ~ "Solo la de uno",
      field_name == "pos_usage_c" & value == "-6" ~ "Otra"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("POS usage") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_usage_c.jpg"))

  results %>%
    filter(field_name == "pos_usage_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "pos_usage_c_.jpg"))
  
  results %>%
    filter(field_name == "pos_usage_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_usage_c_m.jpg"))
  
  
  # reason_many_pos_c
  table_64a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("reason_many_pos_c") %>%
    filter(!is.na(reason_many_pos_c))
  table_64 <- xtable(table_64a)
  print(table_64, file = here("results", "tables", "table_64.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_64a %>%
    mutate(reason_many_pos_c = case_when(
      reason_many_pos_c != "-777" & reason_many_pos_c != "-888" ~ "Respondió",
      reason_many_pos_c == "-777" ~ "No sabe",
      reason_many_pos_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = reason_many_pos_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_many_pos_c_m.jpg"))
  
  
  # reason_one_pos_used
  table_45a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("reason_one_pos_used_c") %>%
    filter(!is.na(reason_one_pos_used_c))
  table_45 <- xtable(table_45a)
  print(table_45, file = here("results", "tables", "table_45.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_45a %>%
    mutate(reason_one_pos_used_c = case_when(
      reason_one_pos_used_c != "-777" & reason_one_pos_used_c != "-888" ~ "Respondió",
      reason_one_pos_used_c == "-777" ~ "No sabe",
      reason_one_pos_used_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = reason_one_pos_used_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_one_pos_used_c_m.jpg"))
  
  
  # reason_of_adoption_c
  survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select(starts_with("reason_of_adoption_c")) %>%
    pivot_longer(cols = 2:12)  %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name == "reason_of_adoption_c_1" ~ "Clientes querían pagar con tarjeta",
      name == "reason_of_adoption_c_2" ~ "Atraer nuevos clientes",
      name == "reason_of_adoption_c_3" ~ "Mas seguridad",
      name == "reason_of_adoption_c_4" ~ "Permitían mantener registro de ventas", 
      name == "reason_of_adoption_c_5" ~ "Transacciones se depositaban en el banco",
      name == "reason_of_adoption_c_6" ~ "Por promoción/ Fue gratis",
      name == "reason_of_adoption_c_7" ~ "Por la competencia/ otras tiendas/ Oxxo",
      name == "reason_of_adoption_c_8" ~ "Para ofrecer recargas/ pago de servicios ",
      name == "reason_of_adoption_c__666" ~ "Otra"
    )) %>%
    filter(!is.na(name))  %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Reasons of adoption") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_of_adoption_c.jpg"), width = 12, height = 9)
  
  results %>%
    filter(field_name == "reason_of_adoption_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "reason_of_adoption_c_.jpg"))
  
  survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select(starts_with("reason_of_adoption_c")) %>%
    pivot_longer(cols = 2:12)  %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name != "reason_of_adoption_c__777" & name != "reason_of_adoption_c__888" ~ "Respondió",
      name == "reason_of_adoption_c__777" ~ "No sabe",
      name == "reason_of_adoption_c__888" ~ "No quiere responder"
    )) %>%
    filter(!is.na(name))  %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Reasons of adoption") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_of_adoption_c_m.jpg"), width = 12, height = 9)
  
  
  # reason_of_adoption_other_c
  table_46a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("reason_of_adoption_other_c") %>%
    filter(!is.na(reason_of_adoption_other_c))
  table_46 <- xtable(table_46a)
  print(table_46, file = here("results", "tables", "table_46.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_46a %>%
    mutate(reason_of_adoption_other_c = case_when(
      reason_of_adoption_other_c != "-777" & reason_of_adoption_other_c != "-888" ~ "Respondió",
      reason_of_adoption_other_c == "-777" ~ "No sabe",
      reason_of_adoption_other_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = reason_of_adoption_other_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_of_adoption_other_c_m.jpg"))
  
  
  # cust_ask_before_pos_c
  results %>%
    filter(field_name == "cust_ask_before_pos_c") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of customers who asked to pay by card") +
    set_theme()
  ggsave(here("results", "figures", "cust_ask_before_pos_c.jpg"))
  
  
  results %>%
    filter(field_name == "cust_ask_before_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_ask_before_pos_c_.jpg"))
  
  results %>%
    filter(field_name == "cust_ask_before_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_ask_before_pos_c_m.jpg"))
  
  
  # cust_ask_before_pos_pay_c
  results %>%
    filter(field_name == "cust_ask_before_pos_pay_c") %>%
    select(field_name, label, value) %>%
    mutate(value = case_when(
      field_name == "cust_ask_before_pos_pay_c" & value == "1" ~ "Sí",
      field_name == "cust_ask_before_pos_pay_c" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Have customers asked to pay by card?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_ask_before_pos_pay_c.jpg"))

  results %>%
    filter(field_name == "cust_ask_before_pos_pay_c") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_ask_before_pos_pay_c_.jpg"))
  
  results %>%
    filter(field_name == "cust_ask_before_pos_pay_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_ask_before_pos_pay_c_m.jpg"))
  
  
  # cust_left_before_pos_c
  results %>%
    filter(field_name == "cust_left_before_pos_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_left_before_pos_c" & value == "1" ~ "Sí",
      field_name == "cust_left_before_pos_c" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Did a customer leave?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_before_pos_c.jpg"))
  
  results %>%
    filter(field_name == "cust_left_before_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_left_before_pos_c_.jpg"))
  
  results %>%
    filter(field_name == "cust_left_before_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_before_pos_c_m.jpg"))
  
  
  # cust_left_before_pos_p_c
  results %>%
    filter(field_name == "cust_left_before_pos_p_c") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of customers who left store") +
    set_theme()
  ggsave(here("results", "figures", "cust_left_before_pos_p_c.jpg"))
  
  results %>%
    filter(field_name == "cust_left_before_pos_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_left_before_pos_p_c_.jpg"))
  
  results %>%
    filter(field_name == "cust_left_before_pos_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_before_pos_p_c_m.jpg"))
  
  
  # cust_left_be4_pos_conf_c
  results %>%
    filter(field_name == "cust_left_be4_pos_conf_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_left_be4_pos_conf_c" & value == "1" ~ "Sí",
      field_name == "cust_left_be4_pos_conf_c" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Confirmed?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_be4_pos_conf_c.jpg"))
  
  results %>%
    filter(field_name == "cust_left_be4_pos_conf_c") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_left_be4_pos_conf_c_.jpg"))
  
  results %>%
    filter(field_name == "cust_left_be4_pos_conf_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_be4_pos_conf_c_m.jpg"))
  
  
  # num_cust_changed_c
  results %>%
    filter(field_name == "num_cust_changed_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "num_cust_changed_c" & value == "1" ~ "Aumentó",
      field_name == "num_cust_changed_c" & value == "0" ~ "Se mantuvo igual",
      field_name == "num_cust_changed_c" & value == "-1" ~ "Disminuyó"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Number of customers: change") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_changed_c.jpg"))
  
  results %>%
    filter(field_name == "num_cust_changed_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "num_cust_changed_c_.jpg"))
  
  results %>%
    filter(field_name == "num_cust_changed_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_changed_c_m.jpg"))
  
  # num_cust_incr_p_c
  results %>%
    filter(field_name == "num_cust_incr_p_c") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of increase in num customers") +
    set_theme()
  ggsave(here("results", "figures", "num_cust_incr_p_c.jpg"))
  
  results %>%
    filter(field_name == "num_cust_incr_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "num_cust_incr_p_c_.jpg"))
  
  results %>%
    filter(field_name == "num_cust_incr_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_incr_p_c_m.jpg"))
  
  
  # incr_vs_expected_c
  results %>%
    filter(field_name == "incr_vs_expected_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "incr_vs_expected_c" & value == "1" ~ "Mayor",
      field_name == "incr_vs_expected_c" & value == "0" ~ "Igual",
      field_name == "incr_vs_expected_c" & value == "-1" ~ "Menor"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Number of customers: reality vs expected") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "incr_vs_expected_c.jpg"))
  
  results %>%
    filter(field_name == "incr_vs_expected_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "incr_vs_expected_c_.jpg"))
  
  results %>%
    filter(field_name == "incr_vs_expected_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "incr_vs_expected_c_m.jpg"))
  
  
  # cust_shop_others_before_pos_c
  results %>%
    filter(field_name == "cust_shop_others_before_pos_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_shop_others_before_pos_c" & value == "1" ~ "Sí",
      field_name == "cust_shop_others_before_pos_c" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("New customers if adopted") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_shop_others_before_pos_c.jpg"))
  
  results %>%
    filter(field_name == "cust_shop_others_before_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_shop_others_before_pos_c_.jpg"))
  
  results %>%
    filter(field_name == "cust_shop_others_before_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_shop_others_before_pos_c_m.jpg"))
  
  
  # num_cust_decr_p_c
  results %>%
    filter(field_name == "num_cust_decr_p_c") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of decrease in num customers") +
    set_theme()
  ggsave(here("results", "figures", "num_cust_decr_p_c.jpg"))
  
  results %>%
    filter(field_name == "num_cust_decr_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "num_cust_decr_p_c_.jpg"))
  
  results %>%
    filter(field_name == "num_cust_decr_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_decr_p_c_m.jpg"))
  
  
  # num_cust_decr_reason_c
  table_47a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("num_cust_decr_reason_c") %>%
    filter(!is.na(num_cust_decr_reason_c))
  table_47<- xtable(table_47a)
  print(table_47, file = here("results", "tables", "table_47.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_47a %>%
    mutate(num_cust_decr_reason_c = case_when(
      num_cust_decr_reason_c != "-777" & num_cust_decr_reason_c != "-888" ~ "Respondió",
      num_cust_decr_reason_c == "-777" ~ "No sabe",
      num_cust_decr_reason_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = num_cust_decr_reason_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_decr_reason_c_m.jpg"))
  
  
  # sales_changed_c
  results %>%
    filter(field_name == "sales_changed_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "sales_changed_c" & value == "1" ~ "Aumentó",
      field_name == "sales_changed_c" & value == "0" ~ "Se mantuvo igual",
      field_name == "sales_changed_c" & value == "-1" ~ "Disminuyó"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Sales: change") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_changed_c.jpg"))
  
  results %>%
    filter(field_name == "sales_changed_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_changed_c_.jpg"))
  
  results %>%
    filter(field_name == "sales_changed_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_changed_c_m.jpg"))
  
  
  # sales_incr_p_c
  results %>%
    filter(field_name == "sales_incr_p_c") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of increase in sales") +
    set_theme()
  ggsave(here("results", "figures", "sales_incr_p_c.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_incr_p_c_.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_incr_p_c_m.jpg"))
  
  
  # sales_incr_vs_expected_c
  results %>%
    filter(field_name == "sales_incr_vs_expected_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "sales_incr_vs_expected_c" & value == "1" ~ "Mayor",
      field_name == "sales_incr_vs_expected_c" & value == "0" ~ "Igual",
      field_name == "sales_incr_vs_expected_c" & value == "-1" ~ "Menor"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Sales: reality vs expected") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_incr_vs_expected_c.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_vs_expected_c") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_incr_vs_expected_c_.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_vs_expected_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_incr_vs_expected_c_m.jpg"))
  
  
  # sales_incr_reason_c
  results %>%
    filter(field_name == "sales_incr_reason_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "sales_incr_reason_c" & value == "1" ~ "Más clientes",
      field_name == "sales_incr_reason_c" & value == "2" ~ "Mayor gasto",
      field_name == "sales_incr_reason_c" & value == "3" ~ "Ambas",
      field_name == "sales_incr_reason_c" & value == "-6" ~ "Otra"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Sales: reality vs expected") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_incr_reason_c.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_reason_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_incr_reason_c_.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_reason_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_incr_reason_c_m.jpg"))
  
  
  # sales_decr_p_c
  results %>%
    filter(field_name == "sales_decr_p_c") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of decrease in sales") +
    set_theme()
  ggsave(here("results", "figures", "sales_decr_p_c.jpg"))
  
  results %>%
    filter(field_name == "sales_decr_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_decr_p_c_.jpg"))
  
  results %>%
    filter(field_name == "sales_decr_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_decr_p_c_m.jpg"))
  
  
  # sales_decr_reason_c
  table_48a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("sales_decr_reason_c") %>%
    filter(!is.na(sales_decr_reason_c))
  table_48 <- xtable(table_48a)
  print(table_48, file = here("results", "tables", "table_48.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_48a %>%
    mutate(sales_decr_reason_c = case_when(
      sales_decr_reason_c != "-777" & sales_decr_reason_c != "-888" ~ "Respondió",
      sales_decr_reason_c == "-777" ~ "No sabe",
      sales_decr_reason_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = sales_decr_reason_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_decr_reason_c_m.jpg"))
  
  
  # profits_changed_c
  results %>%
    filter(field_name == "profits_changed_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "profits_changed_c" & value == "1" ~ "Aumentaron",
      field_name == "profits_changed_c" & value == "0" ~ "Se mantuvieron igual",
      field_name == "profits_changed_c" & value == "-1" ~ "Disminuyeron"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Profits: change") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_changed_c.jpg"))
  
  results %>%
    filter(field_name == "profits_changed_c") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_changed_c_.jpg"))
  
  results %>%
    filter(field_name == "profits_changed_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_changed_c_m.jpg"))
  
  
  # profits_incr_p_c
  results %>%
    filter(field_name == "profits_incr_p_c") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of increase in profits") +
    set_theme()
  ggsave(here("results", "figures", "profits_incr_p_c.jpg"))
  
  results %>%
    filter(field_name == "profits_incr_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_incr_p_c_.jpg"))
  
  results %>%
    filter(field_name == "profits_incr_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_incr_p_c_m.jpg"))
  
  
  # profits_incr_vs_expected_c
  results %>%
    filter(field_name == "profits_incr_vs_expected_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "profits_incr_vs_expected_c" & value == "1" ~ "Mayor",
      field_name == "profits_incr_vs_expected_c" & value == "0" ~ "Igual",
      field_name == "profits_incr_vs_expected_c" & value == "-1" ~ "Menor"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("profits: reality vs expected") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_incr_vs_expected_c.jpg"))
  
  results %>%
    filter(field_name == "profits_incr_vs_expected_c") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_incr_vs_expected_c_.jpg"))
  
  results %>%
    filter(field_name == "profits_incr_vs_expected_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_incr_vs_expected_c_m.jpg"))
  
  
  # profits_decr_p_c
  results %>%
    filter(field_name == "profits_decr_p_c") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of decrease in profits") +
    set_theme()
  ggsave(here("results", "figures", "profits_decr_p_c.jpg"))
  
  results %>%
    filter(field_name == "profits_decr_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_decr_p_c_.jpg"))
  
  results %>%
    filter(field_name == "profits_decr_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_decr_p_c_m.jpg"))
  
  
  # profits_decr_reason_c
  table_49a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("profits_decr_reason_c") %>%
    filter(!is.na(profits_decr_reason_c))
  table_49 <- xtable(table_49a)
  print(table_49, file = here("results", "tables", "table_49.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_49a %>%
    mutate(profits_decr_reason_c = case_when(
      profits_decr_reason_c != "-777" & profits_decr_reason_c != "-888" ~ "Respondió",
      profits_decr_reason_c == "-777" ~ "No sabe",
      profits_decr_reason_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = profits_decr_reason_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_decr_reason_c_m.jpg"))
  
  
  # pos_firm_fee_c
  pos_firm_fee_c <- survey %>%
    filter(has_pos == 0 & has_had_pos == 1) %>%
    select(starts_with("pos_firm_fee_c")) %>%
    select(-c(starts_with("pos_firm_fee_c_format"))) %>%
    select(1:3) %>%
    mutate_all(as.character()) %>%
    pivot_longer(1:3) %>%
    filter(!is.na(value))
  
  pos_firm_fee_c %>%
    select(value) %>%
    rename(pos_firm_fee_c = value)%>%
    filter(pos_firm_fee_c >= 0) %>%
    ggplot(aes(x = pos_firm_fee_c)) +
    geom_histogram() +
    theme_bw() +
    xlab("Fee charged by firms") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_fee_c.jpg"))
  
  pos_firm_fee_c %>%
    select(value) %>%
    mutate_all(as.character()) %>%
    mutate(value = case_when(
      value != "-777" & value != "-888" ~ "Respondió",
      value == "-777" ~ "No sabe",
      value == "-888" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_fee_c_m.jpg"))
  
  
  # pos_firm_price_yesno
  pos_firm_price_yesno_c <- survey %>%
    filter(has_pos == 0 & has_had_pos == 1) %>%
    select(starts_with("pos_firm_price_yesno_c")) %>%
    select(1:3) %>%
    mutate_all(as.character()) %>%
    pivot_longer(1:3) 
  
  pos_firm_price_yesno_c %>%
    mutate(value = case_when(
      value == "1" ~ "Sí",
      value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Price of getting a POS (yesno)") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_price_yesno_c.jpg"))
  
  pos_firm_price_yesno_c %>%
    mutate(value = case_when(
      value != "-777" & value != "-888" ~ "Respondió",
      value == "-777" ~ "No sabe",
      value == "-888" ~ "No quiso responder"
    ))  %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_price_yesno_c_m.jpg"))
  
  
  # pos_firm_price
  pos_firm_price_c <- survey %>%
    filter(has_pos == 0 & has_had_pos == 1) %>%
    select(starts_with("pos_firm_price_c")) %>%
    select(1:3) %>%
    mutate_all(as.character()) %>%
    pivot_longer(1:3) 
  
  pos_firm_price_c %>%
    select(value) %>%
    rename(pos_firm_price_c = value)%>%
    filter(pos_firm_price_c >= 0) %>%
    ggplot(aes(x = pos_firm_price_c)) +
    geom_histogram() +
    theme_bw() +
    xlab("Price charged by firms") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_price_c.jpg"))
  
  pos_firm_price_c %>%
    select(value) %>%
    mutate_all(as.character()) %>%
    mutate(value = case_when(
      value != "-777" & value != "-888" ~ "Respondió",
      value == "-777" ~ "No sabe",
      value == "-888" ~ "No quiso responder"
    )) %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_price_c_m.jpg"))
  
  
  # pos_firm_per_yesno
  pos_firm_per_yesno_c <- survey %>%
    filter(has_pos == 0 & has_had_pos == 1) %>%
    select(starts_with("pos_firm_per_yesno_c")) %>%
    select(1:3) %>%
    mutate_all(as.character()) %>%
    pivot_longer(1:3) 
  
  pos_firm_per_yesno_c %>%
    mutate(value = case_when(
      value == "1" ~ "Sí",
      value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Periodic payment POS (yesno)") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_per_yesno_c.jpg"))
  
  pos_firm_per_yesno_c %>%
    mutate(value = case_when(
      value != "-777" & value != "-888" ~ "Respondió",
      value == "-777" ~ "No sabe",
      value == "-888" ~ "No quiso responder"
    ))  %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_per_yesno_c_m.jpg"))
  
  
  # pos_firm_per_payment_c
  pos_firm_per_payment_c_1 <- survey %>%
    filter(has_pos == 0 & has_had_pos == 1) %>%
    select("pos_firm_per_payment_c_1",
      "c45_other_1",
      "c45_other_other_1") %>%
    mutate_all(as.character()) %>%
    rename(
      pos_firm_per_payment = pos_firm_per_payment_c_1,
      pos_firm_per_of_payment = c45_other_1,
      pos_firm_per_of_payment_other = c45_other_other_1
    )
  
  pos_firm_per_payment_c_2 <- survey %>%
    filter(has_pos == 0 & has_had_pos == 1) %>%
    select("pos_firm_per_payment_c_2",
           "c45_other_2",
           "c45_other_other_2") %>%
    mutate_all(as.character()) %>%
    rename(
      pos_firm_per_payment = pos_firm_per_payment_c_2,
      pos_firm_per_of_payment = c45_other_2,
      pos_firm_per_of_payment_other = c45_other_other_2
    )
  
  pos_firm_per_payment_c_3 <- survey %>%
    filter(has_pos == 0 & has_had_pos == 1) %>%
    select("pos_firm_per_payment_c_3",
           "pos_firm_per_of_payment_c_3",
           "c45_other_other_3") %>%
    mutate_all(as.character()) %>%
    rename(
      pos_firm_per_payment = pos_firm_per_payment_c_3,
      pos_firm_per_of_payment = pos_firm_per_of_payment_c_3,
      pos_firm_per_of_payment_other = c45_other_other_3
    )

  
  pos_firm_per_payment_c <- rbind(
    pos_firm_per_payment_c_1,
    pos_firm_per_payment_c_2,
    pos_firm_per_payment_c_3
    ) %>%
    filter(!is.na(pos_firm_per_payment)) %>%
    mutate_all(as.character) %>%
    mutate(pos_firm_per_of_payment = case_when(
      pos_firm_per_of_payment == "1" ~ "Dia",
      pos_firm_per_of_payment == "2" ~ "Semana",
      pos_firm_per_of_payment == "3" ~ "Mes",
      pos_firm_per_of_payment == "-666" ~ "Otra",
      pos_firm_per_of_payment == "-777" ~ "No sabe",
      pos_firm_per_of_payment == "-888" ~ "No quiso responder"
    )) %>%
    mutate(pos_firm_per_of_payment = case_when(
      pos_firm_per_of_payment_other == "Dos veces a la semana" ~ "Semana",
      TRUE ~ pos_firm_per_of_payment
    )) %>%
    mutate(pos_firm_per_payment = case_when(
      pos_firm_per_of_payment_other == "Dos veces a la semana" ~ "24",
        TRUE ~ pos_firm_per_payment
      )) %>%
    select(-ends_with("other"))
  
  pos_firm_per_payment_c %>%
    filter(pos_firm_per_of_payment == "Dia") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Daily periodic payment") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_daily_c.jpg"))
  
  pos_firm_per_payment_c %>%
    filter(pos_firm_per_of_payment == "Mes") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Monthly periodic payment") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_monthly_c.jpg"))
  
  pos_firm_per_payment_c %>%
    filter(pos_firm_per_of_payment == "Semana") %>%
    mutate(value = as.numeric(pos_firm_per_payment)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Weekly periodic payment") +
    set_theme()
  ggsave(here("results", "figures", "pos_firm_per_payment_weekly_c.jpg"))
  
  pos_firm_per_payment_c %>% 
    select(pos_firm_per_of_payment) %>%
    filter(!is.na(pos_firm_per_of_payment)) %>%
    mutate(value = case_when(
      pos_firm_per_of_payment != "No sabe" & pos_firm_per_of_payment != "No quiso responder" ~ "Respondió",
      TRUE ~ pos_firm_per_of_payment
    )) %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "pos_firm_per_payment_c_m.jpg"))
  
  
  # cust_fee_card_payment_yesno_c
  results %>%
    filter(field_name == "cust_fee_card_payment_yesno_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_fee_card_payment_yesno_c" & value == "1" ~ "Sí",
      field_name == "cust_fee_card_payment_yesno_c" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Fee to customers paying with card") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_payment_yesno_c.jpg"))
  
  results %>%
    filter(field_name == "cust_fee_card_payment_yesno_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_fee_card_payment_yesno_c_.jpg"))
  
  results %>%
    filter(field_name == "cust_fee_card_payment_yesno_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_payment_yesno_c_m.jpg"))
  
  
  # cust_fee_card_payment_c
  
  cust_fee_card_payment_c <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select(c("cust_fee_card_payment_c", "cust_fee_card_payment_c_format"))  %>%
    filter(!is.na(cust_fee_card_payment_c) & !is.na(cust_fee_card_payment_c_format)) %>%
    mutate(as.character(cust_fee_card_payment_c_format)) %>%
    mutate(cust_fee_card_payment_c_format = case_when(
      cust_fee_card_payment_c_format == "0" ~ "Pesos",
      cust_fee_card_payment_c_format == "1" ~ "Porcentaje",
      cust_fee_card_payment_c == -777 ~ "No sabe",
      cust_fee_card_payment_c == -888 ~ "No quiso responder"
    ))
  
  cust_fee_card_payment_c %>%
    filter(cust_fee_card_payment_c_format == "Pesos") %>%
    filter(cust_fee_card_payment_c >= 0) %>%
    ggplot(aes(x = cust_fee_card_payment_c)) +
    geom_histogram() +
    theme_bw() +
    xlab("Pesos") +
    set_theme()
  ggsave(here("results", "figures", "cust_fee_card_payment_c_pesos.jpg"))
  
  cust_fee_card_payment_c %>%
    filter(cust_fee_card_payment_c_format == "Porcentaje") %>%
    filter(cust_fee_card_payment_c >= 0) %>%
    ggplot(aes(x = cust_fee_card_payment_c)) +
    geom_histogram() +
    theme_bw() +
    xlab("Porcentaje") +
    set_theme()
  ggsave(here("results", "figures", "cust_fee_card_payment_c_percent.jpg"))
  
  cust_fee_card_payment_c %>% 
    select(cust_fee_card_payment_c_format) %>%
    filter(!is.na(cust_fee_card_payment_c_format)) %>%
    mutate(value = case_when(
      cust_fee_card_payment_c_format != "No sabe" & cust_fee_card_payment_c_format != "No quiso responder" ~ "Respondió",
      TRUE ~ cust_fee_card_payment_c_format
    )) %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_payment_c_m.jpg"))
  

  # cust_fee_card_payment_when_c
  results %>%
    filter(field_name == "cust_fee_card_payment_when_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_fee_card_payment_when_c" & value == "1" ~ "Siempre he cobrado comisión",
      field_name == "cust_fee_card_payment_when_c" & value == "2" ~ "En algún momento no cobraba comisión"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Have you always charged fee to customers who pay with card?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_payment_when_c.jpg"))
  
  results %>%
    filter(field_name == "cust_fee_card_payment_when_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_fee_card_payment_when_c_.jpg")) 
  
  results %>%
    filter(field_name == "cust_fee_card_payment_when_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_payment_when_c_m.jpg"))
  
  
  # cust_fee_card_payment_reason_c
  table_54a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("cust_fee_card_payment_reason_c") %>%
    filter(!is.na(cust_fee_card_payment_reason_c))
  table_54 <- xtable(table_54a)
  print(table_54, file = here("results", "tables", "table_54.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_54a %>%
    mutate(cust_fee_card_payment_reason_c = case_when(
      cust_fee_card_payment_reason_c != "-777" & cust_fee_card_payment_reason_c != "-888" ~ "Respondió",
      cust_fee_card_payment_reason_c == "-777" ~ "No sabe",
      cust_fee_card_payment_reason_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = cust_fee_card_payment_reason_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_payment_reason_c_m.jpg"))
  
  
  # cust_fee_card_pymnt_when_no_c
  results %>%
    filter(field_name == "cust_fee_card_pymnt_when_no_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_fee_card_pymnt_when_no_c" & value == "1" ~ "Nunca he cobrado comisión",
      field_name == "cust_fee_card_pymnt_when_no_c" & value == "2" ~ "En algún momento sí cobraba comisión"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Have you ever charged fee to customers who pay with card?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_pymnt_when_no_c.jpg"))
  
  results %>%
    filter(field_name == "cust_fee_card_pymnt_when_no_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_fee_card_pymnt_when_no_c_.jpg"))
  
  results %>%
    filter(field_name == "cust_fee_card_pymnt_when_no_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_fee_card_pymnt_when_no_c_m.jpg"))
  
  
  # incr_prices_after_pos_c
  results %>%
    filter(field_name == "incr_prices_after_pos_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "incr_prices_after_pos_c" & value == "1" ~ "Sí",
      field_name == "incr_prices_after_pos_c" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Increased prices after adopting") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "incr_prices_after_pos_c.jpg"))
  
  results %>%
    filter(field_name == "incr_prices_after_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "incr_prices_after_pos_c_.jpg"))
  
  results %>%
    filter(field_name == "incr_prices_after_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "incr_prices_after_pos_c_m.jpg"))
  
  
  # incr_prices_after_pos_p_c
  incr_prices_after_pos_p_c <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select(c("incr_prices_after_pos_p_c", "incr_prices_after_pos_format_c"))  %>%
    filter(!is.na(incr_prices_after_pos_p_c) & !is.na(incr_prices_after_pos_format_c))  %>%
    mutate(as.character(incr_prices_after_pos_format_c)) %>%
    mutate(incr_prices_after_pos_format_c = case_when(
      incr_prices_after_pos_format_c == "0" ~ "Pesos",
      incr_prices_after_pos_format_c == "1" ~ "Porcentaje",
      incr_prices_after_pos_p_c == -777 ~ "No sabe",
      incr_prices_after_pos_p_c == -888 ~ "No quiso responder"
    ))
  
  incr_prices_after_pos_p_c %>%
    filter(incr_prices_after_pos_format_c == "Pesos") %>%
    filter(incr_prices_after_pos_p_c >= 0) %>%
    ggplot(aes(x = incr_prices_after_pos_p_c)) +
    geom_histogram() +
    theme_bw() +
    xlab("Pesos") +
    set_theme()
  ggsave(here("results", "figures", "incr_prices_after_pos_p_c_pesos.jpg"))
  
  incr_prices_after_pos_p_c %>%
    filter(incr_prices_after_pos_format_c == "Porcentaje") %>%
    filter(incr_prices_after_pos_p_c >= 0) %>%
    ggplot(aes(x = incr_prices_after_pos_p_c)) +
    geom_histogram() +
    theme_bw() +
    xlab("Porcentaje") +
    set_theme()
  ggsave(here("results", "figures", "incr_prices_after_pos_p_c_percent.jpg"))
  
  incr_prices_after_pos_p_c %>% 
    select(incr_prices_after_pos_format_c) %>%
    filter(!is.na(incr_prices_after_pos_format_c)) %>%
    mutate(value = case_when(
      incr_prices_after_pos_format_c != "No sabe" & incr_prices_after_pos_format_c != "No quiso responder" ~ "Respondió",
      TRUE ~ incr_prices_after_pos_format_c
    )) %>%
    filter(!is.na(value)) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "incr_prices_after_pos_p_c_m.jpg"))
  
  
  # no_incr_prices_reason_c
  table_56a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("no_incr_prices_reason_c") %>%
    filter(!is.na(no_incr_prices_reason_c))
  table_56 <- xtable(table_56a)
  print(table_56, file = here("results", "tables", "table_56.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_56a %>%
    mutate(no_incr_prices_reason_c = case_when(
      no_incr_prices_reason_c != "-777" & no_incr_prices_reason_c != "-888" ~ "Respondió",
      no_incr_prices_reason_c == "-777" ~ "No sabe",
      no_incr_prices_reason_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = no_incr_prices_reason_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "no_incr_prices_reason_c_m.jpg"))
  
  
  # advantages_pos_c
  survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select(starts_with("advantages_pos_c"))%>%
    select(1:18) %>%
    pivot_longer(cols = 2:18)  %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name == "advantages_pos_c_1" ~ "Mas clientes",
      name == "advantages_pos_c_2" ~ "Mayores ventas",
      name == "advantages_pos_c_3" ~ "Clientes sin efectivo",
      name == "advantages_pos_c_4" ~ "El pago es mas facil", 
      name == "advantages_pos_c_5" ~ "Es mas seguro",
      name == "advantages_pos_c_6" ~ "Me ayuda a administrar el negocio",
      name == "advantages_pos_c_7" ~ "El poder cobrar donde sea",
      name == "advantages_pos_c_8" ~ "Permite hacer recargas/pagar servicios",
      name == "advantages_pos_c_9" ~ "Ninguna",
      name == "advantages_pos_c_10" ~ "No perder ventas de quienes no llevan efectivo",
      name == "advantages_pos_c_11" ~ "Poder competir con otras tiendas con TPV",
      name == "advantages_pos_c_11" ~ "Poder competir con otras tiendas con terminal",
      name == "advantages_pos_c_12" ~ "Innovación en la tienda/ Actualizar la tienda",
      name == "advantages_pos_c_13" ~ "Cobrar más rápido",
      name == "advantages_pos_c_14" ~ "Ahorrar en el banco",
      name == "advantages_pos_c__666" ~ "Otra"
    ))  %>%
    filter(!is.na(name)) %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Advantages of POS") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "advantages_pos_c.jpg"), width = 12, height = 9)
  
  results %>%
    filter(field_name == "advantages_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "advantages_pos_c_.jpg"))
  
  survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select(starts_with("advantages_pos_c")) %>%
    select(1:18) %>%
    pivot_longer(cols = 2:18) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name != "advantages_pos_c__777" & name != "advantages_pos_c__888" ~ "Respondió",
      name == "advantages_pos_c__777" ~ "No sabe",
      name == "advantages_pos_c__888" ~ "No quiere responder"
    )) %>%
    count(name) %>%
    rename(value = name) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "advantages_pos_c_m.jpg"), width = 12, height = 9)
  
  
  # advantages_of_pos_other_c
  table_57 <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("advantages_pos_other_c") %>%
    filter(!is.na(advantages_pos_other_c))
  table_57 <- xtable(table_57)
  print(table_57, file = here("results", "tables", "table_57.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  
  # disadvantages_pos_c
  survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select(starts_with("disadvantages_pos_c")) %>%
    select(1:17) %>%
    pivot_longer(cols = 2:17) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name == "disadvantages_pos_c_1" ~ "El costo de mantenerla",
      name == "disadvantages_pos_c_2" ~ "Otros costos",
      name == "disadvantages_pos_c_3" ~ "Hacienda",
      name == "disadvantages_pos_c_4" ~ "Los fondos se depositan tarde", 
      name == "disadvantages_pos_c_5" ~ "Se necesita señal de internet para cobrar",
      name == "disadvantages_pos_c_6" ~ "Necesidad de efectivo en el negocio",
      name == "disadvantages_pos_c_7" ~ "Dificultad de manejarlas",
      name == "disadvantages_pos_c_8" ~ "Hace lenta la dinámica",
      name == "disadvantages_pos_c_9" ~ "Ninguna",
      name == "disadvantages_pos_b_10" ~ "Pocos usan tarjetas",
      name == "disadvantages_pos_b_11" ~ "Miedo a fraudes o a que no lleguen fondos",
      name == "disadvantages_pos_b_12" ~ "Crear una cuenta bancaria/ desconfiar en bancos",
      name == "disadvantages_pos_b_13" ~ "Errores en los cobros",
      name == "disadvantages_pos_c__666" ~ "Otra"
    ))  %>%
    filter(!is.na(name)) %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Disadvantages of POS") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "disadvantages_pos_c.jpg"), width = 12, height = 9)
  
  results %>%
    filter(field_name == "disadvantages_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "disadvantages_pos_c_.jpg"))
  
  survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select(starts_with("disadvantages_pos_c")) %>%
    select(1:17) %>%
    pivot_longer(cols = 2:17) %>%
    filter(value == 1)  %>%
    select(name) %>%
    mutate(name = case_when(
      name != "disadvantages_pos_c__777" & name != "disadvantages_pos_c__888" ~ "Respondió",
      name == "disadvantages_pos_c__777" ~ "No sabe",
      name == "disadvantages_pos_c__888" ~ "No quiso responder"
    )) %>%
    count(name) %>%
    rename(value = name) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "disadvantages_pos_c_m.jpg"), width = 12, height = 9)
  
  
  # disadvantages_of_pos_other
  table_58 <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("disadvantages_pos_other_c") %>%
    filter(!is.na(disadvantages_pos_other_c))
  table_58 <- xtable(table_58)
  print(table_58, file = here("results", "tables", "table_58.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)

  
  # people_adopted_after_pos_c
  results %>%
    filter(field_name == "people_adopted_after_pos_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "people_adopted_after_pos_c" & value == "1" ~ "Sí",
      field_name == "people_adopted_after_pos_c" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("People adopted because you adopted?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "people_adopted_after_pos_c.jpg"))
  
  results %>%
    filter(field_name == "people_adopted_after_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "people_adopted_after_pos_c_.jpg"))
  
  results %>%
    filter(field_name == "people_adopted_after_pos_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "people_adopted_after_pos_c_m.jpg"))
  
  
  # people_adopted_after_pos_others_c
  results %>%
    filter(field_name == "c55") %>%
    select(field_name, label, value) %>%
    mutate(value = case_when(
      field_name == "c55" & value == "1" ~ "Sí",
      field_name == "c55" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("People adopted because others adopted?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "people_adopted_after_pos_others_c.jpg"))
  
  results %>%
    filter(field_name == "c55") %>%
    select(field_name, label, duration) %>%
    filter(!is.na(duration)) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "people_adopted_after_pos_others_c_.jpg"))
  
  results %>%
    filter(field_name == "c55") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "people_adopted_after_pos_others_c_m.jpg"))
  
  # cust_card_payment_p_c
  results %>%
    filter(field_name == "cust_card_payment_p_c") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of customers that use card") +
    set_theme()
  ggsave(here("results", "figures", "cust_card_payment_p_c.jpg"))
  
  results %>%
    filter(field_name == "cust_card_payment_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_card_payment_p_c_.jpg"))
  
  results %>%
    filter(field_name == "cust_card_payment_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_card_payment_p_c_m.jpg"))
  
  
  # sales_card_payment_p_c
  results %>%
    filter(field_name == "sales_card_payment_p_c") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of sales that come from card") +
    set_theme()
  ggsave(here("results", "figures", "sales_card_payment_p_c.jpg"))
  
  results %>%
    filter(field_name == "sales_card_payment_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_card_payment_p_c_.jpg"))
  
  results %>%
    filter(field_name == "sales_card_payment_p_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_card_payment_p_c_m.jpg"))
  
  
  # min_amount_card_payment_c
  results %>%
    filter(field_name == "min_amount_card_payment_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "min_amount_card_payment_c" & value == "0" ~ "Aceptaba cualquier monto",
      field_name == "min_amount_card_payment_c" & value == "1" ~ "Había un monto mínimo"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Minimum amount") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "min_amount_card_payment_c.jpg"))
  
  results %>%
    filter(field_name == "min_amount_card_payment_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "min_amount_card_payment_c_.jpg"))
  
  results %>%
    filter(field_name == "min_amount_card_payment_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "min_amount_card_payment_c_m.jpg"))
  
  
  # no_min_amount_reason_c
  table_59a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("no_min_amount_reason_c") %>%
    filter(!is.na(no_min_amount_reason_c))
  table_59 <- xtable(table_59a)
  print(table_59, file = here("results", "tables", "table_59.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_59a %>%
    mutate(no_min_amount_reason_c = case_when(
      no_min_amount_reason_c != "-777" & no_min_amount_reason_c != "-888" ~ "Respondió",
      no_min_amount_reason_c == "-777" ~ "No sabe",
      no_min_amount_reason_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = no_min_amount_reason_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "no_min_amount_reason_c_m.jpg"))
  
  
  # no_min_amount_when_c
  results %>%
    filter(field_name == "no_min_amount_when_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "no_min_amount_when_c" & value == "1" ~ "Siempre acepté pagos de cualquier monto",
      field_name == "no_min_amount_when_c" & value == "2" ~ "En algún momento hubo un monto mínimo"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Has a minimum amount ever existed?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "no_min_amount_when_c.jpg"))
  
  results %>%
    filter(field_name == "no_min_amount_when_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "no_min_amount_when_c_.jpg"))
  
  results %>%
    filter(field_name == "no_min_amount_when_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "no_min_amount_when_c_m.jpg"))
  
  
  # min_amount_c_c
  results %>%
    filter(field_name == "min_amount_c_c") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Minimum amount") +
    set_theme()
  ggsave(here("results", "figures", "min_amount_c_c.jpg"))
  
  results %>%
    filter(field_name == "min_amount_c_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "min_amount_c_c_.jpg"))
  
  results %>%
    filter(field_name == "min_amount_c_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "min_amount_c_c_m.jpg"))
  
  
  # min_amount_reason_c
  table_60a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("min_amount_reason_c") %>%
    filter(!is.na(min_amount_reason_c))
  table_60 <- xtable(table_60a)
  print(table_60, file = here("results", "tables", "table_60.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_60a %>%
    mutate(min_amount_reason_c = case_when(
      min_amount_reason_c != "-777" & min_amount_reason_c != "-888" ~ "Respondió",
      min_amount_reason_c == "-777" ~ "No sabe",
      min_amount_reason_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = min_amount_reason_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "min_amount_reason_c_m.jpg"))
  
  
  # min_amount_when_c
  results %>%
    filter(field_name == "min_amount_when_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "min_amount_when_c" & value == "1" ~ "Siempre hubo un monto mínimo",
      field_name == "min_amount_when_c" & value == "2" ~ "En algún aceptaba pagos de cualquier monto"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Has a minimum amount ever existed?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "min_amount_when_c.jpg"))
  
  results %>%
    filter(field_name == "min_amount_when_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "min_amount_when_c_.jpg"))
  
  results %>%
    filter(field_name == "min_amount_when_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "min_amount_when_c_m.jpg"))
  
  
  # vat_whom_before_c
  results %>%
    filter(field_name == "vat_whom_before_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "vat_whom_before_c" & value == "1" ~ "Todos",
      field_name == "vat_whom_before_c" & value == "2" ~ "Algunos",
      field_name == "vat_whom_before_c" & value == "3" ~ "Ninguno"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Who do you VAT to?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_whom_before_c.jpg"))
  
  results %>%
    filter(field_name == "vat_whom_before_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "vat_whom_before_c_.jpg"))
  
  results %>%
    filter(field_name == "vat_whom_before_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_whom_before_c_m.jpg"))
  
  
  # vat_card_before_c
  results %>%
    filter(field_name == "vat_card_before_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "vat_card_before_c" & value == "1" ~ "Todos",
      field_name == "vat_card_before_c" & value == "2" ~ "Algunos",
      field_name == "vat_card_before_c" & value == "3" ~ "Ninguno"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Who did you VAT to? (card)") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_card_before_c.jpg"))

  results %>%
    filter(field_name == "vat_card_before_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "vat_card_before_c_.jpg"))
  
  results %>%
    filter(field_name == "vat_card_before_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_card_before_c_m.jpg"))


  # vat_card_reason_before_c
  table_65a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("vat_card_reason_before_c") %>%
    filter(!is.na(vat_card_reason_before_c))
  table_65 <- xtable(table_65a)
  print(table_65, file = here("results", "tables", "table_65.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_65a %>%
    mutate(vat_card_reason_before_c = case_when(
      vat_card_reason_before_c != "-777" & vat_card_reason_before_c != "-888" ~ "Respondió",
      vat_card_reason_before_c == "-777" ~ "No sabe",
      vat_card_reason_before_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = vat_card_reason_before_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_card_reason_before_c_m.jpg"))
   
   
  # vat_cash_before_c
  results %>%
    filter(field_name == "vat_cash_before_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "vat_cash_before_c" & value == "1" ~ "Todos",
      field_name == "vat_cash_before_c" & value == "2" ~ "Algunos",
      field_name == "vat_cash_before_c" & value == "3" ~ "Ninguno"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Who did you VAT to? (cash)") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_cash_before_c.jpg"))
  
  results %>%
    filter(field_name == "vat_cash_before_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "vat_cash_before_c_.jpg"))
  
  results %>%
    filter(field_name == "vat_cash_before_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_cash_before_c_m.jpg"))
  
  
  # vat_cash_reason_before_c
  table_66a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("vat_cash_reason_before_c") %>%
    filter(!is.na(vat_cash_reason_before_c))
  table_66 <- xtable(table_66a)
  print(table_66, file = here("results", "tables", "table_66.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_66a %>%
    mutate(vat_cash_reason_before_c = case_when(
      vat_cash_reason_before_c != "-777" & vat_cash_reason_before_c != "-888" ~ "Respondió",
      vat_cash_reason_before_c == "-777" ~ "No sabe",
      vat_cash_reason_before_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = vat_cash_reason_before_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_cash_reason_before_c_m.jpg"))
  
  
  # 8.4 SECTION C.1 -----------------------------------------------------------
  
  # Time CANCELED pos c
  timepos_canceled_1 <- survey %>%
    filter(has_had_pos == 1)  %>%
    mutate_all(as.character) %>%
    select(years_canceled_pos_1, months_canceled_pos_1) %>%
    mutate_all(as.numeric)  %>%
    rename(years_canceled_pos = years_canceled_pos_1, months_canceled_pos = months_canceled_pos_1)
  
  timepos_canceled_2 <- survey %>%
    filter(has_had_pos == 1)  %>%
    mutate_all(as.character) %>%
    select(years_canceled_pos_2, months_canceled_pos_2) %>%
    filter(!is.na(years_canceled_pos_2)) %>%
    mutate_all(as.numeric)  %>%
    rename(years_canceled_pos = years_canceled_pos_2, months_canceled_pos = months_canceled_pos_2)

  timepos_canceled_3 <- survey %>%
    filter(has_had_pos == 1)  %>%
    mutate_all(as.character) %>%
    select(years_canceled_pos_3, months_canceled_pos_3) %>%
    filter(!is.na(years_canceled_pos_3)) %>%
    mutate_all(as.numeric)  %>%
    rename(years_canceled_pos = years_canceled_pos_3, months_canceled_pos = months_canceled_pos_3)
  
  timepos_canceled <- rbind(timepos_canceled_1, timepos_canceled_2, timepos_canceled_3) %>%
    filter(years_canceled_pos != -777 & years_canceled_pos != -888) %>%
    mutate(months_canceled_pos = months_canceled_pos/12,
           time_canceled_pos = months_canceled_pos + years_canceled_pos) %>%
    select(time_canceled_pos)
  
  timepos_canceled %>%
    ggplot(aes(x = time_canceled_pos)) +
    geom_histogram() +
    theme_bw() +
    xlab("Time canceled POS (years)") +
    set_theme()
  ggsave(here("results", "figures", "time_pos_canceled.jpg"))
  
  
  # reason_of_canceling
  survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select(starts_with("reason_of_canceling")) %>%
    pivot_longer(cols = 2:12)  %>%
    filter(value == 1) %>%
    select(name) %>%
    mutate(name = case_when(
      name == "reason_of_canceling_1" ~ "Pocos pidieron pagar con tarjeta",
      name == "reason_of_canceling_2" ~ "Esperaba más aumento de ventas/clientes",
      name == "reason_of_canceling_3" ~ "Costos/comisiones demasiado altos",
      name == "reason_of_canceling_4" ~ "Se pueden rastrear transacciones", 
      name == "reason_of_canceling_5" ~ "Necesitaba efectivo en mi negocio",
      name == "reason_of_canceling_6" ~ "No confío en los bancos",
      name == "reason_of_canceling_7" ~ "Dificultad de manejarlas",
      name == "reason_of_canceling_8" ~ "Hace más lenta la dinámica",
      name == "reason_of_canceling__666" ~ "Otra"
    )) %>%
    filter(!is.na(name)) %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Reasons of canceling") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_of_canceling.jpg"), width = 12, height = 9)
  
  results %>%
    filter(field_name == "reason_of_canceling") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "reason_of_canceling_.jpg"))
  
  survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select(starts_with("reason_of_canceling")) %>%
    pivot_longer(cols = 2:12)  %>%
    filter(value == 1) %>%
    select(name) %>%
    mutate(name = case_when(
      name != "reason_of_canceling__777" & name != "reason_of_canceling__888" ~ "Respondió",
      name == "reason_of_canceling__777" ~ "No sabe",
      name == "reason_of_canceling__888" ~ "No quiere responder"
    )) %>%
    filter(!is.na(name)) %>%
    ggplot(aes(x = name)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Reasons of canceling") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_of_canceling_m.jpg"), width = 12, height = 9)
  
  
  # reason_of_canceling_other
  table_61a <- survey %>%
    filter(successful == 1) %>%
    filter(has_had_pos == 1) %>%
    select("reason_of_canceling_other") %>%
    filter(!is.na(reason_of_canceling_other))
  table_61 <- xtable(table_61a)
  print(table_61, file = here("results", "tables", "table_61.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_61a %>%
    mutate(reason_of_canceling_other = case_when(
      reason_of_canceling_other != "-777" & reason_of_canceling_other != "-888" ~ "Respondió",
      reason_of_canceling_other == "-777" ~ "No sabe",
      reason_of_canceling_other == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = reason_of_canceling_other)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "reason_of_canceling_other_m.jpg"))
  
  
  # cust_ask_card_payment_p_cancel
  results %>%
    filter(field_name == "cust_ask_card_payment_p_cancel") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of customers who asked to pay by card") +
    set_theme()
  ggsave(here("results", "figures", "cust_ask_card_payment_p_cancel.jpg"))
  
  
  results %>%
    filter(field_name == "cust_ask_card_payment_p_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_ask_card_payment_p_cancel_.jpg"))
  
  results %>%
    filter(field_name == "cust_ask_card_payment_p_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_ask_card_payment_p_cancel_m.jpg"))
  
  
  # cust_ask_card_payment_cancel
  results %>%
    filter(field_name == "cust_ask_card_payment_cancel") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_ask_card_payment_cancel" & value == "1" ~ "Sí",
      field_name == "cust_ask_card_payment_cancel" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Have customers asked to pay by card?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_ask_card_payment_cancel.jpg"))
  
  results %>%
    filter(field_name == "cust_ask_card_payment_cancel") %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_ask_card_payment_cancel_.jpg"))
  
  results %>%
    filter(field_name == "cust_ask_card_payment_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_ask_card_payment_cancel_m.jpg"))
  
  
  # cust_left_cancel
  results %>%
    filter(field_name == "cust_left_cancel") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "cust_left_cancel" & value == "1" ~ "Sí",
      field_name == "cust_left_cancel" & value == "0" ~ "No"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Did a customer leave?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_cancel.jpg"))
  
  results %>%
    filter(field_name == "cust_left_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_left_cancel_.jpg"))
  
  results %>%
    filter(field_name == "cust_left_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_cancel_m.jpg"))
  
  
  # cust_left_p_cancel
  results %>%
    filter(field_name == "cust_left_p_cancel") %>%
    select(field_name,label, value) %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of customers who left store") +
    set_theme()
  ggsave(here("results", "figures", "cust_left_p_cancel.jpg"))
  
  results %>%
    filter(field_name == "cust_left_p_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "cust_left_p_cancel_.jpg"))
  
  results %>%
    filter(field_name == "cust_left_p_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "cust_left_p_cancel_m.jpg"))
  
  
  # num_cust_changed_cancel
  results %>%
    filter(field_name == "num_cust_changed_cancel") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "num_cust_changed_cancel" & value == "1" ~ "Aumentó",
      field_name == "num_cust_changed_cancel" & value == "0" ~ "Se mantuvo igual",
      field_name == "num_cust_changed_cancel" & value == "-1" ~ "Disminuyó"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Number of customers: change after canceling") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_changed_cancel.jpg"))
  
  results %>%
    filter(field_name == "num_cust_changed_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "num_cust_changed_cancel_.jpg"))
  
  results %>%
    filter(field_name == "num_cust_changed_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "num_cust_changed_cancel_m.jpg"))
  
  
  # sales_changed_cancel
  results %>%
    filter(field_name == "sales_changed_cancel") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "sales_changed_cancel" & value == "1" ~ "Aumentó",
      field_name == "sales_changed_cancel" & value == "0" ~ "Se mantuvo igual",
      field_name == "sales_changed_cancel" & value == "-1" ~ "Disminuyó"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Sales: change") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_changed_cancel.jpg"))
  
  results %>%
    filter(field_name == "sales_changed_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_changed_cancel_.jpg"))
  
  results %>%
    filter(field_name == "sales_changed_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_changed_cancel_m.jpg"))
  
  
  # sales_incr_p_cancel
  results %>%
    filter(field_name == "sales_incr_p_cancel") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of increase in sales") +
    set_theme()
  ggsave(here("results", "figures", "sales_incr_p_cancel.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_p_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_incr_p_cancel_.jpg"))
  
  results %>%
    filter(field_name == "sales_incr_p_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_incr_p_cancel_m.jpg"))
  
  
  # sales_decr_p_cancel
  results %>%
    filter(field_name == "sales_decr_p_cancel") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of decrease in sales") +
    set_theme()
  ggsave(here("results", "figures", "sales_decr_p_cancel.jpg"))
  
  results %>%
    filter(field_name == "sales_decr_p_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "sales_decr_p_cancel_.jpg"))
  
  results %>%
    filter(field_name == "sales_decr_p_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "sales_decr_p_cancel_m.jpg"))
  
  
  # profits_changed_cancel
  results %>%
    filter(field_name == "profits_changed_cancel") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "profits_changed_cancel" & value == "1" ~ "Aumentó",
      field_name == "profits_changed_cancel" & value == "0" ~ "Se mantuvo igual",
      field_name == "profits_changed_cancel" & value == "-1" ~ "Disminuyó"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("profits: change") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_changed_cancel.jpg"))
  
  results %>%
    filter(field_name == "profits_changed_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_changed_cancel_.jpg"))
  
  results %>%
    filter(field_name == "profits_changed_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_changed_cancel_m.jpg"))
  
  
  # profits_incr_p_cancel
  results %>%
    filter(field_name == "profits_incr_p_cancel") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of increase in profits") +
    set_theme()
  ggsave(here("results", "figures", "profits_incr_p_cancel.jpg"))
  
  results %>%
    filter(field_name == "profits_incr_p_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_incr_p_cancel_.jpg"))
  
  results %>%
    filter(field_name == "profits_incr_p_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_incr_p_cancel_m.jpg"))
  
  
  # profits_decr_p_cancel
  results %>%
    filter(field_name == "profits_decr_p_cancel") %>%
    select(field_name,label, value)  %>%
    filter(!is.na(value)) %>%
    mutate(value = as.numeric(value)) %>%
    filter(value >= 0) %>%
    ggplot(aes(x = value)) +
    geom_histogram() +
    theme_bw() +
    xlab("Percent of decrease in profits") +
    set_theme()
  ggsave(here("results", "figures", "profits_decr_p_cancel.jpg"))
  
  results %>%
    filter(field_name == "profits_decr_p_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "profits_decr_p_cancel_.jpg"))
  
  results %>%
    filter(field_name == "profits_decr_p_cancel") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "profits_decr_p_cancel_m.jpg"))
  
  
  # vat_whom_c
  results %>%
    filter(field_name == "vat_whom_c") %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      field_name == "vat_whom_c" & value == "1" ~ "Todos",
      field_name == "vat_whom_c" & value == "2" ~ "Algunos",
      field_name == "vat_whom_c" & value == "3" ~ "Ninguno"
    )) %>%
    filter(!is.na(value)) %>%
    ggplot(aes(x = value)) +
    geom_histogram(stat = "count") +
    theme_bw() +
    xlab("Who do you VAT to?") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_whom_c.jpg"))
  
  results %>%
    filter(field_name == "vat_whom_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, duration) %>%
    mutate(duration = as.numeric(duration))  %>%
    ggplot(aes(x = duration)) +
    geom_histogram() +
    theme_bw() +
    xlab("Duration (seconds)")   +
    set_theme()
  ggsave(here("results", "figures", "vat_whom_c_.jpg"))
  
  results %>%
    filter(field_name == "vat_whom_c") %>%
    filter(!is.na(value)) %>%
    select(field_name,label, value) %>%
    mutate(value = case_when(
      value != "-7" & value != "-8" ~ "Respondió",
      value == "-7" ~ "No sabe",
      value == "-8" ~ "No quiso responder"
    )) %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_whom_c_m.jpg"))
  
  
  # vat_reason_c
  table_62a <- survey %>%
    filter(successful == 1) %>%
    filter(has_pos == 0 & has_had_pos == 0) %>%
    select("vat_reason_c") %>%
    filter(!is.na(vat_reason_c))
  table_62 <- xtable(table_62a)
  print(table_62, file = here("results", "tables", "table_62.tex"), floating = F,
        latex.environments = NULL, booktabs = T, include.rownames = F)
  
  table_62a %>%
    mutate(vat_reason_c = case_when(
      vat_reason_c != "-777" & vat_reason_c != "-888" ~ "Respondió",
      vat_reason_c == "-777" ~ "No sabe",
      vat_reason_c == "-888" ~ "No quiso responder"
    )) %>%
    rename(value = vat_reason_c)  %>%
    count(value) %>%
    rbind(missing_answers) %>%
    group_by(value) %>% 
    summarise(n = sum(n)) %>% 
    mutate(prop = n/sum(n)) %>%
    ggplot(aes(x = value,y = n)) + 
    geom_col()  +
    geom_text(aes(label = paste0(round(100 * prop, 1), "%")), vjust = -0.25)+
    theme_bw() +
    xlab("Answers") +
    set_theme() +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 9))
  ggsave(here("results", "figures", "vat_reason_c_m.jpg"))
  