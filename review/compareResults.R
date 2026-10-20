# read reviews
x <- list.files(path = here(), pattern = ".csv$", full.names = TRUE)

name <- basename(path = file_path_sans_ext(x))
nm <- str_split(string = name, pattern = "_")

reviewsData <- tibble(
  reviewer_id = as.integer(seq_along(x)),
  path = x,
  name = name,
  model = map_chr(nm, 2),
  reviewer_number = as.integer(map_chr(nm, 4))
)

reviews <- reviewsData$path |>
  set_names(reviewsData$reviewer_id) |>
  map(\(x) {
    read_csv(x, show_col_types = FALSE) |>
      arrange(id) |>
      rename(paper_id = "id")
  }) |>
  bind_rows(.id = "reviewer_id") |>
  mutate(reviewer_id = as.integer(reviewer_id))

columns <- c(
  "first_author_country", "survival_analysis", "competing_risk_survival",
  "incidence_rates", "proportion_patients_covered",
  "crude_persistence_proportion", "proportion_days_covered",
  "medication_possession_ratio", "multistate_analysis", "other_methods",
  "method_identified", "abstract_sufficient"
)

papers <- reviews |>
  select(!all_of(c("reviewer_id", columns))) |>
  distinct()

reviews <- reviews |>
  select(all_of(c("paper_id", "reviewer_id", columns))) |>
  mutate(across(all_of(columns), as.character)) |>
  pivot_longer(cols = all_of(columns), names_to = "column", values_to = "value")

# agreement results
agreement <- expand_grid(
  reviewer_1 = reviewsData$reviewer_id,
  reviewer_2 = reviewsData$reviewer_id
) |>
  filter(reviewer_1 < reviewer_2) |>
  inner_join(
    reviewsData |>
      select("reviewer_1" = "reviewer_id", "model_1" = "model"),
    by = "reviewer_1"
  ) |>
  inner_join(
    reviewsData |>
      select("reviewer_2" = "reviewer_id", "model_2" = "model"),
    by = "reviewer_2"
  ) |>
  mutate(group = paste0(model_1, "_", model_2)) |>
  select(!c("model_1", "model_2")) |>
  inner_join(
    reviews |>
      rename("reviewer_1" = "reviewer_id", "value_1" = "value"),
    by = "reviewer_1",
    relationship = "many-to-many"
  ) |>
  inner_join(
    reviews |>
      rename("reviewer_2" = "reviewer_id", "value_2" = "value"),
    by = c("reviewer_2", "paper_id", "column")
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

# agreement by paper_id
agreementPaper <- summarise(agreement, agreement = mean(agreement), .by = "paper_id") |>
  arrange(agreement) |>
  mutate(id = row_number())

ggplot(data = agreementPaper, mapping = aes(x = id, y = agreement)) +
  geom_col() +
  scale_y_continuous(labels = label_percent()) +
  scale_x_continuous(breaks = agreementPaper$id, labels = agreementPaper$paper_id) +
  theme(axis.text.x = element_text(angle = 90))

# final review
final <- reviews |>
  summarise(n = n(), .by = c("paper_id", "column", "value")) |>
  filter(n == max(n), .by = c("paper_id", "column")) |>
  select("paper_id", "column", "value")

# duplicated values
final |>
  filter(n() > 1, .by = c("paper_id", "column"))

# plot review
cols <- c("survival_analysis", "competing_risk_survival",
          "incidence_rates", "proportion_patients_covered",
          "crude_persistence_proportion", "proportion_days_covered",
          "medication_possession_ratio", "multistate_analysis", "other_methods")
x <- final |>
  filter(column %in% c(cols, "abstract_sufficient", "method_identified")) |>
  mutate(value = as.logical(value)) |>
  pivot_wider(names_from = "column", values_from = "value") |>
  filter(abstract_sufficient & method_identified) |>
  summarise(across(all_of(cols), \(x) mean(as.numeric(x)))) |>
  pivot_longer(everything())
ggplot(data = x, mapping = aes(x = name, y = value)) +
  geom_col() +
  geom_text(
    aes(label = percent(value, accuracy = 0.1)),
    hjust = -0.1
  ) +
  scale_y_continuous(labels = label_percent()) +
  coord_flip()
