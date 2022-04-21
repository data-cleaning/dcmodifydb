random_name <- function(name = NULL){
  # if name is a table name with a schema, this does not work correctly
  # so currently switching back to the name dcmodify

  if (is.null(name)){
    name <- "dcmodifydb"
  }

  num <- sample(1e7, 1) - 1
  sprintf("%s_%06d", name, num)
}


`%||%` <- function(a,b){
  if (is.null(a) || anyNA(a)){
    b
  } else {
    a
  }
}

check_key <- function(tbl, key = NULL){
  colnms <- dplyr::tbl_vars(tbl)
  if (is.character(key)){
    key_in_table <- key %in% colnms
    if (!all(key_in_table)){
      key_nf <- paste0("'", key[!key_in_table], "'", collapse = ", ")
      stop("key(s) ", key_nf," not recognized as a column", call. = FALSE)
    }
  } else {
    stop("Use the 'key' argument to indicate the columns that identify a row.", call. = FALSE)
  }
  key
}
