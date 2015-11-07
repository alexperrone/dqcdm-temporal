library(shiny)
library(ggplot2)
library(gridExtra)
require(treemap)
require(dplyr)

shinyServer(
    function(input,output) {
 output$myplot <- renderPlot({
   data <- read.table("database.csv", header=T, sep=',')
   data$factor = as.factor(data$factor) 
   data$patient <- data$people
   data$people <- data$people/data$population
   data <- subset(data, data$year >= min(input$slider) & data$year <= max(input$slider) & data$group ==input$var) 
   
   z <- aggregate (data$people, by=list(data$factor), FUN=IQR,na.rm = TRUE)
   z[is.na(z)] <- 0
   names(z)[1]<-paste("year")
   names(z)[2]<-paste("iqr")
   data2 <- merge(data, z, by="year")
   mean <- mean(data2$iqr,na.rm = TRUE)
   data2$iqr <- (data2$iqr)/mean
   z2 <- aggregate (data$people, by=list(data$factor), FUN=sd,na.rm = TRUE)
   z2[is.na(z2)] <- 0
   names(z2)[1]<-paste("year")
   names(z2)[2]<-paste("std")
   data3 <- merge(data2, z2, by="year")
   mean2 <- mean(data3$std,na.rm = TRUE)
   data3$std <- (data3$std)/mean2
   z3 <- aggregate (data$people, by=list(data$factor), FUN=mean,na.rm = TRUE)
   z3[is.na(z3)] <- 0
   names(z3)[1]<-paste("year")
   names(z3)[2]<-paste("mean")
   data30 <- merge(data3, z3, by="year")
   z4 <- aggregate (data$patient, by=list(data$factor), FUN=mean,na.rm = TRUE)
   z4[is.na(z4)] <- 0
   names(z4)[1]<-paste("year")
   names(z4)[2]<-paste("meanP")
   data31 <- merge(data30, z4, by="year")
      
   mn1 <- min(input$slider2,na.rm = TRUE)
   mx1 <- max(input$slider2,na.rm = TRUE)
   mn2 <- min(input$slider3,na.rm = TRUE)
   mx2 <- max(input$slider3,na.rm = TRUE)
   yearm <- min(input$slider)
   
d <-   qplot(factor, people, data=data31, geom=c("boxplot", "jitter"), 
      fill=iqr, main="Patient by Clinic-Year--Based on Interquartile Range",   
    alpha=I(1/2), aes(color=factor),
    xlab="Year", ylab="W-Patient") 
    
d2 <- d + scale_fill_continuous(low="gold", high="red", limits=c(mn1,mx1)) 
d2

d3 <-   qplot(factor, people, data=data31, geom=c("boxplot", "jitter"), 
             fill=std, main="Patient by Clinic-Year--Based on Standard Deviation Range",   
             alpha=I(1/2), aes(color=factor),
             xlab="Year", ylab="W-Patient") 

d4 <- d3 + scale_fill_continuous(low="gold", high="red", limits=c(mn2,mx2))
d4

grid.arrange(d2, d4, nrow=2)

    
    })

output$myplot2 <- renderPlot({
  data <- read.table("database.csv", header=T, sep=',')
  data$factor = as.factor(data$factor) 
  data$patient <- data$people
  data$people <- data$people/data$population
  data4 <- subset(data, data$year >= min(input$slider) & data$year <= max(input$slider) & data$group ==input$var)    
  yearm <- min(input$slider)
  
  
  d5 <- qplot(year, people, data=data4, main="Patient by Clinic-Year-mean W-percentage",
              xlab="Year", ylab="W-Patient") + stat_smooth(level=0.99) + geom_point(position = "jitter", alpha = 0.3) + scale_x_continuous(breaks=yearm:2014)
  
  d5 
  
  d6 <- qplot(year, population, data=data4, main="Patient by Clinic-Year-Patient size",
              xlab="Year", ylab="Patient Pop") + stat_smooth(colour = "red",level=0.99) + geom_point(position = "jitter", alpha = 0.3) + scale_x_continuous(breaks=yearm:2014)
  
  d6 
  
  grid.arrange(d5, d6, nrow=2)
  
  
})


output$myplot3 <- renderPlot({
  data <- read.table("database.csv", header=T, sep=',')
  data$factor = as.factor(data$factor) 
  data$patient <- data$people
  data$people <- data$people/data$population
  
  #subset data to what is selected interactively
  data2 <- subset(data, data$year >= min(input$slider) & data$year <= max(input$slider) & data$group ==input$var) 
  
  #add std
  z <- aggregate (data$people, by=list(data$factor), FUN=sd,na.rm = TRUE)
  z[is.na(z)] <- 0
  names(z)[1]<-paste("year")
  names(z)[2]<-paste("std")
  data3 <- merge(data2, z, by="year")
  
  #calculate std ratio
  meanstd <- mean(data3$std,na.rm = TRUE)
  data3$std <- (data3$std)/meanstd
 
  
  #calculate index for when std is bigger than the average selected
  data3$index <- ifelse(data3$std>=(input$slider4), 1, 0)
  
  #generate 1 cell for counting number of cells
  data3$numb <- 1
  
  #plot the treemap
 
  treemap(data3, index=c('index','year'), vSize='numb', title = 'number of records with high variability in each year',
          fontsize.title = 30)

  
  
})


output$myplot4 <- renderPlot({
  data0 <- read.table("database.csv", header=T, sep=',')
  data0$factor = as.factor(data0$factor) 
  data0$patient <- data0$people
  data0$people <- data0$people/data0$population
  
  #subset data to what is selected interactively
  data <- subset(data0, data0$year >= min(input$slider) & data0$year <= max(input$slider) & data0$group ==input$var) 
  
  ##ignore the subsets
  ##training set
  #data2 <- subset(data, year <2012 & year > 1999) ##this should be data-1 year
  #data3 <- subset(data, year == 2013) ##this is the last year requested for if we want to show the last year data in a different color...data2+data3=data4
  #names(data)
  
  
  xdata <- data
  data$prd <- data$lowSE <- data$highSE <- 0
  ##for loop begins to calculate regression models for each LOC
  for(i in 1:length(unique(data$LOC))){
    x <- unique(data$LOC)[i]
    idX <-  which(data$LOC == x)
    xdata <- data[idX,]
    fit <- lm(xdata$patient~xdata$year,data=xdata)
    predObj <- predict(fit,newdata=xdata,interval="confidence"
                       , level = 0.95,type="response")
    data$prd[idX] <- predObj[,1]
    data$lowSE[idX] <- predObj[,2]
    data$highSE[idX] <- predObj[,3]
  }
  
  
  data$anom <- ifelse(data$patient>data$highSE | data$patient<data$lowSE, 1, 0)
  dataanom <- subset(data, data$anom == 1)
  ##regular plot of data 1
  plot(data$patient~data$year,  xlab="Year", ylab="Patient", type = "b" , 
       xlim=c(min(input$slider),max(input$slider)), pch=0) ##add x and y mins later-- , col=data$LOC
  points(dataanom$patient~dataanom$year, col = "red", pch=19)
  
  
})



output$sum <- renderPrint({
  data <- read.table("database.csv", header=T, sep=',')
  data$factor = as.factor(data$factor) 
  data$patient <- data$people
  data$people <- data$people/data$population
  data4 <- subset(data, data$year >= min(input$slider) & data$year <= max(input$slider) & data$group ==input$var)    
  yearm <- min(input$slider)  
  
  
  summary(data4)})
    }
    
    
  
  )