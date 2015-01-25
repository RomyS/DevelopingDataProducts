# ui.R
library(shiny)
shinyUI(fluidPage(
    titlePanel("Exploring California Electric Usage and Climate"),
  
    tabsetPanel(

             # Explore Tab
             tabPanel("Explore",
                      
                      sidebarLayout(
                        sidebarPanel(
                          
                          selectInput("sector", 
                                      label = "Choose a Sector to display:",
                                      choices = c("All Sectors", "Agricultural & WaterPumping", "Commercial-Building", "Commercial-Other","Industry",
                                                  "Mining & Construction", "Residential", "Streetlight"),
                                      selected = "Agricultural & WaterPumping"),
                          selectInput("climate", 
                                      label = "Choose a Climate Parameter to display:",
                                      choices = c("Precipitation", "Palmer Drought Severity Index","Max Temperature", "Cooling/Heating Degree Days"),
                                      selected = "Precipitation"),      
                          checkboxInput("avgline", "Add average line", FALSE),
                          checkboxInput("trendline", "Add trend line", FALSE)
#                           submitButton(text = "Plot")

                        ),


                        mainPanel(
                          
                          plotOutput("UsagePlot"),
                          plotOutput("ClimatePlot"),
                          plotOutput("HDDPlot")
                          
                        )
                      )
               ),
             
             # Analyse Tab  
             tabPanel("Analyze",
                      
                      sidebarLayout(
                        sidebarPanel(
                          
                          selectInput("sector2", 
                                      label = "Choose a Sector:",
                                      choices = c("Agricultural & WaterPumping", "Commercial-Building", "Commercial-Other","Industry",
                                                  "Mining & Construction", "Residential", "Streetlight"),
                                      selected = "Agricultural & WaterPumping"),
                          selectInput("climate2", 
                                      label = "Choose a Climate Parameter:",
                                      choices = c("Precipitation", "Palmer Drought Severity Index","Max Temperature", "Cooling Degree Days", "Heating Degree Days"),
                                      selected = "Precipitation")
                          
                       ),
                        
                        mainPanel(
                          
                          plotOutput("CorrPlot"),
                          
                          h4("Correlation Test: cor.test(x,y)"),
                          verbatimTextOutput("corrPvalue"),
                          
                          p("The correlation coefficient, cor, is a number between –1 and 1 that determines whether two paired sets of data are related.", 
                            "The closer to 1 the more ‘confident’ we are of a positive linear correlation and the closer to –1 the more confident ", 
                            "we are of a negative linear correlation."
                            ),
                          p("The p-value is the probability that you would have found the current result if the correlation coefficient were in fact zero", 
                            "(null hypothesis). If this probability is lower than the conventional 5% (P<0.05) the correlation coefficient is called statistically significant."
                            )
                        )
                      )
           ),
             
             # End of Analyse Tab

            tabPanel("About",
                    sidebarLayout(
                        sidebarPanel(
                            h4("the Author"),
                            helpText("Romy Susvilla")
                        ),
                        mainPanel(
                            wellPanel(
                            h4("the Project"),
                            p("This shiny application is a project for the Developing Data Products class in Coursera.",
                              "The objective is to create a simple shiny application using some widgets, performing some",
                              "calculations using R, and having just enough documentation for a user to get started."
                              )
                            ),
                            
                            wellPanel(
                            h4("the Application"),
                            p("This application gives the user a tool to explore how the California climate affects the",
                              "electric energy use by sectors. I got the idea from a colleague of mine at work who asked if the", 
                              "volatility in California's Agricultural sector electric usage is highly correlated with", 
                              "California's precipitation history."
                              ),
                            br(),
                            p("The initial Explore tab shows a bar graph of Agricultural & WaterPumping sector's electric",
                              "usage from 1990 to 2013 in California.  Also shown is the California annual precipitation",
                              "for the same period.  You can change both the sector and the climate parameter, as well as",
                              "add an average line and/or a trend line."
                              ),
                            br(),
                            p("The Analyze gives the user the ability to plot a sector annual electric usage versus a climate",
                              "parameter.  A trend line is automatically shown.  Right below the plot is shown",
                              "the results of a correlation test between a climate variable (x) and usage (y)."
                              ),
                            br(),
                            p("This application does not aim to draw any conclusions from the data analysis being shown.",
                              "The limited timeframe for this project is not enough to go into a more detailed study of the",
                              "relationship between electric energy use and climate."
                                )
                            ),
                            
                            wellPanel(
                            h4("the Data"),
                            p("The Califonia electric usage data came from the California Energy Commission", a("website",
                              href="http://ecdms.energy.ca.gov/elecbyutil.aspx"), ".  Only the data for the 3 major utilities",
                              "(Pacific Gas & Electric, Southern California Edison, San Diego Gas & Electric) were used."
                            ),
                            br(),
                            p("The California climate data came from the NOAA (National Oceanic and Atmospheric Administration)",
                              "National Climatic Data Center", a("website", href="http://www.ncdc.noaa.gov/cag/"), "."
                              )
                            )
                        ) 
                    ) # sidebarLayout       
            ) # End of About tabPanel

    )       # End of tabsetPanel
))