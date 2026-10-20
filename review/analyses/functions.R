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
          "qwen3" = "qwen3.8:32b",
          "gpt-oss" = "gpt-oss:20b",
          "gemma3" = "gemma3:27b"
  )
}
runLlm <- function(model, nr, name, sp, prompt, input, type, nb) {
  batches <- split(input$pmid, ceiling(seq_along(input$pmid)/nb))
  
  for (mod in model) {
    for (rev in seq_len(nr)) {
      
      chat <- chat_ollama(model = modelName(mod), system_prompt = sp)
      output <- list()
      for (b in seq_along(batches)) {
        x <- input |>
          filter(pmid %in% batches[[b]]) |>
          toJSON(dataframe = "rows", auto_unbox = TRUE)
        
        prompt_b <- paste(prompt, x, sep = "\n")
        
        out <- chat$chat_structured(prompt_b, type = type)
        
        output[[b]] <- out |>
          map(\(x) paste0(as.character(x), collapse = ";")) |>
          as_tibble()
      }
      output <- output |>
        bind_rows() |>
        write_csv(file = paste0("results/", name, "_", mod, "_", rev, ".csv"))
    }
  }
  
}
