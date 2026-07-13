
logMessage("Get counts of cohorts of interest")
results$counts <- summariseCohortCounts(cohort = cdm$study_cohorts)

logMessage("Get attrition of cohorts of interest")
results$attrition <- summariseCohortAttrition(cohort = cdm$study_cohorts)

logMessage("Characterise study cohorts")
results$characteristics <- summariseCharacteristics(cohort = cdm$study_cohorts)

logMessage("Get code use of cohorts of interest")
results$code_use <- summariseCohortCodeUse(
  cdm = cdm,
  cohortTable = "study_cohorts",
  cohortId = c("acute_mi", "beta_blockers_000")
)
