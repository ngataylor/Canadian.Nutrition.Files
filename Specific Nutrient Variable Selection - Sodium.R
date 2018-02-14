##Sodium Selection##

## Load in all data files

Ntrnt1 <- lapply(temp,read.csv)

## Change to transposed data frame for manipulation

Ntrnt1 <- lapply(Ntrnt1, as.data.frame(t))

## Use View(Ntrnt1[[1]]) to choose a column for calculations ##

## Create function for column renaming

Lapcols <- function(x) {
  colnames(x) <- make.names(as.character(unlist(x[1,])), unique=TRUE)
  return(x)
}

## Rename columns by first row using new function ##

Ntrnt1 <- lapply(Ntrnt1, Lapcols)

### Create selection function### 
### TO ADD TO SELECTION CREATE NEW TEMP AND ADD VARIABLE NAME ###

Ntrntsel <- function(x){
  temp1 <-NULL
  temp2 <- NULL
  temp1 <- grep("Food", colnames(x))
  temp2 <- grep("Sodium",colnames(x))
  x <- x[,c(temp1,temp2)]
  return(x)
  }

## lapply function

Ntrnt1 <- lapply(Ntrnt1, Ntrntsel)


## Repeat rows for manipulation

Ntrnt1 <- lapply(Ntrnt1, rep.row1)

## Select rows of interest by subsetting

Ntrnt1 <- lapply(Ntrnt1, "[", i=3,j=)

## Rename columns

Ntrnt1 <- lapply(Ntrnt1, setNames, c("Code", "Sodium.mg"))


## Merge Cleaned Data Frames

Ntrnt1 <- plyr::ldply(Ntrnt1, data.frame)

## 

Ntrnt1 <- cbind(temp, Ntrnt1)

## Remove suffix and prefix

Ntrnt1$temp <- gsub(".csv", "", Ntrnt1$temp)
Ntrnt1$temp <- gsub("Q", "", Ntrnt1$temp)

## Make numeric

Ntrnt1$temp <- as.numeric(Ntrnt1$temp)

## Arrange by question

Ntrnt1 <- arrange(Ntrnt1, temp)

## Rename Q Column

colnames(Ntrnt1)[1] <- "Q"

## Remove ""Food code :" from the code column ##

Ntrnt1$Code <- gsub("Food code :","", Ntrnt1$Code)


## Add column of conversion factors

Ntrnt1 <- cbind(Ntrnt1, Setconv$ConversionFactorValue)

## Change name

colnames(Ntrnt1)[4] <- "Conversion"

## Convert from factor

Ntrnt1$Sodium.mg <- as.numeric(as.character(Ntrnt1$Sodium.mg))

## Multiply by conversion

Ntrnt1 <- mutate(Ntrnt1, Na.conv = Sodium.mg*Conversion)

## Get column of values

Qsod <- (select(Ntrnt1, "Na.conv"))

## Multiply by daily values

FFQsod <- data.frame(mapply('*',FFQtc[-1],t(Qsod)))

## Get totals

FFQsod <- mutate(FFQsod, Total.Sod.mg = rowSums(FFQsod))
