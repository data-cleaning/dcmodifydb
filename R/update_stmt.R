#' @importFrom dbplyr translate_sql build_sql sql
update_stmt <- function(x, table, table_ident, con, key, ..., na.condition=FALSE){
  # assumes that all columns are available...

  if (!is_assignment(x) && !is.symbol(x[[2]])){
    return(NULL)
  }

  # library(dplyr)
  # library(dbplyr)
  #
  # A <- memdb_frame(id = "A", id2 = "a", age = 10)
  # con <- remote_con(A)
  #
  #
  # col_name <- ident("age")
  # key <- c("id", "id2")
  #
  # asgn <- list(age = 1)
  # guard <- quote(age > 2)
  #
  # v <- all.vars(guard)
  #
  # prefix_var <- function(e, vars){
  #   if (length(e) > 1){
  #     e[-1] <- lapply(e[-1], prefix_var, vars = vars)
  #   }
  #   if (is.symbol(e)){
  #     if (as.character(e) %in% vars){
  #       e <- substitute(T$v, list(v = e))
  #     }
  #   }
  #   e
  # }
  #
  # guard_t <- prefix_var(guard, vars = all.vars(guard))
  # g_s <- translate_sql(!!guard_t, con = con)
  # where <- g_s
  #
  # keys <- sapply(key, as.symbol)
  # qry <- transmute(A, !!!keys, !!!asgn)
  # show_query(qry)
  # qry
  #
  # tab <- remote_name(A)
  #
  # key_i <- ident(key)
  #
  #
  # where_key <- sapply(key, function(k){
  #   build_sql("T.", ident(k), " = U.", ident(k), con = con)
  # })
  # where_key <- sql(paste(where_key, collapse = " AND "))
  #
  # build_sql("UPDATE ",tab," as T\n",
  #           "SET ",col_name," = U.", col_name  ,"\n",
  #           "FROM\n",
  #           "(",sql_render(qry),") as U\n",
  #           "WHERE ",sql(where_key),"\n",
  #           "  AND ", where,
  #           ";", con = con) -> s
  #
  #
  # s
  # DBI::dbExecute(con, s)
  # A
  #

  keylist <- lapply(key, as.symbol)

  varname <- as.character(x[[2]])
  col_name <- ident(varname)

  # value derivation with transmute
  .value <- list(x[[3]])
  names(.value) <- varname
  qry <- dplyr::transmute(table, !!!keylist, !!!.value)

  where <- NULL

  where_key <- sapply(key, function(k){
    build_sql(sql("T."), ident(k), sql(" = U."), ident(k), con = con)
  })

  g <- guard(x)
  where_guard <- if (!is.null(g)){
    g <- replace_vin(g)
    g_t <- prefix_var(g, vars = all.vars(g))

    if (isTRUE(na.condition)){
      translate_sql(dplyr::coalesce(!!g_t, 1L), con = con)
    } else {
      translate_sql(!!g_t, con = con)
    }
  }

  where_clause <- c(where_key, where_guard)
  if (length(where_clause) > 0){
    where <- build_sql("WHERE "
                      , sql(paste(where_clause, collapse = "\n  AND "))
                      , con = con
                      )
    t_q <- dbplyr::escape(ident("T"), con=con)
    where <- gsub(t_q, "T", where, fixed=TRUE)
    where <- sql(where)
  }

  # browser()
  s <- build_sql("UPDATE ",table_ident," AS T\n",
            "SET ", col_name," = U.", col_name  ,"\n",
            "FROM\n",
            "(",dbplyr::sql_render(qry),") AS U\n",
            where,
            ";", con = con)
  s
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

# prefix a variable in an expression with a prefix T$
prefix_var <- function(e, vars){
  if (length(e) > 1){
    e[-1] <- lapply(e[-1], prefix_var, vars = vars)
  }
  if (is.symbol(e)){
    if (as.character(e) %in% vars){
      e <- substitute(T$v, list(v = e))
    }
  }
  e
}
