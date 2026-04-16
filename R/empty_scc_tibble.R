#' Return an empty tibble with the correct schema
#'
#' Used as a safe fallback when `scc` produces no output (e.g. an empty
#' directory or no files matching the requested extensions).
#'
#' @param by_file Logical. When `TRUE` returns the per-file schema (12
#'   columns); when `FALSE` (default) returns the per-language schema (10
#'   columns).
#'
#' @return A zero-row [tibble::tibble()] whose columns and types match the
#'   output of [scc()] (`by_file = FALSE`) or [scc_by_file()] (`by_file =
#'   TRUE`).
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
      weighted_complexity = double(),
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
      weighted_complexity = double(),
      bytes               = integer(),
      generated           = logical(),
      minified            = logical()
    )
  }
}
