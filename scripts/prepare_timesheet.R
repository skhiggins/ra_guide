#********************************************************************************************
# File name: 		      prepare_timesheet.R
# Creation date:      2022-04-19
# Author:          		César Landín
# Files used:
#   - CSV detailed report from Clockify in Downloads folder.
# Files created:
#   - current_timesheet.csv in Downloads folder.
# Purpose:
# 	- Prepare timesheet.
#********************************************************************************************

#***************** Import packages *****************#
if (!require(pacman)) {install.packages("pacman")}
pacman::p_load(here, tidyverse, magrittr, lubridate)
#*************************************************** #

######################################################
##    (1): Process most recent Clockify timesheet.  ##
######################################################
# (1.1): Define where the downloads folder is located. #
downloads_folder <- "/Users/myusername/Downloads/"
  
# (1.2): Read Clockify report download. #
current_file <- list.files(downloads_folder, pattern = "*.csv")
current_file <- current_file[str_detect(current_file, "Clockify")]
raw <- read_csv(paste0(downloads_folder, current_file))
colnames(raw) <- colnames(raw) %>% str_to_lower() %>% str_replace(" ", "_")

# (1.3): Process variables and sort data by date. #
proc <- raw %>% 
  select(start_date, start_time, end_time, task, description) %>% 
  mutate_at(vars(contains("time")), ~format(parse_date_time(., c("HMS", "HM")), "%H:%M")) %>% 
  mutate(duration = difftime(strptime(end_time, format = "%H:%M"), strptime(start_time, format = "%H:%M"), units = "hours"),
         duration = round(duration, 1)) %>% 
  arrange(start_date, start_time) %>% 
  relocate(duration, .after = end_time)

# (1.4): Save processed report to copy to timesheet. #
write_csv(proc, paste0(downloads_folder, "current_timesheet.csv"))
