
# survival
logMessage("Run discontinuation as survival")
results$survival <- summariseDiscontinuationAsSurvival(
  cohort = cdm$study_cohorts,
  cohortId = sprintf("beta_blockers_%03i", gaps),
  followUpDays = 730,
  strata = strata
)

# competing risk
logMessage("Run discontinuation as competing risk")
results$competing_risk <- summariseDiscontinuationAsSurvival(
  cohort = cdm$study_cohorts,
  cohortId = sprintf("beta_blockers_%03i", gaps),
  followUpDays = 730,
  competingOutcomeCohortTable = "study_cohorts",
  competingOutcomeCohortId = "death_cohort",
  strata = strata
)

# proportion of patients covered
logMessage("Run discontinuation as proportion of patients covered")
results$ppc <- summariseProportionOfPatientsCovered(
  cohort = cdm$study_cohorts,
  cohortId = sprintf("beta_blockers_%03i", gaps),
  followUpDays = 730,
  strata = strata
)

# multistate
logMessage("Run discontinuation as multistate")
for (gap in gaps) {
  exposed <- sprintf("beta_blockers_%03i", gap)
  unexposed <- sprintf("untreated_%03i", gap)
  tmat <- transMat(
    x = list(c(2, 3), c(1, 3), c()),
    names = c(exposed, unexposed, "death_cohort")
  )
  results[[sprintf("multi_state_%03i", gap)]] <- summariseMultistateProbabilities(
    cohort = cdm$study_cohorts,
    trans = tmat,
    followUpDays = 730,
    strata = strata,
    stateHierarchy = c("death_cohort", exposed, unexposed)
  )
}
