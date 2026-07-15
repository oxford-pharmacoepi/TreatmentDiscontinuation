
for (index in c("mi", "stroke")) {
  cohort <- cdm[[paste0("study_", index)]]
  drug <- swicth(index,
                 "mi" = "beta_blockers",
                 "stroke" = "antiplatelets")
  idExposed <- paste0(drug, "_%03i")
  idUnexposed <- paste0(drug, "_untreated_%03i")

  # survival
  logMessage("Run discontinuation as survival for mi")
  results[[paste0(index, "_survival")]] <- summariseDiscontinuationAsSurvival(
    cohort = cohort,
    cohortId = sprintf(idExposed, gaps),
    followUpDays = 730
  )

  # competing risk
  logMessage("Run discontinuation as competing risk")
  results[[paste0(index, "_competing_risk")]] <- summariseDiscontinuationAsSurvival(
    cohort = cohort,
    cohortId = sprintf(idExposed, gaps),
    followUpDays = 730,
    competingOutcomeCohortTable = "study_mi",
    competingOutcomeCohortId = "death_cohort"
  )

  # proportion of patients covered
  logMessage("Run discontinuation as proportion of patients covered")
  results[[paste0(index, "_ppc")]] <- summariseProportionOfPatientsCovered(
    cohort = cohort,
    cohortId = sprintf(idExposed, gaps),
    followUpDays = 730
  )

  # multistate
  logMessage("Run discontinuation as multistate")
  for (gap in gaps) {
    tmat <- transMat(
      x = list(c(2, 3), c(1, 3), c()),
      names = c(sprintf(idExposed, gap), sprintf(idUnexposed, gap), "death_cohort")
    )
    results[[sprintf("%s_multi_state_%03i", drug, gap)]] <- summariseMultiStateProbabilities(
      cohort = cohort,
      tmat = tmat,
      followUpDays = 730
    )
  }
}
