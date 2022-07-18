#********************************************************************************************
# File name: 		      gen_figures.R
# Creation date:      2022-05-03
# Author:          		César Landín
# Files used:
# 	- .eps figures in here("results", "figures")
# Files created:
#   - here("results", "notes", "all_eps_figures.tex")
# Purpose:
# 	- Generate all eps figures without adding figures to all_figures pdf 
#     (for example, presentation version of figures).
#********************************************************************************************

#***************** Import packages *****************#
if (!require(pacman)) {install.packages("pacman")}
pacman::p_load(here, magrittr)
#*************************************************** #

######################################
##    (1): Export all eps figures.  ##
######################################
# (1.1): Get list of all files. #
convert_files <- list.files(here("results", "figures"), pattern = "*.eps")

# (1.2): Generate and export tex with all figures. #
text <- character()
for (i in 1:length(convert_files)) {
  text %<>%
    append(paste0("\\begin{figure}[H] \n",
                  "\\includegraphics[width = 0.75\\textwidth]{./results/figures/", convert_files[i], "} \n",
                  "\\end{figure} \n"))
}
write(text, here("results", "notes", "all_eps_figures.tex"))
