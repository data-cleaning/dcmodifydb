#' Check if UPDATE statement is functional
#'
#' Get an indication of which R statement can be executed on the SQL database.
#' @export
#' @param updates `list` of update statements object ([modifier_to_sql()])
#' @param tab tbl object
#' @param n number of records to use in this check
#' @return `logical` with which statements are working
is_working_db <- function(updates, tab, n = 2){

  #TODO integrate this with sql_alter
  # take the top 2 of the table
  tab <- utils::head(tab, n)
  tc <- get_table_con(tab, copy = TRUE)

  con <- tc$con
  working <- logical(length = length(updates))

  for (i in seq_along(updates)){
    try({
      update <- updates[[i]]
      DBI::dbExecute(con, update)
      working[i] <- TRUE

    }, silent = TRUE
    )
  }

  if (any(!working)){
    stmt <- paste(updates[!working], collapse = "\n\n")
    warning("The following statements are not working:\n\n",stmt)
  }
  working
}
