#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(markdown)

#' Convert temperature from Celsius degrees to Kelvins
#'
#' @param t temperature in Celsius degrees
#' @return temperature in Kelvins
#'
celsius_to_kelvin <- function(t)
{
  t + 273.15
}

#' Convert pressure from pascals to hectopascals
#'
#' @param p pressure in pascals
#' @return pressure in hectopascals
#'
pascal_to_hectopascal <- function(p)
{
  p / 100
}

#' Convert pressure from hectopascals to pascals
#'
#' @param p pressure in hectopascals
#' @return pressure in pascals
#'
hectopascal_to_pascal <- function(p)
{
  p * 100
}

#' Convert fraction into percentages
#'
#' @param a fraction value (0..1)
#' @return percentages
#'
to_percent <- function(a)
{
  a * 100
}

#' Calculate atmospheric pressure
#'
#' @param t_c temperature (°C)
#' @param h altitude under sea level (m)
#' @return pressure (Pa)
#'
calc_air_pressure <- function(t_c, h)
{
  p0 <- 101325 # sea level standard atmospheric pressure (Pa)
  g <- 9.80665 # Earth-surface gravitational acceleration (m/s^2)
  M <- 0.0289644 # molar mass of dry air (kg/mol)
  R <- 8.31447 # universal gas constant (J/(mol*K))
  t_k <- celsius_to_kelvin(t_c) # temperature (K)
  p0 * exp(- M * g * h / (R * t_k))
}

#' Calculate equilibrium vapor pressure
#'
#' @param t_c temperature (°C)
#' @param p_hpa atmospheric presuare (hecto-Pa)
#' @return pressure (hecto-Pa)
#'
calc_max_vapor_pressure <- function(t_c, p_hpa = 1013.25)
{
  (1.0016 + 3.15*10^(-6)*p_hpa - 0.074*p_hpa^(-1)) * (6.112 * exp(17.62 * t_c / (243.12 + t_c)))
}

#' Calculate vapor pressure
#'
#' @param t_dry_c dry-bulb temperature (°C)
#' @param t_wet_c wet-bulb temperature (°C)
#' @param p_hpa atmospheric presuare (hecto-Pa)
#' @return pressure (hecto-Pa)
#'
calc_vapor_pressure <- function(t_dry_c, t_wet_c, p_hpa = 1013.25)
{
  calc_max_vapor_pressure(t_wet_c, p_hpa) - 0.0007947 * (t_dry_c - t_wet_c) * p_hpa
}

#' Calculate relative humidity
#'
#' @param t_dry_c dry-bulb temperature (°C)
#' @param t_wet_c wet-bulb temperature (°C)
#' @param p_hpa atmospheric presuare (hecto-Pa)
#' @return relative humidity (0..1)
#'
calc_relative_humidity <- function(t_dry_c, t_wet_c, p_hpa = 1013.25)
{
  rh <- calc_vapor_pressure(t_dry_c, t_wet_c, p_hpa) / calc_max_vapor_pressure(t_dry_c, p_hpa)
  rh <- ifelse(rh > 1, 1, rh)
  rh <- ifelse(rh < 0, 0, rh)
  rh
}

#' Calculate dew point temperature
#'
#' @param t temperature (°C)
#' @param rh relative himidity (0..1)
#' @return dew point (°C)
#'
calc_dew_point <- function(t, rh)
{
  a <- 17.27
  b <- 237.7
  g <- a * t / (b + t) + log(rh)
  b * g / (a - g)
}

#' Calculate absolute humidity
#'
#' @param t_c temperature (°C)
#' @param rh relative himidity (0..1)
#' @param p_hpa atmospheric presuare (hecto-Pa)
#' @return absolute humidity (kg/m^3)
#'
calc_absolute_humidity <- function(t_c, rh, p_hpa = 1013.25)
{
  Rv <- 461.5 # water gas constant (J/(kg*K)).
  t_k <- celsius_to_kelvin(t_c) # temperature (K)
  vapor_pressure <- hectopascal_to_pascal( rh * calc_max_vapor_pressure(t_c, p_hpa) )
  vapor_pressure / Rv / t_k # kg/m^3
}

# Define server logic required to calculate some humidity indicators
shinyServer(function(input, output)
{
  # Show the summary values using an HTML table
  output$summarytable <- renderTable({
    
    p_hpa <- pascal_to_hectopascal(calc_air_pressure(input$drytemp, input$altitude))
    rh <- calc_relative_humidity(
      input$drytemp,
      input$wettemp,
      p_hpa)
    ah <- calc_absolute_humidity(input$drytemp, p_hpa)
    dp <- calc_dew_point(input$drytemp, rh)
    
    # Compose data frame
    data.frame(
      Name = c(
        "Dry-bulb temperature (°C)",
        "Wet-bulb temperature (°C)",
        "Altitude under sea level (m)",
        "Relative humidity (%)",
        "Absolute humidity (kg/m^3)",
        "Dew point temperature (°C)"),
      Value = as.character(c(
        input$drytemp,
        input$wettemp,
        input$altitude,
        round(to_percent(rh), 2),
        round(ah, 4),
        round(dp, 2))), 
      stringsAsFactors=FALSE)
  })
  
  # Plot for dependence of the relative humidity on the dry-bulb temperature
  output$rh_dbt_plot <- renderPlot({
    
    p_hpa <- pascal_to_hectopascal(calc_air_pressure(input$drytemp, input$altitude))
    rh <- to_percent(calc_relative_humidity(
      input$drytemp,
      input$wettemp,
      p_hpa))
    
    drytemp1 <- seq(-10,50, length=200)
    rh1 <- to_percent(calc_relative_humidity(
      drytemp1,
      input$wettemp,
      p_hpa))
    ggplot(data.frame(drytemp1 = drytemp1, rh1 = rh1), aes(x = drytemp1, y = rh1)) +
      geom_line(colour="blue", size=1) +
      geom_point(data=data.frame(drytemp1 = input$drytemp, rh1 = rh), aes(x = drytemp1, y = rh1), colour="red", size=5) +
      labs(
        x = "Dry-bulb temperature (°C)",
        y = "Relative humidity (%)",
        title = "Dependence of the relative humidity on the dry-bulb temperature")
  })

  # Plot for dependence of the relative humidity on the wet-bulb temperature
  output$rh_wbt_plot <- renderPlot({
    
    p_hpa <- pascal_to_hectopascal(calc_air_pressure(input$drytemp, input$altitude))
    rh <- to_percent(calc_relative_humidity(
      input$drytemp,
      input$wettemp,
      p_hpa))
    
    wettemp1 <- seq(-10,50, length=200)
    rh1 <- to_percent(calc_relative_humidity(
      input$drytemp,
      wettemp1,
      p_hpa))
    ggplot(data.frame(wettemp1 = wettemp1, rh1 = rh1), aes(x = wettemp1, y = rh1)) +
      geom_line(colour="blue", size=1) +
      geom_point(data=data.frame(wettemp1 = input$wettemp, rh1 = rh), aes(x = wettemp1, y = rh1), colour="red", size=5) +
      labs(
        x = "Wet-bulb temperature (°C)",
        y = "Relative humidity (%)",
        title = "Dependence of the relative humidity on the wet-bulb temperature")
  })    
  
  # Plot for dependence of the dew point temperature on the dry-bulb temperature
  output$dp_dbt_plot <- renderPlot({
    
    p_hpa <- pascal_to_hectopascal(calc_air_pressure(input$drytemp, input$altitude))
    rh <- calc_relative_humidity(
      input$drytemp,
      input$wettemp,
      p_hpa)
    dp <- calc_dew_point(input$drytemp, rh)
    
    drytemp1 <- seq(-10,50, length=200)
    rh1 <- calc_relative_humidity(
      drytemp1,
      input$wettemp,
      p_hpa)
    dp1 <- calc_dew_point(
      drytemp1,
      rh1)
    ggplot(data.frame(drytemp1 = drytemp1, dp1 = dp1), aes(x = drytemp1, y = dp1)) +
      geom_line(colour="blue", size=1) +
      geom_point(data=data.frame(drytemp1 = input$drytemp, dp1 = dp), aes(x = drytemp1, y = dp1), colour="red", size=5) +
      labs(
        x = "Dry-bulb temperature (°C)",
        y = "Dew point temperature (°C)",
        title = "Dependence of the dew point temperature on the dry-bulb temperature")
  })  
  
  # Plot for dependence of the dew point temperature on the wet-bulb temperature
  output$dp_wbt_plot <- renderPlot({
    
    p_hpa <- pascal_to_hectopascal(calc_air_pressure(input$drytemp, input$altitude))
    rh <- calc_relative_humidity(
      input$drytemp,
      input$wettemp,
      p_hpa)
    dp <- calc_dew_point(input$drytemp, rh)
    
    wettemp1 <- seq(-10,50, length=200)
    rh1 <- calc_relative_humidity(
      input$drytemp,
      wettemp1,
      p_hpa)
    dp1 <- calc_dew_point(
      input$drytemp,
      rh1)    
    ggplot(data.frame(wettemp1 = wettemp1, dp1 = dp1), aes(x = wettemp1, y = dp1)) +
      geom_line(colour="blue", size=1) +
      geom_point(data=data.frame(wettemp1 = input$wettemp, dp1 = dp), aes(x = wettemp1, y = dp1), colour="red", size=5) +
      labs(
        x = "Wet-bulb temperature (°C)",
        y = "Dew point temperature (°C)",
        title = "Dependence of the dew point temperature on the wet-bulb temperature")
  })    
})