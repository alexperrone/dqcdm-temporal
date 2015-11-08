library(shiny)

shinyUI(fluidPage(
  titlePanel("Anomaly Detective!"),
  sidebarLayout(
    sidebarPanel(
      numericInput("Cond", "Enter Concept ID", 312664),
      br(),
      br(),
      selectInput("Year", "Select Year", choices=c("2004" = 2004, "2005" = 2005, "2006" = 2006, 
                                                   "2007" = 2007, "2008" = 2008, "2009" = 2009, 
                                                   "2010" = 2010, "2011" = 2011, "2012" = 2012), 
                  multiple = F),
      br(),
      br(),
      selectInput("DB", "Select Database", choices=c("JMDC" = "JMDC", "CPRD" = "CPRD", 
                                                     "Optum" = "Optum", "Truven CCAE" = "Truven CCAE", 
                                                     "Truven MDCD" = "Truven MDCD", 
                                                     "Truven MDCR" = "Truven MDCR"),
                  multiple = F ),
      br()
      ),
    mainPanel(
      tabsetPanel(type="tab",
                  tabPanel("Year against Typical Year",plotOutput("mainplot", height = 600))
                  )
      
    )
  )
))
