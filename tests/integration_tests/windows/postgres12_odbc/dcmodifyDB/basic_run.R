

while(TRUE){
    
}

library(DBI)
library(dcmodify)

library(dcmodifydb)
library(odbc)


# silly modification rules
m <- modifier( if (cyl == 6)  gear <- 10
             , gear[cyl == 4] <- 0  # this R syntax works too :-)
             , if (gear == 3) cyl <- 2
             )

# setting up a table in the database
con <- dbConnect(RPostgres::Postgres(),
                 host = "db_postgres12_ssl",
                 dbname = "test_postgres12_ssl",
                 port = 5432,
                 user   = "admin",
                 password    = "admin",)
                 dbRemoveTable(con, "mtcars")
# Table might already exist in db so delete it and fail silently

dbWriteTable(con, "mtcars", mtcars[,c("cyl", "gear")], overwrite = TRUE)
tbl_mtcars <- dplyr::tbl(con, "mtcars")

# "Houston, we have a table"
head(tbl_mtcars)


# lets modify on a copy of the table...
tbl_m <- modify(tbl_mtcars, m, copy=TRUE)

# and gear has changed...
head(tbl_m)
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.35.5 []
#>     cyl  gear
#>   <dbl> <dbl>
#> 1     6    10
#> 2     6    10
#> 3     4     0
#> 4     6    10
#> 5     2     3
#> 6     6    10

dbDisconnect(con)