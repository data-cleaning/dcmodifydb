
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dcmodifydb

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/dcmodifydb)](https://CRAN.R-project.org/package=dcmodifydb)
[![R-CMD-check](https://github.com/data-cleaning/dcmodifydb/workflows/R-CMD-check/badge.svg)](https://github.com/data-cleaning/dcmodifydb/actions)
[![Downloads](https://cranlogs.r-pkg.org/badges/dcmodifydb)](https://cran.r-project.org/package=dcmodifydb)
[![Codecov test
coverage](https://codecov.io/gh/data-cleaning/dcmodifydb/branch/main/graph/badge.svg)](https://codecov.io/gh/data-cleaning/dcmodifydb?branch=main)
<!-- badges: end -->

The goal of dcmodifydb is to apply modification rules specified with
`dcmodify` on a database table, allowing for documented, reproducable
data cleaning adjustments in a database.

`dcmodifydb` separates **intent** from **execution**: a user specifies
*what*, *why* and *how* of an automatic data change and uses dcmodify to
execute them on a `tbl` database table.

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
             , gear[cyl == 4] <- 0  # this R syntax works too :-)
             , if (gear == 3) cyl <- 2
             )

# setting up a table in the database
con <- dbConnect(RSQLite::SQLite())
dbWriteTable(con, "mtcars", mtcars[,c("cyl", "gear")])
tbl_mtcars <- dplyr::tbl(con, "mtcars")

# "Houston, we have a table"
head(tbl_mtcars)
#> # Source:   lazy query [?? x 2]
#> # Database: sqlite 3.36.0 []
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
#> # Database: sqlite 3.36.0 []
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

You can use YAML to store the modification rules: “example.yml”

``` yaml
rules:
- expr: if (age > 130) age = 130L
  name: M1
  label: 'Maximum age'
  description: |
    Human age is limited. (can use  "=")
    Cap the age at 130
- expr: is.na(age) <- age < 0
  name: M2
  label: 'Unknown age'
  description: |
    Negative Age, nah...
    (set to NA)
- expr: income[age < 12] <- 0
  name: M3
  label: 'No Child Labor'
  description: |
    Children should not work. (R syntax)
    Set income to zero for children.
- expr: "retired <- age > 67"
  name: M4
  label: 'Retired'
  description: |
    Derive a new variable...
- expr: if (age < 18) age_class = 'child' else age_class = 'adult'
  name: M5
  label: 'Age class'
  description: |
    Derive a new variable with if else
```

Let’s load the rules and apply them to a data set:

``` r
m <- modifier(.file = "example.yml")
```

``` r
print(m)
#> Object of class modifier with 5 elements:
#> M1: Maximum age
#>   if (age > 130) age = 130
#> 
#> M2: Unknown age
#>   is.na(age) <- age < 0
#> 
#> M3: No Child Labor
#>   income[age < 12] <- 0
#> 
#> M4: Retired
#>   retired <- age > 67
#> 
#> M5: Age class
#>   if (age < 18) age_class = "child" else age_class = "adult"
```

``` r
# setup the data
"age, income
  11,   2000
 150,    300
  25,   2000
 -10,   2000
" -> csv
income <- read.csv(text = csv, strip.white = TRUE)
dbWriteTable(con, "income", income)
tbl_income <- dplyr::tbl(con, "income")

# this is the table in the data base
tbl_income
#> # Source:   table<income> [?? x 2]
#> # Database: sqlite 3.36.0 []
#>     age income
#>   <int>  <int>
#> 1    11   2000
#> 2   150    300
#> 3    25   2000
#> 4   -10   2000

# and now after modification
modify(tbl_income, m, copy = FALSE) 
#> # Source:   table<income> [?? x 2]
#> # Database: sqlite 3.36.0 []
#>     age income retired age_class
#>   <int>  <int>   <int> <chr>    
#> 1    11      0       0 child    
#> 2   130    300       1 adult    
#> 3    25   2000       0 adult    
#> 4    NA   2000      NA <NA>
```

Generated sql can be written with `dump_sql`

``` r
dump_sql(m, tbl_income, file = "modify.sql")
```

modify.sql:

``` sql
-- -------------------------------------
-- Generated with dcmodifydb, do not edit
-- dcmodify version: 0.1.9
-- dcmodifydb version: 0.3.0.9000
-- dplyr version: 1.0.7
-- dbplyr version: 2.1.1
-- from: 'example/example.yml'
-- date: 2022-03-07
-- -------------------------------------


ALTER TABLE `income`
ADD COLUMN `retired` INT;

ALTER TABLE `income`
ADD COLUMN `age_class` TEXT;

-- M1: Maximum age
-- Human age is limited. (can use  "=")
-- Cap the age at 130
-- 
-- R expression: if (age > 130) age = 130
UPDATE `income`
SET `age` = 130
WHERE `age` > 130.0;

-- M2: Unknown age
-- Negative Age, nah...
-- (set to NA)
-- 
-- R expression: is.na(age) <- age < 0
UPDATE `income`
SET `age` = NULL
WHERE `age` < 0.0;

-- M3: No Child Labor
-- Children should not work. (R syntax)
-- Set income to zero for children.
-- 
-- R expression: income[age < 12] <- 0
UPDATE `income`
SET `income` = 0.0
WHERE `age` < 12.0;

-- M4: Retired
-- Derive a new variable...
-- 
-- R expression: retired <- age > 67
UPDATE `income`
SET `retired` = `age` > 67.0
;

-- M5: Age class
-- Derive a new variable with if else
-- 
-- R expression: if (age < 18) age_class = "child" else age_class = "adult"
UPDATE `income`
SET `age_class` = 'child'
WHERE `age` < 18.0;

UPDATE `income`
SET `age_class` = 'adult'
WHERE NOT(`age` < 18.0);
```

``` r
dbDisconnect(con)
```

Note: Modification rules can be written to yaml with `as_yaml` and
`export_yaml`.

``` r
dcmodify::export_yaml(m, "cleaning_steps.yml")
```
