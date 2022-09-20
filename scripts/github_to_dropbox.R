#********************************************************************************************
# File name: 		      github_to_dropbox.R
# Creation date:      2022-06-29
# Author:          		César Landín
# Files used:
# 	- here("git_log.txt")
# Files created:
#   - Multiple files in Dropbox folder.
# Purpose:
# 	- Mirror GitHub commits in Dropbox folder.
#********************************************************************************************

#***************** Import packages *****************#
suppressMessages(
  if (!require(pacman)) {install.packages("pacman")}
)
pacman::p_load(here, dplyr, purrr, stringr, tabulator)
# Faster than loading tidyverse
#*************************************************** #

##############################################################
############         ONLY UPDATE THIS LINE        ############    
##############################################################

dropbox_folder <- "/Users/cesarlandin/Dropbox/dropbox_folder_name/"

##############################################################

###############################################################
##    (1): Generate long-term elasticity regression tables.  ##
###############################################################
# (1.1): Import most recent Git log. #
git_log <- read.table(here("git_log.txt"), skip = 5, sep = "\t", fill = TRUE,
                      col.names = c("mod_type", "old_file", "new_file"),
                      na.strings = c("", "NA", "NA")) %>% 
  filter(!is.na(old_file)) %>% 
  mutate(mod_type = case_when(mod_type == "A" ~ "add",
                              mod_type == "M" ~ "modify",
                              mod_type == "D" ~ "delete",
                              str_detect(mod_type, "R") ~ "rename"),
         new_file = ifelse(mod_type %in% c("add", "modify"), old_file, new_file))

# (1.2): Define process for each mod type. #
# git_log %>% tab(mod_type)
# If add: copy new file
# If modify: replace old file with new file
# If delete: delete file
# If rename: delete old file, copy new file.
# Summary:
# If R or D: delete old file
# If A or R or M: copy new file

# (1.3): Delete files. #
delete_from_dropbox <- function(file) {
  file.remove(str_c(dropbox_folder, file))
}
files_delete <- git_log %>% filter(mod_type %in% c("delete", "rename")) %>% pull(old_file)
if (!is_empty(files_delete)) {invisible(lapply(files_delete, delete_from_dropbox))}

# (1.4): Copy files. #
files_copy <- git_log %>% filter(mod_type %in% c("add", "modify", "rename")) %>% pull(new_file)
copy_to_dropbox <- function(file) {
  file.copy(str_c(here(), "/", file), 
            str_c(dropbox_folder, file), 
            overwrite = TRUE)
}
if (!is_empty(files_copy)) {invisible(lapply(files_copy, copy_to_dropbox))}
