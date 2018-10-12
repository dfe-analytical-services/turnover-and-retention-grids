#load packages

library(dplyr)
library(readr)
library(RODBC)
library(dfeR)

myconn1 <-RODBC::odbcDriverConnect(
  paste0("driver={SQL Server};server=","3DCPRI-PDB16\\ACSQLS",";database=", "SWFC_Project", ";trusted_connection=TRUE")
)

# Run code
sqlString1 <- read_sql_script("Queries/Retention Grids.sql")

# Store output
data_for_retention_grids <- RODBC::sqlQuery(myconn1,sqlString1)
data_for_retention_grids <- subset(data_for_retention_grids, NQT_Year < 2017)

# Return Output
readr::write_rds(data_for_retention_grids, "Data/data_for_retention_grids.rds")
readr::write_csv(data_for_retention_grids, "Data/data_for_retention_grids.csv")

# Close connection
RODBC::odbcClose(myconn1)

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------

myconn2 <-RODBC::odbcDriverConnect(
  paste0("driver={SQL Server};server=","3DCPRI-PDB16\\ACSQLS",";database=", "TAD_UserSpace", ";trusted_connection=TRUE")
)


# Run code
sqlString2 <- read_sql_script("Queries/Leavers by Subjects.sql")

# Store output
data_leavers <- RODBC::sqlQuery(myconn2,sqlString2)

#Reformat data so all combinations of factors are included, even if the result is 0.
y <- expand.grid(unique(data_leavers$CensusYear),
                 unique(data_leavers$Subject),
                 unique(data_leavers$Gender),
                 unique(data_leavers$AgeGroup),
                 unique(data_leavers$QualifiedLeaverType))

names(y)[1]<-paste("CensusYear")
names(y)[2]<-paste("Subject")
names(y)[3]<-paste("Gender")
names(y)[4]<-paste("AgeGroup")
names(y)[5]<-paste("QualifiedLeaverType")

data_leavers <- 
  left_join(y, data_leavers, 
            by=c("CensusYear", "Subject", "Gender", "AgeGroup",
                 "QualifiedLeaverType")) 
data_leavers$StockSize[is.na(data_leavers$StockSize)] <- 0

#Reformat CensusYear to be consistent with SWC publication
data_leavers$CensusYear <- data_leavers$CensusYear +1 
data_leavers <- subset(data_leavers, CensusYear < 2018)

# Return Output
readr::write_rds(data_leavers, "Data/data_leavers.rds")
# Create data for publication
readr::write_csv(data_leavers, "Data/data_leavers.csv")

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# Run code
sqlString3 <- read_sql_script("Queries/Entrants by Subjects.sql")

# Store output
data_entrants <- RODBC::sqlQuery(myconn2,sqlString3)

#Reformat data so all combinations of factors are included, even if the result is 0.
z <- expand.grid(unique(data_entrants$CensusYear),
                 unique(data_entrants$Subject),
                 unique(data_entrants$Gender),
                 unique(data_entrants$AgeGroup),
                 unique(data_entrants$QualifiedEntrantType))

names(z)[1]<-paste("CensusYear")
names(z)[2]<-paste("Subject")
names(z)[3]<-paste("Gender")
names(z)[4]<-paste("AgeGroup")
names(z)[5]<-paste("QualifiedEntrantType")

data_entrants <- 
  left_join(z, data_entrants, 
            by=c("CensusYear", "Subject", "Gender", "AgeGroup",
                 "QualifiedEntrantType")) 
data_entrants$StockSize[is.na(data_entrants$StockSize)] <- 0

data_entrants<- subset(data_entrants, CensusYear > 2010)

# Return Output
readr::write_rds(data_entrants, "Data/data_entrants.rds")
# Create data for publication
readr::write_csv(data_entrants, "Data/data_entrants.csv")

# Close connection
RODBC::odbcClose(myconn2)

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

