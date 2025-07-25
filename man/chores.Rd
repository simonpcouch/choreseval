% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/chores.R
\docType{data}
\name{chores}
\alias{chores}
\title{Evaluation results}
\format{
An object of class \code{tbl_df} (inherits from \code{tbl}, \code{data.frame}) with 8 rows and 6 columns.
}
\usage{
chores
}
\description{
The \code{chores} data contains "confirmed" evaluation results generated by
running the following:

\if{html}{\out{<div class="sourceCode">}}\preformatted{tsk <- chores_task()
tsk$eval(
  solver_chat = ellmer::chat_*(model = "some-model")
)
}\if{html}{\out{</div>}}

See \code{\link[=chores_task]{chores_task()}} for more on how the evaluation task works. Notably:
\itemize{
\item The solver carries out 34 refactorings using
the \link[chores:`doc-helper-cli`]{cli chore helper}, each repeated 3 times.
\item Each refactoring is then graded according to a rubric using Claude 4
Sonnet. The grading results in a score between 0 and 1 and incorporates
measures of code quality as well as execution time. The score on the eval
is the mean of the per-sample scores multiplied by 100.
\item Grading costs something like $2.50; the cost of solving depends on the
model pricing.
}
}
\section{Columns}{

\itemize{
\item \code{name}: An identifier for the experiment.
\item \code{provider}: The ellmer provider name.
\item \code{model}: The model name.
\item \code{score}: The score on the eval, from 0 to 100. Scores above 80
are great, indicating a model is a good fit for use with chores.
For reference, Claude 4 Sonnet scores
\item \code{cost}: The total cost to run the solving across the 102 samples
(estimated by ellmer).
\item \code{metadata}: The full evaluation samples.
}
}

\examples{
library(tibble)

chores
dplyr::glimpse(chores)

}
\keyword{datasets}
