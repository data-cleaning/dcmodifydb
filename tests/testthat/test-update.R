library(dcmodify)
library(dbplyr)

describe("update",{

  it("extracts assignments",{
    m <- modifier(if (gear > 3) carb <- 11)
    asgn <- m$assignments()
    expect_equal( guard(asgn[[1]]), quote(gear > 3))
  })

  tbl_mtcars <- tbl_memdb(mtcars)

  it("generates update statements",{
    m <- modifier(if (gear > 3) carb <- 11)
    asgn <- m$assignments()
    sql <- modifier_to_sql(m, tbl_mtcars)
    expect_equal(sql[[1]], sql(
"UPDATE `mtcars`
SET 'carb' = 11.0
WHERE `gear` > 3.0;"))
  })

})
