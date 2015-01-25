# server.R

library(shiny)
library(ggplot2)
library(dplyr)

csvfile <- "./myData/calUsage.csv"
calUsage <- read.csv(csvfile, header=T, sep=",")
calUsage$Usage <- calUsage$Usage/1000 # make giga-watt-hour
csvfile <- "./myData/calPrecip.csv"
calPrecip <- read.csv(csvfile, header=T, sep=",")
csvfile <- "./myData/calPDSI.csv"
calPDSI <- read.csv(csvfile, header=T, sep=",")
csvfile <- "./myData/calMaxTemp.csv"
calMaxTemp <- read.csv(csvfile, header=T, sep=",")
csvfile <- "./myData/calHDD.csv"
calHDD <- read.csv(csvfile, header=T, sep=",")
csvfile <- "./myData/calCDD.csv"
calCDD <- read.csv(csvfile, header=T, sep=",")

shinyServer(function(input, output, session) {
    
    output$UsagePlot <- renderPlot({     
        
    
        selectSector <- switch(input$sector,
                               "All Sectors" = "All",
                               "Agricultural & WaterPumping" = "Agri_WaterPumping",
                               "Commercial-Building" = "Commercial.Building",
                               "Commercial-Other" = "Commercial.Other",
                               "Industry" = "Industry",
                               "Mining & Construction" = "Mining_Construction",
                               "Residential" = "Residential",
                               "Streetlight" = "Streetlight"
        )

        if (selectSector=="All"){
            ggplot(data=calUsage, aes(x=Year, y=Usage, fill=Sector)) + geom_bar(stat="identity") +  theme(legend.position="bottom") +
                labs(title=paste("California Annual Electric Usage")) + ylab("Usage in gWh") + scale_x_continuous(breaks=c(calPrecip$Year))
        } else {
            selectData <- calUsage %>% filter(Sector==selectSector) 
            plot <- ggplot(data=selectData, aes(x=Year, y=Usage)) + geom_bar(stat="identity",fill="orange3") +  theme(legend.position="bottom") +
                labs(title=paste("California Annual Electric Usage, ",input$sector, " Sector")) + ylab("Usage in gWh") + 
                scale_x_continuous(breaks=c(calPrecip$Year))
            if (input$avgline){
                plot <- plot + geom_hline(aes(yintercept=mean(Usage)))
            }
            if (input$trendline){
                plot <- plot + geom_smooth(method=lm,size=2)
            }
            print(plot)
        }
    })
    
    output$ClimatePlot <- renderPlot({     
        if (input$climate=="Precipitation" ){
            plot <- ggplot(data=calPrecip, aes(x=Year, y=Precipitation)) + geom_bar(stat="identity",fill="green4") +  theme(legend.position="bottom") +
                labs(title=paste("California Annual Statewide Precipitation")) + ylab("Precipitation in Inches") + 
                scale_x_continuous(breaks=c(calPrecip$Year))  
            if (input$avgline){
                plot <- plot + geom_hline(aes(yintercept=mean(Precipitation)))
            }
            if (input$trendline){
                plot <- plot + geom_smooth(method=lm,size=2)
            }
            print(plot)
        } else
            if (input$climate=="Cooling/Heating Degree Days"){
                plot <- ggplot(data=calCDD, aes(x=Year, y=CDD)) + geom_bar(stat="identity",fill="red") +  theme(legend.position="bottom") +
                    labs(title=paste("California Annual Statewide Cooling Degree Days")) + ylab("Degrees Fareinheit") + 
                    scale_x_continuous(breaks=c(calCDD$Year))
                if (input$avgline){
                    plot <- plot + geom_hline(aes(yintercept=mean(CDD)))
                }
                if (input$trendline){
                    plot <- plot + geom_smooth(method=lm,size=2)
                }
                print(plot)
            } else
                if (input$climate=="Max Temperature"){
                    plot <- ggplot(data=calMaxTemp, aes(x=Year, y=MaxTemp)) + geom_bar(stat="identity",fill="red") +  theme(legend.position="bottom") +
                        labs(title=paste("California Annual Statewide Max Temperatures")) + ylab("Fareinheit") + 
                        scale_x_continuous(breaks=c(calMaxTemp$Year))
                    if (input$avgline){
                        plot <- plot + geom_hline(aes(yintercept=mean(MaxTemp)))
                    }
                    if (input$trendline){
                        plot <- plot + geom_smooth(method=lm,size=2)
                    }
                    print(plot)
                    
                } else
                    if (input$climate=="Palmer Drought Severity Index"){
                        calPDSI$colour <- ifelse(calPDSI$PDSI < 0, "negative", "positive")
                        plot <- ggplot(data=calPDSI, aes(x=Year, y=PDSI)) + geom_bar(stat="identity",position="identity",aes(fill=colour)) + 
                            scale_fill_manual(values=c(positive="green4",negative="bisque4")) +
                            theme(legend.position="none") +
                            labs(title=paste("California Annual Statewide Palmer Drought Severity Index")) + ylab("PDSI") + 
                            scale_x_continuous(breaks=c(calPDSI$Year))
                        if (input$avgline){
                            plot <- plot + geom_hline(aes(yintercept=mean(PDSI)))
                        }
                        if (input$trendline){
                            plot <- plot + geom_smooth(method=lm,size=2)
                        }
                        print(plot)
                        
                    }
    })
    
    output$HDDPlot <- renderPlot({     
        if (input$climate=="Cooling/Heating Degree Days"){
            plot <- ggplot(data=calHDD, aes(x=Year, y=HDD)) + geom_bar(stat="identity",fill="blue") +  theme(legend.position="bottom") +
                labs(title=paste("California Annual Statewide Heating Degree Days")) + ylab("Degrees Fareinheit") +
                scale_x_continuous(breaks=c(calHDD$Year))
            if (input$avgline){
                plot <- plot + geom_hline(aes(yintercept=mean(HDD)))
            }
            if (input$trendline){
                plot <- plot + geom_smooth(method=lm,size=2,colour="red")
            }
            print(plot)
        } 
        
    })
    

    # Correlation Plot 
    selectSector <- reactive({
        switch(input$sector2,
               "Agricultural & WaterPumping" = "Agri_WaterPumping",
               "Commercial-Building" = "Commercial.Building",
               "Commercial-Other" = "Commercial.Other",
               "Industry" = "Industry",
               "Mining & Construction" = "Mining_Construction",
               "Residential" = "Residential",
               "Streetlight" = "Streetlight"
        )
    })

    selectClimate <- reactive({
        switch(input$climate2,
               "Precipitation" = "Precipitation", 
               "Palmer Drought Severity Index" = "PDSI",
               "Max Temperature" = "MaxTemp", 
               "Cooling Degree Days" = "CDD",
               "Heating Degree Days" = "HDD"
               )
    })
    
    
    output$CorrPlot <- renderPlot({
        
        selectSector <- selectSector()
        selectClimate <- selectClimate()
        selectData <- calUsage %>% filter(Sector==selectSector) 
        
          if (selectClimate=="Precipitation"){
            selectData <- left_join(selectData,calPrecip,by="Year")
            plot <- ggplot(data=selectData, aes(x=Precipitation, y=Usage)) + geom_point(colour="red",size=3) +  theme(legend.position="bottom") +
                labs(title=paste("Precipitation vs Usage, ",input$sector2, " sector")) + ylab("Usage (gWh)") + geom_smooth(method=lm,size=2)
            
        } else
            if(selectClimate=="PDSI"){
                selectData <- left_join(selectData,calPDSI,by="Year")
                plot <- ggplot(data=selectData, aes(x=PDSI, y=Usage)) + geom_point(colour="red",size=3) +  theme(legend.position="bottom") +
                    labs(title=paste("PDSI vs Usage",input$sector2, " sector")) + ylab("Usage (gWh)") + geom_smooth(method=lm,size=2)
            } else
                if(selectClimate=="MaxTemp"){
                    selectData <- left_join(selectData,calMaxTemp,by="Year")
                    plot <- ggplot(data=selectData, aes(x=MaxTemp, y=Usage)) + geom_point(colour="red",size=3) +  theme(legend.position="bottom") +
                        labs(title=paste("Max Temperature vs Usage",input$sector2, " sector")) + ylab("Usage (gWh)") + geom_smooth(method=lm,size=2)            
                } else
                    if(selectClimate=="CDD"){
                        selectData <- left_join(selectData,calCDD,by="Year")
                        plot <- ggplot(data=selectData, aes(x=CDD, y=Usage)) + geom_point(colour="red",size=3) +  theme(legend.position="bottom") +
                            labs(title=paste("Cooling Degree Days vs Usage",input$sector2, " sector")) + ylab("Usage (gWh)") + geom_smooth(method=lm,size=2)       
                    } else
                        if(selectClimate=="HDD"){
                            selectData <- left_join(selectData,calHDD,by="Year")
                            plot <- ggplot(data=selectData, aes(x=HDD, y=Usage)) + geom_point(colour="red",size=3) +  theme(legend.position="bottom") +
                                labs(title=paste("Heating Degree Days vs Usage",input$sector2, " sector")) + ylab("Usage (gWh)") + geom_smooth(method=lm,size=2)        
                        }        
        
        print(plot)
        
    })
    # End Correlation Plot

    output$corrPvalue <- renderPrint({
        selectSector <- selectSector()
        selectClimate <- selectClimate()
        selectData <- calUsage %>% filter(Sector==selectSector) 
        
        if (selectClimate=="Precipitation"){
            cor.test(calPrecip$Precipitation,selectData$Usage)
        } else
            if (selectClimate=="PDSI"){
                cor.test(calPDSI$PDSI,selectData$Usage)
            } else
                if (selectClimate=="MaxTemp"){
                    cor.test(calMaxTemp$MaxTemp,selectData$Usage)
                } else
                    if (selectClimate=="CDD"){
                        cor.test(calCDD$CDD,selectData$Usage)
                    } else
                        if (selectClimate=="HDD"){
                            cor.test(calHDD$HDD,selectData$Usage)
                        }         
    })
    
})