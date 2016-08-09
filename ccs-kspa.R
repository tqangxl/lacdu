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
load('.KSPA-LS.RData')
source('1-get.R')

# Transform the data
source('2-transform-kspa.R')

num.calls <- nrow(afterschool)

# Make calls
# Reference to TWIML file with instructions
call.orders <- 'https://handler.twilio.com/twiml/EH350c11faa89d921d9299947c6cf890a1'
load('.twilio-kspa.RData')
office.email <- 'psetter@kippcolorado.org; data@climb.kippcolorado.org'
#if(num.calls > 0) source('3-call.R')

# Email report
#staff.email <- 'kspa_staff@kippcolorado.org'
staff.email <- 'psetter@kippcolorado.org'
source('4-email.R')

# Clean-up
rm(list = ls())