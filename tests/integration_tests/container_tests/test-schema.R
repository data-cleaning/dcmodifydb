library(DBI)
library(dbplyr)
library(RSQLite)
library(dcmodify)

describe("Schema's working", {
  con <- dbConnect(SQLite())
  tmp <- tempfile()
  schema <- dbConnect(SQLite(), db=tmp)

  DBI::dbExecute(con, sprintf("ATTACH '%s' as 'schema'", tmp))
  dbWriteTable(schema, "iris", iris, overwrite=TRUE)


  it("works a schema table", {
    ir <- dplyr::tbl(con, in_schema("schema", "iris"))
    m <- modifier(Sepal.Length <- 1)
    modify(ir, m, copy=FALSE)
    modifier_to_sql(m, ir)

  })
})
