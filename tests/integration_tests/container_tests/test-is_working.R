library(dbplyr)
library(dcmodify)

describe("is working",{
  it("is working",{

    con <- create_db_connection()

    dbWriteTable(conn = con, name = "is_working", value = data.frame(x = 1:2))
    tab <- dplyr::tbl(con, "is_working")
    m <- modifier(if (x > 1) x <- 1)

    # updates <- modifier_to_sql(m, tab)
    working <- is_working_db(m, tab)

    expect_equal(working, TRUE)
  })

  it("is working check",{



    con <- create_db_connection()

    dbWriteTable(con, "is_working_check", data.frame(x = 1:2))
    tab <- dplyr::tbl(con, "is_working_check")
    df <- as.data.frame(tab)

    m <- modifier( if (x > 1) x <- 1
                 , if (x > 2) y <- 1
                 , if (z > 2) w <- 1
                 , if (x < 0) x <- 0
                 )

    expect_warning({
      working <- is_working_db(m, tab)
    })

    expect_equal(working, c(TRUE, TRUE, FALSE, TRUE))
    expect_equal(as.data.frame(tab), df)
  })
})
