#' The chores evaluation task
#'
#' @description
#' Creates a vitals [Task][vitals::Task] for evaluating language models on the
#' chores dataset. The task combines the dataset, solver, and scorer into a
#' single object. Run this eval with `chores_task()$eval()` and a `solver_chat`
#' of your choice.
#'
#' @param dir Character string specifying the directory where evaluation logs
#'   will be written.
#'
#' @return A vitals Task object configured with the chores dataset, solver, and
#'   scorer. This object can be used to run evaluations with `task$eval()`.
#'
#' @seealso [chores_dataset] for the dataset used in this task,
#'   [chores_solver] for the solver function, and [chores_scorer] for the
#'   scoring function.
#' @export
chores_task <- function(dir = "data-raw/chores/logs") {
  vitals::Task$new(
    dataset = chores_dataset,
    solver = chores_solver,
    scorer = chores_scorer,
    metrics = list(percent = function(x) {
      round(mean(x) * 100, 3)
    }),
    dir = dir,
    name = "The chores eval"
  )
}
