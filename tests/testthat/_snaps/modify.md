# modify: rollback when an modifier is not working

    Code
      d_m <- modify(d, m, copy = FALSE)
    Warning <simpleWarning>
      The following rule(s) are not working on the db:
      
      - M2: if (y > 2) x <- 2
      
      --------------------------------------------------------------
       use 'is_working_db' with sql_warn=TRUE for more information
      --------------------------------------------------------------
    Error <Rcpp::exception>
      no such column: y
    Warning <simpleWarning>
      Errors, so rolling back / undoing the modifications.

