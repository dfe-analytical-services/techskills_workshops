# Load required libraries
library(shiny)
library(ggplot2)
library(dplyr)

# Load plot data
#plot_data <- read.csv("plot_data.csv")

# Define UI for Shiny app
ui <- fluidPage(
  
  # Add a title to the app
  titlePanel("Assessment Grades by Sex"),
  
  # Create a dropdown for the time period
  sidebarLayout(
    sidebarPanel(
      selectInput("time_period", "Time Period", choices = unique(plot_data$time_period))
    ),
    
    # Create a plot output for the grouped bar chart
    mainPanel(
      plotOutput("grouped_bar_chart")
    )
  )
)

# Define server for Shiny app
server <- function(input, output) {
  
  # Create a reactive filtered data frame based on the time period dropdown
  filtered_data <- reactive({
    plot_data %>%
      filter(time_period == input$time_period)
  })

  
  # Create a grouped bar chart based on the filtered and summarized data
  output$grouped_bar_chart <- renderPlot({
    ggplot(filtered_data(), aes(x = assessment, y = mean_grade, fill = sex)) +
      geom_bar(stat = "identity", position = "dodge") +
      xlab("Assessment") +
      ylab("Mean Grade") +
      ggtitle("Assessment Grades by Sex")
  })
  
}

# Run the Shiny app
shinyApp(ui = ui, server = server)