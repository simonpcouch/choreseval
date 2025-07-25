#' The chores solver
#'
#' @description
#' Pass this function to `Task$new()` as the solver to process input prompts
#' from the chores dataset with a specified language model.
#'
#' @param inputs Character vector of user prompts, likely from
#'  `chores_dataset$input`.
#' @param ... Additional arguments passed to the `chat_parallel` method.
#' @param solver_chat An ellmer chat object to use for solving the prompts.
#'   This must be a Chat object from the ellmer package.
#'
#' @return A list with the following components:
#' \describe{
#'   \item{result}{Character vector of model responses, one for each input.}
#'   \item{solver_chat}{List of Chat objects used to generate each response,
#'     with the same length as `inputs`.}
#' }
#'
#' @seealso [chores_dataset] for the dataset this solver processes, and
#'  [chores_task()] to combine this solver with the chores dataset and scorer.
#' @export
chores_solver <- function(inputs, ..., solver_chat) {
  check_inherits(solver_chat, "Chat")

  ch <- solver_chat$clone()
  ch$set_turns(list())
  ch$set_system_prompt(cli_system_prompt)

  # TODO: ultimately, these timings need to be request-by-request.
  # https://github.com/tidyverse/ellmer/issues/479
  # Provides that don't support parallel chatting (namely, ollama),
  # will get a reasonable average per-request, while provides that do
  # support parallelism will get overoptimistic timings.
  # We purposefully avoid system.time for its error handling
  time_start <- proc.time()
  res <- ellmer::parallel_chat(ch, as.list(inputs), ...)
  time_end <- proc.time()
  average_timing <- (time_end["elapsed"] - time_start["elapsed"]) /
    length(inputs)

  list(
    result = purrr::map_chr(res, function(c) c$last_turn()@text),
    solver_chat = res,
    solver_metadata = list(duration = unname(average_timing))
  )
}
