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

  res <- ellmer::parallel_chat(ch, as.list(inputs), ...)

  list(
    result = purrr::map_chr(res, function(c) c$last_turn()@text),
    solver_chat = res
  )
}
