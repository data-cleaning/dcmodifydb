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

get_tbl_name <- function(x){
  name <- dbplyr::remote_name(x)
  if (is.null(name)){
    if (isTRUE(x$ops$name == "ungroup")){
      name <- x$ops$x$x
    }
  }
  name
}
