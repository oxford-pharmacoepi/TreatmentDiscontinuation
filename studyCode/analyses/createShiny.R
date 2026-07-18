
result <- omopgenerics::importSummarisedResult("/Users/martics/Downloads/results_CPRD GOLD_2026_07_18.csv")

panels <- OmopViewer::panelDetailsFromResult(result = result, includeOneChoiceFilters = FALSE)

panels$summarise_discontinuation_as_survival <- NULL
panels$single_survival <- OmopViewer::getPanel("default")
panels$single_survival$data <- list(result_type = "summarise_discontinuation_as_survival", competing_outcome = "none")
panels$competing_survival <- OmopViewer::getPanel("default")
panels$competing_survival$data <- list(result_type = "summarise_discontinuation_as_survival", competing_outcome = "death_cohort")
panels$discontinuation <- OmopViewer::getPanel("default")
panels$discontinuation$data <- list(result_type = c("summarise_discontinuation_as_survival", "summarise_proportion_of_patients_covered", "summarise_multistate_probabilities"))

OmopViewer::exportStaticApp(
  result = result,
  directory = "/Users/martics/Documents/GitHub/TreatmentDiscontinuation/",
  logo = "ohdsi",
  title = "Treatment Discontinuation",
  background = TRUE,
  summary = FALSE,
  report = TRUE,
  panelDetails = panels,
  panelStructure = list(
    "Database" = c("summarise_omop_snapshot", "summarise_observation_period"),
    "Characterisation" = c("code_use", "summarise_cohort_count", "summarise_cohort_attrition", "summarise_characteristics"),
    "Discontinuation" = c("single_survival", "competing_survival", "summarise_proportion_of_patients_covered", "summarise_multistate_probabilities", "discontinuation")
  ),
  theme = "darwin",
  updateButtons = FALSE,
  includeOneChoiceFilters = FALSE,
  open = FALSE
)
