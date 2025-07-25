# prepares the `chores` data by `vitals_bind()`ing the saved results
library(tidyverse)
library(vitals)

task_files <- list.files(
  path = "data-raw/chores/tasks",
  pattern = "\\.rds$",
  full.names = TRUE
)

tasks <- list()

get_provider_and_model <- function(chat) {
  p <- chat$get_provider()
  c(p@name, p@model)
}

for (file in task_files) {
  task_name <- tools::file_path_sans_ext(basename(file))
  task_data <- readRDS(file)
  task_samples <- task_data$get_samples()
  provider_and_model <- get_provider_and_model(task_samples$solver_chat[[1]])
  cost <- task_data$get_cost()
  cost <- cost[cost$source == "solver", "price"]
  tasks[[task_name]] <- tibble::tibble(
    name = task_name,
    provider = provider_and_model[1],
    model = provider_and_model[2],
    score = mean(task_samples$score),
    price = cost,
    metadata = list(task_samples)
  )
}

chores <- purrr::list_rbind(tasks)

usethis::use_data(chores, overwrite = TRUE)
