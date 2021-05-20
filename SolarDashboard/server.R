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
library(lubridate)
library(tidyverse)
library(stringr)
library(hrbrthemes)
library(dplyr)
library(xts)
library(gganimate)
library(zoo)
library(keras)
library(ggridges)
library(RColorBrewer)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$timeSeriesPlot <- renderPlot({
        
        dane <- mydata()
        
        temp <- dane$Hour * 100
        temp2 <- mapply(function(x, y) paste0(rep(x, y), collapse = ""), 0, 4 - nchar(temp))
        temp <- paste0(temp2, temp)
        dane$Hour <- format(strptime(temp, format="%H%M"), format = "%H:%M")
        dane$Timestamp <- paste(dane$Data, dane$Hour)
        dane$Timestamp <- as.POSIXct(dane$Timestamp, format="%Y-%m-%d %H:%M") 
        
        ### filtrowanie która data ma zostać wyświetlona
        dane <- dane[(dane$Data  == input$inDate),]
        
        
        ggplot(data=dane,aes(x=Timestamp, y=Energy)) + 
            geom_path(colour="#2c7fb8") + 
            ylab("Produkcja") +
            xlab("Data")+
            theme_ipsum()+
            scale_fill_brewer(palette="YlGnBu")
    })
    
    mydata <- reactive({
        ### Wczytanie danychz pliku csv
        tbl <- read.csv("Dane.csv", sep = ",")
        ### Wybranie kolumn
        tbl <- tbl[, c(3,4,5,6,7,8,9,10,11,12)]
        
        tbl$Datestamp <- as.Date(with(tbl, paste(tbl$Data, tbl$Hour)), "%Y-%m-%d %H")
        
        tbl$Data <- as.Date(tbl$Data)
        
        tbl[is.na(tbl)] <- 0
        
        
        return(tbl)
    })
    
    model <- reactive({
        mdl <- load_model_tf("model")
        return(mdl)
    })
    
    history <- reactive({
        historia <- read.csv("Training_history.csv", sep=',')
        
        return(historia)
    })
    
    predict <- reactive({
        predykcja <- read.csv("forecast_plot.csv", sep=',')
        predykcja <- tail(predykcja, -10)
        
        return(predykcja)
    })
    
    output$table <- renderTable({
        dane <- mydata()
        
        ### filtrowanie która data ma zostać wyświetlona
        dane <- dane[(dane$Data  == input$inDate),]
        
        ### Formatowanie wyspisywanych dat
        dane["Data"] <- format(dane["Datestamp"],
                               "%Y-%m-%d %H:%M")
        
        
        head(select(dane, "Data", "Solar_position","Solar_height", "Energy", "Cloud", "Temperature", "Humidity", "Precip", "UV_Index"), 24)
        
    })
    
    output$summary <- renderPrint({
        dane <- mydata()
        summary(select(dane, "Solar_position","Solar_height", "Energy", "Cloud", "Temperature", "Humidity", "Precip", "UV_Index"))
    })
    
    histogram <- reactive({
        dane <- mydata()
        
        if (input$histo_atrib == "Produkcja") {
            plot <- ggplot(dane, aes(x=Energy))
        }
        if (input$histo_atrib == "Zachmurzenie") {
            plot <- ggplot(dane, aes(x=Cloud)) 
        }
        if (input$histo_atrib == "Opady") {
            plot <- ggplot(dane, aes(x=Precip)) 
        }
        if (input$histo_atrib == "UV Index") {
            plot <- ggplot(dane, aes(x=UV_Index)) 
        }
        if (input$histo_atrib == "Temperatura") {
            plot <- ggplot(dane, aes(x=Temperature)) 
        }
        if (input$histo_atrib == "Wilgotność") {
            plot <- ggplot(dane, aes(x=Humidity))
        }
        
        plot +
            geom_histogram(fill="#41b6c4", alpha=0.9, bins=input$histogramBins,) +
            theme_ipsum() +
            scale_color_brewer(palette="Dark2")+
            scale_fill_brewer(palette="Dark2")
    })
    
    output$histogram <- renderPlot({
        p <- histogram()
        p
    })
    
    output$cloudAggregatedHistogram <- renderPlot({
        dane <- mydata()
        dane <- select(dane, "Datestamp","Cloud")
        aggregated <- dane %>% group_by(Date=floor_date(Datestamp, "week")) %>%
            summarize(Cloud=mean(Cloud)) 
        
        aggregated %>% ggplot( aes(x=Date, y=Cloud)) +
            geom_line( color="grey") +
            geom_point(shape=21, color="black", fill="#7fcdbb", size=3) +
            theme_ipsum() +
            ggtitle("Średnie tygodniowe zachmurzenie")
        
    })
    
    output$temperatureScaterdedPlot <- renderPlot({
        dane <- mydata()
        dane <- select(dane, "Datestamp","Temperature")
        
        aggregated <- dane %>% group_by(Date=floor_date(Datestamp, "week")) %>%
            summarize(Temp_max=max(Temperature), Temp_min=min(Temperature)) 
        
        aggregated %>% ggplot() +
            geom_line( aes(x=Date, y=Temp_max), color="grey") + 
            geom_point(aes(x=Date, y=Temp_max), shape=21, color="black", fill="#FF5F4C", size=3) +
            geom_line( aes(x=Date, y=Temp_min), color="grey") +
            geom_point(aes(x=Date, y=Temp_min), shape=21, color="black", fill="#54A3FF", size=3) +
            theme_ipsum() +
            ggtitle("Największa i najmniejsza temperatura w agregacji tygodniowej")
        
        # geom_point(shape=21, color="black", fill="#FF5F4C", size=3) +
        #    geom_point(shape=21, color="black", fill="#54A3FF", size=3)
    })
    
    output$humidityRidgelinePlot <- renderPlot({
        dane <- mydata()
        dane <- select(dane, "Datestamp","Humidity")
        
        aggregated <- dane %>% group_by(Date=floor_date(Datestamp, "month")) %>%
            summarize(Humidity_mean=mean(Humidity)) 
        
        aggregated %>% ggplot(aes(x= Humidity_mean)) +
            geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8) +
            theme_ipsum() 
    })
    
    output$uvDonutPlot <- renderPlot({
        
        
        # Create test data.
        dane <- mydata()
        dane <- select(dane,"UV_Index")
        
        df <- as.data.frame(table(dane))
        
        df$Index = df$dane
        
        # Compute percentages
        df$fraction = df$Freq / sum( df$Freq)
        df$fraction <-  round(df$fraction,3)
        
        # Compute the cumulative percentages (top of each rectangle)
        df$ymax = cumsum(df$fraction)
        
        # Compute the bottom of each rectangle
        df$ymin = c(0, head(df$ymax, n=-1))
        
        # Make the plot
        ggplot(df, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=Index)) +
            geom_rect() +
            geom_label(
                aes(label = paste(fraction * 100, "%"),
                    x = 3.5,
                    y = (ymin + ymax) / 2),
                inherit.aes = TRUE,
                show.legend = FALSE
            )+
            scale_fill_brewer(palette="YlGnBu") +
            coord_polar(theta="y") +
            xlim(c(2, 4)) +
            theme_void()
    })
    
    output$precipBoxPlot <- renderPlot({
        dane <- mydata()
        
        dane_grupowane <- group_by(dane, month=floor_date(dane$Data, "month"))
        
        dane_grupowane <- select(dane_grupowane, "Precip")
        
        dane_grupowane$Month <- format(dane_grupowane$month,"%b")
        
        ggplot(dane_grupowane, aes(x=as.factor(Month), y=Precip, fill=as.factor(Month))) + 
            geom_boxplot(alpha=0.8) + 
            xlab("Miesiąc")+
            ylab("Opady atmosferyczne")+
            theme_ipsum() +
            ggtitle("Opady atmosferyczne zgrupowane miesięcznie")+
            scale_y_continuous(expand = c(0,3))+
            scale_fill_brewer(palette="YlGnBu")+
            theme(legend.position="none")
    })
    
    output$modelSummary <- renderPrint({
        model <- model()
        
        summary(model)
    })
    
    output$modelHistoryPlot <- renderPlot({
        dane <- history()
        
        dane %>% ggplot( aes(x=Epoki, y=Funkcja)) +
            geom_line( color="orange", size=1.5) +
            theme_ipsum() +
            ggtitle("Wykres funkcji straty na przestrzeniu procesu uczenia modelu")
        
    })
    
    output$modelPredictPlot <- renderPlot({
        dane <- predict()
        
        dane <- dane[dane$Date >= input$startDate & dane$Date <= input$endDate,]
        
        dane$Timestamp <- as.POSIXct(dane$Date, format="%Y-%m-%d_%H")
        
        p <- dane %>% ggplot() +
            theme_ipsum()
        
        ### Argumenty dodatkowe
        atrybuty <- mydata()
        atrybuty <- atrybuty[atrybuty$Data >= input$startDate & atrybuty$Data <= input$endDate,]
        if (1 %in% input$atributGroup) {
            dane$Cloud = atrybuty$Cloud 
            p <- p +
                geom_bar(aes(x=Timestamp, y=(dane$Cloud*max(dane$True_production)/100)),
                         stat="identity", fill="gray",
                         alpha = 3/10)
            if (input$textCheckBox == TRUE) {
                p <- p +
                    geom_text(aes(label=dane$Cloud, x=Timestamp, y=(dane$Cloud*max(dane$True_production)/100)*1.02), colour="black")
            }
        }
        if (2 %in% input$atributGroup) {
            dane$Solar = atrybuty$Solar_height 
            p <- p +
                geom_line(aes(x=Timestamp, y=(dane$Solar*max(dane$True_production)/100)+max(dane$True_production)*0.60), color="orange")
        }
        if (3 %in% input$atributGroup) {
            dane$UV = atrybuty$UV_Index
            
            p <- p +
                geom_line(aes(label=dane$UV, x=Timestamp, y=(dane$UV*max(dane$True_production)/10)), colour="brown")
            
            if (input$uvcheckBox == TRUE) {
                p <- p +
                    geom_text(aes(label=dane$UV, x=Timestamp, y=(dane$UV*max(dane$True_production)/10)+50), colour="brown")
            }
        }
        
        ### Wykresy
        if (2 %in% input$chartGroup) {
            p <- p + geom_line(aes(x=Timestamp, y=Forecast), color="red")
        }
        if (1 %in% input$chartGroup) {
            p <- p + geom_line(aes(x=Timestamp, y=True_production), color="blue")
        }
        
        p
    })
})
