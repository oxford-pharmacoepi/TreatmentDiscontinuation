
# Check codeToRun inputs ----
validateCdmArgument(
  cdm = cdm,
  requiredTables = c(
    "person", "observation_period", "condition_occurrence", "drug_exposure",
    "concept"
  )
)
assertNumeric(min_cell_count)

# Create a log file ----
createLogFile(logFile = tempfile(pattern = "log_{date}_{time}"))
logMessage("LOG CREATED")

# Define analysis settings -----
study_period <- c(as.Date(NA), as.Date(NA))
gaps <- seq(from = 0, to = 120, by = 10)

# Initialise list to store results as we go -----
results <- list()

# Analyses -----
logMessage("Extract omop snapshot")
results[["snapshot"]] <- summariseOmopSnapshot(cdm)

logMessage("Summarise observation period")
results[["obs_period"]] <- summariseObservationPeriod(cdm)

logMessage("Instantiating study cohorts")
source(here("analyses", "instantiateCohorts.R"))

logMessage("Characterisa cohorts")
source(here("analyses", "cohortCharacteristics.R"))

logMessage("Treatment discontinuation analyses")
source(here("analyses", "treatmentDiscontinuation.R"))

# Finish ----
exportSummarisedResult(
  results,
  minCellCount = min_cell_count,
  fileName = "results_{cdm_name}_{date}.csv",
  path = here("results")
)

cli_alert_success("Study finished")
