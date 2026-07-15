
logMessage("Get counts of cohorts of interest")
results$counts <- summariseCohortCount(cohort = cdm$study_cohorts)

logMessage("Get attrition of cohorts of interest")
results$attrition <- summariseCohortAttrition(cohort = cdm$study_cohorts)

logMessage("Characterise study cohorts")
results$characteristics <- summariseCharacteristics(
  cohort = cdm$study_cohorts,
  strata = strata
)
