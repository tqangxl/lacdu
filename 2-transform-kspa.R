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

# Get students who automatically earned CP or WHC

# Get current advisories
source('advisory-query.R')

afterschool <- ls.df %>%
    filter(entry_time >= ymd_hms(paste(Sys.Date(), '00:00:00'), tz = 'MST'),
           standard_name %in% c('Deduction (Behavior)', 'Deduction (Work)',
                                'Auto College Prep', 'Auto WHC')
           ) %>%
    group_by(student_number, student_last_name, student_first_name) %>%
    summarize(behavior =sum(standard_name == 'Deduction (Behavior)'),
              work = sum(standard_name == 'Deduction (Work)'),
              autocp = sum(standard_name == 'Auto College Prep'),
              autowhc = sum(standard_name == 'Auto WHC'),
              behaviors.all = paste(behavior_name, collapse = ', '),
              notes.all = paste(user_last_name, behavior_name, conduct_comment, collapse = '; ')) %>%
    CaseStatement(consequence,
                  autocp > 0 ~ 'CP',
                  behavior >= 3 ~ 'CP',
                  autowhc > 0 ~ 'WHC',
                  work >= 3 ~ 'WHC',
                  ~ 'None') %>%
    filter(consequence != 'None') %>%
    merge(x = ., y = advisories,
          by.x = 'student_number',
          by.y = 'local_student_id',
          all.x = TRUE) %>%
    select(grade, advisory = s_group, student_number, student_last_name, student_first_name,
           consequence, behaviors.all, notes.all) %>%
    arrange(grade, advisory, student_last_name, student_first_name)


afterschool.email <- afterschool %>%
    select(consequence, grade, student_number, student_last_name, student_first_name) %>%
    arrange(consequence, grade, student_last_name, student_first_name)