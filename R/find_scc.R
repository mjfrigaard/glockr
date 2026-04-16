#' Find the scc binary
#'
#' Locates the `scc` executable on the system PATH and stops with an
#' informative error if it cannot be found.
#'
#' @return Invisible character string: the resolved path to `scc`.
#' @keywords internal
find_scc <- function() {
  path <- Sys.which("scc")
  if (nchar(path) == 0L) {
    stop(
      "Cannot find 'scc'. Please install it from ",
      "https://github.com/boyter/scc and ensure it is on your PATH.",
      call. = FALSE
    )
  }
  invisible(unname(path))
}
