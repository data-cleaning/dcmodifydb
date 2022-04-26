library(dcmodify)

describe("simulate mssql", {
  con <- dbplyr::simulate_mssql()

  d <- dbplyr::lazy_frame(id = letters[1:2], x = 1:2, y = 1:2, con = con)
  m <- modifier(is.na(x) <- x > 1, if ( y > 1) x <- 2)

  asgns <- get_assignments(m)
  u1 <- update_stmt(asgns$M1, d, ident("d"), con = con, key = "id")
  expect_equal(u1, sql(
"UPDATE `d` AS T
SET `x` = U.`x`
FROM
(SELECT `id`, NULL AS `x`
FROM `df`) AS U
WHERE T.`id` = U.`id`
  AND T.`x` > 1.0;"
  ))

  u2 <- update_stmt(asgns$M2, d, ident("d"), con = con, key = "id")
  expect_equal(u2, sql(
"UPDATE `d` AS T
SET `x` = U.`x`
FROM
(SELECT `id`, 2.0 AS `x`
FROM `df`) AS U
WHERE T.`id` = U.`id`
  AND T.`y` > 1.0;"
  ))

})
