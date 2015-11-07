library("shiny")

# Read in the data. 
source("sharedFuns.R")
source("read.R")
source("compare.R")

shinyServer(
  function(input, output) {
    
    output$mainplot <- renderPlot({
      print("hello")
      sn <- input$DB
      year <- as.numeric(input$Year)
      cid <- input$Cond
      browser()
      res <- compareYearCondition(dat, sn, year, cid)
      res <- computeFlags(res$dat_year, res$dat_control_mean)
      g <- plotComparison(res)
      return(g)
    })
  }
)