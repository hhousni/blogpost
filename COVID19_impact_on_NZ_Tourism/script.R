library(readxl)
library(scales)
library(lubridate)
library(grid)
library(tidyverse)


########### graph1 ######
intArrival <- read_excel("COVID19_impact_on_NZ_Tourism/RawData/InternationaArrival2010-Apr2022.xlsx")


# data prep 
intArrivalClean0 <- as.data.frame(intArrival[2:150,])
names(intArrivalClean0) <- c("date","seasonallyAdjusted","trend")
intArrivalClean0$date <- as.Date(paste(intArrivalClean0$date, "01", sep = "-"), "%YM%m-%d")
intArrivalClean0$date <- as.POSIXct(intArrivalClean0$date)

intArrivalClean1 <- intArrivalClean0 %>%
  mutate(SeasonallyAdjusted = as.numeric(seasonallyAdjusted), 
         Trend = as.numeric(trend),
         Year = year(date),
         Month = month(date)) %>%
  filter(Year %in% c(2018:2022))



# visualisation 

intArrivalClean1$Year <- factor(intArrivalClean1$Year)

ggplot() +
  geom_line(data = intArrivalClean1, aes (x = Month, y = SeasonallyAdjusted, color = Year, alpha = Year),lwd=1.5)+
  scale_alpha_manual(values=c(0.2,0.2,0.2,0.2,1)) +
  theme(axis.title.x = element_blank()) +
  labs (title = "Visitor arrivals",
        subtitle = "2018-2022") +
  scale_y_continuous(name = "Visitor Arrival",limits = c(0,400000),labels = comma) +
  scale_x_continuous( breaks = seq_along(month.name),
                      labels = month.name) +
  theme_bw() +
    theme(plot.title = element_text(colour = "#3d4f6e",size = 24,vjust = 10, hjust = 0.5),
          plot.subtitle = element_text(colour = "#808080",size = 18, vjust = 10, hjust =0.5),
          plot.margin = margin(2, 0.5, 0.5, 0.5, "cm"),
          axis.title.x = element_blank())


########### graphe 2 employment market######

employment <- read_excel("COVID19_impact_on_NZ_Tourism/RawData/employment.xlsx")

employment0 <- as.data.frame(employment[2:13,1:4])
names(employment0) <- c("Year","DirectlyEmployed","IndirectlyEmployed","TotalEmployed")


employment1 <- employment0 %>%
  mutate(DirectlyEmployed = as.numeric(DirectlyEmployed),
         IndirectlyEmployed = as.numeric(IndirectlyEmployed),
         TotalEmployed = as.numeric(TotalEmployed),
         Year = as.numeric(Year)) %>%
  mutate(DirectlyEmployedGrowthRate = 
           round((DirectlyEmployed- lag(DirectlyEmployed))/lag(DirectlyEmployed)*100, digits = 2),
         IndirectlyEmployedGrowthRate = 
           round((IndirectlyEmployed- lag(IndirectlyEmployed))/lag(IndirectlyEmployed)*100, digits = 2),
         TotalEmployedGrowthRate = 
           round((TotalEmployed- lag(TotalEmployed))/lag(TotalEmployed)*100, digits = 2)) %>%
  filter(Year %in% c(2018:2021)) %>%
  select(c("Year","DirectlyEmployedGrowthRate","IndirectlyEmployedGrowthRate","TotalEmployedGrowthRate"))

names(employment1) <- c("Year","Directly Employed", "Indirectly Employed", "Total Employed")


# visualization

emplViz <- employment1 %>%
  gather("Directly Employed", "Indirectly Employed", "Total Employed", 
         key = EmployementType, value = AnnualGrowthRate) %>%
  filter(EmployementType %in% c("Directly Employed","Indirectly Employed"))

ggplot(data = emplViz, aes (x = Year, y = AnnualGrowthRate, fill = EmployementType )) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_text(aes(y=AnnualGrowthRate+sign(AnnualGrowthRate),label=AnnualGrowthRate),position = position_dodge(0.9), size=3.5) +
  scale_fill_brewer(palette = "Paired") +
  labs(title = "Tourism employment in New Zealand",
       subtitle = "Year over year growth (2018-2021)",
       caption = "Data source: Stats NZ",
       fill = "") +
  theme_bw() +
  theme(plot.title = element_text(colour = "#3d4f6e",size = 24,vjust = 10, hjust = 0.5),
        plot.subtitle = element_text(colour = "#808080",size = 18, vjust = 10, hjust =0.5),
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        legend.direction = "horizontal",
        legend.position = c(0.5, 0.91),
        legend.text = element_text(size = 12,margin = margin(r = 1, unit = 'cm')),
        legend.key.size = unit(0.5, "cm"),
        plot.margin = margin(2, 0.5, 0.5, 0.5, "cm")) + 
  scale_x_reverse() +
  coord_flip()





##### 3 Domestic expenditure #####
expenditure0 <- read_excel("COVID19_impact_on_NZ_Tourism/RawData/expenditure.xlsx")

expenditure <- expenditure0 %>%
  mutate(Domestic = as.numeric(Domestic),
         International = as.numeric(International),
         Total = as.numeric(Total)) %>% 
  mutate(DomesticGRT = round((Domestic- lag(Domestic))/lag(Domestic)*100, digits = 2),
         InternationalGRT = round((International- lag(International))/lag(International)*100, digits = 2),
         TotalGRT = round((Total- lag(Total))/lag(Total)*100, digits = 2))
  

expenditureGRT <-  expenditure %>% 
  select(Year, DomesticGRT, InternationalGRT, TotalGRT) %>%
  rename(Domestic = DomesticGRT , International = InternationalGRT, Total = TotalGRT) +
  gather(Domestic, Domestic, Total,key = TypeOfTourist, value = ExpenditureYOYGRT) %>%
  filter( Year %in% c(2015:2022), TypeOfTourist %in% c("Domestic","International")) 


ggplot(data = expenditureGRT, aes(x = Year, y = ExpenditureYOYGRT, fill = TypeOfTourist)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  labs(title = "Annual growth of travel expenditure by tourist type",
       subtitle = "From 2015 to 2021",
       caption = "Data source: Stats NZ",
       fill = "") +
  theme_bw() +
  theme(plot.title = element_text(colour = "#3d4f6e",size = 24,vjust = 10, hjust = 0.5),
        plot.subtitle = element_text(colour = "#808080",size = 18, vjust = 10, hjust =0.5),
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        legend.direction = "horizontal",
        legend.position = c(0.5, 1.035),
        legend.text = element_text(size = 12,margin = margin(r = 1, unit = 'cm')),
        legend.key.size = unit(0.5, "cm"),
        plot.margin = margin(2, 0.5, 0.5, 0.5, "cm"))





