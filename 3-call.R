# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Call families of students with Wall Street
# This code is for testing and does not use acutal contact numbers.
# Source: https://dreamtolearn.com/ryan/data_analytics_viz/78

load('.twilio.RData')
# Authenticate with Twilio

auth.request <- paste0('https://', twilio.sid, ':', twilio.token, 
                       '@api.twilio.com/2010-04-01/Accounts')

repeat {
    auth.response <- GET(auth.request)
    if(login$status == 201) break
    else print('Trying again...')
}

# Build API request
call.request <- paste0(auth.request, '/',
                       twilio.sid,
                       '/Calls')

# Reference to TWIML file with instructions
call.orders <- 'https://raw.githubusercontent.com/peterwsetter/lacdu/master/twiml-test.xml'

# Merge primary phone numbers
# TODO: Add real numbers
# Number format: +11234567890

load('test-numbers.RData')

num.calls <- nrow(daily.wallstreet)

phonenumber <- rep(test.numbers, ceiling(num.calls / 3))[1:num.calls]

call.list <- daily.wallstreet %>%
    cbind(phonenumber)

for(i in 1:3) {        
    current.number <- call.list[i, 'phonenumber'] %>% as.character
        
    call.response <- POST(call.request,
                      body = list(From = twilio.phonenumber,
                                  To = current.number,
                                  Url = call.orders))
    # Printing the response requires the xml2 package
    if(call.response$status != 201) print(content(call.response))
}

# Clean-up
rm(twilio.sid, twilio.token, twilio.phonenumber)