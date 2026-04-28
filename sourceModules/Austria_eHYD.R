# R code for downloading spring (karst) discharge 
# observations from new eHYD package download, Austria

Sys.setenv(LANGUAGE = "en")

library(XML)
library(httr)

basePath <- "./"
sourceModule <- paste0(basePath, "sourceModules/")
source(paste0(sourceModule, "fileIO.R"))

##==============================================================
## SECTION 1: Download full eHYD spring discharge package
##==============================================================

downloadUrl <- "https://gis.lfrz.gv.at/api/ehyd/messstellen/paket/ehyd_messstellen_all_qu.zip"

wokasRDS <- readRDS(paste0(sourceModule, "/station_info.rds"))
stationInfo <- subset(wokasRDS, ISO == "AT" & Source_type == "O")

outfolder <- paste0(basePath, "tmp_eHYD")
if (!dir.exists(outfolder)) {
  dir.create(outfolder, recursive = TRUE)
}

zipfile <- file.path(outfolder, "ehyd_messstellen_all_qu.zip")

cat("Downloading eHYD spring discharge package...\n")
download.file(downloadUrl, destfile = zipfile, mode = "wb", quiet = FALSE)

cat("Unzipping package...\n")
unzip(zipfile, exdir = outfolder)

unlink(zipfile)

##==========================================================
## SECTION 2: Format downloaded datasets and homogenization
##==========================================================

dataFiles <- list.files(
  outfolder,
  pattern = "\\.csv$",
  recursive = TRUE,
  full.names = TRUE
)

if (length(dataFiles) == 0) {
  stop("No CSV files found after unzipping the eHYD package.")
}

cat("Found", length(dataFiles), "CSV files.\n")

dms2dec <- function(angle) {
  angle <- as.character(angle)
  angle <- gsub("[°'\"NSEW]", " ", angle)
  angle <- gsub(",", ".", angle)
  angle <- trimws(angle)
  
  x <- strsplit(angle, "\\s+")
  
  sapply(x, function(y) {
    y <- as.numeric(y)
    y <- y[!is.na(y)]
    
    if (length(y) >= 3) {
      y[1] + y[2] / 60 + y[3] / 3600
    } else if (length(y) == 1) {
      y[1]
    } else {
      NA_real_
    }
  })
}

for (i in seq_along(dataFiles)) {
  
  file_path <- dataFiles[i]
  file_base <- basename(file_path)
  
  cat("Processing:", file_base, "\n")
  
  lines <- readLines(file_path, warn = FALSE, encoding = "UTF-8")
  
  skip_no <- grep("Werte:", lines)
  if (length(skip_no) == 0) {
    cat("  skipped: no 'Werte:' section found\n")
    next
  }
  
  springData <- tryCatch({
    read.csv(
      file_path,
      sep = ";",
      header = FALSE,
      dec = ",",
      stringsAsFactors = FALSE,
      skip = skip_no[1],
      encoding = "UTF-8"
    )[, 1:2]
  }, error = function(e) {
    cat("  skipped: cannot read data table\n")
    return(NULL)
  })
  
  if (is.null(springData)) next
  
  colnames(springData) <- c("date", "discharge")
  
  springData$discharge <- iconv(
    springData$discharge,
    to = "UTF-8",
    sub = "byte"
  )
  
  springData$discharge <- gsub(",", ".", springData$discharge)
  springData$discharge <- gsub("[^0-9.-]+", "", springData$discharge)
  springData$discharge <- as.numeric(springData$discharge) * 0.001
  
  r <- grep("Geographische", lines)
  
  if (length(r) > 0) {
    coordData <- tryCatch({
      read.csv(
        file_path,
        sep = ";",
        header = TRUE,
        dec = ",",
        stringsAsFactors = FALSE,
        skip = r[1],
        nrows = 1,
        col.names = c("timestamp", "lon", "lat")
      )
    }, error = function(e) NULL)
    
    if (!is.null(coordData)) {
      lon <- dms2dec(coordData$lon)
      lat <- dms2dec(coordData$lat)
    } else {
      lon <- NA_real_
      lat <- NA_real_
    }
  } else {
    lon <- NA_real_
    lat <- NA_real_
  }
  
  id_candidates <- regmatches(
    file_base,
    gregexpr("[0-9]+", file_base)
  )[[1]]
  
  ehydID <- NA_character_
  
  for (candidate in id_candidates) {
    if (candidate %in% as.character(stationInfo$Local_database_ID)) {
      ehydID <- candidate
      break
    }
  }
  
  if (is.na(ehydID)) {
    cat("  skipped: station ID not found in station_info.rds\n")
    next
  }
  
  wokasMeta <- subset(
    stationInfo,
    as.character(Local_database_ID) == as.character(ehydID)
  )
  
  if (nrow(wokasMeta) == 0) {
    cat("  skipped: no matching WoKaS metadata\n")
    next
  }
  
  metaData <- list(
    id = as.character(ehydID),
    newID = wokasMeta$Location.Identifier[1],
    name = wokasMeta$Name[1],
    source = "eHYD Bundesministerium Nachhaltigkeit und Tourismus",
    sourceUrl = "https://ehyd.gv.at/#",
    LAT = lat,
    LON = lon,
    unit = "m^3/s"
  )
  
  fileIO.writeSpringData(springData, metaData)
}

unlink(outfolder, recursive = TRUE)

cat("Finished processing eHYD Austria spring discharge data.\n")

