# lacdu
LiveSchool Auto-Call and Database Update

This script is a proof-of-concept and under development. It has not be tested in production.

### Tasks
This script performs the following tasks:

1. Obtains behavior data from [LiveSchool](http://www.liveschoolinc.com) through their API
2. Determines which students earned the after-school consequence. (Wall Street)
3. Calls the families of the students
4. Emails the list of students to school staff
5. Inserts data from the last 24 hours into a database

### system

These scripts were written and tested using 

R version 3.2.3 (2015-12-10)

Platform: x86_64-redhat-linux-gnu

### Before You Start

`gmailr` must be connected to a Gmail account. This script connects to a PostgreSQL database with a table named "liveschool". `RPostgreSQL` must be installed, which depends on `postgresql-devel`. `httr` depends on `openssl-devel` and `libcurl-devel`. Calls are made using [Twilio](https://www.twilio.com). There are several files in this script that score authentication objects.

