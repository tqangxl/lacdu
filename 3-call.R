# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Call families of students with Wall Street
# This code is for testing and does not use acutal contact numbers.
# Source: https://dreamtolearn.com/ryan/data_analytics_viz/78

########
## Function Definitions
CheckTwilioResponse <- function(response.object, current.student, current.number) {
    # Check if Twilio response status was successful
    if(response.object$status != 201) {
        # If not successful, determine if it was a call or SMS
        sms.or.call <- ifelse(is.null(response.object$request$fields$Body),
                              'Call',
                              'SMS')
        
        # Create useful failure notification
        failure.info <- paste(current.student, 
                              current.number,
                              sms.or.call,
                              response.object$status)
        
        # Print to standard output and email for help
        print(failure.info)
        
        CallHelp(failure.info)
    }
}

########

load('.twilio.RData')
# Authenticate with Twilio

auth.request <- paste0('https://', twilio.sid, ':', twilio.token, 
                       '@api.twilio.com/2010-04-01/Accounts')

for(i in 1:5) {
    auth.response <- GET(auth.request)
    if(auth.response$status %in% c(200, 201)) break
    if(i == 5) CallHelp('Cannot auth with Twilio'); stop('Cannot auth with Twilio')
    Sys.sleep(30)
}

# Build API requests
call.request <- paste0(auth.request, '/',
                       twilio.sid,
                       '/Calls')

sms.request <- paste0(auth.request, '/',
                      twilio.sid,
                      '/Messages')

# Reference to TWIML file with instructions
call.orders <- 'https://handler.twilio.com/twiml/EH0a4d09a9a77bf90af8c63114d59932f6'

# Merge primary phone numbers
# TODO: Add real numbers
# Number format: +11234567890

load('test-numbers.RData')

phonenumber <- rep(test.numbers, ceiling(num.calls / 3))[1:num.calls]

email.address <- rep('psetter@kippcolorado.org', ceiling(num.calls / 3))[1:num.calls]

call.list <- daily.wallstreet %>%
    cbind(phonenumber, email.address)

    
for(i in 1:1) {
    current.number <- call.list[i, 'phonenumber'] %>% as.character
    current.student <- paste(call.list[i, 'student_last_name'],
                             call.list[i, 'student_first_name'])
    current.email <- call.list[i, 'email.address'] %>% as.character
    
    call.response <- POST(call.request,
                          body = list(From = twilio.phonenumber,
                                      To = current.number,
                                      Url = call.orders))
    
    # Printing the response requires the xml2 package
    CheckTwilioResponse(call.response, current.student, current.number)
    
    # Send SMS with more detailed information
    sms.body <- paste('Msg from KMCHS:',
                      call.list[i, 'student_first_name'], 
                      'earned Wall St. from:',
                      call.list[i, 'classes']) %>%
        substr(start = 1, stop = 140)
    
    sms.response <- POST(sms.request,
                          body = list(From = twilio.phonenumber,
                                      To = current.number,
                                      Body = sms.body))
    
    CheckTwilioResponse(sms.response, current.student, current.number)
    
    email.body <- paste(call.list[i, 'student_first_name'],
                        'earned Wall Street today from',
                        call.list[i, 'classes'],
                        '\n',
                        'Notes from his teachers:',
                        '\n',
                        gsub(';', '\n', call.list[i, 'notes'])
                        )
    
    send_message(mime(from = 'data@climb.kippcolorado.org',
                      to = current.email,
                      subject = paste('Msg from KMCHS RE: Wall Street')) %>%
                     text_body(email.body)
    )
}

# Clean-up
rm(twilio.sid, twilio.token, twilio.phonenumber)