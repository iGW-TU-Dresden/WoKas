# R code for downloading spring (karst) discharge observations from 
# Agencija Republike Slovenije Za Okolje of Slovenia online data portal
# Author: Tunde Olarinoye
# Institute: University of Freiburg, Germany
# Email: tunde.olarinoye@hydmod.uni-freiburg.de

# Note: set encoding to UTF-8

Sys.setenv(LANGUAGE="en")

# required packages
library("rvest")
library("XML")
library("httr")
library("RHTMLForms")

# set base dir
basePath ='./'
sourceModule <- paste0(basePath, 'sourceModules/')
source(paste0(sourceModule,'fileIO.R'))

##============================================
##                  SECTION 1               ==
##    Download spring discharge datasets    ==
##============================================
# download url base link
baseUrl <- "https://vode.arso.gov.si/hidarhiv/pov_arhiv_tab.php?"

# download query strings
queryString1 <- "p_vodotok="  # station name
queryString2 <- "&p_postaja="  # guage station id
queryString3 <- "&p_od_leto="  # measurement start year
queryString4 <- "&p_do_leto="  # measurement end year
queryString5 <- "&b_oddo_CSV=Izvoz+dnevnih+vrednosti+v+CSV"

# get gauge station information
wokasRDS <- readRDS(paste0(sourceModule,"/station_info.rds"))
stationInfo <- subset(wokasRDS, ISO == "SI" & Source_type == "O" )

sprNames <- lapply(stationInfo$Name, function(x){unlist(strsplit(x, "-"))[1]})
gaugeStn <- lapply(stationInfo$Name, function(x){unlist(strsplit(x, "-"))[2]})
stnIDs <- as.character(stationInfo$Local_database_ID)

# create folder to download datasets
outfolder <- paste0(basePath,"tmp_ARSO")
dir.create(outfolder)

# get recording years, start and end years 
getForms <- list(); p_od_leto <- list(); p_do_leto <- list()

linksUrl <- lapply(paste0(baseUrl, queryString1, sprNames), function(x){URLencode(x)})

DownloadlinksUrl <-lapply(paste0(baseUrl, queryString1, sprNames, queryString2, stnIDs), function(x){URLencode(x)})
# for each recording years url link
for(i in 1:length(linksUrl)){
  url = DownloadlinksUrl[[i]]
  # Read HTML content from the URL
  html_content <- read_html(url)
  
  # Extract forms from the HTML content
  forms <- html_form(html_content)
  
  # get HTML form which contains recording years
  yearForm <- forms[[2]]$fields$p_leto$options
  

  # select recording start year
  startYear <- yearForm[[1]]
  
  # select recording end year
  endYear <- yearForm[[length(yearForm)]]
  
  # start and end year query strings
  p_od_leto <- c(p_od_leto, startYear)
  p_do_leto <- c(p_do_leto, endYear)
}


# complete datasets download url
downloadUrls <- paste0(DownloadlinksUrl, queryString3, p_od_leto, queryString4, p_do_leto, queryString5)

# for each download url link
for(i in 1:length(downloadUrls)){
  
  # send a http GET request for download page
  rGet <- GET(downloadUrls[i], progress())
  
  # show message if page is not loaded
  if(rGet$status!=200){
    cat("problem while requesting download page from", downloadUrls[i])
    next
  }
  # set name to save csv file
  fileName <- paste0(stnIDs, "@", sprNames, ".csv")
  
  # download and save csv file
  download.file(downloadUrls[i], destfile = paste0(outfolder, "/", fileName[i]), mode = "wb", quiet = F)
}

##====================================================================
##                            SECTION 2                             ==
##    Refine datasets: select relevant columns and Homogenization   ==
##====================================================================
# get all downloaded csv files
dataFiles <- list.files(outfolder, pattern = ".csv")

# for every csv file
for(i in 1:length(dataFiles)){
  
  # read content of csv file
  springData <- read.csv(paste0(outfolder, "/", dataFiles[i]), sep = ";", 
                         header = T, stringsAsFactors = F, 
                         col.names=c("date","level(cm)","discharge","temperature",
                                     "transport suspendiranega materiala (kg/s)",
                                     "vsebnost suspendiranega materiala (g/m3)",
                                     "motnost vode (NTU)"))
  
  # create metadata list
  arsoID <- unlist(strsplit(dataFiles[i],"@"))[1]
  wokasMeta <- subset(stationInfo, stationInfo$Local_database_ID == arsoID )
  
  metaData <- list(id = as.character(arsoID),
                   newID = wokasMeta$Location.Identifier,
                   name = wokasMeta$Name,
                   source = "Agencija Republike Slovenije Za Okolje (ARSO) Slovenia",
                   sourceUrl = "http://vode.arso.gov.si/hidarhiv/pov_arhiv_tab.php?",
                   LAT = as.numeric(wokasMeta$Latitude),
                   LON = as.numeric(wokasMeta$Longitude),
                   unit = "m^3/s")
  
  fileIO.writeSpringData(springData[,c("date","discharge")], metaData)

}
# delete dir


## -- end

