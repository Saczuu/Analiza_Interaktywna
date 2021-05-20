dane <- read.csv("/Users/saczewski/Documents/Studia/SystemyInteligentne/SaczewskiMaciej_SIwB/SolarDashboard/Dane.csv", sep = ",")

dane$Date <- paste(dane$Data, dane$Hour)

dane <- select(dane, "Date", "Energy")

TS <- ts(dane$Energy, start = c(2020,2,1), end=c(2021,02,23), frequency=8760)

decompose(TS)
