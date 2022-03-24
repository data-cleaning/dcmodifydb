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
    DBI::dbDisconnect(con, shutdown=TRUE)
 })


 it("handles the new gear test",{
   skip_on_cran()

   skip_if_not_installed("duckdb")
   con <- DBI::dbConnect(duckdb(), dbdir=":memory:")

   mtcars_dd <- dplyr::copy_to(con, mtcars, overwrite=TRUE)
   mtcars_sqlite <- do.call(dbplyr::memdb_frame, as.list(mtcars))
   m <- modifier( if (cyl == 6) {
     new_gear <- 10
   } else if (cyl == 4) {
     new_gear <- 25
   } else {
     new_gear <- NA
   })

   mtcars_dd_c <- modify(mtcars_dd, m, copy = FALSE)
   mtcars_sqlite_c <- modify(mtcars_sqlite, m, copy = FALSE)
   expect_equal(as.data.frame(mtcars_dd_c), as.data.frame(mtcars_sqlite_c))
   DBI::dbDisconnect(con, shutdown=TRUE)
 })
})
