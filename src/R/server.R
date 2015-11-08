library("shiny")
library("gridExtra")
library("ggplot2")
library("ggfortify")
library("forecast")
library("changepoint")
library("strucchange")

# Read in the data.
source("sharedFuns.R")
source("read.R")

shinyServer(
  function(input, output) {

    dat_db_cond <- reactive({
      subset(dat, source_name==input$DB & concept_id==input$Cond)
    })

    # Compute average year.
    avg_year <- reactive({
      ddc <- subset(dat, source_name==input$DB & concept_id==input$Cond)
      avg_year <- summarySE(ddc, measurevar="prevalence", groupvars="month", na.rm=TRUE)
      avg_year[ , upper := prevalence + se]
      avg_year[ , lower := prevalence - se]
      avg_year
    })

    # Compute control data: this is defined as the average year excluding the current
    # year.
    control_dat <- reactive({
      control_dat <- data.table()
      ddc <- subset(dat, source_name==input$DB & concept_id==input$Cond)
      for (yr in unique(ddc$year)){
        subset_dat <- subset(ddc, year != yr)
        cdat <- summarySE(subset_dat, measurevar="prevalence", groupvars="month", na.rm=TRUE)
        cdat[ , control_year := yr]
        cdat[ , time_period := ymd(paste0(control_year, sprintf("%02d", month), "01"))]
        control_dat <- rbindlist(list(control_dat, cdat), use.names=TRUE, fill=TRUE)
      }
      # Rename variables.
      control_dat[ , upper := prevalence + input$multse * se]
      control_dat[ , lower := prevalence - input$multse * se]
      setnames(control_dat, "prevalence", "control_prevalence")
      setnames(control_dat, "control_year", "year")
      setnames(control_dat, "N", "num_data_points")
      control_dat <- subset(control_dat, select=c("month", "year", "time_period",
                                                  "control_prevalence",
                                                  "num_data_points", "se",
                                                  "upper", "lower"))
      control_dat <-merge(ddc, control_dat, all=TRUE, by=c("year", "month", "time_period"))
      # Fill in NAs.
      control_dat[ , source_name := unique(ddc$source_name)]
      control_dat[ , concept_name := unique(ddc$concept_name)]

      # Compute flags on control data.
      control_dat[ , flag := prevalence > upper | prevalence < lower]
      control_dat[is.na(flag), flag := FALSE]
      control_dat[ , flag_color := ifelse(flag, "red", "black")]
      control_dat[ , flag_binary := ifelse(flag, 1, 0)]
      control_dat
    })

    # Plot: Overview.
    output$mainplot <- renderPlot({
      overview_plot <- ggplot(dat_db_cond(), aes(x=time_period, y=prevalence)) +
        geom_line() +
        geom_point() +
        labs(title=paste(paste("Overview of", input$DB, "for:"),
                         dat_db_cond()$concept_name[1], sep="\n")) +
        xlab("Time") +
        ylab("Prevalence") +
        theme_alex
      # Facetted plot by year.
      facet_plot <- ggplot(control_dat(), aes(x=time_period, y=control_prevalence)) +
        geom_line(color="darkgray") +
        geom_ribbon(aes(ymin=lower, ymax=upper), alpha=0.3) +
        geom_point(aes(x=time_period, y=prevalence, color=flag_color), size=5) +
        scale_color_manual(values=c("black", "red"), labels=c("Normal", "Anomaly")) +
        geom_line(aes(x=time_period, y=prevalence)) +
        facet_wrap(~ year, scale="free_x", nrow=1) +
        theme(axis.text.x=element_text(angle=90)) +
        ylab("Prevalence") +
        xlab("Time") +
        theme_alex
      # Plot: Annual Average.
      avg_year_plot <- ggplot(avg_year(), aes(month, prevalence)) +
        geom_line(size=2) +
        geom_point(size=2) +
        geom_line(aes(month, upper), linetype=9) +
        geom_line(aes(month, lower), linetype=9) +
        labs(title=paste("Average Year (mean of prevalence by month) for:",
                         dat_db_cond()$concept_name[1], sep="\n")) +
        xlab("Month") +
        ylab("Prevalence") +
        scale_x_continuous(limits=c(1, 12), breaks=1:12) +
        theme_alex
      grid.arrange(overview_plot, facet_plot, avg_year_plot, nrow=3)
    })

    output$table <- renderPrint({
      concept_name <- dat_db_cond()$concept_name[1]
      source_name <- dat_db_cond()$source_name[1]
      print(concept_name)
      print(source_name)
      table_subset <- subset(control_dat(), flag==TRUE, select=c("year", "month",
                                                                 "prevalence",
                                                                 "control_prevalence", "se"))
      table_subset[ , deviation := abs(prevalence - control_prevalence) / se]
      table_subset <- table_subset[(order(-deviation))]
      table_subset
    })

#     output$tabletitle <- renderText({
#       concept_name <- dat_db_cond()$concept_name[1]
#     })

    output$tsplot <- renderPlot({
      first_year <- dat_db_cond()[ , min(year)]
      first_month <- dat_db_cond()[ , min(month)]
      last_year <- dat_db_cond()[ , max(year)]
      last_month <- dat_db_cond()[ , max(month)]

      #figure out how this handles nulls and maybe put the 0s in
      ts <- ts(dat_db_cond()$prevalence, start=c(first_year, first_month),
               end=c(last_year, last_month), frequency=12)
      stl <- stl(ts, s.window="periodic")
      #       plot(stl, main=paste0("Seasonal Decomposition for:",
      #                             input$Cond, sep="\n"),
      #            col.range="blue")
      ts_vars <- autoplot(stl, ts.colour = 'blue')
      ts_vars <- ts_vars +
        labs(title=paste("Seasonal Decomposition for:",
                          dat_db_cond()$concept_name[1], sep="\n")) +
        theme_alex

      # Time series trend plot.
      breakpoint <- autoplot(cpt.meanvar(ts)) +
        labs(title=paste("Change Points for:",
                         dat_db_cond()$concept_name[1], sep="\n")) +
        theme_alex
      grid.arrange(ts_vars, breakpoint, nrow=2,
                   heights=c(4, 1))
    })

    output$condplot <- renderPlot({
      sub <- dat[dat$concept_id == input$Cond, ]
      concept_name <- sub[1, ]$concept_name
      p <- ggplot(sub, aes(x = time_period, y = prevalence)) +
        geom_point(aes(colour = source_name)) +
        # facet_wrap( ~ source_name, ncol=2) +
        geom_smooth(aes(colour = source_name)) +
        ggtitle(paste(concept_name, "by Database Source")) +
        xlab("Time") +
        ylab("Prevalence") +
        xlim(ymd('20050101'), ymd('20141231')) +
        theme_alex
      p
    })

  }
)