
# load modification rules and apply:
library(dcmodify)
rules <- modifier(.file = system.file("db/corrections.yml", package="dcmodifydb"))

con <- DBI::dbConnect(RSQLite::SQLite(), dbname=system.file("db/person.db", package="dcmodifydb"))
person <- dplyr::tbl(con, "person")
print(person)

person2 <- modify(person, rules, copy=TRUE)
print(person2)
