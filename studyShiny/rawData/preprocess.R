# shiny is prepared to work with this resultList:
resultList <- list(
  summarise_omop_snapshot = list(result_type = "summarise_omop_snapshot"),
  summarise_observation_period = list(result_type = "summarise_observation_period"),
  code_use = list(result_type = "code_use"),
  summarise_cohort_count = list(result_type = "summarise_cohort_count"),
  summarise_cohort_attrition = list(result_type = "summarise_cohort_attrition"),
  summarise_characteristics = list(result_type = "summarise_characteristics"),
  summarise_proportion_of_patients_covered = list(result_type = "summarise_proportion_of_patients_covered"),
  summarise_log_file = list(result_type = "summarise_log_file"),
  summarise_multistate_probabilities = list(result_type = "summarise_multistate_probabilities"),
  single_survival = list(result_type = "summarise_discontinuation_as_survival", competing_outcome = "none"),
  competing_survival = list(result_type = "summarise_discontinuation_as_survival", competing_outcome = "death_cohort"),
  discontinuation = list(result_type = c("summarise_discontinuation_as_survival", "summarise_proportion_of_patients_covered", "summarise_multistate_probabilities"))
)

source(file.path(getwd(), "functions.R"))

result <- omopgenerics::importSummarisedResult(file.path(getwd(), "rawData"))
data <- prepareResult(result, resultList)
values <- getValues(result, resultList)

# edit choices and values of interest
choices <- values
selected <- getSelected(values)

save(data, choices, selected, values, file = file.path(getwd(), "data", "studyData.RData"))

rm(result, values, choices, selected, resultList, data)
