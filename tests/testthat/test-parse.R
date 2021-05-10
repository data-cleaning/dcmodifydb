describe("parse", {
  it("rewrites assigns to selections",{
    e <- quote(x[x>10] <- 10)
    e_rw <- rewrite_asign_select(e)
    expect_equal(e_rw, quote(x <- 10))
    expect_equal(guard(e_rw), quote(x>10))
  })

  it ("leaves normal assigns intact", {
    e <- quote(x <- 10)
    e_rw <- rewrite_asign_select(e)
    expect_equal(e_rw, e)
  })

  it("expands the guard",{
    e <- quote(x[x>10] <- 10)
    attr(e, "guard") <- quote(y > 0)
    e_rw <- rewrite_asign_select(e)
    expect_equal(e_rw, quote(x <- 10))
    expect_equal(guard(e_rw), quote(y > 0 & x>10))
  })

  it("knows is.na(x) assign",{
    e <- quote(is.na(x) <- x > 10)
    e_rw <- rewrite_asign_select(e)
    expect_equal(e_rw, quote(x <- NA))
    expect_equal(guard(e_rw), quote(x > 10))
  })

  it("errors on other assigns",{
    e <- quote(names(x) <- "a")
    expect_error({
      e_rw <- rewrite_asign_select(e)
    })

    e <- quote(x[[x>1]] <- 1)
    expect_error({
      e_rw <- rewrite_asign_select(e)
    })

  })


})
