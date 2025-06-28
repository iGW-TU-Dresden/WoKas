# WoKaS: World Karst Spring Hydrograph Database 

## Instructions for Running the R Code to Download Karst Spring Discharge Datasets on Windows

1. Copy/Save the Auto_Download_Routine folder to your preferred location on your computer. This location will be set as your working directory to run the R code.
- For example, if you copy/save the folder to "D:/Auto_Download_Routine," your working directory will be "D:/Auto_Download_Routine."
- Alternatively, if you copy/save it to "C:/Users/Hydro/Desktop/Auto_Download_Routine," your working directory will be "C:/Users/Hydro/Desktop/Auto_Download_Routine."

2. The Auto_Download_Routine folder contains a sub-folder named "sourceModules," an R file named "download.R," and this read_me.txt file.
- The "sourceModules" folder contains ".R", ".csv", ".txt", and ".rds" files, which must not be modified.

3. The "download.R" file in the main Auto_Download_Routine folder is linked to the required scripts in the "sourceModules" folder to handle the download process.

4. A stable internet connection is required, and the computer should not be shut down or put into sleep mode while the download is running. Depending on the speed of your internet connection, it may take between 2 to 2.5 hours to download all (over 200) datasets.

Before running the "download.R" file, the R program must be installed on your computer. Follow the steps below to install R and run the R code:

### i. Install R program

1. R: Download and install R by following the link that corresponds to your operating system Windows, Mac, or Linux: *https://cran.r-project.org/*
2. RStudio: RStudio is an application that assists you in writing R code. You can download it from: *https://posit.co/downloads/*
Once you have both R and RStudio installed on your computer, you can begin using R by opening the RStudio program. For more information, visit: *https://rstudio-education.github.io/hopr/starting.html*

### ii. Running R Code

There are several ways to run R code. Below are three (3) options:

**1. R Graphical User Interface (Rgui):**

The Rgui application can be found in the R program installation path, for example: "C:\Program Files\R\R-4.4.0\bin\x64".

- From Rgui, import the "download.R" file.
- Check if the working directory is correct by typing and running getwd() in the Rgui editor to get the current working directory.
- If the directory is incorrect, type and run setwd("Your folder path") to set the correct working directory.
- Once the working directory is set, run the "download.R" file.

**2. RStudio:**

Download RStudio from https://www.rstudio.com. It is also available as part of the Anaconda distribution (https://www.anaconda.com).

- Import the "download.R" file into the RStudio code editor and set the working directory as described previously.
- Once the working directory is set, run the download script.

**3. Windows Command Prompt:**

- Add the R program file path (e.g., "C:\Program Files\R\R-4.4.0\bin") to the System Variables path.
    - Go to Control Panel > System and Security > System > Advanced System Settings > Advanced > Environment Variables (in System Variables, select 'Path' and click on 'Edit').
    - In the Edit Environment Variable window, click 'New' and type in the R program file path (e.g., "C:\Program Files\R\R-3.5.2\bin"), then click 'OK.'
- Open the Windows Command Prompt (cmd) and type 'R.' If the path was added successfully, it will display information about the R program.
- From the command prompt, navigate to the directory containing the required files (ensure that the directory contains the "sourceModules" sub-folder, "download.R," and "read_me.txt").
- In the command prompt, type Rscript download.R and press [Enter] to start the process.

A message saying "All datasets download and processing have been completed" will appear at the end of the download process. 
The downloaded discharge datasets will be saved in a sub-folder named "data," which is created during the download process.

## About the scripts

- **Data Sources for Karst Spring Discharge Observations**

eHYD Bundesministerium Nachhaltigkeit und Tourismus (Austria), Banque Hydro (France), Gewässerkundlicher Dienst Bayern (GKD Bavaria) (Germany), Environmental Protection Agency (EPA) (Ireland), Agencija Republike Slovenije Za Okolje (ARSO) (Slovenia), UK National River Flow Archive (UK), and USGS National Water Information System (US). 

When datasets from eHYD Bundesministerium Nachhaltigkeit und Tourismus (Austria), Banque Hydro (France), Landesanstalt für Umwelt Baden-Württemberg (Germany), and the UK National River Flow Archive (UK) are used, users should provide appropriate references to the respective database(s).

- **Downloading French Karst Spring Discharge Data from Banque Hydro**

Users are required to register on www.hydro.eaufrance.fr and request personalized login details to access data downloads from Banque Hydro. After successful registration and receipt of the login details, replace the pre-filled username and password below with your new login credentials. This information is extracted by the R code for data download.

Note that the pre-filled login information below is only for test/trial purpose.

Username = ****** Password = ******

- **Direct Download of Preprocessed Datasets from Umweltinformationssystem Baden-Württemberg UDO**

The module for downloading datasets from the UDO portal is currently not working. However, preprocessed datasets up to September 2024 can be found at the following link: 
*https://shorturl.at/rBdo0*

## Author Reference

Olarinoye, T., Gleeson, T., Marx, V. et al. Global karst springs hydrograph dataset for research and management of the world’s fastest-flowing groundwater. 
Sci Data 7, 59 (2020). https://doi.org/10.1038/s41597-019-0346-5

## Questions

Please contact:

Andreas Hartmann | andreas.hartmann@tu-dresden.de
