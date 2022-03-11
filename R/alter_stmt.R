#' @importFrom dbplyr ident ident_q
alter_stmt <- function(x, table, table_ident, con){
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
  tab <- utils::head(eval(mut))

  # getting datatypes
  df <- as.data.frame(tab)
  types <- DBI::dbDataType(con, df)
  #print(types)

  # qry <- dbplyr::remote_query(tab)
  #
  # rs <- DBI::dbSendQuery(con, qry)
  # ci <- DBI::dbColumnInfo(rs)
  # DBI::dbClearResult(rs)

  new_vars <- types[!names(types) %in% org_vars]
  add_column <- FALSE

  add_ <- if (add_column) sql("\nADD COLUMN ") else sql("\nADD ")

  lapply(names(new_vars), function(n){
    build_sql(
      "ALTER TABLE ", table_ident
      , add_
      , ident(n), " ", unname(sql(new_vars[n])), ";"
      , con = con
    )
  })
}
