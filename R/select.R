
modifier_to_mutate <- function(x){
  as <- get_assignments(x)
  vars <- lapply(as, function(a){
    a[[2]]
  })

  cw <- lapply(as, function(a){
    var <- a[[2]]
    g <- guard(a)
    e <- a[[3]]
    if (is.null(g)){
      bquote(.(e))
    } else {
      bquote(if_else(.(g), .(e), .(var)))
    }
  })
  names(cw) <- vars
  bquote(dplyr::mutate(table, ..(cw)), splice=TRUE)
}

modifier_to_select <- function(x, table, con = NULL){
  mut <- modifier_to_mutate(x)
  query <- eval(mut)
  query
}

# x <- modifier( if (age > 130) age = 130
#              , if (age < 12) income = 0
#              , age <- 1
#              )
