library(shiny)
require(shiny)


shinyUI(fluidPage(
  titlePanel("Anomaly Detective!"),
  sidebarLayout(
    sidebarPanel(
      numericInput("Cond", "Enter Concept ID"),
      br(),
      br(),
      selectInput("Year", "Select Year", choices=c("2014" = 1 , "2013" = 2,"2012" = 3 , "2011" = 4,"2010" = 5, "2009" = 6, "2008" = 7, "2007" = 8, "2006" = 9, "2005" = 10, "2004" = 11, "" = 12), selected = 12, multiple = F ),
      br(),
      br(),
      selectInput("DB", "Select Database", choices=c("CPRD" = 1 , "JMDC" = 2,"Optum" = 3 , "premier" = 4,"Truven CCAE" = 5, "Truven MDCD" = 6, "Truven MDCR" = 7, "" = 8), selected = 8, multiple = F ),
      br()
      
      ),
    mainPanel(
      tabsetPanel(type="tab",
                  tabPanel("AD",plotOutput("myplot", height = 600))
                  )
      
    )
  )
))
