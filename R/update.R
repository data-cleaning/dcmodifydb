#' Extract UPDATE statements
#'
#' Extract UPDATE statements from modifier object.
#' @export
#' @param x [dcmodify::modifier()] object
#' @param table table name
#' @param con optional connection
#' @return `list` of sql UPDATE statements.
modifier_to_sql <- function(x, table, con = NULL){
  stopifnot(inherits(x, "modifier"))
  tc <- get_table_con(table, con, copy=FALSE)
  asgn <- x$assignments()
  lapply(asgn, update_stmt, table=tc$table, con=tc$con)
}

#' @importFrom dbplyr translate_sql build_sql sql
update_stmt <- function(x, table, con, ..., na.condition=FALSE){
  if (!is_assignment(x)){
    return(NULL)
  }
  varname <- as.character(x[[2]])
  value <- do.call(translate_sql, list(x[[3]], con = con))
  where <- NULL

  g <- guard(x)

  if (!is.null(g)){
    where <- do.call(translate_sql, list(g, con = con))
    where <- build_sql("WHERE ", where, con = con)
    if (isTRUE(na.condition)){
      where <- build_sql("COALESCE(",where,"TRUE)")
    }
  }

  build_sql("UPDATE ", sql(table)
           ,  "\n", "SET ", varname
           ,         " = ", value
           ,  "\n", where
           , ";"
           , con=con
           )
}

#' Write generate sql
#'
#' Writes generates sql to file
#' @export
#' @param x [dcmodify::modifier()] object with rules to be written
#' @param table either a [dplyr::tbl()] object or a `character` with table name
#' @param con optional, when `table` is a character a dbi connection.
#' @param file to which the sql will be written.
dump_sql <- function(x, table, con = NULL, file = stdout()){
  sql <- modifier_to_sql(x, table, con)
  nms <- names(x)
  sql <- paste0("\n-- ", nms, "\n", sql)

  sql <- c("-- Generated with dcmodify version . from .\n\n", sql)
  writeLines(sql)
  invisible(sql)
}

get_table_con <- function(table, con = NULL, copy = NULL){
  if (inherits(table, "tbl_dbi")){
    if (!missing(con) && !is.null(con)){
      warning("ignoring `con`, taking connection from `table`", call. = FALSE)
    }

    if (is.na(copy) || is.null(copy)){
      warning("`copy` not specified, setting `copy=TRUE`, working on copy of table.", call. = FALSE)
      copy <- TRUE
    }

    if (isTRUE(copy)){
      table <- dplyr::compute(table)
    }
    con <- table$src$con
    table <- table$ops$x
  }
  list(table = table, con = con)
}

# simple approach write all assignments as update sql statements
