random_name <- function(name){

  if (is.null(name)){
    name <- "dcmodifydb"
  }

  num <- sample(1e7, 1) - 1
  sprintf("%s_%06d", name, num)
}
