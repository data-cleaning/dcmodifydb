person <- dbplyr::memdb_frame(age = 12, salary = 3000)

library(dcmodify)

correction_rules <- modifier( if (age < 16) salary = 0
                            , if (retired == TRUE) salary = 0
                            )

# second rule is not working, because retired is not available
is_working_db(correction_rules, person, warn = FALSE)

# show warnings (default)
is_working_db(correction_rules, person, warn = TRUE)

# show the sql statements that are not working
is_working_db(correction_rules, person, warn = FALSE, sql_warn = TRUE)
