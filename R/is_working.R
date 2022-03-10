#' Rule check on the database
#'
#' Get an indication of which R statement can be executed on the SQL
#' database.
#' dcmodifydb translates R statements into SQL statement. This works for
#' many scenario's but not all R statements can be translated into SQL.
#' This function checks whether a modification rule can be executed on the database.
#' @export
#' @example ./example/is_working_db.R
#' @param m [modifier()] object
#' @param tab tbl object
#' @param n number of records to use in this check
#' @param warn generate warnings for non-working rules
#' @param sql_warn generate warnings with sql code for non-working rules
#' @return `logical` with which statements are working
is_working_db <- function(m, tab, n = 2, warn = TRUE, sql_warn = FALSE){

  if (!inherits(m, "modifier")){
    stop("Expected a modifier object ('m')", call. = FALSE)
  }

  # take the top 2 of the table
  tab <- utils::head(tab, n)
  #TODO integrate this with sql_alter
  tc <- get_table_con(tab, copy = FALSE)
  con <- tc$con

  sql_alter <- alter_stmt(m, tc$table, tc$table_ident)
  sql_updates <- modifier_to_sql( m
                                , table = as.character(tc$table_ident)
                                , con = con)

  working <- logical(length = length(sql_updates))
  # reconstruct the names of the modifiers...
  names(working) <- sub("\\.[^.]+$", "", names(sql_updates))
  # start transaction
  DBI::dbBegin(con)
  # rollback the transaction
  on.exit(DBI::dbRollback(con))

  for (add_col in sql_alter){
    try({
      # print(add_col)
      DBI::dbExecute(con, add_col)
    }, silent = TRUE
    )
  }

  for (i in seq_along(sql_updates)){
    try({
      update <- sql_updates[[i]]
      DBI::dbExecute(con, update)
      working[i] <- TRUE
    }, silent = TRUE
    )
  }

  if (any(!working)){
    if (isTRUE(warn)){
      # a modifier typically has more sqlupdates
      nw <- unique(names(working)[!working])
      nw_m <- m[nw]
      warning( "The following rule(s) are not working on the db:\n\n"
             , paste0("- ", nw, ": ", validate::expr(nw_m), collapse = "\n")
             , "\n\n--------------------------------------------------------------"
             , "\n use 'is_working_db' with sql_warn=TRUE for more information"
             , "\n--------------------------------------------------------------"
             , call. = FALSE
             , immediate. = TRUE
             )
    }
    if (isTRUE(sql_warn)){
      stmt <- paste("-- Rule ", names(sql_updates)[!working], "\n", sql_updates[!working], collapse = "\n\n")
      warning("The following sql statements are not working on the database:\n\n",stmt
             , call. = FALSE
             , immediate. = TRUE
             )
    }
  }
  !(names(m) %in% names(working)[!working])
}
