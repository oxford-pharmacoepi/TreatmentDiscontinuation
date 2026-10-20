# discontinuation term
outcome_terms <- paste0(
  "(",
  paste(
    c(
      "discontinuation[ti]",
      "discontinuing[ti]",
      "discontinued[ti]"#,
      # "treatment cessation[ti]",
      # "therapy cessation[ti]",
      # "treatment interruption[ti]",
      # "drug survival[ti]",
      # "treatment persistence[ti]",
      # "persistence[ti]",
      # "nonpersistence[ti]",
      # "non-persistence[ti]",
      # "adherence[ti]",
      # "nonadherence[ti]",
      # "non-adherence[ti]",
      # "medication compliance[ti]"
    ),
    collapse = " OR "
  ),
  ")"
)

# real world data term
rwd_terms <- paste0(
  "(",
  paste(
    c(
      '"real-world"[tiab]',
      '"real world"[tiab]',
      '"real-world data"[tiab]',
      '"real-world evidence"[tiab]',
      '"observational"[tiab]',
      '"retrospective cohort"[tiab]',
      '"prospective cohort"[tiab]',
      '"cohort study"[tiab]',
      '"cohort studies"[tiab]',
      '"registry"[tiab]',
      '"registries"[tiab]',
      '"claims database"[tiab]',
      '"claims data"[tiab]',
      '"administrative claims"[tiab]',
      '"electronic health records"[tiab]',
      '"electronic medical records"[tiab]',
      '"population-based"[tiab]',
      '"population based"[tiab]',
      '"routine clinical practice"[tiab]'
    ),
    collapse = " OR "
  ),
  ")"
)

# Combine all search blocks
query <- paste(
  outcome_terms,
  "AND",
  rwd_terms,
  "AND",
  "2001:2025[dp]",
  "AND",
  "english[la]",
  "AND",
  "Journal Article[pt]"
)

# matching records
res <- pmQueryTotalCount(query = query)

# retrieve records
records <- pmApiRequest(query = query, limit = res$total_count)

# format
papers <- pmApi2df(records, format = "raw") |>
  as_tibble() |>
  select(
    pmid = "PMID",
    authors = "AU",
    title = "TI",
    abstract = "AB",
    affiliation = "C1",
    publication_year = "PY",
    doi = "DI"
  ) |>
  mutate(
    across(where(is.character), str_trim),
    publication_year = as.integer(publication_year),
    first_author = str_trim(str_split_fixed(authors, ";", 2) [, 1]),
    first_affiliation = str_trim(str_split_fixed(affiliation, ";", 2) [, 1]),
    link = paste0("doi.org/", doi)
  ) |>
  select(
    "pmid", "doi", "link", "publication_year", "first_author", "authors",
    "first_affiliation", "affiliation", "title", "abstract"
  )

logMessage("Number of candidates: {nrow(papers)}")
