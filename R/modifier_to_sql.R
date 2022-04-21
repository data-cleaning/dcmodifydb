#' Utility function to extract SQL statements
#'
#' Extract UPDATE statements from modifier object as a list of SQL statements.
#' A user should normally be using [modify()] or [dump_sql()], but this
#' function may be useful.
#' @importFrom dplyr tbl_vars
#' @export
#' @param x `dcmodify::modifier()` object
#' @param table table object
#' @param con optional connection
#' @param key `character` with column names that identify a row
#' @return `list` of sql UPDATE statements.
#' @family sql translation
modifier_to_sql <- function(x, table, con = NULL, key){
  stopifnot(inherits(x, "modifier"))

  tc <- get_table_con(table, con, copy=FALSE)
  check_key(tc$table, key)

  # print(list(table_ident = tc$table_ident))
  asgn <- get_assignments(x)
  lapply( asgn
        , update_stmt, table       = tc$table
                     , table_ident = tc$table_ident
                     , con         = tc$con
                     , key         = key
        )
}
