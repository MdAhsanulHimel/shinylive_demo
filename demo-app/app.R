# app.R

library(shiny)
library(shinyalert)
library(shinyWidgets)

# Filter Save Module ---------------------
# UI function for Filter Save Module
filterSaveUI <- function(id) {
  ns <- NS(id)
  actionButton(ns("show_alert"), "Click to Show Alert")
}

# Server function for Filter Save Module
filterSaveServer <- function(id, intern) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Show shinyalert when the button is clicked
    observeEvent(input$show_alert, {
      shinyalert(
        title = "Save Filter",
        html = TRUE,
        text = tagList(
          textInput(ns("saveFilterName"), "Name"), 
          actionButton(ns("saveFilterButton"), "Save now")
        ),
        showConfirmButton = FALSE,
        closeOnClickOutside = TRUE,
        closeOnEsc = TRUE
      )
    })
    
    # Handle saving the filter
    observeEvent(input$saveFilterButton, {
      filter_name <- input$saveFilterName
      
      if (filter_name != "") {
        intern$savedFilter[[filter_name]] <- filter_name
        shinyalert::closeAlert()
      }
    })
  })
}





# Filter Display Module --------------------

filterDisplayUI <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("savedFilterRow")),
    actionButton(ns("deleteFilterButton"), "Delete Selected Filter")
  )
}

# Server function for Filter Display Module
filterDisplayServer <- function(id, intern) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Render the saved filters as radio buttons
    output$savedFilterRow <- renderUI({
      req(intern$savedFilter)
      namen <- names(intern$savedFilter)
      if (length(namen) == 0) return(NULL)
      
      radioGroupButtons(
        inputId = ns("savedFilterSelection"), 
        label = "Saved Filter", 
        choices = namen, 
        selected = ""
      )
    })
    
    # Observe the delete button click
    observeEvent(input$deleteFilterButton, {
      selected_filter <- input$savedFilterSelection
      if (!is.null(selected_filter) && selected_filter != "") {
        intern$savedFilter[[selected_filter]] <- NULL  # Delete the selected filter
      }
    })
  })
}

# APP UI ------------------------------------------------------------
ui <- fluidPage(
  useShinyalert(),  # Initialize shinyalert in the app
  
  titlePanel("Modular Shiny App with Saved Filters"),
  
  sidebarLayout(
    sidebarPanel(
      filterSaveUI("filterSave"),  # Use the Filter Save Module UI
      filterDisplayUI("filterDisplay")  # Use the Filter Display Module UI
    ),
    
    mainPanel(
      textOutput("filter_name")
    )
  )
)

# APP SERVER ----------------------------------------------
server <- function(input, output, session) {
  
  # Internal storage for saved filters
  intern <- reactiveValues(savedFilter = list())
  
  # Call the Filter Save Module
  filterSaveServer("filterSave", intern)
  
  # Call the Filter Display Module
  filterDisplayServer("filterDisplay", intern)
}

# Run the application
shinyApp(ui = ui, server = server)
