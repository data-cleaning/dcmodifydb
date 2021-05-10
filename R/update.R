#' Extract UPDATE statements
#'
#' Extract UPDATE statements from modifier object.
#' @importFrom dplyr tbl_vars
#' @export
#' @param x `dcmodify::modifier()` object
#' @param table table name
#' @param con optional connection
#' @return `list` of sql UPDATE statements.
modifier_to_sql <- function(x, table, con = NULL){
  stopifnot(inherits(x, "modifier"))
  tc <- get_table_con(table, con, copy=FALSE)

  asgn <- get_assignments(x)
  lapply(asgn, update_stmt, table=tc$table_name, con=tc$con)
}

#' @importFrom dbplyr ident ident_q
alter_stmt <- function(x, table, table_name){
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
      "ALTER TABLE ", ident_q(table_name),
      "\nADD COLUMN ", ident(n), " ", sql(new_vars$type[new_vars$name == n]), ";"
      , con = con
      )
  })
}

#' @importFrom dbplyr translate_sql build_sql sql
update_stmt <- function(x, table, con, ..., na.condition=FALSE){
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

  build_sql("UPDATE ", sql(table)
           ,  "\n", "SET ", ident(varname)
           ,         " = ", value
           ,  "\n", where
           , ";"
           , con=con
           )
}

#' Write generated sql
#'
#' Writes generated sql to file
#' @export
#' @param x `dcmodify::modifier()` object with rules to be written
#' @param table either a [dplyr::tbl()] object or a `character` with table name
#' @param con optional, when `table` is a character a dbi connection.
#' @param file to which the sql will be written.
#' @param ... not used
#' @importFrom validate description label origin
dump_sql <- function(x, table, con = NULL, file = stdout(), ...){
  tc <- get_table_con(table, con, copy=FALSE)

  alt <- alter_stmt(x, tc$table, tc$table_name)
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

    table_name <- dbplyr::remote_name(table)

    if (isTRUE(copy)){
      table_name <- random_name(table_name)
      table <- dplyr::compute(table, name = table_name)
    }
    con <- dbplyr::remote_con(table)
  } else {
    table_name <- table
    table <- dplyr::tbl(con, table)
  }
  list(table = table, con = con, table_name = table_name)
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
