# create a dataset to be used for testing in dcmodifydb

person <- read.csv(text="
income, age, gender, year, smokes, cigarrettes
  2000,  12,      M, 2020,     no,          10
  2010,  14,      f, 2019,    yes,           4
  2010,  25,      v,   19,     no,
", strip.white=TRUE)

usethis::use_data(person, overwrite = TRUE)

