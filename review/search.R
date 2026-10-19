
library(pubmedR)
library(dplyr)
library(stringr)
library(countrycode)
library(ellmer)
library(purrr)
library(cli)
library(jsonlite)
library(here)
library(readr)
library(tools)
library(tidyr)
library(ggplot2)
library(scales)

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

# date range
date_filter <- '"2001/01/01"[dp] : "2025/12/31"[dp]'

# Combine all search blocks
query <- paste(
  outcome_terms,
  "AND",
  rwd_terms,
  "AND",
  date_filter
)

# matching records
res <- pmQueryTotalCount(query = query)

print(res$total_count)

# retrieve records
D <- pmApiRequest(query = query, limit = res$total_count)

# format
M <- pmApi2df(D, format = "bibliometrix")

# Helper to safely retrieve a column
get_col <- function(df, col) {
  if (col %in% names(df)) {
    as.character(df[[col]])
  } else {
    rep(NA_character_, nrow(df))
  }
}

# Extract first author from semicolon-separated names
get_first_author <- function(authors) {
  str_trim(str_split_fixed(
    authors, ";", 2
  )[, 1])
}

# Read the original XML-structured list before pmApi2df flattens affiliations.
get_first_author_affiliations <- function(records) {
  node_text <- function(node) {
    if (is.null(node)) return("")
    if (is.character(node)) return(paste0(node, collapse = ""))
    children <- node[names(node) != ".attrs"]
    paste0(vapply(children, node_text, character(1)), collapse = "")
  }
  
  ids <- vapply(records, function(record) {
    node_text(record[["MedlineCitation"]][["PMID"]])
  }, character(1))
  
  affiliations <- lapply(records, function(record) {
    authors <- record[["MedlineCitation"]][["Article"]][["AuthorList"]]
    authors <- authors[names(authors) == "Author"]
    if (length(authors) == 0L) return(NA_character_)
    
    first_author <- authors[[1L]]
    info <- first_author[names(first_author) == "AffiliationInfo"]
    values <- vapply(info, function(item) {
      node_text(item[["Affiliation"]])
    }, character(1))
    values <- unique(str_squish(values))
    values <- values[!is.na(values) & nzchar(values)]
    if (length(values) == 0L) return(NA_character_)
    values
  })
  
  tibble(
    id = unname(ids),
    first_author_affiliation = unname(vapply(affiliations, function(values) {
      if (all(is.na(values))) return(NA_character_)
      paste(values, collapse = "; ")
    }, character(1))),
    first_listed_affiliation = unname(vapply(affiliations, function(values) {
      values[[1L]]
    }, character(1)))
  )
}

first_author_affiliations <- get_first_author_affiliations(D$data)

# Build the review dataset
papers <- tibble(
  id = get_col(M, "PMID"),
  authors = get_col(M, "AU"),
  first_author = get_first_author(get_col(M, "AU")),
  first_author_afiliation = first_author_affiliations$first_author_affiliation[
    match(get_col(M, "PMID"), first_author_affiliations$id)
  ],
  title = get_col(M, "TI"),
  abstract = get_col(M, "AB"),
  year_of_publication = suppressWarnings(as.integer(get_col(M, "PY"))),
  doi = get_col(M, "DI"),
  link = paste0("doi.org/", doi)
)

# eliminate missing title
nr <- nrow(papers)
papers <- papers |>
  filter(!is.na(title) & nzchar(str_trim(title)))
cli_inform(c(i = "{nr - nrow(papers)} eliminated papers because they do not have title in pubmed."))

# eliminate missing abstracts
nr <- nrow(papers)
papers <- papers |>
  filter(!is.na(abstract) & nzchar(str_trim(abstract)))
cli_inform(c(i = "{nr - nrow(papers)} eliminated papers because they do not have abstract in pubmed."))

papers <- papers |>
  slice_sample(n = 100)

for (mod in c("qwen3", "gpt-oss", "gemma3")) {
  
  model <- switch (mod,
    "qwen3" = "qwen3:32b",
    "gpt-oss" = "gpt-oss:20b",
    "gemma3" = "gemma3:27b"
  )
  
  # iterate
  for (ver in 1:5) {
    
    # get afiliations
    source(here("assess_afiliation.R"))
    
    # get models flags
    source(here("assess_models.R"))
    
    x <- papers |>
      left_join(afiliations, by = "first_author_afiliation") |>
      left_join(models_flags, by = "id")
    
    write_csv(x, file = paste0("papers_", mod, "_ver_", ver,".csv"))
  }
  
}

# summary
# cols <- c("survival_analysis", "competing_risk_survival", "incidence_rates",
#           "proportion_patients_covered", "crude_persistence_proportion", "pdc",
#           "mpr", "multistate_analysis")
# papers |>
#   mutate(
#     other_methods_only = method_identified &
#       rowSums(across(all_of(cols)), na.rm = TRUE) == 0
#   ) |>
#   summarise(
#     across(all_of(cols), \(x) sum(x, na.rm = TRUE) / n() * 100),
#     other_methods = sum(other_methods_only, na.rm = TRUE) / n() * 100,
#     no_method_identified = sum(!method_identified, na.rm = TRUE) / n() * 100
#   )
