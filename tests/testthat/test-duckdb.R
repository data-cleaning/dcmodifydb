library(dcmodify)

describe("Test against duckdb", {
  it("handles the person dataset", {
    skip_on_cran()

    skip_if_not_installed("duckdb")
    attachNamespace("duckdb")

    con <- DBI::dbConnect(duckdb(), dbdir=":memory:")
    person_dd <- dplyr::copy_to(con, person)

    person_sqlite <- dbplyr::tbl_memdb(person)

    m <- modifier(.file = system.file("db/corrections.yml", package="dcmodifydb"))

    person_c <- modify(person_sqlite, m, copy=FALSE)
    person_dd_c <- modify(person_dd, m, copy=FALSE)
    expect_equal(as.data.frame(person_dd_c), as.data.frame(person_c))
 })
})
