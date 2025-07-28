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

## Local ollama models -----------------------------------------------

# Includes <think><\think> in the response even with /no_think.
# At some point in the future, chores/streamy might support excluding content
# from specific tags, but not the case yet.
# qwen3_32b <- chat_ollama(model = "qwen3:32b")
# qwen3_14b <- chat_ollama(model = "qwen3:14b")

# Similar story with magistral--100 tokens of rambling before a response
# with a strange `\boxed{\text{}}` output format.`
# magistral <- chat_ollama(model = "magistral")

mistral_small3_2 <- chat_ollama(model = "mistral-small3.2")
deepseek_r1_8b <- chat_ollama(model = "deepseek-r1:8b")
deepseek_r1_32b <- chat_ollama(model = "deepseek-r1:32b")
gemma3_27b <- chat_ollama(model = "gemma3:27b")
gemma3_12b <- chat_ollama(model = "gemma3:12b")

# ollama pull qwen3:32b
# ollama pull qwen3:14b
#
# ollama pull magistral
# ollama pull mistral-small3.2
#
# ollama pull deepseek-r1:8b
# ollama pull deepseek-r1:32b
#
# ollama pull gemma3:27b
# ollama pull gemma3:12b

# All together -----------------------------------------------------------------
# fmt: skip
eval_models <- tibble::tribble(
  ~solver_chat, ~name,
  #     claude_opus_4, "claude_opus_4",
  #     claude_sonnet_4, "claude_sonnet_4",
  #     gpt_4_1, "gpt_4_1",
  #     gpt_4_1_mini, "gpt_4_1_mini",
  #     gpt_4_1_nano, "gpt_4_1_nano",
  #     gemini_2_5_pro, "gemini_2_5_pro",
  #     gemini_2_5_flash_thinking, "gemini_2_5_flash_thinking",
  #     gemini_2_5_flash_non_thinking, "gemini_2_5_flash_non_thinking",
  # qwen3_32b, "qwen3_32b",
  # qwen3_14b, "qwen3_14b",
  # magistral, "magistral",
  mistral_small3_2, "mistral_small3_2",
  deepseek_r1_8b, "deepseek_r1_8b",
  deepseek_r1_32b, "deepseek_r1_32b",
  gemma3_27b, "gemma3_27b",
  gemma3_12b, "gemma3_12b"
)

chores_eval_safely <- function(solver_chat, name) {
  cli::cli_inform("Evaluating {.field {name}}")
  # For ollama models, make sure the model is running so eval doesn't
  # inforporate a "cold start"
  solver_chat$clone()$chat("Hey!", echo = FALSE)
  purrr::safely(chores_eval(solver_chat, name))
}

purrr::pmap(eval_models, chores_eval_safely)
