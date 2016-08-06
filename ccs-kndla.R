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
library(kippco)

########
# Function Definitions
CallHelp <- function(message) {
    send_message(mime(from = 'noreply@climb.kippcolorado.org',
                      to = 'psetter@kippcolorado.org',
                      subject = message))
}


########
# Extract Data
load('.KNDLA-LS.RData')
source('1-get.R')

# Transform the data
source('2-transform-kndla.R')

num.calls <- nrow(afterschool)

# Make calls
# Reference to TWIML file with instructions
call.orders <- 'https://handler.twilio.com/twiml/EHa676baf2e7284276129c95ac9cb84aa0'
load('.twilio-kndla.RData')
office.email <- 'psetter@kippcolorado.org; data@climb.kippcolorado.org'
#if(num.calls > 0) source('3-call.R')

# Email report
#staff.email <- 'kndla_staff@kippcolorado.org'
staff.email <- 'psetter@kippcolorado.org'
source('4-email.R')