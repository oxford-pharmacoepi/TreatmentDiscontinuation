
library(pubmedR)
library(dplyr)
library(stringr)
library(countrycode)
library(ellmer)
library(purrr)
library(cli)
library(jsonlite)
library(here)
library(readr)
library(tools)
library(tidyr)
library(ggplot2)
library(scales)
library(omopgenerics)
library(stringi)

model <- "qwen3"
numberReviewers <- 1
outputFolder <- here("results")

createLogFile(logFile = here(outputFolder, "log_{date}_{time}.txt"))

source(here("analyses", "functions.R"))

logMessage("Find initial candidates")
source(here("analyses", "find_candidates.R"))

papers <- papers |>
  slice_sample(n = 100)

logMessage("Screening process")
source(here("analyses", "screening_process.R"))

logMessage("Assess used models")
source(here("analyses", "assess_models.R"))
