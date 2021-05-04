library(dbplyr)
library(dcmodify)

describe("sql",{
  d <- tbl_memdb(data.frame(x = 1:2), "ds")
  it("dumps sql",{
    m <- modifier(if (x > 1) x <- 1)
    dcmodify::description(m) <- "Nonsense\n!!!!"

    expect_output_file(dump_sql(m, d), "dump.sql")
  })
})
