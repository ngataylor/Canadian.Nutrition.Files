## Bring in all files in Nutrient File Folder

# Set Working Directory 

setwd("C://Users//Natha//Desktop//R//Branch Household Survey//Nutrient Files")

# Select all files from the folder to load

temp <- list.files(pattern="*.csv")

# Load all files

Ntrnt <- lapply(temp, read.csv)

# Transpose as data frames

Ntrnt <- lapply(Ntrnt, as.data.frame(t))

# Remove Excess

Ntrnt <-lapply(Ntrnt, '[', i=,j=1:13)

Ntrnt <-lapply(Ntrnt, '[', i=,j=-(3:7))

#Create vector of names

Colnms <- c("Food","Code", "Protein(g)", "Fat(g)", "Carbohydrate(g)", "Alcohol", 
            "Energy(kcal", "Energy(kJ)")

#Rename columns

Ntrnt <- lapply(Ntrnt, setNames, nm=Colnms)

# Create function to replicate the name of the food through all rows in 1 column

rep.row1 <- function(df){
  df[2:3,1] <- df[1,1] 
  df
}

rep.row2 <- function(df){
  df[2:3,2] <- df[1,2]
  df
}


# lapply rep.row1 and rep.row2

Ntrnt <- lapply(Ntrnt, rep.row1)

Ntrnt <- lapply(Ntrnt, rep.row2)

# Remove row function

rem.row <- function(df){
  df[3,]
  }

# lapply rem.row

Ntrnt <- lapply(Ntrnt, rem.row)

## Merge Cleaned Data Frames

Ntrnt <- plyr::ldply(Ntrnt, data.frame)


## Add identifiers for FFQ questions

Ntrnt <- cbind(temp, Ntrnt)


## Remove suffix and prefix

Ntrnt$temp <- gsub(".csv", "", Ntrnt$temp)
Ntrnt$temp <- gsub("Q", "", Ntrnt$temp)

## Make numeric

Ntrnt$temp <- as.numeric(Ntrnt$temp)

## Arrange by question

Ntrnt <- arrange(Ntrnt, temp)

## Rename Q Column

colnames(Ntrnt)[1] <- "Q"

## Remove ""Food code :" from the code column ##

Ntrnt$Code <- gsub("Food code :","", Ntrnt$Code)

## Subset and replace energy kcal values with alcohol values when energy kj is missing values

Ntrnt1 <- lapply(Ntrnt[,-2], as.character)
Ntrnt1 <- lapply(Ntrnt1, as.numeric)
Ntrnt1 <- as.data.frame(Ntrnt1)

Ntrnt1$Energy.kcal[is.na(Ntrnt1$Energy.kJ.)] <- Ntrnt1$Alcohol[is.na(Ntrnt1$Energy.kJ.)]

Ntrnt <- cbind(Ntrnt1[,1], Ntrnt[,2], Ntrnt1[2:length(Ntrnt1)])

rm(Ntrnt1)

colnames(Ntrnt)[1:2] <- c("Q", "Food")

## Bring in conversion file

Ntrntconv <- read.csv("C:/Users/natha/Desktop/Canadian Nutrient File/ConvFactAmount.csv")

## Select rows for food codes of interest

Ntrnt$Code <- as.integer(Ntrnt$Code)

Ntrntconv <- Ntrntconv[is.element(Ntrntconv$FoodCode,Ntrnt$Code),]

## change date column to dates...

Ntrntconv$ConvFactorDateOfEntry <- as.Date(Ntrntconv$ConvFactorDateOfEntry)

## Bring in Food Measures File

Ntrntmsr <- read.csv("C:/Users/natha/Desktop/Canadian Nutrient File/Food Measure Name.csv")

## Select rows and columns for measure IDs of interest

Ntrntmsr <- Ntrntmsr[is.element(Ntrntmsr$ï..MeasureID, Ntrntconv$MeasureID),1:2]

## Add food measures from Ntrntmsr to a new column in Ntrntconv

Ntrntconv <- dplyr::mutate(Ntrntconv, 
              Measure.Description= Ntrntmsr[match(Ntrntconv$MeasureID, Ntrntmsr$ï..MeasureID),2])


## Move and rename columns ##

Ntrntconv <- cbind(Ntrntconv[,2:3], Ntrntconv[,6], Ntrntconv[,4:5])

colnames(Ntrntconv)[3] <- "Measure"

## Add Question Number

Ntrntconv$Q <- Ntrnt[match(Ntrntconv$FoodCode, Ntrnt$Code),1]

## And Food 

Ntrntconv$Food <- Ntrnt[match(Ntrntconv$FoodCode, Ntrnt$Code),2]

## Reorganize

Ntrntconv <- cbind(Ntrntconv[,6:7], Ntrntconv[,1:5])

### NOTE FOOD MEASURE ID 1666 IS MISSING FROM THE ORIGINAL CNF DATASET ###
### FOOD MEASURE ID 1666 CORRESPONDS TO FOOD CODE 1749, STRAWBERRY, RAW ###


## Ntrntconv <- dplyr::top_n(Ntrntconv, n=1, wt=ConvFactorDateOfEntry) ##

### Create conversion table ###

Setconv <- read.csv("C://Users//natha//Desktop//Temp//Selected Conversions.csv")

## Get a list of specific macros, energy etc. (Calories in this case) ##

Qcals <- (select(Ntrnt, "Energy.kcal"))

Qcals$Energy.kcal <- as.numeric(as.character(Qcals$Energy.kcal))

Qprot <- (select(Ntrnt,"Protein.g."))

Qprot$Protein.g. <- as.numeric(as.character(Qprot$Protein.g.))

Qfat <- (select(Ntrnt,"Fat.g."))

Qfat$Fat.g. <- as.numeric(as.character(Qfat$Fat.g.))

Qcarb <- (select(Ntrnt, "Carbohydrate.g."))

Qcarb$Carbohydrate.g. <- as.numeric(as.character(Qcarb$Carbohydrate.g.))

## Create conversion list

Qconv <- Setconv$ConversionFactorValue

##Multiply FFQ daily totals by portions 

FFQtc <- cbind(FFQt[,1], data.frame(mapply('*',FFQt[-1],t(Qconv))))

## Multiply FFQ daily totals by nutrient of interest

FFQcarb<- data.frame(mapply('*',FFQtc[-1],t(Qcarb)))

FFQfat <- data.frame(mapply('*',FFQtc[-1],t(Qfat)))

FFQprot <- data.frame(mapply('*',FFQtc[-1],t(Qprot)))

FFQcals <- data.frame(mapply('*',FFQtc[-1],t(Qcals)))

## Create rows of totals

FFQcarb <- mutate(FFQcarb, Total.Carbs = rowSums(FFQcarb))

FFQfat <- mutate(FFQfat, Total.Fat = rowSums(FFQfat))

FFQprot <- mutate(FFQprot, Total.Prot = rowSums(FFQprot))

FFQcals <- mutate(FFQcals, Total.Cals = rowSums(FFQcals))

## Create df of totals 

FFQtotals <- cbind(FFQt$`Survey Number`,FFQcarb$Total.Carbs,FFQfat$Total.Fat, 
                   FFQprot$Total.Prot, FFQcals$Total.Cals)

##Name columns

FFQcols <- c("Survey Number", "Total Carbs", "Total Fats", "Total Protein", "Total Calories")

colnames(FFQtotals) <- FFQcols

## df

FFQtotals <- as.data.frame(FFQtotals)

### Cals per Macro ##

FFQtotals$Cals.Carbs <- FFQtotals$`Total Carbs`*4
FFQtotals$Cals.Fats <- FFQtotals$`Total Fats`*9
FFQtotals$Cals.Prot <- FFQtotals$`Total Protein`*4


### % Cals

FFQtotals$'%cals.Carbs' <- (FFQtotals$Cals.Carbs/FFQtotals$`Total Calories`)*100
FFQtotals$'%cals.Fats' <- (FFQtotals$Cals.Fats/FFQtotals$`Total Calories`)*100
FFQtotals$'%cals.Prot' <- (FFQtotals$Cals.Prot/FFQtotals$`Total Calories`)*100

### Total to confirm accuracy

FFQtotals$total <- FFQtotals$`%cals.Carbs`+FFQtotals$`%cals.Fats`+FFQtotals$`%cals.Prot`

## Choose directory to store excel file

## write.csv(FFQtotals, "C://Users//natha//Desktop//Totals.csv")
