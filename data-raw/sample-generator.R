# A shiny app used to write samples with a nice UI.
# This code was model-generated with `data-raw/sample-generator-prompt.txt`.
library(shiny)
library(jsonlite)
library(glue)
library(tidyverse)

# Define UI
ui <- fluidPage(
  titlePanel("Eval sample JSON generator"),

  fluidRow(
    # Left Column
    column(
      6,
      textInput("id", "ID", placeholder = "e.g. 'cli-sprintf'"),
      textAreaInput("user", "User", rows = 4),
      textAreaInput("target", "Target", rows = 4)
    ),

    # Right Column
    column(
      6,
      selectInput(
        "helper",
        "Helper",
        choices = c(
          "NA" = "NA",
          "cli" = "cli",
          "roxygen" = "roxygen",
          "testthat" = "testthat",
          "Other" = "other"
        )
      ),
      conditionalPanel(
        condition = "input.helper == 'other'",
        textInput("otherHelper", "Specify Other Helper")
      ),
      textAreaInput("source", "Source", rows = 4),
      radioButtons(
        "parsable",
        "Parsable",
        choices = c("Yes" = "yes", "No" = "no"),
        selected = "yes"
      ),
      br(),
      actionButton("submit", "Submit", class = "btn-primary"),
      br(),
      br(),
      textOutput("statusMsg")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  # Create reactive status message
  status <- reactiveVal("")

  # Update the status message output
  output$statusMsg <- renderText({
    status()
  })

  # Handle submission
  observeEvent(input$submit, {
    # Validate ID
    if (input$id == "") {
      status("Error: ID cannot be empty!")
      return()
    }

    # Create data structure
    helper_value <- if (input$helper == "other") input$otherHelper else
      input$helper
    if (helper_value == "NA") helper_value <- NA

    data <- list(
      id = input$id,
      user = input$user,
      target = input$target,
      helper = helper_value,
      source = input$source,
      parsable = tolower(input$parsable) == "yes"
    )

    # Create directory if it doesn't exist
    dir.create(
      "data-raw/chores-dataset",
      recursive = TRUE,
      showWarnings = FALSE
    )

    # Write to file
    filename <- glue("data-raw/chores-dataset/{input$id}.json")
    write_json(data, filename, pretty = TRUE, auto_unbox = TRUE)

    # Update status and reset inputs
    status("Sample written to file!")

    # Reset all inputs
    updateTextInput(session, "id", value = "")
    updateTextAreaInput(session, "user", value = "")
    updateTextAreaInput(session, "target", value = "")
    updateSelectInput(session, "helper", selected = "NA")
    updateTextAreaInput(session, "source", value = "")
    updateRadioButtons(session, "parsable", selected = "yes")
  })
}

# Run the application
shinyApp(ui = ui, server = server)
