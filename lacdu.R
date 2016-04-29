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
# Extract Data
source('1-get.R')

# Transform the data
source('2-transform.R')

# Make calls 
source('3-call.R')

# Email report
source('4-email.R')

# Insert ls.insert into the liveschool table
source('5-database.R')