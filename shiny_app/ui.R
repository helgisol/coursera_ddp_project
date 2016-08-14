#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that calculates some humidity indicators
shinyUI(navbarPage(
  "Calculator of some humidity indicators",
  tabPanel("Execute",
           fluidPage(
             # Input data
             fluidRow(
               column(
                 width = 4,
                 sliderInput(
                   "drytemp",
                   "Dry-bulb temperature (°C):",
                   min = -10,
                   max = 50,
                   value = 20
                 )
               ),
               column(
                 width = 4,
                 sliderInput(
                   "wettemp",
                   "Wet-bulb temperature (°C):",
                   min = -10,
                   max = 50,
                   value = 15
                 )
               ),
               column(
                 width = 4,
                 sliderInput(
                   "altitude",
                   "Altitude under sea level (m):",
                   min = 0,
                   max = 10000,
                   value = 10
                 )
               )
             ),
             
             # Show a table or plots for some humidity indicators
             mainPanel(
               width = 12,
               tabsetPanel(
                 type = "tabs",
                 tabPanel("Summary table", tableOutput("summarytable")),
                 tabPanel("RH(DBT) plot", plotOutput("rh_dbt_plot")),
                 tabPanel("RH(WBT) plot", plotOutput("rh_wbt_plot")),
                 tabPanel("DP(DBT) plot", plotOutput("dp_dbt_plot")),
                 tabPanel("DP(WBT) plot", plotOutput("dp_wbt_plot"))
               )
             )
           )),
  # Help page for application
  tabPanel(
    "Help",
    mainPanel(width = 12, includeMarkdown("include.md"))
  )
))