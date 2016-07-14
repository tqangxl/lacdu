# Consequence Communication System

This script is a proof-of-concept and under development. It has not be tested in production.

### Tasks
This script performs the following tasks:

1. Obtains behavior data from [LiveSchool](http://www.liveschoolinc.com) through their API
2. Determines which students earned the after-school consequence.
3. Calls and texts the families of the students using [Twilio](http://www.twilio.com) and emails using gmailr
4. Emails the list of students to school staff
5. Inserts data from the last 24 hours into a database

### System

These scripts were written and tested using 

R version 3.2.3 (2015-12-10)

Platform: x86_64-redhat-linux-gnu

### Software

- [`gmailr`](https://github.com/jimhester/gmailr) must be connected to a Gmail account. 
- [`RPostgreSQL`](https://code.google.com/p/rpostgresql/) must be installed, which depends on `postgresql-devel`.
- [`httr`](https://github.com/hadley/httr) must be installed, which depends on `openssl-devel` and `libcurl-devel`.
- Response objects from Twilio are in xml. In printing requires the [`xml2`](	https://github.com/hadley/xml2) package, which depends on `libxml2-devel`
- This script connects to a PostgreSQL database called "kippco" with a table named "liveschool".   
- There are several files in this script that store authentication objects.
- Making phone calls with Twilio requires an [TwiML](https://www.twilio.com/docs/api/twiml) file accessible via a public url. The file twiml-test.xml is hosted on Github.