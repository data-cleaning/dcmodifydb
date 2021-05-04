library(dcmodify)
library(dbplyr)

describe("modify",{
  it("modifies a simple dataset",{
    d <- tbl_memdb(data.frame(x = 1:2), "d")
    m <- modifier(if (x > 1) x <- 1)

    d_m <- modify(d, m, copy = FALSE)
    expect_equal(as.data.frame(d_m), data.frame(x = c(1,1)))

    # check if the table in the db is really changed...
    expect_equal(as.data.frame(d), data.frame(x = c(1,1)))
  })

  it("modifies a copy of a simple dataset",{
    d <- tbl_memdb(data.frame(x = 1:2), "d2")
    m <- modifier(if (x > 1) x <- 1)

    d_m <- modify(d, m, copy = TRUE)
    expect_equal(as.data.frame(d_m), data.frame(x = c(1,1)))

    # check if the table in the db has not been changed.
    expect_equal(as.data.frame(d), data.frame(x = c(1,2)))
  })

  it("modifies a copy of a simple dataset (unspecified",{
    d <- tbl_memdb(data.frame(x = 1:2), "d3")
    m <- modifier(if (x > 1) x <- 1)

    expect_warning({
      d_m <- modify(d, m)
    })
    expect_equal(as.data.frame(d_m), data.frame(x = c(1,1)))

    # check if the table in the db has not been changed.
    expect_equal(as.data.frame(d), data.frame(x = c(1,2)))
  })

  it("rollback when an modifier is not working",{
    d <- tbl_memdb(data.frame(x = 1:2), "d4")
    m <- modifier(if (x > 1) x <- 1, if (y > 2) x <- 2)

    expect_error({
      expect_warning({
        d_m <- modify(d, m, copy = FALSE)
      })
    })

    # check if the table in the db is really changed...
    expect_equal(as.data.frame(d), data.frame(x = c(1,2)))
  })


})
