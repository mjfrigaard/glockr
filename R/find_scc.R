#' Find the scc binary
#'
#' Locates the `scc` executable on the system PATH and stops with an
#' informative error if it cannot be found.
#'
#' @return Invisible character string: the resolved path to `scc`.
#'
#' @examples
#' \dontrun{
#' find_scc()
#' }
find_scc <- function() {
  path <- Sys.which("scc")
  if (nchar(path) == 0L) {
    go_path <- Sys.which("go")
    go_msg  <- if (nchar(go_path) > 0L) {
      go_ver <- tryCatch(
        trimws(system2("go", "version", stdout = TRUE, stderr = FALSE)),
        error = function(e) "go (version unknown)"
      )
      paste0("Go is installed (", go_ver, "). Install scc with:\n",
             "  go install github.com/boyter/scc/v3@latest\n",
             "Then ensure ~/go/bin is on your PATH.")
    } else {
      paste0("Go was not found on your PATH. Install Go from ",
             "https://go.dev/dl/, then run:\n",
             "  go install github.com/boyter/scc/v3@latest")
    }
    stop(
      "Cannot find 'scc' (https://github.com/boyter/scc).\n",
      go_msg,
      call. = FALSE
    )
  }
  invisible(unname(path))
}
