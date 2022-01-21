#' Modify records in a tbl
#'
#' Modify records in a database table using modification rules specified
#' in a modifier object.
#'
#' The modification rules are translated into SQL update statements
#' and executed on the table.
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
#' @param dat [tbl_sql()] object, table in a SQL database
#' @param x `dcmodify::modifier()` object.
#' @param copy if `TRUE` (default), modify copy of table
#' @param transaction if `TRUE` use one transaction for all modifications.
#' @param ... unused
#' @example ./example/modify.R
#' @return [tbl_sql()] object, referencing the modified table object.
#' @export
setMethod("modify", signature("ANY", "modifier")
          , function(dat, x, copy = NULL, transaction = !isTRUE(copy), ...){
  if (inherits(dat, "tbl_sql")){
    return(modify.tbl_sql(dat = dat, x = x
                          , copy = copy, transaction = transaction,...))
  }
  stop(class(dat), " not supported")
})

modify.tbl_sql <- function(dat, x, ..., copy = NULL, transaction = !isTRUE(copy)){
  tc <- get_table_con(dat, copy = copy)

  con <- tc$con
  table <- tc$table

  sql_alter <- alter_stmt(x, table, tc$table_ident)

  # somehow it does not work to give table = table...
  sql_updates <- modifier_to_sql( x
                                , table = as.character(tc$table_ident)
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
  table
}
