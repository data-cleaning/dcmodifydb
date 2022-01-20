random_name <- function(name){

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
