guard <- function(x){
  attr(x, "guard")
}

# set_guard <- function(x, guard){
#   attr(x, "guard") <- guard
#   x
# }

is_assignment <- function(e){
  is.call(e) && as.character(e[[1]]) %in% c("<-", "=", ":=")
}

