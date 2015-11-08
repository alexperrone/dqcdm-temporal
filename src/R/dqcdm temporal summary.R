
library(xlsx)
library(lubridate)
library(reshape)
library(reshape2)
library(forecast)
library(tsoutliers)
library(strucchange)
library(ggplot2)
library(jpeg)

dqdata <- read.xlsx("C:/Documents/OHDSI/DQCDM/dqcdm_temporal_summary.xlsx",1)
dqdata$time_period_year <- substr(dqdata$time_period, 1, nchar(dqdata$time_period)-2)
dqdata$time_period_month <- substr(dqdata$time_period, 5, nchar(dqdata$time_period))
dqdata$time_period_date <- ymd(paste0(dqdata$time_period,"01"))

dqdatam <- melt(dqdata,id.vars=c("source_name","concept_id","concept_name","domain_id","time_period_year","measure_id","time_period","time_period_month"))
dqdatat <- dcast(dqdatam, source_name + concept_id + concept_name + time_period_year ~ time_period_month)

concepts <- as.data.frame(table(dqdata$concept_id))
sources <- as.data.frame(table(dqdata$source_name))

analyses <- unique(dqdata[c("concept_id","source_name")])


# loop through all databases, all concepts
for(i in 1:nrow(analyses))
{
  sourceFolder <-  paste("C:/Documents/OHDSI/DQCDM/",analyses[i,]$source_name,sep="")
  if (!file.exists(sourceFolder))
  {
    
    dir.create(sourceFolder)
  }
  
  resultsFolder <- paste("C:/Documents/OHDSI/DQCDM/",analyses[i,]$source_name,"/",analyses[i,]$concept_id,sep="")
  if (!file.exists(resultsFolder))
  {
    
    dir.create(resultsFolder)
  }
  
  i<-3
    dqdata1 <- subset(dqdata, source_name == analyses[i,]$source_name & concept_id==analyses[i,]$concept_id, select=c(prevalence,time_period_year,time_period_month,time_period, time_period_date))
      dqdata1 <- dqdata1[order(dqdata1$time_period),]
      
    first_year <- as.numeric(dqdata1[1,]$time_period_year)
    first_month <- as.numeric(dqdata1[1,]$time_period_month)
    last_year <- as.numeric(dqdata1[nrow(dqdata1),]$time_period_year)
    last_month <- as.numeric(dqdata1[nrow(dqdata1),]$time_period_month)
    
    #figure out how this handles nulls and maybe put the 0s in
    ts <- ts(dqdata1[,1], start=c(first_year, first_month), end=c(last_year, last_month), frequency=12)
    
    stl<- stl(ts,s.window="periodic")
    plot(stl)
    trend <- stl$time.series[,"trend"]
    seasonal <- stl$time.series[,"seasonal"]
    remainder <- stl$time.series[,"remainder"]
    
   
    #data quality checks
    #fit lr to trend data,  is abs(beta) large AND significant?
    
    lmfit <- tslm(ts ~ trend + season)
    lmfitsum <-summary(lmfit)
    analyses[i,]$temporalslope <- lmfit$coef[2]
    analyses[i,]$temporalslopesig <- lmfitsum$coef[2,4]
  

    n <- length(ts)
    plot(ts)
    lines(ts(lmfit$coef[1]+lmfit$coef[2]*(1:n)+mean(lmfit$coef[-(1:2)]),
             start=start(ts),f=12),col="red")

    
   
    
    
    #look for any outlier values in remainder...
  
    dqoutliers <- tso(ts)
    jpeg(file=paste(resultsFolder,"/dqoutliers.jpg",sep=""))
    plot(dqoutliers)
    dev.off()
    analyses[i,]$numoutliers <- nrow(dqoutliers$outliers)
  
  
    struc<-breakpoints(ts~1)
  
    analyses[i,]$numbreakpoints <- length(struc$breakpoints)
  
}

