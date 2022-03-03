#install.packages("odbc")
#install.packages("RPostgres")
library(DBI)
library(dcmodify)
library(dcmodifydb)
library(odbc)
print(sessionInfo())
flush.console()

# silly modification rules
m <- modifier( if (cyl == 6)  gear <- 10
             , gear[cyl == 4] <- 0  # this R syntax works too :-)
             , if (gear == 3) cyl <- 2
             )

# setting up a table in the database
con <- dbConnect(RPostgres::Postgres(),
                 host = "db",
                 dbname = "r_testing",
                 port = 5432,
                 user   = "admin",
                 password    = "admin",)
dbWriteTable(con, "mtcars", mtcars[,c("cyl", "gear")])
tbl_mtcars <- dplyr::tbl(con, "mtcars")

# "Houston, we have a table"
head(tbl_mtcars)
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.35.5 []
#>     cyl  gear
#>   <dbl> <dbl>
#> 1     6     4
#> 2     6     4
#> 3     4     4
#> 4     6     3
#> 5     8     3
#> 6     6     3

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