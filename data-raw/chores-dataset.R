library(tidyverse)
library(jsonlite)

chores_dataset <-
  list.files(
    "data-raw/chores-dataset",
    pattern = "*.json",
    full.names = TRUE
  ) %>%
  map(function(.x) {
    .x <- fromJSON(.x)
    as_tibble(.x)
  }) %>%
  list_rbind() %>%
  arrange(id) %>%
  rename(input = user) %>%
  select(-helper) %>%
  relocate(input, .after = id) %>%
  mutate(id = str_replace(id, "cli-", "")) %>%
  as_tibble()

usethis::use_data(chores_dataset, overwrite = TRUE)
