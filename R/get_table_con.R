#' Get table connection
#'
#' Gets a table connection, possibly a copy of the table.
#' @param table either a character or a tbl_sql object
#' @param con dbi connection
#' @param copy should a copy of the table be generated?
#' @keywords internal
get_table_con <- function(table, con = NULL, copy = NULL){
  if (inherits(table, "tbl_sql")){
    if (!missing(con) && !is.null(con)){
      warning("ignoring `con`, taking connection from `table`", call. = FALSE)
    }

    if (is.null(get_tbl_name(table))){
      # this is a query, so will be stored in a temporary table
      copy <- TRUE
    }

    if (is.na(copy) || is.null(copy)){
      warning("`copy` not specified, setting `copy=TRUE`, working on copy of table.", call. = FALSE)
      copy <- TRUE
    }

    table_ident <- get_tbl_name(table)

    if (isTRUE(copy)){
      table_name <- random_name()
      # table_name <- random_name(table_name)
      table <- dplyr::compute(table, name = table_name)
      table_ident <- get_tbl_name(table) %||% ident(table_name)
    }
    con <- dbplyr::remote_con(table)
  } else {
    table_ident <- dbplyr::as.sql(table, con=con)
    table <- dplyr::tbl(con, table_ident)
  }
  list(table = table, con = con, table_ident = table_ident)
}
