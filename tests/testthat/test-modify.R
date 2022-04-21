library(dcmodify)
library(dbplyr)

describe("modify",{
  it("modifies a simple dataset",{
    d <- tbl_memdb(data.frame(id=letters[1:2], x = 1:2), "d")
    m <- modifier(if (x > 1) x <- 1)

    d_m <- modify(d, m, copy = FALSE,key="id")
    expect_equal(as.data.frame(d_m), data.frame(id=letters[1:2],x = c(1,1)))

    # check if the table in the db is really changed...
    expect_equal(as.data.frame(d), data.frame(id=letters[1:2], x = c(1,1)))
  })

  it("modifies a copy of a simple dataset",{
    d <- tbl_memdb(data.frame(id=letters[1:2], x = 1:2), "d2")
    m <- modifier(if (x > 1) x <- 1)

    d_m <- modify(d, m, copy = TRUE, key = "id")
    expect_equal(as.data.frame(d_m), data.frame(id = letters[1:2],x = c(1,1)))

    # check if the table in the db has not been changed.
    expect_equal(as.data.frame(d), data.frame(id = letters[1:2],x = c(1,2)))
  })

  it("modifies a copy of a simple dataset (unspecified",{
    d <- tbl_memdb(data.frame(id=letters[1:2],x = 1:2), "d3")
    m <- modifier(if (x > 1) x <- 1)

    expect_warning({
      d_m <- modify(d, m, key = "id")
    })
    expect_equal(as.data.frame(d_m), data.frame(id=letters[1:2], x = c(1,1)))

    # check if the table in the db has not been changed.
    expect_equal(as.data.frame(d), data.frame(id = letters[1:2], x = c(1,2)))
  })

  it("rollback when an modifier is not working",{
    d <- tbl_memdb(data.frame(id = letters[1:2], x = 1:2), "d4")
    m <- modifier(if (x > 1) x <- 1, if (y > 2) x <- 2)

    expect_error({
      expect_warning({
        d_m <- modify(d, m, copy = FALSE, key = "id")
      })
    })

    # check if the table in the db is really changed...
    expect_equal(as.data.frame(d), data.frame(id = letters[1:2], x = c(1,2)))
  })

  it("adds a new column", {
    d <- memdb_frame(id = letters[1:2], x = 1:2)
    m <- modifier(if (x > 1) y <- "two" else y <- "one")
    d_m <- modify(d, m, copy=TRUE, key = "id")

    df <- as.data.frame(d)
    df_m <- as.data.frame(d_m)

    expect_true("y" %in% names(df_m))
    expect_equal(df_m$x, df$x)
    expect_equal(df_m$y,c("one","two"))
  })

  it("handles selection assign", {
    d <- tbl_memdb(data.frame(id = letters[1:2], x = 1:2), "d6")
    m <- modifier(x[x>1] <- 1)
    d_m <- modify(d, m, copy=TRUE, key = "id")
    expect_equal(as.data.frame(d_m), data.frame(id = letters[1:2], x = c(1,1)))
  })

  it("handles NA assign", {
    d <- tbl_memdb(data.frame(id = letters[1:2], x = 1:2), "d7")
    m <- modifier(is.na(x) <- x>1)
    d_m <- modify(d, m, copy=TRUE, key = "id")
    expect_equal(as.data.frame(d_m), data.frame(id = letters[1:2], x = c(1,NA)))
  })

  it("handles NA check", {
    d <- tbl_memdb(data.frame(id = letters[1:2], x = c(1,NA)), "d8")
    m <- modifier(x[is.na(x)] <- 2)
    d_m <- modify(d, m, copy=TRUE, key = "id")
    expect_equal(as.data.frame(d_m), data.frame(id = letters[1:2], x = c(1,2)))
  })

  it("handles a non-working rule",{
    d <- memdb_frame(id = letters[1:2], x = c(1,2))
    m <- modifier(if (y>1) x <- 3)

    expect_error({
      expect_warning({
        d_m <- modify(d, m, copy=TRUE, key = "id")
      })
    })

    expect_warning({
      d_m <- modify(d, m, copy=TRUE, ignore_nw=TRUE, key = "id")
    })

    expect_equal(as.data.frame(d_m), as.data.frame(d))

  })

  it("handles %in% guards", {
    m <- modifier(if (nace %in% "A") {turnover <- 0})
    d <- dbplyr::memdb_frame(id = letters[1], nace = "A", turnover = 1000)

    d_m <- modify(d, m, copy=TRUE, key = "id")
    expect_equal(as.data.frame(d_m), data.frame(id = letters[1], nace = "A", turnover=0))
  })

  it("handles aggregate functions", {
    m <- modifier(if (is.na(turnover)) {turnover <- mean(turnover, na.rm=TRUE)})
    d <- dbplyr::memdb_frame(id = letters[1:3], turnover = c(NA, 1000, 3000))
    d_m <- modify(d, m, copy=TRUE, key = "id")
    expect_equal(as.data.frame(d_m), data.frame(id = letters[1:3], turnover=c(2000,1000,3000)))
  })

  it("errors with no key", {
    d <- memdb_frame(id=letters[1:2], x = 1:2)
    m <- modifier(if (x > 1) x <- 1)

    expect_error({
      d_m <- modify(d, m, copy = FALSE)
    })
  })

  it("errors with wrong key", {
    d <- memdb_frame(id=letters[1:2], id2=LETTERS[1:2], x = 1:2)
    m <- modifier(if (x > 1) x <- 1)

    expect_error({
      d_m <- modify(d, m, copy = FALSE, key="no_id")
    })

    expect_error({
      d_m <- modify(d, m, copy = FALSE, key=c("id2", "no_id"))
    })

  })

  it("handles multiple keys", {
    d <- memdb_frame(id=letters[1:2], id2=LETTERS[1:2], x = 1:2)
    df <- as.data.frame(d)

    m <- modifier(if (x > 1) x <- 1)

    d_m <- modify(d, m, copy = FALSE, key=c("id", "id2"))
    df_m <- modify(df, m)

    expect_equal(as.data.frame(d_m), df_m)

  })



})
