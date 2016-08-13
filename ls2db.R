# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# BOY update of LiveSchool data

# Library
library(dplyr)
library(httr)
library(RODBC)
library(lubridate)

# Functions
Logout <- function(url) {
    for(i in 1:5) {
        logout <- GET(url)
        if(logout$status == 200) return(0)
        Sys.sleep(30)
    }
    CallHelp('Cannot logout of LiveSchool.')
    stop('Cannot logout of LiveSchool.')
}

#Global Variables
escape.POSIXt <- dplyr:::escape.Date

logout.url <- 'https://admin.liveschoolinc.com/logout'

load('.login.RData')

Logout(logout.url)

kippco <- src_postgres('kippco')

for(i in 1:nrow(login.info)) {
    LS.username <- as.character(login.info[i, 1])
    LS.password <- as.character(login.info[i, 2])
    
    
    
    login <- POST('https://admin.liveschoolinc.com/', 
                 body = list(username = LS.username, password = LS.password))
    
    api.call <- paste0('https://admin.liveschoolinc.com/api?action=genericconducts2&mode=reports&from=', 
                       Sys.Date() - 6, '&to=', Sys.Date() + 1)
    
    ls.data <- GET(api.call)

    Logout(logout.url)
    
    source('2-transform.R')
    
    ls.insert <- ls.df %>%
        select(conduct_id,
               student_id = student_number,
               user_id = user_number,
               standard_name,
               behavior_name,
               behavior_points = behavior_amount,
               comments = conduct_comment,
               entry_time)
    
    db_insert_into(kippco$con, 'liveschool', ls.insert)
    
    rm(ls.insert)
}