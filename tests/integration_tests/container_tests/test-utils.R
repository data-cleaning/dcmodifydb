describe("utils",{
  it("generate a name from NULL",{
    set.seed(1)
    name <- random_name(NULL)
    expect_equal(name, "dcmodifydb_856017")
  })

  it("generate a name from table_name",{
    set.seed(1)
    name <- random_name("table_name")
    expect_equal(name, "table_name_856017")
  })

})
