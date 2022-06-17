#' Apply corrections/derivations to a db table
#'
#' Change records in a database table using modification rules specified
#' in a [modifier()] object. This is the main function of package `dcmodifydb`.
#' For more information see the vignettes.
#'
#' The modification rules are translated into SQL update statements
#' and executed on the table.
#'
#'
#' Note that
#'
#' - by default the updates are executed on a copy of the table.
#'
#' - the default for `transaction` is `FALSE` when `copy=TRUE` and
#'  `TRUE` when `copy=FALSE`
#'
#' - when `transaction = TRUE` and a modification fails,
#' all modifications are rolled back.
#'
#' @importFrom dcmodify modify
#' @importFrom methods setMethod
#' @param dat [tbl_sql()] object, table in a SQL database
#' @param x `dcmodify::modifier()` object.
#' @param copy if `TRUE` (default), modify copy of table
#' @param transaction if `TRUE` use one transaction for all modifications.
#' @param ignore_nw if `TRUE` non-working rules are ignored
#' @param ... unused
#' @example ./example/modify.R
#' @return [tbl_sql()] object, referencing the modified table object.
#' @export
setMethod("modify", signature("ANY", "modifier")
          , function(dat, x, copy = NULL, transaction = !isTRUE(copy), ignore_nw = FALSE, ...){
  if (inherits(dat, "tbl_sql")){
    return(modify.tbl_sql(dat = dat, x = x
                          , copy = copy, transaction = transaction, ignore_nw = ignore_nw, ...))
  }
  stop(class(dat), " not supported")
})

modify.tbl_sql <- function( dat, x, ..., copy = NULL
                          , transaction = !isTRUE(copy)
                          , ignore_nw = FALSE
                          ){

  tc <- get_table_con(dat, copy = copy)

  con <- tc$con
  table <- tc$table

  working <- is_working_db(x, table)

  if (any(!working)){
    if (isTRUE(ignore_nw)){
      x <- x[working]
      if (all(!working)){
        return(table)
      }
    }
  }

  sql_alter <- alter_stmt(x, table, tc$table_ident)

  # somehow it does not work to give table = table...
  sql_updates <- modifier_to_sql( x
                                , table = tc$table_ident
                                , con = con
                                )


  if (isTRUE(transaction)){
    DBI::dbBegin(con)
    # if something happens, rollback...
    on.exit({
      warning( "Errors, so rolling back / undoing the modifications."
             , call. = FALSE
             )
      DBI::dbRollback(con)
    })
  }

  #

  rows_affected <- numeric(length(sql_updates))
  i <- 0


  # first add columns if we need to...
  for (add_col in sql_alter){
    DBI::dbExecute(con, add_col)
  }

  for (update in sql_updates){
    DBI::dbExecute(con, update)
  }

  # ok, we can commit
  if (isTRUE(transaction)){
    on.exit(DBI::dbCommit(con))
  }

  # TODO do something with row_affected (attribute)
  dplyr::tbl(tc$con, tc$table_ident)
}
