#' The chores eval
#'
#' @description
#' Pass this dataset to `Task$new()` to situate it inside of an evaluation
#' task.
#'
#' @format A tibble with `r nrow(chores_dataset)` rows and `r ncol(chores_dataset)` columns:
#' \describe{
#'   \item{id}{Character. Unique identifier/title for the code problem.}
#'   \item{input}{The user prompt that would be submitted to the chore.}
#'   \item{target}{Character. The solution, often with a description of notable
#'   features of a correct solution.}
#'   \item{source}{Character. URL or source of the problem, usually as a link to
#'   a commit on GitHub. `NA`s indicate that
#'   the problem was written originally for this eval.}
#' }
#'
#' @seealso [chores_task()] to situate this dataset in the chores eval.
#' @examples
#' chores_dataset
#'
#' str(chores_dataset)
"chores_dataset"
