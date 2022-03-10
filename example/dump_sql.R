# load modification rules and apply:
library(dcmodify)

con <- DBI::dbConnect(RSQLite::SQLite(), dbname=system.file("db/person.db", package="dcmodifydb"))
person <- dplyr::tbl(con, "person")

rules <- modifier(.file = system.file("db/corrections.yml", package="dcmodifydb"))
print(rules)

# show sql code generated from the rules.
dump_sql(rules, person)
