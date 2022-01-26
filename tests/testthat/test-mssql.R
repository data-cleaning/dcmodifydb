library(dcmodify)

describe("simulate mssql", {
  con <- dbplyr::simulate_mssql()

  d <- dbplyr::lazy_frame(x = 1:2, y = 1:2, con = con)
  m <- modifier(is.na(x) <- x > 1, if ( y > 1) x <- 2)

  asgns <- get_assignments(m)
  u1 <- update_stmt(asgns$M1, d, ident("d"), con = con)
  expect_equal(u1, sql(
"UPDATE `d`
SET `x` = NULL
WHERE `x` > 1.0;"
  ))

  u2 <- update_stmt(asgns$M2, d, ident("d"), con = con)
  expect_equal(u2, sql(
"UPDATE `d`
SET `x` = 2.0
WHERE `y` > 1.0;"
  ))

})
