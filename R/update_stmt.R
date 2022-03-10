#' @importFrom dbplyr translate_sql build_sql sql
update_stmt <- function(x, table, table_ident, con, ..., na.condition=FALSE){
  # assumes that all columns are available...

  if (!is_assignment(x) && !is.symbol(x[[2]])){
    return(NULL)
  }


  varname <- as.character(x[[2]])

  value <- do.call(translate_sql, list(x[[3]], con = con))
  where <- NULL

  g <- guard(x)

  if (!is.null(g)){
    g <- replace_vin(g)
    qry_f <- eval(bquote(dplyr::filter(table, .(g))))
    qry <- dbplyr::sql_build(qry_f)
    where <- qry$where
    if (isTRUE(na.condition)){
      where <- build_sql("COALESCE(",where,",1)", con = con)
    }
    where <- build_sql("WHERE ", where, con = con)
    where <- sql(where)
  }
  build_sql("UPDATE ", table_ident
            ,  "\n", "SET ", ident(varname)
            ,         " = ", value
            ,  "\n", where
            , ";"
            , con=con
  )
}

# fix for vin in validate...
replace_vin <- function(e){
  if (is.call(e)){
    if (e[[1]] == "%vin%"){
      return(substitute( a %in% b, list(a = e[[2]], b =e[[3]])))
    }
    e[[2]] <- replace_vin(e[[2]])
    if (length(e) > 2){
      e[[3]] <- replace_vin(e[[3]])
    }
  }
  e
}

