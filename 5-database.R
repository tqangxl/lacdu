# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Insert records from the past 24 hours into database

# Source: https://github.com/hadley/dplyr/issues/857
# Handle escape error 
escape.POSIXt <- dplyr:::escape.Date

# Connect to database
kippco.db <- src_postgres('kippco')

current.date <- as.POSIXct(Sys.Date() - 4)

indb <- tbl(kippco.db, 'liveschool') %>% 
    filter(entry_time >= current.date) %>% 
    collect()

ls.insert <- ls.df %>%
    select(conduct_id,
           student_id = student_number,
           user_id = user_number,
           standard_name,
           behavior_name,
           behavior_points = behavior_amount,
           comments = conduct_comment,
           entry_time) %>%
    anti_join(indb, by = 'conduct_id')

# Insert new values
db_insert_into(kippco.db$con, 'liveschool', ls.insert)
