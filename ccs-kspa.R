# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# ETL LiveSchool data for automated calls and loading into database

# Used to demark current run in stdout
print(Sys.Date())


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
# Extract Data
load('.KSPA-LS.RData')
source('1-get.R')

# Transform the data
source('2-transform-kspa.R')

num.calls <- nrow(afterschool)

# Make calls
# Reference to TWIML file with instructions
call.orders <- 'https://handler.twilio.com/twiml/EH0a4d09a9a77bf90af8c63114d59932f6'
load('.twilio-kspa.RData')
if(num.calls > 0) source('3-call.R')

# Email report
#staff.email <- 'kspa_staff@kippcolorado.org'
staff.email <- 'psetter@kippcolorado.org'
source('4-email.R')

# Insert ls.insert into the liveschool table
#source('5-database.R')