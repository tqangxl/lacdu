# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Email Wall Street list
# Input daily.wallstreet

# Convert daily.wallstreet into an html table
wallstreet.html <- knitr::kable(daily.wallstreet, format = 'html')

# Send an email with the list
send_message(mime(from = 'data@climb.kippcolorado.org',
                    to = 'psetter@kippcolorado.org',
                    subject = paste('Wall Street', Sys.Date())) %>%
    html_body(wallstreet.html))