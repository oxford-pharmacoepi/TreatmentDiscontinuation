# read reviews
x <- list.files(path = here("results"), pattern = ".csv$", full.names = TRUE)

name <- basename(path = file_path_sans_ext(x))
nm <- str_split(string = name, pattern = "_")

reviewsData <- tibble(
  review_id = as.integer(seq_along(x)),
  path = x,
  name = name,
  type = map_chr(nm, 1),
  model = map_chr(nm, 2),
  reviewer_number = as.integer(map_chr(nm, 3))
)

reviews <- reviewsData$path |>
  set_names(reviewsData$review_id) |>
  map(\(x) {
    read_csv(x, col_types = "c") |>
      arrange(pmid) |>
      pivot_longer(!"pmid")
  }) |>
  bind_rows(.id = "review_id") |>
  mutate(review_id = as.integer(review_id))

types <- unique(reviewsData$type)

for (typ in types) {
  
  ids <- reviewsData$review_id[reviewsData$type == typ]
  
  # agreement results
  agreement <- expand_grid(review_1 = ids, review_2 = ids) |>
    filter(review_1 < review_2) |>
    inner_join(
      reviewsData |>
        select("review_1" = "review_id", "model_1" = "model"),
      by = "review_1"
    ) |>
    inner_join(
      reviewsData |>
        select("review_2" = "review_id", "model_2" = "model"),
      by = "review_2"
    ) |>
    mutate(group = paste0(model_1, "_", model_2)) |>
    select(!c("model_1", "model_2")) |>
    inner_join(
      reviews |>
        rename("review_1" = "review_id", "value_1" = "value"),
      by = "review_1",
      relationship = "many-to-many"
    ) |>
    inner_join(
      reviews |>
        rename("review_2" = "review_id", "value_2" = "value"),
      by = c("review_2", "pmid", "name")
    ) |>
    mutate(agreement = coalesce(as.numeric(value_1 == value_2 | (is.na(value_1) & is.na(value_2))), 0)) |>
    select(!c("value_1", "value_2"))
  
  # agreement by comparison
  agreementOverall <- summarise(agreement, agreement = mean(agreement), .by = "group")
  ggplot(data = agreementOverall, mapping = aes(x = group, y = agreement)) +
    geom_col() +
    geom_text(
      aes(label = percent(agreement, accuracy = 0.1)),
      hjust = -0.1
    ) +
    scale_y_continuous(labels = label_percent()) +
    coord_flip()
  
  # agreement by column
  agreementColumn <- summarise(agreement, agreement = mean(agreement), .by = "column")
  ggplot(data = agreementColumn, mapping = aes(x = column, y = agreement)) +
    geom_col() +
    geom_text(
      aes(label = percent(agreement, accuracy = 0.1)),
      hjust = -0.1
    ) +
    scale_y_continuous(labels = label_percent()) +
    coord_flip()
  
  # agreement by pmid
  agreementPaper <- summarise(agreement, agreement = mean(agreement), .by = "pmid") |>
    arrange(agreement) |>
    mutate(id = row_number())
  ggplot(data = agreementPaper, mapping = aes(x = id, y = agreement)) +
    geom_col() +
    scale_y_continuous(labels = label_percent()) +
    scale_x_continuous(breaks = agreementPaper$id, labels = agreementPaper$pmid) +
    theme(axis.text.x = element_text(angle = 90))
}
