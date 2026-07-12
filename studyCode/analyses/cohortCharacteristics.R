
logMessage("Get counts of cohorts of interest")
result$counts <- summariseCohortCounts(cohort = cdm$study_cohorts)

logMessage("Get attrition of cohorts of interest")
result$attrition <- summariseCohortAttrition(cohort = cdm$study_cohorts)

logMessage("Characterise study cohorts")
result$characteristics <- summariseCharacteristics(cohort = cdm$study_cohorts)

logMessage("Get code use of cohorts of interest")
result$characteristics <- summariseCohortCodeUse(
  cdm = cdm,
  cohortTable = "study_cohorts",
  cohortId = c("acute_mi", "beta_blockers_000")
)
