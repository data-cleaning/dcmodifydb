#' Show generated sql
#'
#' Writes the generated sql to a file or command line. The script contains ALTER and
#' UPDATE statements and can be used for documentation purposes.
#'
#' Note that when this script is run on the database it will change the
#' original table. This differs from the default behavior of dcmodify which
#' works on a (temporary) copy of the table.
#'
#' Furthermore, it seems wise to wrap the generated SQL in a transaction when
#' apply the SQL code on a database.
#' @export
#' @param x `dcmodify::modifier()` object with rules to be written
#' @param table either a [dplyr::tbl()] object or a `character` with table name
#' @param con optional, when `table` is a character, a dbi connection.
#' @param file to which the sql will be written.
#' @param ... not used
#' @return `character` sql script with all statements.
#' @importFrom validate description label origin
#' @example ./example/dump_sql.R
#' @family sql translation
dump_sql <- function(x, table, con = NULL, file = stdout(), ...){
  tc <- get_table_con(table, con, copy=FALSE)

  alt <- alter_stmt(x, tc$table, tc$table_ident, con = con)
  sql <- modifier_to_sql(x, tc$table)

  # TODO write expression!

  comments <- sql_comment( "\n", names(x), ": ", label(x)
                           , "\n", description(x)
                           , "\nR expression: ", validate::expr(x)
  )

  names(comments) <- names(x)

  comments <- comments[names(sql)]
  comments[is.na(comments)] <- ""

  sql <- paste0( comments
                 , "\n"
                 , sql
  )

  org <- paste0("'",unique(origin(x)),"'", collapse = " ,")
  args <- list(...)
  front <- paste0("-- ", c(
    "-------------------------------------",
    "Generated with dcmodifydb, do not edit",
    sprintf("dcmodify version: %s", utils::packageVersion("dcmodify")),
    sprintf("dcmodifydb version: %s", utils::packageVersion("dcmodifydb")),
    sprintf("dplyr version: %s", utils::packageVersion("dplyr")),
    sprintf("dbplyr version: %s", utils::packageVersion("dbplyr")),
    sprintf("from: %s", org),
    sprintf("date: %s", Sys.Date()),
    "-------------------------------------"
  ))

  sql <- c(
    # for testing this header can be skipped otherwise generating errors when versions
    # of packages change
    if (!isTRUE(args$skip_header)) {front}
    , "\n"
    , paste(alt, collapse = "\n\n")
    , sql
  )
  writeLines(sql, con = file)
  invisible(sql)
}

sql_comment <- function(..., sep = ""){
  x <- paste(..., sep = sep)
  I <- x != ""
  x[I] <- gsub("(^|\n)", "\\1-- ", x[I])
  # remove empty line
  x[I] <- gsub("\n-- $", "", x[I])
  x
}


