# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Insert records from the past 24 hours into database

# Source: https://github.com/hadley/dplyr/issues/857
# Handle escape error 
escape.POSIXt <- dplyr:::escape.Date

# Connect to database
kippco.db <- src_postgres('kippco')

# Insert new values
db_insert_into(kippco.db$con, 'liveschool', ls.insert)