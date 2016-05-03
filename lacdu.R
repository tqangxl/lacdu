# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# ETL LiveSchool data for automated calls and loading into database

########
# Library Calls
library(httr)
library(dplyr)
library(lubridate)
library(gmailr)

########
# Function Definitions
CallHelp <- function(message) {
    send_message(mime(from = 'data@climb.kippcolorado.org',
                      to = 'psetter@kippcolorado.org',
                      subject = message))
}


########
print(Sys.Date())

# Extract Data
source('1-get.R')

# Transform the data
source('2-transform.R')

num.calls <- nrow(daily.wallstreet)

# Make calls 
if(num.calls > 0) source('3-call.R')

# Email report
source('4-email.R')

# Insert ls.insert into the liveschool table
source('5-database.R')