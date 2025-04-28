The chores eval is an example large language model evaluation implemented with [vitals](https://vitals.tidyverse.org/), an LLM eval framework for R. It's structured as an R package.

## Structure

The implementation of the chores eval lives in `R/`:

-   `chores_dataset` is a dataset of samples containing potential user prompts to chore helpers as well as grading criteria for the desired output.

-   `chores_solver` is a function that takes in a model as well as an element of `chores_dataset$input` and attempts to carry out the user prompt.

-   `chores_scorer` is a function that evaluates how well the solver carried out the user prompt based on the grading criteria.

The package also exports a tibble `chores_eval`, which is the result of running `inspect_bind()` on all of the evaluation results to date.

The `inst/` directory contains source code and intermediate results for other components of the eval:

-   `inst/dataset/` contains the app that was used to generate the source data underlying `chores_dataset` as well as the prompt that generated the app. The app writes `.json` files that are ultimately loaded into R and concatenated into `chores_dataset`.

-   `inst/results` contains the logs resulting from running the eval using a given model; `inst/results/tasks` contains the vitals Tasks as `.rda`, `inst/results/logs` contains the `.json` logs generated from the Tasks.

The `context/` directory contains the source directory for the ellmer and vitals R packages, which are important for understanding how this eval works. I've pasted the contents of important documentation on those packages below.

**Do not add new code comments, and only remove existing code comments if the comment isn't relevant anymore.**

The package has not yet been published and does not have any users; remove functionality outright when it's no longer needed rather than beginning a deprecation process. No need to worry about breaking changes.

To get a sense for the style used to write and test code in this package, read `context/vitals/R/task.R` and `context/vitals/tests/testthat/test-task.R`, respectively. Notably, do not comment your code besides roxygen comments.

<!-- btw::btw("{ellmer}", "{vitals}", ?vitals::Task, ?ellmer::Chat, ellmer::chat_anthropic, vignette("vitals", "vitals")) -->

## Context

"{ellmer}"
```json
[
  {"topic_id":"Chat","title":"A chat","aliases":["Chat"]},
  {"topic_id":"Content","title":"Content types received from and sent to a chatbot","aliases":["Content","ContentText","ContentImage","ContentImageRemote","ContentImageInline","ContentToolRequest","ContentToolResult","ContentThinking","ContentPDF"]},
  {"topic_id":"Provider","title":"A chatbot provider","aliases":["Provider"]},
  {"topic_id":"Turn","title":"A user or assistant turn","aliases":["Turn"]},
  {"topic_id":"Type","title":"Type definitions for function calling and structured data extraction.","aliases":["Type","TypeBasic","TypeEnum","TypeArray","TypeObject"]},
  {"topic_id":"chat_anthropic","title":"Chat with an Anthropic Claude model","aliases":["chat_anthropic"]},
  {"topic_id":"chat_aws_bedrock","title":"Chat with an AWS bedrock model","aliases":["chat_aws_bedrock"]},
  {"topic_id":"chat_azure_openai","title":"Chat with a model hosted on Azure OpenAI","aliases":["chat_azure_openai"]},
  {"topic_id":"chat_cloudflare","title":"Chat with a model hosted on CloudFlare","aliases":["chat_cloudflare"]},
  {"topic_id":"chat_cortex_analyst","title":"Create a chatbot that speaks to the Snowflake Cortex Analyst","aliases":["chat_cortex_analyst"]},
  {"topic_id":"chat_databricks","title":"Chat with a model hosted on Databricks","aliases":["chat_databricks"]},
  {"topic_id":"chat_deepseek","title":"Chat with a model hosted on DeepSeek","aliases":["chat_deepseek"]},
  {"topic_id":"chat_github","title":"Chat with a model hosted on the GitHub model marketplace","aliases":["chat_github"]},
  {"topic_id":"chat_google_gemini","title":"Chat with a Google Gemini or Vertex AI model","aliases":["chat_google_gemini","chat_google_vertex"]},
  {"topic_id":"chat_groq","title":"Chat with a model hosted on Groq","aliases":["chat_groq"]},
  {"topic_id":"chat_huggingface","title":"Chat with a model hosted on Hugging Face Serverless Inference API","aliases":["chat_huggingface"]},
  {"topic_id":"chat_mistral","title":"Chat with a model hosted on Mistral's La Platforme","aliases":["chat_mistral"]},
  {"topic_id":"chat_ollama","title":"Chat with a local Ollama model","aliases":["chat_ollama"]},
  {"topic_id":"chat_openai","title":"Chat with an OpenAI model","aliases":["chat_openai"]},
  {"topic_id":"chat_openrouter","title":"Chat with one of the many models hosted on OpenRouter","aliases":["chat_openrouter"]},
  {"topic_id":"chat_perplexity","title":"Chat with a model hosted on perplexity.ai","aliases":["chat_perplexity"]},
  {"topic_id":"chat_snowflake","title":"Chat with a model hosted on Snowflake","aliases":["chat_snowflake"]},
  {"topic_id":"chat_vllm","title":"Chat with a model hosted by vLLM","aliases":["chat_vllm"]},
  {"topic_id":"content_image_url","title":"Encode images for chat input","aliases":["content_image_url","content_image_file","content_image_plot"]},
  {"topic_id":"content_pdf_file","title":"Encode PDFs content for chat input","aliases":["content_pdf_file","content_pdf_url"]},
  {"topic_id":"contents_text","title":"Format contents into a textual representation","aliases":["contents_text","contents_html","contents_markdown"]},
  {"topic_id":"create_tool_def","title":"Create metadata for a tool","aliases":["create_tool_def"]},
  {"topic_id":"deprecated","title":"Deprecated functions","aliases":["deprecated","chat_cortex","chat_azure","chat_bedrock","chat_claude","chat_gemini"]},
  {"topic_id":"ellmer-package","title":"ellmer: Chat with Large Language Models","aliases":["ellmer","ellmer-package"]},
  {"topic_id":"google_upload","title":"Upload a file to gemini","aliases":["google_upload"]},
  {"topic_id":"has_credentials","title":"Are credentials avaiable?","aliases":["has_credentials"]},
  {"topic_id":"interpolate","title":"Helpers for interpolating data into prompts","aliases":["interpolate","interpolate_file","interpolate_package"]},
  {"topic_id":"live_console","title":"Open a live chat application","aliases":["live_console","live_browser"]},
  {"topic_id":"params","title":"Standard model parameters","aliases":["params"]},
  {"topic_id":"token_usage","title":"Report on token usage in the current session","aliases":["token_usage"]},
  {"topic_id":"tool","title":"Define a tool","aliases":["tool"]},
  {"topic_id":"tool_annotations","title":"Tool annotations","aliases":["tool_annotations"]},
  {"topic_id":"type_boolean","title":"Type specifications","aliases":["type_boolean","type_integer","type_number","type_string","type_enum","type_array","type_object"]}
]
```

"{vitals}"
# Getting started with vitals {#getting-started-with-vitals .title .toc-ignore}

At their core, LLM evals are composed of three pieces:

1.  **Datasets** contain a set of labelled samples. Datasets are just a
    tibble with columns `input` and `target`, where `input` is a prompt
    and `target` is either literal value(s) or grading guidance.
2.  **Solvers** evaluate the `input` in the dataset and produce a final
    result (hopefully) approximating `target`. In vitals, the simplest
    solver is just an ellmer chat (e.g. `ellmer::chat_anthropic()`)
    wrapped in `generate()`, i.e. `generate(ellmer::chat_anthropic()`),
    which will call the Chat object's `$chat()` method and return
    whatever it returns.
3.  **Scorers** evaluate the final output of solvers. They may use text
    comparisons, model grading, or other custom schemes to determine how
    well the solver approximated the `target` based on the `input`.

This vignette will explore these three components using `are`, an
example dataset that ships with the package.

First, load the required packages:

::: {#cb1 .sourceCode}
``` {.sourceCode .r}
library(vitals)
library(ellmer)
library(dplyr)
library(ggplot2)
```
:::

:::::: {#an-r-eval-dataset .section .level2}
## An R eval dataset

From the `are` docs:

> An R Eval is a dataset of challenging R coding problems. Each `input`
> is a question about R code which could be solved on first-read only by
> human experts and, with a chance to read documentation and run some
> code, by fluent data scientists. Solutions are in `target` and enable
> a fluent data scientist to evaluate whether the solution deserves
> full, partial, or no credit.

::: {#cb2 .sourceCode}
``` {.sourceCode .r}
glimpse(are)
```
:::

    #> Rows: 26
    #> Columns: 7
    #> $ id        <chr> "after-stat-bar-heights", "conditional-grouped-summary", "co…
    #> $ input     <chr> "This bar chart shows the count of different cuts of diamond…
    #> $ target    <chr> "Preferably: \n\n```\nggplot(data = diamonds) + \n  geom_bar…
    #> $ domain    <chr> "Data analysis", "Data analysis", "Data analysis", "Programm…
    #> $ task      <chr> "New code", "New code", "New code", "Debugging", "New code",…
    #> $ source    <chr> "https://jrnold.github.io/r4ds-exercise-solutions/data-visua…
    #> $ knowledge <list> "tidyverse", "tidyverse", "tidyverse", "r-lib", "tidyverse"…

At a high level:

-   `id`: A unique identifier for the problem.
-   `input`: The question to be answered.
-   `target`: The solution, often with a description of notable features
    of a correct solution.
-   `domain`, `task`, and `knowledge` are pieces of metadata describing
    the kind of R coding challenge.
-   `source`: Where the problem came from, as a URL. Many of these
    coding problems are adapted "from the wild" and include the kinds of
    context usually available to those answering questions.

For the purposes of actually carrying out the initial evaluation, we're
specifically interested in the `input` and `target` columns. Let's print
out the first entry in full so you can get a taste of a typical problem
in this dataset:

::: {#cb4 .sourceCode}
``` {.sourceCode .r}
cat(are$input[1])
```
:::

    #> This bar chart shows the count of different cuts of diamonds, and each
    #> bar is stacked and filled according to clarity:
    #> 
    #> ```
    #> ggplot(data = diamonds) +
    #> geom_bar(mapping = aes(x = cut, fill = clarity))
    #> ```
    #> 
    #> Could you change this code so that the proportion of diamonds with a
    #> given cut corresponds to the bar height and not the count? Each bar
    #> should still be filled according to clarity.

Here's the suggested solution:

::: {#cb6 .sourceCode}
``` {.sourceCode .r}
cat(are$target[1])
```
:::

    #> Preferably:
    #> 
    #> ```
    #> ggplot(data = diamonds) +
    #> geom_bar(aes(x = cut, y = after_stat(count) / sum(after_stat(count)),
    #> fill = clarity))
    #> ```
    #> 
    #> The dot-dot notation (`..count..`) was deprecated in ggplot2 3.4.0, but
    #> it still works:
    #> 
    #> ```
    #> ggplot(data = diamonds) +
    #> geom_bar(aes(x = cut, y = ..count.. / sum(..count..), fill = clarity))
    #> ```
    #> 
    #> Simply setting `position = "fill" will result in each bar having a
    #> height of 1 and is not correct.
::::::

::::::: {#creating-and-evaluating-a-task .section .level2}
## Creating and evaluating a task

LLM evaluation with vitals happens in two main steps:

1.  Use `Task$new()` to situate a dataset, solver, and scorer in a
    `Task`.

::: {#cb8 .sourceCode}
``` {.sourceCode .r}
are_task <- Task$new(
  dataset = are,
  solver = generate(chat_anthropic(model = "claude-3-7-sonnet-latest")),
  scorer = model_graded_qa(partial_credit = TRUE),
  name = "An R Eval"
)

are_task
```
:::

2.  Use `Task$eval()` to evaluate the solver, evaluate the scorer, and
    then explore a persistent log of the results in the interactive
    Inspect log viewer.

::: {#cb9 .sourceCode}
``` {.sourceCode .r}
are_task$eval()
```
:::

After evaluation, the task contains information from the solving and
scoring steps. Here's what the model responded to that first question
with:

::: {#cb10 .sourceCode}
``` {.sourceCode .r}
cat(are_task$samples$result[1])
```
:::

    #> # Converting a stacked bar chart from counts to proportions
    #> 
    #> To change the bar heights from counts to proportions, you need to use
    #> the `position = "fill"` argument in `geom_bar()`. This will normalize
    #> each bar to represent proportions (with each bar having a total height
    #> of 1), while maintaining the stacked clarity segments.
    #> 
    #> Here's the modified code:
    #> 
    #> ```r
    #> ggplot(data = diamonds) +
    #> geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill") +
    #> labs(y = "Proportion") # Updating y-axis label to reflect the change
    #> ```
    #> 
    #> This transformation:
    #> - Maintains the stacking by clarity within each cut category
    #> - Scales each bar to the same height (1.0)
    #> - Shows the proportion of each clarity level within each cut
    #> - Allows for easier comparison of clarity distributions across
    #> different cuts
    #> 
    #> The y-axis will now range from 0 to 1, representing the proportion
    #> instead of raw counts.

The task also contains score information from the scoring step. We've
used `model_graded_qa()` as our scorer, which uses another model to
evaluate the quality of our solver's solutions against the reference
solutions in the `target` column. `model_graded_qa()` is a model-graded
scorer provided by the package. This step compares Claude's solutions
against the reference solutions in the `target` column, assigning a
score to each solution using another model. That score is either `1` or
`0`, though since we've set `partial_credit = TRUE`, the model can also
choose to allot the response `.5`. vitals will use the same model that
generated the final response as the model to score solutions.

Hold up, though---we're using an LLM to generate responses to questions,
and then using the LLM to grade those responses?

This technique is called "model grading" or "LLM-as-a-judge." Done
correctly, model grading is an effective and scalable solution to
scoring. That said, it's not without its faults. Here's what the grading
model thought of the response:

::: {#cb12 .sourceCode}
``` {.sourceCode .r}
cat(are_task$samples$scorer_chat[[1]]$last_turn()@text)
#> I need to assess whether the submission meets the criterion for
#> changing the bar chart to show proportions instead of counts.
#> 
#> The submission suggests using `position = "fill"` in the `geom_bar()`
#> function. This approach would normalize each bar to have a total height
#> of 1, showing the proportion of different clarity levels within each
#> cut category.
#> 
#> However, the criterion specifies a different approach. According to the
#> criterion, each bar should represent the proportion of diamonds with a
#> given cut relative to the total number of diamonds. This means using
#> either:
#> 1. `aes(x = cut, y = after_stat(count) / sum(after_stat(count)), fill =
#> clarity)` (preferred modern syntax)
#> 2. `aes(x = cut, y = ..count.. / sum(..count..), fill = clarity)`
#> (deprecated but functional syntax)
#> 
#> The criterion explicitly states that using `position = "fill"` is not
#> correct because it would make each bar have a height of 1, rather than
#> showing the true proportion of each cut in the overall dataset.
#> 
#> The submission is suggesting a different type of proportional
#> representation than what is being asked for in the criterion. The
#> submission shows the distribution of clarity within each cut, while the
#> criterion is asking for the proportion of each cut in the total
#> dataset.
#> 
#> GRADE: I
```
:::
:::::::

::::::::: {#analyzing-the-results .section .level2}
## Analyzing the results

Especially the first few times you run an eval, you'll want to inspect
(ha!) its results closely. The vitals package ships with an app, the
Inspect log viewer, that allows you to drill down into the solutions and
grading decisions from each model for each sample. In the first couple
runs, you'll likely find revisions you can make to your grading guidance
in `target` that align model responses with your intent.

![The Inspect log viewer, an interactive app displaying information on
the samples evaluated in this
eval.](){role="img"
aria-label="The Inspect log viewer, an interactive app displaying information on the samples evaluated in this eval."
width="1739"}

\

Under the hood, when you call `task$eval()`, results are written to a
`.json` file that the Inspect log viewer can read. The Task object
automatically launches the viewer when you call `task$eval()` in an
interactive session. You can also view results any time with
`are_task$view()`. You can explore this eval above (on the package's
pkgdown site).

For a cursory analysis, we can start off by visualizing correct
vs. partially correct vs. incorrect answers:

::: {#cb13 .sourceCode}
``` {.sourceCode .r}
are_task_data <- vitals_bind(are_task)

are_task_data
#> # A tibble: 26 × 4
#>    task     id                          score metadata         
#>    <chr>    <chr>                       <ord> <list>           
#>  1 are_task after-stat-bar-heights      I     <tibble [1 × 10]>
#>  2 are_task conditional-grouped-summary P     <tibble [1 × 10]>
#>  3 are_task correlated-delays-reasoning C     <tibble [1 × 10]>
#>  4 are_task curl-http-get               C     <tibble [1 × 10]>
#>  5 are_task dropped-level-legend        I     <tibble [1 × 10]>
#>  6 are_task geocode-req-perform         C     <tibble [1 × 10]>
#>  7 are_task ggplot-breaks-feature       I     <tibble [1 × 10]>
#>  8 are_task grouped-filter-summarize    P     <tibble [1 × 10]>
#>  9 are_task grouped-mutate              C     <tibble [1 × 10]>
#> 10 are_task implement-nse-arg           P     <tibble [1 × 10]>
#> # ℹ 16 more rows

are_task_data %>%
  ggplot() +
  aes(x = score) +
  geom_bar()
```
:::

![A ggplot2 bar plot, showing Claude was correct most of the
time.](){role="img"}

Is this difference in performance just a result of noise, though? We can
supply the scores to an ordinal regression model to answer this
question.

::: {#cb16 .sourceCode}
``` {.sourceCode .r}
library(ordinal)
#> 
#> Attaching package: 'ordinal'
#> The following object is masked from 'package:dplyr':
#> 
#>     slice

are_mod <- clm(score ~ model, data = are_task_eval)

are_mod
#> formula: score ~ model
#> data:    are_task_eval
#> 
#>  link  threshold nobs logLik AIC    niter max.grad cond.H 
#>  logit flexible  52   -54.80 115.61 4(0)  2.15e-12 1.2e+01
#> 
#> Coefficients:
#> modelGPT-4o 
#>     -0.9725 
#> 
#> Threshold coefficients:
#>      I|P      P|C 
#> -1.35956 -0.09041
```
:::

The coefficient for `model == "GPT-4o"` is -0.972, indicating that
GPT-4o tends to be associated with lower grades. If a 95% confidence
interval for this coefficient contains zero, we can conclude that there
is not sufficient evidence to reject the null hypothesis that the
difference between GPT-4o and Claude's performance on this eval is zero
at the 0.05 significance level.

::: {#cb17 .sourceCode}
``` {.sourceCode .r}
confint(are_mod)
#>                 2.5 %     97.5 %
#> modelGPT-4o -2.031694 0.04806051
```
:::

::: callout-note
If we had evaluated this model across multiple epochs, the question ID
could become a "nuisance parameter" in a mixed model, e.g. with the
model structure `ordinal::clmm(score ~ model + (1|id), ...)`.
:::

This vignette demonstrated the simplest possible evaluation based on the
`are` dataset. If you're interested in carrying out more advanced evals,
check out the other vignettes in this package!
:::::::::

`?`(vitals::Task)
## `help(package = "vitals", "Task")`

### Creating and evaluating tasks

#### Description

Evaluation `Task`s provide a flexible data structure for evaluating
LLM-based tools.

1.  **Datasets** contain a set of labelled samples. Datasets are just a
    tibble with columns `input` and `target`, where `input` is a prompt
    and `target` is either literal value(s) or grading guidance.

2.  **Solvers** evaluate the `input` in the dataset and produce a final
    result.

3.  **Scorers** evaluate the final output of solvers. They may use text
    comparisons (like `detect_match()`), model grading (like
    `model_graded_qa()`), or other custom schemes.

**The usual flow of LLM evaluation with Tasks calls `⁠$new()⁠` and then
`⁠$eval()⁠`.** `⁠$eval()⁠` just calls `⁠$solve()⁠`, `⁠$score()⁠`, `⁠$measure()⁠`,
`⁠$log()⁠`, and `⁠$view()⁠` in order. The remaining methods are generally
only recommended for expert use.

#### Public fields

`dir`  
The directory where evaluation logs will be written to. Defaults to
`vitals_log_dir()`.

`samples`  
A tibble representing the evaluation. Based on the `dataset`, `epochs`
may duplicate rows, and the solver and scorer will append columns to
this data.

`metrics`  
A named vector of metric values resulting from `⁠$measure()⁠` (called
inside of `⁠$eval()⁠`). Will be `NULL` if metrics have yet to be applied.

#### Methods

##### Public methods

-   [`Task$new()`](#method-Task-new)

-   [`Task$eval()`](#method-Task-eval)

-   [`Task$solve()`](#method-Task-solve)

-   [`Task$score()`](#method-Task-score)

-   [`Task$measure()`](#method-Task-measure)

-   [`Task$log()`](#method-Task-log)

-   [`Task$view()`](#method-Task-view)

-   [`Task$set_solver()`](#method-Task-set_solver)

-   [`Task$set_scorer()`](#method-Task-set_scorer)

-   [`Task$set_metrics()`](#method-Task-set_metrics)

-   [`Task$clone()`](#method-Task-clone)

------------------------------------------------------------------------

<span id="method-Task-new"></span>

##### Method `new()`

The typical flow of LLM evaluation with vitals tends to involve first
calling this method and then `⁠$eval()⁠` on the resulting object.

###### Usage

    Task$new(
      dataset,
      solver,
      scorer,
      metrics = NULL,
      epochs = NULL,
      name = deparse(substitute(dataset)),
      dir = vitals_log_dir()
    )

###### Arguments

`dataset`  
A tibble with, minimally, columns `input` and `target`.

`solver`  
A function that takes a vector of inputs from the dataset's `input`
column as its first argument and determines values approximating
`dataset$target`. Its return value must be a list with the following
elements:

-   `result` - A character vector of the final responses, with the same
    length as `dataset$input`.

-   `solver_chat` - A list of ellmer Chat objects that were used to
    solve each input, also with the same length as `dataset$input`.

Additional output elements can be included in a slot `solver_metadata`
that has the same length as `dataset$input`, which will be logged in
`solver_metadata`.

Additional arguments can be passed to the solver via `⁠$solve(...)⁠` or
`⁠$eval(...)⁠`. See the definition of `generate()` for a function that
outputs a valid solver that just passes inputs to ellmer Chat objects'
`⁠$chat()⁠` method in parallel.

`scorer`  
A function that evaluates how well the solver's return value
approximates the corresponding elements of `dataset$target`. The
function should take in the `⁠$samples⁠` slot of a Task object and return
a list with the following elements:

-   `score` - A vector of scores with length equal to `nrow(samples)`.
    Built-in scorers return ordered factors with levels `I` &lt; `P`
    (optionally) &lt; `C` (standing for "Incorrect", "Partially
    Correct", and "Correct"). If your scorer returns this output type,
    the package will automatically calculate metrics.

Optionally:

-   `scorer_chat` - If your scorer makes use of ellmer, also include a
    list of ellmer Chat objects that were used to score each result,
    also with length `nrow(samples)`.

-   `scorer_metadata` - Any intermediate results or other values that
    you'd like to be stored in the persistent log. This should also have
    length equal to `nrow(samples)`.

Scorers will probably make use of `samples$input`, `samples$target`, and
`samples$result` specifically. See model-based scoring for examples.

`metrics`  
A metric summarizing the results from the scorer.

`epochs`  
The number of times to repeat each sample. Evaluate each sample multiple
times to better quantify variation. Optional, defaults to `1L`. The
value of `epochs` supplied to `⁠$eval()⁠` or `⁠$score()⁠` will take
precedence over the value in `⁠$new()⁠`.

`name`  
A name for the evaluation task. Defaults to
`deparse(substitute(dataset))`.

`dir`  
Directory where logs should be stored.

------------------------------------------------------------------------

<span id="method-Task-eval"></span>

##### Method `eval()`

Evaluates the task by running the solver, scorer, logging results, and
viewing (if interactive). This method works by calling `⁠$solve()⁠`,
`⁠$score()⁠`, `⁠$log()⁠`, and `⁠$view()⁠` in sequence.

The typical flow of LLM evaluation with vitals tends to involve first
calling `⁠$new()⁠` and then this method on the resulting object.

###### Usage

    Task$eval(..., epochs = NULL, view = interactive())

###### Arguments

`...`  
Additional arguments passed to the solver and scorer functions.

`epochs`  
The number of times to repeat each sample. Evaluate each sample multiple
times to better quantify variation. Optional, defaults to `1L`. The
value of `epochs` supplied to `⁠$eval()⁠` or `⁠$score()⁠` will take
precedence over the value in `⁠$new()⁠`.

`view`  
Automatically open the viewer after evaluation (defaults to TRUE if
interactive, FALSE otherwise).

###### Returns

The Task object (invisibly)

------------------------------------------------------------------------

<span id="method-Task-solve"></span>

##### Method `solve()`

Solve the task by running the solver

###### Usage

    Task$solve(..., epochs = NULL)

###### Arguments

`...`  
Additional arguments passed to the solver function.

`epochs`  
The number of times to repeat each sample. Evaluate each sample multiple
times to better quantify variation. Optional, defaults to `1L`. The
value of `epochs` supplied to `⁠$eval()⁠` or `⁠$score()⁠` will take
precedence over the value in `⁠$new()⁠`.

###### Returns

The Task object (invisibly)

------------------------------------------------------------------------

<span id="method-Task-score"></span>

##### Method `score()`

Score the task by running the scorer and then applying metrics to its
results.

###### Usage

    Task$score(...)

###### Arguments

`...`  
Additional arguments passed to the scorer function.

###### Returns

The Task object (invisibly)

------------------------------------------------------------------------

<span id="method-Task-measure"></span>

##### Method `measure()`

Applies metrics to a scored Task.

###### Usage

    Task$measure()

------------------------------------------------------------------------

<span id="method-Task-log"></span>

##### Method `log()`

Log the task to a directory.

Note that, if an `VITALS_LOG_DIR` envvar is set, this will happen
automatically in `⁠$eval()⁠`.

###### Usage

    Task$log(dir = vitals_log_dir())

###### Arguments

`dir`  
The directory to write the log to.

###### Returns

The path to the logged file, invisibly.

------------------------------------------------------------------------

<span id="method-Task-view"></span>

##### Method `view()`

View the task results in the Inspect log viewer

###### Usage

    Task$view()

###### Returns

The Task object (invisibly)

------------------------------------------------------------------------

<span id="method-Task-set_solver"></span>

##### Method `set_solver()`

Set the solver function

###### Usage

    Task$set_solver(solver)

###### Arguments

`solver`  
A function that takes a vector of inputs from the dataset's `input`
column as its first argument and determines values approximating
`dataset$target`. Its return value must be a list with the following
elements:

-   `result` - A character vector of the final responses, with the same
    length as `dataset$input`.

-   `solver_chat` - A list of ellmer Chat objects that were used to
    solve each input, also with the same length as `dataset$input`.

Additional output elements can be included in a slot `solver_metadata`
that has the same length as `dataset$input`, which will be logged in
`solver_metadata`.

Additional arguments can be passed to the solver via `⁠$solve(...)⁠` or
`⁠$eval(...)⁠`. See the definition of `generate()` for a function that
outputs a valid solver that just passes inputs to ellmer Chat objects'
`⁠$chat()⁠` method in parallel.

###### Returns

The Task object (invisibly)

------------------------------------------------------------------------

<span id="method-Task-set_scorer"></span>

##### Method `set_scorer()`

Set the scorer function

###### Usage

    Task$set_scorer(scorer)

###### Arguments

`scorer`  
A function that evaluates how well the solver's return value
approximates the corresponding elements of `dataset$target`. The
function should take in the `⁠$samples⁠` slot of a Task object and return
a list with the following elements:

-   `score` - A vector of scores with length equal to `nrow(samples)`.
    Built-in scorers return ordered factors with levels `I` &lt; `P`
    (optionally) &lt; `C` (standing for "Incorrect", "Partially
    Correct", and "Correct"). If your scorer returns this output type,
    the package will automatically calculate metrics.

Optionally:

-   `scorer_chat` - If your scorer makes use of ellmer, also include a
    list of ellmer Chat objects that were used to score each result,
    also with length `nrow(samples)`.

-   `scorer_metadata` - Any intermediate results or other values that
    you'd like to be stored in the persistent log. This should also have
    length equal to `nrow(samples)`.

Scorers will probably make use of `samples$input`, `samples$target`, and
`samples$result` specifically. See model-based scoring for examples.

###### Returns

The Task object (invisibly)

------------------------------------------------------------------------

<span id="method-Task-set_metrics"></span>

##### Method `set_metrics()`

Set the metrics that will be applied in `⁠$measure()⁠` (and thus
`⁠$eval()⁠`).

###### Usage

    Task$set_metrics(metrics)

###### Arguments

`metrics`  
A named list of functions that take in a vector of scores (as in
`task$samples$score`) and output a single numeric value.

###### Returns

The Task (invisibly)

------------------------------------------------------------------------

<span id="method-Task-clone"></span>

##### Method `clone()`

The objects of this class are cloneable with this method.

###### Usage

    Task$clone(deep = FALSE)

###### Arguments

`deep`  
Whether to make a deep clone.

#### See Also

`generate()` for the simplest possible solver, and scorer\_model and
scorer\_detect for two built-in approaches to scoring.

#### Examples

``` R
if (!identical(Sys.getenv("ANTHROPIC_API_KEY"), "")) {
  library(ellmer)
  library(tibble)

  simple_addition <- tibble(
    input = c("What's 2+2?", "What's 2+3?"),
    target = c("4", "5")
  )

  # create a new Task
  tsk <- Task$new(
    dataset = simple_addition,
    solver = generate(chat_anthropic(model = "claude-3-7-sonnet-latest")),
    scorer = model_graded_qa()
  )

  # evaluate the task (runs solver and scorer) and opens
  # the results in the Inspect log viewer (if interactive)
  tsk$eval()
}
```

`?`(ellmer::Chat)
## `help(package = "ellmer", "Chat")`

### A chat

#### Description

A `Chat` is a sequence of user and assistant Turns sent to a specific
Provider. A `Chat` is a mutable R6 object that takes care of managing
the state associated with the chat; i.e. it records the messages that
you send to the server, and the messages that you receive back. If you
register a tool (i.e. an R function that the assistant can call on your
behalf), it also takes care of the tool loop.

You should generally not create this object yourself, but instead call
`chat_openai()` or friends instead.

#### Value

A Chat object

#### Methods

##### Public methods

-   [`Chat$new()`](#method-Chat-new)

-   [`Chat$get_turns()`](#method-Chat-get_turns)

-   [`Chat$set_turns()`](#method-Chat-set_turns)

-   [`Chat$add_turn()`](#method-Chat-add_turn)

-   [`Chat$get_system_prompt()`](#method-Chat-get_system_prompt)

-   [`Chat$get_model()`](#method-Chat-get_model)

-   [`Chat$set_system_prompt()`](#method-Chat-set_system_prompt)

-   [`Chat$get_tokens()`](#method-Chat-get_tokens)

-   [`Chat$get_cost()`](#method-Chat-get_cost)

-   [`Chat$last_turn()`](#method-Chat-last_turn)

-   [`Chat$chat()`](#method-Chat-chat)

-   [`Chat$chat_parallel()`](#method-Chat-chat_parallel)

-   [`Chat$extract_data()`](#method-Chat-extract_data)

-   [`Chat$extract_data_parallel()`](#method-Chat-extract_data_parallel)

-   [`Chat$extract_data_async()`](#method-Chat-extract_data_async)

-   [`Chat$chat_async()`](#method-Chat-chat_async)

-   [`Chat$stream()`](#method-Chat-stream)

-   [`Chat$stream_async()`](#method-Chat-stream_async)

-   [`Chat$register_tool()`](#method-Chat-register_tool)

-   [`Chat$get_provider()`](#method-Chat-get_provider)

-   [`Chat$get_tools()`](#method-Chat-get_tools)

-   [`Chat$set_tools()`](#method-Chat-set_tools)

-   [`Chat$clone()`](#method-Chat-clone)

------------------------------------------------------------------------

<span id="method-Chat-new"></span>

##### Method `new()`

###### Usage

    Chat$new(provider, system_prompt = NULL, echo = "none")

###### Arguments

`provider`  
A provider object.

`system_prompt`  
System prompt to start the conversation with.

`echo`  
One of the following options:

-   `none`: don't emit any output (default when running in a function).

-   `text`: echo text output as it streams in (default when running at
    the console).

-   `all`: echo all input and output.

Note this only affects the `chat()` method.

------------------------------------------------------------------------

<span id="method-Chat-get_turns"></span>

##### Method `get_turns()`

Retrieve the turns that have been sent and received so far (optionally
starting with the system prompt, if any).

###### Usage

    Chat$get_turns(include_system_prompt = FALSE)

###### Arguments

`include_system_prompt`  
Whether to include the system prompt in the turns (if any exists).

------------------------------------------------------------------------

<span id="method-Chat-set_turns"></span>

##### Method `set_turns()`

Replace existing turns with a new list.

###### Usage

    Chat$set_turns(value)

###### Arguments

`value`  
A list of Turns.

------------------------------------------------------------------------

<span id="method-Chat-add_turn"></span>

##### Method `add_turn()`

Add a pair of turns to the chat.

###### Usage

    Chat$add_turn(user, system)

###### Arguments

`user`  
The user Turn.

`system`  
The system Turn.

------------------------------------------------------------------------

<span id="method-Chat-get_system_prompt"></span>

##### Method `get_system_prompt()`

If set, the system prompt, it not, `NULL`.

###### Usage

    Chat$get_system_prompt()

------------------------------------------------------------------------

<span id="method-Chat-get_model"></span>

##### Method `get_model()`

Retrieve the model name

###### Usage

    Chat$get_model()

------------------------------------------------------------------------

<span id="method-Chat-set_system_prompt"></span>

##### Method `set_system_prompt()`

Update the system prompt

###### Usage

    Chat$set_system_prompt(value)

###### Arguments

`value`  
A character vector giving the new system prompt

------------------------------------------------------------------------

<span id="method-Chat-get_tokens"></span>

##### Method `get_tokens()`

A data frame with a `tokens` column that proides the number of input
tokens used by user turns and the number of output tokens used by
assistant turns.

###### Usage

    Chat$get_tokens(include_system_prompt = FALSE)

###### Arguments

`include_system_prompt`  
Whether to include the system prompt in the turns (if any exists).

------------------------------------------------------------------------

<span id="method-Chat-get_cost"></span>

##### Method `get_cost()`

The cost of this chat

###### Usage

    Chat$get_cost(include = c("all", "last"))

###### Arguments

`include`  
The default, `"all"`, gives the total cumulative cost of this chat.
Alternatively, use `"last"` to get the cost of just the most recent
turn.

------------------------------------------------------------------------

<span id="method-Chat-last_turn"></span>

##### Method `last_turn()`

The last turn returned by the assistant.

###### Usage

    Chat$last_turn(role = c("assistant", "user", "system"))

###### Arguments

`role`  
Optionally, specify a role to find the last turn with for the role.

###### Returns

Either a `Turn` or `NULL`, if no turns with the specified role have
occurred.

------------------------------------------------------------------------

<span id="method-Chat-chat"></span>

##### Method `chat()`

Submit input to the chatbot, and return the response as a simple string
(probably Markdown).

###### Usage

    Chat$chat(..., echo = NULL)

###### Arguments

`...`  
The input to send to the chatbot. Can be strings or images (see
`content_image_file()` and `content_image_url()`.

`echo`  
Whether to emit the response to stdout as it is received. If `NULL`,
then the value of `echo` set when the chat object was created will be
used.

------------------------------------------------------------------------

<span id="method-Chat-chat_parallel"></span>

##### Method `chat_parallel()`

[![\[Experimental\]](../help/figures/lifecycle-experimental.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

Submit multiple prompts in parallel. Returns a list of Chat objects, one
for each prompt.

###### Usage

    Chat$chat_parallel(prompts, max_active = 10, rpm = 500)

###### Arguments

`prompts`  
A list of user prompts.

`max_active`  
The maximum number of simultaenous requests to send.

`rpm`  
Maximum number of requests per minute.

------------------------------------------------------------------------

<span id="method-Chat-extract_data"></span>

##### Method `extract_data()`

Extract structured data

###### Usage

    Chat$extract_data(..., type, echo = "none", convert = TRUE)

###### Arguments

`...`  
The input to send to the chatbot. Will typically include the phrase
"extract structured data".

`type`  
A type specification for the extracted data. Should be created with a
`type_()` function.

`echo`  
Whether to emit the response to stdout as it is received. Set to "text"
to stream JSON data as it's generated (not supported by all providers).

`convert`  
Automatically convert from JSON lists to R data types using the schema.
For example, this will turn arrays of objects into data frames and
arrays of strings into a character vector.

------------------------------------------------------------------------

<span id="method-Chat-extract_data_parallel"></span>

##### Method `extract_data_parallel()`

[![\[Experimental\]](../help/figures/lifecycle-experimental.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

Submit multiple prompts in parallel.

###### Usage

    Chat$extract_data_parallel(
      prompts,
      type,
      convert = TRUE,
      max_active = 10,
      rpm = 500
    )

###### Arguments

`prompts`  
A vector created by `interpolate()` or a list of character vectors.

`type`  
A type specification for the extracted data. Should be created with a
`type_()` function.

`convert`  
If `TRUE`, automatically convert from JSON lists to R data types using
the schema. This typically works best when `type` is `type_object()` as
this will give you a data frame with one column for each property. If
`FALSE`, returns a list.

`max_active`  
The maximum number of simultaenous requests to send.

`rpm`  
Maximum number of requests per minute.

------------------------------------------------------------------------

<span id="method-Chat-extract_data_async"></span>

##### Method `extract_data_async()`

Extract structured data, asynchronously. Returns a promise that resolves
to an object matching the type specification.

###### Usage

    Chat$extract_data_async(..., type, echo = "none")

###### Arguments

`...`  
The input to send to the chatbot. Will typically include the phrase
"extract structured data".

`type`  
A type specification for the extracted data. Should be created with a
`type_()` function.

`echo`  
Whether to emit the response to stdout as it is received. Set to "text"
to stream JSON data as it's generated (not supported by all providers).

------------------------------------------------------------------------

<span id="method-Chat-chat_async"></span>

##### Method `chat_async()`

Submit input to the chatbot, and receive a promise that resolves with
the response all at once. Returns a promise that resolves to a string
(probably Markdown).

###### Usage

    Chat$chat_async(...)

###### Arguments

`...`  
The input to send to the chatbot. Can be strings or images.

------------------------------------------------------------------------

<span id="method-Chat-stream"></span>

##### Method `stream()`

Submit input to the chatbot, returning streaming results. Returns A
[coro
generator](https://coro.r-lib.org/articles/generator.html#iterating)
that yields strings. While iterating, the generator will block while
waiting for more content from the chatbot.

###### Usage

    Chat$stream(...)

###### Arguments

`...`  
The input to send to the chatbot. Can be strings or images.

------------------------------------------------------------------------

<span id="method-Chat-stream_async"></span>

##### Method `stream_async()`

Submit input to the chatbot, returning asynchronously streaming results.
Returns a [coro async
generator](https://coro.r-lib.org/reference/async_generator.html) that
yields string promises.

###### Usage

    Chat$stream_async(...)

###### Arguments

`...`  
The input to send to the chatbot. Can be strings or images.

------------------------------------------------------------------------

<span id="method-Chat-register_tool"></span>

##### Method `register_tool()`

Register a tool (an R function) that the chatbot can use. If the chatbot
decides to use the function, ellmer will automatically call it and
submit the results back.

The return value of the function. Generally, this should either be a
string, or a JSON-serializable value. If you must have more direct
control of the structure of the JSON that's returned, you can return a
JSON-serializable value wrapped in `base::I()`, which ellmer will leave
alone until the entire request is JSON-serialized.

###### Usage

    Chat$register_tool(tool_def)

###### Arguments

`tool_def`  
Tool definition created by `tool()`.

------------------------------------------------------------------------

<span id="method-Chat-get_provider"></span>

##### Method `get_provider()`

Get the underlying provider object. For expert use only.

###### Usage

    Chat$get_provider()

------------------------------------------------------------------------

<span id="method-Chat-get_tools"></span>

##### Method `get_tools()`

Retrieve the list of registered tools.

###### Usage

    Chat$get_tools()

------------------------------------------------------------------------

<span id="method-Chat-set_tools"></span>

##### Method `set_tools()`

Sets the available tools. For expert use only; most users should use
`register_tool()`.

###### Usage

    Chat$set_tools(tools)

###### Arguments

`tools`  
A list of tool definitions created with `tool()`.

------------------------------------------------------------------------

<span id="method-Chat-clone"></span>

##### Method `clone()`

The objects of this class are cloneable with this method.

###### Usage

    Chat$clone(deep = FALSE)

###### Arguments

`deep`  
Whether to make a deep clone.

#### Examples

``` R
chat <- chat_openai(echo = TRUE)
chat$chat("Tell me a funny joke")
```

ellmer::chat_anthropic
```r
function (system_prompt = NULL, params = NULL, max_tokens = deprecated(), 
    model = NULL, api_args = list(), base_url = "https://api.anthropic.com/v1", 
    beta_headers = character(), api_key = anthropic_key(), echo = NULL) 
{
    echo <- check_echo(echo)
    model <- set_default(model, "claude-3-7-sonnet-latest")
    params <- params %||% params()
    if (lifecycle::is_present(max_tokens)) {
        lifecycle::deprecate_warn(when = "0.2.0", what = "chat_anthropic(max_tokens)", 
            with = "chat_anthropic(params)")
        params$max_tokens <- max_tokens
    }
    provider <- ProviderAnthropic(name = "Anthropic", model = model, 
        params = params %||% params(), extra_args = api_args, 
        base_url = base_url, beta_headers = beta_headers, api_key = api_key)
    Chat$new(provider = provider, system_prompt = system_prompt, 
        echo = echo)
}
```

vignette("vitals", "vitals")
# Getting started with vitals {#getting-started-with-vitals .title .toc-ignore}

At their core, LLM evals are composed of three pieces:

1.  **Datasets** contain a set of labelled samples. Datasets are just a
    tibble with columns `input` and `target`, where `input` is a prompt
    and `target` is either literal value(s) or grading guidance.
2.  **Solvers** evaluate the `input` in the dataset and produce a final
    result (hopefully) approximating `target`. In vitals, the simplest
    solver is just an ellmer chat (e.g. `ellmer::chat_anthropic()`)
    wrapped in `generate()`, i.e. `generate(ellmer::chat_anthropic()`),
    which will call the Chat object's `$chat()` method and return
    whatever it returns.
3.  **Scorers** evaluate the final output of solvers. They may use text
    comparisons, model grading, or other custom schemes to determine how
    well the solver approximated the `target` based on the `input`.

This vignette will explore these three components using `are`, an
example dataset that ships with the package.

First, load the required packages:

::: {#cb1 .sourceCode}
``` {.sourceCode .r}
library(vitals)
library(ellmer)
library(dplyr)
library(ggplot2)
```
:::

:::::: {#an-r-eval-dataset .section .level2}
## An R eval dataset

From the `are` docs:

> An R Eval is a dataset of challenging R coding problems. Each `input`
> is a question about R code which could be solved on first-read only by
> human experts and, with a chance to read documentation and run some
> code, by fluent data scientists. Solutions are in `target` and enable
> a fluent data scientist to evaluate whether the solution deserves
> full, partial, or no credit.

::: {#cb2 .sourceCode}
``` {.sourceCode .r}
glimpse(are)
```
:::

    #> Rows: 26
    #> Columns: 7
    #> $ id        <chr> "after-stat-bar-heights", "conditional-grouped-summary", "co…
    #> $ input     <chr> "This bar chart shows the count of different cuts of diamond…
    #> $ target    <chr> "Preferably: \n\n```\nggplot(data = diamonds) + \n  geom_bar…
    #> $ domain    <chr> "Data analysis", "Data analysis", "Data analysis", "Programm…
    #> $ task      <chr> "New code", "New code", "New code", "Debugging", "New code",…
    #> $ source    <chr> "https://jrnold.github.io/r4ds-exercise-solutions/data-visua…
    #> $ knowledge <list> "tidyverse", "tidyverse", "tidyverse", "r-lib", "tidyverse"…

At a high level:

-   `id`: A unique identifier for the problem.
-   `input`: The question to be answered.
-   `target`: The solution, often with a description of notable features
    of a correct solution.
-   `domain`, `task`, and `knowledge` are pieces of metadata describing
    the kind of R coding challenge.
-   `source`: Where the problem came from, as a URL. Many of these
    coding problems are adapted "from the wild" and include the kinds of
    context usually available to those answering questions.

For the purposes of actually carrying out the initial evaluation, we're
specifically interested in the `input` and `target` columns. Let's print
out the first entry in full so you can get a taste of a typical problem
in this dataset:

::: {#cb4 .sourceCode}
``` {.sourceCode .r}
cat(are$input[1])
```
:::

    #> This bar chart shows the count of different cuts of diamonds, and each
    #> bar is stacked and filled according to clarity:
    #> 
    #> ```
    #> ggplot(data = diamonds) +
    #> geom_bar(mapping = aes(x = cut, fill = clarity))
    #> ```
    #> 
    #> Could you change this code so that the proportion of diamonds with a
    #> given cut corresponds to the bar height and not the count? Each bar
    #> should still be filled according to clarity.

Here's the suggested solution:

::: {#cb6 .sourceCode}
``` {.sourceCode .r}
cat(are$target[1])
```
:::

    #> Preferably:
    #> 
    #> ```
    #> ggplot(data = diamonds) +
    #> geom_bar(aes(x = cut, y = after_stat(count) / sum(after_stat(count)),
    #> fill = clarity))
    #> ```
    #> 
    #> The dot-dot notation (`..count..`) was deprecated in ggplot2 3.4.0, but
    #> it still works:
    #> 
    #> ```
    #> ggplot(data = diamonds) +
    #> geom_bar(aes(x = cut, y = ..count.. / sum(..count..), fill = clarity))
    #> ```
    #> 
    #> Simply setting `position = "fill" will result in each bar having a
    #> height of 1 and is not correct.
::::::

::::::: {#creating-and-evaluating-a-task .section .level2}
## Creating and evaluating a task

LLM evaluation with vitals happens in two main steps:

1.  Use `Task$new()` to situate a dataset, solver, and scorer in a
    `Task`.

::: {#cb8 .sourceCode}
``` {.sourceCode .r}
are_task <- Task$new(
  dataset = are,
  solver = generate(chat_anthropic(model = "claude-3-7-sonnet-latest")),
  scorer = model_graded_qa(partial_credit = TRUE),
  name = "An R Eval"
)

are_task
```
:::

2.  Use `Task$eval()` to evaluate the solver, evaluate the scorer, and
    then explore a persistent log of the results in the interactive
    Inspect log viewer.

::: {#cb9 .sourceCode}
``` {.sourceCode .r}
are_task$eval()
```
:::

After evaluation, the task contains information from the solving and
scoring steps. Here's what the model responded to that first question
with:

::: {#cb10 .sourceCode}
``` {.sourceCode .r}
cat(are_task$samples$result[1])
```
:::

    #> # Converting a stacked bar chart from counts to proportions
    #> 
    #> To change the bar heights from counts to proportions, you need to use
    #> the `position = "fill"` argument in `geom_bar()`. This will normalize
    #> each bar to represent proportions (with each bar having a total height
    #> of 1), while maintaining the stacked clarity segments.
    #> 
    #> Here's the modified code:
    #> 
    #> ```r
    #> ggplot(data = diamonds) +
    #> geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill") +
    #> labs(y = "Proportion") # Updating y-axis label to reflect the change
    #> ```
    #> 
    #> This transformation:
    #> - Maintains the stacking by clarity within each cut category
    #> - Scales each bar to the same height (1.0)
    #> - Shows the proportion of each clarity level within each cut
    #> - Allows for easier comparison of clarity distributions across
    #> different cuts
    #> 
    #> The y-axis will now range from 0 to 1, representing the proportion
    #> instead of raw counts.

The task also contains score information from the scoring step. We've
used `model_graded_qa()` as our scorer, which uses another model to
evaluate the quality of our solver's solutions against the reference
solutions in the `target` column. `model_graded_qa()` is a model-graded
scorer provided by the package. This step compares Claude's solutions
against the reference solutions in the `target` column, assigning a
score to each solution using another model. That score is either `1` or
`0`, though since we've set `partial_credit = TRUE`, the model can also
choose to allot the response `.5`. vitals will use the same model that
generated the final response as the model to score solutions.

Hold up, though---we're using an LLM to generate responses to questions,
and then using the LLM to grade those responses?

![The meme of 3 spiderman pointing at each
other.]()

This technique is called "model grading" or "LLM-as-a-judge." Done
correctly, model grading is an effective and scalable solution to
scoring. That said, it's not without its faults. Here's what the grading
model thought of the response:

::: {#cb12 .sourceCode}
``` {.sourceCode .r}
cat(are_task$samples$scorer_chat[[1]]$last_turn()@text)
#> I need to assess whether the submission meets the criterion for
#> changing the bar chart to show proportions instead of counts.
#> 
#> The submission suggests using `position = "fill"` in the `geom_bar()`
#> function. This approach would normalize each bar to have a total height
#> of 1, showing the proportion of different clarity levels within each
#> cut category.
#> 
#> However, the criterion specifies a different approach. According to the
#> criterion, each bar should represent the proportion of diamonds with a
#> given cut relative to the total number of diamonds. This means using
#> either:
#> 1. `aes(x = cut, y = after_stat(count) / sum(after_stat(count)), fill =
#> clarity)` (preferred modern syntax)
#> 2. `aes(x = cut, y = ..count.. / sum(..count..), fill = clarity)`
#> (deprecated but functional syntax)
#> 
#> The criterion explicitly states that using `position = "fill"` is not
#> correct because it would make each bar have a height of 1, rather than
#> showing the true proportion of each cut in the overall dataset.
#> 
#> The submission is suggesting a different type of proportional
#> representation than what is being asked for in the criterion. The
#> submission shows the distribution of clarity within each cut, while the
#> criterion is asking for the proportion of each cut in the total
#> dataset.
#> 
#> GRADE: I
```
:::
:::::::

::::::::: {#analyzing-the-results .section .level2}
## Analyzing the results

Especially the first few times you run an eval, you'll want to inspect
(ha!) its results closely. The vitals package ships with an app, the
Inspect log viewer, that allows you to drill down into the solutions and
grading decisions from each model for each sample. In the first couple
runs, you'll likely find revisions you can make to your grading guidance
in `target` that align model responses with your intent.

![The Inspect log viewer, an interactive app displaying information on
the samples evaluated in this
eval.]

Under the hood, when you call `task$eval()`, results are written to a
`.json` file that the Inspect log viewer can read. The Task object
automatically launches the viewer when you call `task$eval()` in an
interactive session. You can also view results any time with
`are_task$view()`. You can explore this eval above (on the package's
pkgdown site).

For a cursory analysis, we can start off by visualizing correct
vs. partially correct vs. incorrect answers:

::: {#cb13 .sourceCode}
``` {.sourceCode .r}
are_task_data <- vitals_bind(are_task)

are_task_data
#> # A tibble: 26 × 4
#>    task     id                          score metadata         
#>    <chr>    <chr>                       <ord> <list>           
#>  1 are_task after-stat-bar-heights      I     <tibble [1 × 10]>
#>  2 are_task conditional-grouped-summary P     <tibble [1 × 10]>
#>  3 are_task correlated-delays-reasoning C     <tibble [1 × 10]>
#>  4 are_task curl-http-get               C     <tibble [1 × 10]>
#>  5 are_task dropped-level-legend        I     <tibble [1 × 10]>
#>  6 are_task geocode-req-perform         C     <tibble [1 × 10]>
#>  7 are_task ggplot-breaks-feature       I     <tibble [1 × 10]>
#>  8 are_task grouped-filter-summarize    P     <tibble [1 × 10]>
#>  9 are_task grouped-mutate              C     <tibble [1 × 10]>
#> 10 are_task implement-nse-arg           P     <tibble [1 × 10]>
#> # ℹ 16 more rows

are_task_data %>%
  ggplot() +
  aes(x = score) +
  geom_bar()
```
:::

![A ggplot2 bar plot, showing Claude was correct most of the
time.]

Claude answered fully correctly in 14 out of 26 samples, and partially
correctly 6 times.For me, this leads to all sorts of questions:

-   Are there any models that are cheaper than Claude that would do just
    as well? Or even a local model?
-   Are there other models available that would do better out of the
    box?
-   Would Claude do better if I allow it to "reason" briefly before
    answering?
-   Would Claude do better if I gave it tools that'd allow it to peruse
    documentation and/or run R code before answering? (See
    [`btw::btw_register_tools()`](https://posit-dev.github.io/btw/reference/btw_register_tools.html)
    if you're interested in this.)

These questions can be explored by evaluating Tasks against different
solvers and scorers. For example, to compare Claude's performance with
OpenAI's GPT-4o, we just need to clone the object and then run `$eval()`
with a different solver `chat`:

::: {#cb14 .sourceCode}
``` {.sourceCode .r}
are_task_openai <- are_task$clone()
are_task_openai$eval(solver_chat = chat_openai(model = "gpt-4o"))
```
:::

Any arguments to solving or scoring functions can be passed directly to
`$eval()`, allowing for quickly evaluating tasks across several
parameterizations.

Using this data, we can quickly juxtapose those evaluation results:

::: {#cb15 .sourceCode}
``` {.sourceCode .r}
are_task_eval <-
  vitals_bind(are_task, are_task_openai) %>%
  mutate(
    task = if_else(task == "are_task", "Claude", "GPT-4o")
  ) %>%
  rename(model = task)

are_task_eval %>%
  mutate(
    score = factor(
      case_when(
        score == "I" ~ "Incorrect",
        score == "P" ~ "Partially correct",
        score == "C" ~ "Correct"
      ),
      levels = c("Incorrect", "Partially correct", "Correct"),
      ordered = TRUE
    )
  ) %>%
  ggplot(aes(y = model, fill = score)) +
  geom_bar() +
  scale_fill_brewer(breaks = rev, palette = "RdYlGn")
```
:::

Is this difference in performance just a result of noise, though? We can
supply the scores to an ordinal regression model to answer this
question.

::: {#cb16 .sourceCode}
``` {.sourceCode .r}
library(ordinal)
#> 
#> Attaching package: 'ordinal'
#> The following object is masked from 'package:dplyr':
#> 
#>     slice

are_mod <- clm(score ~ model, data = are_task_eval)

are_mod
#> formula: score ~ model
#> data:    are_task_eval
#> 
#>  link  threshold nobs logLik AIC    niter max.grad cond.H 
#>  logit flexible  52   -54.80 115.61 4(0)  2.15e-12 1.2e+01
#> 
#> Coefficients:
#> modelGPT-4o 
#>     -0.9725 
#> 
#> Threshold coefficients:
#>      I|P      P|C 
#> -1.35956 -0.09041
```
:::

The coefficient for `model == "GPT-4o"` is -0.972, indicating that
GPT-4o tends to be associated with lower grades. If a 95% confidence
interval for this coefficient contains zero, we can conclude that there
is not sufficient evidence to reject the null hypothesis that the
difference between GPT-4o and Claude's performance on this eval is zero
at the 0.05 significance level.

::: {#cb17 .sourceCode}
``` {.sourceCode .r}
confint(are_mod)
#>                 2.5 %     97.5 %
#> modelGPT-4o -2.031694 0.04806051
```
:::

::: callout-note
If we had evaluated this model across multiple epochs, the question ID
could become a "nuisance parameter" in a mixed model, e.g. with the
model structure `ordinal::clmm(score ~ model + (1|id), ...)`.
:::

This vignette demonstrated the simplest possible evaluation based on the
`are` dataset. If you're interested in carrying out more advanced evals,
check out the other vignettes in this package!
:::::::::
