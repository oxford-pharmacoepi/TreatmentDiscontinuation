
codes <- importCodelist(here("codelist"))

logMessage("Instantiate acute mi cohort")
cdm$acute_mi <- conceptCohort(
  cdm = cdm,
  name = "acute_mi",
  conceptSet = codes["acute_mi"]
) |>
  requireIsFirstEntry() |>
  addConceptIntersectFlag(
    conceptSet = codes["heart_failure"],
    window = c(-Inf, 0),
    nameStyle = "prior_heart_failure",
    name = "acute_mi"
  ) |>
  mutate(prior_heart_failure = if_else(prior_heart_failure == 1, "Yes", "No")) |>
  compute(name = "acute_mi")

logMessage("Instantiate beta blockers cohort")
cdm$drugs <- conceptCohort(
  cdm = cdm,
  name = "drugs",
  conceptSet = codes["beta_blockers"],
  subsetCohort = "acute_mi"
) |>
  requireCohortIntersect(
    targetCohortTable = "acute_mi",
    window = c(-28, 0),
    atFirst = TRUE
  ) |>
  requireFutureObservation(minFutureObservation = 1)

logMessage("Instantiate death cohort")
cdm$death_cohort <- deathCohort(cdm = cdm, name = "death_cohort", subsetCohort = "drugs")

logMessage("Collapse beta blockers cohorts")
cdm$drugs <- cdm$drugs |>
  copyCohorts(name = "drugs", n = length(gaps)) |>
  renameCohort(newCohortName = sprintf("beta_blockers_%03i", gaps))
for (gap in gaps) {
  cdm$drugs <- cdm$drugs |>
    collapseCohorts(cohortId = sprintf("beta_blockers_%03i", gap), gap = gap)
}

logMessage("Create untreated beta blockers cohorts")
cdm$untreated <- cdm$drugs |>
  padCohortEnd(days = 1L, name = "untreated", requireFullContribution = TRUE) |>
  padCohortDate(days = 0L, cohortDate = "cohort_start_date", indexDate = "cohort_end_date") |>
  renameCohort(newCohortName = sprintf("untreated_%03i", gaps))

logMessage("Bind cohorts together")
cdm <- bind(cdm$acute_mi, cdm$death_cohort, cdm$drugs, cdm$untreated, name = "study_cohorts")

logMessage("Add prior heart failure strata")
cdm$study_cohorts <- cdm$study_cohorts |>
  addCohortIntersectField(
    targetCohortTable = "acute_mi",
    field = "prior_heart_failure",
    window = c(-Inf, 0),
    nameStyle = "prior_heart_failure",
    name = "study_cohorts"
  )

cdm <- dropSourceTable(cdm = cdm, name = c("acute_mi", "drugs", "untreated", "death_cohort"))
