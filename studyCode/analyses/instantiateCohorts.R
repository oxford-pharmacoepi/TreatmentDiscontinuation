
codes <- importCodelist(here("codelist"))

logMessage("Instantiate acute mi cohort")
cdm$acute_mi <- conceptCohort(
  cdm = cdm,
  name = "acute_mi",
  conceptSet = codes["acute_mi"]
)

logMessage("Instantiate stroke cohort")
cdm$stroke <- conceptCohort(
  cdm = cdm,
  name = "acute_mi",
  conceptSet = codes["stroke"]
)

logMessage("Instantiate death cohort")
cdm$death_cohort <- deathCohort(cdm = cdm, name = "death_cohort", subsetCohort = "acute_mi")

logMessage("Instantiate beta blockers cohort")
cdm$drugs_mi <- conceptCohort(
  cdm = cdm,
  name = "drugs_mi",
  conceptSet = codes["beta_blockers"],
  subsetCohort = "acute_mi"
) |>
  requireCohortIntersect(
    targetCohortTable = "acute_mi",
    window = c(-28, 0),
    atFirst = TRUE
  )

logMessage("Collapse beta blockers cohorts")
cdm$drugs_mi <- cdm$drugs_mi |>
  copyCohorts(name = "drugs_mi", n = length(gaps)) |>
  renameCohort(newCohortName = sprintf("beta_blockers_%03i", gaps))
for (gap in gaps) {
  cdm$drugs_mi <- cdm$drugs_mi |>
    collapseCohorts(cohortId = sprintf("beta_blockers_%03i", gap), gap = gap)
}

logMessage("Create untreated beta blockers cohorts")
cdm$untreated_mi <- cdm$drugs_mi |>
  padCohortEnd(days = 1L, name = "untreated_mi") |>
  padCohortDate(days = 0L, cohortDate = "cohort_start_date", indexDate = "cohort_end_date") |>
  renameCohort(newCohortName = sprintf("beta_blockers_untreated_%03i", gaps))

logMessage("Instantiate antiplatelets cohort")
cdm$drugs_stroke <- conceptCohort(
  cdm = cdm,
  name = "drugs_stroke",
  conceptSet = codes["antiplatelets"],
  subsetCohort = "stroke"
) |>
  requireCohortIntersect(
    targetCohortTable = "stroke",
    window = c(-28, 0),
    atFirst = TRUE
  )

logMessage("Collapse antiplatelets cohorts")
cdm$drugs_stroke <- cdm$drugs_stroke |>
  copyCohorts(name = "drugs_stroke", n = length(gaps)) |>
  renameCohort(newCohortName = sprintf("antiplatelets_%03i", gaps))
for (gap in gaps) {
  cdm$drugs_stroke <- cdm$drugs_stroke |>
    collapseCohorts(cohortId = sprintf("beta_blockers_%03i", gap), gap = gap)
}

logMessage("Create untreated antiplatelets cohorts")
cdm$untreated_stroke <- cdm$drugs_stroke |>
  padCohortEnd(days = 1L, name = "untreated_stroke") |>
  padCohortDate(days = 0L, cohortDate = "cohort_start_date", indexDate = "cohort_end_date") |>
  renameCohort(newCohortName = sprintf("antiplatelets_untreated_%03i", gaps))

logMessage("Bind mi cohorts together")
cdm <- bind(cdm$acute_mi, cdm$death_cohort, cdm$drugs_mi, cdm$untreated_mi, name = "study_mi")
cdm <- dropSourceTable(cdm = cdm, name = c("acute_mi", "drugs_mi", "untreated_mi"))

logMessage("Bind stroke cohorts together")
cdm <- bind(cdm$stroke, cdm$death_cohort, cdm$drugs_stroke, cdm$untreated_stroke, name = "study_stroke")
cdm <- dropSourceTable(cdm = cdm, name = c("stroke", "death_cohort", "drugs_stroke", "untreated_stroke"))
