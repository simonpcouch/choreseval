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
chores_solver <- function(
  inputs,
  ...,
  solver_chat,
  disable_thinking = FALSE,
  push_system_prompt = FALSE
) {
  check_inherits(solver_chat, "Chat")

  ch <- solver_chat$clone()
  ch$set_turns(list())
  ch$set_system_prompt(cli_system_prompt)

  # We purposefully avoid system.time for its error handlers.
  # Solve in sequence rather than in parallel so we can get better
  # tokens/s estimates (and to lessen the impact of rate limiting
  # on those estimates for remote models).
  res <- vector("list", length = length(inputs))
  timings <- vector("numeric", length = length(inputs))

  withr::local_options(cli.progress_show_after = 0)
  cli::cli_progress_bar("Solving", total = length(inputs))
  cli::cli_progress_update(inc = 0)
  for (i in seq_along(inputs)) {
    input <- inputs[i]
    # Allow turning off <think></think> for ollama models (#2)
    if (isTRUE(disable_thinking)) {
      input <- paste0(c(input, disable_thinking_keyword(ch)), collapse = "\n\n")
    }
    ch_i <- ch$clone()
    # Optionally inline the contents of the system prompt into the user turn,
    # as recommended by some ollama models (#2)
    if (isTRUE(push_system_prompt)) {
      input <- paste0(c(ch_i$get_system_prompt(), input), collapse = "\n\n")
      ch_i$set_system_prompt(NULL)
    }
    time_start <- proc.time()
    ch_i$chat(input, echo = FALSE)
    time_end <- proc.time()
    res[[i]] <- ch_i
    timings[i] <- unname(time_end["elapsed"] - time_start["elapsed"])
    cli::cli_progress_update()
  }
  cli::cli_progress_done()

  list(
    result = purrr::map_chr(res, function(c) c$last_turn()@text),
    solver_chat = res,
    solver_metadata = purrr::map(timings, function(t) {
      list(duration = t, thinking_disabled = disable_thinking)
    })
  )
}

# fmt: skip
disable_thinking_keywords <- tibble::tribble(
  ~model, ~keyword,
  "qwen3:14b", "\\no_think"
)

disable_thinking_keyword <- function(chat) {
  chat_model <- chat$get_provider()@model
  disable_thinking_keywords$keyword[
    disable_thinking_keywords$model == chat_model
  ]
}
