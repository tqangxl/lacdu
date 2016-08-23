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
load('.KMCP-LS.RData')
source('1-get.R')

# Transform the data
source('2-transform-kmcp.R')

all.calls <- afterschool
office.email <- 'iflores@kippcolorado.org; dloveall@kippcolorado.org; psetter@climb.kippcolorado.org'
load('.twilio-kmcp.RData')

# BND
afterschool <- all.calls %>%
    filter(consequence == 'BND')

if(weekdays(Sys.Date()) == 'Tuesday') {
    call.orders <- 'https://handler.twilio.com/twiml/EHb1e71ddc4e494794cdd4738fcfab3fc3'
} else {
    call.orders <- 'https://handler.twilio.com/twiml/EH33abe4d04ac41abfda62e8ad4a18fc57'
}

if(nrow(afterschool) > 0) source('3-call.R')

# HWC
afterschool <- all.calls %>%
    filter(consequence != 'BND')

call.orders <- 'https://handler.twilio.com/twiml/EH2244639c24b4a1acc65cf547820b1c12'

if(nrow(afterschool) > 0) source('3-call.R')

# Email report
staff.email <- 'iflores@kippcolorado.org; dloveall@kippcolorado.org; psetter@kippcolorado.org'
source('4-email.R')

source('5-database.R')

# Clean-up
rm(list = ls())
