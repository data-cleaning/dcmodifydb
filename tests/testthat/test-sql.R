library(dbplyr)
library(dcmodify)

describe("sql",{
  d <- tbl_memdb(data.frame(age = c(11, 130), income = c(10, 10)), "ds")
  it("dumps sql",{
    m <- modifier(.file="test-sql.yml")
    expect_snapshot(
      dump_sql(m, d, skip_header=TRUE)
    )
  })
})
