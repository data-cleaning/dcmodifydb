
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dcmodifydb

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/dcmodifydb)](https://CRAN.R-project.org/package=dcmodifydb)
[![R-CMD-check](https://github.com/data-cleaning/dcmodifydb/workflows/R-CMD-check/badge.svg)](https://github.com/data-cleaning/dcmodifydb/actions)
[![Codecov test
coverage](https://codecov.io/gh/data-cleaning/dcmodifydb/branch/main/graph/badge.svg)](https://codecov.io/gh/data-cleaning/dcmodifydb?branch=main)
<!-- badges: end -->

The goal of dcmodifydb is to apply modification rules specified with
`dcmodify` on a database table, allowing for documented, reproducable
data cleaning adjustments in a database.

## Installation

<!-- You can install the released version of dcmodifydb from [CRAN](https://CRAN.R-project.org) with: -->
<!-- ``` r -->
<!-- install.packages("dcmodifydb") -->
<!-- ``` -->

The development version from [GitHub](https://github.com/) can be
installed with:

``` r
# install.packages("devtools")
devtools::install_github("data-cleaning/dcmodifydb")
```

## Example

``` r
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
```
