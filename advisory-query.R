dsn <- 'Colorado_Illuminate_64'

library(RODBC)

advisory.query <- "
SELECT stu.local_student_id, local_site_id as school, grade_level_id - 1 as grade,
	CASE
-- Middle Schools use Comp
WHEN cube.site_id IN (435) AND c.long_name LIKE 'Composition%'
THEN split_part(sec.local_section_id, '-', 1)
-- High Schools use Advisory
WHEN cube.site_id IN (426, 460, 498) AND c.long_name = 'Advisory'
THEN u.last_name
-- KME use Homeroom
WHEN cube.site_id = 306
THEN split_part(sec.local_section_id, '-', 1)
END AS s_group

FROM matviews.ss_cube cube
-- Join to users to select teacher
INNER JOIN public.users u ON u.user_id = cube.user_id
Inner Join public.section_teacher_aff staf on staf.section_id = cube.section_id and staf.user_id = u.user_id and staf.primary_teacher = TRUE
-- Join to sections to get house name
INNER JOIN public.sections sec ON sec.section_id = cube.section_id
-- Join to courses to get course name
INNER JOIN public.courses c ON c.course_id = cube.course_id
INNER JOIN public.sites sit ON sit.site_id = cube.site_id
INNER JOIN public.students stu ON stu.student_id = cube.student_id

WHERE cube.academic_year = 2017
AND cube.entry_date <= '2016-08-08' ---current_date
AND cube.leave_date > current_date
AND staf.start_date <= '2016-08-08' ---current_date 
and staf.end_date > current_date
AND CASE
-- Middle Schools use Comp
WHEN cube.site_id IN (435)
THEN c.long_name LIKE 'Composition%'
-- High Schools use Advisory
WHEN cube.site_id IN (426, 460, 498)
THEN c.long_name = 'Advisory'
-- KME use Homeroom
WHEN cube.site_id = 306
THEN c.long_name = 'Homeroom'
END
"
ch <- odbcConnect(dsn)

advisories <- sqlQuery(ch, advisory.query)

close(ch)

rm(ch, dsn, advisory.query)
