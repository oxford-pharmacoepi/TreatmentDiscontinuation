
x <- finalDataset |>
  summarise(across(is.logical, \(x) mean(as.numeric(x)))) |>
  pivot_longer(everything())

ggplot(data = x, mapping = aes(x = name, y = value)) +
  geom_col() +
  geom_text(
    aes(label = percent(value, accuracy = 0.1)),
    hjust = -0.1
  ) +
  scale_y_continuous(labels = label_percent()) +
  coord_flip()
