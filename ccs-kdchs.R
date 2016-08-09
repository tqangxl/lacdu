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
load('.KDCHS-LS.RData')
source('1-get.R')

# Transform the data
source('2-transform-kdchs.R')

num.calls <- nrow(afterschool)

# Make calls
# Reference to TWIML file with instructions
call.orders <- 'https://handler.twilio.com/twiml/EHcb1dfb652469515869cfa30b50998f1f'
load('.twilio-kdchs.RData')
office.email <- 'psetter@kippcolorado.org; data@climb.kippcolorado.org'
#if(num.calls > 0) source('3-call.R')

# Email report
#staff.email <- 'kdchs_staff@kippcolorado.org'
staff.email <- 'psetter@kippcolorado.org'
source('4-email.R')

# Clean-up
rm(list = ls())