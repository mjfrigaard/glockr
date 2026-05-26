#' Return an empty tibble with the correct schema
#'
#' Used as a safe fallback when `scc` produces no output (e.g. an empty
#' directory or no files matching the requested extensions).
#'
#' @param by_file Logical. When `TRUE` returns the per-file schema; when
#'   `FALSE` (default) returns the per-language schema.
#' @param dryness Logical. When `TRUE` includes the `dryness` column; when
#'   `FALSE` (default) the column is omitted, matching the runtime gate in
#'   [scc()] / [scc_by_file()].
#'
#' @return A zero-row [tibble::tibble()] whose columns and types match the
#'   output of [scc()] (`by_file = FALSE`) or [scc_by_file()] (`by_file =
#'   TRUE`) called with the same `dryness` flag.
empty_scc_tibble <- function(by_file = FALSE, dryness = FALSE) {
  if (!by_file) {
    result <- tibble::tibble(
      language            = character(),
      files               = integer(),
      lines               = integer(),
      code                = integer(),
      comments            = integer(),
      blanks              = integer(),
      complexity          = integer(),
      weighted_complexity = double(),
      bytes               = integer(),
      uloc                = integer(),
      dryness             = double()
    )
  } else {
    result <- tibble::tibble(
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
      uloc                = integer(),
      dryness             = double(),
      generated           = logical(),
      minified            = logical()
    )
  }

  if (!isTRUE(dryness)) result$dryness <- NULL
  result
}
