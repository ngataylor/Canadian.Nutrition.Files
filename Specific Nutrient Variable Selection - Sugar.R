##Sugar Selection##

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
  temp2 <- grep("Sugars",colnames(x))
  x <- x[,c(temp1,temp2)]
  return(x)
  }

## lapply function

Ntrnt1 <- lapply(Ntrnt1, Ntrntsel)


## Repeat rows for manipulation

Ntrnt1 <- lapply(Ntrnt1, as.data.frame)

Ntrnt1 <- lapply(Ntrnt1, rep.row1)

## Select rows of interest by subsetting

Ntrnt1 <- lapply(Ntrnt1, "[", i=3,j=)

## Create subset vector for later

Sgsb <- lapply(Ntrnt1,length)==2

## Create new temp for later

temp2 <- temp[lapply(Ntrnt1,length)==2]

## Subset by length

Ntrnt1 <- Ntrnt1[lapply(Ntrnt1,length)==2]

## Rename columns

Ntrnt1 <- lapply(Ntrnt1, setNames, c("Code", "Sugars.g"))


## Merge Cleaned Data Frames

Ntrnt1 <- plyr::ldply(Ntrnt1, data.frame)

## Add Qs

Ntrnt1 <- cbind(temp2, Ntrnt1)

## Remove suffix and prefix

Ntrnt1$temp2 <- gsub(".csv", "", Ntrnt1$temp2)
Ntrnt1$temp2 <- gsub("Q", "", Ntrnt1$temp2)

## Make numeric

Ntrnt1$temp2 <- as.numeric(Ntrnt1$temp2)

## Arrange by question

Ntrnt1 <- arrange(Ntrnt1, temp2)

## Rename Q Column

colnames(Ntrnt1)[1] <- "Q"

## Remove ""Food code :" from the code column ##

Ntrnt1$Code <- gsub("Food code :","", Ntrnt1$Code)

##Create a data.frame to merge with Ntrnt1 to keep order and insert NAs for rows missing from data.frame

Q <- 1:125
Q <- data.frame(Q)
Ntrnt1 <- merge(Ntrnt1, Qm, by="Q",all=T)

## Add column of conversion factors

Ntrnt1 <- cbind(Ntrnt1, Setconv$ConversionFactorValue)

## Change name

colnames(Ntrnt1)[4] <- "Conversion"

## Convert from factor

Ntrnt1$Sugars.g <- as.numeric(as.character(Ntrnt1$Sugars.g))

## Multiply by conversion

Ntrnt1 <- mutate(Ntrnt1, Sg.conv = Sugars.g*Conversion)

## Get column of values

Qsug <- (select(Ntrnt1, "Sg.conv"))


## Multiply by daily values

FFQsug <- data.frame(mapply('*',FFQtc[-1],t(Qsug)))

# Change NAs to zeros

FFQsug[is.na(FFQsug)] <- 0

## Get totals

FFQsug <- mutate(FFQsug, Total.Sug.g = rowSums(FFQsug))
