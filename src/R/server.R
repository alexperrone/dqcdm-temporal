library("shiny")
# library(ggplot2)
# library(gridExtra)
# require(treemap)
# require(dplyr)
# library("data.table")
# library("lubridate")
# library("magrittr")
# library("testhat")

# Read in the data. 
# source("sharedFuns.R")
# source("read.R")
# source("compare.R")

# Read in the data. 
# dat <- fread("data/dqcdm-temporal-summary/dqcdm_temporal_summary_subset_2.txt")
# 
# # Light munging. 
# dat[ , prevalence := as.double(prevalence)]
# dat[ , time_period := paste0(time_period, "01")]
# dat[ , time_period := ymd(time_period)]

shinyServer(
  function(input, output) {
    output$mainplot <- renderPlot({
      plot(1:10, 1:10)
      #g <- runComparison(dat, input$DB, input$Year, input$Cond)
      # print(g)
    })
  }
)