#********************************************************************************************
# File name: 		      presentation_versions.R
# Creation date:      2022-08-21
# Author:          		César Landín
# Files used:
# 	- here("presentations", "SmallBusinessesProfitableOpportunities.tex")
# Files created:
#   - here("presentations", "slide_dataset.xlsx")
# Purpose:
# 	- Generate slide dataset from master presentation, and generate different presentation 
#     versions.
#********************************************************************************************

#***************** Import packages *****************#
if (!require(pacman)) {install.packages("pacman")}
pacman::p_load(here, tidyverse, magrittr, tabulator,
               readxl, writexl)
source(here("scripts", "programs", "output_directory.R"))
#*************************************************** #

###############################################################
##    (1): Generate slide dataset from master presentation.  ##
###############################################################
# (1.1): Import master presentation. #
master_pres_name <- "SmallBusinessesProfitableOpportunities.tex"
master_pres <- read_file(here("presentations", master_pres_name))

# (1.2): Get content from title onwards. #
master_pres %<>% str_sub(str_locate(master_pres, fixed("\\maketitle"))[1] + 20, str_length(master_pres))

# (1.3): Get start and end location of slides in presentation. #
frame_loc <- str_locate_all(master_pres, fixed("\\begin{frame}"))[[1]] %>% 
  as_tibble() %>% 
  bind_cols(str_locate_all(master_pres, fixed("\\end{frame}"))[[1]] %>% 
              as_tibble()) %>% 
  mutate(type = "frame")
colnames(frame_loc) <- c("begin_1", "begin_2", "end_1", "end_2", "type")

# (1.4): Add transition slides. #
trans_frames <- str_locate_all(master_pres, fixed("\\begin{transitionframe}"))[[1]] %>% 
  as_tibble() %>% 
  bind_cols(str_locate_all(master_pres, fixed("\\end{transitionframe}"))[[1]] %>% 
              as_tibble()) %>% 
  mutate(type = "transitionframe")
colnames(trans_frames) <- c("begin_1", "begin_2", "end_1", "end_2", "type")
frame_loc %<>% 
  bind_rows(trans_frames) %>% 
  arrange(begin_1)

# (1.5): Generate dataset and list with all slides. #
all_slides <- list()
slide_dataset <- tibble()
for (i in 1:nrow(frame_loc)) {
  current_slide <- str_sub(master_pres, frame_loc$begin_1[i], frame_loc$end_2[i])
  
  # Extract title from current slide
  current_title <- str_sub(current_slide,
                           str_locate(current_slide, fixed(paste0("\\begin{", frame_loc$type[i])))[2] + 3,
                           str_locate_all(current_slide, fixed("}"))[[1]][2,2] - 1)
  current_label <- str_sub(current_slide,
                           str_locate(current_slide, fixed("\\label{s:"))[2] + 1,
                           str_locate_all(current_slide, fixed("}"))[[1]][3,2] - 1)
  all_slides[current_label] <- current_slide
  
  # Keep track of slide title, group and label
  slide_dataset %<>%
    bind_rows(tibble(title = ifelse(frame_loc$type[i] == "frame", current_title, paste(str_to_title(str_split(current_label, "_")[[1]][1]), "Transition")),
                     label = current_label,
                     group = str_split(current_label, "_")[[1]][1]))
}
rm(frame_loc, trans_frames, current_label, current_slide, current_title, master_pres)

# (1.6): Import and update existing slide dataset (if already exists).  #
if (file.exists(here("presentations", "slide_dataset.xlsx"))) {
  current_slide_dataset <- read_excel(here("presentations", "slide_dataset.xlsx"))
  slide_dataset %<>% left_join(current_slide_dataset, by = c("title", "label", "group"))
}

# (1.7): Save slide dataset. #
write_xlsx(slide_dataset, here("presentations", "slide_dataset.xlsx"))
rm(current_slide_dataset, slide_dataset)

########################################################
##    (2): Generate different presentation versions.  ##
########################################################
# (2.0): Function to get currrent OS. #
define_os <- function() {
  output <- Sys.info()["sysname"]
  current_os <- case_when(output == "Darwin" ~ "mac",
                          output == "Windows" ~ "windows")
  return(current_os)
}

# Loop over presentation versions
p_vers <- c(10, 15, 20, 40)

for (p in p_vers) {
  # (2.1): Import slide dataset. #
  slide_dataset <- read_excel(here("presentations", "slide_dataset.xlsx")) %>% 
    select(title, label, group, all_of(as.character(p))) %>% 
    rename(loc = all_of(as.character(p)))
  
  # (2.2): Filter out 0's (slides not in presentation) and missings (new slides not yet assigned to presentations). #
  slide_dataset %<>% filter(loc != 0 & !is.na(loc))
  
  # (2.3): Split slides in main and appendix. #
  main_slides <- slide_dataset %>% filter(loc == 1)
  appendix_slides <- slide_dataset %>% 
    filter(loc == 2) %>% 
    mutate(order = ifelse(title == "Appendix Transition", 0, 1)) %>% 
    arrange(order) %>% 
    select(-order)
  
  # (2.4): Remove buttons from main presentation that reference slides in main presentation or missing slides. #
  pres_slides <- all_slides
  # Loop over all slides
  for (slide in slide_dataset$label) {
    current_slide <- pres_slides[[slide]]
    # Identify buttons
    button_loc <- str_locate_all(current_slide, fixed("\\buttonto"))[[1]] %>% 
      as_tibble() %>% 
      bind_rows(str_locate_all(current_slide, fixed("\\inlinebuttonto"))[[1]] %>% 
                  as_tibble()) %>% 
      mutate(end = start + 100,
             button_text = str_sub(current_slide, start, end),
             button_label = str_extract(button_text, "(?<=\\{).+?(?=\\})") %>% str_remove("s:"),
             slide_main = (button_label %in% main_slides$label) %>% as.numeric(),
             slide_missing = (!(button_label %in% slide_dataset$label)) %>% as.numeric(),
             button_text = str_extract(button_text, "[^\\}]*\\}[^\\}]*\\}"))
    # If slide in main presentation, remove buttons from main presentation that reference slides in main presentation.
    if (slide %in% main_slides$label) {
      remove_slides <- button_loc %>% filter(slide_main == 1)
    }
    # For all slides, remove buttons from presentation that reference slides not in presentation.
    remove_slides %<>% bind_rows(button_loc %>% filter(slide_missing == 1))
    # Remove slides.
    if (nrow(remove_slides) > 0) {
      for (i in 1:nrow(remove_slides)) {
        current_slide %<>% 
          str_remove(fixed(paste0(remove_slides$button_text[i], "\n"))) %>% 
          str_remove(fixed(paste0(remove_slides$button_text[i], "   \n"))) %>% 
          str_remove(fixed(paste0(remove_slides$button_text[i], "\r\n"))) %>% 
          str_remove(fixed(paste0(remove_slides$button_text[i], "   \r\n")))
      }
    }
    # Save slide 
    pres_slides[slide] <- current_slide
  }
  
  # (2.6): Prepare and export output. #
  master_pres <- read_file(here("presentations", master_pres_name))
  output <- master_pres %>% str_sub(1, str_locate_all(master_pres, fixed("\\begin{frame}"))[[1]][4,1]- 1)
  output %<>%
    # Append main slides
    append(pres_slides[names(pres_slides) %in% main_slides$label] %>% 
             unlist() %>% 
             paste(collapse = "\n\n")) %>% 
    # Append transition slide
    append(paste("\n\n",
                 pres_slides$appendix_trans,
                 "\n\n")) %>% 
    append(pres_slides[names(pres_slides) %in% 
                               (appendix_slides %>% filter(label != "appendix_trans") %>% pull(label))] %>% 
             unlist() %>% 
             paste(collapse = "\n\n")) %>% 
    append("\\end{document}")
  
  # (2.7): Fix characters if using Windows #
  if (define_os() != "mac") {
    output %<>% map_chr(\(x) str_replace_all(x, "\r\n", "\n"))
  }
  
  # (2.8): Export presentation. #
  cat(output, file = here("presentations", paste0(str_remove(master_pres_name, ".tex"), "_", p, ".tex")), append = FALSE)
}
