check_inherits <- function(x, cls, x_arg = caller_arg(x), call = caller_env()) {
  if (!inherits(x, cls)) {
    cli::cli_abort(
      "{.arg {x_arg}} must be a {.cls {cls}}, not {.obj_type_friendly {x}}",
      call = call
    )
  }

  invisible()
}

cli_system_prompt <-
  paste0(
    readLines(system.file("prompts/cli-replace.md", package = "chores")),
    collapse = "\n"
  )

utils::globalVariables(c(
  "across",
  "caller_arg",
  "caller_env",
  "ch",
  "chores_dataset",
  "everything",
  "mutate",
  "n",
  "rowwise",
  "yes_count"
))
