#' Person data, income and smoking habits
#'
#' A synthetic data set with person data with records to be corrected.
#' The datasethas missing values
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
#' @example ./example/person.R
"person"
