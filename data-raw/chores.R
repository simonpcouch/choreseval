# prepares the `chores` data by `vitals_bind()`ing the saved results
library(tidyverse)
library(vitals)

task_files <- list.files(
  path = "data-raw/chores/tasks",
  pattern = "\\.rds$",
  full.names = TRUE
)

task_data <- list()

split_on_first_hyphen <- function(string) {
  pos <- regexpr("-", string)
  if (pos == -1) {
    c(string, "")
  } else {
    c(substr(string, 1, pos - 1), substr(string, pos + 1, nchar(string)))
  }
}

for (file in task_files) {
  task_name <- tools::file_path_sans_ext(basename(file))
  provider_and_model <- split_on_first_hyphen(task_name)
  task_data <- readRDS(file)
  task_samples <- task_data$get_samples()
  tasks[[task_name]] <- tibble::tibble(
    provider = provider_and_model[1],
    model = provider_and_model[2],
    score = mean(task_samples$score),
    metadata = list(task_samples)
  )
}

chores <- purrr::list_rbind(tasks)

usethis::use_data(chores, overwrite = TRUE)
