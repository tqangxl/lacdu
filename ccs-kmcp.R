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

num.calls <- nrow(afterschool)

# Make calls
# Reference to TWIML file with instructions
call.orders <- 'https://handler.twilio.com/twiml/EH680c5a2f9c14b8a8d559af6f5a3eb988'
load('.twilio-kmcp.RData')
office.email <- 'iflores@kippcolorado.org; dloveall@kippcolorado.org; psetter@climb.kippcolorado.org'
#if(num.calls > 0) source('3-call.R')

# Email report
#staff.email <- 'kmcp_staff@kippcolorado.org'
staff.email <- 'iflores@kippcolorado.org; dloveall@kippcolorado.org; psetter@kippcolorado.org'
source('4-email.R')

source('5-database.R')

# Clean-up
rm(list = ls())