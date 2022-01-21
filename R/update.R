#' Extract UPDATE statements
#'
#' Extract UPDATE statements from modifier object as a list of SQL statements.
#' @importFrom dplyr tbl_vars
#' @export
#' @param x `dcmodify::modifier()` object
#' @param table table object
#' @param con optional connection
#' @return `list` of sql UPDATE statements.
modifier_to_sql <- function(x, table, con = NULL){
  stopifnot(inherits(x, "modifier"))
  tc <- get_table_con(table, con, copy=FALSE)
  # print(list(table_ident = tc$table_ident))
  asgn <- get_assignments(x)
  lapply(asgn, update_stmt, table_ident=tc$table_ident, con=tc$con)
}

#' @importFrom dbplyr ident ident_q
alter_stmt <- function(x, table, table_ident){
  org_vars <- dplyr::tbl_vars(table)

  # just for querying meta data
  tab <- utils::head(table, 2)
  con <- dbplyr::remote_con(table)

  # collect all assignments
  as <- get_assignments(x)

  vars <- sapply(as, function(a) a[[2]], USE.NAMES = FALSE)
  asgns <- sapply(as, function(a) a[[3]])

  names(asgns) <- vars
  mut <- bquote(dplyr::mutate(tab, ..(asgns)), splice = TRUE)
  tab <- eval(mut)
  qry <- dbplyr::remote_query(tab)

  rs <- DBI::dbSendQuery(con, qry)
  ci <- DBI::dbColumnInfo(rs)
  DBI::dbClearResult(rs)

  new_vars <- ci[!(ci$name %in% org_vars),]

  lapply(new_vars$name, function(n){
    build_sql(
      "ALTER TABLE ", table_ident,
      "\nADD COLUMN ", ident(n), " ", sql(new_vars$type[new_vars$name == n]), ";"
      , con = con
      )
  })
}

#' @importFrom dbplyr translate_sql build_sql sql
update_stmt <- function(x, table_ident, con, ..., na.condition=FALSE){
  # assumes that all columns are available...

  if (!is_assignment(x) && !is.symbol(x[[2]])){
    return(NULL)
  }


  varname <- as.character(x[[2]])

  value <- do.call(translate_sql, list(x[[3]], con = con))
  where <- NULL

  g <- guard(x)

  if (!is.null(g)){
    where <- do.call(translate_sql, list(g, con = con))
    if (isTRUE(na.condition)){
      where <- build_sql("COALESCE(",where,",1)", con = con)
    }
    where <- build_sql("WHERE ", where, con = con)
  }

  build_sql("UPDATE ", table_ident
           ,  "\n", "SET ", ident(varname)
           ,         " = ", value
           ,  "\n", where
           , ";"
           , con=con
           )
}

#' Write generated sql
#'
#' Writes the generated sql to a file. The script contains ALTER and
#' UPDATE statements and can be used as documentation.
#' Note that when this script is run on the database it will change the
#' original table. This differs from the default behavior of dcmodify which
#' works on a (temporary) copy of the table.
#' @export
#' @param x `dcmodify::modifier()` object with rules to be written
#' @param table either a [dplyr::tbl()] object or a `character` with table name
#' @param con optional, when `table` is a character, a dbi connection.
#' @param file to which the sql will be written.
#' @param ... not used
#' @return `character` sql script with all statements.
#' @importFrom validate description label origin
dump_sql <- function(x, table, con = NULL, file = stdout(), ...){
  tc <- get_table_con(table, con, copy=FALSE)

  alt <- alter_stmt(x, tc$table, tc$table_ident)
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
    sprintf("from: %s", org),
    if (!isTRUE(args$skip_date)){
      sprintf("date: %s", Sys.Date())
    },

    "-------------------------------------"
  ))

  sql <- c(
    front
    , "\n"
    , paste(alt, collapse = "\n\n")
    , sql
    )
  writeLines(sql)
  invisible(sql)
}

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

    if (is.null(dbplyr::remote_name(table))){
      # this is a query, so will be stored in a temporary table
      copy <- TRUE
    }

    if (is.na(copy) || is.null(copy)){
      warning("`copy` not specified, setting `copy=TRUE`, working on copy of table.", call. = FALSE)
      copy <- TRUE
    }

    table_ident <- dbplyr::remote_name(table)

    if (isTRUE(copy)){
      table_name <- random_name()
      # table_name <- random_name(table_name)
      table <- dplyr::compute(table, name = table_name)
      table_ident <- dbplyr::remote_name(table) %||% ident(table_name)
    }
    con <- dbplyr::remote_con(table)
  } else {
    table_ident <- ident(table)
    table <- dplyr::tbl(con, table)
  }
  list(table = table, con = con, table_ident = table_ident)
}

sql_comment <- function(..., sep = ""){
  x <- paste(..., sep = sep)
  I <- x != ""
  x[I] <- gsub("(^|\n)", "\\1-- ", x[I])
  # remove empty line
  x[I] <- gsub("\n-- $", "", x[I])
  x
}

# simple approach write all assignments as update sql statements
