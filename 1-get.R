# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Download LiveSchool points log

## Function definitions
Logout <- function(url) {
    for(i in 1:5) {
        logout <- GET(url)
        if(logout$status == 200) return(0)
        Sys.sleep(30)
    }
    CallHelp('Cannot logout of LiveSchool.')
    stop('Cannot logout of LiveSchool.')
}

########
## Pull Data from LiveSchool

# Defensive: Logout in case of previous open session
logout.url <- 'https://admin.liveschoolinc.com/logout'

Logout(logout.url)

# Login
for(i in 1:5) {
    login <- POST('https://admin.liveschoolinc.com/', 
                 body = list(username = LS.username, password = LS.password))
    if(login$status == 200) break
    if(i == 5) CallHelp('Cannot login to LiveSchool'); stop('Cannot login to LiveSchool')
    Sys.sleep(30)
}

rm(LS.username, LS.password)

# Time for API call is 12 hours ahead of Mountain Time
# Use Sys.Date + 1 in order to request records for after 12:00 PM
api.call <- paste0('https://admin.liveschoolinc.com/api?action=genericconducts2&mode=reports&from=', 
    #Sys.Date(), '&to=', Sys.Date() + 1)
    '2016-07-28', '&to=', '2016-07-29')
# TODO: Check for valid input
for(i in 1:5) {
    ls.data <- GET(api.call)
    if(ls.data$status == 200) break
    if(i == 5) CallHelp('Did not receive LiveSchool data'); stop('Did not receive LiveShool data')
    Sys.sleep(30)
}

# Close out call
Logout(logout.url)
