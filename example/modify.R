library(DBI)
library(dcmodify)
library(dcmodifydb)

# data with "errors"
print(person)

# setting up a database table
con <- dbConnect(RSQLite::SQLite())
person_tbl <- copy_to(con, person)
# or
# dbWriteTable(con, "person", person)
# person_tbl <- tbl(con, "person")
print(person_tbl)

# make some modification rules
m <- modifier(
  if (is.na(cigarettes) && smokes == "no")  cigarettes = 0,
  if (age < 14) age = mean(age, na.rm=TRUE)
)


# lets modify on a temporary copy of the table..
# this copy is only visible to the current connection
person_m <- modify(person_tbl, m, key="id", copy=TRUE)


# and cigarretes and age has changed has changed...
person_m

# If one certain about the changes, then you can overwrite the table with the changes
person_m <- modify(person_tbl, m, key="id", copy=FALSE)

dbDisconnect(con)
