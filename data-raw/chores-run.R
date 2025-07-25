devtools::load_all()
library(ellmer)

# Anthropic --------------------------------------------------------------------
claude_opus_4 <- chat_anthropic(model = "claude-opus-4-20250514")
claude_sonnet_4 <- chat_anthropic(model = "claude-sonnet-4-20250514")


# OpenAI -----------------------------------------------------------------------
gpt_4_1 <- chat_openai(model = "gpt-4.1")
gpt_4_1_mini <- chat_openai(model = "gpt-4.1-mini")
gpt_4_1_nano <- chat_openai(model = "gpt-4.1-nano")

# Google Gemini ----------------------------------------------------------------
gemini_2_5_pro <- chat_google_gemini(
  model = "gemini-2.5-pro"
)

gemini_2_5_flash_thinking <- chat_google_gemini(
  model = "gemini-2.5-flash-preview-05-20"
)

gemini_2_5_flash_non_thinking <- chat_google_gemini(
  model = "gemini-2.5-flash-preview-05-20",
  api_args = list(
    generationConfig = list(
      thinkingConfig = list(
        thinkingBudget = 0
      )
    )
  )
)

# All together -----------------------------------------------------------------
# fmt: skip
eval_models <- tibble::tribble(
  ~solver_chat, ~name,
  claude_opus_4, "claude_opus_4",
  claude_sonnet_4, "claude_sonnet_4",
  gpt_4_1, "gpt_4_1",
  gpt_4_1_mini, "gpt_4_1_mini",
  gpt_4_1_nano, "gpt_4_1_nano",
  gemini_2_5_pro, "gemini_2_5_pro",
  gemini_2_5_flash_thinking, "gemini_2_5_flash_thinking",
  gemini_2_5_flash_non_thinking, "gemini_2_5_flash_non_thinking"
)

chores_eval_safely <- function(...) {
  purrr::safely(chores_eval(...))
  Sys.sleep(45)
}

purrr::pmap(eval_models, chores_eval_safely)
