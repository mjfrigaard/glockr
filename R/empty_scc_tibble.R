#' Return an empty tibble with the correct schema
#' @keywords internal
empty_scc_tibble <- function(by_file = FALSE) {
  if (!by_file) {
    tibble::tibble(
      language            = character(),
      files               = integer(),
      lines               = integer(),
      code                = integer(),
      comments            = integer(),
      blanks              = integer(),
      complexity          = integer(),
      weighted_complexity = integer(),
      bytes               = integer(),
      uloc                = integer()
    )
  } else {
    tibble::tibble(
      language            = character(),
      filename            = character(),
      location            = character(),
      lines               = integer(),
      code                = integer(),
      comments            = integer(),
      blanks              = integer(),
      complexity          = integer(),
      weighted_complexity = integer(),
      bytes               = integer(),
      generated           = logical(),
      minified            = logical()
    )
  }
}
