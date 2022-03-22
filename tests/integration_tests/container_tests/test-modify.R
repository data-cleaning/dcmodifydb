library(dcmodify)
library(dbplyr)

describe("modify",{
  it("modifies a simple dataset",{

    con <- create_db_connection()

    dbWriteTable(conn = con, name = "d", value = data.frame(x = 1:2))
    d <- dplyr::tbl(con, "d")
    m <- modifier(if (x > 1) x <- 1)

    d_m <- modify(d, m, copy = FALSE)
    expect_equal(as.data.frame(d_m), data.frame(x = c(1,1)))

    # check if the table in the db is really changed...
    expect_equal(as.data.frame(d), data.frame(x = c(1,1)))
  })

  it("modifies a copy of a simple dataset",{
    con <- create_db_connection()

    dbWriteTable(conn = con, name = "d2", value = data.frame(x = 1:2))

    d <- dplyr::tbl(con, "d2")
    m <- modifier(if (x > 1) x <- 1)

    d_m <- modify(d, m, copy = TRUE)
    expect_equal(as.data.frame(d_m), data.frame(x = c(1,1)))

    # check if the table in the db has not been changed.
    expect_equal(as.data.frame(d), data.frame(x = c(1,2)))
  })

  it("modifies a copy of a simple dataset (unspecified",{
    con <- create_db_connection()

    dbWriteTable(conn = con, name = "d3", value = data.frame(x = 1:2))
    d <- dplyr::tbl(con, "d3")
    m <- modifier(if (x > 1) x <- 1)

    expect_warning({
      d_m <- modify(d, m)
    })
    expect_equal(as.data.frame(d_m), data.frame(x = c(1,1)))

    # check if the table in the db has not been changed.
    expect_equal(as.data.frame(d), data.frame(x = c(1,2)))
  })

  it("rollback when an modifier is not working",{
    con <- create_db_connection()

    dbWriteTable(conn = con, name = "d4", value = data.frame(x = 1:2))
    d <- dplyr::tbl(con, "d4")
    m <- modifier(if (x > 1) x <- 1, if (y > 2) x <- 2)

    expect_error({
      expect_warning({
        d_m <- modify(d, m, copy = FALSE)
      })
    })

    # check if the table in the db is really changed...
    expect_equal(as.data.frame(d), data.frame(x = c(1,2)))
  })

  it("adds a new column", {
    con <- create_db_connection()

    dbWriteTable(conn = con, name = "d5", value = data.frame(x = 1:2))
    d <- dplyr::tbl(con, "d5")
    m <- modifier(if (x > 1) y <- "two" else y <- "one")
    d_m <- modify(d, m, copy=TRUE)

    df <- as.data.frame(d)
    df_m <- as.data.frame(d_m)

    expect_true("y" %in% names(df_m))
    expect_equal(df_m$x, df$x)
    expect_equal(df_m$y,c("one","two"))
  })

  it("handles selection assign", {
    con <- create_db_connection()

    dbWriteTable(conn = con, name = "d6", value = data.frame(x = 1:2))
    d <- dplyr::tbl(con, "d6")
    m <- modifier(x[x>1] <- 1)
    d_m <- modify(d, m, copy=TRUE)
    expect_equal(as.data.frame(d_m), data.frame(x = c(1,1)))
  })

  it("handles NA assign", {
    con <- create_db_connection()

    dbWriteTable(conn = con, name = "d7", value = data.frame(x = 1:2))
    d <- dplyr::tbl(con, "d7")
    m <- modifier(is.na(x) <- x>1)
    d_m <- modify(d, m, copy=TRUE)
    expect_equal(as.data.frame(d_m), data.frame(x = c(1,NA)))
  })

  it("handles NA check", {
    con <- create_db_connection()

    dbWriteTable(conn = con, name = "d8", value = data.frame(x = c(1,NA)))
    d <- dplyr::tbl(con, "d8")
    m <- modifier(x[is.na(x)] <- 2)
    d_m <- modify(d, m, copy=TRUE)
    expect_equal(as.data.frame(d_m), data.frame(x = c(1,2)))
  })

  it("handles a non-working rule",{
    con <- create_db_connection()

    dbWriteTable(conn = con, name = "d9", value = data.frame(x = c(1,NA)))
    d <- dplyr::tbl(con, "d9")
    m <- modifier(if (y>1) x <- 3)

    expect_error({
      expect_warning({
        d_m <- modify(d, m, copy=TRUE)
      })
    })

    expect_warning({
      d_m <- modify(d, m, copy=TRUE, ignore_nw=TRUE)
    })

    expect_equal(as.data.frame(d_m), as.data.frame(d))

  })

  it("handles %in% guards", {
    con <- create_db_connection()

    dbWriteTable(conn = con, name = "d10", value = data.frame(nace = "A", turnover = 1000))
    d <- dplyr::tbl(con, "d10")
    
    m <- modifier(if (nace %in% "A") {turnover <- 0})
    

    d_m <- modify(d, m, copy=TRUE)
    expect_equal(as.data.frame(d_m), data.frame(nace = "A", turnover=0))
  })

})
