#' Test
#'
#' test
#'
#' @importFrom dcmodify modify
#' @param dat [tbl_dbi()] object, table in a DBI database
#' @param x [dcmodify::modifier()] object.
#' @param ... unused
#' @export
setMethod("modify", signature("ANY", "modifier"), function(dat, x, ...){
  if (inherits(dat, "tbl_dbi")){
    return(modify.tbl_dbi(dat, x, ...))
  }
  stop(class(dat), " not supported")
})

modify.tbl_dbi <- function(dat, x, ..., copy = NULL, transaction = TRUE){
  tc <- get_table_con(dat, copy = copy)

  con <- tc$con
  table <- tc$table

  sql_updates <- modifier_to_sql(x, table = table, con = con)

  if (isTRUE(transaction)){
    DBI::dbBegin(con)
    # if something happens, rollback...
    on.exit({
      warning("Errors, so rolling back / undoing the modifications.", call. = FALSE)
      DBI::dbRollback(con)
    })
  }

  for (update in sql_updates){
    DBI::dbExecute(con, update) # todo collect number of records
  }

  # ok, we can commit
  if (isTRUE(transaction)){
    on.exit(DBI::dbCommit(con))
  }

  dat
}
