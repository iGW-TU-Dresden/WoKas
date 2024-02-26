# R code for downloading spring (karst) discharge 
# observations from eHYD online data portal, Austria
# Author: Tunde Olarinoye
# Institute: University of Freiburg, Germany
# Email: tunde.olarinoye@hydmod.uni-freiburg.de

Sys.setenv(LANGUAGE="en")

library(XML)
library(httr)

basePath = "./"
sourceModule = paste0(basePath, 'sourceModules/')
source(paste0(sourceModule, 'fileIO.R'))

##==============================================================
##                          SECTION 1                         ==   
##    Download spring discharge datasets from eHYD database   ==
##==============================================================
# url link to download data
# the base url requires additional query string
baseUrl <- "https://ehyd.gv.at/eHYD/MessstellenExtraData/qu?id=" 

# eHYD station names and IDs
wokasRDS <- readRDS(paste0(sourceModule,"/station_info.rds"))
stationInfo <- subset(wokasRDS, ISO == "AT" & Source_type == "O")

# create folder to download datasets
outfolder <- paste0(basePath,"tmp_eHYD")
dir.create(outfolder)

# for each eHYD station
for (i in 1:nrow(stationInfo)) {
  # get download url link
  downloadUrl <- sprintf(paste0(baseUrl,"%s&file=3"),stationInfo$Local_database_ID[i])
  
  # use http GET request to to access page redirect for download 
  getData <- GET(downloadUrl, progress())
  
  # check for download request error
  if(getData$status!=200) {
    cat("problem while requesting download :(")
    next
  }
  
  # create file name
  fileName <- paste0(stationInfo$Local_database_ID[i], '@', stationInfo$Name[i], '.csv')
  
  # download dataset
  download.file(downloadUrl, destfile = paste0(outfolder, "/", fileName), mode = "wb", quiet = F)
}

##==========================================================
##                        SECTION 2                       ==
##    Format downloaded datasets and homogenization       ==
##==========================================================

# list downloaded csv files in directory
dataFiles <- list.files(outfolder, pattern = '.csv')

# for every csv file in baseFile dir
for(i in 1:length(dataFiles)){
  #i=1
  
  skip_no <- grep("Werte:",readLines(paste0(outfolder, "/", dataFiles[i])))
  if(length(skip_no)==0)
    next
  
  #read csv file
  springData <- read.csv(paste0(outfolder, "/", dataFiles[i]), sep = ";", header = F, dec = ',', 
                         stringsAsFactors = F, skip = skip_no, encoding = "UTF-8")[,1:2]
  colnames(springData) = c("date", "discharge")
  
  # Convert encoding of the discharge column to UTF-8
  springData$discharge <- iconv(springData$discharge, to = "UTF-8", sub = "byte") # delete non-numeric values
  
  # Replace non-numeric values
  springData$discharge <- gsub("[^0-9.]+", "", springData$discharge) # delete non-numeric values
  
  springData$discharge <- gsub("L<fc>cke", "", springData$discharge)
  
  # select, rename and convert discharge observations to m3/s
  springData$discharge <- as.numeric(gsub(",",".",springData$discharge)) * 0.001
  
  # read csv file to extract coordinates
  r <- grep("Geographische", readLines(paste0(outfolder, "/", dataFiles[i])))
  if(r>0){
    coordData <- read.csv(paste0(outfolder, "/", dataFiles[i]), sep = ";", header = T, dec = ',', stringsAsFactors = F, skip=r, nrows=1, col.names=c("timestamp","lon","lat"))
    
    # convert cordinates from dms to dec
    dms2dec <- function(angle) {
      angle <- as.character(angle)
      x <- do.call(rbind, strsplit(angle, split=' '))
      x <- apply(x, 1L, function(y) {
        y <- as.numeric(y)
        y[1] + y[2]/60 + y[3]/3600
      })
      return(x)
    }
    lon <- dms2dec(coordData$lon)
    lat <- dms2dec(coordData$lat)
    
  }else{
    lon <- NULL
    lat <- NULL
  }
  
  # create metadata list
  ehydID = unlist(strsplit(dataFiles[i],"@"))[1]
  wokasMeta <- subset(stationInfo, Local_database_ID == ehydID)
  
  metaData <- list(id = as.character(ehydID),
                   newID = wokasMeta$Location.Identifier,
                   name = wokasMeta$Name,
                   source = "eHYD Bundesministerium Nachhaltigkeit und Tourismus",
                   sourceUrl = "https://ehyd.gv.at/#",
                   LAT = lat,
                   LON = lon,
                   unit = "m^3/s")
  
  fileIO.writeSpringData(springData, metaData)
}

#remove the original csv file
unlink(outfolder, recursive = T)

## end --

