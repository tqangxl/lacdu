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

all.calls <- afterschool

# Make calls
# Reference to TWIML file with instructions
office.email <- 'psetter@kippcolorado.org'

# Office Hours
afterschool <- all.calls %>%
    filter(consequence == 'Office Hours')
num.calls <- nrow(afterschool)

call.orders <- 'https://handler.twilio.com/twiml/EH1b6af133e8c0038ce11d7df088aa2a9a'
load('.twilio-kdchs.RData')
if(num.calls > 0) source('3-call.R')

# Detention
afterschool <- all.calls %>%
    filter(consequence != 'Office Hours')

num.calls <- nrow(afterschool)


call.orders <- 'https://handler.twilio.com/twiml/EH3d798e75f8e2b1956cdcc270317aa24a'
load('.twilio-kdchs.RData')

if(num.calls > 0) source('3-call.R')

# Email report
staff.email <- 'nzamora@kippcolorado.org; cramirez@kippcolorado.org; awykowski@kippcolorado.org; psetter@kippcolorado.org'
source('4-email.R')

source('5-database.R')

# Clean-up
rm(list = ls())