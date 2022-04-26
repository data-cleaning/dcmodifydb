
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

`dcmodify` separates **intent** from **execution**: a user specifies
*what*, *why* and *how* of an automatic data change and uses
`dcmodifydb` to execute them on a `tbl` database table.

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

# data with "errors"
print(person)
#>   id income age gender year smokes cigarettes
#> 1  1   2000  12      M 2020     no         10
#> 2  2   2010  14      f 2019    yes          4
#> 3  3   2010  25      v   19     no         NA

# setting up a database table
con <- dbConnect(RSQLite::SQLite())
person_tbl <- copy_to(con, person)
# or
# dbWriteTable(con, "person", person)
# person_tbl <- tbl(con, "person")
print(person_tbl)
#> # Source:   table<person> [?? x 7]
#> # Database: sqlite 3.37.2 []
#>      id income   age gender  year smokes cigarettes
#>   <int>  <int> <int> <chr>  <int> <chr>       <int>
#> 1     1   2000    12 M       2020 no             10
#> 2     2   2010    14 f       2019 yes             4
#> 3     3   2010    25 v         19 no             NA

# make some modification rules
m <- modifier(
  if (is.na(cigarettes) && smokes == "no"){
    cigarettes = 0
  },
  if (age < 14) { age = mean(age, na.rm=TRUE)}
)


# lets modify on a temporary copy of the table..
# this copy is only visible to the current connection
person_m <- modify(person_tbl, m, key="id", copy=TRUE)


# and cigarretes and age has changed has changed...
person_m
#> # Source:   table<dcmodifydb_3319833> [?? x 7]
#> # Database: sqlite 3.37.2 []
#>      id income   age gender  year smokes cigarettes
#>   <int>  <int> <int> <chr>  <int> <chr>       <int>
#> 1     1   2000    17 M       2020 no             10
#> 2     2   2010    14 f       2019 yes             4
#> 3     3   2010    25 v         19 no              0

# If one certain about the changes, then you can overwrite the table with the changes
person_m <- modify(person_tbl, m, key="id", copy=FALSE)

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
"id, age, income
  A,  11,   2000
  B, 150,    300
  C,  25,   2000
  D, -10,   2000
" -> csv
income <- read.csv(text = csv, strip.white = TRUE)
dbWriteTable(con, "income", income)
tbl_income <- dplyr::tbl(con, "income")

# this is the table in the data base
tbl_income
#> # Source:   table<income> [?? x 3]
#> # Database: sqlite 3.37.2 []
#>   id      age income
#>   <chr> <int>  <int>
#> 1 A        11   2000
#> 2 B       150    300
#> 3 C        25   2000
#> 4 D       -10   2000

# and now after modification
modify(tbl_income, m, key="id", copy = FALSE) 
#> # Source:   table<income> [?? x 5]
#> # Database: sqlite 3.37.2 []
#>   id      age income retired age_class
#>   <chr> <int>  <int>   <int> <chr>    
#> 1 A        11      0       0 child    
#> 2 B       130    300       1 adult    
#> 3 C        25   2000       0 adult    
#> 4 D        NA   2000      NA <NA>
```

Generated sql can be written with `dump_sql`

``` r
dump_sql(m, tbl_income, key = "id", file = "modify.sql")
```

modify.sql:

``` sql
-- -------------------------------------
-- Generated with dcmodifydb, do not edit
-- dcmodify version: 0.1.9
-- dcmodifydb version: 0.3.0.9001
-- dplyr version: 1.0.8
-- dbplyr version: 2.1.1
-- from: 'example/example.yml'
-- date: 2022-04-26
-- -------------------------------------


ALTER TABLE `income`
ADD `retired` INT;

ALTER TABLE `income`
ADD `age_class` TEXT;

-- M1: Maximum age
-- Human age is limited. (can use  "=")
-- Cap the age at 130
-- 
-- R expression: if (age > 130) age = 130
UPDATE `income` AS T
SET `age` = U.`age`
FROM
(SELECT `id`, 130 AS `age`
FROM `income`) AS U
WHERE T.`id` = U.`id`
  AND T.`age` > 130.0;

-- M2: Unknown age
-- Negative Age, nah...
-- (set to NA)
-- 
-- R expression: is.na(age) <- age < 0
UPDATE `income` AS T
SET `age` = U.`age`
FROM
(SELECT `id`, NULL AS `age`
FROM `income`) AS U
WHERE T.`id` = U.`id`
  AND T.`age` < 0.0;

-- M3: No Child Labor
-- Children should not work. (R syntax)
-- Set income to zero for children.
-- 
-- R expression: income[age < 12] <- 0
UPDATE `income` AS T
SET `income` = U.`income`
FROM
(SELECT `id`, 0.0 AS `income`
FROM `income`) AS U
WHERE T.`id` = U.`id`
  AND T.`age` < 12.0;

-- M4: Retired
-- Derive a new variable...
-- 
-- R expression: retired <- age > 67
UPDATE `income` AS T
SET `retired` = U.`retired`
FROM
(SELECT `id`, `age` > 67.0 AS `retired`
FROM `income`) AS U
WHERE T.`id` = U.`id`;

-- M5: Age class
-- Derive a new variable with if else
-- 
-- R expression: if (age < 18) age_class = "child" else age_class = "adult"
UPDATE `income` AS T
SET `age_class` = U.`age_class`
FROM
(SELECT `id`, 'child' AS `age_class`
FROM `income`) AS U
WHERE T.`id` = U.`id`
  AND T.`age` < 18.0;

UPDATE `income` AS T
SET `age_class` = U.`age_class`
FROM
(SELECT `id`, 'adult' AS `age_class`
FROM `income`) AS U
WHERE T.`id` = U.`id`
  AND NOT(T.`age` < 18.0);
```

``` r
dbDisconnect(con)
```

Note: Modification rules can be written to yaml with `as_yaml` and
`export_yaml`.

``` r
dcmodify::export_yaml(m, "cleaning_steps.yml")
```
