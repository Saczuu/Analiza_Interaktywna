#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(


    titlePanel("Generacja energi przez panel fotowoltaiczny"),
    
    fluidRow(
        column(12,
               p("Celem analizy jest zbadanie jak parametrty ze zbioru danych mają wpływ na produkcje energi elektrycznej przez panele fotowoltaiczne.
               Dodatkowo ważnym parametrem w naszej lokalizacji wydaje się pokrywa snieżna znajdująca się na panelu oraz inne ciała obce jak np. liscie jesienią.
               Niestety zbiór danych który uzywany jest do analizy posiada jedynie informacje o pozycji słońca tj. azymucie oraz elewacji, oraz procentową wartość zachmurzenia nieba."),
               p("Zbiór danych zawiera informacje o produkcji na przestrzeni ponad roku tj od 2020-02-01 do 2021-02-23, są to informacje wygenerowane przez własny panel fotowoltaiczny,
                 i posłużą one do stworzenia modelu sztucznej sieci neuronowej w oparciu o siec rekurencyjne LSTM, której zadaniem będzie predykcj szeregu czasowego na N dni w przód.
                 Predykcja szeregu czasowego z angielskiego forecast (w dalszej czesci analizy będzie używana angielska nazwa), odbywać się będzie zarówno za pomocą danych historycznych,
                 czyli odczytanych ze zbioru danych, jak i informacji o przyszłosci np. prognozie pogody dla następnych dni.")
               )
    ),
    
    fluidRow(
        column(3,
               dateInput("inDate", "Data do wyświetlenia", value = "2020-10-29")
        ),
        column(9,
               tableOutput("table"),style = "height:350px; overflow-y: scroll;overflow-x: scroll;")
    ),
    
    fluidRow(
        column(1, p(" ")),
        column(10, 
               plotOutput("timeSeriesPlot"))
    ),
    
    fluidRow(
        column(12,
               p("Dane nie wymagają czyszczenia gdyż nie posiadają żadnych braków oraz zduplikowanych wierszy.
               Jedyna atrybut który potrzebował czyszczenia to atrybut Cloud który posiadał 97 brakujących wartości i zostały one zastąpione zerami.
               Przyczyną tego najprawdopodobniej jest błąd API pogodowego.
               \nZestaw danych został przygotowany przez mnie na podstawie danych o produkcji zwracanych przez prosotwnik.
                Następnie na podstawie lokalizacji geograficznej oraz informacji o dacie i godzinie dane zostały zupełnione o informacje o pozycji
                słonca obliczonej przy pomocy programu PySolar, oraz o informacje odnośnie pogody pobranych z API pogowoego WeatherStack."))
    ),
    
    fluidRow(
        column(10, 
               h3("Statystyka podsumowywująca"))
    ),
    
    fluidRow(
        column(1, p(" ")),
        column(10, 
               verbatimTextOutput("summary"))
    ),
    
    fluidRow(
        column(10,
               h3("Historgram wartości atrybutów"))
    ),
    
    fluidRow(
        column(3,
               selectInput("histo_atrib", h3("Atrybut"), 
                           choices = c("Produkcja","Zachmurzenie", "Opady", "UV Index", "Temperatura", "Wilgotność"), selected = 1)),
        column(9, plotOutput("histogram"))
    ),
    
    fluidRow(
        column(10,
               h3("Atrybuty"),p("Przedstawienie poszczególnych atrybutów"))
    ),
    
    fluidRow(
        column(3,
               h5("Cloud")),
        column(9,p(
            "Procentowa wartość opisująca zachmurzenie nieba"
            ),
            plotOutput("cloudAggregatedHistogram")
        )
    ),
    
    fluidRow(
        column(3,
               h5("UV_Index")),
        column(9,
               p("Index promeniowania UV w 10 stopniowej skali"),
               plotOutput("uvDonutPlot")
        )
        
    ),
    
   fluidRow(
        column(3,
               h5("Precip")),
        column(9,
               p("Opady atmosferyczne w mm/m^3"),
               plotOutput("precipBoxPlot")
        )
        
    ),
   
   fluidRow(
       column(3,
              h5("Temperature")),
       column(9,
              p("Temperatura powietrza w stopniach Celcjusza"),
              plotOutput("temperatureScaterdedPlot")
       )
       
   ),
   
   fluidRow(
       column(3,
              h5("Humidity")),
       column(9,
              p("Ciśnienie atmosferyczne"),
              plotOutput("humidityRidgelinePlot")
       )
       
   ),
    
    fluidRow(
        column(10,
               h3("Prototyp modelu"),
               p("Protoptyp modelu sieci neuronowej którego zadaniem jest predykcja produkcji energi na następne n zadanych godzin.
                 Model został stworzony w środowisku programistycznym TensorFlow Keras, a zastosowana technika sieci neuonowych to rekurencyjne sieci neuronowe LSTM."))
    ),
    
    fluidRow(
        column(1, p(" ")),
        column(10, 
               verbatimTextOutput("modelSummary"))
    ),
    
    fluidRow(
        column(10,
               p("Model składa się z 2 warstw: warstwy rekurencyjnej LSTM o 100 neuronach oraz warswy gęstej (pełnego połączenia) z 1 neuronem, której zadaniem jest sproawadzenie wyniku do pojedyńczej liczby."))
    ),
    
    fluidRow(
        column(10,
               h3("Uczenie modelu"),
               p("Model został nauczony na zbiorze testowym który zawierał 95% danych poczatkowych ze zbioru.
               Atrybuty na których został wyszkolony to pozycja słońca oraz zachmurzenie nieba.
                 Model był uczony na przestrzeni 50 epok.
                 Z uwagi an zastosowanie warstwy LSTM każdy element wsadowy modelu musi odwoływac się do częsci danych historycznych.
                 Zdecydowałem aby model odwoływał się do ostatnich 12 godzin."))
    ),
   
   fluidRow(
       column(2, p(" ")),
       column(7, 
              plotOutput("modelHistoryPlot"))
   ),
   
   fluidRow(
       column(10,
              h3("Predykcja"),
              p("Przykładowa predykcja dokonana na całości zbioru testowego zestawiona z prawdziwymi wartosciami.
                Predykcja została dokonana na danych od 17 stycznia do 23 lutego. Na wykresie można określić zakres dni
                z jakiego mają zostać pokazane dane oraz dodać do wykresu dodatkowe atrybuty które zostały wykorzystane w procesie uczenia
                w celu lepszego zobrazowania zależności pomiędzy nimi."))
   ),
   
   fluidRow(
       column(2,
              dateInput("startDate", "Data początkowa", value = "2021-01-17"),
              dateInput("endDate", "Data końcowa", value = "2021-01-20"),
              checkboxGroupInput("chartGroup", label = h5("Produkcja"), 
                                 choices = list("Rzezywiste" = 1, "Przewidziane" = 2),
                                 selected = c(1,2)),
              checkboxGroupInput("atributGroup", label = h5("Dodatkowy atrybut"), 
                                 choices = list("Zachmurzenie" = 1,
                                                "Pozycja słońca" = 2,
                                                "Index UV" = 3),
                                 selected = c(1)),
              h5("Dodatkowe informacje"),
              checkboxInput("textCheckBox", label = "Pokaż wartości zachmurzenia", value = FALSE),
              checkboxInput("uvcheckBox", label = "Pokaż wartości indeksu UV", value = FALSE),
              ),
                
       column(8, 
              plotOutput("modelPredictPlot"))
              
   )
))
