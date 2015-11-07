# Detects the functional form of a univariate time series for detecting temporal anomalies.
# (Not yet, really, but should be a reasonable placeholder)

# source("C:/Users/pardre1/Documents/vdw/dq/r/detect_form.R")

# Function that returns Root Mean Squared Error
rmse <- function(error)
{
  sqrt(mean(error^2))
}

# Function that returns Mean Absolute Error
mae <- function(error)
{
  mean(abs(error))
}

fit_models <- function(dat) {
  # fit a series of simple lms for each concept_name, return the RMSE for each one, and pick a winner.
  concepts <- as.data.frame(table(dat$concept_name))
  concepts$rmse_linear <- NA
  concepts$rmse_quadratic <- NA
  concepts$rmse_cubic <- NA
  concepts$winner <- '?'

  names(concepts) <- c('concept', 'freq', 'rmse_linear', 'rmse_quadratic', 'rmse_cubic', 'winner')
  for (con in concepts[, 1]) {
    lin  <- lm(prevalence ~ time_period, dat[dat$concept_name == con,])
    quad <- lm(prevalence ~ time_period + I(as.integer(time_period)^2), dat[dat$concept_name == con,])
    cub  <- lm(prevalence ~ time_period + I(as.integer(time_period)^3), dat[dat$concept_name == con,])

    concepts[concepts$concept == con,]$rmse_linear    <- rmse(lin$residuals)
    concepts[concepts$concept == con,]$rmse_quadratic <- rmse(quad$residuals)
    concepts[concepts$concept == con,]$rmse_cubic     <- rmse(cub$residuals)

    # there has got to be a better way...
    best <- min(concepts[concepts$concept == con, c('rmse_linear', 'rmse_quadratic', 'rmse_cubic')])

    if (best == concepts[concepts$concept == con, c('rmse_linear'   )]) {concepts[concepts$concept == con, ]$winner <- 'linear'}
    if (best == concepts[concepts$concept == con, c('rmse_quadratic')]) {concepts[concepts$concept == con, ]$winner <- 'quadratic'}
    if (best == concepts[concepts$concept == con, c('rmse_cubic'    )]) {concepts[concepts$concept == con, ]$winner <- 'cubic'}

  }
  return(concepts)
}

