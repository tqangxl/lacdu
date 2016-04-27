# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Download LiveSchool points log

# Handle escape error 
escape.POSIXt <- dplyr:::escape.Date

# Connect to database
kippco.db <- src_postgres('kippco')

# Insert new values
db_insert_into(kippco.db$con, 'liveschool', ls.insert)