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

get_assignments <- function(x, ...){
  asgn <- x$assignments(...)
  lapply(asgn, rewrite_asign_select)
}

rewrite_asign_select <- function(e){
  if (!is_assignment(e)){
    return(e)
  }

  v <- e[[2]]
  if (is.symbol(v)){
    return(e)
  }

  if (!is.call(v)){
    stop("Invalid syntax: '",deparse(e),"'", call. = FALSE)
  }

  if (v[[1]] == "["){
    e[[2]] <- v[[2]]
    g <- v[[3]]
  } else if (v[[1]] == "is.na"){
    e[[2]] <- v[[2]]
    g <- e[[3]]
    e[[3]] <- NA
  } else {
    stop("Invalid syntax: '",deparse(e),"'", call. = FALSE)
  }

  g <- Reduce( function(e1,e2){bquote(.(e1) & .(e2))}
             , c(guard(e), g)
             )

  attr(e, "guard") <- g
  e
}

# test
#e <- quote(x[x>10] <- 10)

#e <- quote(x[[x>10]] <- 10)
