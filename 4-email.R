# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Email staff a list of students earning an afterschool consequence
# Input afterschool

# Convert afterschool into an html table
afterschool.html <- afterschool %>%
    select(-behaviors.all) %>%
    knitr::kable(format = 'html',
                 col.names = c('Grade', 'Advisory', 'Student ID', 'Last Name', 'First Name', 
                               'Consequence', 'Notes'))

if(num.calls > 0) {
    send_message(mime(from = 'noreply@climb.kippcolorado.org',
                      to = staff.email,
                      subject = paste('Consequence List', Sys.Date())) %>%
                    html_body(afterschool.html)
    )
    } else {
        send_message(mime(from = 'noreply@climb.kippcolorado.org',
                          to = staff.email,
                          subject = paste('Consequence List', Sys.Date())) %>%
                    text_body('No after school consequences today!')
        )}
