# lacdu
LiveSchool Auto-Call and Database Update

This script is a proof-of-concept and under development. It has not be tested in production.

### Tasks
This script performs the following tasks:

1. Obtains behavior data from [LiveSchool](http://www.liveschoolinc.com) through their API
2. Determines which students earned the after-school consequence. (Wall Street)
3. Calls the families of the students using [Twilio](http://www.twilio.com)
4. Emails the list of students to school staff
5. Inserts data from the last 24 hours into a database

### System

These scripts were written and tested using 

R version 3.2.3 (2015-12-10)

Platform: x86_64-redhat-linux-gnu

### Software

- `gmailr` must be connected to a Gmail account. 
- `RPostgreSQL` must be installed, which depends on `postgresql-devel`.
- `httr` depends on `openssl-devel` and `libcurl-devel`.
- Response objects from Twilio are in xml. In printing requires the `xml2` package, which depends on `libxml-devel`
- This script connects to a PostgreSQL database with a table named "liveschool".   
- There are several files in this script that store authentication objects.
- Making phone calls with Twilio requires an TWIML file accessible via a public url. The file twiml-test.xml is hosted on Github.