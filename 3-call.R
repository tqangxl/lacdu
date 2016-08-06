# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Call families of students who earned the consequence
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
                              response.object$status,
                              '\n')
        
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

# Merge primary phone numbers

# For use on PC
ch <- odbcConnect('Blackstone')
contacts <- sqlQuery(ch, 'SELECT * FROM contact_test')
close(ch)

# For use on Blackstone
#kippco <- src_postgres('kippco')
#contacts <- tbl(kippco, 'contact_test')

# TODO: Clean-up test code
#load('test-numbers.RData')

#phonenumber <- rep(test.numbers, ceiling(num.calls / 3))[1:num.calls]

#email.address <- rep('psetter@kippcolorado.org', ceiling(num.calls / 3))[1:num.calls]

call.list <- merge(afterschool, contacts,
                   by.x = 'student_number',
                   by.y = 'studentid',
                   all.x = TRUE) %>%
    mutate(call = 'failed',
           sms = 'failed')

    
for(i in 1:1) {
    current.number <- call.list[i, 'phonenumber'] %>% as.character
    current.student <- paste(call.list[i, 'student_last_name'],
                             call.list[i, 'student_first_name'])
    current.email <- call.list[i, 'email'] %>% as.character
    
    call.response <- POST(call.request,
                          body = list(From = twilio.phonenumber,
                                      To = current.number,
                                      Url = call.orders))
    
    # Printing the response requires the xml2 package
    # CheckTwilioResponse calls data@climb for help and prints to sdout
    CheckTwilioResponse(call.response, current.student, current.number)
    
    # Modify call.list for forwarding to office staff for follow-up
    if(call.response$status == 201) {
        call.list[i, 'call'] <- 'success'
    }
    
    
    # Send SMS with more detailed information
    sms.body <- paste('Msg from KIPP:',
                      call.list[i, 'student_first_name'], 
                      'will need to stay after school for',
                      call.list[i, 'behaviors.all']) %>%
        substr(start = 1, stop = 140)
    
    sms.response <- POST(sms.request,
                          body = list(From = twilio.phonenumber,
                                      To = current.number,
                                      Body = sms.body))
    
    
    CheckTwilioResponse(sms.response, current.student, current.number)
    
    if(sms.response$status == 201) {
        call.list[i, 'call'] <- 'success'
    }
    
    email.body <- paste(call.list[i, 'student_first_name'],
                        'will need to stay after school today for',
                        call.list[i, 'consequence'],
                        '\n',
                        'Notes from their teachers:',
                        '\n',
                        gsub(';', '\n', call.list[i, 'notes.all'])
                        )
    
    send_message(mime(from = 'noreply@climb.kippcolorado.org',
                      to = current.email,
                      subject = paste('Msg from KIPP RE: Staying After School Today')) %>%
                     text_body(email.body)
    )
}

# Send email to office staff with list of failed calls and SMS
office.body <- call.list %>%
    filter(call == 'failed' || sms == 'failed') %>%
    select(student_number, student_last_name, student_first_name, consequence,
           phonenumber, call, sms) %>%
    knitr::kable(format = 'html')

send_message(mime(from = 'noreply@climb.kippcolorado.org',
                  to = office.email,
                  subject = paste('Failed Calls & SMS')) %>%
                 html_body(office.body)
)

# Clean-up
rm(twilio.sid, twilio.token, twilio.phonenumber)