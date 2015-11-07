library("shiny")
library("gridExtra")

# Read in the data. 
source("sharedFuns.R")
source("read.R")

shinyServer(
  function(input, output) {
    
    dat_db_cond <- reactive({
      subset(dat, source_name==input$DB & concept_id==input$Cond)
    })
    
    dat_year <- reactive({
      subset(dat, source_name==input$DB & 
               year(time_period)==as.numeric(input$Year) &
               concept_id==input$Cond)
    })
    
    dat_control_mean <- reactive({
      # Subset the data. 
      dat_control <- subset(dat, source_name==input$DB & 
                              year(time_period) != as.numeric(input$Year) &
                              concept_id==input$Cond)
      # Compute mean and SE by month. 
      dat_control_mean <- summarySE(dat_control, measurevar="prevalence", groupvars="month")
      dat_control_mean[ , upper := prevalence + se]
      dat_control_mean[ , lower := prevalence - se]
      dat_control_mean
    })
    
    flagged_dat <- reactive({
      flagged_dat <- merge(dat_year(), dat_control_mean(), by="month")
      setnames(flagged_dat, "prevalence.x", "prevalence_year")
      setnames(flagged_dat, "prevalence.y", "prevalence_control")
      flagged_dat[ , flag_color := ifelse(prevalence_year > upper | 
                     prevalence_year < lower, "red", "black")]
      flagged_dat
    })
    
    output$mainplot <- renderPlot({
      overview_plot <- ggplot(dat_db_cond(), aes(x=time_period, y=prevalence)) + 
        geom_line() +
        geom_point() + 
        labs(title=paste("Overview of", input$DB, "for Concept_id", input$Cond)) + 
        xlab("Time") + 
        ylab("Prevalence") + 
        theme_alex
      year_comparison_plot <- ggplot(flagged_dat(), aes(x=month, y=prevalence_control)) + 
        geom_line() + 
        geom_line(aes(x=month, y=prevalence_year)) +
        geom_point(aes(x=month, y=prevalence_year, color=flag_color), color=flagged_dat()$flag_color, size=5) +
        geom_line(aes(x=month, y=upper), linetype=9) +
        geom_line(aes(x=month, y=lower), linetype=9) +
        scale_color_manual(values=c("black", "red"), labels=c("Normal", "Anomaly")) + 
        labs(title=paste("Comparison of year", input$Year, "to all mean of other years")) +
        xlab("Month (1-12)") + 
        ylab("Prevalence") + 
        theme_alex
      grid.arrange(overview_plot, year_comparison_plot, nrow=2)
    })
  }
)