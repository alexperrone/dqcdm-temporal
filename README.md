Anomaly Detective 
==========================

This repository has collected different work from the Temporal Group from the DQ-CDM Code-a-thon Nov 6-8, 2015. 

The Anomaly Detective provides an interactive app to explore temporal anomalies on top of DQ-CDM data. 

## Installation


To run the Shiny app, you will need to install R, then from within R you can install the required R packages as 
follows: 

```r
install.packages(c("shiny", "ggplot2", "data.table", "lubridate", "magrittr", 
                 "gridExtra", "ggfortify", "forecast", "changepoint", "strucchange"), 
                 dependencies=TRUE)
```

Then you can run the app from within Rstudio by clicking Run App after opening either 
`ui.R` or `server.R`. 

## The app

For a selected condition (concept_id) and data source, the Shiny app presents results of different analyses in 4 tabs:

The first tab on the app overviews the data and calculates a "typical" annual pattern. It highlights data points that statistically deviate from the "typical" pattern, defined as falling outside the error bounds given by the user-selected multiple of the standard error (SE) estimate. 

![tab 1](https://github.com/alexperrone/dqcdm-temporal/blob/master/img/screenshot-11.png)

We compute a "typical" year by averaging over each month over all of the data. The bounds are a multiple of the SE, which the user can select. For the condition below, we see a seasonality effect, with higher prevalence in the winter months. 

![tab 1](https://github.com/alexperrone/dqcdm-temporal/blob/master/img/screenshot-10.png)

The second tab returns a table of high prevalence of the selected condition.

![tab 2](https://github.com/alexperrone/dqcdm-temporal/blob/master/img/screenshot-04.png)

The third tab produces plots from a set of time series analyses. 

Picture goes below...
![tab 3](https://github.com/alexperrone/dqcdm-temporal/blob/master/img/screenshot-07.png)

The fourth tab plots prevelance overtime of the selected concept_id by database (for every database available).  

![tab 4](https://github.com/alexperrone/dqcdm-temporal/blob/master/img/screenshot-09.png)
