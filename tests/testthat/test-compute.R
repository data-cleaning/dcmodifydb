library(dcmodify)
library(dbplyr)

describe("compute",{
  it("handles compute with a new column, issue #8", {
    d <- memdb_frame(x = 1)
    m <- modifier(y <- x + 1)
    d2 <- modify(d, m, copy=TRUE)
    d3 <- dplyr::compute(d2)

    d1 <- data.frame(x = 1, y = 2)
    expect_equal(as.data.frame(d2), d1)
    expect_equal(as.data.frame(d3), d1)
  })
})
