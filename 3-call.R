# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Call families of students with Wall Street
# This code is for testing.
# TODO: Access table of primary contact numbers & merge onto list

load('.twilio.RData')
# Authenticate with Twilio

auth.request <- paste0('https://', twilio.sid, ':', twilio.token, 
                       '@api.twilio.com/2010-04-01/Accounts')

repeat {
    auth.response <- GET(auth.request)
    if(login$status == 200) break
    else print('Trying again...')
}

call.request <- paste0('https://api.twilio.com/2010-04-01/',
                       twilio.sid,
                       '/Calls')

call.response <- POST(call.request,
                      body = list(From = twilio.number,
                                  To = current.number,
                                  ApplicationSid = ))


# Clean-up
rm(twilio.sid, twilio.token, twilio.phonenumber)