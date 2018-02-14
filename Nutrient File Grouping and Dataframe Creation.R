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


## Subset and replace energy kcal values with alcohol values when energy kj is missing values

Ntrnt$Energy.kJ. <- as.numeric(as.character(Ntrnt$Energy.kJ.))

Ntrnt$Energy.kcal <- as.numeric(as.character(Ntrnt$Energy.kcal))

Ntrnt$Alcohol <- as.numeric(as.character(Ntrnt$Alcohol))

x <- is.na(Ntrnt$Energy.kJ.)

Ntrnt$Energy.kJ.[x] <- Ntrnt$Energy.kcal[x]

Ntrnt$Energy.kcal[x] <- Ntrnt$Alcohol[x]

Ntrnt$Alcohol[x] <- 0


File.Ready <- Ntrnt


## Create csv file to work with in excel


write.csv(File.Ready, "C:/" )
