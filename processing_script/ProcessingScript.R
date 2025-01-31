###################
#Processing Script
#This script loads and cleans raw data for the Ibis data analysis process. It then saves processed data for further analysis.

###############################Loading all required packages###########################
library(here) #to set paths
library(tidyverse) #all required data manipulation packages
library(xlsx) #to read in excel spreadsheets
library(lubridate) #to extract times from raw data
library(janitor) #to help clean up dates and tidy data

#--------------------------------------------------------------------------------------#

##################################Inputting Raw Data###################################
#Setting the path to the Ibis blood parasite spreadsheet
data_locationIbisB <- here::here("raw_data","Ibis_Blood_ParasiteData_2017.xlsx")
#Setting the path to the Ibis field data spreadsheet
data_locationIbisF <- here::here("raw_data","IbisFieldDataOct19_2017.xlsx")
#Loads the raw Ibis blood data excel sheet from 2015-2017
rdIbisBlood15_17 <- read.xlsx(data_locationIbisB, sheetName = "2015-2017")
#Loads the raw Ibis blood data excel sheet from 2010-2014
rdIbisBlood10_14 <- read.xlsx(data_locationIbisB, sheetName = "2010-2014")
#Loads the raw Ibis field data excel sheet
rdIbisField <- read.xlsx(data_locationIbisF, sheetName = "All capture data")
#--------------------------------------------------------------------------------------#

##############################Cleaning the rdIbisBlood10_14 data###########################
IbisBlood10_14 <- rename(rdIbisBlood10_14, ID = X.) #renames the ID column

#Extracts just the columns of interest
IbisBlood10_14 <- select(IbisBlood10_14, ID, Site.ID, Date, PCR.sex, Age..adult.juvenile., 
                         Total.RBC, Haemoproteus.parasitemia.)

#Renames the columns of interest
IbisBlood10_14 <- rename(IbisBlood10_14, Site = Site.ID, Sex = PCR.sex, Age = Age..adult.juvenile.,
                         TotalRBC = Total.RBC, HaeParasit = Haemoproteus.parasitemia.)

#Change "adult" and "juvenile" in the Age column to "A" and "J"
IbisBlood10_14$Age[IbisBlood10_14$Age == "adult"] <- "A"
IbisBlood10_14$Age[IbisBlood10_14$Age == "Adult"] <- "A"
IbisBlood10_14$Age[IbisBlood10_14$Age == "juvenile"] <- "J"
IbisBlood10_14$Age[IbisBlood10_14$Age == "SA"] <- "A"
#Now the Ibises that had age recorded are referred to as "A" for adult or "J" for juvenile


#Changing the DIV/0 values in HaeParasit to NA and change the column to numerical values
IbisBlood10_14$HaeParasit <- as.numeric(IbisBlood10_14$HaeParasit)  # Divide-by-zero errors are now NA

#Reformatting the date values in the Date column
IbisBlood10_14$Date <- excel_numeric_to_date(IbisBlood10_14$Date)
#After this step, the values that just state the year are labelled with "1905", may need to go back or exclude from analysis

#Abbreviating the site names to make analysis easier
IbisBlood10_14$Site[IbisBlood10_14$Site == "Royal Palms"] <- "RP"
IbisBlood10_14$Site[IbisBlood10_14$Site == "Everglades"] <- "E"
IbisBlood10_14$Site[IbisBlood10_14$Site == "Dreher Park"] <- "DRP"
IbisBlood10_14$Site[IbisBlood10_14$Site == "Indian Creek"] <- "ICP"
IbisBlood10_14$Site[IbisBlood10_14$Site == "Indian Creek "] <- "ICP"
IbisBlood10_14$Site[IbisBlood10_14$Site == "Indian Creek Park"] <- "ICP"
IbisBlood10_14$Site[IbisBlood10_14$Site == "Juno Beach"] <- "JB"
IbisBlood10_14$Site[IbisBlood10_14$Site == "Lion Country Safari"] <- "LCS"
IbisBlood10_14$Site[IbisBlood10_14$Site == "Lake Worth"] <- "LW"
IbisBlood10_14$Site[IbisBlood10_14$Site == "Prosperity Oaks"] <- "PO"
IbisBlood10_14$Site[IbisBlood10_14$Site == "Promenade Plaza"] <- "PP"
IbisBlood10_14$Site[IbisBlood10_14$Site == "San Mateo"] <- "SM"
IbisBlood10_14$Site[IbisBlood10_14$Site == "Solid Waste Authority"] <- "SWA"
IbisBlood10_14$Site[IbisBlood10_14$Site == "West Palm Beach Zoo"] <- "WPBZ"


#Reformatting the mislabeled dates. These are set to Jan 1st of the year they were
#recorded on the data sheet, these entries only had the year stated, not month and day.
IbisBlood10_14$Date[IbisBlood10_14$Date == "1905-07-02"] <- "2010-01-01"
IbisBlood10_14$Date[IbisBlood10_14$Date == "1905-07-03"] <- "2011-01-01"
IbisBlood10_14$Date[IbisBlood10_14$Date == "1905-07-04"] <- "2012-01-01"

#The bottom of the dataset has a couple rows of just missing data for all variables,
#This code filters the dataset so that if any rows are present that has at least
#one variable be NOT NA, R keeps it
IbisBlood10_14 <- filter(IbisBlood10_14, if_any(everything(), ~ !is.na(.)))

#This completes the cleaning phase for IbisBlood10_14
#------------------------------------------------------------------------------------#


############################Cleaning the rdIbisBlood15_17 Data#########################

IbisBlood15_17<- rename(rdIbisBlood15_17, ID= X.) #renames the ID column

####Extracting only the columns relevant for analysis
IbisBlood15_17 <- select(IbisBlood15_17,ID,Site.Name,Date,PCR.sex,Age,Season,Habitat.type,
                         Total.RBC,X..Haemoproteus,Haemoproteus.parasitemia.,F1,F2,F3,
                         Avg.RBC.FOV,Ibis..,Total.mass..g.,Mass.bag..g.,Mass.bird..g.,Body.condition.score..1.5.,
                         Ectoparasite.score..1.5.,Culmen.length..mm.,Wing.chord.length..mm.,
                         Tarsus.length..mm.,Tarsus.width..mm.)

####Renaming the columns 
IbisBlood15_17 <- rename(IbisBlood15_17,Site = Site.Name,Sex = PCR.sex,HabType = Habitat.type,TotalRBC = Total.RBC,NumHae = X..Haemoproteus,
                         HaeParasit = Haemoproteus.parasitemia.,AvgRBC = Avg.RBC.FOV,
                         IbisNum = Ibis..,TotalMassG = Total.mass..g.,BagMassG = Mass.bag..g.,
                         BirdMassG = Mass.bird..g.,BodyCondScore = Body.condition.score..1.5.,
                         EctoParasitScore = Ectoparasite.score..1.5.,CulmenLmm = Culmen.length..mm.,
                         WingChordLmm = Wing.chord.length..mm.,TarsusLmm = Tarsus.length..mm.,
                         TarsusWmm = Tarsus.width..mm.)

####Site column
#Ibis that have sites matched with the 10_14 dataset will have the same labels
IbisBlood15_17$Site[IbisBlood15_17$Site == "Juno Beach"] <- "JB"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Indian Creek Park"] <- "ICP"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Dubois park"] <- "DUP"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Dreher Park"] <- "DRP"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Lion Country Safari"] <- "LCS"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Dubois Park"] <- "DUP"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Loxahatchee Wildlife Refuge"] <- "LOXWR"
IbisBlood15_17$Site[IbisBlood15_17$Site == "J.W. Corbett Wildlife Management Area"] <- "JWC"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Gaines Park"] <- "GP"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Solid Waste Authority"] <- "SWA"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Fisheating creek"] <- "FC"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Kitching Creek"] <- "KC"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Loxahatchee NE"] <- "LOXNE"
IbisBlood15_17$Site[IbisBlood15_17$Site == "DuBois Park"] <- "DUP"
IbisBlood15_17$Site[IbisBlood15_17$Site == "TetraTech"] <- "TT"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Green Cay"] <- "GC"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Dreher park"] <- "DRP"
IbisBlood15_17$Site[IbisBlood15_17$Site == "CROW Wildlife Rehabilitation Center"] <- "CROW"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Lake Worth"] <- "LW"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Royal Palm"] <- "RP"
IbisBlood15_17$Site[IbisBlood15_17$Site == "JW Corbett"] <- "JWC"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Busch Wildlife Sanctuary"] <- "BWS"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Loxahatchee Slough"] <- "LOXS"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Indian Creek"] <- "ICP"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Cat House (Bonnie's, Richard Lane)"] <- "CAT"
IbisBlood15_17$Site[IbisBlood15_17$Site == "Palm Beach Zoo"] <- "WPBZ"

####Date column
#Changing the date column to numeric values to allow date extraction
IbisBlood15_17$Date <- as.numeric(IbisBlood15_17$Date) 
##Reformatting the date values in the Date column
IbisBlood15_17$Date <- excel_numeric_to_date(IbisBlood15_17$Date)

####Sex column
IbisBlood15_17$Sex[IbisBlood15_17$Sex == "not bled"] <- NA
#Two values have missing data because the birds were not bled to determine sex
IbisBlood15_17$Sex[IbisBlood15_17$Sex == "M?"] <- NA
IbisBlood15_17$Sex[IbisBlood15_17$Sex == "F?"] <- NA
IbisBlood15_17$Sex[IbisBlood15_17$Sex == "F "] <- "F"
#Two values have question marks for unsure sex determination, removing those values

####Age column
#When an ibis reaches 4 years old, their plumage becomes all white. Any Ibis
#that was sampled with brown plumage is considered a juvenile. Since Haemoproteus is
#a chronic disease that mostly likely accumulates over time, long-lived birds should
#theoretically have more parasitemia. Could not be true though and may come back to
#look at the individual years in the juvenile birds
IbisBlood15_17$Age[IbisBlood15_17$Age == "Juvenile"] <- "J"
IbisBlood15_17$Age[IbisBlood15_17$Age == "Adult"] <- "A"
IbisBlood15_17$Age[IbisBlood15_17$Age == "2nd/3rd year"] <- "J"
IbisBlood15_17$Age[IbisBlood15_17$Age == "3rd year"] <- "J"
IbisBlood15_17$Age[IbisBlood15_17$Age == "1st year"] <- "J"
IbisBlood15_17$Age[IbisBlood15_17$Age == "adult"] <- "A"
IbisBlood15_17$Age[IbisBlood15_17$Age == "2nd year"] <- "J"
IbisBlood15_17$Age[IbisBlood15_17$Age == "NA"] <- NA
IbisBlood15_17$Age[IbisBlood15_17$Age == "2nd Year"] <- "J"
IbisBlood15_17$Age[IbisBlood15_17$Age == "Late third year"] <- "J"
IbisBlood15_17$Age[IbisBlood15_17$Age == "ADULT"] <- "A"
IbisBlood15_17$Age[IbisBlood15_17$Age == "Adult bc"] <- "A" #Not sure what bc stands for

#Season and HabType are fine the way they are

####TotalRBC
IbisBlood15_17$TotalRBC <- as.numeric(IbisBlood15_17$TotalRBC)
#DIV/0 errors are now NA in this column

#NumHae column is fine

####HaeParasit
IbisBlood15_17$HaeParasit <- as.numeric(IbisBlood15_17$HaeParasit)

####-999 values
IbisBlood15_17[IbisBlood15_17 == -999] <- NA

####Removing the last couple empty rows
IbisBlood15_17 <- IbisBlood15_17[-c(401, 402, 403, 404, 405, 406),]

#This completes the cleaning phase for IbisBlood15_17
#------------------------------------------------------------------------------------#

######################### #Cleaning the rdIbisField Data###############################

IbisField <- rename(rdIbisField, ID = ID..NSFSITE...) #renames the ID column

#Selecting the columns of interest to this analysis from the datasheet
IbisField <- select(IbisField,ID,Site.Name,Latitude,Longitude,Date,PCR.Sex,Age,Season,
                    Habitat.type,Ibis.number,Mass.bird..g.,Body.condition.score..1.5.,
                    Ectoparasite.score..1.5.,Culmen.length..mm.,Wing.chord.length..mm.,
                    Tarsus.length..mm.,Tarsus.width..mm.,Habituation.score.of.flock..1.5.)

#Renaming the columns of interest, also matching the other cleaned datasets
IbisField <- rename(IbisField,Site = Site.Name,Lat = Latitude,Long = Longitude,Sex = PCR.Sex,
                    HabType = Habitat.type,IbisNum = Ibis.number,BirdMassG = Mass.bird..g.,
                    BodyCondScore = Body.condition.score..1.5.,EctoParasitScore = Ectoparasite.score..1.5.,
                    CulmenLmm = Culmen.length..mm.,WingChordLmm = Wing.chord.length..mm.,
                    TarsusLmm = Tarsus.length..mm.,TarsusWmm = Tarsus.width..mm.,HabFlockScore = Habituation.score.of.flock..1.5.)

#This dataset has "-999" values which mean they are intentionally left blank,
#Birds with an ID number of "-999" represent sites that didn't catch any birds,
#but had weather data collected. This code deletes those observations.
IbisField <- IbisField[!(IbisField$ID == "-999"),]

####Site
#These site location abbreviations are the same across datasets
IbisField$Site[IbisField$Site == "Busch Wildlife Sanctuary"] <- "BWS"
IbisField$Site[IbisField$Site == "Cat House (Bonnie's, Richard Lane)"] <- "CAT"
IbisField$Site[IbisField$Site == "Dubois Park"] <- "DUP"
IbisField$Site[IbisField$Site == "DuBois Park"] <- "DUP"
IbisField$Site[IbisField$Site == "Dreher Park"] <- "DRP"
IbisField$Site[IbisField$Site == "Fisheating Creek"] <- "FC"
IbisField$Site[IbisField$Site == "Green Cay"] <- "GC"
IbisField$Site[IbisField$Site == "Gaines Park"] <- "GP"
IbisField$Site[IbisField$Site == "Indian Creek"] <- "ICP"
IbisField$Site[IbisField$Site == "Juno Beach"] <- "JB"
IbisField$Site[IbisField$Site == "Juno Beach "] <- "JB"
IbisField$Site[IbisField$Site == "J.W. Corbett Wildlife Management Area"] <- "JWC"
IbisField$Site[IbisField$Site == "Kitching Creek"] <- "KC"
IbisField$Site[IbisField$Site == "Lion Country Safari"] <- "LCS"
IbisField$Site[IbisField$Site == "Lake Worth"] <- "LW"
IbisField$Site[IbisField$Site == "Loxahatchee Slough"] <- "LOXS"
IbisField$Site[IbisField$Site == "Loxahatchee Wildlife Refuge"] <- "LOXWR"
IbisField$Site[IbisField$Site == "Loxahatchee/LILA Cell B2"] <- "LOXB2"
IbisField$Site[IbisField$Site == "Loxahatchee NE "] <- "LOXNE"
IbisField$Site[IbisField$Site == "Palm Beach Zoo"] <- "WPBZ"
IbisField$Site[IbisField$Site == "Royal Palm"] <- "RP"
IbisField$Site[IbisField$Site == "CROW Wildlife Rehabilitation Center"] <- "CROW"
IbisField$Site[IbisField$Site == "Solid Waste Authority"] <- "SWA"
IbisField$Site[IbisField$Site == "TetraTech"] <- "TT"

####Sex Column
#This replaces the -999 and FAIL values with NA. The IbisBlood datasheets carry more sex data for the birds
IbisField$Sex[IbisField$Sex == "FAIL"] <- NA

####Age Column
IbisField$Age[IbisField$Age == "Adult"] <- "A"
IbisField$Age[IbisField$Age == "3rd year"] <- "J"
IbisField$Age[IbisField$Age == "2nd year"] <- "J"
IbisField$Age[IbisField$Age == "1st year"] <- "J"
IbisField$Age[IbisField$Age == "NA"] <- NA
IbisField$Age[IbisField$Age == "Adult "] <- "A"
IbisField$Age[IbisField$Age == "2nd year "] <- "J"
IbisField$Age[IbisField$Age == "Juvenile"] <- "J"
IbisField$Age[IbisField$Age == "2nd Year"] <- "J"

#Replacing all -999 values in the dataset with NA
IbisField[IbisField == -999] <- NA

#Replacing NA text strings with regular NA values in multiple columns
IbisField$BodyCondScore[IbisField$BodyCondScore == "NA"] <- NA
IbisField$HabFlockScore[IbisField$HabFlockScore == "NA"] <- NA
IbisField$CulmenLmm[IbisField$CulmenLmm == "NA"] <- NA
IbisField$WingChordLmm[IbisField$WingChordLmm == "NA"] <- NA
IbisField$TarsusLmm[IbisField$TarsusLmm == "NA"] <- NA
IbisField$TarsusWmm[IbisField$TarsusWmm == "NA"] <- NA

#--------------------------------------------------------------------------------------#

###############################Saving the Cleaned Datasets###########################

#Saving the Ibis Blood 10-14 dataset as an RDS in the processed data folder
save_data_location <- here::here("processed_data", "processedIbisBlood10_14.rds")
saveRDS(IbisBlood10_14, file = save_data_location)

#Saving the Ibis Blood 15-17 dataset as an RDS in the processed data folder
save_data_location2 <- here::here("processed_data", "processedIbisBlood15_17.rds")
saveRDS(IbisBlood15_17, file = save_data_location2)

#Saving the Ibis Field dataset as an RDS in the processed data folder
save_data_location3 <- here::here("processed_data", "processedIbisFielddata.rds")
saveRDS(IbisField, file = save_data_location3)


