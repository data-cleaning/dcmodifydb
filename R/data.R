#' Person data with income and smoking habits
#'
#' A synthetic data set with records to be corrected.
#'
#'
#' @format A data frame with x rows and variables:
#' \describe{
#'   \item{income}{monthly income, in US dollars}
#'   \item{age}{age of a person in year}
#'   \item{gender}{gender of a person}
#'   \item{year}{year of measurement}
#'   \item{smokes}{if a person smokes or not}
#'   \item{cigarettes}{how many cigarretes a person smokes}
#'   ...
#' }
#' The dataset is also available as a sqlite database at
#' `system.file("db/person.db", package="dcmodifydb")`
"person"
