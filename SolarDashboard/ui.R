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
    
    fluidRow(style = "text-align: justify;",
        column(12,
               p("Celem analizy jest zbadanie jak parametrty ze zbioru danych mają wpływ na produkcje energi
               elektrycznej przez panele fotowoltaiczne.
               Dodatkowo ważnym parametrem w naszej lokalizacji wydaje się pokrywa snieżna 
               znajdująca się na panelu oraz inne ciała obce jak np. liscie jesienią.
               Niestety zbiór danych który uzywany jest do analizy posiada jedynie 
                 informacje o pozycji słońca tj. azymucie oraz elewacji, oraz procentową wartość zachmurzenia nieba."),
               p("Zbiór danych zawiera informacje o produkcji na przestrzeni ponad
               roku tj od 2020-02-01 do 2021-02-23, są to informacje wygenerowane przez własny panel fotowoltaiczny,
                 i posłużą one do stworzenia modelu sztucznej sieci neuronowej w 
                 oparciu o siec rekurencyjne LSTM, której zadaniem będzie predykcj szeregu czasowego na N dni w przód.
                 Predykcja szeregu czasowego z angielskiego forecast
                 (w dalszej czesci analizy będzie używana angielska nazwa),
                 odbywać się będzie zarówno za pomocą danych historycznych,
                 czyli odczytanych ze zbioru danych, jak i
                 informacji o przyszłosci np. prognozie pogody dla następnych dni.")
               )
    ),
    
    fluidRow(
        style="padding:10px;",
        hr(),
        h3("Prezentacja danych")
    ),
    
    fluidRow(
        style = "text-align: justify;",
        column(12,
               p("Dane nie wymagają czyszczenia gdyż nie posiadają żadnych braków oraz zduplikowanych wierszy.
               Jedyna atrybut który potrzebował czyszczenia to atrybut Cloud który posiadał 97 
               brakujących wartości i zostały one zastąpione zerami.
               Przyczyną tego najprawdopodobniej jest błąd API pogodowego.
               \nZestaw danych został przygotowany przez mnie na podstawie danych o produkcji zwracanych przez prosotwnik.
                Następnie na podstawie lokalizacji geograficznej oraz informacji o dacie i
                godzinie dane zostały zupełnione o informacje o pozycji
                słonca obliczonej przy pomocy programu PySolar, 
                 oraz o informacje odnośnie pogody pobranych z API pogowoego WeatherStack."))
    ),
    
    fluidRow(
        column(3,
               p(" "),
               dateInput("inDate", "Data do wyświetlenia", value = "2020-10-29")
        ),
        column(9,
               plotOutput("timeSeriesPlot"),
               tableOutput("table"))
    ),
    
    fluidRow(
        style="padding:10px;",
        hr(),
        h3("Statystyka podsumowywująca")
    ),
    
    fluidRow(
        column(1, p(" ")),
        column(10, 
               verbatimTextOutput("summary"))
    ),
    
    fluidRow(
        style="padding:10px;",
        hr(),
        h3("Histogramy wartości poszczególnych atrybutów")
    ),
    
    fluidRow(
        column(3,
               selectInput("histo_atrib", h3("Atrybut"), 
                           choices = c("Produkcja","Zachmurzenie", "Opady", "UV Index", "Temperatura", "Wilgotność"), selected = 1),
               sliderInput("histogramBins", label = "Ilośc podziałów", min = 1, 
                           max = 20, value = 10)),
        column(9, plotOutput("histogram"))
    ),
    
    fluidRow(
        column(10,
               h3("Atrybuty"),p("Przedstawienie poszczególnych atrybutów"))
    ),
    
    fluidRow(
        style = "text-align: justify;",
        column(3,
               h4("Cloud")),
        column(9,
               p("Procentowa wartość opisująca zachmurzenie nieba"),
               plotOutput("cloudAggregatedHistogram"),
               p("Można zauważyć iż przez cały okres średnie zachmurzenei tygodniowe oscyluje w oklicy ~55%,
                 zakładam iż to własnie ten parametr wraz z pozycją słońca powinein miec największy wpływ
                 na ilość wyprodukowanej enrgii przez panele fotowoltaiczne"),
        )
    ),
    
    fluidRow(),
    
    fluidRow(
        style = "text-align: justify;",
        column(3,
               h4("UV_Index")),
        column(9,
               p("Index promeniowania UV w 10 stopniowej skali"),
               plotOutput("uvDonutPlot"),
               p("W naszym kraju przez większą cześć roku indeks UV osiąga wartości 1 lub 2,
                 jedynie w okresie letnio-wakacyjnym osiągane są wyższe wartości. Wykres kołowy umieszczony powyżej
                 potwierdza tą opserwacje gdyż ukazjue że w ponad połowie odczytów indeks UV przyjmował wartość 1")
        )
        
    ),
    
   fluidRow(
       style = "text-align: justify;",
        column(3,
               h4("Precip")),
        column(9,
               p("Opady atmosferyczne w mm/m^3"),
               plotOutput("precipBoxPlot"),
               p("Opady atmosferyczne przez cały rok nie przekraczają 5 mm/m^3,
               a średnia dla całego zbioru danych jest mniejsza niż 1mm/m^3.
                 Jedynie miesiąc wrzesień jest wyrózniający się ze znacznie większą
                 i czestszą liczbą opadów atmosferycznych, 
                 to również we wrzesniu odnotowano największe opady czyli 12mm/m^3")
               
        )
        
    ),
   
   fluidRow(
       column(3,
              h4("Temperature")),
       column(9,
              p("Temperatura powietrza w stopniach Celcjusza"),
              plotOutput("temperatureScaterdedPlot")
       )
       
   ),
   
   fluidRow(
       style = "text-align: justify;",
       column(3,
              h5("Humidity")),
       column(9,
              p("Wilgotność powietrza"),
              plotOutput("humidityRidgelinePlot"),
              p("Z uwagi na klimat w którym znajduje się Polska, można zauważyć że w ciągu
                roku poziom wilgotności powietrza oscyluje głównie w okolicy 80.")
       )
       
   ),
   
   fluidRow(
       style="padding:10px;",
       hr(),
       h3("Sieć neuronowa")
   ),
    
    fluidRow(
        style = "text-align: justify;",
        column(10,
               p("Protoptyp modelu sieci neuronowej którego zadaniem jest predykcja produkcji energi
               na następne n zadanych godzin.
                 Model został stworzony w środowisku programistycznym TensorFlow Keras,
                 a zastosowana technika sieci neuonowych to rekurencyjne sieci neuronowe LSTM."))
    ),
    
    fluidRow(
        style = "text-align: justify;",
        column(10,
               p("Model składa się z 2 warstw: warstwy rekurencyjnej LSTM o 100 neuronach
                 oraz warswy gęstej (pełnego połączenia) z 1 neuronem, 
                 której zadaniem jest sproawadzenie wyniku do pojedyńczej liczby."))
    ),
    
    fluidRow(
        style = "text-align: justify;",
        column(10,
               h3("Uczenie modelu"),
               p("Model został nauczony na zbiorze testowym który zawierał 95% danych poczatkowych ze zbioru.
               Atrybuty na których został wyszkolony to pozycja słońca oraz zachmurzenie nieba.
                 Model był uczony na przestrzeni 50 epok.
                 Z uwagi an zastosowanie warstwy LSTM każdy element wsadowy modelu 
                 musi odwoływac się do częsci danych historycznych.
                 Zdecydowałem aby model odwoływał się do ostatnich 12 godzin."))
    ),
   
   fluidRow(
       style = "text-align: justify;",
       column(2, p(" ")),
       column(7, 
              plotOutput("modelHistoryPlot"),
              p("Funkcja kosztu została ładnie wypłaszczona co oznacza iż model został prawidłowo nauczony.
                Jedynie model może uciepiepiec na przeuczeniu,
                lecz początkowe predykcje na danych testowych nie wykazywały tej przypadłosci.")
        )
   ),
   
   fluidRow(
       style = "text-align: justify;",
       column(10,
              h3("Predykcja"),
              p("Przykładowa predykcja dokonana na całości zbioru testowego zestawiona z prawdziwymi wartosciami.
                Predykcja została dokonana na danych od 17 stycznia do 23 lutego. Na wykresie można określić zakres dni
                z jakiego mają zostać pokazane dane oraz dodać do wykresu dodatkowe atrybuty, 
                które zostały wykorzystane w procesie uczenia
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
              
   ),
   
   fluidRow(
       style="padding:10px;",
       hr(),
       h3("Podsumowanie")
   ),
   
   fluidRow(
       column(12,
       style = "text-align: justify;",
       p("Po początkowej ewaluacji modelu na zbiorze testowm, wytrenowany model prezentuje się pozytywnie.
         Model nauczył się trendu danych (wzrost produkcji wraz ze wschodem słońca, oraz spadek po południu),
         jedynym problemem który można zauważyć na pierwszy rzut oka przy ewaluacji jest przypadłość iż model w godzinach
         nocnych zwraca wartości ujemne, a nie równe 0. Jest to dosyć błach problem, na który napotkałem się również w przypadku
         stosowania bardziej klasycznych modeli uczenia maszynowego jak np. AutoArima, która to również zamiast 0 zwracała małe
         wartości ujemne. Problem ten łatwo rozwiązałem przy pomocy zamiany wszystkich wartosciu ujemnych na 0 w momencie zwracania predykcji.
         Uzyskany model posłużył mi to stworzenia prototypu aplikacji, która na podstawie danych z ostatniego dnia oraz progrnozy pogody na
         następne dni zwraca predykcje produkcji energi. Problemem niestety w tym przypadku okazuje się jakość prognozy pogody godzinowej.
         Ponieważ tylko pierwszych 12 predykcji (tj. godzinnych produkcji energi) będzie oparte na sprawdzonych i potwierdzonych danych
         historycznych, a każda kolejna godzina dokonywana jest tylko na danych z prognozy pogody oraz w oparciu o poprzednie predykcje.
         I po początkowej ewaluacji wyników okazało się iż model nie dokońca jest w stanie przewidzieć nagłe skoki produkcji energi;
         model zwraca produkcje dzienną której wykres jest bardzo `równy` pozbawiony jakich kolwiek skoków.
         Niestety z braku czasu nie byłem wstanie przeprowadzić prototypowania nowego modelu z innymi parametrami,
         lecz jak miałbym wybierac próbował bym zmienić długość okna czasowego do jakiego model odwołuje się wstecz oraz zwiększył,
         liczbę parametrów na podstawie, których trenowany jest model o np. index uv oraz o parametry samej instalacji słonecznej.
         Ponieważ mam wrażenie iż obecnie zastosowane parametry nie końiecznie sią wystarczające.
        ")
       )
   )
))
