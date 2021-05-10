library(dcmodify)
library(dbplyr)

describe("update",{

  it("extracts assignments",{
    m <- modifier(if (gear > 3) carb <- 11)
    asgn <- get_assignments(m)
    expect_equal( guard(asgn[[1]]), quote(gear > 3))
  })

  tbl_mtcars <- tbl_memdb(mtcars)

  it("generates update statements",{
    m <- modifier( if (gear > 3) carb <- 11L
                 )
    sql <- modifier_to_sql(m, tbl_mtcars)
    expect_equal(sql[[1]], sql(
"UPDATE `mtcars`
SET `carb` = 11
WHERE `gear` > 3.0;"))
  })

  it("generates update statements",{
    m <- modifier(if (gear > 3) carb <- 11)
    asgn <- get_assignments(m)
    d <- tbl_memdb(mtcars, "na.c")
    tc <- get_table_con(d, copy=FALSE)
    update <- update_stmt( asgn[[1]]
                         , table = tc$table_name
                         , con = tc$con
                         , na.condition = TRUE
                         )

    expect_equal(update, sql(
"UPDATE `na.c`
SET `carb` = 11.0
WHERE COALESCE(`gear` > 3.0,1);"))
  })

  it("generates update statements",{
    m <- modifier( gear[is.na(gear)] <- 0L)
    sql <- modifier_to_sql(m, tbl_mtcars)
    expect_equal(sql[[1]], sql(
"UPDATE `mtcars`
SET `gear` = 0
WHERE ((`gear`) IS NULL);"))
  })

})
