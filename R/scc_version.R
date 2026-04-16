#' Return the installed scc version string
#'
#' @return Character scalar, e.g. `"scc version 3.7.0"`.
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' scc_version()
#' }
scc_version <- function() {
  scc <- find_scc()
  res <- processx::run(scc, args = "--version", error_on_status = FALSE)
  trimws(res$stdout)
}
