# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Email Wall Street list
# Input daily.wallstreet

# Convert daily.wallstreet into an html table
wallstreet.html <- knitr::kable(daily.wallstreet, format = 'html')

if(num.calls > 0) {
    send_message(mime(from = 'data@climb.kippcolorado.org',
                      to = 'psetter@kippcolorado.org',
                      subject = paste('Wall Street', Sys.Date())) %>%
                    html_body(wallstreet.html)
    )
    } else {
        send_message(mime(from = 'data@climb.kippcolorado.org',
                          to = 'psetter@kippcolorado.org',
                          subject = paste('Wall Street', Sys.Date())) %>%
                    text_body('No Wall Streets Today!')
        )}
# Send an email with the list
