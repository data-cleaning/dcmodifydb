library(DBI)
library(dcmodify)
library(dcmodifydb)

# silly modification rules
m <- modifier( if (cyl == 6)  gear <- 10
             , if (cyl == 4)  gear <- 0
             , if (gear == 3) cyl <- 2
             )

# setting up a table in the database
con <- dbConnect(RSQLite::SQLite())
dbWriteTable(con, "mtcars", mtcars[,c("cyl", "gear")])
tbl_mtcars <- dplyr::tbl(con, "mtcars")

# "Houston, we have a table"
head(tbl_mtcars)

# lets modify on a copy of the table...
tbl_m <- modify(tbl_mtcars, m, copy=TRUE)
# and gear has changed...
head(tbl_m)

dbDisconnect(con)
