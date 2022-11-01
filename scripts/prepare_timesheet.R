#********************************************************************************************
# File name: 		      prepare_timesheet.R
# Creation date:      2022-04-19
# Author:          		César Landín
# Purpose:
# 	- Prepare timesheet.
#********************************************************************************************

#***************** Import packages *****************#
suppressPackageStartupMessages(
  if (!require(pacman)) {install.packages("pacman")}
)
pacman::p_load(here, tidyverse, magrittr, lubridate)
#*************************************************** #

################################
##    (1): Prepare timesheet.  #
################################
# (1.1): Identify Clockify download. #
downloads_folder <- here("/Users/cesarlandin/Downloads/")
current_file <- list.files(downloads_folder, pattern = "*.csv")
current_file <- current_file[str_detect(current_file, "Clockify")]

# (1.2): Read file. #
raw <- read_csv(str_c(downloads_folder, current_file),
                show_col_types = FALSE) %>% 
  rename_all(~str_to_lower(.) %>% str_replace(" ", "_"))

# (1.3): Process timesheet. #
proc <- raw %>% 
  # Keep reduced set of variables
  select(start_date, start_time, end_time, task, description) %>% 
  # Change parsing to ensure compatibility with Excel
  mutate_at(vars(contains("time")), ~format(parse_date_time(., c("HMS", "HM")), "%H:%M")) %>% 
  # Calculate duraction (best practice is to extend formula in Excel either way)
  mutate(duration = difftime(strptime(end_time, format = "%H:%M"), strptime(start_time, format = "%H:%M"), units = "hours"),
         duration = round(duration, 1)) %>% 
  # Arrange and relocate variables (match timesheet formatting)
  arrange(start_date, start_time) %>% 
  relocate(duration, .after = end_time)

# (1.4): Save processed timesheet. #
write_csv(proc, str_c(downloads_folder, "current_timesheet.csv"))
# Final step: copy and paste this into timesheet Excel.
