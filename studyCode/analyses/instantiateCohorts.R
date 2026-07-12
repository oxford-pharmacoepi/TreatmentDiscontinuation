
codes <- importCodelist(here("codelist"))

logMessage("Instantiate acute mi cohort")
cdm$acute_mi <- conceptCohort(
  cdm = cdm,
  name = "acute_mi",
  conceptSet = codes["acute_mi"]
)

logMessage("Instantiate death cohort")
cdm$death_cohort <- deathCohort(cdm = cdm, name = "death_cohort", subsetCohort = "acute_mi")

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
  )

logMessage("Collapse beta blockers cohorts")
cdm$drugs <- cdm$drugs |>
  copyCohorts(name = "drugs", n = length(gaps)) |>
  renameCohort(newCohortName = sprintf("beta_blockers_%03i", gaps))
for (gap in gaps) {
  cdm$drugs <- cdm$drugs |>
    collapseCohorts(cohortId = sprintf("beta_blockers_%03i", gap), gap = gap)
}

logMessage("Create untreated cohorts")
cdm$untreated <- cdm$drugs |>
  padCohortDate(
    days = 1L,
    cohortDate = "cohort_start_date",
    indexDate = "cohort_end_date",
    name = "untreated"
  ) |>
  renameCohort(newCohortName = sprintf("beta_blockers_untreated_%03i", gaps))

logMessage("Bind cohorts together")
cdm <- bind(cdm$acute_mi, cdm$death_cohort, cdm$drugs, name = "study_cohorts")
cdm <- dropSourceTable(cdm = cdm, name = c("acute_mi", "death_cohort", "drugs"))
