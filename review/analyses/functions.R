attritionLine <- function(attrition, papers, reason) {
  id <- max(attrition$attrition_id)
  nr <- attrition$number_records[attrition$attrition_id == id]
  nc <- nrow(papers)
  attrition |>
    union_all(
      tibble(
        attrition_id = id + 1L,
        number_records = nc,
        excluded_records = nr - nc,
        reason = reason
      )
    )
}
modelName <- function(key) {
  switch (key,
          "qwen3" = "qwen3.8:27b",
          "gpt-oss" = "gpt-oss:20b",
          "gemma3" = "gemma3:27b"
  )
}
runLlm <- function(model, nr, name, sp, prompt, input, type, nb) {
  batches <- split(seq_len(nrow(input)), ceiling(seq_len(nrow(input)) / nb))

  all_results <- list()

  for (mod in model) {
    for (rev in seq_len(nr)) {

      reviewer_results <- list()

      for (b in seq_along(batches)) {

        rows <- batches[[b]]
        x <- input[rows, , drop = FALSE]
        x_p <- toJSON(x, dataframe = "rows", auto_unbox = FALSE, na = "null")
        prompt_b <- paste(prompt, x_p, sep = "\n\n")

        cli_inform("Processing {name}: model {mod}, reviewer {rev}/{nr}, batch {b}/{length(batches)}")

        reviewer_results[[b]] <- attemptLlm(
          model = modelName(mod),
          system_prompt = sp,
          prompt = prompt_b,
          type = type,
          ids = x$pmid
        )
      }

      reviewer_results <- bind_rows(reviewer_results)
      output_path <- here("results", paste0(name, "_", mod, "_", rev, ".csv"))
      write_csv(reviewer_results, file = output_path)

      all_results[[paste(mod, rev, sep = "_")]] <- reviewer_results |>
        mutate(model = mod, reviewer = rev)
    }
  }

  bind_rows(all_results)
}
attemptLlm <- function(model, system_prompt, prompt, type, ids, attempts = 3) {

  for (attempt in seq_len(attempts)) {

    chat <- chat_ollama(
      model = model,
      system_prompt = system_prompt,
      params = params(temperature = 0)
    )

    response <- tryCatch(
      chat$chat_structured(prompt, type = type),
      error = function(e) conditionMessage(e)
    )

    if (!is.character(response)) {
      response <- tryCatch(
        as_tibble(response$results),
        error = function(e) NULL
      )
    }

    valid <- !is.character(response) &&
      "pmid" %in% names(response) &&
      nrow(response) == length(ids) &&
      !anyNA(response$pmid) &&
      !anyDuplicated(as.character(response$pmid)) &&
      identical(as.character(response$pmid), as.character(ids))

    if (valid) {
      return(response)
    } else if (attempt < attempts) {
      cli_inform("Retrying (attempt {attempt + 1L} of {attempts}).")
    } else {
      cli_abort(c(x = "LLM failed"))
    }
  }
}
