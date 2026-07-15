
# survival
logMessage("Run discontinuation as survival for mi")
results$survival <- summariseDiscontinuationAsSurvival(
  cohort = cdm$study_cohort,
  cohortId = sprintf("beta_blockers_%03i", gaps),
  followUpDays = 730,
  strata = strata
)

# competing risk
logMessage("Run discontinuation as competing risk")
results$competing_risk <- summariseDiscontinuationAsSurvival(
  cohort = cdm$study_cohort,
  cohortId = sprintf("beta_blockers_%03i", gaps),
  followUpDays = 730,
  competingOutcomeCohortTable = "study_cohort",
  competingOutcomeCohortId = "death_cohort",
  strata = strata
)

# proportion of patients covered
logMessage("Run discontinuation as proportion of patients covered")
results$ppc <- summariseProportionOfPatientsCovered(
  cohort = cdm$study_cohort,
  cohortId = sprintf("beta_blockers_%03i", gaps),
  followUpDays = 730,
  strata = strata
)

# multistate
logMessage("Run discontinuation as multistate")
for (gap in gaps) {
  tmat <- transMat(
    x = list(c(2, 3), c(1, 3), c()),
    names = c(sprintf("beta_blockers_%03i", gap), sprintf("untreated_%03i", gap), "death_cohort")
  )
  results[[sprintf("multi_state_%03i", gap)]] <- summariseMultiStateProbabilities(
    cohort = cdm$study_cohort,
    tmat = tmat,
    followUpDays = 730,
    strata = strata
  )
}
