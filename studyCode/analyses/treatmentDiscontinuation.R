
# survival
logMessage("Run discontinuation as survival")
result$survival <- summariseDiscontinuationAsSurvival(
  cohort = cdm$study_cohort,
  cohortId = sprintf("beta_blockers_%03i", gaps),
  followUpDays = 730
)

# competing risk
logMessage("Run discontinuation as competing risk")
result$competing_risk <- summariseDiscontinuationAsSurvival(
  cohort = cdm$study_cohort,
  cohortId = sprintf("beta_blockers_%03i", gaps),
  followUpDays = 730,
  competingOutcomeCohortTable = "study_cohort",
  competingOutcomeCohortId = "death"
)

# proportion of patients covered
logMessage("Run discontinuation as proportion of patients covered")
result$ppc <- summariseProportionOfPatientsCovered(
  cohort = cdm$study_cohort,
  cohortId = sprintf("beta_blockers_%03i", gaps),
  followUpDays = 730
)

# multistate
logMessage("Run discontinuation as multistate")
for (gap in gaps) {
  tmat <- transMat(
    x = list(c(2, 3), c(1, 3), c()),
    names = c(sprintf("beta_blockers_%03i", gap), sprintf("beta_blockers_untreated_%03i", gap), "death")
  )
  result[[sprintf("multi_state_%03i", gap)]] <- summariseMultiStateProbabilities(
    cohort = cdm$study_cohort,
    tmat = tmat,
    followUpDays = 730
  )
}
