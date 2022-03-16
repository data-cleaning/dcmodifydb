library(DBI)
library(dcmodify)
library(dcmodifydb)

# silly modification rules
m <- modifier( if (cyl == 6)  gear <- 10
             , gear[cyl == 4] <- 0  # this R syntax works too :-)
             , if (gear == 3) cyl <- 2
             )

# setting up a table in the database
con <- dbConnect(RSQLite::SQLite())
dbWriteTable(con, "mtcars", mtcars[,c("cyl", "gear")])
tbl_mtcars <- dplyr::tbl(con, "mtcars")

# "Houston, we have a table"
head(tbl_mtcars)

# lets modify on a temporary copy of the table..
# this copy is only visible to the current connection
tbl_m <- modify(tbl_mtcars, m, copy=TRUE)


# and gear has changed...
head(tbl_m)

# If one certain about the changes, then you can overwrite the table with the changes
tbl_m <- modify(tbl_mtcars, m, copy=FALSE)

dbDisconnect(con)
