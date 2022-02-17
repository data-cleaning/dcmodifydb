library(dcmodify)
library(dcmodifydb)
m <- modifier( if (age  < 12) income <- 0)
d <- dbplyr::memdb_frame(income = 1000)

# age is missing so this rule cannot be applied
modify(d, m, copy = TRUE, ignore_nw=TRUE)

