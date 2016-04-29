# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Download LiveSchool points log

## Function definitions
Logout <- function(url) {
    repeat {
        logout <- GET(url)
        if(logout$status == 200) return(0)
        else print('Trying again...')
    }
}

########
## Pull Data from LiveSchool
# TODO: Ensure that API call is completed (Added repeat loops; is there a better solution?)
# TODO: Convert to a function so it can be called for every site
load('.KMCHS-LS.RData')

# Defensive: Logout in case of previous open session
logout.url <- 'https://admin.liveschoolinc.com/logout'

Logout(logout.url)

# Login
repeat {
    login <- POST('https://admin.liveschoolinc.com/', 
                 body = list(username = KMCHS.username, password = KMCHS.password))
    if(login$status == 200) break
    else print('Trying again...')
}

rm(KMCHS.username, KMCHS.password)

# Time for API call is 12 hours ahead of Mountain Time
# Use Sys.Date + 1 in order to request records for after 12:00 PM
api.call <- paste0('https://admin.liveschoolinc.com/api?action=genericconducts2&mode=reports&from=', 
    Sys.Date(), '&to=', Sys.Date() + 1)

# TODO: Check for valid input
repeat {
    ls.data <- GET(api.call)
    if(ls.data$status == 200) break
    else print('Trying again...')
}

# Close out call
Logout(logout.url)