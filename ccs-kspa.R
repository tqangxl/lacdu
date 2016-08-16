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
call.orders <- 'https://handler.twilio.com/twiml/EH56709c45c2257c8bafc795db138c5190'
load('.twilio-kspa.RData')
office.email <- 'spagan@kippcolorado.org; rcozens@kippcolorado.org; rmolinar@kippcolorado.org; psetter@kippcolorado.org'
#office.email <- 'psetter@kippcolorado.org'
if(num.calls > 0) source('3-call.R')

# Email report
staff.email <- 'kservis@kippcolorado.org; rcozens@kippcolorado.org; mgoble@kippcolorado.org; jlevy@kippcolorado.org; psetter@kippcolorado.org'
#staff.email <- 'psetter@kippcolorado.org'
source('4-email.R')

source('5-database.R')

# Clean-up
#rm(list = ls())