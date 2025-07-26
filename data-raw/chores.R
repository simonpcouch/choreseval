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

tokens_per_second <- function(solver_chat, solver_metadata) {
  tokens <- solver_chat$get_tokens()
  tokens <- tokens$tokens[tokens$role == "assistant"]
  tokens / solver_metadata[1]
}

avg_tokens_per_second <- function(samples) {
  toks <- purrr::pmap_dbl(
    samples[c("solver_chat", "solver_metadata")],
    tokens_per_second
  )
  mean(toks)
}

is_local <- function(chat) {
  identical(chat$get_provider()@name, "Ollama")
}

n_parameters <- function(chat) {
  if (!is_local(chat)) {
    return(NA_character_)
  }

  model_name <- chat$get_provider()@model
  match <- regexpr("([0-9.]+)b", model_string, ignore.case = TRUE)
  if (match == -1) {
    return(lookup_n_parameters(model_name))
  }

  toupper(regmatches(model_name, match))
}

lookup_n_parameters <- function(model_name) {
  switch(
    model_name,
    magistral = "24B",
    NA_character_
  )
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
    tokens_per_s = avg_tokens_per_second(task_samples),
    local = if_else(is_local(task_samples$solver_chat[[1]]), "Yes", "No"),
    n_parameters = n_parameters(task_samples$solver_chat[[1]])
  )
}

chores <- purrr::list_rbind(tasks)

usethis::use_data(chores, overwrite = TRUE)
