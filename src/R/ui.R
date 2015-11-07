library(shiny)

shinyUI(fluidPage(
  titlePanel("Anomaly Detective!"),
  sidebarLayout(
    sidebarPanel(
      numericInput("Cond", "Enter Concept ID", 312664),
      br(),
      br(),
      selectInput("Year", "Select Year", choices=c("2011" = 2011), multiple = F),
      br(),
      br(),
      selectInput("DB", "Select Database", choices=c("JMDC" = "JMDC"), multiple = F ),
      br()
      ),
    mainPanel(
      tabsetPanel(type="tab",
                  tabPanel("AD",plotOutput("mainplot", height = 600))
                  )
      
    )
  )
))
