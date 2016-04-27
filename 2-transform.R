# Copyright KIPP Colorado Schools 2016
# Author Peter W Setter
# Transform LiveSchool data for calls and loading into database
# Input: ls.data (object returned by API call)
# Outputs:
#   daily.wallstreet: List of students earning Wall Street
#   ls.insert: df of records to add to the database

########
## Transform the data

# Get data in list format
ls.report <- content(ls.data)$report

# Convert from list to df. This requires converting NULL to NA
# Soure: http://stackoverflow.com/a/30722199/5408193
ls.df <- lapply(ls.report, function(x) {
    nonnull <- sapply(x, typeof)!="NULL"
    do.call(data.frame, c(x[nonnull], stringsAsFactors=FALSE))
}) %>%
    plyr::ldply() %>%
    # Convert character timestamp into POSIXct
    mutate(entry_time = parse_date_time(time_of_behavior, tz = 'MST',
                                        orders = '%Y-%m-%d %I:%M:%S %p'))

# Select records and columns for Wall Street
# TODO: Add and sort by advisory
daily.wallstreet <- ls.df %>%
    filter(entry_time >= ymd_hms(paste(Sys.Date(), '00:00:00'), tz = 'MST'),
           standard_name == 'Wall Street') %>%
    select(student_number,
           student_last_name,
           student_first_name,
           user_last_name,
           user_first_name,
           conduct_comment)

# Select records and columns to add to database
ls.insert <- ls.df %>%
    select(conduct_id,
           student_id = student_number,
           user_id = user_number,
           standard_name,
           behavior_name,
           behavior_points = behavior_amount,
           comments = conduct_comment,
           entry_time) %>%
    filter(entry_time >= ymd_hms(paste(Sys.Date()-1, '14:00:00'), tz = 'MST') & 
        entry_time < ymd_hms(paste(Sys.Date(), '11:00:00'), tz = 'MST'))
