#' The chores scorer
#'
#' @description
#' Pass this function to `Task$new()` as the scorer to evaluate model responses
#' based on the chores eval criteria.
#'
#' @param samples The samples from a solver task, likely retrieved from
#' `task$get_samples()`.
#' @param ... Additional arguments passed to the scoring function.
#' @param scorer_chat An ellmer chat object to use for scoring. Defaults to
#'   `ellmer::chat_anthropic(model = "claude-3-7-sonnet-latest")`; this is the
#'   scoring model used in "official" results.
#'
#' @return A list with the following components:
#' \describe{
#'   \item{score}{Numeric vector of scores between 0 and 1, representing the
#'     proportion of criteria met.}
#'   \item{.scorer_metadata}{List containing the prompts used for scoring and
#'     the detailed grading results.}
#' }
#'
#' @seealso [chores_dataset] for the dataset this scorer evaluates, and
#'  [chores_task()] to combine this scorer with the dataset and solver.
#' @export
chores_scorer <- function(
  samples,
  ...,
  scorer_chat = ellmer::chat_anthropic(model = "claude-3-7-sonnet-latest")
) {
  # first, filter out all `result`s that aren't valid R code;
  # those will receive a score of 0
  result <- samples$result
  result_is_valid_r_code <- purrr::map_lgl(result, is_valid_r_code)
  result_indices_to_grade <- which(result_is_valid_r_code)

  # assemble each prompt by gluing the sample data into the rubric.
  # entries corresponding to invalid r code will have an empty string `""`
  prompts <- character(length(samples$input))
  for (i in seq_along(result_indices_to_grade)) {
    user_turn <- samples$input[i]
    assistant_turn <- samples$result[i]
    target <- samples$target[i]

    prompts[i] <- glue::glue(
      paste0(
        readLines(system.file(
          "prompts/rubric-cli.md",
          package = "choreseval"
        )),
        collapse = "\n"
      ),
      system_prompt = cli_system_prompt,
      user_prompt = user_turn,
      assistant_response = assistant_turn,
      target = target,
      .open = "<<",
      .close = ">>"
    )
  }

  # send all of the prompts to the scorer.
  # the output is a data frame with one row per valid R code result.
  res <- scorer_chat$extract_data_parallel(
    as.list(prompts[prompts != ""]),
    type = rubric_type_cli
  )

  # "fill in" the data by adding rows for the results that weren't
  # valid R code
  full_res <- matrix(NA, nrow = length(samples$input), ncol = ncol(res))
  colnames(full_res) <- colnames(res)
  full_res <- tibble::as_tibble(full_res)
  full_res[result_indices_to_grade, ] <- res
  res <- full_res

  # tidy up + calculate numeric scores
  res <- dplyr::mutate(res, across(everything(), ~ dplyr::na_if(., "NA")))
  grading <- res

  # after a 2-second "grace period", subtract a point from the
  # numerator per second
  res$duration <- purrr::map_dbl(
    samples$solver_chat,
    duration_of_last_turn
  )
  res <- dplyr::rowwise(res)
  res <- dplyr::mutate(
    res,
    yes_count = sum(dplyr::across(dplyr::everything()) == "Yes", na.rm = TRUE),
    # the sum would otherwise include `yes_count` and `duration`
    n = sum(!is.na(dplyr::across(dplyr::everything()))) - 2,
    duration_penalty = max(duration - 2, 0),
    numerator = max(yes_count - duration_penalty, 0),
    prop = dplyr::case_when(
      # all NAs, so result wasn't valid R code
      n == 0 ~ 0,
      .default = numerator / n
    )
  )

  list(
    score = res$prop,
    # TODO: rename to `scorer_metadata` once this format is supported
    # In that case, grading would need to transposed as well.
    .scorer_metadata = list(prompts = prompts, grading = grading)
  )
}

rubric_type_cli <- ellmer::type_object(
  correctness_selection = ellmer::type_string("Correct selection of function"),
  correctness_untouched = ellmer::type_string(
    "Original message content intact"
  ),
  substitution_sprintf = ellmer::type_string(
    "Replaced sprintf-style with cli substitutions"
  ),
  substitution_paste0 = ellmer::type_string(
    "Transitioned paste0 to cli substitutions"
  ),
  substitution_glue = ellmer::type_string(
    "Converted glue::glue to cli substitutions"
  ),
  args_retained = ellmer::type_string("Retained existing arguments"),
  args_minimal = ellmer::type_string("No unnecessary arguments added"),
  args_integration = ellmer::type_string("Code integrated effectively"),
  pluralization_implemented = ellmer::type_string(
    "Pluralization implemented correctly"
  ),
  structure_vector = ellmer::type_string("Error messages in character vectors"),
  structure_bullets = ellmer::type_string("Bullets named properly"),
  markup_general = ellmer::type_string("Uses semantic markup appropriately"),
  markup_fn = ellmer::type_string("Function markup applied correctly"),
  markup_friendly = ellmer::type_string(
    "Uses obj_type_friendly for actual values"
  )
)

is_valid_r_code <- function(x) {
  tryCatch(
    {
      parse(text = x)
      TRUE
    },
    error = function(e) FALSE
  )
}

duration_of_last_turn <- function(chat) {
  turns <- chat$get_turns()

  user_turn_completed <- turns[[length(turns) - 1]]@completed
  assistant_turn_completed <- turns[[length(turns)]]@completed

  as.numeric(difftime(
    assistant_turn_completed,
    user_turn_completed,
    units = "secs"
  ))
}
