# create a dataset to be used for testing in dcmodifydb

person <- read.csv(text="
id, income, age, gender, year, smokes, cigarettes
 1,   2000,  12,      M, 2020,     no,         10
 2,   2010,  14,      f, 2019,    yes,          4
 3,   2010,  25,      v,   19,     no,
", strip.white=TRUE)

usethis::use_data(person, overwrite = TRUE)

dir.create("inst/db", showWarnings = FALSE, recursive = TRUE)
con <- DBI::dbConnect(RSQLite::SQLite(), db = "inst/db/person.db")
DBI::dbWriteTable(con, "person", person, overwrite=TRUE)
DBI::dbDisconnect(con)
