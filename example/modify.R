library(DBI)
library(dcmodify)

# silly modification rule
m <- modifier(if (cyl == 6) gear <- 10)

con <- dbConnect(RSQLite::SQLite())

dbWriteTable(con, "mtcars", mtcars)
tbl_mtcars <- dplyr::tbl(con, "mtcars")
tbl_m <- modify(tbl_mtcars, m, copy=TRUE)

dbDisconnect(con)
