# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Transform LiveSchool data for calls and loading into database
# Input: ls.data (object returned by API call)
# Outputs:
#   afterschool

########
## Transform the data

# Get data in list format
ls.report <- content(ls.data)$report

# Convert from list to df. This requires converting NULL to ''
# Soure: http://stackoverflow.com/a/30722199/5408193
ls.df <- lapply(ls.report, function(x) {
    null <- sapply(x, typeof)=="NULL"
    x[null] <- ''
    do.call(data.frame, c(x, stringsAsFactors=FALSE))
}) %>%
    plyr::ldply() %>%
    # Convert character timestamp into POSIXct
    mutate(entry_time = parse_date_time(time_of_behavior, tz = 'MST',
                                        orders = '%Y-%m-%d %I:%M:%S %p'))

# Filter ls.df depending on the day of the week
current.date <- Sys.Date()
dow <- weekdays(current.date)


if(dow == 'Monday') {
    ls.df.filtered <- ls.df %>%
        filter(between(entry_time,
                       ymd_hms(paste(current.date - 3, '14:31:00'), tz = 'MST'),
                       ymd_hms(paste(current.date, '14:30:00'), tz = 'MST'))
                       & standard_name %in% c('Be Nice Detention', 'Auto HWC', 'Homework Club')
        )
} else if(dow == 'Tuesday') {
    ls.df.filtered <- ls.df %>%
        filter(between(entry_time,
                       ymd_hms(paste(current.date - 1, '14:31:00'), tz = 'MST'),
                       ymd_hms(paste(current.date, '13:00:00'), tz = 'MST'))
               & standard_name == 'Be Nice Detention')
} else if(dow == 'Wednesday') {
    ls.df.filtered <- ls.df %>%
        filter((between(entry_time,
                       ymd_hms(paste(current.date - 1, '13:0:01'), tz = 'MST'),
                       ymd_hms(paste(current.date, '14:30:00'), tz = 'MST'))
               & standard_name == 'Be Nice Detention')
               |
                   (between(entry_time,
                            ymd_hms(paste(current.date - 1, '00:00:00'), tz = 'MST'),
                            ymd_hms(paste(current.date, '14:30:00'), tz = 'MST'))
                    & standard_name %in% c('Auto HWC', 'Homework Club'))
               )
} else {
    ls.df.filtered <- ls.df %>%
        filter(between(entry_time,
                        ymd_hms(paste(current.date - 1, '14:31:00'), tz = 'MST'),
                        ymd_hms(paste(current.date, '14:30:00'), tz = 'MST'))
                    & standard_name %in% c('Be Nice Detention', 'Auto HWC', 'Homework Club')
        )
}

# Get current advisories
source('advisory-query.R')



afterschool <- ls.df.filtered %>%
    group_by(student_number, student_last_name, student_first_name) %>%
    summarize(bnd = sum(standard_name == 'Be Nice Detention'),
              autohwc = sum(standard_name == 'Auto HWC'),
              hwc = sum(standard_name == 'Homework Club'),
              behaviors.all = paste(behavior_name, collapse = ', '),
              notes.all = paste(user_last_name, behavior_name, conduct_comment, collapse = '; ')) %>%
    CaseStatement(consequence,
                  bnd > 0 ~ 'BND',
                  autohwc > 0 ~ 'HWC',
                  hwc >= 2 ~ 'HWC',
                  ~ 'None') %>%
    filter(consequence != 'None') %>%
    merge(x = ., y = advisories,
          by.x = 'student_number',
          by.y = 'local_student_id',
          all.x = TRUE) %>%
    select(grade, advisory = s_group, student_number, student_last_name, student_first_name,
           consequence, behaviors.all, notes.all) %>%
    arrange(grade, advisory, student_last_name, student_first_name)




