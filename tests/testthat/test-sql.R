library(dbplyr)
library(dcmodify)

describe("sql",{
  d <- tbl_memdb(data.frame(id = letters[1:2], age = c(11, 130), income = c(10, 10)), "ds")
  it("dumps sql",{
    m <- modifier(.file="test-sql.yml")
    expect_output_file(dump_sql(m, d, skip_header=TRUE, key = "id"), "dump.sql")
  })
})
