## Title: "Understanding Toronto's Homicide Rates Through its Marginalized Neighbourhoods"
## Author: Cindy Ly
## Purpose: This is an R script for Assignment-1 Markdown

knitr::opts_chunk$set(echo = TRUE)

## Install Packages
options(repos = list(CRAN="http://cran.rstudio.com/"))
install.packages("opendatatoronto")
install.packages("dplyr")
install.packages("tidyverse")
install.packages("janitor")
install.packages("tidyr")
install.packages("bibtex")
install.packages("here")

## Load libraries
library(opendatatoronto)
library(dplyr)
library(janitor)
library(tidyverse)
library(tidyr)
library(bibtex)
library(here)

# get our raw data from out inputs folder
raw_data <- read_csv(here("Inputs", "data", "raw_data.csv"))

# basic cleaning of homicide dataset from janitor package
cleaned_homicide <-
  clean_names(raw_data)

#### we want to look at the data from 2013-2020 and must select these rows

# the occurrence_year data is an integer, so we must convert to numeric before filtering
cleaned_homicide$occurrence_year <- as.numeric(cleaned_homicide$occurrence_year)

# we can filter the years out and create a new data frame
homicide_data <- subset(cleaned_homicide, cleaned_homicide$occurrence_year > 2012)

# lets create a table that includes homicide type and year
tab1 <- table(homicide_data$occurrence_year, homicide_data$homicide_type)

## now lets create a new column that will show us the total homicides that year

# we need to turn this into a dataframe first in order to use mutate()
tab1 <- as.data.frame.matrix(tab1) 

# now we can create a new column that will show us the total per neighbourhood
tab1 <-
  tab1 |>
  mutate(Total = Other + Shooting + Stabbing)

## Table 1 - shows total homicides in Toronto from 2013 to 2020 with the three types (other, shooting, stabbing)
# using knitr, we can make a nicer looking table for our markdown of homicide types
kable1 <-
  knitr::kable(
    tab1,
    "pipe",
    col.names = c("Other", "Shooting", "Stabbing", "Total"),
    align = "lccr",
    caption = "Number of Homicides by Type in Toronto from 2013 to 2020"
  )
kable1

## Graph 1 - shows annual homicide counts and each type
graph1 <-
  (homicide_data |> 
     ggplot(mapping = aes(x = occurrence_year, fill = homicide_type)) +
     geom_bar(width = 0.7) +
     geom_text(stat='count', aes(label=..count..), position = position_stack(vjust = 0.5)) +
     labs(title = "Homicide Rates in Toronto from 2013 to 2020", 
          x = "Year", 
          y = "Cases",
          fill = "Homicide Type") +
     theme_minimal() +
     scale_fill_manual(values = c("#ffd675", "#4bc9a3", "#1c6fff"))
  )
graph1

#### lets look at the highest homicide count for the top 6 neighbourhoods from 2013 to 2020

# we need to create a table that counts homicide rate per year for each neighbourhood
# note: we use table() rather than count() because they are "character" classes and not "numeric"
tab2 <- table(homicide_data$neighbourhood, homicide_data$occurrence_year)

# we need to turn this into a dataframe for processing
tab2 <- as.data.frame.matrix(tab2) 

# now we can create a new column that will show us the total per neighbourhood
tab2 <-
  tab2 |>
  mutate(Total = `2013` + `2014` + `2015` + `2016` + `2017` + `2018` + `2019` + `2020`)

# now we can use order counts from smallest to greatest
sorted.tab2 <- tab2[order(as.numeric(tab2$Total)), ]

## table 2 - the greatest homicide counts in Toronto neighbourhoods (top 6)
kable2 <- 
  knitr::kable(
    tail(sorted.tab2),
    "pipe",
    col.names = c("2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020", "Total"),
    align = "lcccccccr",
    caption = "Greatest Homicide Counts in Toronto's Neighbourhoods from 2013 to 2020"
  )
kable2

# now lets make a graph to show the total homicides between these years per neighbourhood
homicide_data$occurrence_year<-as.numeric(homicide_data$occurrence_year)

# lets start with a table 
tab3 <-
  count(homicide_data, neighbourhood)

# lets order this table from smallest to greatest while making the 'n' column a numeric class
sorted.tab3 <- tab3[order(as.numeric(tab3$n)), ]

# now lets find the 6 largest values (aka the last six in this data frame)
sorted.tab3 <- tail(sorted.tab3)

# we can now graph all of these values 
graph2 <-
  sorted.tab3 |> 
  ggplot(mapping = aes(x = neighbourhood, y = n)) +
  geom_bar(stat = "identity", width = 0.6) +
  labs(title = "Greatest Homicide Cases by Toronto Neighbourhood from 2013 to 2020", 
       x = "Neighbourhood", 
       y = "Cases") +
  scale_x_discrete(labels = c("Waterfront Communities-The Island (77)" = "The Island", "West Humber-Clairville (1)" = "W. Humber Clairville", "Weston (113)" = "Weston", "Bay Street Corridor (76)" = "Bay St. Corridor", "Mount Olive-Silverstone-Jamestown (2)" = "Smithfield", "Moss Park (73)" = "Moss Park")) +
  geom_text(aes(label = n), vjust = -0.4) +
  theme_minimal()
graph2

#### create a bibliography file
library(bibtex)
knitr::write_bib(c('knitr', 'opendatatoronto', 'tidyverse', 'ggplot2', 'dplyr', 'janitor', 'tidyr', 'bibtex', 'here'), file = 'references.bib')

# adding R as a reference to the file 
Rcite = citation()
Rcite$key = "R"
bibtex::write.bib(Rcite, 'references.bib', append = TRUE)
