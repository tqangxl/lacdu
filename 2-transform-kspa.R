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

auto <- ls.df %>%
    filter(entry_time >= ymd_hms(paste(Sys.Date(), '00:00:00'), tz = 'MST'),
        standard_name %in% c('Auto College Prep', 'Auto WHC')) %>%
    mutate(consequence = ifelse(standard_name == 'Auto WHC', 'WHC', 'CP')) %>%
    group_by(student_number, student_last_name, student_first_name, consequence) %>%
    summarize(
        # Source: http://stackoverflow.com/a/20854935/5408193
              behaviors = paste(behavior_name, collapse = ', '),
              notes = paste(user_last_name, behavior_name, conduct_comment, collapse = '; '))

# Students with three deductions earn a CP

cp3 <- ls.df %>%
    filter(entry_time >= ymd_hms(paste(Sys.Date(), '00:00:00'), tz = 'MST'),
        standard_name == 'Deduction (Behavior)') %>%
    group_by(student_number, student_last_name, student_first_name) %>%
    summarize(deductions = n(),
              # Source: http://stackoverflow.com/a/20854935/5408193
              behaviors = paste(behavior_name, collapse = ', '),
              notes = paste(user_last_name, behavior_name, conduct_comment, collapse = '; ')) %>%
    filter(deductions >= 3) %>%
    select(-deductions) %>%
    mutate(consequence = 'CP')

# Students with three work deductions earn a WHC

wh3 <- ls.df %>%
    filter(entry_time >= ymd_hms(paste(Sys.Date(), '00:00:00'), tz = 'MST'),
        standard_name == 'Deduction (Work)') %>%
    group_by(student_number, student_last_name, student_first_name) %>%
    summarize(deductions = n(),
              # Source: http://stackoverflow.com/a/20854935/5408193
              behaviors = paste(behavior_name, collapse = ', '),
              notes = paste(user_last_name, behavior_name, conduct_comment, collapse = '; ')) %>%
    filter(deductions >= 3) %>%
    select(-deductions) %>%
    mutate(consequence = 'WHC')

# Get current advisories
source('advisory-query.R')


afterschool <- rbind(auto, cp3, wh3) %>%
    group_by(student_number, student_last_name, student_first_name, consequence) %>%
    summarize(
              # Source: http://stackoverflow.com/a/20854935/5408193
              behaviors.all = paste(behaviors, collapse = ', '),
              notes.all = paste(notes, collapse = '\n ')) %>%
    merge(x = ., y = advisories,
          by.x = 'student_number',
          by.y = 'local_student_id') %>%
    select(grade, advisory = s_group, student_number, student_last_name, student_first_name,
           consequence, behaviors.all, notes.all) %>%
    arrange(consequence, grade,student_last_name, student_first_name)