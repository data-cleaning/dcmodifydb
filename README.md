
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

### Documented rules

``` r
library(DBI)
library(dcmodify)
library(dcmodifydb)
con <- dbConnect(RSQLite::SQLite())
```

You can use YAML to store the modification rules: “modify.yml”

``` yaml
rules:
- expr: if (age > 130) age <- 130
  name: M1
  label: 'human age'
  description: |
    Human ages above 130 are inplausible
- expr: if (age < 15) {income <- 0}
  name: M2
  label: 'Child labor'
  description: |
    A child should not work and earn money.
```

``` r
m <- modifier(.file = "modify.yml")
```

``` r
"age, income
  11,   2000
 150,    300
  25,   2000
" -> csv
income <- read.csv(text = csv, strip.white = TRUE)
dbWriteTable(con, "income", income)
tbl_income <- dplyr::tbl(con, "income")

tbl_income
#> # Source:   table<income> [?? x 2]
#> # Database: sqlite 3.35.5 []
#>     age income
#>   <int>  <int>
#> 1    11   2000
#> 2   150    300
#> 3    25   2000
modify(tbl_income, m)
#> Warning: `copy` not specified, setting `copy=TRUE`, working on copy of table.
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.35.5 []
#>     age income
#>   <int>  <int>
#> 1    11      0
#> 2   130    300
#> 3    25   2000
dbDisconnect(con)
```

Note: Modification rules can be written to yaml with `as_yaml` and
`export_yaml`.

``` r
dcmodify::export_yaml(m, "cleaning_steps.yml")
```
