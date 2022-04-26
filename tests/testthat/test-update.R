library(dcmodify)
library(dbplyr)

describe("update",{

  it("extracts assignments",{
    m <- modifier(if (gear > 3) carb <- 11)
    asgn <- get_assignments(m)
    expect_equal( guard(asgn[[1]]), quote(gear > 3))
  })

  mtcars$name <- rownames(mtcars)
  tbl_mtcars <- tbl_memdb(mtcars)

  it("generates update statements",{
    m <- modifier( if (gear > 3) carb <- 11L
                 )
    sql <- modifier_to_sql(m, tbl_mtcars, key  = "name")
    expect_equal(sql[[1]], sql(
"UPDATE `mtcars` AS T
SET `carb` = U.`carb`
FROM
(SELECT `name`, 11 AS `carb`
FROM `mtcars`) AS U
WHERE T.`name` = U.`name`
  AND T.`gear` > 3.0;"))
  })

  it("generates update statements",{
    m <- modifier(if (gear > 3) carb <- 11)
    asgn <- get_assignments(m)
    d <- tbl_memdb(mtcars, "na.c")
    tc <- get_table_con(d, copy=FALSE)
    update <- update_stmt( asgn[[1]]
                         , table  = tc$table
                         , table_ident = tc$table_ident
                         , con = tc$con
                         , key = "name"
                         , na.condition = TRUE
                         )

    expect_equal(update, sql(
"UPDATE `na.c` AS T
SET `carb` = U.`carb`
FROM
(SELECT `name`, 11.0 AS `carb`
FROM `na.c`) AS U
WHERE T.`name` = U.`name`
  AND COALESCE(T.`gear` > 3.0, 1);"))
  })

  it("generates update statements",{
    m <- modifier( gear[is.na(gear)] <- 0L)
    sql <- modifier_to_sql(m, tbl_mtcars, key = "name")
    expect_equal(sql[[1]], sql(
"UPDATE `mtcars` AS T
SET `gear` = U.`gear`
FROM
(SELECT `name`, 0 AS `gear`
FROM `mtcars`) AS U
WHERE T.`name` = U.`name`
  AND ((T.`gear`) IS NULL);"))
  })

})
