# a smoke test for the model grading---runs a solver once and then asks
# many different models to grade it.
library(vitals)
library(ellmer)
devtools::load_all()

# models ---------------
gpt_4_1 <- chat_openai(model = "gpt-4.1")
gpt_4_1_mini <- chat_openai(model = "gpt-4.1-mini")
gpt_4_1_nano <- chat_openai(model = "gpt-4.1-nano")

claude_3_7 <- chat_anthropic(model = "claude-3-7-sonnet-latest")

gemini_2_5 <- chat_google_gemini(model = "gemini-2.5-pro-preview-03-25")

# running the eval -----
tsk <- chores_task()
tsk$solve(solver_chat = claude_3_7$clone())

save(tsk, file = "inst/smoke-test/tasks/tsk_solved.rda")

costs <- list()
tasks <- list()
for (scorer_chat in list(
  gpt_4_1,
  gpt_4_1_mini,
  gpt_4_1_nano,
  claude_3_7,
  gemini_2_5
)) {
  tsk_i <- tsk$clone()
  tsk_i$score(scorer_chat = scorer_chat)
  tsk_i$measure()
  tsk_i$log(dir = "inst/smoke-test/logs")
  tasks[[scorer_chat$get_model()]] <- tsk_i
  costs[[scorer_chat$get_model()]] <- tsk_i$get_cost()
}

save(tasks, file = "inst/smoke-test/tasks/tasks_scored.rda")

vitals_view("inst/smoke-test/logs")
